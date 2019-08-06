# frozen_string_literal: true

module Type::Hash
  def self.definition
    if @definition.nil?
      @definition = GraphQL::ScalarType.define do
        name 'Hash'
        coerce_input ->(value, _ctx) { binding.pry }
        coerce_result ->(value, _ctx) { value }
      end
    end
    @definition
  end
end
