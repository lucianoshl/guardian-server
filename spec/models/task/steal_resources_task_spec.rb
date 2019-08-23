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

  it 'with strong player' do
    target = stub_target(points: Account.main.player.points * 100)
    target.should_receive(:status=).with('strong')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with banned player' do
    target = stub_target

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 50))
    allow(target).to receive(:latest_valid_report).and_return(nil)
    allow_any_instance_of(Screen::Place).to receive(:send_attack).with(anything,anything).and_raise(BannedPlayerException)

    target.should_receive(:status=).with('banned')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with newbie protection player' do
    target = stub_target

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 50))
    allow(target).to receive(:latest_valid_report).and_return(nil)
    
    allow_any_instance_of(Screen::Place).to receive(:send_attack).with(anything,anything).and_raise(NewbieProtectionException.new('termina ago 22, 2019 20:16:10.'))

    target.should_receive(:status=).with('newbie_protection')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with weak player' do
    target = stub_target

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 50))
    allow(target).to receive(:latest_valid_report).and_return(nil)
    allow_any_instance_of(Screen::Place).to receive(:send_attack).with(anything,anything).and_raise(VeryWeakPlayerException)

    target.should_receive(:status=).with('weak_player')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with removed player' do
    target = stub_target

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 50))
    allow(target).to receive(:latest_valid_report).and_return(nil)
    allow_any_instance_of(Screen::Place).to receive(:send_attack).with(anything,anything).and_raise(RemovedPlayerException)

    target.should_receive(:status=).with('removed_player')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with invited player' do
    target = stub_target

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 50))
    allow(target).to receive(:latest_valid_report).and_return(nil)
    allow_any_instance_of(Screen::Place).to receive(:send_attack).with(anything,anything).and_raise(InvitedPlayerException.new('22/Aug/2019  20:30,'))

    target.should_receive(:status=).with('invited_player')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with minimal population to attack player' do
    target = stub_target
    report = stub_report

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 50, light: 100))
    allow(report).to receive(:time_to_produce).with(anything).and_return(Time.zone.now + 1.hour)
    allow(report).to receive(:mark_read)
    allow(target).to receive(:latest_valid_report).and_return(report)
    allow_any_instance_of(Screen::Place).to receive(:send_attack).with(anything,anything).and_raise(NeedsMinimalPopulationException.new('200'))

    target.should_receive(:status=).with('waiting_resource_production')
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

  it 'with barbarian and without spy research' do
    target = stub_target(barbarian: true)
    screen = train_screen(build_info: { 'spy' => OpenStruct.new(active: false) })

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spear: 100, light: 100))

    allow(Screen::Train).to receive(:new).and_return(screen)
    allow(target).to receive(:latest_valid_report).and_return(nil)
    allow(target).to receive(:reports).and_return([])

    target.should_receive(:status=).with('waiting_report')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with barbarian and without spy research and no troops enough' do
    target = stub_target(barbarian: true)
    screen = train_screen(build_info: { 'spy' => OpenStruct.new(active: false) })

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spear: 1))

    allow(Screen::Train).to receive(:new).and_return(screen)
    allow(target).to receive(:latest_valid_report).and_return(nil)
    allow(target).to receive(:reports).and_return([])

    target.should_receive(:status=).with('waiting_troops')
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

  it 'without latest_valid_report' do
    target = stub_target
    allow(target).to receive(:latest_valid_report).and_return(nil)
    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 50))

    target.should_receive(:status=).with('waiting_report')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'without report and spies' do
    target = stub_target
    allow(target).to receive(:latest_valid_report).and_return(nil)
    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 0))

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

  it 'target waiting_report' do
    target = stub_target(status: 'waiting_report')

    report = stub_report

    allow(report).to receive(:possible_attack?).and_return(false)
    allow(target).to receive(:latest_valid_report).and_return(report)

    target.should_receive(:status=).with('has_spies')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'attack with report without troops' do
    target = stub_target(status: 'waiting_report')

    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spy: 5, spear: 100, light: 50))
    allow(target).to receive(:latest_valid_report).and_return(stub_report)

    target.should_receive(:status=).with('waiting_report')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'attack with report with wall, strong troops and wall to destroy' do
    target = stub_target(status: 'waiting_report')

    troops_available = Troop.new(light: 50, ram: 800)
    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(troops_available)
    allow(target).to receive(:latest_valid_report).and_return(stub_report(wall: 1))
    allow(troops_available).to receive(:distribute).with(anything, anything).and_return(Troop.new(light: 1))

    target.should_receive(:status=).with('waiting_report')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'attack with report with wall, strong troops without ram' do
    target = stub_target(status: 'waiting_report')

    troops_available = Troop.new(light: 50, ram: 0)
    allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(troops_available)
    allow(target).to receive(:latest_valid_report).and_return(stub_report(wall: 20, rams_to_destroy_wall: 20))
    allow(troops_available).to receive(:distribute).with(anything, anything).and_return(Troop.new(light: 1))

    target.should_receive(:status=).with('waiting_strong_troops')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  context 'with incomings' do
    it 'finish after' do
      target = stub_target(barbarian: true)
      allow(target).to receive(:latest_valid_report).and_return(stub_report)

      incomings = [OpenStruct.new(
        incomings: Command::Incoming.new(arrival: Time.now + 1.minute)
      )]
      allow(Screen::Place).to receive_message_chain(:all_places, :values).and_return(incomings)
      allow_any_instance_of(Screen::Place).to receive(:troops_available).and_return(Troop.new(spear: 100, light: 100))

      target.should_receive(:status=).with('waiting_incoming')
      target.should_receive(:next_event=).with(anything)
      target.should_receive(:save)
      subject.run
    end
  end
end
