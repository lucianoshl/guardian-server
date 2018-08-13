# frozen_string_literal: true

describe Service::StartupTasks do
  it 'fill_user_information' do
    Service::StartupTasks.new.fill_user_information
  end
end
