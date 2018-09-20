# frozen_string_literal: true

class Village
  include Mongoid::Document
  include AbstractCoordinate

  field :name, type: String
  field :points, type: Integer

  field :status, type: String
  field :next_event, type: DateTime

  field :disable_recruit, type: Boolean

  belongs_to :player, optional: true
  embeds_many :evolution, class_name: 'PointsEvolution'

  scope :targets, -> { not_in(player_id: [Account.main.player.id]) }

  has_many :reports, inverse_of: :target

  before_save do |_news|
    if evolution.empty?
      evolution << PointsEvolution.new(current: points, diference: 0, causes: ['startup'])
    else
      diference = points - evolution.last.current
      evolution << PointsEvolution.new(current: points, diference: diference) unless diference.zero?
    end
  end

  def latest_valid_report
    Report.where(target: self, read: false).gte(ocurrence: Time.now - 5.hours).order(ocurrence: 'desc').first
  end

  def self.reset_all
    Village.update_all(next_event: nil, status: nil)
  end

  def building_model
    model = []
    model << Buildings.new(main: 7, barracks: 1, smith: 1, place: 1)
    model << Buildings.new(wall: 10)
    model << Buildings.new(wood: 10, stone: 10, iron: 10)
    model << Buildings.new(main: 10, barracks: 10)
    model << Buildings.new(wall: 15)
    model << Buildings.new(wood: 20, stone: 20, iron: 10)
    model << Buildings.new(market: 10)
    model << Buildings.new(wall: 20)
    model << Buildings.new(barracks: 25, smith: 20, market: 15, snob: 1)
    model << Buildings.new(wood: 30, stone: 30, iron: 30)
    model
  end

  def train_model
    TroopModel.new(spear: 1.0 / 2, sword: 1.0 / 2, spy: 2000)
  end

  def to_s
    "#{x}|#{y}"
  end
end
