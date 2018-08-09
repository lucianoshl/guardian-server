# frozen_string_literal: true

module Routes::Overlay
  def fix_html(page)
    raw = page.body
    raw = raw.gsub(/game\.php/, 'overlay')
    raw
  end
end
