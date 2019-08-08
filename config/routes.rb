# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'

  post 'graphql', to: 'application#graphql'
  get 'healthcheck', to: 'application#health_check'
end
