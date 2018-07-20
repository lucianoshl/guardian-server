# frozen_string_literal: true

class Quest
  include Mongoid::Document

  field :goals_completed, type: Integer
  field :goals_total, type: Integer
  field :opened, type: Boolean
  field :finished, type: Boolean
  field :hide, type: Boolean
  field :can_be_skipped, type: Boolean
  field :title, type: String
  field :icon, type: String
  field :state, type: String
end
