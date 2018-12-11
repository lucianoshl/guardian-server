# frozen_string_literal: true

class Service::HealthCheck
  include Logging
  include Delayed::Backend::Mongoid

  def self.check_system
    validations = []

    validations << validation('job_with_error') do
      Job.nin(last_error: [nil]).pluck(:id)
    end

    validations << validation('inconsistent_job_size') do
      linked_jobs = Task::Abstract.pluck(:job_id)
      unlinked_jobs = Job.nin(id: linked_jobs)

      task_without_job = Task::Abstract.all.select{|t| t.job.nil? }

      unlinked_jobs + task_without_job
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
