# # frozen_string_literal: true

# class Service::OfflineSimulator
#   include Logging

#   def self.simulate(attack, defence, _wall, _moral)
#     types = Unit.all.map(&:type).uniq - ['other']
#     atk_power = {}
#     attack.each do |unit, qte|
#       meta = Unit.get(unit)
#       if types.include? meta.type
#         atk_power[meta.type] ||= 0
#         atk_power[meta.type] += meta.attack * qte
#       end
#     end

#     def_power = {}
#     mapping_fields = {}
#     mapping_fields['infantry'] = 'defense'
#     mapping_fields['cavalry'] = 'defense_cavalry'
#     mapping_fields['archer'] = 'defense_archer'

#     defence.each do |unit, qte|
#       meta = Unit.get(unit)
#       if types.include? meta.type
#         def_power[meta.type] ||= 0
#         def_power[meta.type] += meta[mapping_fields[meta.type]] * qte
#       end
#     end

#     Simulation.new
#   end
# end
