# frozen_string_literal: true

describe Task::StealResourcesTask do
  before(:all) do
    Service::StartupTasks.new.first_login_event
  end

  before(:each) do
    Service::StartupTasks.new.first_login_event
    Screen::Place.any_instance.stub(:send_attack).and_return(Command.new(arrival: Time.now + 1.hour))
    Screen::Place.any_instance.stub(:troops).and_return(Troop.new(spy: 5, light: 5, sword: 10))
    Task::StealResourcesTask.any_instance.stub(:next_returning_command).and_return(Command.new(arrival: Time.now + 1.day))
  end

  it 'StealResourcesTask' do
    Task::StealResourcesTask.new.run
  end

  # it 'StealResourcesTask1' do
  #   v = Village.all.to_a[1..1]
  #   v[0].status = 'not_initialized'
  #   v[0].save

  #   Task::StealResourcesTask.any_instance.stub(:sort_by_priority).and_return( v.map{|a| [a]} )

  #   allow(Property).to receive(:get).with(anything(),anything()).and_call_original
  #   allow(Property).to receive(:get).with('STEAL_RESOURCES_DISTANCE',10) { 9999 }

  #   Task::StealResourcesTask.new.run
  # end
end
