# frozen_string_literal: true

class Screen::GuestInfoPlayer < Screen::Guest
  entry 'guest.php'
  screen :info_player

  attr_accessor :villages

  def initialize(args = {})
    super
  end

  def parse(page)
    self.villages = (parse_table(page, '#villages_list').map do |tr|
      lines = tr.search('> td')

      if lines.size == 1
        player_id = page.uri.to_s.scan(/id=(\d+)/).first.first.to_i
        page = Mechanize.new.get("http://#{Account.main.world}.tribalwars.com.br/guest.php?screen=info_player&ajax=fetch_villages&player_id=#{player_id}")
        html = JSON.parse(page.body)['villages']
        Nokogiri::HTML(html).search('body > tr').map do |inner_tr|
          extract_village(inner_tr)
        end
      else
        extract_village(tr, lines)
      end
    end).flatten
  end

  def extract_village(tr, lines = tr.search('> td'))
    village_link = lines[0].search('a')
    coordinate = lines[1].text.to_coordinate

    v = Village.new
    v.id = village_link.attr('href').value.scan(/id=(\d+)/).first.first.to_i
    v.name = village_link.text
    v.points = lines[2].number_part
    v.player_id = village_link.first.parent.attr('data-player').to_i
    v.x = coordinate.x
    v.y = coordinate.y
    v
  end
end
