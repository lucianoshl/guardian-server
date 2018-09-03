# frozen_string_literal: true

require_rel './types'

QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'The query root of this schema'

  MongoTypes.index.map do |model, grahql_object|
    field model.to_s.gsub('::', '_').downcase, grahql_object do
      MongoTypes.generate_arguments(model, types).map do |field, type|
        argument(field, type)
      end

      description "Representation of #{model} in guardian"
      resolve ->(_obj, _args, _ctx) {
        filters = _args.argument_values.map do |k, v|
          v = v.value
          v = v.to_i if k == 'id'
          [k, v]
        end
        model.where(filters.to_h).first
      }
    end

    field "#{model.to_s.gsub('::', '_').downcase}s", types[grahql_object] do
      description "Representation of #{model} in guardian"
      resolve ->(_obj, _args, _ctx) {
        filters = _args.argument_values.map do |k, v|
          v = v.to_i if k == 'id'
          [k, v.value]
        end
        model.where(filters.to_h).to_a
      }
    end
  end
end
