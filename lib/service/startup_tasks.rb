# frozen_string_literal: true

class Service::StartupTasks

  def first_login_event
    fill_user_information
    fill_units_information
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
  end

  def fill_units_information
    client = Client::Logged.mobile
    unit_data = JSON.parse(client.get("/game.php?screen=unit_info&ajax=data").body)['unit_data']
    units = unit_data.map do |k,v|
        Unit.new(v).save
    end
  end

  def fill_buildings_information
    page = Mechanize.new.get("http://br.twstats.com/#{Account.main.world}/index.php?page=buildings")
    buildings = page.search('.r1,.r2').map do |row|
      building = Building.new

      column = row.search('td').map(&:text) 

      building.id = row.search('a').attr('href').value.scan(/detail=(.+)/).first.first
      building.name = column[0]

      building.max_level = column[1].to_i
      building.min_level = column[2].to_i

      building.wood = column[3].to_i
      building.stone = column[4].to_i
      building.iron = column[5].to_i
      building.pop = column[6].to_i

      building.wood_factor = column[7].to_f
      building.stone_factor = column[8].to_f
      building.iron_factor = column[9].to_f
      building.pop_factor = column[10].to_f
      building.build_time_factor = column[12].to_f
      building
    end
    buildings.map(&:save)
  end

  def create_tasks
    monitor_task = Task::PlayerMonitoringTask.new
    monitor_task.run
    monitor_task.save
  end

end
