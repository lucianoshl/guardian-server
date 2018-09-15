# frozen_string_literal: true

describe Screen::Place do
  before do
    Service::StartupTasks.new.fill_units_information
  end

  it 'parse place' do
    Screen::Place.new
  end
end
