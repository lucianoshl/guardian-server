# frozen_string_literal: true

describe Task::StealResourcesTask do

  it 'test_steal_resources' do
    Task::PlayerMonitoringTask.new.run
    Task::StealResourcesTask.new.run
  end


end
