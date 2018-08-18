class Troop
  include Mongoid::Document
  include Mongoid::Timestamps

  Unit.ids.map do |id|
    field id.to_sym, type: Integer, default: 0
  end

  def distribute(resources)
    current = self.clone
    result = Troop.new
    units = Unit.all.sort(speed: 'desc').to_a

    found_unit_candidate = nil
    loop do
      found_unit_candidate = false
      units.map do |unit|
        if (unit.carry > 0)
          while current[unit.id] > 0 && resources >= 0
            current[unit.id] -= 1
            result[unit.id] += 1
            resources -= unit.carry
            found_unit_candidate = true
          end
        end
      end
      break if !found_unit_candidate
      break if resources <= 0
    end
    [result,resources]
  end

  def upgrade(disponible,type = :attack)
    result = self.clone
    to_insert = Unit.all.sort(:"#{type}" => 'desc').to_a
    to_remove = Unit.nin(id: [:spy]).sort(:"#{type}" => 'asc').to_a

    resolved = false
    to_insert.map do |insert_unit|
      to_remove.map do |remove_unit|
        next if insert_unit[type] <= remove_unit[type]
        next if disponible[insert_unit.id] <= 0
        next if result[remove_unit.id] <= 0
        carry_equivalent = insert_unit.equivalent(remove_unit,:carry)
        if (carry_equivalent > 1)
          result[remove_unit.id] -= carry_equivalent.floor
          result[insert_unit.id] += 1
          disponible[remove_unit.id] += carry_equivalent.floor
          disponible[insert_unit.id] -= 1
          resolved = true
        else
          equivalent = (1/carry_equivalent).ceil
          result[remove_unit.id] -= 1
          result[insert_unit.id] += equivalent
          disponible[remove_unit.id] += 1
          if (equivalent <= disponible[insert_unit.id])
            disponible[insert_unit.id] -= equivalent
          else
            disponible[insert_unit.id] = 0
            result[remove_unit.id] += 1
          end
        end
        break if resolved
      end
      break if resolved
    end

    raise Exception.new('Invalid logic') if disponible.has_negative? ||  result.has_negative?

    result
  end

  def each(&block)
    attrs = self.attributes.clone
    attrs.delete('_id')
    attrs.map(&block)
  end

  def total
    to_a.sum
  end

  def carry
    self.each{|unit,qte| Unit.find(unit).carry * qte}.sum
  end

  def has_negative?
    to_a.select{|a| a < 0}.size > 0
  end

  def to_a
    self.each.to_a.to_h.values
  end

  def -(other)
    result = self.clone
    result.each do |troop,qte|
      result[troop] -= other[troop]
    end
    raise Exception.new('Invalid operation') if result.has_negative?
    result
  end

  def ==(other)
    return false if (other.class != Troop)
    other.to_a == to_a
  end
  
end