# frozen_string_literal: true

module Service::Recruiter
  include Logging

  def recruit(village)
    return if village.points < 200

    train_screen = Screen::Train.new(village: village.id)

    if train_screen.farm.warning
      logger.info("Stop recruiting because farm warning (#{train_screen.farm.percent})")
      return
    end

    model = generate_target_model(train_screen, village)

    now = Time.now
    queue_seconds = (train_screen.queue.to_h.map do |building, queue|
      [building, ((queue&.finish || now) - now).floor]
    end).to_h

    to_train = define_units_to_train(model, train_screen, queue_seconds)

    if to_train.total > 0
      logger.info("Recruting: #{to_train}")
      train_screen.train(to_train)
    end
  end

  def define_units_to_train(model, train_screen, queue_seconds)
    result = Troop.new
    queue_size = runs_every * 2
    resources = train_screen.resources
    loop do
      executed = false
      model.each do |unit, qte|
        qte = qte.floor
        next if qte.zero?
        current_queue = Unit.get(unit).prod_building.to_sym
        next unless queue_seconds[current_queue] < queue_size
        build_info = train_screen.build_info[unit]
        next if build_info.nil?
        next unless resources.include?(build_info.cost)
        result[unit] += 1
        model[unit] -= 1
        queue_seconds[current_queue] += build_info.cost_time
        resources -= build_info.cost
        executed = true
      end
      break unless executed
    end
    result
  end

  def generate_target_model(train_screen, village)
    buildings_pop = 5000
    model = village.defined_model.train

    troops_population = 24_000 - buildings_pop

    model.each do |unit_id, qte|
      troops_population -= model[unit_id] * Unit.get(unit_id)[:pop] if qte >= 1
    end

    model.each do |unit_id, qte|
      if qte < 1 && Unit.get(unit_id)[:pop] > 0
        model[unit_id] = (troops_population * qte).to_f / Unit.get(unit_id)[:pop]
      end
    end

    (model - train_screen.troops).remove_negative
  end
end
