# frozen_string_literal: true

describe Task::RecruitBuildTask do

  before(:each) do
    Service::StartupTasks.new.fill_user_information
    Service::StartupTasks.new.fill_units_information
    Service::StartupTasks.new.fill_buildings_information
    Screen::Train.any_instance.stub(:train).and_return(nil)
    Screen::Main.any_instance.stub(:build).and_return(Time.now + 10.minutes)
  end

  it 'run recruit build task' do
    Task::RecruitBuildTask.new.run
  end

end
