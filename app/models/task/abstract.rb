# frozen_string_literal: true

class Task::Abstract
  include Mongoid::Document
  include Logging

  class << self
    attr_accessor :_runs_every
    def runs_every(time)
      self._runs_every = time
    end
  end

  field :runs_every, type: Integer
  field :queue, type: String
  field :last_execution, type: Time
  field :next_execution, type: Time
  field :enabled, type: Boolean, default: true
  field :name, type: String

  belongs_to :job, class_name: 'Delayed::Backend::Mongoid::Job', optional: true

  after_initialize do
    self.runs_every = self.class._runs_every
    self.queue = 'normal'
    self.name = define_name
  end

  before_save do
    self.next_execution ||= calc_next_execution
    self.name = define_name
  end

  after_save do
    schedule unless next_execution.nil?
    logger.debug("Task Saved: #{attributes.to_json}")
  end

  def execute
    logger.info("Running task #{self.class} scheduled in #{next_execution}".black.on_white)
    if enabled == false
      self.next_execution = Time.now + 1.minute
      logger.info("Task #{self.id} is #{'disabled'.black.on_white}")
      save
    else
      self.next_execution = nil
      execution_result = run
      if [Time, DateTime, ActiveSupport::TimeWithZone].include? execution_result.class
        self.next_execution = execution_result
      end
      if runs_every.nil?
        job&.delete
        delete
      else
        self.last_execution = Time.now
        self.next_execution = calc_next_execution if self.next_execution.nil?
        save
      end
    end
  end

  def schedule
    logger.debug("Scheduling #{self.class} run in #{next_execution}".white.on_red)
    relation_job = delay(run_at: next_execution, queue: queue).execute
    job&.delete
    self.class.where(id: id).update_all(job_id: relation_job.id)
    reload
  end

  def run_now
    if job.nil?
      self.next_execution = nil
    else
      job.run_at = self.next_execution = Time.now + 1.second
    end
    job&.delete
    save
  end

  def calc_next_execution
    return Time.now if last_execution.nil?

    possible_next_execution(last_execution)
  end

  def possible_next_execution(base = Time.now)
    base = base.to_datetime if base.class == Time

    return base + runs_every.to_f unless runs_every.nil?
  end

  def self.remove_orphan_tasks
    Delayed::Backend::Mongoid::Job.all.select { |a| a.task.nil? }.map(&:delete)
  end

  def test_local
    loop do
      result = run
      begin
        seconds = result.to_i - Time.now.to_i
        puts "Waiting #{seconds}"
        sleep(1)
      end while seconds.positive?
    end
  end

  def self.remove_inconsistent_job
    (Delayed::Backend::Mongoid::Job.all - Task::Abstract.all.map(&:job)).map(&:delete)
  end

  def define_name
    self.class.name
  end
end
