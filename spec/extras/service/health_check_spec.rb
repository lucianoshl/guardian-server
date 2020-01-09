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
  it 'check_task_without_job' do
    basic_task = Task::StealResourcesTask.new(target: Village.new)
    basic_task.save
    basic_task.job.delete

    errors = Service::HealthCheck.check_system.map(&:name)
    expect(errors).to include('task_without_job')
  end

  it 'check_unlinked_jobs' do
    expect(Delayed::Backend::Mongoid::Job.new.save).to eq(true)
    
    errors = Service::HealthCheck.check_system.map(&:name)
    expect(errors).to include('unlinked_jobs')
  end

  it 'check_invalid_jobs' do
    job = Delayed::Backend::Mongoid::Job.new
    job.run_at = Time.now - 10.minutes
    job.save

    errors = Service::HealthCheck.check_system.map(&:name)
    expect(errors).to include('invalid_jobs')
  end
end
