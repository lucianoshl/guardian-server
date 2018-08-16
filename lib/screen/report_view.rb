# frozen_string_literal: true

class Screen::ReportView < Screen::Base
  screen :report

  attr_accessor :report

  def initialize(args = {})
    super
  end

  def parse(page)
    super
    report_table = page.search('.quickedit-label').parent_until {|a| a.name == 'table' }
    report = self.report = Report.new
    report.erase_uri = page.search('a[href*=del_one]').attr('href').value
    report.id = report.erase_uri.scan(/id=(\d+)/).first.first.to_i
    report.ocurrence = report_table.search('tr > td')[1].text.strip.to_datetime
    report.resources = Resource.parse(page.search('#attack_spy_resources').first)
    report.origin_id,report.target_id = page.search('.village_anchor').map{|a| a.attr('data-id').to_i}
    report.has_troops = page.search('#attack_info_def_units > tr:eq(2) > td').map{|a| a.text}.map(&:to_i).sum > 0
  end

  def erase
    binding.pry
  end
end
