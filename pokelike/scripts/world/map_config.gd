# res://scripts/world/map_config.gd
class_name MapConfig
extends Resource

## ── Propiedades escalares del mapa ────────────────────────────────────────────
## Identificador único del mapa (ej: "kanto_brock")
var map_id: String = ""
## Nombre legible del mapa
var display_name: String = ""
## Nivel máximo de Pokémon permitido en este mapa
var level_cap: int = 10
## Cantidad de Pokémon por equipo de entrenador enemigo
var enemy_team_size: int = 1
## Nivel de los Pokémon de los entrenadores
var trainer_level: int = 4
## Nivel de los Pokémon salvajes
var wild_level: int = 4
## Cantidad máxima de nodos TRAINER que aparecen en el mapa
var max_trainers: int = 4

## ── Datos del jefe del mapa ───────────────────────────────────────────────────
## Nombre del jefe que se muestra en batalla
var boss_name: String = ""
## Título del capítulo del jefe (para la UI de batalla)
var boss_chapter_name: String = ""
## Color de fondo de la pantalla de batalla del jefe
var boss_bg_color: Color = Color("1a0e0e")
## Equipo del jefe: Array de {"name": String, "level": int}
var boss_team: Array = []

## ── Rutas de íconos para nodos (override en subclases) ───────────────────────
var icon_grass: String    = "res://assets/sprites/objetos_mapa/frlgpng.png"
var icon_bag: String      = "res://assets/sprites/objetos_mapa/bag_1.png"
var icon_event: String    = "res://assets/sprites/objetos_mapa/000.png"
var icon_tm: String       = "res://assets/sprites/objetos_mapa/machine_tr_NORMAL.png"
var icon_pokeball: String = "res://assets/sprites/objetos_mapa/POKEBALL.png"
## Ícono del jefe — debe definirse en cada subclase de gimnasio
var icon_boss: String     = ""
## Ruta de la imagen de fondo del mapa (vacío = color sólido)
var map_bg_image: String  = ""

## ── Métodos de datos (override en subclases) ─────────────────────────────────

## Devuelve el árbol de capas de nodos del mapa.
## Cada capa es un Array de Dictionary con las claves:
##   id, type, icon, label, pos (Vector2), next (Array[String])
func get_map_layers() -> Array:
	return []

## Devuelve el pool de nombres de Pokémon salvajes de este mapa.
func get_wild_pool() -> Array:
	return []

## Devuelve el pool de regalo del nodo Pokébola.
## Cada elemento es un Dictionary con datos del Pokémon.
func get_gift_pool() -> Array:
	return []

## Devuelve las instancias de TrainerClass disponibles para este mapa.
## Los entrenadores adaptan su nivel y tamaño de equipo según las propiedades
## de este MapConfig cuando generan sus datos de batalla.
func get_trainer_classes() -> Array:
	return []

## Devuelve los tipos de nodo que pueden aparecer al azar en nodos intermedios.
func get_possible_node_types() -> Array[String]:
	return ["GRASS", "BAG", "POKEBALL", "EVENT", "TM"]

## Crea y devuelve el NodeEvent apropiado para un tipo de nodo dado.
## Las subclases sobreescriben este método para devolver eventos personalizados
## (por ejemplo, BrockMapConfig devuelve BrockBossEvent para "BOSS").
func create_node_event(n_data: Dictionary) -> NodeEvent:
	match n_data.get("type", ""):
		"STARTER":  return load("res://scripts/world/node_events/starter_event.gd").new()
		"GRASS":    return load("res://scripts/world/node_events/grass_event.gd").new()
		"BAG":      return load("res://scripts/world/node_events/bag_event.gd").new()
		"TM":       return load("res://scripts/world/node_events/tm_event.gd").new()
		"POKEBALL": return load("res://scripts/world/node_events/pokeball_event.gd").new()
		"EVENT":    return load("res://scripts/world/node_events/random_event.gd").new()
		"TRAINER":  return load("res://scripts/world/node_events/trainer_event.gd").new()
		"BOSS":     return load("res://scripts/world/node_events/boss_event.gd").new()
	return load("res://scripts/world/node_event.gd").new()
