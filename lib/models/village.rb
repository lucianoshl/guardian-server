# frozen_string_literal: true

class Village
  include Mongoid::Document
  include AbstractCoordinate

  field :name, type: String
  field :points, type: Integer

  field :status, type: String
  field :next_event, type: Time

  field :disable_recruit, type: Boolean, default: false
  field :disable_build, type: Boolean, default: false

  belongs_to :player, optional: true
  embeds_many :evolution, class_name: 'PointsEvolution'
  has_many :reports, inverse_of: :target

  belongs_to :model, class_name: VillageModel.to_s, optional: true

  scope :targets, -> { not_in(player_id: [Account.main.player.id]) }
  scope :my, -> { self.in(player_id: [Account.main.player.id]) }

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

  def reset
    self.next_event = nil
    self.status = nil
    save
    Task::StealResourcesTask.first&.run_now
  end

  def to_s
    "#{x}|#{y}"
  end

  def self.steal_resources_targets
    my_villages = Account.main.player.villages

    map = %{
      function() {
        var self = this;
        var my_villages = #{my_villages.to_json}
        var distance = function(v1,v2){
          var a = Math.abs(v1.x - v2.x);
          var b = Math.abs(v1.y - v2.y);
          return Math.sqrt( a*a + b*b );
        };
        var distances = my_villages.map(function(v1){ return distance(v1,self); })

        emit(this._id, {x: this.x, y: this.y, distance: distances});
      }
    }

    reduce = %{
      function(key, coords) {
        return {test: key};
      }
    }
    result = Village.map_reduce(map, reduce).out(inline: 1).each.to_a

    binding.pry
  end

  def reserved_troops
    Troop.new(knight: 1)
  end
end
