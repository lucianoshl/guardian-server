# frozen_string_literal: true

module Routes::HealthCheck
  def self.registered(app)
    app.get '/healthcheck' do
      begin
        errors = Service::HealthCheck.check_system
        status errors.empty? ? 200 : 500
        body errors.to_json
      rescue
        status 500
      end
    end
  end
end
