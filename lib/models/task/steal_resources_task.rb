# frozen_string_literal: true

class Task::StealResourcesTask < Task::Abstract
  runs_every 10.minutes
  include Logging

  def run
    @spy_is_researched = Screen::Smith.spy_is_researched?
    @@places = {}
    Service::Report.sync
    steal_candidates
    criteria = Village.targets.lte(next_event: Time.now)

    criteria = criteria.in(player_id: [nil]) unless @spy_is_researched
    criteria = criteria.sort(next_event: 'asc')

    logger.info("Running for #{criteria.count} targets")

    while target = criteria.first do
      logger.info("#{criteria.count} targets now running for #{target} current_status=#{target.status} ")
      original_status = target.status
      @origin = Account.main.player.villages.first
      @target = target
      binding.pry if !target.next_event.nil? && target.next_event > Time.now
      begin
        send(@target.status)
      rescue BannedPlayerException => e
        send_to('banned', Time.now + 1.day)
      rescue NewbieProtectionException => e
        send_to('not_initialized', e.expiration)
      rescue UpgradeIsImpossibleException => e
        send_to('waiting_strong_troops', next_returning_command.arrival)
      rescue NeedsMinimalPopulationException => e
        # TODO: calculate resource production
        send_to('waiting_resource_production', Time.now + 1.hour)
      end

      logger.info("Finish for #{target} #{original_status} > #{target.status} ")
    end

    next_event = Village.targets.order(next_event: 'asc').first.next_event
    possible_next_event = Time.now + 5.minutes

    next_event > possible_next_event ? possible_next_event : next_event
  end

  def not_initialized
    waiting_report
  end

  def waiting_report
    report = @target.latest_valid_report
    if report.nil? || report.resources.nil?
      command = place(@origin.id).commands.leaving.select { |a| a.target == @target }.first
      command.nil? ? send_spies : send_to('waiting_report', command.arrival)
    else
      report.has_troops ? send_to('has_troops') : send_pillage_troop(report)
    end
  end

  def send_spies
    place_screen = place(@origin.id)
    troops = place_screen.troops
    if troops.spy >= spy_qte
      command = place_screen.send_attack(@target, Troop.new(spy: spy_qte))
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
      wait_report_production = last_report.nil? ? false : last_report.full_pillage == false
      if place.troops.carry >= 200 && !wait_report_production
        troops, remaining = place.troops.distribute(200)
        result = troops.upgrade_until_win(place.troops)
        command = place.send_attack(@target, result)
        send_to('waiting_report', command.arrival)
      elsif wait_report_production
        send_to('waiting_resource_production', Time.now + 2.hour)
      else
        Village.in(status: %w[not_initialized waiting_troops]).update_all(next_event: next_returning_command.arrival, status: 'waiting_troops')
        send_to('waiting_troops', next_returning_command.arrival)
      end
    end
  end

  def send_pillage_troop(report)
    total = report.resources.total
    total = 100 if total < 100
    place = place(@origin.id)

    to_send, remaining = place.troops.distribute(total)

    return send_to('waiting_troops', next_returning_command.arrival) if to_send.total.zero?

    to_send = to_send.upgrade_until_win(place.troops)

    to_send.spy += 1 if place.troops.spy > 0

    command = place.send_attack(@target, to_send)
    send_to('waiting_report', command.arrival)
    report.read = true
    report.save
  end

  def send_to(status, time = Time.now)
    time += 1.second
    @target.status = status
    @target.next_event = time
    @target.save
  end

  def spy_qte
    1
    # binding.pry
    # TODO: make this based in simulator
    # @target.player.nil? ? 1 : 5
  end

  def steal_candidates
    current_player = Account.main.player
    current_ally = current_player.ally
    current_points = current_player.points

    Village.targets.in(status: ['strong', 'ally', nil]).update_all(status: 'not_initialized')

    strong_player = Player.gte(points: current_points * 0.6).pluck(:id) - [current_player.id]
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

  def strong
    send_to('strong', Time.now + 1.day)
  end

  def has_troops
    send_to('has_troops', Time.now + 1.hour)
  end

  def place(id = @origin.id)
    @@places[id] = Screen::Place.new(village: id) if @@places[id].nil?
    @@places[id]
  end

  def next_returning_command
    place(@origin.id).commands.returning.first || place(@origin.id).commands.all.first
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
end
