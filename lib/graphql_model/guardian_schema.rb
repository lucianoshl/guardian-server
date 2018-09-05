# frozen_string_literal: true

Type.constants.map{|a| Type.const_get(a)}.select{|a| a.included_modules.include? Type::Base}.map(&:definition)

GuardianSchema = GraphQL::Schema.define do
  query Type::Query.definition
  # mutation Mutation::Root
end
