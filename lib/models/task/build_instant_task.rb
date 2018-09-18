class Task::BuildInstantTask < Task::Abstract

  belongs_to :village

  def run
    main = Screen::Main.new(village: village.id)
    main.build_instant
  end
end