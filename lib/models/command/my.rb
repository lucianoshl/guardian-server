# frozen_string_literal: true

class Command::My < Command::Abstract
  field :returning, type: Boolean
  embeds_one :troop
end