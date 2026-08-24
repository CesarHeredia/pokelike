# res://scripts/world/regions/kanto/gym1_brock/brock_map_config.gd
class_name BrockMapConfig
extends MapConfig

func _init() -> void:
	map_id = "kanto_brock"
	display_name = "Ruta 1 - Ciudad Plateada (Brock)"
	level_cap = 14
	enemy_team_size = 1  # Regla Gym 1: 1 Pokémon por entrenador normal
	trainer_level = 4
	wild_level = 4
	max_trainers = 4
	
	boss_name = "Brock - Líder de Gimnasio"
	boss_chapter_name = "Gimnasio de Pewter (Brock)"
	boss_bg_color = Color("1a0e0e")
	boss_team = [
		{"name": "Geodude", "level": 12},
		{"name": "Onix", "level": 14}
	]
	
	icon_boss = "res://assets/sprites/objetos_mapa/entrenadores/brock1.PNG"
	map_bg_image = "res://assets/sprites/mapa/mapa de brock.png"

func get_wild_pool() -> Array:
	return ["Caterpie", "Pidgey", "Rattata", "Pikachu", "Nidoran♂"]

func get_gift_pool() -> Array:
	var pool: Array = []
	var pokemon_script = preload("res://scripts/core/pokemon.gd")
	var pokedex: Dictionary = pokemon_script.POKEDEX
	
	var gift_ids: Array[int] = [
		1, 4, 7, 10, 13, 16, 19, 21, 23, 25, 27, 29, 32, 35, 37, 39, 41, 43, 46, 
		48, 50, 52, 54, 56, 58, 60, 63, 66, 69, 72, 74, 77, 79, 81, 84, 86, 88, 
		90, 92, 96, 98, 100, 102, 104, 109, 111, 116, 118, 120, 129, 133, 138, 140
	]
	
	for id in gift_ids:
		if pokedex.has(id):
			var data: Dictionary = pokedex[id]
			var p_name: String = data["name"]
			
			# Determinar frame size y frame count para starters o por defecto
			var f_size: int = 40
			var f_count: int = 1
			if id == 1:
				f_size = 38
				f_count = 99
			elif id == 4:
				f_size = 42
				f_count = 107
			elif id == 7:
				f_size = 43
				f_count = 51
			
			pool.append({
				"pokedex_id": id,
				"name": p_name,
				"types": data["types"],
				"evo_id": data["evo_id"],
				"evo_lvl": data["evo_lvl"],
				"stats": data["stats"],
				"sprite_path": "res://assets/sprites/pokemon/pokemon izquierda/%s.png" % p_name.to_upper(),
				"frame_size": f_size,
				"frame_count": f_count
			})
	return pool

func get_map_layers() -> Array:
	return [
		# Capa 0 — Pokébola de Starters (1 nodo)
		[
			{"id":"0_0","type":"STARTER","icon":icon_pokeball,"label":"¡Elige tu Starter!",
			 "pos":Vector2(340,80),"next":["1_0","1_1"]}
		],
		# Capa 1 (2 nodos)
		[
			{"id":"1_0","type":"GRASS","icon":icon_grass,"label":"Hierba Alta",
			 "pos":Vector2(220,190),"next":["2_0","2_1"]},
			{"id":"1_1","type":"EVENT","icon":icon_event,"label":"Evento ?",
			 "pos":Vector2(460,190),"next":["2_1","2_2"]}
		],
		# Capa 2 (3 nodos)
		[
			{"id":"2_0","type":"BAG",  "icon":icon_bag,  "label":"Bolso",
			 "pos":Vector2(140,300),"next":["3_0","3_1"]},
			{"id":"2_1","type":"TM",   "icon":icon_tm,   "label":"MT",
			 "pos":Vector2(340,300),"next":["3_1","3_2"]},
			{"id":"2_2","type":"GRASS","icon":icon_grass,"label":"Hierba Alta",
			 "pos":Vector2(540,300),"next":["3_2","3_3"]}
		],
		# Capa 3 (4 nodos)
		[
			{"id":"3_0","type":"EVENT","icon":icon_event,"label":"Evento ?",
			 "pos":Vector2(80,410), "next":["4_0","4_1"]},
			{"id":"3_1","type":"GRASS","icon":icon_grass,"label":"Hierba Alta",
			 "pos":Vector2(250,410),"next":["4_1","4_2"]},
			{"id":"3_2","type":"POKEBALL","icon":icon_pokeball,"label":"Pokébola",
			 "pos":Vector2(430,410),"next":["4_2","4_3"]},
			{"id":"3_3","type":"TM",   "icon":icon_tm,   "label":"MT",
			 "pos":Vector2(600,410),"next":["4_3","4_4"]}
		],
		# Capa 4 (5 nodos)
		[
			{"id":"4_0","type":"GRASS","icon":icon_grass,"label":"Hierba Alta",
			 "pos":Vector2(60,520), "next":["5_0"]},
			{"id":"4_1","type":"BAG",  "icon":icon_bag,  "label":"Bolso",
			 "pos":Vector2(190,520),"next":["5_0","5_1"]},
			{"id":"4_2","type":"TRAINER","icon":icon_event,"label":"Entrenador",
			 "pos":Vector2(340,520),"next":["5_1","5_2"]},
			{"id":"4_3","type":"TM",   "icon":icon_tm,   "label":"MT",
			 "pos":Vector2(490,520),"next":["5_2","5_3"]},
			{"id":"4_4","type":"EVENT","icon":icon_event,"label":"Evento ?",
			 "pos":Vector2(620,520),"next":["5_3"]}
		],
		# Capa 5 (4 nodos)
		[
			{"id":"5_0","type":"GRASS","icon":icon_grass,"label":"Hierba Alta",
			 "pos":Vector2(110,630),"next":["6_0","6_1"]},
			{"id":"5_1","type":"TM",   "icon":icon_tm,   "label":"MT",
			 "pos":Vector2(280,630),"next":["6_1"]},
			{"id":"5_2","type":"POKEBALL","icon":icon_pokeball,"label":"Pokébola",
			 "pos":Vector2(420,630),"next":["6_1","6_2"]},
			{"id":"5_3","type":"EVENT","icon":icon_event,"label":"Evento ?",
			 "pos":Vector2(570,630),"next":["6_2"]}
		],
		# Capa 6 (3 nodos)
		[
			{"id":"6_0","type":"EVENT","icon":icon_event,"label":"Evento ?",
			 "pos":Vector2(140,740),"next":["7_0"]},
			{"id":"6_1","type":"GRASS","icon":icon_grass,"label":"Hierba Alta",
			 "pos":Vector2(340,740),"next":["7_0","7_1"]},
			{"id":"6_2","type":"TM",   "icon":icon_tm,   "label":"MT",
			 "pos":Vector2(540,740),"next":["7_1"]}
		],
		# Capa 7 (2 nodos)
		[
			{"id":"7_0","type":"EVENT","icon":icon_event,"label":"Evento ?",
			 "pos":Vector2(220,850),"next":["8_0"]},
			{"id":"7_1","type":"GRASS","icon":icon_grass,"label":"Hierba Alta",
			 "pos":Vector2(460,850),"next":["8_0"]}
		],
		# Capa 8 — FINAL / JEFE (1 nodo)
		[
			{"id":"8_0","type":"BOSS", "icon":icon_boss, "label":"Gimnasio de Pewter (Brock)",
			 "pos":Vector2(340,960),"next":[]}
		]
	]

