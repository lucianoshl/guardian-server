# frozen_string_literal: true

describe Service::Simulator do

  before do
    Account.stub_account
    Service::StartupTasks.new.fill_units_information
  end

  it 'simulate_1' do
    Service::Simulator.run(spear: 5)
  end

  it 'simulate_2' do
    Troop.new(spear:20).upgrade_until_win(Troop.new(spear: 20, sword: 5), 5)
    Troop.new(spear:20).upgrade_until_win(Troop.new(spear: 20, sword: 5), 5)
  end
end
