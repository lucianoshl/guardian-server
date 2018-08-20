# frozen_string_literal: true

class Hash
  def select_keys(*keys)
    copy = HashWithIndifferentAccess.new(self)
    keys.map { |key| [key, copy[key]] }.to_h
  end

  def to_mongoid_model
    hash = self
    hash.map do |k, v|
      puts "field :#{k}, type: #{[TrueClass].include?(v.class) ? 'Boolean' : v.class}"
    end
    nil
  end
end
