# # frozen_string_literal: true

# class Quest::Abstract
#   include Mongoid::Document

#   field :goals_completed, type: Integer
#   field :goals_total, type: Integer
#   field :opened, type: Boolean
#   field :finished, type: Boolean
#   field :hide, type: Boolean
#   field :can_be_skipped, type: Boolean
#   field :title, type: String
#   field :icon, type: String
#   field :state, type: String
#   field :started, type: Boolean, default: false

#   def self.create(hash)
#     quest_id = hash['id']
#     quests = {}
#     quests[47] = Quest::MentorSystem
#     quests[1010] = Quest::BuildWood
#     result = quests[quest_id]
#     throw Exception.new("Implement class for quest with id=#{quest_id}") if result.nil?
#     result.new(hash)
#   end

#   def start
#     self.started = true
#     save
#   end
# end
