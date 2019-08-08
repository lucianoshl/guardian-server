# frozen_string_literal: true

Dir["#{Rails.root}/app/graphql_model/{type,mutation}/**"].map { |f| require f }

Type.constants.map { |a| Type.const_get(a) }.select { |a| a.included_modules.include? Type::Base }.map(&:definition)

GuardianSchema = GraphQL::Schema.define do
  query Type::Query.definition
  mutation Mutation::Root.definition
end
