# frozen_string_literal: true

module ModelStub
  def stub_village(name, _args = {})
    stub = Village.new(name: name)
    stub
  end

  def stub_report(args = {})
    wall = args[:wall] || 0
    rams_to_destroy_wall = args[:rams_to_destroy_wall] || 0
    stub = double('report')
    allow(stub).to receive(:possible_attack?).and_return(true)
    allow(stub).to receive(:rams_to_destroy_wall).and_return(rams_to_destroy_wall)
    allow(stub).to receive(:has_troops).and_return(false)
    allow(stub).to receive(:moral).and_return(100)
    allow(stub).to receive(:read=)
    allow(stub).to receive(:save)
    allow(stub).to receive(:resources).and_return(Resource.new(wood: 300, iron: 300, stone: 300))
    allow(stub).to receive(:buildings).and_return(Buildings.new(wall: wall))
    stub
  end

  def stub_target(args = {})
    status = args[:status] || 'waiting_report'

    stub = double('target')
    if args[:barbarian] != false
      player = stub_player(args)
      allow(stub).to receive(:player).and_return player
    end

    allow(stub).to receive(:barbarian?).and_return args[:barbarian] == true
    allow(stub).to receive(:distance).with(anything).and_return((@distance / 2).ceil)

    allow(stub).to receive(:status).and_return(status)
    allow(subject).to receive(:target).and_return stub
    stub
  end

  def stub_player(args = {})
    player = double('player')
    points = args[:points] || Account.main.player.points * 0.5
    ally_id = args[:ally_id]

    ally = double('ally')
    allow(ally).to receive(:id).and_return ally_id unless ally_id.nil?

    allow(player).to receive(:ally).and_return ally unless ally_id.nil?
    allow(player).to receive(:points).and_return points
    player
  end
end
