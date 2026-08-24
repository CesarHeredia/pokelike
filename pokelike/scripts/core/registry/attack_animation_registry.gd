# res://scripts/core/registry/attack_animation_registry.gd
# Registra las animaciones de ataque por tipo y categoría.
# Cada entrada: { "path": String, "cols": int, "rows": int, "fps": float }
extends RefCounted

## Estructura de datos: anims[type_id][category] = AnimationData
## category: Move.Category.PHYSICAL = 0, Move.Category.SPECIAL = 1
var anims: Dictionary = {}

func _init() -> void:
	_register_all()

func _register_all() -> void:
	# ── NORMAL (type 0) ─────────────────────────────────────────────────────
	_register(0, 0, "res://assets/sprites/movimientos/normal.png", 5, 2, 10.0)
	_register(0, 1, "res://assets/sprites/movimientos/normal.png", 5, 2, 10.0)

	# ── FUEGO (type 1) ──────────────────────────────────────────────────────
	_register(1, 0, "res://assets/sprites/movimientos/fuego.png", 5, 1, 10.0)
	_register(1, 1, "res://assets/sprites/movimientos/fuego.png", 5, 1, 10.0)

	# ── AGUA (type 2) ───────────────────────────────────────────────────────
	_register(2, 0, "res://assets/sprites/movimientos/agua.png", 5, 2, 10.0)
	_register(2, 1, "res://assets/sprites/movimientos/agua.png", 5, 2, 10.0)

	# ── ELÉCTRICO (type 3) ──────────────────────────────────────────────────
	_register(3, 0, "res://assets/sprites/movimientos/electrico.png", 5, 2, 10.0)
	_register(3, 1, "res://assets/sprites/movimientos/electrico.png", 5, 2, 10.0)

	# ── PLANTA (type 4) ─────────────────────────────────────────────────────
	_register(4, 0, "res://assets/sprites/movimientos/planta.png", 4, 1, 5.0)
	_register(4, 1, "res://assets/sprites/movimientos/planta.png", 4, 1, 5.0)

	# ── HIELO (type 5) ──────────────────────────────────────────────────────
	_register(5, 0, "res://assets/sprites/movimientos/hielo.png", 5, 2, 10.0)
	_register(5, 1, "res://assets/sprites/movimientos/hielo.png", 5, 2, 10.0)

	# ── LUCHA (type 6) ──────────────────────────────────────────────────────
	_register(6, 0, "res://assets/sprites/movimientos/lucha.png", 5, 2, 5.0, "", "big")
	_register(6, 1, "res://assets/sprites/movimientos/lucha.png", 5, 2, 5.0, "", "big")

	# ── VENENO (type 7) ─────────────────────────────────────────────────────
	_register(7, 0, "res://assets/sprites/movimientos/veneno.png", 5, 2, 5.0)
	_register(7, 1, "res://assets/sprites/movimientos/veneno.png", 5, 2, 5.0)

	# ── TIERRA (type 8) ─────────────────────────────────────────────────────
	_register(8, 0, "res://assets/sprites/movimientos/tierra.png", 5, 1, 10.0, "", "bottom")
	_register(8, 1, "res://assets/sprites/movimientos/tierra.png", 5, 1, 10.0, "", "bottom")

	# ── VOLADOR (type 9) ────────────────────────────────────────────────────
	_register(9, 0, "res://assets/sprites/movimientos/volador (2).png", 2, 1, 10.0, "", "centered")
	_register(9, 1, "res://assets/sprites/movimientos/volador (2).png", 2, 1, 10.0, "", "centered")

	# ── PSÍQUICO (type 10) ──────────────────────────────────────────────────
	_register(10, 0, "res://assets/sprites/movimientos/psyquico.png", 5, 2, 10.0)
	_register(10, 1, "res://assets/sprites/movimientos/psyquico.png", 5, 2, 10.0)

	# ── BICHO (type 11) ─────────────────────────────────────────────────────
	_register(11, 0, "res://assets/sprites/movimientos/bicho.png", 8, 6, 5.0)
	_register(11, 1, "res://assets/sprites/movimientos/bicho.png", 8, 6, 5.0)

	# ── ROCA (type 12) ──────────────────────────────────────────────────────
	_register(12, 0, "res://assets/sprites/movimientos/roca.png", 2, 1, 5.0)
	_register(12, 1, "res://assets/sprites/movimientos/roca.png", 2, 1, 5.0)

	# ── FANTASMA (type 13) ──────────────────────────────────────────────────
	_register(13, 0, "res://assets/sprites/movimientos/fantasma.png", 8, 6, 24.0)
	_register(13, 1, "res://assets/sprites/movimientos/fantasma.png", 8, 6, 24.0)

	# ── DRAGÓN (type 14) ────────────────────────────────────────────────────
	_register(14, 0, "res://assets/sprites/movimientos/dragon.png", 8, 6, 24.0)
	_register(14, 1, "res://assets/sprites/movimientos/dragon.png", 8, 6, 24.0)

	# ── SINIESTRO (type 15) ─────────────────────────────────────────────────
	_register(15, 0, "res://assets/sprites/movimientos/siniestro.png", 4, 5, 10.0)
	_register(15, 1, "res://assets/sprites/movimientos/siniestro.png", 4, 5, 10.0)

	# ── ACERO (type 16) ─────────────────────────────────────────────────────
	_register(16, 0, "res://assets/sprites/movimientos/acero.png", 2, 1, 5.0)
	_register(16, 1, "res://assets/sprites/movimientos/acero.png", 2, 1, 5.0)

	# ── HADA (type 17) ──────────────────────────────────────────────────────
	_register(17, 0, "res://assets/sprites/movimientos/hada.png", 5, 2, 10.0)
	_register(17, 1, "res://assets/sprites/movimientos/hada.png", 5, 2, 10.0)

	# Se pueden agregar los demás tipos conforme se creen los sprites

func _register(type_id: int, category: int, path: String, cols: int, rows: int, fps: float, power_key: String = "", pos: String = "full") -> void:
	if not anims.has(type_id):
		anims[type_id] = {}
	if not anims[type_id].has(category):
		anims[type_id][category] = {}
	var anim_data: Dictionary = {
		"path": path,
		"cols": cols,
		"rows": rows,
		"fps": fps,
		"frame_count": cols * rows,
		"frame_w": 0,
		"frame_h": 0,
		"position": pos,
	}
	anims[type_id][category][power_key] = anim_data

## Obtiene la animación para un ataque dado.
func get_animation(type_id: int, category: int, power: int = 0) -> Dictionary:
	if not anims.has(type_id):
		return {}
	if not anims[type_id].has(category):
		return {}
	var by_power: Dictionary = anims[type_id][category]
	var pkey := str(power)
	if by_power.has(pkey):
		return by_power[pkey]
	if by_power.has(""):
		return by_power[""]
	return {}
