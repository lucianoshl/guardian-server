# frozen_string_literal: true

require 'sinatra'

class WebApp < Sinatra::Base

  post '/graphql' do
    params = JSON.parse request.body.read
    result = GuardianSchema.execute(
      params['query'],
      variables: params['variables'],
      context: { current_user: nil }
    )
    content_type :json
    result.to_json
  end

  get '/graphiql' do
    Rack::GraphiQL.new(endpoint: '/graphql').call(request.env)
  end

  get '/healthcheck' do
    content_type :json

    Report.where('_type': 'Troop').delete
    Task::Abstract.remove_orphan_tasks

    errors = Service::HealthCheck.check_system
    status errors.empty? ? 200 : 500
    body errors.to_json
  rescue StandardError => e
    status 500
    raise e
  end

end
