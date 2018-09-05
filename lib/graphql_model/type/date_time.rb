module Type::DateTime
  def self.definition

    @definition = GraphQL::ScalarType.define do
      name 'Time'
      coerce_input ->(value, _ctx) { Time.parse(value) }
      coerce_result ->(value, _ctx) { value.utc.iso8601 }
    end if @definition.nil?
    @definition
  end
end