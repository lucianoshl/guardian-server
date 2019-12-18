# frozen_string_literal: true

describe Troop do
  it 'test_distribute_1' do
    troop = Troop.new(spear: 76, sword: 36, spy: 83)
    result = troop.distribute(1458)
    pp result
  end

  it 'test_upgrade_1' do
    troop = Troop.new(spear: 20)
    result = troop.upgrade(Troop.new(light: 1))
    pp result
  end

  it 'test_upgrade_2' do
    troop = Troop.new(spear: 20)
    disponible = Troop.new(sword: 1)
    result = troop.upgrade(disponible)
    pp result
  end

  it 'troop +' do
    a = Troop.new(spear: 5, axe: 4)
    b = Troop.new(spear: 4, sword: 3)
    c = a + b
    expect(c.spear).to eq(9)
    expect(c.axe).to eq(4)
    expect(c.sword).to eq(3)
  end
end
