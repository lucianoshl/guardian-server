Type::Query = GraphQL::ObjectType.define do
  name 'Query'
  description 'Guardian queries'

  models = (Type.constants - [:Query,:Base,:DateTime,:PointsEvolution,:Buildings])

  models.map do |model_name|
    model = Type.const_get(model_name)
    label = model_name.to_s.downcase

    field "#{label}", model.definition do
      description "Representation of #{model_name} in guardian"
      instance_eval &model.config unless model.config.nil?
      resolve lambda { |*args| model.base_criteria(*args).first }
    end

    field "#{label}s", types[model.definition] do
      description "Representation of #{model_name} in guardian"
      instance_eval &model.config unless model.config.nil?
      resolve lambda { |*args| model.base_criteria(*args).to_a }
    end
  end

end