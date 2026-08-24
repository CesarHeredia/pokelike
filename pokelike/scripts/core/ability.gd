# res://scripts/core/ability.gd
# Clase Resource: Ability
#
# Representa una habilidad pasiva Pokémon con efectos reales.
# El sistema usa un patrón de "trigger + contexto":
#   - El BattleManager llama a ability.on_<evento>(context) en el momento correcto.
#   - El contexto es un Dictionary con los datos relevantes del turno.
#   - La habilidad modifica el contexto o aplica efectos directamente.
#
# Habilidades implementadas (iniciales Gen 1 + comunes):
#   OVERGROW    – Espesura   (Bulbasaur)
#   BLAZE       – Ígnea      (Charmander)
#   TORRENT     – Torrente   (Squirtle)
#   STATIC      – Estática
#   INTIMIDATE  – Intimidación
#   SHED_SKIN   – Mudar
#   SWIFT_SWIM  – Nado Rápido
#   CHLOROPHYLL – Clorofila
#   FLASH_FIRE  – Absorbe Fuego
#   LEVITATE    – Levitación
#   STURDY      – Robustez
#   THICK_FAT   – Sebo
class_name Ability
extends Resource

## Identificador único de la habilidad.
enum AbilityID {
	NONE = 0,
	MAR_DE_LLAMAS = 1,
	ESPESURA = 2,
	TORRENTE = 3,
	STATIC = 4,
	INTIMIDATE,
	SHED_SKIN,
	SWIFT_SWIM,
	CHLOROPHYLL,
	FLASH_FIRE,
	LEVITATE,
	STURDY,
	THICK_FAT,
}

@export var ability_id:   int    = AbilityID.NONE
@export var ability_name: String = "Sin habilidad"
@export var description:  String = ""

## Estado interno de la habilidad (ej: Flash Fire activado).
var _flash_fire_active: bool = false

# ── Constructor ────────────────────────────────────────────────────────────────
static func create(id: int) -> Ability:
	var a := Ability.new()
	a.ability_id = id
	match id:
		AbilityID.MAR_DE_LLAMAS:
			a.ability_name = "Mar de Llamas"
			a.description  = "Potencia los movimientos de tipo Fuego ×1.5 cuando el HP es ≤ 1/3."
		AbilityID.ESPESURA:
			a.ability_name = "Espesura"
			a.description  = "Potencia los movimientos de tipo Planta ×1.5 cuando el HP es ≤ 1/3."
		AbilityID.TORRENTE:
			a.ability_name = "Torrente"
			a.description  = "Potencia los movimientos de tipo Agua ×1.5 cuando el HP es ≤ 1/3."
		AbilityID.STATIC:
			a.ability_name = "Estática"
			a.description  = "30% de probabilidad de paralizar al rival cuando le hace contacto."
		AbilityID.INTIMIDATE:
			a.ability_name = "Intimidación"
			a.description  = "Al entrar en batalla, baja el Ataque del rival 1 stage."
		AbilityID.SHED_SKIN:
			a.ability_name = "Mudar"
			a.description  = "30% de curar una alteración de estado al final de cada turno."
		AbilityID.SWIFT_SWIM:
			a.ability_name = "Nado Rápido"
			a.description  = "Dobla la Velocidad bajo la lluvia."
		AbilityID.CHLOROPHYLL:
			a.ability_name = "Clorofila"
			a.description  = "Dobla la Velocidad bajo el sol."
		AbilityID.FLASH_FIRE:
			a.ability_name = "Absorbe Fuego"
			a.description  = "Inmune a ataques Fuego. Al recibirlos, potencia sus propios ataques Fuego ×1.5."
		AbilityID.LEVITATE:
			a.ability_name = "Levitación"
			a.description  = "Inmune a movimientos de tipo Tierra."
		AbilityID.STURDY:
			a.ability_name = "Robustez"
			a.description  = "Sobrevive con 1 HP cualquier golpe que lo dejaría KO con HP completo."
		AbilityID.THICK_FAT:
			a.ability_name = "Sebo"
			a.description  = "Reduce el daño de ataques de Fuego e Hielo a la mitad."
		_:
			a.ability_name = "Sin habilidad"
			a.description  = ""
	return a

# ── Triggers de combate ────────────────────────────────────────────────────────

## Llamado al inicio de la batalla.
## context = { "owner": Pokemon, "opponent": Pokemon, "battle": BattleManager }
func on_battle_start(context: Dictionary) -> void:
	match ability_id:
		AbilityID.INTIMIDATE:
			var opponent = context.get("opponent")
			if opponent and opponent.stats:
				opponent.stats.stage_attack = clampi(opponent.stats.stage_attack - 1, -6, 6)
				_emit_message(context, "%s usó Intimidación. ¡Bajó el Ataque de %s!" % [
					context.get("owner", {}).get("species_name", "?"),
					opponent.species_name
				])

