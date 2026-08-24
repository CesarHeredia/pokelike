# res://scripts/core/move.gd
# Clase Resource: Move
#
# Representa un movimiento Pokémon individual con todos sus atributos.
# Los movimientos son Resources inmutables por especie; cada Pokémon
# tiene una copia con su PP actual.
class_name Move
extends Resource

## Categoría del movimiento.
enum Category {
	PHYSICAL, ## Usa Ataque / Defensa
	SPECIAL,  ## Usa Atk. Esp. / Def. Esp.
	STATUS,   ## No hace daño directo, aplica efectos
}

## Efecto de estado que puede infligir el movimiento.
enum StatusEffect {
	NONE,
	BURN,       ## Quemadura  – -1/16 HP por turno, Atk físico /2
	FREEZE,     ## Congelado  – no puede moverse (15% de descongelarse)
	PARALYSIS,  ## Parálisis  – 25% de no moverse, Speed /2
	POISON,     ## Veneno     – -1/8 HP por turno
	BAD_POISON, ## Tóxico     – daño creciente cada turno
	SLEEP,      ## Dormido    – 1-3 turnos sin moverse
	CONFUSION,  ## Confusión  – 33% de hacerse daño a sí mismo
}

## Identificador único del movimiento.
enum MoveID {
	NONE = 0,
	HUMAREDA = 1,
	PLACAJE = 2,
	ARANAZO = 3,
	ASCUAS = 4,
}

# ── Propiedades del movimiento ─────────────────────────────────────────────────
@export var move_name:   String = ""
@export var move_type:   int    = 0   ## Enums.PokemonType
@export var category:    int    = Category.PHYSICAL
@export var power:       int    = 0   ## 0 = movimiento de estado
@export var description: String = ""

## Efecto de estado que puede aplicar (NONE = sin efecto).
@export var status_effect:      int   = StatusEffect.NONE
## Probabilidad de aplicar el efecto de estado (0.0 – 1.0).
@export var status_chance:      float = 0.0
## Cambio de stage al stat del objetivo (ej: -1 Defensa con Destructor).
@export var target_stat_change: Dictionary = {}
## Cambio de stage propio (ej: +1 Atk con Danza Espada).
@export var self_stat_change:   Dictionary = {}
## Si true, el movimiento golpea primero sin importar la velocidad.
@export var is_priority:        bool  = false
## Prioridad numérica (Ataque Rápido = +1, Placaje = 0, etc.)
@export var priority:           int   = 0

# ── Constructor conveniente ────────────────────────────────────────────────────
static func create(
	p_name:     String,
	p_type:     int,
	p_category: int,
	p_power:    int,
	p_desc:     String = ""
) -> Move:
	var m        := Move.new()
	m.move_name  = p_name
	m.move_type  = p_type
	m.category   = p_category
	m.power      = p_power
	m.description = p_desc
	return m

## Crea un movimiento predefinido por su ID numérico.
static func create_by_id(id: int) -> Move:
	match id:
		MoveID.HUMAREDA:
			var m = Move.create("Humareda", Enums.PokemonType.FIRE, Category.SPECIAL, 50, "Ataca con llamas. 30% de quemar al rival.")
			m.status_effect = StatusEffect.BURN
			m.status_chance = 0.3
			return m
		MoveID.PLACAJE:
			return Move.create("Placaje", Enums.PokemonType.NORMAL, Category.PHYSICAL, 40, "Embiste con todo el cuerpo.")
		MoveID.ARANAZO:
			return Move.create("Arañazo", Enums.PokemonType.NORMAL, Category.PHYSICAL, 40, "Araña con garras afiladas.")
		MoveID.ASCUAS:
			var m = Move.create("Ascuas", Enums.PokemonType.FIRE, Category.SPECIAL, 40, "Lanza pequeñas llamas. 10% de quemar.")
			m.status_effect = StatusEffect.BURN
			m.status_chance = 0.1
			return m
		_:
			return Move.create("Combate", Enums.PokemonType.NORMAL, Category.PHYSICAL, 50, "Ataque básico.")

