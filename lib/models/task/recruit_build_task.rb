# frozen_string_literal: true

class Task::RecruitBuildTask < Task::Abstract
  runs_every 30.minutes

  def run
    Account.main.player.villages.map do |village|
      run_for_village(village)
    end
  end

  def run_for_village village
    # binding.pry
  end
end
