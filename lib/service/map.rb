# frozen_string_literal: true

class Service::Map
  def self.find_nearby(villages, distance)
    client = Client::Desktop.new
    targets = villages.map { |v| generate_targets_for_village(v, distance).keys }.flatten.uniq

    get_limit = 1800 / 9
    @json = []

    targets.each_slice(get_limit) do |parts|
      @json = @json.concat(JSON.parse(client.get("/map.php?v=2&#{parts.map { |a| "#{a}=1" }.join('&')}").body))
    end

    values = save_villages(save_players(save_allies)).values

    puts "Extracted villages #{values.size}"

    values = values.reject do |target|
      nearby = villages.select do |my_village|
        my_village.distance(target) <= distance
      end
      nearby.empty?
    end

    nearby = values.to_index(&:id)
  end

  def self.generate_targets_for_village(village, distance)
    squares = (distance / 20.0).ceil + 1

    start_x = (village.x / 20) * 20 - 20 * squares
    start_y = (village.y / 20) * 20 - 20 * squares

    size = (squares * 2 + 1)

    targets = {}

    for i in (0..size - 1)
      for j in (0..size - 1)
        x = start_x + (i * 20)
        y = start_y + (j * 20)
        targets["#{x.to_i}_#{y.to_i}"] = 1
      end
    end
    targets
  end

  def self.save_allies
    allies = {}
    @json.map do |i|
      node = i['data']['allies']
      next if node.empty?
      allies = allies.merge(node)
    end

    (allies.map do |k, v|
      a = OpenStruct.new(
        id: k.to_i,
        name: v[0],
        points: v[1].number_part,
        short: v[2]
      )
      [a.id, a]
    end).to_h
  end

  def self.save_players(allies)
    players = {}
    @json.map do |i|
      node = i['data']['players']
      next if node.empty?
      players = players.merge(node)
    end

    (players.map do |k, v|
      p = OpenStruct.new(
        id: k.to_i,
        name: v[0],
        points: v[1].number_part,
        ally_id: allies[v[2].number_part]&.id,
        ally: allies[v[2].number_part]
      )
      [p.id, p]
    end).to_h
  end

  def self.save_villages(players)
    villages = {}
    @json.map do |json_item|
      x = json_item['data']['x']
      y = json_item['data']['y']

      next if json_item['data']['villages'].empty?

      if json_item['data']['villages'].class == Array
        aux = json_item['data']['villages']
        json_item['data']['villages'] = aux.to_index { |a| aux.index(a).to_s }
      end

      json_item['data']['villages'].map do |k, v|
        current_x = x + k.to_i

        if v.class == Array
          if v.size != 2
            v = v.to_index { |a| v.index(a).to_s }
          elsif v.first.class == Array
            v = v.to_index { |a| v.index(a).to_s }
          # else
          #   current_x += v.first.to_i
          #   v = v.last
          end

        end

        v.each do |k, v_info|
          current_y = y + k.to_i
          next if v_info.nil?
          villages[v_info[0].to_i] = OpenStruct.new(
            id: v_info[0].to_i,
            name: v_info[2],
            points: v_info[3].number_part,
            player_id: players[v_info[4].to_i]&.id,
            player: players[v_info[4].to_i],
            x: current_x,
            y: current_y
          )
        end
      end
    end
    villages
  end
end
