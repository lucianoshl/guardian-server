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

  after_initialize do 
    self.runs_every = self.class._runs_every
  end

  before_save do
    self.next_execution ||= calc_next_execution
  end

  after_save do
    unless (next_execution.nil?)
      schedule
    end
  end

  def execute
    self.next_execution = self.run
    self.last_execution = Time.now
    if (self.next_execution.nil?)
      self.next_execution = calc_next_execution
    end
    save
  end

  def schedule
    logger.debug("Scheduling #{self.class} run in #{next_execution}".black.on_red)
    self.delay(run_at: next_execution).execute
  end

  def calc_next_execution
    return Time.now if last_execution.nil?
    unless (runs_every.nil?)
      return last_execution + runs_every.to_f/1.day
    end
  end
end
