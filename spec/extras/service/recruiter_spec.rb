# frozen_string_literal: true

describe Service::Recruiter do
  subject { Object.new.extend(Service::Recruiter) }

  it 'recruit with farming warning' do
    Screen::Train.stub(:new).and_return stub_train(farm_warning: true)
    subject.recruit(create_village, 2.hours)
  end

  it 'recruit troops' do
    build_info = {}
    build_info['spear'] = OpenStruct.new(cost: Resource.new(wood: 10, stone: 10, iron: 10), cost_time: 10)

    queue = OpenStruct.new
    queue.stable = OpenStruct.new
    queue.stable.itens = [OpenStruct.new(finish: 10)]
    
    train = stub_train(troops: Troop.new(spear: 10, spy: 10), build_info: build_info, queue: queue)
    allow(train).to receive(:resources).and_return Resource.new(wood: 100, stone: 100, iron: 100)
    Screen::Train.stub(:new).and_return train

    expect(train).to receive(:train).with(anything).and_return true

    subject.recruit(create_village, 2.hours)
  end
end
