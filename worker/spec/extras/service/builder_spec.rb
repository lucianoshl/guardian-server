# frozen_string_literal: true

describe Service::Builder do
  subject { Object.new.extend(Service::Builder) }

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
    main.should_receive(:build).with(:barracks)
    subject.build(create_village, main)
  end

  it 'build with completed model' do
    completed_model = VillageModel.new
    completed_model.buildings = [Buildings.new(main: 1, barracks: 1)]
    subject.build(create_village(model: completed_model), create_main)
  end
end
