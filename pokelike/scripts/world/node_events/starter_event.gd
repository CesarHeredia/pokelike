# res://scripts/world/node_events/starter_event.gd
class_name StarterEvent
extends NodeEvent

func _init() -> void:
	event_type = "STARTER"
	icon_path  = "res://assets/sprites/objetos_mapa/POKEBALL.png"
	label      = "¡Elige tu Starter!"

func execute(_map: MapConfig, _context: Dictionary) -> Dictionary:
	return {"type": "starter"}
