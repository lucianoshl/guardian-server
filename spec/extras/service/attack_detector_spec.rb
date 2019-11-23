# frozen_string_literal: true

describe Service::AttackDetector do
  subject { Service::AttackDetector }

  it 'detect' do
    place = double(:place_screen)
    incoming = double(:incoming)

    info_command_screen = double(:info_command_screen)
    allow(info_command_screen).to receive(:command).and_return incoming
    allow(incoming).to receive(:create_at).and_return Time.now
    allow(incoming).to receive(:target).and_return 'target'
    allow(incoming).to receive(:origin).and_return(stub_village('my_village'))
    allow(incoming).to receive(:possible_troop).and_return ['spy']
    allow(incoming).to receive(:save).and_return nil

    allow(incoming).to receive(:id).and_return(1)

    allow(Screen::InfoCommand).to receive(:new).and_return(info_command_screen)

    allow(place).to receive(:incomings).and_return([incoming])
    allow(Screen::Place).to receive_message_chain(:all_places, :values).and_return([place])
    subject.run
  end
end
