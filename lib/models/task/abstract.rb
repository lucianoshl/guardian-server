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
  field :last_execution, type: DateTime
  field :next_execution, type: DateTime
  field :enabled, type: Boolean, default: true
  field :name, type: String

  belongs_to :job, class_name: 'Delayed::Backend::Mongoid::Job', optional: true

  after_initialize do
    self.runs_every = self.class._runs_every
    self.queue = 'normal'
    self.name = self.class.name
  end

  before_save do
    self.next_execution ||= calc_next_execution
  end

  after_save do
    schedule unless next_execution.nil?
    logger.debug("Task Saved: #{attributes.to_json}")
  end

  def execute
    puts "Current jobs #{Delayed::Backend::Mongoid::Job.count}".white.on_red
    self.next_execution = run
    self.last_execution = Time.now
    self.next_execution = calc_next_execution if self.next_execution.nil?
    logger.info("Task #{self.class} scheduled for #{self.next_execution.to_s.on_red.white}")
    save
  end

  def schedule
    logger.debug("Scheduling #{self.class} run in #{next_execution}".white.on_red)
    job = delay(run_at: next_execution, queue: queue).execute
    self.class.where(id: id).update_all(job_id: job.id)
  end

  def run_now
    self.last_execution = nil
    self.job.delete
    self.save
  end

  def calc_next_execution
    return Time.now if last_execution.nil?
    return last_execution + runs_every.to_f / 1.day unless runs_every.nil?
  end
end
