# frozen_string_literal: true

describe Screen::Place do
  it 'parse place' do
    mock_request_from_id('place_with_commands_incomings')
    Screen::Place.new
  end
end
