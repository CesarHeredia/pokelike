# res://scripts/core/pokemon_type.gd
# Clase Resource: PokemonTypeData
#
# Representa el tipo (o doble tipo) de un Pokémon y calcula
# su multiplicador defensivo contra un tipo de ataque dado.
class_name PokemonTypeData
extends Resource

## Tipo primario (obligatorio). Usar valores de Enums.PokemonType.
@export var primary: int = 0

## Tipo secundario. -1 = monotype (sin segundo tipo).
@export var secondary: int = -1

## Constructor conveniente.
static func create(p: int, s: int = -1) -> PokemonTypeData:
	var res := PokemonTypeData.new()
	res.primary   = p
	res.secondary = s
	return res

## Devuelve true si el Pokémon tiene doble tipo.
func is_dual_type() -> bool:
	return secondary >= 0

## Calcula el multiplicador total de daño recibido desde [attack_type].
## Usa TypeChart autoload para consultar la tabla.
func get_defense_multiplier(attack_type: int) -> float:
	var mult: float = TypeChart.get_effectiveness(attack_type, primary)
	if is_dual_type():
		mult *= TypeChart.get_effectiveness(attack_type, secondary)
	return mult

## Devuelve el nombre del tipo primario.
func primary_name() -> String:
	return Enums.type_name(primary)

## Devuelve el nombre del tipo secundario, o "" si es monotype.
func secondary_name() -> String:
	if secondary < 0:
		return ""
	return Enums.type_name(secondary)

## Devuelve color del tipo primario.
func primary_color() -> Color:
	return Enums.type_color(primary)

## Representación como texto legible, ej: "Fuego / Volador"
func _to_string() -> String:
	if is_dual_type():
		return "%s / %s" % [primary_name(), secondary_name()]
	return primary_name()
