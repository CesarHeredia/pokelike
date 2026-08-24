# res://scripts/world/regions/kanto/gym2_misty/misty_map_config.gd
class_name MistyMapConfig
extends MapConfig

func _init() -> void:
	map_id = "kanto_misty"
	display_name = "Ruta a Celeste (Misty)"
	level_cap = 21
	enemy_team_size = 2  # Regla Gym 2: 2 Pokémon por entrenador
	trainer_level = 14
	wild_level = 12
	max_trainers = 4
	
	boss_name = "Misty - Líder de Gimnasio"
	boss_chapter_name = "Gimnasio Celeste (Misty)"
	boss_bg_color = Color("0e1a1a")
	boss_team = [
		{"name": "Staryu", "level": 18},
		{"name": "Starmie", "level": 21}
	]
	
	icon_boss = "res://assets/sprites/objetos_mapa/entrenadores/brock1.PNG" # Placeholder sprite

func get_wild_pool() -> Array:
	return ["Oddish", "Bellsprout", "Psyduck", "Poliwag", "Horsea"]

func get_gift_pool() -> Array:
	return [
		{
			"pokedex_id": 54, "name": "Psyduck",    "types": [2],
			"evo_id": 55, "evo_lvl": 33,
			"stats": [50, 52, 48, 55, 65, 50],
			"sprite_path": "res://assets/sprites/pokemon/pokemon izquierda/PSYDUCK.png",
			"frame_size": 40, "frame_count": 1
		}
	]

func get_map_layers() -> Array:
	# Retornar una capa inicial y final de placeholder
	return [
		[
			{"id":"0_0","type":"STARTER","icon":icon_pokeball,"label":"Inicio Ruta Celeste",
			 "pos":Vector2(340,80),"next":["1_0"]}
		],
		[
			{"id":"1_0","type":"BOSS","icon":icon_boss,"label":"Gimnasio de Celeste (Misty)",
			 "pos":Vector2(340,300),"next":[]}
		]
	]

func get_trainer_classes() -> Array:
	var tc := TrainerClass.new()
	tc.trainer_id = "swimmer_m"
	tc.display_name = "Marinero"
	tc.sprite_path = "res://assets/sprites/objetos_mapa/entrenadores/cocinero.png"
	tc.pokemon_pool = ["Poliwag", "Horsea", "Goldeen"]
	return [tc]
