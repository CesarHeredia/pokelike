# res://scripts/world/node_events/random_event.gd
class_name RandomEvent
extends NodeEvent

func _init() -> void:
	event_type = "EVENT"
	icon_path  = "res://assets/sprites/objetos_mapa/000.png"
	label      = "Evento ?"

## Elige aleatoriamente entre GRASS, BAG o TM y delega al evento correspondiente.
## Usa el mapa para obtener los tipos posibles disponibles (excluyendo TRAINER/BOSS).
func execute(map: MapConfig, context: Dictionary) -> Dictionary:
	var pool: Array[String] = ["GRASS", "BAG", "TM"]
	var chosen_type: String = pool[randi() % pool.size()]
	var sub_event: NodeEvent = map.create_node_event({"type": chosen_type})
	return sub_event.execute(map, context)
