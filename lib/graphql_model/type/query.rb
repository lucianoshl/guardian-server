# frozen_string_literal: true

module Type::Query
  def self.definition
    GraphQL::ObjectType.define do
      name 'Query'
      description 'Guardian queries'

      models = (Type.constants - %i[Query Base Time PointsEvolution Buildings Yaml Hash])
      models.map do |model_name|
        model = Type.const_get(model_name)
        label = model.definition_name.to_s.snakecase

        field label.to_s, model.definition do
          description "Representation of #{model_name} in guardian"
          instance_eval &model.config unless model.config.nil?
          resolve ->(*args) { model.base_criteria(*args).first }
        end

        field label.to_s.pluralize, types[model.definition] do
          description "Representation of #{model_name} in guardian"
          instance_eval &model.config unless model.config.nil?
          resolve ->(*args) { model.base_criteria(*args).to_a }
        end
      end
    end
  end
end
