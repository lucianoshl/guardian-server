# frozen_string_literal: true

class Service::Report
  include Logging

  def self.sync(modes: ['attack'] )
    logger.info('Loading reports: start')
    report_ids = []

    modes.map do |mode|
      report_screen = Screen::ReportList.new(mode: mode)
      (1..report_screen.pages).map do |page|
        report_screen = Screen::ReportList.new(mode: mode, from: (page - 1) * 12)
        report_ids = report_ids.concat(report_screen.report_id_list)
      end
    end

    report_ids -= Report.in(id: report_ids).pluck(:id)

    report_ids.map { |report_id| process_report(report_id) }

    logger.info('Loading reports: end')
  end

  def self.process_report(report_id)
    report = Screen::ReportView.new(view: report_id).report
    report.save if Report.where(id: report.id).count.zero?
    report.erase
  end
  
end
