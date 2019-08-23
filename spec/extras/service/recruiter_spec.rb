# frozen_string_literal: true

describe Service::Recruiter do
  subject { Object.new.extend(Service::Recruiter) }

  it 'recruit with farming warning' do
    Screen::Train.stub(:new).and_return stub_train(farm_warning: true)
    subject.recruit(create_village, 2.hours)
  end

  # it 'build with farming warning' do
  #   Screen::Train.stub(:new).and_return stub_train(troops: Troop.new(spear: 100, spy: 10))
  #   subject.recruit(create_village, 2.hours)
  # end
end
