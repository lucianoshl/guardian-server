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

  embeds_one :reserved_troops, as: :troopable, class_name: Troop.to_s

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
    self
  end

  def to_s
    "#{x}|#{y}"
  end

  def self.steal_resources_targets
    my_villages = Account.main.player.villages
    distance = Property.get('STEAL_RESOURCES_DISTANCE', 10)

    map = %{
      function() {
        var self = this;
        var max_distance = #{distance};
        var my_villages = #{my_villages.to_json};
        var distance = function(v1,v2){
          var a = Math.abs(v1.x - v2.x);
          var b = Math.abs(v1.y - v2.y);
          return Math.sqrt( a*a + b*b );
        };
        var distances = my_villages.map(function(v1){
           return {
             distance: distance(v1,self),
             village: v1._id
           };
        });

        distances = distances.filter(function(a){ return a.distance < max_distance});
        distances = distances.sort(function(a,b){ return Math.sign(a.distance - b.distance) })

        var nearby = distances.length > 0 ? 1 : 0

        emit(this._id, {
          id: this._id,
          distances: distances,
          nearby: nearby});
      }
    }

    reduce = %{
      function(key, values) {
        return {key: key, villages: values.length};
      }
    }

    finalize = %{
      function(key, element) {
        return element.nearby ? element : null
      }
    }

    result = Village.map_reduce(map, reduce).out(inline: 1).finalize(finalize).each.to_a
    result.select { |a| a['value'] }
  end

  def defined_model
    model || VillageModel.basic_model
  end

  def self.load_if_not_exists(village_id)
    return false unless where(id: village_id).empty?

    screen = Screen::GuestInfoVillage.new(id: village_id)
    screen.village.save
    true
  end
end
