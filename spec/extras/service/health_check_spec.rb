# frozen_string_literal: true

describe Service::HealthCheck do
  it 'check_job_with_error' do
    job_with_error = Delayed::Backend::Mongoid::Job.new
    job_with_error.last_error = 'invalid network'
    job_with_error.save

    errors = Service::HealthCheck.check_system.map(&:name)
    expect(errors).to include('job_with_error')

    Delayed::Backend::Mongoid::Job.all.delete
  end

  # TODO: add case with invalid DelayedJob state
  it 'check_inconsistent_job_size' do
    basic_task = Task::StealResourcesTask.new(target: Village.new)
    basic_task.save
    basic_task.job.delete

    errors = Service::HealthCheck.check_system.map(&:name)
    expect(errors).to include('inconsistent_job_size')
  end

  it 'check_invalid_jobs' do
    job = Delayed::Backend::Mongoid::Job.new
    job.run_at = Time.now - 10.minutes
    job.save

    errors = Service::HealthCheck.check_system.map(&:name)
    expect(errors).to include('invalid_jobs')
  end
end
