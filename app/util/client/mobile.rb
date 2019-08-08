# frozen_string_literal: true

class Client::Mobile < Client::Base

  def post(uri, query = {}, headers = {})
    uri = inject_global(uri, query)
    logger.debug("POST: #{uri}")
    is_form = headers['Content-Type']&.include?('form') || false
    super(uri, is_form ? query.to_query : query.to_json, headers)
  end

  def get(uri, parameters = [], referer = nil, headers = {})
    uri = inject_global(uri)
    logger.debug("GET: #{uri}")
    super(uri, parameters, referer, headers)
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
    "https://#{Account.main.world}.tribalwars.com.br#{uri}"
  end

  def login
    logger.info('Making mobile login'.on_blue)
    account = Account.main
    parameters = [account.username, account.password, '2.7.8']
    result = post('https://www.tribalwars.com.br/m/m/login', parameters)
    result = JSON.parse(result.body)
    throw Exception.new(result['error']) unless result['error'].nil?
    token = result['result']['token']
    post('https://www.tribalwars.com.br/m/m/worlds', [token])
    result = post("https://#{account.world}.tribalwars.com.br/m/g/login", [token, 2, 'android'])
    add_global_arg('sid', JSON.parse(result.body)['result']['sid'])
    get("https://#{account.world}.tribalwars.com.br/login.php?mobile&2")
    Session.create(account, cookies, 'mobile')
  end
end
