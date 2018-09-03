# frozen_string_literal: true

describe Task::RecruitBuildTask do
  before(:each) do
    Service::StartupTasks.new.fill_user_information
    Service::StartupTasks.new.fill_units_information
    Service::StartupTasks.new.fill_buildings_information
    Screen::Train.any_instance.stub(:train).and_return(nil)
    Screen::Main.any_instance.stub(:build).and_return(nil)
    stub_troop = TroopModel.new(spear: 1.0 / 2, sword: 1.0 / 2, spy: 1000)
    Village.any_instance.stub(:train_model).and_return(stub_troop)
  end

  it 'run recruit build task' do
    Task::RecruitBuildTask.new.run
  end
end