## Obtiene un movimiento del pool de 108 ataques según tipo, categoría (físico/especial) y potencia (50, 90, 120)
static func get_move_by_type_category_power(p_type: int, p_category: int, p_power: int) -> Move:
	var m_name := ""
	var m_desc := ""
	match p_type:
		Enums.PokemonType.STEEL: # ACERO = 16
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Garra Metal"; m_desc = "Corta con garras de metal."
					90: m_name = "Cabeza de Hierro"; m_desc = "Cabezazo duro como el hierro."
					_: m_name = "Megatón Acero"; m_desc = "Golpe devastador de acero."
			else:
				match p_power:
					50: m_name = "Disparo Espejo"; m_desc = "Destello de luz espejo."
					90: m_name = "Foco Resplandor"; m_desc = "Rayo concentrado de luz."
					_: m_name = "Deseo Oculto"; m_desc = "Poder misterioso del acero."
		Enums.PokemonType.WATER: # AGUA = 2
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Aqua Jet"; m_desc = "Embestida rápida de agua."
					90: m_name = "Aqua Cola"; m_desc = "Coletazo cargado de agua."
					_: m_name = "Envite Acuático"; m_desc = "Carga acuática muy potente."
			else:
				match p_power:
					50: m_name = "Pulso Agua"; m_desc = "Onda de agua burbujeante."
					90: m_name = "Surf"; m_desc = "Ola gigante de agua."
					_: m_name = "Hidrobomba"; m_desc = "Chorro de agua a gran presión."
		Enums.PokemonType.BUG: # BICHO = 11
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Picadura"; m_desc = "Picotazo de insecto."
					90: m_name = "Escaramuza"; m_desc = "Ataque sorpresa al entrar."
					_: m_name = "Megacuerno"; m_desc = "Embestida con un gran cuerno."
			else:
				match p_power:
					50: m_name = "Rayo Señal"; m_desc = "Rayo de luz extraño."
					90: m_name = "Zumbido"; m_desc = "Vibración de alta frecuencia."
					_: m_name = "Polvo Explosivo"; m_desc = "Polvo que detona al contacto."
		Enums.PokemonType.DRAGON: # DRAGÓN = 14
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Garra Dragón"; m_desc = "Araña con garras de dragón."
					90: m_name = "Martillo Dragón"; m_desc = "Golpea con el cuerpo de dragón."
					_: m_name = "Enfado"; m_desc = "Furia descontrolada de dragón."
			else:
				match p_power:
					50: m_name = "Dragoaliento"; m_desc = "Aliento de dragón abrasador."
					90: m_name = "Pulso Dragón"; m_desc = "Onda de choque mística."
					_: m_name = "Cometa Draco"; m_desc = "Lluvia de meteoros de dragón."
		Enums.PokemonType.ELECTRIC: # ELÉCTRICO = 3
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Chispa"; m_desc = "Descarga eléctrica leve."
					90: m_name = "Puño Trueno"; m_desc = "Puñetazo electrificado."
					_: m_name = "Voltio Cruel"; m_desc = "Carga eléctrica temeraria."
			else:
				match p_power:
					50: m_name = "Rayo Carga"; m_desc = "Rayo que puede subir el Atq. Esp."
					90: m_name = "Rayo"; m_desc = "Potente descarga eléctrica."
					_: m_name = "Trueno"; m_desc = "Tormenta eléctrica fulminante."
		Enums.PokemonType.FAIRY: # HADA = 17
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Choque Anímico"; m_desc = "Impacto de fuerza espiritual."
					90: m_name = "Carantoña"; m_desc = "Juego brusco y travieso."
					_: m_name = "Feerichoque"; m_desc = "Golpe mágico devastador."
			else:
				match p_power:
					50: m_name = "Beso Drenaje"; m_desc = "Restaura HP al dañar."
					90: m_name = "Fuerza Lunar"; m_desc = "Poder de la luz lunar."
					_: m_name = "Luz Aniquiladora"; m_desc = "Rayo de energía pura de luz."
		Enums.PokemonType.FIRE: # FUEGO = 1
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Nitrocarga"; m_desc = "Carga ígnea que sube velocidad."
					90: m_name = "Puño Fuego"; m_desc = "Puñetazo ardiente."
					_: m_name = "Envite Ígneo"; m_desc = "Carga de fuego destructiva."
			else:
				match p_power:
					50: m_name = "Calcinación"; m_desc = "Quema con cenizas calientes."
					90: m_name = "Lanzallamas"; m_desc = "Chorro de fuego continuo."
					_: m_name = "Llamarada"; m_desc = "Gran estrella de fuego."
		Enums.PokemonType.GHOST: # FANTASMA = 13
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Puño Sombra"; m_desc = "Puño ineludible desde las sombras."
					90: m_name = "Garra Umbría"; m_desc = "Araña con garras fantasmales."
					_: m_name = "Poltergeist"; m_desc = "Controla objetos para atacar."
			else:
				match p_power:
					50: m_name = "Infortunio"; m_desc = "Daño duplicado si hay problemas de estado."
					90: m_name = "Bola Sombra"; m_desc = "Proyectil de energía oscura."
					_: m_name = "Haz Espectral"; m_desc = "Rayo fantasmal destructor."
		Enums.PokemonType.GRASS: # PLANTA = 4
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Hoja Afilada"; m_desc = "Lanza hojas cortantes."
					90: m_name = "Hoja Aguda"; m_desc = "Corta con hojas de espadas."
					_: m_name = "Mazazo"; m_desc = "Golpe violento de tronco."
			else:
				match p_power:
					50: m_name = "Mágica Hoja"; m_desc = "Hojas mágicas ineludibles."
					90: m_name = "Energibola"; m_desc = "Bola de energía de la naturaleza."
					_: m_name = "Rayo Solar"; m_desc = "Rayo cargado con energía solar."
		Enums.PokemonType.ICE: # HIELO = 5
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Colmillo Hielo"; m_desc = "Mordisco helado."
					90: m_name = "Chuzo"; m_desc = "Lanza carámbanos de hielo."
					_: m_name = "Pirueta Helada"; m_desc = "Patada giratoria sobre hielo."
			else:
				match p_power:
					50: m_name = "Viento Hielo"; m_desc = "Ráfaga de aire helado."
					90: m_name = "Rayo Hielo"; m_desc = "Rayo congelante."
					_: m_name = "Ventisca"; m_desc = "Tormenta de nieve violenta."
		Enums.PokemonType.FIGHTING: # LUCHA = 6
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Ultra Puño"; m_desc = "Puño rápido."
					90: m_name = "Demolición"; m_desc = "Golpe que rompe barreras."
					_: m_name = "A Bocajarro"; m_desc = "Ataque a quemarropa."
			else:
				match p_power:
					50: m_name = "Onda Vacío"; m_desc = "Onda de choque rápida."
					90: m_name = "Esfera Aural"; m_desc = "Esfera de aura ineludible."
					_: m_name = "Onda Certera"; m_desc = "Proyectil concentrado de lucha."
		Enums.PokemonType.NORMAL: # NORMAL = 0
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Corte"; m_desc = "Corta con garras o espadas."
					90: m_name = "Golpe Cuerpo"; m_desc = "Cae con todo el peso corporal."
					_: m_name = "Doble Filo"; m_desc = "Carga arriesgada."
			else:
				match p_power:
					50: m_name = "Rapidez"; m_desc = "Lanza estrellas ineludibles."
					90: m_name = "Vozarrón"; m_desc = "Grito potente."
					_: m_name = "Alboroto"; m_desc = "Ruido molesto y continuo."
		Enums.PokemonType.PSYCHIC: # PSÍQUICO = 10
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Psico-corte"; m_desc = "Corte de energía psíquica."
					90: m_name = "Psicocarga Física"; m_desc = "Onda mental que golpea el físico."
					_: m_name = "Choque Fotónico"; m_desc = "Impacto de luz psíquica."
			else:
				match p_power:
					50: m_name = "Confusión"; m_desc = "Onda mental leve."
					90: m_name = "Psíquico"; m_desc = "Fuerte poder telequinético."
					_: m_name = "Premonición"; m_desc = "Ataque retrasado del futuro."
		Enums.PokemonType.ROCK: # ROCA = 12
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Tumba Rocas"; m_desc = "Tira piedras para frenar al rival."
					90: m_name = "Avalancha"; m_desc = "Derrumbe de rocas potentes."
					_: m_name = "Testarazo"; m_desc = "Cabezazo de roca temerario."
			else:
				match p_power:
					50: m_name = "Poder Pasado"; m_desc = "Lanza piedras prehistóricas."
					90: m_name = "Joya de Luz"; m_desc = "Destello de gemas preciosas."
					_: m_name = "Rayo Meteórico"; m_desc = "Carga de energía del espacio."
		Enums.PokemonType.DARK: # SINIESTRO = 15
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Ladrón"; m_desc = "Ataque rápido y roba objetos."
					90: m_name = "Triturar"; m_desc = "Mordisco triturador oscuro."
					_: m_name = "Golpe Oscuro"; m_desc = "Golpe crítico inevitable."
			else:
				match p_power:
					50: m_name = "Alarido"; m_desc = "Grito siniestro."
					90: m_name = "Pulso Umbrío"; m_desc = "Onda de energía oscura."
					_: m_name = "Pulso Umbrío"; m_desc = "Onda de energía oscura máxima."
		Enums.PokemonType.GROUND: # TIERRA = 8
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Bucle Arena"; m_desc = "Atrapa al rival en arena."
					90: m_name = "Taladradora"; m_desc = "Gira como taladro en tierra."
					_: m_name = "Fuerza Arrolladora"; m_desc = "Embiste con fuerza terrestre."
			else:
				match p_power:
					50: m_name = "Disparo Lodo"; m_desc = "Lodo para bajar velocidad."
					90: m_name = "Tierra Viva"; m_desc = "Terremoto de energía viva."
					_: m_name = "Tierra Viva"; m_desc = "Terremoto de energía viva máxima."
		Enums.PokemonType.POISON: # VENENO = 7
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Colmillo Veneno"; m_desc = "Mordisco venenoso."
					90: m_name = "Puya Nociva"; m_desc = "Pinchazo tóxico."
					_: m_name = "Lanza Mugre"; m_desc = "Lanza basura tóxica."
			else:
				match p_power:
					50: m_name = "Carga Tóxica"; m_desc = "Daño duplicado si está envenenado."
					90: m_name = "Bomba Lodo"; m_desc = "Lanza bola de lodo venenoso."
					_: m_name = "Onda Tóxica"; m_desc = "Onda venenosa expansiva."
		_: # Default to FLYING = 9
			if p_category == Category.PHYSICAL:
				match p_power:
					50: m_name = "Ataque Ala"; m_desc = "Golpea con las alas."
					90: m_name = "Vuelo"; m_desc = "Ataque aéreo en dos turnos."
					_: m_name = "Pájaro Osado"; m_desc = "Carga de ave suicida."
			else:
				match p_power:
					50: m_name = "Aire Afilado"; m_desc = "Ráfaga de viento cortante."
					90: m_name = "Tajo Aéreo"; m_desc = "Corte de viento con chance de retroceso."
					_: m_name = "Vendaval"; m_desc = "Tormenta de viento devastadora."

	return Move.create(m_name, p_type, p_category, p_power, m_desc)