func get_trainer_classes() -> Array:
	var list: Array = []
	
	# 1. Cazabichos
	list.append(_create_tc("bug_catcher", "Cazabichos", "res://assets/sprites/objetos_mapa/entrenadores/cazabichos1.png", ["Caterpie", "Weedle", "Paras", "Venonat"]))
	# 2. Cerebrito
	list.append(_create_tc("nerd", "Cerebrito", "res://assets/sprites/objetos_mapa/entrenadores/cerebrito.png", ["Pikachu", "Voltorb", "Magnemite", "Rattata", "Pidgey", "Meowth", "Spearow"]))
	# 3. Científica
	list.append(_create_tc("scientist_f", "Científica", "res://assets/sprites/objetos_mapa/entrenadores/cientifica.png", ["Ekans", "Nidoran♀", "Nidoran♂", "Bellsprout", "Tentacool", "Koffing", "Grimer", "Zubat", "Pikachu", "Voltorb", "Magnemite"]))
	# 4. Científico
	list.append(_create_tc("scientist_m", "Científico", "res://assets/sprites/objetos_mapa/entrenadores/cientifico.png", ["Ekans", "Nidoran♀", "Nidoran♂", "Bellsprout", "Tentacool", "Koffing", "Grimer", "Zubat", "Pikachu", "Voltorb", "Magnemite"]))
	# 5. Cocinero
	list.append(_create_tc("cook", "Cocinero", "res://assets/sprites/objetos_mapa/entrenadores/cocinero.png", ["Oddish", "Bellsprout", "Paras", "Exeggcute", "Rattata", "Pidgey", "Meowth", "Spearow"]))
	# 6. Enfermera
	list.append(_create_tc("nurse", "Enfermera", "res://assets/sprites/objetos_mapa/entrenadores/enfermera.png", ["Rattata", "Pidgey", "Meowth", "Spearow", "Doduo", "Chansey", "Jigglypuff"], "nurse_heal"))
	# 7. Gordo
	list.append(_create_tc("fat", "Gordo", "res://assets/sprites/objetos_mapa/entrenadores/gordo.png", ["Rattata", "Pidgey", "Meowth", "Spearow", "Doduo", "Geodude", "Rhyhorn", "Onix"]))
	# 8. Rocket Male
	list.append(_create_tc("rocket_m", "Rocket", "res://assets/sprites/objetos_mapa/entrenadores/rocketo.png", ["Ekans", "Grimer", "Koffing", "Zubat", "Nidoran♂"]))
	# 9. Rocket Female
	list.append(_create_tc("rocket_f", "Rocket", "res://assets/sprites/objetos_mapa/entrenadores/rocketa.png", ["Ekans", "Grimer", "Koffing", "Zubat", "Nidoran♀"]))
	# 10. Elite Rocket
	list.append(_create_tc("rocket_elite", "Élite Rocket", "res://assets/sprites/objetos_mapa/entrenadores/rocketElite.png", ["Grimer", "Koffing", "Ekans", "Zubat"]))
	
	return list

func _create_tc(id: String, d_name: String, sprite: String, pool: Array[String], reward: String = "trainer_win") -> TrainerClass:
	var tc := TrainerClass.new()
	tc.trainer_id = id
	tc.display_name = d_name
	tc.sprite_path = sprite
	tc.pokemon_pool = pool
	tc.reward_type = reward
	return tc

func create_node_event(n_data: Dictionary) -> NodeEvent:
	if n_data.get("type", "") == "BOSS":
		return load("res://scripts/world/regions/kanto/gym1_brock/brock_boss_event.gd").new()
	return super.create_node_event(n_data)
