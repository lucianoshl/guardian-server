# frozen_string_literal: true

require_rel './types'

QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'The query root of this schema'

  Types::MongoTypes.map do |model|
  	type = Types.const_get(model.to_s)

	  field model.to_s.downcase, type do
	    description "Representation of #{model} in guardian"
	    resolve ->(_obj, _args, _ctx) {
	      model.first
	    }
	  end

	  field "#{model.to_s.downcase}s", types[type] do
	    description "Representation of #{model} in guardian"
	    resolve ->(_obj, _args, _ctx) {
	      model.limit(5).to_a
	    }
	  end
  end

end
