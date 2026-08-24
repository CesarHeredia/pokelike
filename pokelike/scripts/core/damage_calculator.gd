# res://scripts/core/damage_calculator.gd
# Autoload singleton: "DamageCalc"
#
# Calcula el daño de un movimiento Pokémon usando la fórmula clásica
# (simplificada para este juego) más el multiplicador de tipos.
#
# Fórmula base (Gen 5+):
#   Daño = ((2 * Nivel / 5 + 2) * Poder * Atk / Def / 50 + 2) * Modificadores
#
# Modificadores incluidos:
#   - Efectividad de tipo (via TypeChart)
#   - STAB (Same Type Attack Bonus) +50%
#   - Factor aleatorio (0.85 – 1.00)
extends Node

const STAB_BONUS: float = 1.5

## Resultado de un cálculo de daño.
class DamageResult:
	var damage: int        ## Daño final
	var type_mult: float   ## Multiplicador de tipo aplicado
	var stab: bool         ## ¿Se aplicó STAB?
	var label: String      ## Etiqueta descriptiva ("¡Super eficaz!" etc.)

	func _init(d: int, tm: float, s: bool, l: String) -> void:
		damage    = d
		type_mult = tm
		stab      = s
		label     = l

## Calcula el daño de un ataque.
##
## Parámetros:
##   move_type      → Tipo del movimiento (Enums.PokemonType)
##   attacker_type  → PokemonTypeData del atacante (para STAB)
##   defender_types → PokemonTypeData del defensor
##   base_power     → Potencia base del movimiento
##   atk_stat       → Estadística de Ataque (o Atk. Esp.) del atacante
##   def_stat       → Estadística de Defensa (o Def. Esp.) del defensor
##   level          → Nivel del atacante (default 50)
##   random         → Si true, aplica factor aleatorio 0.85–1.00
##
## Devuelve: DamageResult
func calculate(
	move_type:      int,
	attacker_type:  PokemonTypeData,
	defender_types: PokemonTypeData,
	base_power:     int,
	atk_stat:       int,
	def_stat:       int,
	level:          int = 50,
	random:         bool = true
) -> DamageResult:

	# ── Fórmula base ─────────────────────────────────────────────────────────
	var base: float = (float(2 * level) / 5.0 + 2.0) * base_power * atk_stat
	base = base / float(def_stat) / 50.0 + 2.0

	# ── Modificadores ─────────────────────────────────────────────────────────
	# 1. Efectividad de tipo
	var type_mult: float = defender_types.get_defense_multiplier(move_type)

	# 2. STAB
	var has_stab: bool = (
		move_type == attacker_type.primary or
		(attacker_type.is_dual_type() and move_type == attacker_type.secondary)
	)
	var stab_mult: float = STAB_BONUS if has_stab else 1.0

	# 3. Aleatorio
	var rand_mult: float = 1.0
	if random:
		rand_mult = randf_range(0.85, 1.0)

	# ── Resultado final ───────────────────────────────────────────────────────
	var final_damage: int = maxi(1, int(base * type_mult * stab_mult * rand_mult))
	var label: String = TypeChart.effectiveness_label(type_mult)

	return DamageResult.new(final_damage, type_mult, has_stab, label)

## Versión simplificada para cálculos rápidos (sin stats de nivel).
## Útil para comparaciones de tipo en la UI.
func type_effectiveness(move_type: int, defender: PokemonTypeData) -> float:
	return defender.get_defense_multiplier(move_type)
