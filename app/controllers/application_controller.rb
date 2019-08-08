class ApplicationController < ActionController::API

  def graphql
    params = JSON.parse request.body.read
    result = GuardianSchema.execute(
      params['query'],
      variables: params['variables'],
      context: { current_user: nil }
    )
    render json: result
  end
  
  def health_check

    Report.where('_type': 'Troop').delete
    Task::Abstract.remove_orphan_tasks

    errors = Service::HealthCheck.check_system
    status = errors.empty? ? 200 : 500
    render json: errors, status: status

  rescue StandardError => e
    render json: e.backtrace, status: 500
  end

end
