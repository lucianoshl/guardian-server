class Task::BuildInstantTask < Task::Abstract

  belongs_to :village

  def run
    Screen::Main.new(village: village.id).build_instant
  end
end