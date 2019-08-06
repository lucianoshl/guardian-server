# frozen_string_literal: true

module Type::Job
  include Type::Base
  class_base Delayed::Backend::Mongoid::Job
end
