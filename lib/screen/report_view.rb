# frozen_string_literal: true

class Screen::ReportView < Screen::Base
  screen :report

  attr_accessor :report

  def initialize(args = {})
    super
  end

  def parse(page)
    super
    report_table = page.search('.quickedit-label').parent_until { |a| a.name == 'table' }
    report = self.report = Report.new
    report.erase_uri = page.search('a[href*=del_one]').attr('href').value
    report.id = report.erase_uri.scan(/id=(\d+)/).first.first.to_i
    report.ocurrence = report_table.search('tr > td')[1].text.strip.to_datetime

    report.origin_id, report.target_id = page.search('.village_anchor').map { |a| a.attr('data-id').to_i }
    report.has_troops = page.search('#attack_info_def_units > tr:eq(2) > td').map(&:text).map(&:to_i).sum > 0

    unless page.search('#attack_results').empty?
      report.pillage = Resource.parse(page.search('#attack_results').first)
      pillage, capacity = page.search('#attack_results').first.text.strip.scan(/(\d+)\/(\d+)/).flatten.map(&:to_i)
      report.full_pillage = capacity == pillage
    end

    has_spy_information = !page.search('#attack_spy_resources').empty?
    if has_spy_information
      report.buildings = Buildings.new
      (parse_table(page, '#attack_spy_buildings_left') + parse_table(page, '#attack_spy_buildings_right')).map do |tr|
        img = tr.search('img')
        next if img.empty?
        building = tr.search('img').attr('src').text.scan(/buildings\/(.+)\./).first.first
        report.buildings[building] = tr.search('td').last.text.to_i
      end
      report.resources = Resource.parse(page.search('#attack_spy_resources').first)
    end
  end

  def erase
    binding.pry
  end
end
