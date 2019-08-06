# frozen_string_literal: true

module Routes::Cookie
  def self.registered(app)
    app.get '/cookies/desktop' do
      Client::Logged.mobile.get('/game.php')
      return YAML.dump(Session.current(Account.main).cookies.map(&:to_raw))
    end
  end
end
