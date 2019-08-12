# frozen_string_literal: true

class Task::DailyBonus < Task::Abstract
  include Logging

  runs_every 1.day

  def run
    screen = Screen::DailyBonus.new
    screen.closed_chests.map do |chest|
      screen.open_chest(chest)
    end
  end
end
