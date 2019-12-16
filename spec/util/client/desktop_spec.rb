# frozen_string_literal: true

describe Client::Desktop do
  it 'test desktop client' do
    client = Client::Desktop.new
    client.login
    get = client.get('/game.php?screen=main')
    post = client.post('/game.php?screen=main')
    expect(get.body.include?('expirou')).to eq(false)
    expect(post.body.include?('expirou')).to eq(false)
  end
end
