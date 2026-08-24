# res://scripts/world/trainer_class.gd
class_name TrainerClass
extends Resource

## ── Identidad del entrenador ──────────────────────────────────────────────────
## Identificador único del tipo de entrenador (ej: "bug_catcher")
var trainer_id: String = ""
## Nombre que se muestra en la UI de batalla
var display_name: String = ""
## Ruta del sprite del entrenador (sprite sheet o PNG estático)
var sprite_path: String = ""
## Pool de nombres de Pokémon que puede usar este tipo de entrenador.
## La selección específica se hace durante la randomización del mapa.
var pokemon_pool: Array[String] = []
## Tipo de recompensa al derrotarlo
var reward_type: String = "trainer_win"

## ── Adaptación al mapa ────────────────────────────────────────────────────────
## Genera los datos de batalla adaptados al contexto del mapa actual.
##
## El mapa provee:
##   - map.trainer_level  → nivel de los Pokémon del entrenador
##   - map.enemy_team_size → cuántos Pokémon puede llevar el entrenador
##
## chosen_pokemon es el Pokémon elegido durante la randomización del mapa.
## Si el equipo permite más de un Pokémon, se rellenan del pool aleatoriamente.
func generate_battle_data(map: MapConfig, chosen_pokemon: String) -> Dictionary:
	var level: int     = map.trainer_level
	var team_size: int = map.enemy_team_size

	# Construir el equipo del entrenador
	var team: Array = []

	# El primer Pokémon siempre es el elegido durante randomización
	if not chosen_pokemon.is_empty():
		team.append({"name": chosen_pokemon, "level": level})
	
	# Si el tamaño de equipo permite más Pokémon, rellenar del pool
	if team_size > 1:
		var remaining: Array[String] = pokemon_pool.duplicate()
		remaining.erase(chosen_pokemon)
		remaining.shuffle()
		for i in range(mini(team_size - 1, remaining.size())):
			team.append({"name": remaining[i], "level": level})

	# Fallback si el pool estaba vacío
	if team.is_empty():
		team.append({"name": "Rattata", "level": level})

	var main_poke: String = String(team[0].get("name", "?"))
	return {
		"chapter":        "Entrenador - " + display_name,
		"enemy_name":     display_name,
		"enemy_pokemon":  "%s Lv.%d" % [main_poke, level],
		"trainer_team":   team,
		"trainer_sprite": sprite_path,
		"wild_name":      main_poke,
		"wild_level":     level,
		"reward_type":    reward_type,
		"bg_color":       Color("0d0a1a")
	}
