# frozen_string_literal: true

class Client::Desktop < Client::Base
  def post(uri, query = {}, headers = {})
    super(inject_global(uri), query, headers)
  end

  def get(uri, parameters = [], referer = nil, headers = {})
    super(inject_global(uri), parameters, referer, headers)
  end

  def inject_global(uri)
    uri = inject_base(uri) unless uri.include?('http')
    uri
  end

  def inject_base(uri)
    "https://#{Account.main.world}.tribalwars.com.br#{uri}"
  end

  def login
    account = Account.main
    login_page = get('https://www.tribalwars.com.br')
    headers = {}
    headers['X-CSRF-Token'] = login_page.search('meta[name=csrf-token]').attr('content').text
    headers['Content-Type'] = 'application/x-www-form-urlencoded'
    headers['X-Requested-With'] = 'XMLHttpRequest'

    world_select_page = post('https://www.tribalwars.com.br/page/auth', {
                               username: account.username,
                               password: account.password,
                               remember: 1
                             }, headers)
    get("https://www.tribalwars.com.br/page/play/#{account.world}")
    Session.create(account, cookies)
  end
end
