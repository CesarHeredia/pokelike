# res://scripts/core/type_chart.gd
# Autoload singleton: "TypeChart"
#
# Contiene la tabla de efectividades de tipos Pokémon (generación 6+).
# REGLA ESPECIAL DE ESTE JUEGO:
#   Las inmunidades canónicas (0×) se sustituyen por 0.125×
#   (muy reducido, pero no completamente nulo).
#
# Valores posibles en la tabla:
#   2.0  → superefectivo
#   0.5  → poco eficaz
#   0.125→ "inmune" (modificado)
#   1.0  → neutro (no almacenado, es el valor por defecto)
extends Node

# ── Alias cortos para legibilidad ──────────────────────────────────────────────
const T = {
	"NOR": 0,  # Normal
	"FIR": 1,  # Fire / Fuego
	"WAT": 2,  # Water / Agua
	"ELE": 3,  # Electric / Eléctrico
	"GRA": 4,  # Grass / Planta
	"ICE": 5,  # Ice / Hielo
	"FIG": 6,  # Fighting / Lucha
	"POI": 7,  # Poison / Veneno
	"GRO": 8,  # Ground / Tierra
	"FLY": 9,  # Flying / Volador
	"PSY": 10, # Psychic / Psíquico
	"BUG": 11, # Bug / Bicho
	"ROC": 12, # Rock / Roca
	"GHO": 13, # Ghost / Fantasma
	"DRA": 14, # Dragon / Dragón
	"DAR": 15, # Dark / Siniestro
	"STE": 16, # Steel / Acero
	"FAI": 17, # Fairy / Hada
}

const IMMUNE: float = 0.125  # Inmunidades → daño muy reducido
const RESIST: float = 0.5    # Resistencia
const SUPER:  float = 2.0    # Superefectivo
const NEUTRO: float = 1.0    # Neutro (default)

## Tabla completa: _chart[atacante][defensor] = multiplicador
## Solo contiene entradas que NO son 1.0 (neutro).
var _chart: Dictionary = {}

func _ready() -> void:
	_build_chart()