# ── API ────────────────────────────────────────────────────────────────────────

## Devuelve true si el movimiento hace daño directo.
func deals_damage() -> bool:
	return category != Category.STATUS and power > 0

## ¿El movimiento usa la stat de Ataque físico?
func uses_physical_attack() -> bool:
	return category == Category.PHYSICAL

## ¿El movimiento usa Ataque especial?
func uses_special_attack() -> bool:
	return category == Category.SPECIAL

## Intenta aplicar el efecto de estado (retorna el StatusEffect si se activa).
func roll_status_effect() -> int:
	if status_effect == StatusEffect.NONE or status_chance <= 0.0:
		return StatusEffect.NONE
	if randf() <= status_chance:
		return status_effect
	return StatusEffect.NONE

## Nombre de categoría legible.
func category_name() -> String:
	match category:
		Category.PHYSICAL: return "Físico"
		Category.SPECIAL:  return "Especial"
		Category.STATUS:   return "Estado"
	return ""

## Crea una copia del movimiento (para asignarlo a un Pokémon concreto).
func duplicate_move() -> Move:
	var copy       := Move.new()
	copy.move_name  = move_name
	copy.move_type  = move_type
	copy.category   = category
	copy.power      = power
	copy.description = description
	copy.status_effect  = status_effect
	copy.status_chance  = status_chance
	copy.target_stat_change = target_stat_change.duplicate()
	copy.self_stat_change   = self_stat_change.duplicate()
	copy.is_priority = is_priority
	copy.priority    = priority
	return copy

