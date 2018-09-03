# frozen_string_literal: true

module Recruiter
  def recruit(village)
    queue_size = self.runs_every * 2
    train_screen = Screen::Train.new(village: village.id)
    model = generate_target_model(train_screen)
    resources = train_screen.resources

    now = Time.now
    queue_seconds = (train_screen.queue.to_h.map do |building,queue|
      [building,((queue&.finish || now) - now).floor]
    end).to_h

    to_train = Troop.new

    loop do
      executed = false
      model.each do |unit,qte|
        qte = qte.floor
        next if qte.zero?
        current_queue = Unit.get(unit).prod_building.to_sym
        if queue_seconds[current_queue] < queue_size
          build_info = train_screen.build_info[unit]
          if resources.include?(build_info.cost)
            to_train[unit] += 1
            model[unit] -= 1
            queue_seconds[current_queue] += build_info.cost_time
            resources -= build_info.cost
            executed = true
          end
        end
      end
      break if !executed
    end

    if to_train.total > 0
      logger.info("Recruting: #{to_train}")
      train_screen.train(to_train) 
    else
      logger.info('it is not necessary recruit any unit'.black.on_white)
    end
    
  end

  def generate_target_model(train_screen)
    buildings_pop = 5000
    model = TroopModel.new(spear: 1.0/3, sword: 1.0/3, archer: 1.0/3, spy: 1000)

    troops_population = 24000 - buildings_pop

    model.each do |unit_id,qte|
      if qte >= 1
        troops_population -= model[unit_id] * Unit.get(unit_id)[:pop]
      end
    end

    model.each do |unit_id,qte|
      if qte < 1 && Unit.get(unit_id)[:pop] > 0
        model[unit_id] = (troops_population * qte).to_f/Unit.get(unit_id)[:pop]
      end
    end

    (model - train_screen.troops).remove_negative
  end
end

module Builder
  def build village
    main = @main
    if main.storage.warning && !main.in_queue?(:storage)
      return main.possible_build?(:storage) ? main.build(:storage) : nil
    end

    if main.farm.warning && !main.in_queue?(:farm)
      return main.possible_build?(:farm) ? main.build(:farm) : nil
    end

    model = select_model_item(village.building_model,main).each.to_a

    model = model.select do |building,level|
      !main.buildings_meta[building].nil? && level > 0
    end

    model = model.sort do |a,b|
      a_meta = main.buildings_meta[a.first]
      b_meta = main.buildings_meta[b.first]
      a_cost = Resource.new(a_meta.select_keys(:wood,:stone,:iron)).total
      b_cost = Resource.new(b_meta.select_keys(:wood,:stone,:iron)).total
      a_cost <=> b_cost
    end

    model.map do |building,level|
      if main.possible_build?(building)
        return main.build(building)
      end
    end

    return nil
  end

  def select_model_item(list,main)
    finded = false
    list.each do |item|
      item.each do |building,level|
        extra_level = main.in_queue?(building) ? 1 : 0
        finded ||= (main.buildings[building] + extra_level) <= level
      end
      return item if finded
    end
  end
end

class Task::RecruitBuildTask < Task::Abstract
  include Logging
  include ::Builder
  include Recruiter
  runs_every 30.minutes

  def run
    results = Account.main.player.villages.map do |village|
      run_for_village(village)
    end
    results.compact.sort.first || nil
  end

  def run_for_village(village)
    recruit(village)
    next_execution = nil

    @main = Screen::Main.new(id: village.id)

    unless select_model_item(village.building_model,@main).nil?
      next_execution = build(village)
    end

    return nil if next_execution.nil?
    next_execution < possible_next_execution ? next_execution : possible_next_execution
  end

end
