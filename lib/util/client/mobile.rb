# frozen_string_literal: true

class Client::Mobile < Mechanize
  def initialize
    super
    user_agent = 'Mozilla/5.0 (Linux; Android 4.4.4; SAMSUNG-SM-N900A Build/tt) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36'
    @global_args = {}
  end

  def post(uri, query = {}, headers = {})
    super(inject_global(uri, query), query.to_json, headers)
  end

  def get(uri, parameters = [], referer = nil, headers = {})
    super(inject_global(uri), parameters, referer, headers)
  end

  def inject_global(uri, query = {})
    uri = inject_base(uri) unless uri.include?('http')

    uri = URI.parse(uri)
    parameters = Rack::Utils.parse_nested_query(uri.query).merge(@global_args)
    parameters['hash'] = Digest::SHA1.hexdigest('2sB2jaeNEG6C01QOTldcgCKO-' + query.to_json)
    "#{uri.scheme}://#{uri.host}/#{uri.path}?#{parameters.to_query}"
  end

  def add_global_arg(name, value)
    @global_args[name] = value
  end

  def inject_base(uri)
    "https://#{Account.main.world}.tribalwars.com.br/#{uri}"
  end

  def login
    Account.main.world_login
  end
end
