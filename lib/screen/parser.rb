# frozen_string_literal: true

module Screen::Parser
  def parse_json_argument(page, function)
    JSON.parse(page.body.scan(/#{function}\(({.+})\)/).flatten.first)
  end

  def parse_table(page, selector, remove_columns: [], include_header: false)
    generate_table_selector.map_compact do |tr|
      if tr.search('th').empty? || include_header
        tr.search('td').select_index(remove_columns).map(&:remove) unless remove_columns.empty?
        tr
      end
    end
  end

  def generate_table_selector(base_selector)
    has_thead = !page.search("#{base_selector} > thead").empty?
    has_tbody = !page.search("#{base_selector} > tbody").empty?
    if has_thead || has_tbody
      page.search("#{base_selector} > thead > tr, #{selector} > tbody > tr")
    else
      page.search("#{base_selector} > tr")
    end
  end
end
