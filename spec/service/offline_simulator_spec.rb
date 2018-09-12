# # frozen_string_literal: true

# describe Service::OfflineSimulator do
  
#   before do
#     Service::StartupTasks.new.fill_units_information
#   end

#   def compare_results(attack, defence, wall = 0, moral = 100)
#     screen = Screen::Simulator.new
#     screen.simulate(attack, defence, wall, moral)
#     simulation1 = screen.to_simulation
#     simulation2 = Service::OfflineSimulator.simulate(attack, defence, wall, moral)

#     expect(simulation1).to eq(simulation2)
#   end

#   it 'only_troops_pair' do
#     compare_results(Troop.new(axe: 41),Troop.new(sword: 33))
#   end


# end
