# frozen_string_literal: true

describe Task::RecruitBuildTask do

  before(:each) do
    Service::StartupTasks.new.fill_user_information
    Service::StartupTasks.new.fill_units_information
    Service::StartupTasks.new.fill_buildings_information
  end

  it 'run recruit build task' do
    # Task::RecruitBuildTask.new.run
  end

end
