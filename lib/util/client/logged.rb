# frozen_string_literal: true

class Client::Logged < Client::Mobile

  class << self
    def global
      @global = Client::Logged.new if @global.nil?
      @global
    end
  end

  def initialize(*args)
    super
    reload_cookies
  end

  def reload_cookies
    cookie_jar.clear
    Property.get('cookies', []).map do |cookie|
      cookie_jar.add(cookie)
    end
  end

  def post(*args)
    result = super
    tries = 0
    until check_is_logged(result)
      raise Exception, 'Invalid login' if tries > 0
      Account.main.world_login
      reload_cookies
      result = super
      tries += 1
    end
    result
  end

  def get(*args)
    result = super
    tries = 0
    until check_is_logged(result)
      raise Exception, 'Invalid login' if tries > 0
      Account.main.world_login
      reload_cookies
      result = super
      tries += 1
    end
    result
  end

  def check_is_logged(page)
    !page.uri.to_s.include?('www')
  end
end
