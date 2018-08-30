# frozen_string_literal: true

module Screen::Parser
  def parse_json_argument(page, function)
    JSON.parse(page.body.scan(/#{function}\(({.+})\)/).flatten.first)
  end

  def parse_table(page, selector, remove_columns: [])
    tr_list = []
    has_thead = page.search("#{selector} > thead").size > 0
    has_tbody = page.search("#{selector} > tbody").size > 0
    
    if (has_thead || has_tbody)
      tr_list = page.search("#{selector} > thead > tr, #{selector} > tbody > tr")
    else
      tr_list = page.search("#{selector} > tr")
    end
    
    tr_list.map_compact do |tr|
      if tr.search('th').empty?
        tr.search('td').select_index(remove_columns).map(&:remove) unless remove_columns.empty?
        tr
      end
    end
  end
end
