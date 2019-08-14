# frozen_string_literal: true

describe Service::Builder do
  subject { Object.new.extend(Service::Builder) }

  def create_main(farm_warning: false, storage_warning: false)
    main = double('main')
    buildings = Buildings.new(main: 3, barracks: 1, wood: 2, stone: 2, iron: 1)
    main.should_receive(:queue).and_return []
    allow(main).to receive(:in_queue?).with(anything).and_return false
    allow(main).to receive(:possible_build?).with(anything).and_return true

    allow(main).to receive(:farm).and_return double('farm_info', warning: farm_warning)
    allow(main).to receive(:storage).and_return double('storage_info', warning: storage_warning)
    allow(main).to receive(:buildings).and_return buildings
    allow(main).to receive(:buildings_meta).and_return({
      'wood' => { wood: 100, stone: 100, iron: 100 },
      'stone' => { wood: 50, stone: 50, iron: 50 },
      'barracks' => { wood: 10, stone: 10, iron: 10 },
    })
    main
  end

  def create_village
    basic_model = VillageModel.basic_model
    village = double('village')
    allow(village).to receive(:id).and_return 1
    allow(village).to receive(:disable_build).and_return false
    allow(village).to receive(:defined_model).and_return basic_model
    village
  end

  it 'build with farming warning' do
    main = create_main(farm_warning: true)
    main.should_receive(:build).with(:farm)
    subject.build(create_village, main)
  end

  it 'build with storage warning' do
    main = create_main(storage_warning: true)
    main.should_receive(:build).with(:storage)
    subject.build(create_village, main)
  end

  it 'farm or storage warning without resources' do
    main = create_main(storage_warning: true, farm_warning: true)
    main.should_receive(:possible_build?).with(:farm).and_return false
    main.should_receive(:possible_build?).with(:storage).and_return false
    subject.build(create_village, main)
  end

  it 'with village build disabled' do
    main = create_main
    village = create_village
    village.should_receive(:disable_build).and_return true
    subject.build(village, main)
  end

  it 'build lowest item(barracks)' do
    main = create_main
    village = create_village
    main.should_receive(:build).with(:barracks)
    subject.build(village, main)
  end
end
