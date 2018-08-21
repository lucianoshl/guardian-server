# frozen_string_literal: true

class Village
  include Mongoid::Document
  include AbstractCoordinate
  include Mongoid::Timestamps

  field :name, type: String
  field :points, type: Integer

  field :status, type: String
  field :next_event, type: DateTime

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
    Report.where(target: self, read: false).gte(ocurrence: Time.now - 5.hours).nin(resources: [nil]).order(ocurrence: 'desc').first
  end

  def to_s
    "#{x}|#{y}"
  end

  def self.reset_all
    Village.update_all(next_event: nil, status: nil)
  end
end
