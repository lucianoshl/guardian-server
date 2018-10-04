module Service::Targets
  def update_steal_candidates
    current_player = Account.main.player
    current_ally = current_player.ally
    current_points = current_player.points

    Village.targets.in(status: ['strong', 'ally', nil]).update_all(status: 'not_initialized')

    strong_player = Player.gte(points: current_points * 0.6).pluck(:id) - [current_player.id]

    attacked_strong_player = Village.in(player_id: strong_player).pluck(:id)
    strong_villages_attacked = Report.in(target_id: attacked_strong_player).nin(dot: 'red').pluck(:target_id)

    strong_player -= Village.in(id: strong_villages_attacked.uniq).map(&:player_id)

    Village.targets.in(player_id: strong_player).update_all(status: 'strong', next_event: Time.now + 1.day)

    unless current_ally.nil?
      current_allies = Screen::AllyContracts.new.allies_ids << current_ally.id
      ally_players = Player.in(ally_id: current_allies).pluck(:id)
      Village.targets.in(player_id: ally_players).update_all(status: 'ally', next_event: Time.now + 1.day)
    end

    Village.targets.in(next_event: nil).update_all(next_event: Time.now)
  end

  def sort_by_priority(targets)
    my_villages = Account.main.player.villages
    distances = targets.map do |target|
      villages = my_villages.select { |a| target.distance(a) <= @distance }
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

  def targets_criteria
    Village.targets.order(next_event: 'asc')
  end

end