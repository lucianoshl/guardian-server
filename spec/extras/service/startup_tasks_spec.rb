# frozen_string_literal: true

describe Service::StartupTasks do
  subject { Service::StartupTasks.new }

  before do 
    task_stub = double(:task_stub)
    allow(Task::PlayerMonitoringTask).to receive(:new).and_return task_stub
    allow(task_stub).to receive(:run).and_return nil
    allow(task_stub).to receive(:save).and_return nil
    
    account = Account.main
    allow(account).to receive(:player=).and_return(nil)
    allow(account.player).to receive(:save).and_return(nil)
  end
  
  it 'first_login_event' do
    subject.first_login_event
  end
  
  it 'fill_user_information' do
    subject.fill_user_information
  end
  
  it 'fill_units_information' do
    subject.fill_units_information
  end
  
  it 'fill_buildings_information' do
    subject.fill_buildings_information
  end
  
  it 'create_tasks' do
    subject.create_tasks
  end
end