## Resuelve el tipo principal y la categoría de ataque (físico/especial) de una especie Pokémon.
static func get_species_type_and_category(species: String) -> Dictionary:
	var name_upper := species.to_upper().strip_edges()
	# Elimina sufijos como " SALVAJE"
	if name_upper.ends_with(" SALVAJE"):
		name_upper = name_upper.replace(" SALVAJE", "").strip_edges()
	# Elimina prefijos/sufijos con nivel como " LV.4"
	if " LV." in name_upper:
		name_upper = name_upper.split(" LV.")[0].strip_edges()
	# Elimina nombres de entrenadores/líderes
	if "GARY (" in name_upper:
		# Extrae el pokémon de la cadena, ej: "Rival Gary (Blastoise Lv.45)" -> "Blastoise"
		var parts := name_upper.split("(")
		if parts.size() > 1:
			name_upper = parts[1].split(" ")[0].strip_edges()
	if "BROCK (" in name_upper:
		var parts := name_upper.split("(")
		if parts.size() > 1:
			name_upper = parts[1].split(" ")[0].strip_edges()
	if "ONIX LV." in name_upper:
		name_upper = "ONIX"
	if "CATERPIE" in name_upper:
		name_upper = "CATERPIE"
	if "PIDGEY" in name_upper:
		name_upper = "PIDGEY"
	if "RATTATA" in name_upper:
		name_upper = "RATTATA"
	if "PIKACHU" in name_upper:
		name_upper = "PIKACHU"
	if "NIDORAN" in name_upper:
		name_upper = "NIDORAN"
	if "ONIX" in name_upper:
		name_upper = "ONIX"
	if "BULBASAUR" in name_upper:
		name_upper = "BULBASAUR"
	if "IVYSAUR" in name_upper:
		name_upper = "IVYSAUR"
	if "CHARMANDER" in name_upper:
		name_upper = "CHARMANDER"
	if "SQUIRTLE" in name_upper:
		name_upper = "SQUIRTLE"
	if "BLASTOISE" in name_upper:
		name_upper = "BLASTOISE"

	match name_upper:
		"BULBASAUR", "IVYSAUR":
			return {"type": Enums.PokemonType.GRASS, "category": Category.SPECIAL}
		"CHARMANDER":
			return {"type": Enums.PokemonType.FIRE, "category": Category.SPECIAL}
		"SQUIRTLE", "BLASTOISE":
			return {"type": Enums.PokemonType.WATER, "category": Category.SPECIAL}
		"PIKACHU":
			return {"type": Enums.PokemonType.ELECTRIC, "category": Category.SPECIAL}
		"CATERPIE":
			return {"type": Enums.PokemonType.BUG, "category": Category.PHYSICAL}
		"PIDGEY":
			return {"type": Enums.PokemonType.FLYING, "category": Category.PHYSICAL}
		"RATTATA":
			return {"type": Enums.PokemonType.NORMAL, "category": Category.PHYSICAL}
		"NIDORAN♂", "NIDORAN♀", "NIDORAN":
			return {"type": Enums.PokemonType.POISON, "category": Category.PHYSICAL}
		"ONIX":
			return {"type": Enums.PokemonType.ROCK, "category": Category.PHYSICAL}
		_:
			return {"type": Enums.PokemonType.NORMAL, "category": Category.PHYSICAL}
