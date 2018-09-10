# frozen_string_literal: true

describe Service::Simulator do
  before do
    Service::StartupTasks.new.fill_units_information
  end

  it 'simulate_1' do
    Service::Simulator.win?(spear: 5)
  end

  it 'test_cache' do
    method = -> { Troop.new(spear: 20).upgrade_until_win(Troop.new(spear: 20, sword: 5), 5) }
    expect { method.call }.to raise_error(UpgradeIsImpossibleException)
    expect { method.call }.to raise_error(UpgradeIsImpossibleException)
  end
end
