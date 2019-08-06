class ApplicationController < ActionController::API

  def graphql
    params = JSON.parse request.body.read
    result = GuardianSchema.execute(
      params['query'],
      variables: params['variables'],
      context: { current_user: nil }
    )
    content_type :json
    result.to_json
  end
  
end
