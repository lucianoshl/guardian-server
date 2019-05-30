# frozen_string_literal: true

class Screen::ReportList < Screen::Base
  screen :report

  attr_accessor :report_id_list, :pages

  def initialize(args = {})
    super
  end

  def parse(page)
    super
    self.pages = page.search('.paged-nav-item').size + 1
    self.report_id_list = (page.search('#report_list').search('a[href*=view]').map do |link|
      next if link.text.include? 'visitou'

      link.attr('href').scan(/view=(\d+)/).first.first.to_i
    end).compact
  end
end
