# frozen_string_literal: true

describe Screen::Place do
  it 'test place messages' do
    # TODO: extract complete messages from game
    mock_request_from_id('place_with_commands_incomings')
    place = Screen::Place.new

    expectations = {}
    expectations[NewbieProtectionException] = 'para novatos que termina Set 10, 2019 10:30:32.'
    expectations[BannedPlayerException] = 'jogador foi banido'
    expectations[VeryWeakPlayerException] = 'apenas poderá atacar e ser atacado se a razão'
    expectations[NeedsMinimalPopulationException] = 'de ataque precisa do'
    expectations[RemovedPlayerException] = 'Alvo não existe'
    expectations[InvitedPlayerException] = ' convidou o proprietario 10/Oct/10  10:10,'

    expectations[Exception] = 'other unknown message'

    expectations.map do |exception, message|
      expect { raise place.convert_error(message) }.to raise_error(exception)
    end
  end

  it 'parse troops available' do
    mock_request_from_id('place_with_commands_incomings')
    place = Screen::Place.new
    troops_available = place.troops_available
    expect(troops_available.spear).to eq(1)
  end

  it 'get all places' do
    mock_request_from_id('place_with_commands_incomings')
    places = Screen::Place.all_places
    expect(places.size).to eq(3)
  end

  it 'check has command for village' do
    mock_request_from_id('place_with_commands_incomings')
    place = Screen::Place.new

    target = double(:target)
    command = double(:command)

    allow(target).to receive(:distance).and_return(0)
    allow(command).to receive(:target).and_return(target)
    allow(command).to receive(:next_arrival).and_return(Time.now)
    allow(place).to receive_message_chain(:commands, :leaving).and_return([command])

    place.next_leaving_command(target)
  end

  it 'send attack' do
    place = Screen::Place.new
    attack_command = double('attack_command')

    allow(attack_command).to receive(:id).and_return(1)
    allow(attack_command).to receive(:troops).and_return(Troop.new)
    allow(attack_command).to receive(:troop=).and_return(nil)
    allow(attack_command).to receive(:returning=).and_return(nil)
    allow(attack_command).to receive(:returning_arrival=).and_return(nil)
    allow(attack_command).to receive(:origin).and_return(double(:origin))
    allow(attack_command).to receive(:target).and_return(double(:target))
    allow(attack_command).to receive(:save_if_not_saved).and_return(nil)
    allow(attack_command).to receive(:arrival).and_return(Time.now + 1.hour)
    allow(attack_command).to receive_message_chain(:troop, :travel_time).and_return(1.hour)

    place_page = get_mock_page('place_with_commands_incomings')
    allow(place).to receive_message_chain(:commands, :leaving, :select).and_return([attack_command])

    confirm_page = double('confirm_page')
    allow(confirm_page).to receive_message_chain(:search, :text, :strip).and_return('')
    allow(confirm_page).to receive_message_chain(:form, :submit).and_return(place_page)

    allow_any_instance_of(Mechanize).to receive(:submit).with(anything, anything, anything)
                                                        .and_return(confirm_page)

    place.send_attack(Village.new(x: 501, y: 501), Troop.new(spy: 50))
  end
end
