# frozen_string_literal: true

class Task::StealResourcesTask < Task::Abstract

  runs_every 10.minutes
  
  def run
    @@places = {}
    Service::Report.sync
  	steal_candidates.map do |distance,candidates,target|
      # this is not thread safe!!
      @origin = candidates.first
      @target = target
      begin
        self.send(@target.status)
      rescue NewbieProtectionException => e
        send_to('not_initialized',e.expiration)
      end
  	end
  end

  def not_initialized
    report = @target.latest_valid_report
    if (report.nil?)
      send_spies
    else
      report.has_troops ? send_to('has_troops') : send_pillage_troop(report)
    end
  end

  def send_spies
    place_screen = place(@origin.id)
    troops = place_screen.troops
    if troops.spy >= spy_qte
      command = place_screen.send_attack(@target,Troop.new(spy: spy_qte))
      send_to('waiting_report',command.arrival)
    else
      send_to('waiting_spies')
    end
  end

  def send_pillage_troop(report)
    total = report.resources.total
    place = place(@origin.id)
    to_send,remaining = place.troops.distribute(total)
    loop do
      win = Service::Simulator.run(to_send)
      break if win
      remaining = place.troops - to_send
      new_troop = to_send.upgrade(remaining)
      if new_troop == to_send
        binding.pry
      else
        to_send = new_troop
      end
    end

    if (place.troops.spy > 0)
      to_send.spy += 1
    end

    command = place.send_attack(@target,to_send)
    send_to('waiting_report',command.arrival)
    report.read = true
    report.save
  end

  def send_to(status,time = Time.now)
    time += 1.second
    @target.status = status
    @target.next_event = time
    @target.save
  end

  def spy_qte
    # TODO: make this based in simulator
    @target.player.nil? ? 1 : 5
  end

  def waiting_spies
    binding.pry
  end

  def steal_candidates
    current_player = Account.main.player
    current_ally = current_player.ally
    current_points = current_player.points

    Village.targets.in(status: ['strong','ally',nil]).update_all(status: 'not_initialized')


    strong_player = Player.gte(points: current_points*0.6).pluck(:id) - [current_player.id]
    Village.targets.in(player_id: strong_player).update_all(status: 'strong')

    if !current_ally.nil?
      ally_players = Player.where(ally_id: current_ally.id).pluck(:id)
      Village.targets.in(player_id: ally_players).update_all(status: 'ally')
    end

    result = Village.targets.lte(next_event: Time.now).to_a + Village.targets.in(next_event: nil).to_a

    sort_by_priority(result)

  end

  def sort_by_priority(targets)
    villages = Account.main.player.villages
    distances = targets.map do |target|
      villages = villages.select{|a| target.distance(a) <= 20 }
      villages = villages.sort{|a,b| target.distance(a) <=> target.distance(b) }

      unless villages.empty?
        [
          villages.first.distance(target),
          villages,
          target
        ]
      end
    end

    distances.compact.sort{|a,b| a.first <=> b.first }
  end

  def strong
    send_to('strong',Time.now + 1.day)
  end

  def places(id)
    if @@place[id].nil?
      @@place[id] = Screen::Place.new(village: id)
    end
    @@place[id]
  end

end
