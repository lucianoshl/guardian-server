# frozen_string_literal: true

describe Troop do
  before(:each) do
    Service::StartupTasks.new.fill_units_information
  end

  it 'test_distribute_1' do
    troop = Troop.new(spear: 76, sword: 36, spy: 83)
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
    puts "Original carry: #{troop.carry}"
    puts "Upgrade carry: #{result.carry}"
    puts "Upgrade carry: #{result.carry}"
  end

  # it 'error_01' do
  #   troop = Troop.new(spear:22, axe:3)
  #   disponible = Troop.new(spear:13, sword:10, axe: 1, spy:11)
  #   result = troop.upgrade(disponible)

  # end

  # it 'test_upgrade_until_win_1' do
  #   troop = Troop.from_a([8, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  #   disponible = Troop.from_a([8, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  #   result = troop.upgrade_until_win(disponible)
  #   puts "Troop     : #{troop.to_s}"
  #   puts "disponible: #{disponible.to_s}"
  #   puts "result    : #{result.to_s}"
  #   disponible - result
  # end
end
