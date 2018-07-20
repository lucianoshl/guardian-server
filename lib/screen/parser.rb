# frozen_string_literal: true

module Screen::Parser
  def parse_json_argument(page, function)
    JSON.parse(page.body.scan(/#{function}\(({.+})\)/).flatten.first)
  end
end
