# frozen_string_literal: true

class Task::StealResourcesTask < Task::Abstract
  runs_every 10.minutes

  def run
    smith_screen = Screen::Smith.new
    @spy_is_researched = smith_screen.spy_is_researched?

    @distance = Property.get('STEAL_RESOURCES_DISTANCE', 10)
    @@places = {}
    Service::Report.sync
    steal_candidates
    # TODO: refactor this criteria in a function duplicated code bellow
    criteria = Village.targets.lte(next_event: Time.now)

    criteria = criteria.in(player_id: [nil]) unless @spy_is_researched
    criteria = criteria.sort(next_event: 'asc')

    logger.info("Running for #{criteria.count} targets")

    while target = sort_by_priority(criteria).shift
      logger.info('-' * 50)
      target = target.last
      logger.info("#{criteria.count} targets now running for #{target} current_status=#{target.status} ")
      original_status = target.status
      @origin = Account.main.player.villages.first
      @target = target
      
      begin
        send(@target.status)
      rescue BannedPlayerException => e
        send_to('banned', Time.now + 1.day)
      rescue NewbieProtectionException => e
        send_to('not_initialized', e.expiration)
      rescue UpgradeIsImpossibleException => e
        send_to('waiting_strong_troops', next_returning_command.arrival)
      rescue VeryWeakPlayerException => e
        send_to('weak_player', Time.now + 1.day)
      rescue RemovedPlayerException => e
        send_to('removed_player', Time.now + 1.day)
      rescue NeedsMinimalPopulationException => e
        report = @target.latest_valid_report
        next_attack = report.time_to_produce(e.population * 25)
        report.mark_read
        send_to('waiting_resource_production', next_attack)
      rescue Exception => e
        send_to('error', Time.now + 10.minutes)
      end

      logger.info("Finish for #{target} #{original_status} > #{target.status} ")
    end

    criteria = Village.targets.order(next_event: 'asc')
    criteria = criteria.in(player_id: [nil]) unless @spy_is_researched

    # next_event = criteria.first.next_event
    criteria.first.next_event
    # possible_next_event = Time.now + 5.minutes

    # next_event > possible_next_event ? possible_next_event : next_event
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
      if place_screen.incomings.size.positive?
        travel_time = troop.travel_time(@target, @origin)
        next_incoming = place_screen.incomings.first.arrival
        back_time = Time.now + travel_time * 2
        if back_time.to_datetime > (next_incoming - 1.minute)
          return send_to('waiting_incoming', next_incoming)
        end
      end
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
      if place.troops.carry >= resource && last_report.produced_resource?(resource)
        troops, _remaining = place.troops.distribute(200)
        result = troops.upgrade_until_win(place.troops)
        command = place.send_attack(@target, result)
        send_to('waiting_report', command.arrival)
      elsif place.troops.carry < resource
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
    place.troops.knight = 0

    distribute_type = report.buildings.wall > 0 ? :attack : :speed

    to_send, remaining = place.troops.distribute(total, distribute_type)

    return send_to('waiting_troops', next_returning_command.arrival) if to_send.total.zero?

    to_send.ram += report.rams_to_destroy_wall if place.troops.ram >= report.rams_to_destroy_wall

    to_send = to_send.upgrade_until_win(place.troops, report.buildings.wall, report.moral)

    to_send.spy += 1 if place.troops.spy > 0

    unless place.incomings.empty?
      travel_time = to_send.travel_time(@target, @origin)
      next_incoming = place.incomings.first.arrival
      back_time = Time.now + travel_time * 2
      if back_time.to_datetime > (next_incoming - 1.minute)
        return send_to('waiting_incoming', next_incoming)
      end
    end

    command = place.send_attack(@target, to_send)
    send_to('waiting_report', command.arrival)
    report.read = true
    report.save
  end

  def send_to(status, time = Time.now)
    logger.info("Moving to #{status} until #{time}")
    time += 1.second
    @target.status = status
    @target.next_event = time
    @target.save
  end

  def spy_qte
    # 1
    # binding.pry
    # TODO: make this based in simulator
    @target.player.nil? ? 1 : 5
  end

  def steal_candidates
    current_player = Account.main.player
    current_ally = current_player.ally
    current_points = current_player.points

    Village.targets.in(status: ['strong', 'ally', nil]).update_all(status: 'not_initialized')


    strong_player = Player.gte(points: current_points * 0.6).pluck(:id) - [current_player.id]

    attacked_strong_player = Village.in(player_id: strong_player).pluck(:id)
    strong_villages_attacked = Report.in(target_id: attacked_strong_player).select(&:possible_attack?).to_a

    strong_player -= strong_villages_attacked.map{|a| a.target.player.id}

    Village.targets.in(player_id: strong_player).update_all(status: 'strong', next_event: Time.now + 1.day)

    unless current_ally.nil?
      ally_players = Player.where(ally_id: current_ally.id).pluck(:id)
      Village.targets.in(player_id: ally_players).update_all(status: 'ally', next_event: Time.now + 1.day)
    end
    Village.targets.in(next_event: nil).update_all(next_event: Time.now)

    result = Village.targets.lte(next_event: Time.now).to_a

    sort_by_priority(result)
  end

  def sort_by_priority(targets)
    villages = Account.main.player.villages
    distances = targets.map do |target|
      villages = villages.select { |a| target.distance(a) <= 20 }
      villages = villages.sort { |a, b| target.distance(a) <=> target.distance(b) }

      next if villages.empty?
      [
        villages.first.distance(target),
        villages,
        target
      ]
    end

    distances.compact.sort_by(&:first)
  end

  def place(id = @origin.id)
    @@places[id] = Screen::Place.new(village: id) if @@places[id].nil?
    @@places[id]
  end

  def next_returning_command
    result = place(@origin.id).commands.returning.first
    result ||= place(@origin.id).commands.all.first

    if result.nil?
      finish_recruit = Screen::Train.new.queue.to_h.values.flatten.map(&:next_finish).compact.min
      result ||= Time.now + finish_recruit unless finish_recruit.nil?
    end

    result ||= Time.now + 10.minutes
    result = Command.new(arrival: result) if result.class == Time
    result
  end

  def strong
    unless @target.latest_valid_report.nil?
      waiting_report
      return
    end
    send_to('strong', Time.now + 1.hour)
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

  def waiting_incoming
    waiting_report
  end

  def error
    waiting_report
  end
  
end
