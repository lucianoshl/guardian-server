# frozen_string_literal: true

class Service::HealthCheck
  include Logging
  include Delayed::Backend::Mongoid

  def self.check_system
    validations = []

    validations << validation('job_with_error') do
      Job.nin(last_error: [nil]).pluck(:id)
    end

    validations << validation('unlinked_jobs') do
      linked_jobs = Task::Abstract.pluck(:job_id)
      Job.nin(id: linked_jobs).to_a
    end

    validations << validation('task_without_job') do
      saved_jobs = Job.pluck(:id)
      Task::Abstract.nin(job_id: saved_jobs).to_a
    end

    validations << validation('invalid_jobs') do
      Job.lte(run_at: Time.now - 10.minutes).all.to_a
    end

    validations << validation('village_with_error') do
      Village.where(status: 'error').pluck(:id)
    end

    validations.select do |item|
      item = item.with_error
      if item.class == TrueClass
        true
      elsif item.class == Array && item.size.positive?
        true
      elsif item.class == Integer && item.positive?
        true
      elsif item.nil?
        false
      else
        false
      end
    end
  end

  def self.validation(name)
    OpenStruct.new(
      name: name,
      with_error: yield
    )
  end
end
