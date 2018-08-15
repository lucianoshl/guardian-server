# frozen_string_literal: true

describe Service::StartupTasks do
  it 'fill_user_information' do
    Task::PlayerMonitoringTask.new.run
    Task::PlayerMonitoringTask.new.run
  end
end
