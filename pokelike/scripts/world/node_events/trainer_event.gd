# res://scripts/world/node_events/trainer_event.gd
class_name TrainerEvent
extends NodeEvent

func _init() -> void:
	event_type = "TRAINER"
	icon_path  = "res://assets/sprites/objetos_mapa/000.png"
	label      = "Entrenador"

## Genera la batalla contra el entrenador asignado al nodo.
##
## El contexto debe incluir:
##   context["trainer_idx"] → índice en map.get_trainer_classes()
##   context["pokemon"]     → nombre del Pokémon elegido en la randomización
##
## El entrenador adapta su equipo (nivel, tamaño) según map.trainer_level
## y map.enemy_team_size.
func execute(map: MapConfig, context: Dictionary) -> Dictionary:
	var t_idx: int     = int(context.get("trainer_idx", 0))
	var chosen: String = String(context.get("pokemon", "Rattata"))
	
	var trainer_classes: Array = map.get_trainer_classes()
	if trainer_classes.is_empty():
		return {"type": "none"}
	
	var tc: TrainerClass = trainer_classes[t_idx % trainer_classes.size()]
	var details: Dictionary = tc.generate_battle_data(map, chosen)
	
	return {
		"type":        "battle",
		"battle_mode": "HISTORIA",
		"details":     details
	}
