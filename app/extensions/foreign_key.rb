# frozen_string_literal: true

class Mongoid::Fields::ForeignKey
  def is_list?
    false
  end
end
