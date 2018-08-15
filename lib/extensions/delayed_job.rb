class Delayed::Backend::Mongoid::Job
  has_one :task, class_name: 'Task::Abstract'
end