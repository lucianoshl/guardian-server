# frozen_string_literal: true

describe Task::StealResourcesTask do
  subject { Task::StealResourcesTask.new }

  def stub_target(args= {})
    stub = double('target')
    player = stub_player(args)

    allow(stub).to receive(:player).and_return player
    allow(subject).to receive(:village).and_return stub
    stub
  end

  def stub_player(args)
    player = double('player')
    points = args[:points] || 500
    ally_id = args[:ally_id]

    allow(player).to receive_message_chain(:ally,:id).and_return ally_id unless ally_id.nil?
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

  # it 'with ally player' do
  #   target = stub_target(ally_id: 10)
  #   target.should_receive(:status=).with('strong')
  #   target.should_receive(:next_event=).with(anything)
  #   target.should_receive(:save)
  #   subject.run
  # end

end
