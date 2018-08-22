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
    self.report_id_list = page.search('#report_list').to_html.scan(/view=(\d+)/).flatten.map(&:to_i)
  end
end
