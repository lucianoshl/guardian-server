# frozen_string_literal: true

class Report
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ocurrence, type: DateTime
  field :erase_uri, type: String
  field :moral, type: Integer

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
    if dot != 'red' && dot != 'yellow'
      Client::Logged.mobile.get(erase_uri)
    end
  end

  def win?
    dot != 'red'
  end

  def rams_to_destroy_wall
    wall = (self.buildings.wall || "0").to_i

    results = {}
    results[0] = 0
    results[1] = 2 
    results[2] = 7
    results[3] = 13
    results[4] = 20
    results[5] = 28
    results[6] = 37
    results[7] = 48
    results[8] = 60
    results[9] = 74
    results[10] = 90
    results[11] = 108
    results[12] = 129
    results[13] = 153
    results[14] = 180
    results[15] = 211
    results[16] = 246
    results[17] = 286
    results[18] = 330
    results[19] = 380
    results[20] = 437

    return results[wall]
  end
end
