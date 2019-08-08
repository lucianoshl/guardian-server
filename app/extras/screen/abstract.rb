# frozen_string_literal: true

class Screen::Abstract
  include Screen::Parser

  class << self
    attr_accessor :_screen, :_mode, :_entry
    def screen(name)
      self._screen = name
    end

    def mode(name)
      self._mode = name
    end

    def entry(name)
      self._entry = name
    end
  end

  def initialize(args = {})
    raise Exception, "client not created in #{self.class}" if @client.nil?

    @args = args
    reload
  end

  def merge_parameters(parameters)
    r = parameters.merge(screen: self.class._screen)
    r = r.merge(mode: self.class._mode) unless self.class._mode.nil?
    r
  end

  def request(parameters, _requests = 0)
    uri = "#{base_url}/#{self.class._entry || 'game.php'}"
    uri += "?#{parameters.to_query}" unless parameters.empty?
    result = @client.get(uri)
  end

  def base_url
    "http://#{Account.main.world}.tribalwars.com.br"
  end

  def reload
    page = request(merge_parameters(@args))
    parse(page)
    self
  end
end
