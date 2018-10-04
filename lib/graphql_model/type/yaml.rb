# frozen_string_literal: true

module Type::Yaml
  def self.definition
    if @definition.nil?
      @definition = GraphQL::ScalarType.define do
        name 'Yaml'
        coerce_input ->(value, _ctx) { YAML.load(value) }
        coerce_result ->(value, _ctx) { YAML.dump(value) }
      end
    end
    @definition
  end
end