func _build_chart() -> void:
	# Formato: _set(ATACANTE, DEFENSOR, MULTIPLICADOR)
	# ── NORMAL ─────────────────────────────────────────────────────────────────
	_set_val(T.NOR, T.ROC, RESIST)
	_set_val(T.NOR, T.STE, RESIST)
	_set_val(T.NOR, T.GHO, IMMUNE)  # Normal no afecta a Fantasma

	# ── FUEGO ──────────────────────────────────────────────────────────────────
	_set_val(T.FIR, T.FIR, RESIST)
	_set_val(T.FIR, T.WAT, RESIST)
	_set_val(T.FIR, T.ROC, RESIST)
	_set_val(T.FIR, T.DRA, RESIST)
	_set_val(T.FIR, T.GRA, SUPER)
	_set_val(T.FIR, T.ICE, SUPER)
	_set_val(T.FIR, T.BUG, SUPER)
	_set_val(T.FIR, T.STE, SUPER)

	# ── AGUA ───────────────────────────────────────────────────────────────────
	_set_val(T.WAT, T.WAT, RESIST)
	_set_val(T.WAT, T.GRA, RESIST)
	_set_val(T.WAT, T.DRA, RESIST)
	_set_val(T.WAT, T.FIR, SUPER)
	_set_val(T.WAT, T.GRO, SUPER)
	_set_val(T.WAT, T.ROC, SUPER)

	# ── ELÉCTRICO ──────────────────────────────────────────────────────────────
	_set_val(T.ELE, T.ELE, RESIST)
	_set_val(T.ELE, T.GRA, RESIST)
	_set_val(T.ELE, T.DRA, RESIST)
	_set_val(T.ELE, T.GRO, IMMUNE)  # Eléctrico no afecta a Tierra
	_set_val(T.ELE, T.WAT, SUPER)
	_set_val(T.ELE, T.FLY, SUPER)

	# ── PLANTA ─────────────────────────────────────────────────────────────────
	_set_val(T.GRA, T.FIR, RESIST)
	_set_val(T.GRA, T.GRA, RESIST)
	_set_val(T.GRA, T.POI, RESIST)
	_set_val(T.GRA, T.FLY, RESIST)
	_set_val(T.GRA, T.BUG, RESIST)
	_set_val(T.GRA, T.DRA, RESIST)
	_set_val(T.GRA, T.STE, RESIST)
	_set_val(T.GRA, T.WAT, SUPER)
	_set_val(T.GRA, T.GRO, SUPER)
	_set_val(T.GRA, T.ROC, SUPER)

	# ── HIELO ──────────────────────────────────────────────────────────────────
	_set_val(T.ICE, T.WAT, RESIST)
	_set_val(T.ICE, T.ICE, RESIST)
	_set_val(T.ICE, T.STE, RESIST)
	_set_val(T.ICE, T.FIR, RESIST)
	_set_val(T.ICE, T.GRA, SUPER)
	_set_val(T.ICE, T.GRO, SUPER)
	_set_val(T.ICE, T.FLY, SUPER)
	_set_val(T.ICE, T.DRA, SUPER)

	# ── LUCHA ──────────────────────────────────────────────────────────────────
	_set_val(T.FIG, T.POI, RESIST)
	_set_val(T.FIG, T.BUG, RESIST)
	_set_val(T.FIG, T.PSY, RESIST)
	_set_val(T.FIG, T.FLY, RESIST)
	_set_val(T.FIG, T.FAI, RESIST)
	_set_val(T.FIG, T.GHO, IMMUNE)  # Lucha no afecta a Fantasma
	_set_val(T.FIG, T.NOR, SUPER)
	_set_val(T.FIG, T.ICE, SUPER)
	_set_val(T.FIG, T.ROC, SUPER)
	_set_val(T.FIG, T.DAR, SUPER)
	_set_val(T.FIG, T.STE, SUPER)

	# ── VENENO ─────────────────────────────────────────────────────────────────
	_set_val(T.POI, T.POI, RESIST)
	_set_val(T.POI, T.GRO, RESIST)
	_set_val(T.POI, T.ROC, RESIST)
	_set_val(T.POI, T.GHO, RESIST)
	_set_val(T.POI, T.STE, IMMUNE)  # Veneno no afecta a Acero
	_set_val(T.POI, T.GRA, SUPER)
	_set_val(T.POI, T.FAI, SUPER)

	# ── TIERRA ─────────────────────────────────────────────────────────────────
	_set_val(T.GRO, T.GRA, RESIST)
	_set_val(T.GRO, T.BUG, RESIST)
	_set_val(T.GRO, T.FLY, IMMUNE)  # Tierra no afecta a Volador
	_set_val(T.GRO, T.FIR, SUPER)
	_set_val(T.GRO, T.ELE, SUPER)
	_set_val(T.GRO, T.POI, SUPER)
	_set_val(T.GRO, T.ROC, SUPER)
	_set_val(T.GRO, T.STE, SUPER)

	# ── VOLADOR ────────────────────────────────────────────────────────────────
	_set_val(T.FLY, T.ELE, RESIST)
	_set_val(T.FLY, T.ROC, RESIST)
	_set_val(T.FLY, T.STE, RESIST)
	_set_val(T.FLY, T.GRA, SUPER)
	_set_val(T.FLY, T.FIG, SUPER)
	_set_val(T.FLY, T.BUG, SUPER)

	# ── PSÍQUICO ───────────────────────────────────────────────────────────────
	_set_val(T.PSY, T.PSY, RESIST)
	_set_val(T.PSY, T.STE, RESIST)
	_set_val(T.PSY, T.DAR, IMMUNE)  # Psíquico no afecta a Siniestro
	_set_val(T.PSY, T.FIG, SUPER)
	_set_val(T.PSY, T.POI, SUPER)

	# ── BICHO ──────────────────────────────────────────────────────────────────
	_set_val(T.BUG, T.FIR, RESIST)
	_set_val(T.BUG, T.FIG, RESIST)
	_set_val(T.BUG, T.FLY, RESIST)
	_set_val(T.BUG, T.GHO, RESIST)
	_set_val(T.BUG, T.STE, RESIST)
	_set_val(T.BUG, T.FAI, RESIST)
	_set_val(T.BUG, T.POI, RESIST)
	_set_val(T.BUG, T.GRA, SUPER)
	_set_val(T.BUG, T.PSY, SUPER)
	_set_val(T.BUG, T.DAR, SUPER)

	# ── ROCA ───────────────────────────────────────────────────────────────────
	_set_val(T.ROC, T.FIG, RESIST)
	_set_val(T.ROC, T.GRO, RESIST)
	_set_val(T.ROC, T.STE, RESIST)
	_set_val(T.ROC, T.FIR, SUPER)
	_set_val(T.ROC, T.ICE, SUPER)
	_set_val(T.ROC, T.FLY, SUPER)
	_set_val(T.ROC, T.BUG, SUPER)

	# ── FANTASMA ───────────────────────────────────────────────────────────────
	_set_val(T.GHO, T.NOR, IMMUNE)  # Fantasma no afecta a Normal
	_set_val(T.GHO, T.DAR, RESIST)
	_set_val(T.GHO, T.PSY, SUPER)
	_set_val(T.GHO, T.GHO, SUPER)

	# ── DRAGÓN ─────────────────────────────────────────────────────────────────
	_set_val(T.DRA, T.FAI, IMMUNE)  # Dragón no afecta a Hada
	_set_val(T.DRA, T.STE, RESIST)
	_set_val(T.DRA, T.DRA, SUPER)

	# ── SINIESTRO ──────────────────────────────────────────────────────────────
	_set_val(T.DAR, T.FIG, RESIST)
	_set_val(T.DAR, T.DAR, RESIST)
	_set_val(T.DAR, T.FAI, RESIST)
	_set_val(T.DAR, T.PSY, SUPER)
	_set_val(T.DAR, T.GHO, SUPER)

	# ── ACERO ──────────────────────────────────────────────────────────────────
	_set_val(T.STE, T.FIR, RESIST)
	_set_val(T.STE, T.WAT, RESIST)
	_set_val(T.STE, T.ELE, RESIST)
	_set_val(T.STE, T.STE, RESIST)
	_set_val(T.STE, T.ICE, SUPER)
	_set_val(T.STE, T.ROC, SUPER)
	_set_val(T.STE, T.FAI, SUPER)

	# ── HADA ───────────────────────────────────────────────────────────────────
	_set_val(T.FAI, T.FIR, RESIST)
	_set_val(T.FAI, T.POI, RESIST)
	_set_val(T.FAI, T.STE, RESIST)
	_set_val(T.FAI, T.FIG, SUPER)
	_set_val(T.FAI, T.DRA, SUPER)
	_set_val(T.FAI, T.DAR, SUPER)

