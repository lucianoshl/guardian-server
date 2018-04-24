# frozen_string_literal: true

module Mongoid::Document
  def store
    save
    self
  end
end
