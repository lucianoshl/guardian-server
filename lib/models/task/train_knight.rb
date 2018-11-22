# frozen_string_literal: true

class Task::TrainKnight < Task::Abstract
  include Logging
  include Notifier

  runs_every 6.hours

  def run
    overview = Screen::Statue::Overview.new
    times = overview.knights_data.map do |_id,info|
      run_for_knight(info)
    end
    times.compact.min
  end

  def run_for_knight(info)
    current = info['activity']['type']
    send(current,info)
  end

  def dead info
    notify("Knigth #{info['name']} is dead")
    Time.now + 1.hour
  end

  def training info
    finish_time = info['activity']['finish_time']
    finish_time.nil? ? nil : Time.at(finish_time)
  end

  def home info
    village = Village.find(info['home_village']['id'])
    regimen = info['usable_regimens'].first
    train_cost = regimen['res_cost'].to_resource
    statue = Screen::Statue::Main.new(village: village.id)
    possible_train = statue.resources.include?(train_cost * 10)
    possible_train ? statue.train(info['id'], regimen['id']) : training(info)
  end

end
