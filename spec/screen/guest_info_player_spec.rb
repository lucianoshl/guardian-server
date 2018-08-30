# frozen_string_literal: true

describe Screen::GuestInfoPlayer do
  it 'guest info player' do
    page = Mechanize.new.get("http://#{Account.main.world}.tribalwars.com.br/guest.php")
    top_player_link = page.search('#player_ranking_table > tr:eq(2) a')
    player_id = top_player_link.attr('href').value.scan(/id=(\d+)/).first.first.to_i
    Screen::GuestInfoPlayer.new(id: player_id)
  end
end
