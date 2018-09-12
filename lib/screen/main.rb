# frozen_string_literal: true

class Screen::Main < Screen::Base
  screen :main

  attr_accessor :queue, :possible_build, :buildings_meta, :buildings

  def possible_build?(building)
    building = building.to_s
    building_meta = buildings_meta[building]
    return false if building_meta.nil? || full_builded?(building_meta) || queue.size > 1
    building_meta.nil? ? false : (building_meta['can_build'] &&  building_meta['cheap_error'].blank?)
  end

  def full_builded?(building_meta)
    building_meta['level'].to_i == building_meta['max_level']
  end

  def in_queue?(building)
    building_meta = buildings_meta[building.to_s]
    return false if building_meta.nil?
    building_meta['level_next'] - building_meta['level'].to_i > 1
  end

  def build(building)
    building_meta = buildings_meta[building.to_s]
    parse(@client.get(building_meta['build_link']))
    queue.last.finish_at
  end

  def parse(page)
    super
    self.queue = parse_queue(page)
    self.possible_build = page.search('.btn-build').map { |a| a.attr('data-building') }
    self.buildings_meta = parse_buildings(page)
    self.buildings = convert_buildings_meta
  end

  def parse_queue(page)
    page.search('.queueItem').map do |queueItem|
      src_attr = queueItem.search('img').first.attr('src')
      divs = queueItem.search('div > div > div')

      item = OpenStruct.new
      item.building = src_attr.scan(/hd\/(.+).png/).first.first.gsub(/\d+/, '')
      item.level = divs[0].text.number_part
      item.finish_at = divs[1].text.split(' - ').last.strip.to_datetime
      item
    end
  end

  def parse_buildings(page)
    JSON.parse(page.body.scan(/BuildingMain.buildings = (.+);/).first.first)
  end

  def convert_buildings_meta
    result = Buildings.new
    buildings_meta.map do |name, info|
      result[name] = info['level_next'] - 1
    end
    result
  end
end
