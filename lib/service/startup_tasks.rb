# frozen_string_literal: true

class Service::StartupTasks
  def first_login_event
    fill_user_information
    fill_units_information
    fill_buildings_information
    create_tasks
  end

  def fill_user_information
    main_account = Account.main

    main_screen = Screen::Main.new
    main_screen.player.upsert

    main_account.player = main_screen.player
    main_account.player.save

    main_screen.village.player = main_screen.player
    main_screen.village.upsert

    Screen::GuestInfoPlayer.new(id: main_screen.player.id).villages.map(&:upsert)
  end

  def fill_units_information
    unit_data = Screen::UnitInfo.new.json['unit_data']
    units = unit_data.map do |_k, v|
      Unit.new(v).upsert
    end
  end

  def fill_buildings_information
    names = Screen::Main.new.buildings_labels
    page = Mechanize.new.get("https://#{Account.main.world}.tribalwars.com.br/interface.php?func=get_building_info")
    buildings = page.search('config > *').map do |item|
      attributes = item.search('*').map { |a| [a.name, a.text.to_f] }.to_h
      attributes['id'] = item.name
      attributes['name'] = names[attributes['id']]
      Building.new attributes
    end
    buildings.map(&:upsert)
  end

  def create_tasks
    monitor_task = Task::PlayerMonitoringTask.new
    monitor_task.run
    monitor_task.save
    Village.my.map do |village|
      village.reserved_troops = Troop.new(knight: 1)
      village.save
    end
    Task::RecruitBuildTask.new.save
    Task::StealResourcesTask.new.save
    Task::TrainKnight.new.save
  end
end
