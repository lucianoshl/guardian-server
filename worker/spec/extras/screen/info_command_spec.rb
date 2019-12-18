# frozen_string_literal: true

describe Screen::InfoCommand do
  it 'load info player command' do
    mock_request_from_id('player_command')
    screen = Screen::InfoCommand.new(id: 506_937_843)
    command = screen.command
    expect(command).to be_nil
  end

  it 'TODO: page with incoming info' do
  end
end
