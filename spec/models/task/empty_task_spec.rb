# frozen_string_literal: true

describe Task::EmptyTask do
  it 'Task::EmptyTask' do
    Task::EmptyTask.new.execute
  end
end
