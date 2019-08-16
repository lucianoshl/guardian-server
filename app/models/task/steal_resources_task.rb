# frozen_string_literal: true

class Task::StealResourcesTask < Task::Abstract
  belongs_to :village

  runs_every 10.minutes

  include Service::Targets

  def is_strong_player
    current_points = Account.main.player.points
    strong_player = if village.player.nil?
                      false
                    else
                      village.player.points > current_points * 0.6
                    end
    strong_player
  end

  def is_ally_player
    current_ally = Account.main.player.ally

    return false if current_ally.nil? || village.player.nil? || village.player.ally.nil?

    current_allies = Screen::AllyContracts.new.allies_ids << current_ally.id
    current_allies.include? village.player.ally.id
  end

  def run
    return nil if village.nil?

    @spy_is_researched = !!Screen::Train.new.build_info['spy']&.active

    @distance = Property.get('STEAL_RESOURCES_DISTANCE', 10)
    @@places = {}
    Service::Report.sync

    return send('strong') if is_strong_player
    return send('ally') if is_ally_player

    logger.info("Running for #{sort_by_priority(criteria).size} targets")
    list = sort_by_priority(criteria)

    loop do
      element = list.shift

      break if element.nil?

      distance, @origins, target = element

      logger.info('-' * 50)
      logger.info("#{list.size} targets for #{target} current_status=#{target.status} ")

      @original_status = target.status

      @range_villages = @origins.clone
      @origin = @origins.shift
      @target = target
      @target.status = 'far_away' if @origin.nil?

      begin
        send(@target.status)
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
        report = @target.latest_valid_report
        next_attack = report.time_to_produce(e.population * 25)
        report.mark_read
        send_to('waiting_resource_production', next_attack)
      rescue NotPossibleAttackBeforeIncomingException => e
        send_to('waiting_incoming', e.incoming_time)
      rescue Exception => e
        binding.pry unless Rails.env.production?
        send_to('with_error', Time.now + 10.minutes)
      end

      logger.info("Finish for #{target} #{@original_status} > #{target.status} ")
    end

    criteria = targets_criteria
    criteria = criteria.in(player_id: [nil]) unless @spy_is_researched

    sort_by_priority(criteria).map(&:last).min_by(&:next_event).next_event
  end

  def not_initialized
    waiting_report
  end

  def waiting_report
    if @origin.distance(@target) > @distance
      next_execution = Time.now + 1.day
      Village.where(status: 'far_away').update_all(next_event: next_execution)
      return send_to('far_away', next_execution)
    end

    report = @target.latest_valid_report

    return send_to('has_spies') if !report.nil? && !report.possible_attack?

    if report.nil? || report.resources.nil?
      command = place(@origin.id).commands.leaving.select { |a| a.target == @target }.first
      command.nil? ? send_spies : send_to('waiting_report', command.arrival)
    else
      report.has_troops ? send_spies : send_pillage_troop(report)
    end
  end

  def send_spies
    place_screen = place(@origin.id)
    troops = place_screen.troops
    if troops.spy >= spy_qte
      troop = Troop.new(spy: spy_qte)
      check_is_possible_attack_before_incoming(place_screen, troop)
      command = place_screen.send_attack(@target, troop)
      send_to('waiting_report', command.arrival)
    else
      send_to_waiting_spies

    end
  end

  def send_to_waiting_spies
    if @spy_is_researched
      Village.where(status: 'waiting_spies').update_all(next_event: next_returning_command.arrival)
      send_to('waiting_spies', next_returning_command.arrival)
    else
      last_report = @target.reports.last
      resource = 200
      place_troops = place.troops_available

      if place_troops.carry >= resource && (last_report.nil? || last_report.produced_resource?(resource))
        troops, _remaining = place_troops.distribute(200)
        result = troops.upgrade_until_win(place_troops)
        command = place.send_attack(@target, result)
        send_to('waiting_report', command.arrival)
      elsif place_troops.carry < resource
        Village.in(status: %w[not_initialized waiting_troops]).update_all(next_event: next_returning_command.arrival, status: 'waiting_troops')
        send_to('waiting_troops', next_returning_command.arrival)
      elsif last_report.produced_resource?(resource)
        @target.latest_valid_report&.mark_read
        send_to('waiting_resource_production', last_report.time_to_produce(resource))
      end
    end
  end

  def send_pillage_troop(report)
    total = report.resources.total
    total = 100 if total < 100
    place = place(@origin.id)

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
        raise e
      end
    end

    to_send.spy += 1 if place_troops.spy.positive?

    check_is_possible_attack_before_incoming(place, to_send)

    command = place.send_attack(@target, to_send)
    command.origin_report = report
    command.store

    send_to('waiting_report', command.arrival)
    report.read = true
    report.save
  end

  def check_is_possible_attack_before_incoming(_place, troops)
    incomings = all_places.map(&:incomings).flatten
    return if incomings.empty?

    travel_time = troops.travel_time(@target, @origin)
    next_incoming = incomings.first.arrival
    back_time = Time.now + travel_time * 2
    if back_time.to_datetime > (next_incoming - 1.minute)
      raise NotPossibleAttackBeforeIncomingException, next_incoming
    end
  end

  def send_to(status, time = Time.now)
    switch_village_stages = %w[waiting_incoming waiting_strong_troops waiting_troops waiting_resource_production waiting_spies]

    if switch_village_stages.include?(status) && @origins.size.positive?
      @origin = @origins.shift
      puts "Change village to #{@origin}".black.on_red
      send(@original_status)
      return
    end

    logger.info("Moving to #{status} until #{time}")
    time += 1.second
    village.status = status
    village.next_event = time
    village.save
  end

  def spy_qte
    village.player.nil? ? 1 : 5
  end

  def place(id = @origin.id)
    @@places[id] = Screen::Place.new(village: id) if @@places[id].nil?
    @@places[id]
  end

  def all_places
    @range_villages.map { |v| place(v.id) }
  end

  def next_returning_command
    all_commands = all_places.map(&:commands)

    result = all_commands.map(&:returning).flatten.min_by(&:arrival)
    result ||= all_commands.map(&:all).flatten.min_by(&:arrival)

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
    send_to('strong', Time.now + 1.hour)
  end

  def ally
    send_to('ally', Time.now + 1.hour)
  end

  # deprecated
  def has_troops
    send_spies
  end

  def has_spies
    send_to('has_spies', Time.now + 1.hour)
  end

  def waiting_spies
    waiting_report
  end

  def waiting_resource_production
    waiting_report
  end

  def waiting_troops
    waiting_report
  end

  def waiting_strong_troops
    waiting_report
  end

  def banned
    waiting_report
  end

  def far_away
    waiting_report
  end

  def weak_player
    waiting_report
  end

  def removed_player
    waiting_report
  end

  def invited_player
    waiting_report
  end

  def waiting_incoming
    waiting_report
  end

  def with_error
    waiting_report
  end

  def newbie_protection
    waiting_report
  end
end
