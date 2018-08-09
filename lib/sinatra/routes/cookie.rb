# frozen_string_literal: true

module Routes::Cookie
  def self.registered(app)
    app.get '/cookies/desktop' do
      client = Client::Logged.new(Client::Desktop.new)
      client.get('/game.php')
      return YAML.dump(client.cookies)
    end
  end
end
