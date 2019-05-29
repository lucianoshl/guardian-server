json = %{
  {
    "unit_data": {
      "spear": {
        "id": "spear",
        "image": "unit\/unit_spear.png",
        "type": "infantry",
        "prod_building": "barracks",
        "build_time": 1020,
        "wood": 50,
        "stone": 30,
        "iron": 10,
        "pop": 1,
        "speed": 0.0009259259259,
        "attack": 10,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 15,
        "defense_cavalry": 45,
        "defense_archer": 20,
        "carry": 25,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 4,
        "defpoints": 1,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "barracks",
            "building_link": "\/game.php?village=15008&amp;screen=barracks",
            "name": "Quartel",
            "level": 1
          }
        ]
      },
      "sword": {
        "id": "sword",
        "image": "unit\/unit_sword.png",
        "type": "infantry",
        "prod_building": "barracks",
        "build_time": 1500,
        "wood": 30,
        "stone": 30,
        "iron": 70,
        "pop": 1,
        "speed": 0.0007575757576,
        "attack": 25,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 50,
        "defense_cavalry": 15,
        "defense_archer": 40,
        "carry": 15,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 5,
        "defpoints": 2,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "smith",
            "building_link": "\/game.php?village=15008&amp;screen=smith",
            "name": "Ferreiro",
            "level": 1
          }
        ]
      },
      "axe": {
        "id": "axe",
        "image": "unit\/unit_axe.png",
        "type": "infantry",
        "prod_building": "barracks",
        "build_time": 1320,
        "wood": 60,
        "stone": 30,
        "iron": 40,
        "pop": 1,
        "speed": 0.0009259259259,
        "attack": 40,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 10,
        "defense_cavalry": 5,
        "defense_archer": 10,
        "carry": 10,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 1,
        "defpoints": 4,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "smith",
            "building_link": "\/game.php?village=15008&amp;screen=smith",
            "name": "Ferreiro",
            "level": 2
          }
        ],
        "tech_costs": {
          "wood": 700,
          "stone": 840,
          "iron": 820
        }
      },
      "archer": {
        "id": "archer",
        "image": "unit\/unit_archer.png",
        "type": "archer",
        "prod_building": "barracks",
        "build_time": 1800,
        "wood": 100,
        "stone": 30,
        "iron": 60,
        "pop": 1,
        "speed": 0.0009259259259,
        "attack": 15,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 50,
        "defense_cavalry": 40,
        "defense_archer": 5,
        "carry": 10,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 5,
        "defpoints": 2,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "barracks",
            "building_link": "\/game.php?village=15008&amp;screen=barracks",
            "name": "Quartel",
            "level": 5
          },
          {
            "building_id": "smith",
            "building_link": "\/game.php?village=15008&amp;screen=smith",
            "name": "Ferreiro",
            "level": 5
          }
        ],
        "tech_costs": {
          "wood": 640,
          "stone": 560,
          "iron": 740
        }
      },
      "spy": {
        "id": "spy",
        "image": "unit\/unit_spy.png",
        "type": "other",
        "prod_building": "stable",
        "build_time": 900,
        "wood": 50,
        "stone": 50,
        "iron": 20,
        "pop": 2,
        "speed": 0.001851851852,
        "attack": 0,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 2,
        "defense_cavalry": 1,
        "defense_archer": 2,
        "carry": 0,
        "stealth": 1,
        "perception": 1,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 1,
        "defpoints": 2,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "stable",
            "building_link": "\/game.php?village=15008&amp;screen=stable",
            "name": "Est\u00e1bulo",
            "level": 1
          }
        ],
        "tech_costs": {
          "wood": 560,
          "stone": 480,
          "iron": 480
        }
      },
      "light": {
        "id": "light",
        "image": "unit\/unit_light.png",
        "type": "cavalry",
        "prod_building": "stable",
        "build_time": 1800,
        "wood": 125,
        "stone": 100,
        "iron": 250,
        "pop": 4,
        "speed": 0.001666666667,
        "attack": 130,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 30,
        "defense_cavalry": 40,
        "defense_archer": 30,
        "carry": 80,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 5,
        "defpoints": 13,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "stable",
            "building_link": "\/game.php?village=15008&amp;screen=stable",
            "name": "Est\u00e1bulo",
            "level": 3
          }
        ],
        "tech_costs": {
          "wood": 2200,
          "stone": 2400,
          "iron": 2000
        },
        "name": "Cavalaria leve",
        "shortname": "CavL",
        "desc": "A cavalaria leve \u00e9 uma unidade boa para ataques. A sua velocidade e capacidade de carga a tornam uma excelente unidade para saquear aldeias inimigas.",
        "desc_abilities": []
      },
      "marcher": {
        "id": "marcher",
        "image": "unit\/unit_marcher.png",
        "type": "archer",
        "prod_building": "stable",
        "build_time": 2700,
        "wood": 250,
        "stone": 100,
        "iron": 150,
        "pop": 5,
        "speed": 0.001666666667,
        "attack": 120,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 40,
        "defense_cavalry": 30,
        "defense_archer": 50,
        "carry": 50,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 6,
        "defpoints": 12,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "stable",
            "building_link": "\/game.php?village=15008&amp;screen=stable",
            "name": "Est\u00e1bulo",
            "level": 5
          }
        ],
        "tech_costs": {
          "wood": 3000,
          "stone": 2400,
          "iron": 2000
        },
        "name": "Arqueiro a cavalo",
        "shortname": "ArqC",
        "desc": "O arqueiro a cavalo \u00e9 especialmente \u00fatil para derrotar arqueiros inimigos escondidos atr\u00e1s da muralha.",
        "desc_abilities": []
      },
      "heavy": {
        "id": "heavy",
        "image": "unit\/unit_heavy.png",
        "type": "cavalry",
        "prod_building": "stable",
        "build_time": 3600,
        "wood": 200,
        "stone": 150,
        "iron": 600,
        "pop": 6,
        "speed": 0.001515151515,
        "attack": 150,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 200,
        "defense_cavalry": 80,
        "defense_archer": 180,
        "carry": 50,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 23,
        "defpoints": 15,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "stable",
            "building_link": "\/game.php?village=15008&amp;screen=stable",
            "name": "Est\u00e1bulo",
            "level": 10
          },
          {
            "building_id": "smith",
            "building_link": "\/game.php?village=15008&amp;screen=smith",
            "name": "Ferreiro",
            "level": 15
          }
        ],
        "tech_costs": {
          "wood": 3000,
          "stone": 2400,
          "iron": 2000
        },
        "desc_abilities": []
      },
      "ram": {
        "id": "ram",
        "image": "unit\/unit_ram.png",
        "type": "infantry",
        "prod_building": "garage",
        "build_time": 4800,
        "wood": 300,
        "stone": 200,
        "iron": 200,
        "pop": 5,
        "speed": 0.0005555555556,
        "attack": 2,
        "building_attack_multiplier": 1,
        "additional_max_wall_negation": 0,
        "defense": 20,
        "defense_cavalry": 50,
        "defense_archer": 20,
        "carry": 0,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 4,
        "defpoints": 8,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "garage",
            "building_link": "\/game.php?village=15008&amp;screen=garage",
            "name": "Oficina",
            "level": 1
          }
        ],
        "tech_costs": {
          "wood": 1200,
          "stone": 1600,
          "iron": 800
        }
      },
      "catapult": {
        "id": "catapult",
        "image": "unit\/unit_catapult.png",
        "type": "infantry",
        "prod_building": "garage",
        "build_time": 7200,
        "wood": 320,
        "stone": 400,
        "iron": 100,
        "pop": 8,
        "speed": 0.0005555555556,
        "attack": 100,
        "building_attack_multiplier": 1,
        "additional_max_wall_negation": null,
        "defense": 100,
        "defense_cavalry": 50,
        "defense_archer": 100,
        "carry": 0,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 12,
        "defpoints": 10,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "garage",
            "building_link": "\/game.php?village=15008&amp;screen=garage",
            "name": "Oficina",
            "level": 2
          },
          {
            "building_id": "smith",
            "building_link": "\/game.php?village=15008&amp;screen=smith",
            "name": "Ferreiro",
            "level": 12
          }
        ],
        "tech_costs": {
          "wood": 1600,
          "stone": 2000,
          "iron": 1200
        }
      },
      "knight": {
        "id": "knight",
        "image": "unit\/unit_knight.png",
        "type": "cavalry",
        "prod_building": "statue",
        "build_time": 21600,
        "wood": 20,
        "stone": 20,
        "iron": 40,
        "pop": 10,
        "speed": 0.001666666667,
        "attack": 150,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 250,
        "defense_cavalry": 400,
        "defense_archer": 150,
        "carry": 100,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 40,
        "defpoints": 20,
        "cost_modifier": 1
      },
      "snob": {
        "id": "snob",
        "image": "unit\/unit_snob.png",
        "type": "infantry",
        "prod_building": "snob",
        "build_time": 18000,
        "wood": 40000,
        "stone": 50000,
        "iron": 50000,
        "pop": 100,
        "speed": 0.0004761904762,
        "attack": 30,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 100,
        "defense_cavalry": 50,
        "defense_archer": 100,
        "carry": 0,
        "stealth": 0,
        "perception": 0,
        "can_attack": true,
        "can_support": true,
        "attackpoints": 200,
        "defpoints": 200,
        "cost_modifier": 1,
        "reqs": [
          {
            "building_id": "snob",
            "building_link": "\/game.php?village=15008&amp;screen=snob",
            "name": "Academia",
            "level": 1
          },
          {
            "building_id": "main",
            "building_link": "\/game.php?village=15008&amp;screen=main",
            "name": "Edif\u00edcio principal",
            "level": 20
          },
          {
            "building_id": "smith",
            "building_link": "\/game.php?village=15008&amp;screen=smith",
            "name": "Ferreiro",
            "level": 20
          },
          {
            "building_id": "market",
            "building_link": "\/game.php?village=15008&amp;screen=market",
            "name": "Mercado",
            "level": 10
          }
        ]
      },
      "militia": {
        "id": "militia",
        "image": "unit\/unit_militia.png",
        "type": "infantry",
        "prod_building": "farm",
        "build_time": 1,
        "wood": 0,
        "stone": 0,
        "iron": 0,
        "pop": 0,
        "speed": 1,
        "attack": 0,
        "building_attack_multiplier": null,
        "additional_max_wall_negation": null,
        "defense": 15,
        "defense_cavalry": 45,
        "defense_archer": 25,
        "carry": 0,
        "stealth": 0,
        "perception": 0,
        "can_attack": false,
        "can_support": false,
        "attackpoints": 4,
        "defpoints": 1,
        "cost_modifier": 1,
        "desc_abilities": []
      }
    }
  }
}

stub_request(:get, /.*ajax=data.*screen=unit_info.*/).
to_return(status: 200, body: lambda { |request|
  logger.debug("Stub request: #{request.uri.to_s}")
  json
})