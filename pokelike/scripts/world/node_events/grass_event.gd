# res://scripts/world/node_events/grass_event.gd
class_name GrassEvent
extends NodeEvent

func _init() -> void:
	event_type = "GRASS"
	icon_path  = "res://assets/sprites/objetos_mapa/frlgpng.png"
	label      = "Hierba Alta"

## Elige un Pokémon aleatorio del pool de salvajes del mapa
## y genera los datos de batalla al nivel definido por el mapa.
func execute(map: MapConfig, _context: Dictionary) -> Dictionary:
	var pool: Array = map.get_wild_pool()
	if pool.is_empty():
		return {"type": "none"}
	var wild_name: String = String(pool[randi() % pool.size()])
	var level: int        = map.wild_level
	return {
		"type":         "battle",
		"battle_mode":  "HISTORIA",
		"details": {
			"chapter":        "Hierba Alta - " + map.display_name,
			"enemy_name":     wild_name + " Salvaje",
			"enemy_pokemon":  "%s Salvaje Lv.%d" % [wild_name, level],
			"wild_name":      wild_name,
			"wild_level":     level,
			"reward_type":    "level_up",
			"bg_color":       Color("0a1a0e")
		}
	}
