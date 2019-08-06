# frozen_string_literal: true

module Service::Targets
  include Logging

  def update_steal_candidates
    logger.info('update_steal_candidates: start')
    current_player = Account.main.player
    current_ally = current_player.ally
    current_points = current_player.points

    Village.targets.in(status: ['strong', 'ally', nil]).update_all(status: 'not_initialized')

    strong_player = Player.gte(points: current_points * 0.6).pluck(:id) - [current_player.id]

    Village.targets.in(player_id: strong_player).update_all(status: 'strong', next_event: Time.now + 1.day)

    unless current_ally.nil?
      current_allies = Screen::AllyContracts.new.allies_ids << current_ally.id

      ally_players = Player.in(ally_id: current_allies).pluck(:id)
      Village.targets.in(player_id: ally_players).update_all(status: 'ally', next_event: Time.now + 1.day)
    end

    result = Village.targets.in(next_event: nil).update_all(next_event: Time.now)
    logger.info('update_steal_candidates: end')
    result
  end

  def sort_by_priority(targets)
    logger.info('sort_by_priority: start')
    my_villages = Village.my.to_a.clone
    logger.info("sort_by_priority: targets #{targets.count}")
    targets = targets.to_a

    distances = targets.each_with_index.to_a.pmap do |target, index|
      logger.debug("#{targets.size}/#{index}")
      villages = my_villages.select { |a| target.distance(a) <= @distance }
      villages = villages.sort { |a, b| target.distance(a) <=> target.distance(b) }

      next if villages.empty?

      [
        villages.first.distance(target),
        villages,
        target
      ]
    end
    logger.info('sort_by_priority: end')
    distances.compact.sort_by(&:first)
  end

  def targets_criteria
    Village.targets.order(next_event: 'asc')
  end
end
