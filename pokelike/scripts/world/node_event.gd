# res://scripts/world/node_event.gd
class_name NodeEvent
extends Resource

## Tipo de nodo que este evento representa (ej: "GRASS", "TRAINER", "BOSS")
var event_type: String = ""
## Ruta del ícono PNG del nodo
var icon_path: String = ""
## Etiqueta que se muestra en el mapa bajo el nodo
var label: String = ""

## Ejecuta el evento y devuelve un diccionario de resultado.
## El diccionario describe qué debe hacer el mapa a continuación.
##
## context: Diccionario con datos del nodo (id, type, pos, etc.)
##          Para nodos TRAINER incluye también "trainer_idx" y "pokemon".
##
## ── Formato del diccionario de resultado ──────────────────────────────────────
## Batalla:
##   { "type": "battle", "battle_mode": String, "details": Dictionary }
##
## Regalo (Pokébola):
##   { "type": "gift", "pool": Array }
##
## Recompensa (MT) con notificación opcional:
##   { "type": "reward", "reward": Dictionary, "notification": Dictionary? }
##   Donde notification es { "text": String, "color": Color }
##
## Notificación pura (Bolso):
##   { "type": "notification", "text": String, "color": Color }
##
## Selección de objeto (Bolso con objetos):
##   { "type": "item_choice", "items": Array[Dictionary] }
##   Donde cada item es { "id": int, "name": String, "desc": String, "icon": String }
##
## Selección de starter:
##   { "type": "starter" }
##
## Sin acción:
##   { "type": "none" }
func execute(_map: MapConfig, _context: Dictionary) -> Dictionary:
	return {"type": "none"}
