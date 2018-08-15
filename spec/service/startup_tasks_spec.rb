# frozen_string_literal: true

describe Service::StartupTasks do
  it 'test_evolution' do
    Task::PlayerMonitoringTask.new.run
    village = Village.first
    village.points += 20
    village.save
    Task::PlayerMonitoringTask.new.run
  end

  it 'test_startup' do
  	Service::StartupTasks.new.first_login_event
  	puts "JOB : #{Task::Abstract.first.job}"
  end


end
