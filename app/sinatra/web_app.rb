# frozen_string_literal: true

require 'sinatra'

class WebApp < Sinatra::Base

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
