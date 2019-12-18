# frozen_string_literal: true

class Service::WorldConfig
  extend Screen::Parser

  def self.has_milliseconds?
    world_config_html = Rails.cache.fetch('world_config') do
      Mechanize.new.get("https://#{Account.main.world}.tribalwars.com.br/page/settings").body
    end
    page = Nokogiri::HTML(world_config_html)

    parse_table(page, '.data-table').map do |tr|
      return tr.text.include?('Ativo') if tr.text.include?('Milésimos de segundo')
    end
    raise Exception, 'needs implementation'
  end
end
