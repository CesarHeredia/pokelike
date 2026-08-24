# res://scripts/world/regions/kanto/gym1_brock/brock_boss_event.gd
class_name BrockBossEvent
extends BossEvent

func _init() -> void:
	event_type = "BOSS"
	icon_path  = "res://assets/sprites/objetos_mapa/entrenadores/brock1.PNG"
	label      = "Gimnasio de Pewter (Brock)"

func execute(map: MapConfig, context: Dictionary) -> Dictionary:
	var result: Dictionary = super.execute(map, context)
	if not result.is_empty() and result.has("details"):
		result["details"]["chapter"] = "Líder de Gimnasio - Brock"
	return result
