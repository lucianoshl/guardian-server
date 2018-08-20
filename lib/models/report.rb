# frozen_string_literal: true

class Report
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ocurrence, type: DateTime
  field :erase_uri, type: String
  
  field :has_troops, type: Boolean
  field :read, type: Boolean, default: false
  field :full_pillage, type: Boolean

  belongs_to :origin, class_name: Village.to_s, optional: true
  belongs_to :target, class_name: Village.to_s, optional: true

  embeds_one :resources, as: :resourcesable, class_name: Resource.to_s
  embeds_one :pillage, as: :resourcesable, class_name: Resource.to_s
  embeds_one :buildings, class_name: Buildings.to_s

  def erase
    Client::Logged.mobile.get(self.erase_uri)
  end
end