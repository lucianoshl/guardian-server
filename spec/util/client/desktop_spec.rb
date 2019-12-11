# frozen_string_literal: true

describe Client::Desktop do
  it 'test desktop client' do
    client = Client::Desktop.new
    client.login
    client.get('/game.php?screen=main')
    client.post('/game.php?screen=main')
  end
end
