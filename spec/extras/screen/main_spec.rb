# frozen_string_literal: true

describe do
  it 'main screen health check' do
    main = Screen::Main.new
    server_time = main.server_time
    current_time = Time.now
    diference = (current_time - server_time).abs
    diference -= 3600 if diference > 3599
    expect(diference).to be < 500

    main.possible_build?(:farm)
  end
end
