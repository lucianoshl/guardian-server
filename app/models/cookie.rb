# frozen_string_literal: true

class Cookie
  include Mongoid::Document

  field :origin, type: String
  field :name, type: String
  field :value, type: String
  field :domain_name, type: Hash
  field :domain, type: String
  field :for_domain, type: Boolean
  field :path, type: String
  field :secure, type: Boolean
  field :httponly, type: Boolean
  field :expires, type: Time
  field :session, type: Boolean
  field :max_age, type: Integer
  field :created_at, type: Time
  field :accessed_at, type: Time

  def to_raw
    values = attributes.to_h
    values.delete('_id')
    HTTP::Cookie.new(values)
  end
end
