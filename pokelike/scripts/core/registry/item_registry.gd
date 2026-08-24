# res://scripts/core/registry/item_registry.gd
# Autoload: ItemRegistry
# Registro central de todos los objetos equipables.
extends Node

## Efectos posibles de un objeto.
enum EffectType {
	NONE,
	STAT_BOOST_ATK,       # +X% ATK y ATK_SP
	STAT_BOOST_DEF,       # +X% DEF y DEF_SP
	TYPE_BOOST,           # +X% ataques de un tipo específico
	HEAL_PER_TURN,        # Cura X% HP al final del turno
	RECOIL_DAMAGE,        # Quita X% HP al final del turno
	RECOIL_BOOST,         # Cada vez que quita vida, +X% ATK/ATK_SP
	MOVE_COUNTER_BOOST,   # +X% ATK/ATK_SP, se acumula cada turno
	EXP_BOOST,            # +1 nivel extra al ganar combate
	PREVENT_EVOLUTION,    # Impide evolución + stat boost
}

## Datos de un objeto.
class ItemData:
	var id: int
	var name: String
	var description: String
	var icon_path: String
	var effect_type: int
	var effect_value: float        # Porcentaje (0.2 = 20%)
	var effect_types: Array[int]   # Para TYPE_BOOST: qué tipo(s) potencia
	var prevents_evolution: bool
	var evo_stat_boost: String     # "atk", "def", "" para PREVENT_EVOLUTION

	func _init(p_id: int, p_name: String, p_desc: String, p_icon: String,
			p_effect: int, p_value: float = 0.0, p_types: Array[int] = [],
			p_prevent_evo: bool = false, p_evo_stat: String = ""):
		id = p_id
		name = p_name
		description = p_desc
		icon_path = p_icon
		effect_type = p_effect
		effect_value = p_value
		effect_types = p_types
		prevents_evolution = p_prevent_evo
		evo_stat_boost = p_evo_stat

var _items: Dictionary = {}

func _ready() -> void:
	_register_all_items()

func get_item(id: int) -> ItemData:
	return _items.get(id, null)

func get_item_name(id: int) -> String:
	var item: ItemData = _items.get(id, null)
	return item.name if item else ""

func get_all_item_ids() -> Array[int]:
	var ids: Array[int] = []
	for id in _items:
		ids.append(id)
	ids.sort()
	return ids

func get_random_items(count: int, exclude: Array[int] = []) -> Array[int]:
	var available: Array[int] = []
	for id in _items:
		if id not in exclude:
			available.append(id)
	available.shuffle()
	var result: Array[int] = []
	for i in range(mini(count, available.size())):
		result.append(available[i])
	return result

