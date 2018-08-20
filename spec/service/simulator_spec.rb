# frozen_string_literal: true

describe Service::Simulator do
  it 'simulate_1' do
    Service::Simulator.run(spear: 5)
  end
end
