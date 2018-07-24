# frozen_string_literal: true

class Event::FirstLogin
  include Wisper::Publisher

  def initialize
    method_name = self.class.name.demodulize.underscore.to_sym
    Service.constants.map do |item|
      if Service.const_get(item).instance_methods.include?(method_name)
        subscribe(Service.const_get(item).new)
      end
    end
    broadcast(method_name)
  end
end
