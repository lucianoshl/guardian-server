# frozen_string_literal: true

describe Client::Logged do
  it 'logged client with desktop' do
    Client::Logged.desktop.get('/game.php')
  end

  it 'logged client with mobile' do
    Client::Logged.mobile.get('/game.php')
  end
end
