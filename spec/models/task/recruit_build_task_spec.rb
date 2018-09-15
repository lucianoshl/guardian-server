# frozen_string_literal: true

# # frozen_string_literal: true

# describe Task::RecruitBuildTask do
#   before(:each) do
#     Service::StartupTasks.new.fill_user_information
#     Service::StartupTasks.new.fill_units_information
#     Service::StartupTasks.new.fill_buildings_information
#     Screen::Train.any_instance.stub(:train).and_return(nil)
#     Screen::Main.any_instance.stub(:build).and_return(nil)
#     stub_troop = TroopModel.new(spear: 1.0 / 2, sword: 1.0 / 2, spy: 1000)
#     Village.any_instance.stub(:train_model).and_return(stub_troop)
#   end

#   it 'run recruit build task' do
#     Task::RecruitBuildTask.new.run
#   end

#   it 'run recruit build task with storage warning' do
#     Screen::Main.any_instance.stub(:storage).and_return(OpenStruct.new(warning: true))
#     Task::RecruitBuildTask.new.run
#   end

#   it 'run recruit build task with farm warning' do
#     Screen::Main.any_instance.stub(:farm).and_return(OpenStruct.new(warning: true))
#     Task::RecruitBuildTask.new.run
#   end

#   it 'run with multiple candidates' do
#     Screen::Main.any_instance.stub(:buildings).and_return(Buildings.new(main: 5, barracks: 4, market: 1))
#     Screen::Main.any_instance.stub(:in_queue?).with(anything()).and_call_original
#     Screen::Main.any_instance.stub(:in_queue?).with('barracks').and_return true
#     Screen::Main.any_instance.stub(:possible_build?).with(anything()).and_call_original
#     Screen::Main.any_instance.stub(:possible_build?).with('barracks').and_return true
#     Screen::Main.any_instance.stub(:possible_build?).with('market').and_return true

#     Village.any_instance.stub(:building_model).and_return([
#         Buildings.new(main: 1),
#         Buildings.new(main: 5, barracks: 5),
#         Buildings.new(market: 5)
#     ])

#     Screen::Main.any_instance.stub(:build).and_return(Time.now + 2.hours)
#     village = Account.main.player.villages.first
#     main_screen = Screen::Main.new(id: village.id)

#     expect(main_screen).to receive(:build).with('market')
#     expect(main_screen).not_to receive(:build).with('barracks')

#     Task::RecruitBuildTask.new.build(village, main_screen)
#   end

# end
