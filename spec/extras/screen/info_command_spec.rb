# frozen_string_literal: true

describe Screen::InfoCommand do
  it 'load info player command' do
    mock_request_from_id('player_command')
    screen = Screen::InfoCommand.new(id: 506_937_843)
    command = screen.command
    expect(command).to be_nil
  end

  it 'page with incoming info' do
    allow(Account).to receive_message_chain(:main, :player,:villages,:map,:include?).and_return(true)
    mock_request_from_id('incoming_command')
    screen = Screen::InfoCommand.new(id: 1405170379)
    command = screen.command
    expect(command.id).to eq(1405170379)
  end
end
