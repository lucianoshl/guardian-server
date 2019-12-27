# frozen_string_literal: true

module ScreenHelper
  def stub_place(args = {})
    command_for_village = args[:next_leaving_command]
    troops = args[:troops] || Troop.new

    place = create_base('place', args)
    allow(place).to receive(:next_leaving_command).with(anything).and_return(command_for_village)
    allow(place).to receive(:troops_available).and_return(troops)
    allow(place).to receive(:commands).and_return(OpenStruct.new(
                                                    all: [],
                                                    returning: [],
                                                    leaving: []
                                                  ))

    command = double('command', arrival: Time.zone.now + 1.minute)
    allow(command).to receive(:origin_report=)
    allow(command).to receive(:store)
    allow(place).to receive(:send_attack).with(anything, anything).and_return(command)

    allow(Screen::Place).to receive_message_chain(:all_places, :values).and_return([])
    place
  end

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

  def stub_train(args = {})
    troops = args[:troops] || Troop.new
    build_info = args[:build_info] || { 'spy' => OpenStruct.new(active: true) }
    queue = args[:queue] || []

    train = create_base('train', args)
    allow(train).to receive(:queue).and_return queue
    allow(train).to receive(:troops).and_return troops
    allow(train).to receive(:build_info).and_return build_info
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
