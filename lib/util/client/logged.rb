# frozen_string_literal: true

require_rel './desktop.rb'
require_rel './mobile.rb'

class Client::Logged
  class << self
    def mobile
      @mobile = Client::Logged.new(Client::Mobile.new) if @mobile.nil?
      @mobile
    end

    def desktop
      @desktop = Client::Logged.new(Client::Desktop.new) if @desktop.nil?
      @desktop
    end
  end

  def initialize(client)
    @client = client
    reload_cookies
  end

  def reload_cookies
    @client.cookie_jar.clear
    Property.get("#{@client.class}_cookies", []).map do |cookie|
      @client.cookie_jar.add(cookie)
    end
  end

  def post(*args)
    args.unshift(:post)
    result = @client.send(*args)
    tries = 0
    until check_is_logged(result)
      raise Exception, 'Invalid login' if tries > 0
      @client.login
      reload_cookies
      result = @client.send(:post, *args)
      tries += 1
    end
    result
  end

  def get(*args)
    args.unshift(:get)
    result = @client.send(*args)
    tries = 0
    until check_is_logged(result)
      raise Exception, 'Invalid login' if tries > 0
      @client.login
      reload_cookies
      result = @client.send(*args)
      tries += 1
    end
    result
  end

  def check_is_logged(page)
    !page.uri.to_s.include?('www')
  end

  def cookies
    @client.cookies
  end

  def submit(form, button = nil, headers = {})
    @client.submit(form, button, headers)
  end
end
