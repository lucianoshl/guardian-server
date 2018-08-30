# frozen_string_literal: true

class Task::RecruitBuildTask < Task::Abstract
  include Logging
  runs_every 30.minutes

  def run
    Account.main.player.villages.map do |village|
      run_for_village(village)
    end
    nil
  end

  def run_for_village village
    queue_size = self.runs_every * 2
    model = generate_target_model
    train_screen = Screen::Train.new(village: village.id)
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

  def generate_target_model
    buildings_pop = 5000
    model = TroopModel.new(spear: 1.0/3, sword: 1.0/3, archer: 1.0/3, spy: 1000, ram: 200)

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

    model
  end


end