func _register_all_items() -> void:
	# ID 1: Piedra Eterna (Everstone) — Impide evolución, +50% ATK y ATK_SP
	_items[1] = ItemData.new(1, "Piedra Eterna",
		"Detiene la evolución. +50% ATK y ATK SP.",
		"res://assets/sprites/objetos de bolso/EVERSTONE.png",
		EffectType.PREVENT_EVOLUTION, 0.5, [], true, "atk")

	# ID 2: Mineral Evolutivo (Eviolite) — Impide evolución, +50% DEF y DEF_SP
	_items[2] = ItemData.new(2, "Mineral Evolutivo",
		"Detiene la evolución. +50% DEF y DEF SP.",
		"res://assets/sprites/objetos de bolso/EVIOLITE.png",
		EffectType.PREVENT_EVOLUTION, 0.5, [], true, "def")

	# ID 3: Piedra Dura (Hard Stone) — +20% ataques tipo Roca
	_items[3] = ItemData.new(3, "Piedra Dura",
		"Potencia un 20% los ataques de tipo Roca.",
		"res://assets/sprites/objetos de bolso/HARDSTONE.png",
		EffectType.TYPE_BOOST, 0.2, [Enums.PokemonType.ROCK])

	# ID 4: Restos (Leftovers) — Cura 10% HP al final del turno
	_items[4] = ItemData.new(4, "Restos",
		"Cura 10% de la vida al final del turno.",
		"res://assets/sprites/objetos de bolso/LEFTOVERS.png",
		EffectType.HEAL_PER_TURN, 0.1)

	# ID 5: Vidaesfera (Life Orb) — +20% ATK/ATK_SP, quita 5% HP, +10% adicional cada vez que daña
	_items[5] = ItemData.new(5, "Vidaesfera",
		"+20% ATK y ATK SP. Quita 5% HP al final del turno.\nCada vez que quita vida: +10% ATK/ATK SP.",
		"res://assets/sprites/objetos de bolso/LIFEORB.png",
		EffectType.RECOIL_BOOST, 0.2)

	# ID 6: Revestimiento Metálico (Metal Coat) — +20% ataques tipo Acero
	_items[6] = ItemData.new(6, "Revestimiento Metálico",
		"Potencia un 20% los ataques de tipo Acero.",
		"res://assets/sprites/objetos de bolso/METALCOAT.png",
		EffectType.TYPE_BOOST, 0.2, [Enums.PokemonType.STEEL])

	# ID 7: Metronomo (Metronome) — +10% ATK/ATK_SP, +10% más cada turno
	_items[7] = ItemData.new(7, "Metronomo",
		"+10% ATK y ATK SP. Cada turno suma +10% más.",
		"res://assets/sprites/objetos de bolso/METRONOME.png",
		EffectType.MOVE_COUNTER_BOOST, 0.1)

	# ID 8: Semilla Milagro (Miracle Seed) — +20% ataques tipo Planta
	_items[8] = ItemData.new(8, "Semilla Milagro",
		"Potencia un 20% los ataques de tipo Planta.",
		"res://assets/sprites/objetos de bolso/MIRACLESEED.png",
		EffectType.TYPE_BOOST, 0.2, [Enums.PokemonType.GRASS])

	# ID 9: Cinta Fuerte (Muscle Band) — +20% ataques tipo Lucha
	_items[9] = ItemData.new(9, "Cinta Fuerte",
		"Potencia un 20% los ataques de tipo Lucha.",
		"res://assets/sprites/objetos de bolso/MUSCLEBAND.png",
		EffectType.TYPE_BOOST, 0.2, [Enums.PokemonType.FIGHTING])

	# ID 10: Agua Mística (Mystic Water) — +20% ataques tipo Agua
	_items[10] = ItemData.new(10, "Agua Mística",
		"Potencia un 20% los ataques de tipo Agua.",
		"res://assets/sprites/objetos de bolso/MYSTICWATER.png",
		EffectType.TYPE_BOOST, 0.2, [Enums.PokemonType.WATER])

	# ID 11: Hielo Perpetuo (Never-Melt Ice) — +20% ataques tipo Hielo
	_items[11] = ItemData.new(11, "Hielo Perpetuo",
		"Potencia un 20% los ataques de tipo Hielo.",
		"res://assets/sprites/objetos de bolso/NEVERMELTICE.png",
		EffectType.TYPE_BOOST, 0.2, [Enums.PokemonType.ICE])

	# ID 12: Huevo Suerte (Lucky Egg) — +1 nivel extra al ganar
	_items[12] = ItemData.new(12, "Huevo Suerte",
		"+1 nivel extra al ganar combate (hierva o entrenador).",
		"res://assets/sprites/objetos de bolso/LUCKYEGG.png",
		EffectType.EXP_BOOST, 1.0)

	# ID 13: Pañuelo Sed (Silk Scarf) — +20% ataques tipo Normal
	_items[13] = ItemData.new(13, "Pañuelo Sed",
		"Potencia un 20% los ataques de tipo Normal.",
		"res://assets/sprites/objetos de bolso/SILKSCARF.png",
		EffectType.TYPE_BOOST, 0.2, [Enums.PokemonType.NORMAL])

	# ID 14: Polvo Plata (Silver Powder) — +20% ataques tipo Bicho
	_items[14] = ItemData.new(14, "Polvo Plata",
		"Potencia un 20% los ataques de tipo Bicho.",
		"res://assets/sprites/objetos de bolso/SILVERPOWDER.png",
		EffectType.TYPE_BOOST, 0.2, [Enums.PokemonType.BUG])

	# ID 15: Arena Fina (Soft Sand) — +20% ataques tipo Tierra
	_items[15] = ItemData.new(15, "Arena Fina",
		"Potencia un 20% los ataques de tipo Tierra.",
		"res://assets/sprites/objetos de bolso/SOFTSAND.png",
		EffectType.TYPE_BOOST, 0.2, [Enums.PokemonType.GROUND])
