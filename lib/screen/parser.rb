# frozen_string_literal: true

module Screen::Parser
  def parse_json_argument(page, function)
    JSON.parse(page.body.scan(/#{function}\(({.+})\)/).flatten.first)
  end

  def parse_table(page, selector, remove_columns: [], include_header: false)
    tr_list = []
    has_thead = !page.search("#{selector} > thead").empty?
    has_tbody = !page.search("#{selector} > tbody").empty?

    tr_list = if has_thead || has_tbody
                page.search("#{selector} > thead > tr, #{selector} > tbody > tr")
              else
                page.search("#{selector} > tr")
              end

    tr_list.map_compact do |tr|
      if tr.search('th').empty? || include_header
        tr.search('td').select_index(remove_columns).map(&:remove) unless remove_columns.empty?
        tr
      end
    end
  end
end
