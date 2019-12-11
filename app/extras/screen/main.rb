# frozen_string_literal: true

class Screen::Main < Screen::Base
  screen :main

  attr_accessor :queue, :possible_build, :buildings_meta, :buildings, :buildings_labels
  attr_accessor :link_change_order

  def possible_build?(building)
    building = building.to_s
    building_meta = buildings_meta[building]
    return false if building_meta.nil? || full_builded?(building_meta) || queue.size > 1

    building_meta['error'].nil?
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
    finish_at = queue.last.finish_at
    Task::BuildInstantTask.new(village: village, next_execution: finish_at - 3.minutes).save
    finish_at
  end

  def parse(page)
    super
    self.queue = parse_queue(page)
    self.possible_build = page.search('.btn-build').map { |a| a.attr('data-building') }
    self.buildings_meta = parse_buildings(page)
    self.buildings = convert_buildings_meta
    self.buildings_labels = parse_buildings_labels(page)
    self.link_change_order = parse_link_change_order(page)
  end

  def parse_link_change_order(page)
    button = page.search('.btn-instant-free').first
    if !button.nil? && button['style'].nil?
      page.body.scan(/link_change_order = '(.+)'/).first&.first
    end
  end

  def parse_buildings_labels(page)
    (page.search('#building_wrapper > div').map do |line|
      id = line.search('img').first.attr('src').split('/').last.scan(/\w+/).first.gsub(/\d+/, '')
      label = line.search('a').first.text.gsub(/ +\(\d+\)/, '')
      [id, label]
    end).to_h
  end

  def parse_queue(page)
    page.search('.queueItem').map do |queueItem|
      src_attr = queueItem.search('img').first.attr('src')
      divs = queueItem.search('div > div > div')

      item = OpenStruct.new
      item.id = queueItem.attr('data-order').to_i
      item.building = src_attr.scan(%r{hd/(.+).png}).first.first.gsub(/\d+/, '')
      item.level = divs[0].text.number_part
      item.finish_at = divs[1].text.split(' - ').last.strip.to_datetime
      item
    end
  end

  def parse_buildings(page)
    JSON.parse(page.body.scan(/BuildingMain.buildings = (.+);/).first.first)
  end

  def build_instant
    return if link_change_order.nil?

    params = {
      id: queue.first.id,
      detroy: 0,
      client_time: client_time
    }
    Client::Logged.mobile.get(link_change_order + '&' + params.to_query)
  end

  def convert_buildings_meta
    result = Buildings.new
    buildings_meta.map do |name, info|
      result[name] = info['level_next'] - 1
    end
    result
  end
end
