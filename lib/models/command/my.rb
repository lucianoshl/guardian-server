# frozen_string_literal: true

class Command::My < Command::Abstract
  field :returning, type: Boolean
  embeds_one :troop
  belongs_to :origin_report, optional: true, class_name: Report.to_s
end
