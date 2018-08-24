class Mongoid::Relations::Metadata
  def relation_class
    if [Mongoid::Relations::Embedded::Many,
        Mongoid::Relations::Referenced::Many].include?(relation)
      return (self[:class_name] || self[:name].to_s.singularize).to_s.camelize.constantize
    end


    if [Mongoid::Relations::Referenced::In,
      Mongoid::Relations::Embedded::One,
      Mongoid::Relations::Referenced::One].include?(relation)
      return (self[:class_name] || self[:name]).to_s.camelize.constantize
    end
    binding.pry
  end
end