# frozen_string_literal: true

class Service::HealthCheck
  include Logging

  def self.check_system
    validations = []

    validations << validation('job_with_error') do
      Delayed::Backend::Mongoid::Job.nin(last_error: [nil]).count > 0
    end

    validations << validation('inconsistent_job_size') do
      Delayed::Backend::Mongoid::Job.count != Task::Abstract.count
    end

    validations << validation('invalid_jobs') do
      Delayed::Backend::Mongoid::Job.lte(run_at: Time.now - 5.minutes).count > 0
    end

    system_error = validations.select{|a| a.with_error }
  end

  def self.validation name
    OpenStruct.new({
      name: name,
      with_error: yield
    })
  end
end
