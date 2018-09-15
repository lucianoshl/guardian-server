# frozen_string_literal: true

# # frozen_string_literal: true

# describe Service::StartupTasks do
#   before(:all) do
#     Account.main.player = player = Player.new
#     player.villages = []
#     player.villages << Village.new(x: 500, y: 500)
#     player.villages << Village.new(x: 400, y: 400)
#     player.villages << Village.new(x: 510, y: 510)
#   end

#   it 'test_evolution' do
#     Task::PlayerMonitoringTask.new.run
#     village = Village.first
#     village.points += 20
#     village.save
#     Task::PlayerMonitoringTask.new.run
#   end
# end
