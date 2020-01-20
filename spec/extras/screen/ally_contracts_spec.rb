# frozen_string_literal: true

describe Screen::AllyContracts do
  it 'do_request' do
    mock_request_from_id('ally_contracts')
    allow(Screen::AllyContracts).to receive(:new).and_call_original
    Screen::AllyContracts.new
  end
end
