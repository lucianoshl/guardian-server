# frozen_string_literal: true

class Report
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ocurrence, type: DateTime
  field :erase_uri, type: String

  field :dot, type: String

  field :has_troops, type: Boolean
  field :read, type: Boolean, default: false
  field :full_pillage, type: Boolean

  belongs_to :origin, class_name: Village.to_s, optional: true
  belongs_to :target, class_name: Village.to_s, optional: true

  embeds_one :resources, as: :resourcesable, class_name: Resource.to_s
  embeds_one :pillage, as: :resourcesable, class_name: Resource.to_s
  embeds_one :buildings, class_name: Buildings.to_s

  embeds_one :atk_troops, class_name: Troop
  embeds_one :atk_losses, class_name: Troop
  embeds_one :def_troops, class_name: Troop
  embeds_one :def_losses, class_name: Troop

  def erase
    Client::Logged.mobile.get(erase_uri)
  end

  def win?
    self.dot != 'red'
  end
end
