# frozen_string_literal: true

describe Task::StealResourcesTask do

	before(:each) do
		Account.stub_account
		Service::StartupTasks.new.fill_buildings_information
		Service::StartupTasks.new.fill_units_information
	end

  it 'test_troop_upgrade_wall_10' do
   	resources = Resource.new(wood: 50, stone: 50, iron: 50)
   	place = Troop.new(spear:2, sword: 10, spy: 10, light: 1)
  	to_send,remaining = place.distribute(resources.total)
    expect { to_send.upgrade_until_win(place,10) }.to raise_error(UpgradeIsImpossibleException)
  end

end
