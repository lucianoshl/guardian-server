# frozen_string_literal: true

describe Service::Report do

  before do
    Service::StartupTasks.new.fill_units_information
    Service::StartupTasks.new.fill_buildings_information
  end

  it 'test report sync' do
    Service::Report.sync(modes: ['attack','defense'])
  end

  # it 'parse_specific_report' do
  #   screen = Screen::ReportView.new(view: 29050472)
  #   puts JSON.pretty_generate(screen.report.attributes)
  # end
end
