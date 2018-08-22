# frozen_string_literal: true

describe Service::Report do
  it 'test report sync' do
    Service::Report.sync
  end

  # it 'parse_specific_report' do
  #   screen = Screen::ReportView.new(view: 89991251)
  #   pp screen.report
  # end
end
