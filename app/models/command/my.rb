# frozen_string_literal: true

class Command::My < Command::Abstract
  field :returning, type: Boolean
  field :returning_arrival, type: Time
  embeds_one :troop
  belongs_to :origin_report, optional: true, class_name: Report.to_s
  belongs_to :arrival_report, optional: true, class_name: Report.to_s

  def next_arrival
    returning_arrival.nil? ? arrival : returning_arrival
  end
end