# ── API pública ────────────────────────────────────────────────────────────────

## Devuelve el multiplicador de efectividad de un ataque de [attacker_type]
## sobre un defensor de [defender_type].
func get_effectiveness(attacker_type: int, defender_type: int) -> float:
	if _chart.has(attacker_type) and _chart[attacker_type].has(defender_type):
		return _chart[attacker_type][defender_type]
	return NEUTRO

## Devuelve el multiplicador total de un ataque de [attacker_type]
## sobre un Pokémon con tipos [def_type1] y [def_type2].
## Pasa -1 en def_type2 si el defensor tiene un solo tipo.
func get_total_effectiveness(attacker_type: int, def_type1: int, def_type2: int = -1) -> float:
	var mult: float = get_effectiveness(attacker_type, def_type1)
	if def_type2 >= 0:
		mult *= get_effectiveness(attacker_type, def_type2)
	return mult

## Devuelve una etiqueta descriptiva del multiplicador para la UI.
## Ejemplo: 2.0 → "¡Super eficaz!", 0.5 → "Poco eficaz..."
func effectiveness_label(mult: float) -> String:
	if mult >= 4.0:
		return "¡¡¡Superpotente!!!"
	elif mult >= 2.0:
		return "¡Super eficaz!"
	elif mult <= IMMUNE + 0.01:
		return "Casi sin efecto..."
	elif mult <= 0.25:
		return "Muy poco eficaz..."
	elif mult < 1.0:
		return "Poco eficaz..."
	return ""

# ── Internos ───────────────────────────────────────────────────────────────────
func _set_val(attacker: int, defender: int, value: float) -> void:
	if not _chart.has(attacker):
		_chart[attacker] = {}
	_chart[attacker][defender] = value
