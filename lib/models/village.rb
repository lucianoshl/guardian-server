# frozen_string_literal: true

class Village
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :points, type: Integer
  field :x, type: Integer
  field :y, type: Integer

  field :status, type: String
  field :next_event, type: String

  belongs_to :player, optional: true
  embeds_many :evolution, class_name: 'PointsEvolution'

  scope :targets, -> { not_in(player_id: [ Account.main.player.id ]) }

  before_save do |news|
    if evolution.empty?
      evolution << PointsEvolution.new(current: points, diference: 0, causes: ['startup'])
    else
      diference = self.points - evolution.last.current
      unless diference.zero?
        evolution << PointsEvolution.new(current: points, diference: diference)
      end
    end
  end

  def distance other
    Math.sqrt ((self.x - other.x)**2 + (self.y - other.y)**2)
  end
end