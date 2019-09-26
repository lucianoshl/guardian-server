# frozen_string_literal: true

class Task::PlayerMonitoringTask < Task::Abstract
  runs_every 10.minutes

  def run
    max_distance = Property.get('STEAL_RESOURCES_DISTANCE', 10)
    distance_border = Property.get('STEAL_RESOURCES_DISTANCE', 10) * 2
    # nearby = Service::Map.find_nearby(Account.main.player.villages, distance_border)

    # moved_villages = Village.all.pluck(:id) - nearby.keys
    # Village.in(id: moved_villages).delete_all

    # all_villages = nearby
    # all_players = nearby.values.map(&:player).compact.uniq.to_index(&:id)
    # all_allies = all_players.values.map(&:ally).compact.uniq.to_index(&:id)

    # all_players.values.map { |a| a.ally = nil }
    # all_villages.values.map { |a| a.player = nil }

    # save_or_update(Village, all_villages)
    # save_or_update(Player, all_players)
    # save_or_update(Ally, all_allies)

    my_villages = Village.my.to_a
    targets = Village.all.pluck(:id, :x, :y)
    to_create = (targets.pmap do |id, x, y|
      c_distance = my_villages.map { |v| v.distance(OpenStruct.new(x: x, y: y)) }.min
      next if c_distance > max_distance || c_distance.zero?

      [id, c_distance]
    end).compact.sort_by { |_id, distance| distance }.map { |id, _d| id }

    now = Time.zone.now
    saveds = Task::StealResourcesTask.pluck(:target_id).compact
    to_create -= saveds

    to_create.each_with_index do |id, index|
      job = Task::StealResourcesTask.new(target_id: id)
      job.next_execution = now + (10.seconds * index)
      job.save
    end
  end

  def save_or_update(model, index)
    list_ids = index.keys
    saved = model.in(id: list_ids).to_a

    saved_ids = saved.map(&:id)
    unsaved_ids = list_ids - saved_ids

    to_save = index.select_keys(*unsaved_ids).values.map do |a|
      model.new(a.to_h)
    end

    logger.info("Saving #{model.name}")
    Parallel.map(to_save, in_threads: 8) do |v|
      raise Exception, "Error saving #{model.name} #{v.errors.to_a}" unless v.save
    end

    logger.info("Merging #{model.name}")

    Parallel.map(saved, in_threads: 8) do |v|
      merged = v.merge_properties(index[v.id])
      raise Exception, "Error saving #{model.name} #{merged.errors.to_a}" unless merged.save
    end
  end
end
