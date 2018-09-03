# frozen_string_literal: true

describe Task::StealResourcesTask do

	before(:each) do
		Service::StartupTasks.new.first_login_event
    Screen::Place.any_instance.stub(:send_attack).and_return(Command.new(arrival: Time.now + 1.hour))
    Screen::Place.any_instance.stub(:troops).and_return(Troop.new(spy:5, light: 5, sword: 10))
    Task::StealResourcesTask.any_instance.stub(:next_returning_command).and_return(Command.new(arrival: Time.now + 1.day))
	end

  it 'test_troop_upgrade_wall_10' do
    resources = Resource.new(wood: 50, stone: 50, iron: 50)
    place = Troop.new(spear:2, sword: 10, spy: 10, light: 1)
    to_send,remaining = place.distribute(resources.total)
    expect { to_send.upgrade_until_win(place,10,99) }.to raise_error(UpgradeIsImpossibleException)
  end

  it 'StealResourcesTask' do
    Task::StealResourcesTask.new.run
  end

end
