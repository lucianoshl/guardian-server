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
  field :last_execution, type: DateTime
  field :next_execution, type: DateTime

  belongs_to :job, class_name: 'Delayed::Backend::Mongoid::Job', optional: true

  after_initialize do
    self.runs_every = self.class._runs_every
    self.queue = 'normal'
  end

  before_save do
    self.next_execution ||= calc_next_execution
  end

  after_save do
    schedule unless next_execution.nil?
  end

  def execute
    self.next_execution = run
    self.last_execution = Time.now
    self.next_execution = calc_next_execution if self.next_execution.nil?
    save
  end

  def schedule
    logger.debug("Scheduling #{self.class} run in #{next_execution}".white.on_red)
    job = delay(run_at: next_execution, queue: self.queue).execute
    self.class.where(id: id).update_all(job_id: job.id)
  end

  def calc_next_execution
    return Time.now if last_execution.nil?
    return last_execution + runs_every.to_f / 1.day unless runs_every.nil?
  end
end
