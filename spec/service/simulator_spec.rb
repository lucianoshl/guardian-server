# frozen_string_literal: true

describe Service::Simulator do

  it 'simulate_1' do
    Service::Simulator.win?(spear: 5)
  end

  it 'simulate_2' do
    Service::Simulator.win?(Troop.new(axe: 2000), defence: Troop.new(spear: 2000))
  end

  it 'test_cache' do
    method = -> { Troop.new(spear: 20).upgrade_until_win(Troop.new(spear: 20, sword: 5), 5) }
    expect { method.call }.to raise_error(UpgradeIsImpossibleException)
    expect { method.call }.to raise_error(UpgradeIsImpossibleException)
  end
end
