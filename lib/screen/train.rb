# frozen_string_literal: true

class Screen::Train < Screen::Base
  screen :train

  attr_accessor :queue, :build_info, :form, :troops

  def train(troop)
    troop.each do |unit, qte|
      form[unit] = qte if qte > 0
    end
    parse(form.submit)
  end

  def parse(page)
    super
    self.queue = parse_queue(page)
    self.build_info = parse_build_info(page)
    self.form = page.form
    self.troops = Troop.new build_info.map { |k, v| [k, v.total] }.to_h
  end

  def parse_queue(page)
    queue = OpenStruct.new

    queue.barracks = parse_queue_html(page, 'barracks')
    queue.stable = parse_queue_html(page, 'stable')
    queue.garage = parse_queue_html(page, 'garage')
    queue
  end

  def parse_queue_html(page, selector)
    queue = OpenStruct.new
    queue.itens = page.search("#replace_#{selector} .queueItem").map do |html_item|
      quote_item = OpenStruct.new
      quote_item.unit = html_item.search('img').attr('src').value.scan(/unit_(.+)\.png/).first.first
      quote_item.qte = html_item.search('div > div')[0].text.number_part
      quote_item.finish = html_item.search('.btn-cancel').first.parent.previous.previous.text.to_datetime
      quote_item
    end
    queue.finish = queue.itens.last&.finish
    queue
  end

  def parse_build_info(page)
    (page.search('#train_form > .mobileBlock').map do |block_item|
      item = OpenStruct.new
      item.name = block_item.search('img').attr('src').value.scan(/big\/(.+?).png/).first.first
      item.actual, item.total = block_item.search('div')[0].text.scan(/\d+/).map(&:to_i)

      main_info = block_item.search('.unitOther p')
      item.cost = Resource.new(
        stone: main_info[0].search('span[id*=cost_stone]').text,
        wood: main_info[0].search('span[id*=cost_wood]').text,
        iron: main_info[0].search('span[id*=cost_iron]').text
      )

      hour, minute, seconds = main_info[0].search('span[id*=cost_time]').text.split(':').map(&:to_i)

      item.cost_time = hour * 60 * 60 + minute * 60 + seconds
      item.possible_build = block_item.search("##{item.name}_0_a").first.text.to_i
      [item.name, item]
    end).to_h
  end
end
