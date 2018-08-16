# frozen_string_literal: true

class Service::Report

  include Logging

  def self.sync
    logger.info('Loading reports: start')
    loop do
      report_screen = Screen::ReportList.new(mode: 'attack')
      break if report_screen.report_id_list.empty?
      report_screen.report_id_list.map {|report_id| process_report(report_id) }
      binding.pry
      break if ENV['ENV'] == 'test'
    end

    logger.info('Loading reports: end')
  end

  def self.process_report(report_id)
    report = Screen::ReportView.new(view: report_id).report
    report.save if Report.where(id: report.id).count.zero?
    report.erase
  end

end
