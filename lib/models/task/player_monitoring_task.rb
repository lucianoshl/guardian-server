# frozen_string_literal: true

class Task::PlayerMonitoringTask < Task::Abstract

  runs_every 10.minutes
  def run
    nearby = Service::Map.find_nearby(Account.main.player.villages,20)

    all_villages = nearby
    all_players = nearby.values.map{|a| a.player}.compact.uniq.to_index{|a| a.id}
    all_allies = all_players.values.map{|a| a.ally}.compact.uniq.to_index{|a| a.id}

    save_or_update(Village,all_villages)
    # save_or_update(Player,all_players)
    # save_or_update(Ally,all_allies)

  end

  def save_or_update(model,index)
    list_ids = index.keys
    saved = model.in(id: list_ids).to_a

    saved_ids = saved.map(&:id)
    unsaved_ids = list_ids - saved_ids

    to_save = index.select_keys(*unsaved_ids).values.map{ |a| model.new(a.to_h)}
    Parallel.map(to_save, in_threads: 3, progress: "Saving #{model.name}") do |v|
      raise Exception.new("Error saving village #{v.errors.to_a}") if !v.save
    end

    Parallel.map(saved, in_threads: 1, progress: "Merging #{model.name}") do |v|
      v.merge_non_nil(index[v.id]).save
    end
  end



end
 