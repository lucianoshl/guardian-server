# frozen_string_literal: true

class Client::Desktop < Mechanize
  def initialize
    super
    user_agent = 'Mozilla/5.0 (Linux; Android 4.4.4; SAMSUNG-SM-N900A Build/tt) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36'
    @global_args = {}
    this = self
    ObjectSpace.define_finalizer(self, proc { this.shutdown })
  end

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
    Property.put("#{self.class}_#{account.username}_cookies", cookies)
  end
end
