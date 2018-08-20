# frozen_string_literal: true

module Routes::Graphql
  def self.registered(app)
    app.post '/graphql' do
      params = JSON.parse request.body.read
      result = GuardianSchema.execute(
        params['query'],
        variables: params['variables'],
        context: { current_user: nil }
      )
      content_type :json
      result.to_json
    end

    app.get '/graphiql' do
      Rack::GraphiQL.new(endpoint: '/graphql').call(request.env)
    end
  end
end
