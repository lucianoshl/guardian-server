# frozen_string_literal: true

class Client::Desktop < Mechanize
  def initialize
    super
    user_agent = 'Mozilla/5.0 (Linux; Android 4.4.4; SAMSUNG-SM-N900A Build/tt) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36'
    @global_args = {}
  end

  def post(uri, query = {}, headers = {})
    binding.pry
    super(inject_global(uri, query), query.to_json, headers)
  end

  def get(uri, parameters = [], referer = nil, headers = {})
    binding.pry
    super(inject_global(uri), parameters, referer, headers)
  end

  def inject_global(uri)
    uri = inject_base(uri) unless uri.include?('http')
    uri
  end

  def inject_base(uri)
    "https://#{Account.main.world}.tribalwars.com.br/#{uri}"
  end

  def login
    binding.pry
  end
end
