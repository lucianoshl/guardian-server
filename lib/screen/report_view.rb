# frozen_string_literal: true

class Screen::ReportView < Screen::Base
  screen :report
  mode :all

  attr_accessor :report

  def initialize(args = {})
    super
  end

  def parse(page)
    super

    report_table = page.search('.quickedit-label').parent_until { |a| a.name == 'table' }
    report = self.report = Report.new

    report.dot = page.search('img[src*=dots]').attr('src').value.scan(/dots\/(.+)\.png/).first.first
    report.erase_uri = page.search('a[href*=del_one]').attr('href').value
    report.id = report.erase_uri.scan(/id=(\d+)/).first.first.to_i
    report.ocurrence = report_table.search('tr > td')[1].text.strip.to_datetime
    report.moral = report_table.search('h4')[1].text.number_part
    report.luck = page.search('#attack_luck').text.strip.gsub('%','')

    bonus_title = report_table.search('h4')[2]
    report.night_bonus = bonus_title.nil? ? false : bonus_title.text.downcase.include?('bonus')

    report.origin_id, report.target_id = page.search('.village_anchor').map { |a| a.attr('data-id').to_i }

    attack_units = parse_table(page,'#attack_info_att_units',remove_columns: [0])
    defence_units = parse_table(page,'#attack_info_def_units',remove_columns: [0])

    report.atk_troops = parse_units(attack_units,1)
    report.atk_losses = parse_units(attack_units,2)
    report.def_troops = parse_units(defence_units,1)
    report.def_losses = parse_units(defence_units,2)

    attack_atk_table = parse_table(page,'#attack_info_att')
    report.atk_bonus = attack_atk_table[2..-1].map{|a| a.search('td').map(&:text).map(&:strip) }
    report.atk_bonus = fix_bonus_names(report.atk_bonus)

    attack_def_table = parse_table(page,'#attack_info_def')
    report.def_bonus = attack_def_table[2..-1].map{|a| a.search('td').map(&:text).map(&:strip) }
    report.def_bonus = fix_bonus_names(report.def_bonus)

    away_units = parse_table(page,'#spy_away_table', include_header: true)
    report.def_away = away_units.empty? ? Troop.new : parse_units(away_units,1)

    ram_label = Unit.get(:ram).name.downcase
    catapult_label = Unit.get(:catapult).name.downcase

    buildings_regex = Building.all.map(&:name).map(&:downcase).join('|')
    catapult_damage_text = page.search("th:contains('#{catapult_label}')").first
    unless catapult_damage_text.nil?
      catapult_damage_text = catapult_damage_text.next.next.text
      report.catapult_damage = catapult_damage_text.downcase.scan(/\d+|#{buildings_regex}/)
      report.catapult_damage[0] = Buildings.where(name: /#{report.catapult_damage[0]}/i).first.id
    end

    ram_damage_text = page.search("th:contains('#{ram_label}')").first
    unless ram_damage_text.nil?
      ram_damage_text = ram_damage_text.next.next.text
      report.ram_damage = ram_damage_text.scan(/\d+/)
    end
    
    report.extra_info = parse_table(page,'#attack_info').map(&:text).map(&:strip)

    unless page.search('#attack_results').empty?
      report.pillage = Resource.parse(page.search('#attack_results').first)
      pillage, capacity = page.search('#attack_results').first.text.strip.scan(/(\d+)\/(\d+)/).flatten.map(&:to_i)
      report.full_pillage = capacity == pillage
    end

    has_spy_information = !page.search('#attack_spy_resources').empty?
    if has_spy_information
      report.buildings = Buildings.new
      (parse_table(page, '#attack_spy_buildings_left') + parse_table(page, '#attack_spy_buildings_right')).map do |tr|
        img = tr.search('img')
        next if img.empty?
        building = tr.search('img').attr('src').text.scan(/buildings\/(.+)\./).first.first
        report.buildings[building] = tr.search('td').last.text.to_i
      end
      report.resources = Resource.parse(page.search('#attack_spy_resources').first)
    end

  end

  def fix_bonus_names(bonus)
    bonus.map do |label,values|
      [label,values.split("\n").map(&:strip)]
    end
  end

  def parse_units(lines,line)
    result = Troop.new
    units_tds = lines[0].search('td,th')
    qte_tds = lines[line].search('td,th')
    units_tds.each_with_index do |td,index|
      unit = td.search('a').first.attr('data-unit')
      result[unit] = qte_tds[index].text.number_part
    end

    return result
  end
end
