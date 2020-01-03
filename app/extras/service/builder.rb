# frozen_string_literal: true

module Service::Builder
  include Logging

  def build(village, main)
    return unless main.queue.empty?

    if main.farm.warning && !main.in_queue?(:farm) && main.possible_build?(:farm)
      return main.build(:farm)
    end

    if main.storage.warning && !main.in_queue?(:storage) && main.possible_build?(:storage)
      return main.build(:storage)
    end

    return nil if main.farm.warning || main.storage.warning

    return nil if village.disable_build == true

    model = select_model_item(village.defined_model.buildings, main).each.to_a

    return if model.nil?

    model = model.select do |building, level|
      !main.buildings_meta[building].nil? && level.positive?
    end

    model = model.sort do |a, b|
      a_meta = main.buildings_meta[a.first]
      b_meta = main.buildings_meta[b.first]
      a_cost = Resource.new(a_meta.select_keys(:wood, :stone, :iron)).total
      b_cost = Resource.new(b_meta.select_keys(:wood, :stone, :iron)).total
      a_cost <=> b_cost
    end

    to_build_list = model.select do |building, _level|
      main.possible_build?(building)
    end

    unless to_build_list.empty?
      building, _level = to_build_list.first
      logger.info("Building #{building} in village #{village.id}")
      return main.build(building.to_sym)
    end

    nil
  end

  def select_model_item(list, main)
    finded = false
    list.each do |item|
      item = item.clone
      item.each do |building, level|
        extra_level = main.in_queue?(building) ? 1 : 0

        incomplete = (main.buildings[building] + extra_level) < level
        item[building] = 0 unless incomplete

        finded ||= incomplete
      end
      return item if finded
    end
    {}
  end
end
