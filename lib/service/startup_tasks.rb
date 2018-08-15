# frozen_string_literal: true

class Service::StartupTasks

  def first_login_event
    fill_user_information
    fill_units_information
    create_tasks
  end

  def fill_user_information
  	main_screen = Screen::Main.new
    main_screen.player.upsert
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

  def create_tasks
    Task::PlayerMonitoringTask.new.save
  end

end
