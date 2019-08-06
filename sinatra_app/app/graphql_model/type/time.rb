# frozen_string_literal: true

module Type::Time
  def self.definition
    if @definition.nil?
      @definition = GraphQL::ScalarType.define do
        name 'Time'
        coerce_input ->(value, _ctx) { Time.parse(value) }
        coerce_result ->(value, _ctx) { value.utc.iso8601 }
      end
    end
    @definition
  end
end
