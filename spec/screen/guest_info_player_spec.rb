# frozen_string_literal: true

describe Screen::GuestInfoPlayer do
  it 'guest info player' do
    client = Mechanize.new

    worlds_lines = client.get('http://br.twstats.com/').search('.r1,.r2').reject { |a| a.text.include?('closed') }
    worlds_lines = worlds_lines.map do |world_line|
      parts = world_line.text.downcase.split("\n")
      parts.map(&:strip).uniq - ['']
    end

    most_village_world = worlds_lines.max { |a, b| a.last.number_part <=> b.last.number_part }.first

    account = Account.main
    account.world = most_village_world
    allow(Account).to receive(:main).and_return(account)

    page = client.get("http://#{Account.main.world}.tribalwars.com.br/guest.php")

    top_player_link = page.search('#player_ranking_table > tr:eq(2) a')
    player_id = top_player_link.attr('href').value.scan(/id=(\d+)/).first.first.to_i

    Screen::GuestInfoPlayer.new(id: player_id)
  end
end
