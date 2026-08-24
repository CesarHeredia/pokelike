# res://scripts/world/node_events/pokeball_event.gd
class_name PokeballEvent
extends NodeEvent

func _init() -> void:
	event_type = "POKEBALL"
	icon_path  = "res://assets/sprites/objetos_mapa/POKEBALL.png"
	label      = "Pokébola"

## Emite el pool de regalo definido en el mapa.
## El jugador elige un Pokémon de ese pool.
func execute(map: MapConfig, _context: Dictionary) -> Dictionary:
	return {
		"type": "gift",
		"pool": map.get_gift_pool()
	}
