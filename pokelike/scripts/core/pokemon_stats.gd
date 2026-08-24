# res://scripts/core/pokemon_stats.gd
# Clase Resource: PokemonStats
#
# Estadísticas de un Pokémon calculadas a partir de stats base + nivel.
# Sin IVs ni EVs. Fórmula estándar Gen 3+.
#
# HP  = floor(2 * base_hp * lvl / 100) + lvl + 10
# Resto = floor(2 * base_stat * lvl / 100) + 5
class_name PokemonStats
extends Resource

# ── Stats base (definidas por especie) ────────────────────────────────────────
@export var base_hp:        int = 45
@export var base_attack:    int = 49
@export var base_defense:   int = 49
@export var base_sp_attack: int = 65
@export var base_sp_defense:int = 65
@export var base_speed:     int = 45

# ── Stats calculadas (se generan con recalculate) ─────────────────────────────
var hp_max:     int = 1
var hp_current: int = 1
var attack:     int = 1
var defense:    int = 1
var sp_attack:  int = 1
var sp_defense: int = 1
var speed:      int = 1

# ── Modificadores de batalla (se resetean al terminar el combate) ──────────────
## Cada stage va de -6 a +6, igual que en los juegos oficiales.
var stage_attack:     int = 0
var stage_defense:    int = 0
var stage_sp_attack:  int = 0
var stage_sp_defense: int = 0
var stage_speed:      int = 0
var stage_accuracy:   int = 0
var stage_evasion:    int = 0

## Constructor conveniente.
static func create(
	b_hp: int, b_atk: int, b_def: int,
	b_spe: int, b_spa: int, b_spd: int
) -> PokemonStats:
	var s := PokemonStats.new()
	s.base_hp         = b_hp
	s.base_attack     = b_atk
	s.base_defense    = b_def
	s.base_speed      = b_spe
	s.base_sp_attack  = b_spa
	s.base_sp_defense = b_spd
	return s

## Recalcula todas las stats para un nivel dado.
## Si el HP Máximo aumenta, la diferencia se suma al HP Actual
## (no se cura al 100% ni pierde porcentaje de vida).
func recalculate(level: int) -> void:
	var old_hp_max: int = hp_max
	hp_max = _calc_hp(base_hp, level)
	attack     = _calc_stat(base_attack,     level)
	defense    = _calc_stat(base_defense,    level)
	sp_attack  = _calc_stat(base_sp_attack,  level)
	sp_defense = _calc_stat(base_sp_defense, level)
	speed      = _calc_stat(base_speed,      level)

	# Preservar HP: si el máximo sube, sumar la diferencia al actual
	if old_hp_max <= 0:
		hp_current = hp_max
	elif hp_max > old_hp_max:
		hp_current = mini(hp_max, hp_current + (hp_max - old_hp_max))
	else:
		hp_current = mini(hp_max, hp_current)

## Devuelve el multiplicador de stage para una stat de ataque/defensa.
## Tabla oficial: ±1 = 1.5×/0.67×, ±2 = 2×/0.5×, …, ±6 = 4×/0.25×
func stage_multiplier(stage: int) -> float:
	var clamped := clampi(stage, -6, 6)
	if clamped >= 0:
		return (2.0 + clamped) / 2.0
	else:
		return 2.0 / (2.0 - clamped)

## Ataque efectivo con stage aplicado.
func effective_attack() -> int:
	return maxi(1, int(attack * stage_multiplier(stage_attack)))

## Defensa efectiva con stage aplicado.
func effective_defense() -> int:
	return maxi(1, int(defense * stage_multiplier(stage_defense)))

## Atk especial efectivo.
func effective_sp_attack() -> int:
	return maxi(1, int(sp_attack * stage_multiplier(stage_sp_attack)))

## Def especial efectiva.
func effective_sp_defense() -> int:
	return maxi(1, int(sp_defense * stage_multiplier(stage_sp_defense)))

## Velocidad efectiva.
func effective_speed() -> int:
	return maxi(1, int(speed * stage_multiplier(stage_speed)))

## Aplica daño y retorna true si el Pokémon se debilitó.
func take_damage(amount: int) -> bool:
	hp_current = maxi(0, hp_current - amount)
	return hp_current == 0

## Cura HP. No puede superar hp_max.
func heal(amount: int) -> void:
	hp_current = mini(hp_max, hp_current + amount)

## Porcentaje de HP actual (0.0 – 1.0).
func hp_ratio() -> float:
	if hp_max <= 0:
		return 0.0
	return float(hp_current) / float(hp_max)

## Resetea todos los stages a 0 (fin de batalla).
func reset_stages() -> void:
	stage_attack = 0
	stage_defense = 0
	stage_sp_attack = 0
	stage_sp_defense = 0
	stage_speed = 0
	stage_accuracy = 0
	stage_evasion = 0

# ── Internos ──────────────────────────────────────────────────────────────────
func _calc_hp(base: int, lvl: int) -> int:
	return int(2.0 * base * lvl / 100.0) + lvl + 10

func _calc_stat(base: int, lvl: int) -> int:
	return int(2.0 * base * lvl / 100.0) + 5
