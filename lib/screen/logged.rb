# frozen_string_literal: true

class Screen::Logged
  class << self
    attr_accessor :_screen
    def screen(name)
      self._screen = name
    end
  end

  attr_accessor :server_time

  def initialize(args = {})
    @client = Client::Mobile.logged
    parse(request(merge_parameters(args)))
  end

  def merge_parameters(parameters)
    parameters.merge(screen: self.class._screen)
  end

  def request(parameters, requests = 0)
    uri = "#{base_url}/game.php"
    uri += "?#{parameters.to_query}" unless parameters.empty?
    result = @client.get(uri)
    unless check_is_logged(result)
      raise('Error in login') if requests > 1
      do_login
      return request(parameters, requests + 1)
    end
    result
  end

  def do_login
    Account.main.world_login
  end

  def check_is_logged(page)
    !page.uri.to_s.include?('www')
  end

  def base_url
    "http://#{Account.main.world}.tribalwars.com.br"
  end
end
