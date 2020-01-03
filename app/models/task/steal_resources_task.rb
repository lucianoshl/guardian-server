# frozen_string_literal: true

class Task::StealResourcesTask < Task::Abstract
  belongs_to :target, class_name: Village.to_s

  runs_every 10.minutes

  # include Service::Targets

  def is_strong_player
    current_points = Account.main.player.points
    strong_player = if target.player.nil?
                      false
                    else
                      target.player.points > current_points * 0.6
                    end
    strong_player
  end

  def is_ally_player
    current_ally = Account.main.player.ally

    return false if current_ally.nil? || target.player.nil? || target.player.ally.nil?

    current_allies = Screen::AllyContracts.new.allies_ids << current_ally.id
    current_allies.include? target.player.ally.id
  end

  def nearby
    @distance = Property.get('STEAL_RESOURCES_DISTANCE', 10)
    nearby = Account.main.player.villages.map do |my_village|
      [my_village, target.distance(my_village)]
    end
    nearby = nearby.select { |a| a.last <= @distance }
    nearby.sort_by(&:last).map(&:first)
  end

  def researched_spies?
    !!Screen::Train.new.build_info['spy']&.active
  end

  def run_to_state(state)
    send(equivalment_state(state))
  rescue BannedPlayerException => e
    send_to('banned', Time.now + 1.day)
  rescue NewbieProtectionException => e
    send_to('newbie_protection', e.expiration)
  rescue UpgradeIsImpossibleException => e
    send_to('waiting_strong_troops', next_returning_command.arrival)
  rescue VeryWeakPlayerException => e
    send_to('weak_player', Time.now + 1.day)
  rescue RemovedPlayerException => e
    send_to('removed_player', Time.now + 1.day)
  rescue InvitedPlayerException => e
    send_to('invited_player', e.expiration)
  rescue NeedsMinimalPopulationException => e
    report = target.latest_valid_report
    unless report.nil?
      next_attack = report.time_to_produce(e.population * 25)
      report.mark_read
    end
    send_to('waiting_resource_production', report.nil? ? (Time.zone.now + 1.hour) : next_attack)
  rescue NotPossibleAttackBeforeIncomingException => e
    send_to('waiting_incoming', e.incoming_time)
  rescue Exception => e
    binding.pry unless Rails.env.production?
    send_to('with_error', Time.now + 10.minutes)
  end

  def run
    return nil if target.nil?

    logger.info(">>>> Running for target #{target.to_s.black.on_white} with status #{target.status.black.on_white}")

    @original_status = target.status

    return strong if is_strong_player
    return ally if is_ally_player
    return far_away if (@nearby = nearby).size.zero? # TODO: optmize
    return waiting_spy_research if !target.barbarian? && !researched_spies?

    @nearby.map do |village|
      command = Screen::Place.get_place(village.id).next_leaving_command(target)
      return send_to('waiting_report', command.next_arrival) unless command.nil?
    end

    Service::Report.sync if target.status == 'waiting_report'
    @origin = @nearby.shift

    @report = target.latest_report

    if %w[red yellow].include? @report&.dot
      only_spies = @report.atk_troops.total == @report.atk_troops.spy
      next_execute = Time.zone.now + 1.day
      return send_to('has_spies', next_execute) if only_spies

      return send_to('has_troops', next_execute)
    end

    @report = target.latest_valid_report
    return run_to_state('send_spies') if @report.nil?

    run_to_state(target.status)
  end

  def send_spies
    place_screen = Screen::Place.get_place(@origin.id)
    troops = place_screen.troops_available
    if troops.spy >= spy_qte
      troop = Troop.new(spy: spy_qte)
      check_is_possible_attack_before_incoming(place_screen, troop)
      command = place_screen.send_attack(target, troop)
      send_to('waiting_report', command.arrival)
    else
      send_to_waiting_spies
    end
  end

  def send_to_waiting_spies
    if researched_spies?
      send_to('waiting_spies', next_returning_command.arrival)
    else
      last_report = target.reports.last
      resource = 200
      place = Screen::Place.get_place(@origin.id)
      place_troops = place.troops_available

      if place_troops.carry >= resource
        troops, _remaining = place_troops.distribute(200)
        result = troops.upgrade_until_win(place_troops)
        command = place.send_attack(target, result)
        send_to('waiting_report', command.arrival)
      elsif place_troops.carry < resource
        send_to('waiting_troops', next_returning_command.arrival)
      end
    end
  end

  def waiting_report
    return run_to_state('send_spies') if @report.nil? || @report.resources.nil?

    return send_to('has_spies') unless @report.possible_attack?

    @report.has_troops ? send_spies : send_pillage_troop(@report)
  end

  def send_pillage_troop(report)
    total = report.resources.total
    total = 100 if total < 100
    place = Screen::Place.get_place(@origin.id)

    distribute_type = report.buildings.wall.positive? ? :attack : :speed

    place_troops = place.troops_available
    to_send, _remaining = place_troops.distribute(total, distribute_type)

    return send_to('waiting_troops', next_returning_command.arrival) if to_send.total.zero?

    to_send.ram += report.rams_to_destroy_wall if place_troops.ram >= report.rams_to_destroy_wall

    begin
      to_send = to_send.upgrade_until_win(place_troops, report.buildings.wall, report.moral)
    rescue UpgradeIsImpossibleException => e
      if report.buildings.wall.positive? && place_troops.ram >= report.rams_to_destroy_wall
        strong_troop = Troop.new(ram: report.rams_to_destroy_wall)
        to_send = strong_troop.increment_until_win(place_troops, report.buildings.wall, report.moral)
      else
        raise UpgradeIsImpossibleException
      end
    end

    to_send.spy += 1 if place_troops.spy.positive?

    check_is_possible_attack_before_incoming(place, to_send)

    command = place.send_attack(target, to_send)
    command.origin_report = report
    command.store

    send_to('waiting_report', command.arrival)
    report.read = true
    report.save
  end

  def check_is_possible_attack_before_incoming(_place, troops)
    incomings = Screen::Place.all_places.values.map(&:incomings).flatten
    return if incomings.empty?

    travel_time = troops.travel_time(target, @origin)
    next_incoming = incomings.first.arrival
    back_time = Time.now + travel_time * 2
    if back_time.to_datetime > (next_incoming - 1.minute)
      raise NotPossibleAttackBeforeIncomingException, next_incoming
    end
  end

  def send_to(status, time = Time.now)
    switch_village_stages = %w[waiting_incoming waiting_strong_troops waiting_troops waiting_resource_production waiting_spies]

    if switch_village_stages.include?(status) && @nearby.size.positive?
      @origin = @nearby.shift
      return run_to_state(@original_status)
    end

    logger.info("Moving to #{status} until #{time}")
    time += 1.second
    target.status = status
    target.next_event = time
    target.save
    target.next_event
  end

  def spy_qte
    target.player.nil? ? 1 : 5
  end

  def nearby_places
    @nearby.map { |village| Screen::Place.get_place(village.id) }
  end

  def next_returning_command
    all_places = nearby_places.map(&:commands)

    result = all_places.map(&:returning).flatten.min_by(&:arrival)
    result ||= all_places.map(&:all).flatten.min_by(&:arrival)

    if result.nil?
      finish_recruit = Screen::Train.new.queue.to_h.values.flatten.map(&:next_finish).compact.min
      result ||= Time.now + finish_recruit unless finish_recruit.nil?
    end

    result ||= Time.now + 10.minutes
    result = Command::My.new(arrival: result) if result.class == Time
    result
  end

  def strong
    # TODO: continue steal resources task if has report
    # unless village.latest_valid_report.nil?
    #   waiting_report
    #   return
    # end
    send_to('strong', Time.now + 1.day)
  end

  def ally
    # TODO: rector this to use EVENTS
    send_to('ally', Time.now + 1.day)
  end

  def far_away
    # TODO: rector this to use EVENTS
    send_to('far_away', Time.now + 1.day)
  end

  def has_spies
    return send_to('has_spies', Time.now + 1.day) if @target.latest_report.dot != :green

    send_to('waiting_report')
  end

  def waiting_spy_research
    # TODO: rector this to use EVENTS
    send_to('waiting_spy_research', Time.now + 1.day)
  end

  def equivalment_state(state)
    equivalences = {}
    equivalences['waiting_spies'] = 'waiting_report'
    equivalences['waiting_resource_production'] = 'waiting_report'
    equivalences['waiting_troops'] = 'waiting_report'
    equivalences['waiting_strong_troops'] = 'waiting_report'
    equivalences['banned'] = 'waiting_report'
    equivalences['weak_player'] = 'waiting_report'
    equivalences['removed_player'] = 'waiting_report'
    equivalences['invited_player'] = 'waiting_report'
    equivalences['waiting_incoming'] = 'waiting_report'
    equivalences['with_error'] = 'waiting_report'
    equivalences['newbie_protection'] = 'waiting_report'
    equivalences['has_troops'] = 'waiting_report'
    equivalences[state] || state
  end

  def define_name
    "#{self.class} : #{target} > #{target&.status}"
  end
end
