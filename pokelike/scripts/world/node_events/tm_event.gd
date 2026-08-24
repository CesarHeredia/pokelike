# res://scripts/world/node_events/tm_event.gd
class_name TmEvent
extends NodeEvent

func _init() -> void:
	event_type = "TM"
	icon_path  = "res://assets/sprites/objetos_mapa/machine_tr_NORMAL.png"
	label      = "MT"

## Emite una recompensa de MT y muestra una notificación.
func execute(_map: MapConfig, _context: Dictionary) -> Dictionary:
	return {
		"type":   "reward",
		"reward": {"type": "tm_upgrade"},
		"notification": {
			"text":  "¡Encontraste una MT!\nEl primer ataque de tu equipo\nha subido de nivel.",
			"color": Color("3498db")
		}
	}
