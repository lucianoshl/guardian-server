# frozen_string_literal: true

class Command::Incoming < Command::Abstract
  # TODO: refactor this to Troop model
  field :possible_troop, type: Array
end
