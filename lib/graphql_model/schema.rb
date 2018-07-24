# frozen_string_literal: true

require_rel './query.rb'

GuardianSchema = GraphQL::Schema.define do
  query QueryType
end
