# res://scripts/world/node_events/bag_event.gd
class_name BagEvent
extends NodeEvent

func _init() -> void:
	event_type = "BAG"
	icon_path  = "res://assets/sprites/objetos_mapa/bag_1.png"
	label      = "Bolso"

## Ofrece 3 objetos aleatorios del registro. El jugador elige uno.
func execute(_map: MapConfig, _context: Dictionary) -> Dictionary:
	var item_ids: Array[int] = ItemRegistry.get_random_items(3)
	var options: Array[Dictionary] = []
	for id in item_ids:
		var item = ItemRegistry.get_item(id)
		if item:
			options.append({"id": id, "name": item.name, "desc": item.description, "icon": item.icon_path})
	return {
		"type": "item_choice",
		"items": options,
	}
