# frozen_string_literal: true

module Routes::HealthCheck
  def self.registered(app)
    app.get '/healthcheck' do
      content_type :json

      Report.where(:'_type' => 'Troop').delete
      errors = Service::HealthCheck.check_system
      status errors.empty? ? 200 : 500
      body errors.to_json
    rescue StandardError => e
      status 500
      raise e
    end
  end
end
