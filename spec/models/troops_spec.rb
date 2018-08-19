# frozen_string_literal: true

describe Troop do

  before(:all) do
    Service::StartupTasks.new.fill_units_information
  end

  it 'test_distribute_1' do
    troop = Troop.new(spear:76,sword:36,spy:83)
    result = troop.distribute(1458)
    pp result
  end

  it 'test_upgrade_1' do
    troop = Troop.new(spear: 20)
    result = troop.upgrade(Troop.new(light: 1))
    pp result
    puts "Original carry: #{troop.carry}"
    puts "Upgrade carry: #{result.carry}"
  end

  it 'test_upgrade_2' do
    troop = Troop.new(spear: 20)
    disponible = Troop.new(sword: 1)
    result = troop.upgrade(disponible)
    pp result
    pp disponible
    puts "Original carry: #{troop.carry}"
    puts "Upgrade carry: #{result.carry}"
    puts "Upgrade carry: #{result.carry}"
  end
  
end
