# res://scripts/world/regions/kanto/kanto_region.gd
class_name KantoRegion
extends Resource

## Lista de configuraciones de mapas para la región de Kanto
var maps: Array[MapConfig] = []

func _init() -> void:
	# Instanciar cada mapa de gimnasio/sección
	maps.append(preload("res://scripts/world/regions/kanto/gym1_brock/brock_map_config.gd").new())
	maps.append(preload("res://scripts/world/regions/kanto/gym2_misty/misty_map_config.gd").new())
	maps.append(preload("res://scripts/world/regions/kanto/pokemon_league/league_map_config.gd").new())

## Busca una configuración de mapa por su ID
func get_map_config(map_id: String) -> MapConfig:
	for map in maps:
		if map.map_id == map_id:
			return map
	return null
