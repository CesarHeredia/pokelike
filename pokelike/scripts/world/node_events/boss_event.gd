# res://scripts/world/node_events/boss_event.gd
class_name BossEvent
extends NodeEvent

func _init() -> void:
	event_type = "BOSS"
	icon_path  = ""          # Override en subclases de cada gimnasio
	label      = "Jefe de Gimnasio"

## Genera la batalla contra el jefe usando los datos del MapConfig.
## Las subclases (BrockBossEvent, MistyBossEvent, etc.) pueden sobreescribir
## este método para añadir lógica especial del jefe.
func execute(map: MapConfig, _context: Dictionary) -> Dictionary:
	if map.boss_team.is_empty():
		return {"type": "none"}
	
	var last_poke: Dictionary = map.boss_team[-1]
	return {
		"type":        "battle",
		"battle_mode": "HISTORIA",
		"details": {
			"chapter":        map.boss_chapter_name,
			"enemy_name":     map.boss_name,
			"enemy_pokemon":  "%s Lv.%d" % [
				String(last_poke.get("name", "?")),
				int(last_poke.get("level", 10))
			],
			"trainer_team":   map.boss_team,
			"reward_type":    "none",
			"bg_color":       map.boss_bg_color
		}
	}
