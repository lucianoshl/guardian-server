# frozen_string_literal: true

class Task::PlayerMonitoringTask < Task::Abstract
  runs_every 10.minutes

  def run
    nearby = Service::Map.find_nearby(Account.main.player.villages, 20)

    all_villages = nearby
    all_players = nearby.values.map(&:player).compact.uniq.to_index(&:id)
    all_allies = all_players.values.map(&:ally).compact.uniq.to_index(&:id)

    all_players.values.map { |a| a.ally = nil }
    all_villages.values.map { |a| a.player = nil }

    save_or_update(Village, all_villages)
    save_or_update(Player, all_players)
    save_or_update(Ally, all_allies)
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
      merged = v.merge_non_nil(index[v.id])
      raise Exception, "Error saving #{model.name} #{merged.errors.to_a}" unless merged.save
    end
  end
end
