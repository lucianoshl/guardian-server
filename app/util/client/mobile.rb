# frozen_string_literal: true

class Client::Mobile < Client::Base
  def post(uri, query = {}, headers = {})
    with_hash = headers.delete(:'with-hash')

    if with_hash.nil? || with_hash == true
      uri = inject_global(uri, query)
    else
      uri = inject_base(uri) unless uri.include?('http')
    end

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
    parameters = [
      "password",
      {
          "intent": "login",
          "username": account.username,
          "password": account.password
      }
    ]

    result = post('https://www.tribalwars.com.br/m/m/signon', parameters)
    token = JSON.parse(result.body)['result']['master_session']['token']

    result = JSON.parse(post("https://#{account.world}.tribalwars.com.br/m/g/login", [token, 2]).body)
    sid = result['result']['sid']
    login_url = result['result']['login_url']
    post(login_url)

    Session.create(account, cookies, 'mobile')
  end
end
