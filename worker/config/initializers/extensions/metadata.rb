# frozen_string_literal: true

class Mongoid::Relations::Metadata
  def relation_class
    if [Mongoid::Relations::Embedded::Many,
        Mongoid::Relations::Referenced::Many].include?(relation)
      return (self[:class_name] || self[:name].to_s.singularize).to_s.camelize.constantize
    end

    if [Mongoid::Relations::Referenced::In,
        Mongoid::Relations::Embedded::One,
        Mongoid::Relations::Referenced::One].include?(relation)
      (self[:class_name] || self[:name]).to_s.camelize.constantize
    end
  end

  def list?
    [Mongoid::Relations::Embedded::Many,
     Mongoid::Relations::Referenced::Many].include?(relation)
  end
end
