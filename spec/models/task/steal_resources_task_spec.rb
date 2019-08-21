# frozen_string_literal: true

describe Task::StealResourcesTask do
  subject { Task::StealResourcesTask.new }

  before :each do
    @distance = 10
    allow(Property).to receive(:get).with('STEAL_RESOURCES_DISTANCE', 10).and_return @distance

    allow(Account.main).to receive_message_chain(:player, :points).and_return 3000
    allow(Account.main).to receive_message_chain(:player, :ally).and_return nil

    allow(Account.main).to receive_message_chain(:player, :villages).and_return [
      stub_village('my_001'),
      stub_village('my_002'),
      stub_village('my_003')
    ]

    screen = train_screen(build_info: { 'spy' => OpenStruct.new(active: true) })
    allow(Screen::Train).to receive(:new).and_return(screen)
    allow_any_instance_of(Screen::Place).to receive(:has_command_for_village).with(anything).and_return(nil)
    allow(Service::Report).to receive(:sync)
  end

  def stub_village(name, _args = {})
    stub = Village.new(name: name)
    stub
  end

  def stub_report(_args = {})
    stub = double('report')
    allow(stub).to receive(:possible_attack?).and_return(true)
    allow(stub).to receive(:rams_to_destroy_wall).and_return(0)
    allow(stub).to receive(:has_troops).and_return(false)
    allow(stub).to receive(:moral).and_return(100)
    allow(stub).to receive(:read=)
    allow(stub).to receive(:save)
    allow(stub).to receive(:resources).and_return(Resource.new(wood: 300, iron: 300, stone: 300))
    allow(stub).to receive(:buildings).and_return(Buildings.new(wall: 0))
    stub
  end

  def stub_target(args = {})
    status = args[:status] || 'waiting_report'

    stub = double('target')
    player = stub_player(args)
    allow(stub).to receive(:distance).with(anything).and_return((@distance / 2).ceil)

    allow(stub).to receive(:status).and_return(status)
    allow(stub).to receive(:player).and_return player
    allow(stub).to receive(:barbarian?).and_return false
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

  it 'with strong player' do
    target = stub_target(points: Account.main.player.points * 100)
    target.should_receive(:status=).with('strong')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with ally player' do
    allow(Account.main).to receive(:player).and_return(stub_player(ally_id: 10))
    target = stub_target(ally_id: 10)
    target.should_receive(:status=).with('ally')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with far way barbarian village' do
    target = stub_target
    target.should_receive(:player).and_return(nil)
    allow(target).to receive(:distance).with(anything).and_return(@distance + 1)

    target.should_receive(:status=).with('far_away')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with player but without spy research' do
    target = stub_target
    screen = train_screen(build_info: { 'spy' => OpenStruct.new(active: false) })
    allow(Screen::Train).to receive(:new).and_return(screen)

    target.should_receive(:status=).with('waiting_spy_research')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with existing command' do
    target = stub_target
    command = double('command')
    command.should_receive(:next_arrival).and_return Time.now

    allow_any_instance_of(Screen::Place).to receive(:has_command_for_village).with(anything).and_return(command)

    target.should_receive(:status=).with('waiting_report')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'without report' do
    target = stub_target
    allow(target).to receive(:latest_valid_report).and_return(nil)
    allow_any_instance_of(Screen::Place).to receive(:troops).and_return(Troop.new(spy: 50))

    target.should_receive(:status=).with('waiting_report')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'without report and spies' do
    target = stub_target
    allow(target).to receive(:latest_valid_report).and_return(nil)
    allow_any_instance_of(Screen::Place).to receive(:troops).and_return(Troop.new(spy: 0))

    allow(target).to receive(:status).and_return('send_spies')

    target.should_receive(:status=).with('waiting_spies')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'target waiting_report' do
    target = stub_target(status: 'waiting_report')

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 5, spear: 100, light: 50))
    allow(target).to receive(:latest_valid_report).and_return(stub_report)

    target.should_receive(:status=).with('waiting_report')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'attack with report without troops troops' do
    target = stub_target(status: 'waiting_report')

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 5, spear: 100, light: 50))
    allow(target).to receive(:latest_valid_report).and_return(stub_report)

    target.should_receive(:status=).with('waiting_report')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'attack with report with wall and strong troops' do
    target = stub_target(status: 'waiting_report')

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 5, spear: 100, light: 50))
    allow_any_instance_of(Troop).to receive(:upgrade_until_win)
    allow(target).to receive(:latest_valid_report).and_return(stub_report)

    target.should_receive(:status=).with('waiting_report')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

end
