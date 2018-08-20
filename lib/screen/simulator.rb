# frozen_string_literal: true

class Screen::Simulator < Screen::Base
  screen :place
  mode :sim

  attr_accessor :form, :atk_troops, :atk_looses, :def_troops, :def_looses

  def initialize
    super
  end

  def parse(page)
    super
    self.form = page.form
    table = parse_table(page, '#simulation_result', remove_columns: [0])
    unless table.empty?
      self.atk_troops = table[0].search('td').map(&:text).map(&:to_i).to_troops
      self.atk_looses = table[1].search('td').map(&:text).map(&:to_i).to_troops
      self.def_troops = table[2].search('td').map(&:text).map(&:to_i).to_troops
      self.def_looses = table[3].search('td').map(&:text).map(&:to_i).to_troops
    end
  end

  def simulate(attack, defence = Troop.new, wall = 0, moral = 100)
    attack.each do |unit, qte|
      form["att_#{unit}"] = qte
    end

    defence.each do |unit, qte|
      form["def_#{unit}"] = qte
    end

    form['moral'] = moral
    form['luck'] = -25
    form['def_wall'] = wall
    parse(form.submit)
  end
end
