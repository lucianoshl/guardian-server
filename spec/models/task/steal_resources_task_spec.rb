# frozen_string_literal: true

describe Task::StealResourcesTask do
  # before(:all) do
  #   Service::StartupTasks.new.fill_units_information
  #   Service::StartupTasks.new.fill_user_information
  # end

  # before(:each) do
  #   # Service::StartupTasks.new.first_login_event
  #   allow_any_instance_of(Screen::Place).to receive(:send_attack).and_return(Command::My.new(arrival: Time.now + 1.hour))
  #   allow_any_instance_of(Screen::Place).to receive(:troops).and_return(Troop.new(spy: 5, light: 5, sword: 10))
  #   allow_any_instance_of(Task::StealResourcesTask).to receive(:next_returning_command).and_return(Command::My.new(arrival: Time.now + 1.day))
  #   Service::Report.stub(:sync).and_return(nil)
  # end

  # it 'StealResourcesTask' do
  #   binding.pry
  #   allow_any_instance_of(Task::StealResourcesTask).to receive(:sort_by_priority).and_return([])
  #   Task::StealResourcesTask.new.run
  # end

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
