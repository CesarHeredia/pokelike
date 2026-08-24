# res://scripts/world/regions/kanto/pokemon_league/league_map_config.gd
class_name LeagueMapConfig
extends MapConfig

func _init() -> void:
	map_id = "kanto_league"
	display_name = "Calle Victoria y Liga Pokémon"
	level_cap = 55
	enemy_team_size = 5  # Liga: 5 Pokémon por rival
	trainer_level = 45
	wild_level = 40
	max_trainers = 5
	
	boss_name = "Blue - Campeón de la Liga"
	boss_chapter_name = "Liga Pokémon - Sala del Campeón"
	boss_bg_color = Color("1a1a0e")
	boss_team = [
		{"name": "Pidgeot", "level": 50},
		{"name": "Alakazam", "level": 50},
		{"name": "Rhydon", "level": 52},
		{"name": "Gyarados", "level": 53},
		{"name": "Charizard", "level": 55}
	]
	
	icon_boss = "res://assets/sprites/objetos_mapa/entrenadores/brock1.PNG" # Placeholder sprite

func get_wild_pool() -> Array:
	return ["Machop", "Geodude", "Onix", "Rhyhorn"]

func get_gift_pool() -> Array:
	return [
		{
			"pokedex_id": 133,"name": "Eevee",      "types": [0],
			"evo_id": null,"evo_lvl": 0,
			"stats": [55, 55, 50, 55, 45, 65],
			"sprite_path": "res://assets/sprites/pokemon/pokemon izquierda/EEVEE.png",
			"frame_size": 40, "frame_count": 1
		}
	]

func get_map_layers() -> Array:
	return [
		[
			{"id":"0_0","type":"STARTER","icon":icon_pokeball,"label":"Calle Victoria",
			 "pos":Vector2(340,80),"next":["1_0"]}
		],
		[
			{"id":"1_0","type":"BOSS","icon":icon_boss,"label":"Alto Mando / Campeón",
			 "pos":Vector2(340,300),"next":[]}
		]
	]

func get_trainer_classes() -> Array:
	var tc := TrainerClass.new()
	tc.trainer_id = "cooltrainer"
	tc.display_name = "Entrenador Guay"
	tc.sprite_path = "res://assets/sprites/objetos_mapa/entrenadores/rocketElite.png"
	tc.pokemon_pool = ["Charizard", "Blastoise", "Venusaur", "Raichu", "Snorlax"]
	return [tc]
