# frozen_string_literal: true

describe Screen::Main do
  it 'main screen health check' do
    server_time = Screen::Main.new.server_time
    current_time = Time.now
    diference = (current_time - server_time).abs
    # expect(diference < 500).to eq(true)
  end
end
