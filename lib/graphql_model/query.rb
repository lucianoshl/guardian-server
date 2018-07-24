# frozen_string_literal: true

require_rel './types'

QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'The query root of this schema'
  field :speakers, types[Types::SpeakerType] do
    description 'Get a list of speakers'
    resolve ->(_obj, _args, _ctx) {
      []
    }
  end
end
