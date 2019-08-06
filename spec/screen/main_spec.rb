# frozen_string_literal: true

describe Screen::Main do
  it 'main screen health check' do
    main = Screen::Main.new
    server_time = main.server_time
    current_time = Time.now
    diference = (current_time - server_time).abs
    expect(diference < 500).to eq(true)

    main.possible_build?(:farm)
  end
end
