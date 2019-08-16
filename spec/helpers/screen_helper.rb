# frozen_string_literal: true

module ScreenHelper
  def create_main(args = {})
    buildings_meta = args[:buildings_meta]

    buildings_meta ||= {
      'wood' => { wood: 100, stone: 100, iron: 100 },
      'stone' => { wood: 50, stone: 50, iron: 50 },
      'barracks' => { wood: 10, stone: 10, iron: 10 }
    }

    main = create_base('main', args)
    buildings = Buildings.new(main: 3, barracks: 1, wood: 2, stone: 2, iron: 1)
    main.should_receive(:queue).and_return []
    allow(main).to receive(:in_queue?).with(anything).and_return false
    allow(main).to receive(:possible_build?).with(anything).and_return true

    allow(main).to receive(:buildings).and_return buildings
    allow(main).to receive(:buildings_meta).and_return(buildings_meta)
    main
  end

  def train_screen(args = {})
    troops = args[:troops] || Troop.new
    build_info = args[:build_info]

    train = create_base('train', args)
    allow(train).to receive(:queue).and_return []
    allow(train).to receive(:troops).and_return troops
    allow(train).to receive(:build_info).and_return build_info unless build_info.nil?
    train
  end

  def create_base(name = 'without_name', args)
    farm_warning = args[:farm_warning] || false
    storage_warning = args[:storage_warning] || false

    base = double(name)
    farm_info = double('farm_info', warning: farm_warning)
    allow(farm_info).to receive(:percent).and_return 90 if farm_warning

    allow(base).to receive(:farm).and_return farm_info
    allow(base).to receive(:storage).and_return double('storage_info', warning: storage_warning)
    base
  end
end
