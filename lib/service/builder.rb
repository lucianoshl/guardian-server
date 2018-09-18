module Service::Builder
  def build(village, main)

    if main.farm.warning && !main.in_queue?(:farm)
      return main.possible_build?(:farm) ? main.build(:farm) : nil
    end

    if main.storage.warning && !main.in_queue?(:storage)
      return main.possible_build?(:storage) ? main.build(:storage) : nil
    end

    model = select_model_item(village.building_model, main).each.to_a

    model = model.select do |building, level|
      !main.buildings_meta[building].nil? && level > 0
    end

    model = model.sort do |a, b|
      a_meta = main.buildings_meta[a.first]
      b_meta = main.buildings_meta[b.first]
      a_cost = Resource.new(a_meta.select_keys(:wood, :stone, :iron)).total
      b_cost = Resource.new(b_meta.select_keys(:wood, :stone, :iron)).total
      a_cost <=> b_cost
    end

    model.map do |building, _level|
      if main.possible_build?(building)
        logger.info("Building #{building} in village #{village.id}")
        return main.build(building)
      end
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
    nil
  end
end