## Llamado al calcular el multiplicador del daño de un ataque propio.
## context = { "owner": Pokemon, "move": Move, "multiplier": float }
## ¡IMPORTANTE! Modifica context["multiplier"] directamente.
func on_damage_multiplier(context: Dictionary) -> void:
	var owner  = context.get("owner")
	var move   = context.get("move")
	if owner == null or move == null:
		return

	var ratio: float = owner.stats.hp_ratio() if owner.stats else 1.0

	match ability_id:
		AbilityID.ESPESURA:
			if ratio <= 0.333 and move.move_type == Enums.PokemonType.GRASS:
				context["multiplier"] = context.get("multiplier", 1.0) * 1.5
		AbilityID.MAR_DE_LLAMAS:
			if ratio <= 0.333 and move.move_type == Enums.PokemonType.FIRE:
				context["multiplier"] = context.get("multiplier", 1.0) * 1.5
		AbilityID.TORRENTE:
			if ratio <= 0.333 and move.move_type == Enums.PokemonType.WATER:
				context["multiplier"] = context.get("multiplier", 1.0) * 1.5
		AbilityID.THICK_FAT:
			# Sebo reduce el daño recibido de Fuego e Hielo
			var incoming_type = context.get("incoming_move_type", -1)
			if incoming_type == Enums.PokemonType.FIRE or incoming_type == Enums.PokemonType.ICE:
				context["multiplier"] = context.get("multiplier", 1.0) * 0.5
		AbilityID.FLASH_FIRE:
			var incoming_type = context.get("incoming_move_type", -1)
			if incoming_type == Enums.PokemonType.FIRE:
				context["multiplier"] = 0.0  # Absorbe el ataque
				_flash_fire_active = true
			elif _flash_fire_active and move.move_type == Enums.PokemonType.FIRE:
				context["multiplier"] = context.get("multiplier", 1.0) * 1.5
		AbilityID.LEVITATE:
			var incoming_type = context.get("incoming_move_type", -1)
			if incoming_type == Enums.PokemonType.GROUND:
				context["multiplier"] = 0.0  # Inmune a Tierra
		AbilityID.SWIFT_SWIM:
			pass  # Manejado en speed_multiplier
		AbilityID.CHLOROPHYLL:
			pass  # Manejado en speed_multiplier

## Llamado al calcular la velocidad efectiva.
## context = { "owner": Pokemon, "weather": String, "speed": int }
func on_speed_calc(context: Dictionary) -> void:
	var weather: String = context.get("weather", "")
	match ability_id:
		AbilityID.SWIFT_SWIM:
			if weather == "rain":
				context["speed"] = context.get("speed", 1) * 2
		AbilityID.CHLOROPHYLL:
			if weather == "sun":
				context["speed"] = context.get("speed", 1) * 2

## Llamado cuando el portador golpea al rival con contacto físico.
## context = { "owner": Pokemon, "target": Pokemon }
func on_contact_hit(context: Dictionary) -> void:
	match ability_id:
		AbilityID.STATIC:
			if randf() <= 0.30:
				var target = context.get("target")
				if target and target.status == Pokemon.Status.NONE:
					target.status = Pokemon.Status.PARALYSIS
					_emit_message(context, "¡%s quedó paralizado por Estática!" % target.species_name)

## Llamado al final de cada turno sobre el portador.
## context = { "owner": Pokemon }
func on_turn_end(context: Dictionary) -> void:
	match ability_id:
		AbilityID.SHED_SKIN:
			var owner = context.get("owner")
			if owner and owner.status != Pokemon.Status.NONE:
				if randf() <= 0.30:
					owner.status = Pokemon.Status.NONE
					_emit_message(context, "¡%s se curó con Mudar!" % owner.species_name)

## Llamado cuando el portador va a recibir daño letal (0 HP).
## context = { "owner": Pokemon, "damage": int, "blocked": bool }
## Si pone context["blocked"] = true, el daño queda en 1 HP.
func on_would_faint(context: Dictionary) -> void:
	match ability_id:
		AbilityID.STURDY:
			var owner = context.get("owner")
			if owner and owner.stats and owner.stats.hp_ratio() >= 1.0:
				context["blocked"] = true
				_emit_message(context, "¡%s aguantó gracias a Robustez!" % owner.species_name)

# ── Helpers ────────────────────────────────────────────────────────────────────
func _emit_message(context: Dictionary, msg: String) -> void:
	var battle = context.get("battle")
	if battle and battle.has_method("add_message"):
		battle.add_message(msg)
