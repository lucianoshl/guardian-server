# frozen_string_literal: true

class Task::RecruitBuildTask < Task::Abstract
  include Logging
  include Service::Builder
  include Service::Recruiter
  runs_every 30.minutes

  def run
    results = Account.main.player.villages.map do |village|
      run_for_village(village)
    end
    results.compact.min || nil
  end

  def run_for_village(village)
    recruit(village, runs_every * 2) if village.disable_recruit != true

    @main = Screen::Main.new(village: village.id)
    next_execution = build(village, @main)

    return nil if next_execution.nil?

    next_execution < possible_next_execution ? next_execution : possible_next_execution
  end
end
