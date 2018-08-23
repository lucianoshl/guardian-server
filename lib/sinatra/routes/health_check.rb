# frozen_string_literal: true

module Routes::HealthCheck
  def self.registered(app)
    app.get '/healthcheck' do
      begin
        job_error = Delayed::Backend::Mongoid::Job.nin(last_error: [nil]).count > 0
        validations = [job_error] 
        system_error = validations.select{|a| a}.size > 0
        status = system_error ? 500 : 200
        status status
        body status.to_s
      rescue
        status 500
      end
    end
  end
end
