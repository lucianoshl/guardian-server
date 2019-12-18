# frozen_string_literal: true

module DatabaseStub
  def clean_db
    # session = Session.all.map(&:clone)
    Mongoid.purge!
    # errors = session.map(&:save).select(&:!)
    # raise Exception, 'Error saving Session' unless errors.size.zero?
  end
end
