# frozen_string_literal: true

class Event::FirstLogin
  include Wisper::Publisher
  include Logging

  def initialize
    method_name = self.class.name.demodulize.underscore.to_sym
    target_method_name = "#{method_name}_event".to_sym
    logger.debug("Detecting listeners for event #{method_name.to_s.black.on_blue}")
    Service.constants.map do |item|
      if Service.const_get(item).instance_methods.include?(target_method_name)
        logger.debug("Subscribe Service::#{item.to_s.black.on_blue} for event #{method_name}")
        subscribe(Service.const_get(item).new)
      end
    end
    broadcast(target_method_name)
  end
end
