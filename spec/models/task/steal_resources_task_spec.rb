# frozen_string_literal: true

describe Task::StealResourcesTask do
  subject { Task::StealResourcesTask.new }

  before :each do
    allow(Account.main).to receive_message_chain(:player, :points).and_return 1000
  end

  def stub_target(args = {})
    stub = double('target')
    player = stub_player(args)

    allow(stub).to receive(:player).and_return player
    allow(subject).to receive(:village).and_return stub
    stub
  end

  def stub_player(args = {})
    player = double('player')
    points = args[:points] || 500
    ally_id = args[:ally_id]

    ally = double('ally')
    allow(ally).to receive(:id).and_return ally_id unless ally_id.nil?

    allow(player).to receive(:ally).and_return ally unless ally_id.nil?
    allow(player).to receive(:points).and_return points
    player
  end

  it 'with strong player' do
    target = stub_target(points: Account.main.player.points * 100)
    target.should_receive(:status=).with('strong')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with ally player' do
    allow(Account.main).to receive(:player).and_return(stub_player(ally_id: 10))
    target = stub_target(ally_id: 10, points: Account.main.player.points * 0.5)
    target.should_receive(:status=).with('ally')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end
end
