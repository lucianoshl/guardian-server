# frozen_string_literal: true

class Task::EmptyTask < Task::Abstract
  def run
    nil
  end
end
