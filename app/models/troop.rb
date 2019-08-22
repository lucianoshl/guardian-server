# frozen_string_literal: true

class Troop
  include Mongoid::Document
  include Logging

  embedded_in :troopable, polymorphic: true

  Unit.ids.map do |id|
    field id.to_sym, type: Integer, default: 0
  end

  def distribute(resources, type = :speed)
    current = Troop.new(attributes.clone)
    result = Troop.new
    units = Unit.all.sort("#{type}": 'desc').to_a

    found_unit_candidate = nil
    loop do
      found_unit_candidate = false
      units.map do |unit|
        next unless unit.carry > 0

        while current[unit.id] > 0 && resources >= 0
          current[unit.id] -= 1
          result[unit.id] += 1
          resources -= unit.carry
          found_unit_candidate = true
        end
      end
      break unless found_unit_candidate
      break if resources <= 0
    end
    [result, resources]
  end

  def upgrade(disponible, type = :attack)
    result = clone
    to_insert = Unit.all.sort("#{type}": 'desc').to_a
    to_remove = Unit.nin(id: [:spy]).sort("#{type}": 'asc').to_a

    resolved = false
    to_insert.map do |insert_unit|
      to_remove.map do |remove_unit|
        next if insert_unit[type] <= remove_unit[type]
        next if disponible[insert_unit.id] <= 0
        next if result[remove_unit.id] <= 0

        carry_equivalent = insert_unit.equivalent(remove_unit, :carry)
        next if carry_equivalent.zero?

        if carry_equivalent > 1
          result[remove_unit.id] -= carry_equivalent.floor
          result[insert_unit.id] += 1
          disponible[remove_unit.id] += carry_equivalent.floor
          disponible[insert_unit.id] -= 1
          resolved = true
        else
          equivalent = (1 / carry_equivalent).ceil
          result[remove_unit.id] -= 1
          disponible[remove_unit.id] += 1
          if equivalent <= disponible[insert_unit.id]
            result[insert_unit.id] += equivalent
            disponible[insert_unit.id] -= equivalent
          else
            result[insert_unit.id] += disponible[insert_unit.id]
            disponible[insert_unit.id] = 0
          end
          resolved = true
        end
        break if resolved
      end
      break if resolved
    end

    raise Exception, 'Invalid logic' if disponible.has_negative? || result.has_negative?

    result
  end

  def each(&block)
    attrs = attributes.clone
    attrs.delete('_id')
    attrs.delete('_type')
    attrs.map(&block)
  end

  def total
    sum
  end

  def sum
    to_a.reject(&:nil?).sum
  end

  def carry
    each { |unit, qte| Unit.find(unit).carry * qte }.sum
  end

  def has_negative?
    !to_a.select { |a| a < 0 }.empty?
  end

  def to_a
    each.to_a.to_h.values
  end

  def -(other)
    result = clone
    result.each do |troop, _qte|
      result[troop] -= other[troop]
    end
    # raise Exception, 'Invalid operation' if result.has_negative?
    result
  end

  def +(other)
    result = clone
    result.each do |troop, _qte|
      result[troop] += other[troop]
    end
    # raise Exception, 'Invalid operation' if result.has_negative?
    result
  end

  def ==(other)
    return false if other.class != Troop

    other.to_a == to_a
  end

  def size
    to_a.sum
  end

  def to_h
    each.to_a.to_h
  end

  def to_s
    to_h.select { |_k, v| v > 0 }.to_s
  end

  def self.from_a(array)
    result = Troop.new
    Unit.ids.each_with_index do |id, index|
      result[id] = array[index]
    end
    result
  end

  def slow_unit
    to_h.select { |_unit, qte| qte > 0 }.keys.map { |a| Unit.get(a) }.max { |b, a| a.speed <=> b.speed }
  end

  def travel_time(origin, target)
    (slow_unit.square_per_minutes * origin.distance(target)).minutes
  end

  def remove_negative
    result = Troop.new
    each do |unit, qte|
      result[unit] = qte < 0 ? 0 : qte
    end
    result
  end

  def upgrade_until_win(disponible, wall = 0, moral = 100)
    begin
      disponible - self
    rescue StandardError
      raise Exception, 'self must be included in disponible'
    end
    result = clone
    loop do
      win = Service::Simulator.win?(result, wall: wall, moral: moral)
      return result if win

      new_troop = result.upgrade(disponible - result)
      raise Exception, 'Invalid state' if new_troop.has_negative?
      if new_troop == result
        raise UpgradeIsImpossibleException
      else
        result = new_troop
      end
    end
  end

  def increment_until_win(disponible, wall = 0, moral = 100)
    begin
      disponible - self
    rescue StandardError
      raise Exception, 'self must be included in disponible'
    end
    result = clone
    loop do
      simulator = Screen::Simulator.new
      logger.info("Running increment simulator for #{result}")
      simulator.simulate(result, Troop.new, wall, moral)
      win = simulator.atk_looses.ram.zero? && simulator.atk_looses.population <= 10

      return result if win

      new_troop = result.increment(disponible - result)
      raise Exception, 'Invalid state' if new_troop.has_negative?
      if new_troop == result
        raise UpgradeIsImpossibleException
      else
        result = new_troop
      end
    end
  end

  def increment(disponible)
    result = clone
    possible = Unit.nin(id: %i[spy ram catapult snob militia]).sort(attack: 'desc').to_a
    increment_number = 5
    possible.each do |unit|
      next unless disponible[unit.id] >= increment_number

      disponible[unit.id] -= increment_number
      result[unit.id] += increment_number
      break
    end
    result
  end

  def population
    each { |unit, qte| Unit.get(unit)['pop'] * qte }.sum
  end
end
