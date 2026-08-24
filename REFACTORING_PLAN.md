# Plan de Refactorización — PokéLike

## Estado Actual: Resumen de Problemas

1. **`mobile_battle_ui.gd`** tiene DUPLICADOS completos de POKEDEX_BASE (60 entradas), TYPE_CHART (incompleto), y fórmula de daño — ignora TODAS las clases core
2. **`player_party`** es `Array[Dictionary]`, NO `Array[Pokemon]` — la clase Pokemon casi no se usa
3. **Movimientos** son 108 entradas hardcoded en match/case sin IDs (solo 4 con ID)
4. **Habilidades** son 12 con lógica dispersa en 6 métodos
5. **`_find_pokemon_dictionary`** está hardcodeada al pool de regalo de Brock
6. **`player_attack_power`** se trackea pero NUNCA se usa en batalla (power hardcoded a 40)
7. **Los map configs** embeben datos de entrenadores, pools salvajes y pools de regalo inline

---

## FASE 1: Capa de Registros de Datos (Fundación)

### 1.1 MoveRegistry — `res://scripts/core/registry/move_registry.gd`

**Clase:** `MoveRegistry extends Node` (autoload)

**Estructura de datos:** Un solo Dictionary plano indexado por `int` ID. Cada entrada es un Dictionary con las propiedades del movimiento. `Move.create_by_id()` consulta el registro en lugar de tener un match/case gigante.

```gdscript
# res://scripts/core/registry/move_registry.gd
# Autoload: MoveRegistry
class_name MoveRegistryClass
extends Node

## Cada movimiento es un Dictionary con las mismas propiedades de Move:
##   name, type, category, power, desc, status_effect, status_chance,
##   target_stat_change, self_stat_change, is_priority, priority
var _moves: Dictionary = {}

func _ready() -> void:
    _register_all_moves()

## Devuelve una copiafresh de un Move Resource desde el registro.
func get_move(id: int) -> Move:
    var data: Dictionary = _moves.get(id, {})
    if data.is_empty():
        return Move.create("Combate", Enums.PokemonType.NORMAL, Move.Category.PHYSICAL, 50, "Ataque básico.")
    var m := Move.create(data.name, data.type, data.category, data.power, data.desc)
    m.status_effect = data.get("status_effect", Move.StatusEffect.NONE)
    m.status_chance = data.get("status_chance", 0.0)
    m.target_stat_change = data.get("target_stat_change", {})
    m.self_stat_change = data.get("self_stat_change", {})
    m.is_priority = data.get("is_priority", false)
    m.priority = data.get("priority", 0)
    return m

## Devuelve solo los datos crudos (sin instanciar Move).
func get_data(id: int) -> Dictionary:
    return _moves.get(id, {})

## Devuelve un movimiento generado por tipo/categoría/poder
## (reemplaza get_move_by_type_category_power).
func get_stab_move(type: int, category: int, power: int) -> Move:
    # Busca por type+category+power en el registro, o genera uno genérico
    for id in _moves:
        var d: Dictionary = _moves[id]
        if d.type == type and d.category == category and d.power == power:
            return get_move(id)
    # Fallback: genera uno con nombre genérico
    return _generate_generic(type, category, power)

func _register_all_moves() -> void:
    # ── IDs 1-4: Movimientos existentes ──
    _moves[1] = {"name":"Humareda","type":Enums.PokemonType.FIRE,"category":Move.Category.SPECIAL,"power":50,
        "desc":"Ataca con llamas. 30% de quemar al rival.",
        "status_effect":Move.StatusEffect.BURN,"status_chance":0.3}
    _moves[2] = {"name":"Placaje","type":Enums.PokemonType.NORMAL,"category":Move.Category.PHYSICAL,"power":40,
        "desc":"Embiste con todo el cuerpo."}
    _moves[3] = {"name":"Arañazo","type":Enums.PokemonType.NORMAL,"category":Move.Category.PHYSICAL,"power":40,
        "desc":"Araña con garras afiladas."}
    _moves[4] = {"name":"Ascuas","type":Enums.PokemonType.FIRE,"category":Move.Category.SPECIAL,"power":40,
        "desc":"Lanza pequeñas llamas. 10% de quemar.",
        "status_effect":Move.StatusEffect.BURN,"status_chance":0.1}

    # ── IDs 10-99: Movimientos STAB por tipo (los 108 del match/case) ──
    # FIRE Physical 50/90/120
    _moves[10] = {"name":"Nitrocarga","type":1,"category":0,"power":50,"desc":"Carga ígnea que sube velocidad."}
    _moves[11] = {"name":"Puño Fuego","type":1,"category":0,"power":90,"desc":"Puñetazo ardiente."}
    _moves[12] = {"name":"Envite Ígneo","type":1,"category":0,"power":120,"desc":"Carga de fuego destructiva."}
    _moves[13] = {"name":"Calcinación","type":1,"category":1,"power":50,"desc":"Quema con cenizas calientes."}
    _moves[14] = {"name":"Lanzallamas","type":1,"category":1,"power":90,"desc":"Chorro de fuego continuo."}
    _moves[15] = {"name":"Llamarada","type":1,"category":1,"power":120,"desc":"Gran estrella de fuego."}

    # WATER Physical 50/90/120, Special 50/90/120
    _moves[20] = {"name":"Aqua Jet","type":2,"category":0,"power":50,"desc":"Embestida rápida de agua.",
        "is_priority":true,"priority":1}
    _moves[21] = {"name":"Aqua Cola","type":2,"category":0,"power":90,"desc":"Coletazo cargado de agua."}
    _moves[22] = {"name":"Envite Acuático","type":2,"category":0,"power":120,"desc":"Carga acuática muy potente."}
    _moves[23] = {"name":"Pulso Agua","type":2,"category":1,"power":50,"desc":"Onda de agua burbujeante."}
    _moves[24] = {"name":"Surf","type":2,"category":1,"power":90,"desc":"Ola gigante de agua."}
    _moves[25] = {"name":"Hidrobomba","type":2,"category":1,"power":120,"desc":"Chorro de agua a gran presión."}

    # ELECTRIC
    _moves[30] = {"name":"Chispa","type":3,"category":0,"power":50,"desc":"Descarga eléctrica leve."}
    _moves[31] = {"name":"Puño Trueno","type":3,"category":0,"power":90,"desc":"Puñetazo electrificado."}
    _moves[32] = {"name":"Voltio Cruel","type":3,"category":0,"power":120,"desc":"Carga eléctrica temeraria."}
    _moves[33] = {"name":"Rayo Carga","type":3,"category":1,"power":50,"desc":"Rayo que puede subir el Atq. Esp."}
    _moves[34] = {"name":"Rayo","type":3,"category":1,"power":90,"desc":"Potente descarga eléctrica."}
    _moves[35] = {"name":"Trueno","type":3,"category":1,"power":120,"desc":"Tormenta eléctrica fulminante.",
        "status_effect":Move.StatusEffect.PARALYSIS,"status_chance":0.1}

    # GRASS
    _moves[40] = {"name":"Hoja Afilada","type":4,"category":0,"power":50,"desc":"Lanza hojas cortantes."}
    _moves[41] = {"name":"Hoja Aguda","type":4,"category":0,"power":90,"desc":"Corta con hojas de espadas."}
    _moves[42] = {"name":"Mazazo","type":4,"category":0,"power":120,"desc":"Golpe violento de tronco."}
    _moves[43] = {"name":"Mágica Hoja","type":4,"category":1,"power":50,"desc":"Hojas mágicas ineludibles."}
    _moves[44] = {"name":"Energibola","type":4,"category":1,"power":90,"desc":"Bola de energía de la naturaleza."}
    _moves[45] = {"name":"Rayo Solar","type":4,"category":1,"power":120,"desc":"Rayo cargado con energía solar."}

    # ICE
    _moves[50] = {"name":"Colmillo Hielo","type":5,"category":0,"power":50,"desc":"Mordisco helado."}
    _moves[51] = {"name":"Chuzo","type":5,"category":0,"power":90,"desc":"Lanza carámbanos de hielo."}
    _moves[52] = {"name":"Pirueta Helada","type":5,"category":0,"power":120,"desc":"Patada giratoria sobre hielo."}
    _moves[53] = {"name":"Viento Hielo","type":5,"category":1,"power":50,"desc":"Ráfaga de aire helado."}
    _moves[54] = {"name":"Rayo Hielo","type":5,"category":1,"power":90,"desc":"Rayo congelante.",
        "status_effect":Move.StatusEffect.FREEZE,"status_chance":0.1}
    _moves[55] = {"name":"Ventisca","type":5,"category":1,"power":120,"desc":"Tormenta de nieve violenta."}

    # NORMAL
    _moves[60] = {"name":"Corte","type":0,"category":0,"power":50,"desc":"Corta con garras o espadas."}
    _moves[61] = {"name":"Golpe Cuerpo","type":0,"category":0,"power":90,"desc":"Cae con todo el peso corporal."}
    _moves[62] = {"name":"Doble Filo","type":0,"category":0,"power":120,"desc":"Carga arriesgada."}
    _moves[63] = {"name":"Rapidez","type":0,"category":1,"power":50,"desc":"Lanza estrellas ineludibles."}
    _moves[64] = {"name":"Vozarrón","type":0,"category":1,"power":90,"desc":"Grito potente."}
    _moves[65] = {"name":"Alboroto","type":0,"category":1,"power":120,"desc":"Ruido molesto y continuo."}

    # FIGHTING
    _moves[70] = {"name":"Ultra Puño","type":6,"category":0,"power":50,"desc":"Puño rápido."}
    _moves[71] = {"name":"Demolición","type":6,"category":0,"power":90,"desc":"Golpe que rompe barreras.",
        "target_stat_change":{"defense":-1}}
    _moves[72] = {"name":"A Bocajarro","type":6,"category":0,"power":120,"desc":"Ataque a quemarropa."}
    _moves[73] = {"name":"Onda Vacío","type":6,"category":1,"power":50,"desc":"Onda de choque rápida."}
    _moves[74] = {"name":"Esfera Aural","type":6,"category":1,"power":90,"desc":"Esfera de aura ineludible."}
    _moves[75] = {"name":"Onda Certera","type":6,"category":1,"power":120,"desc":"Proyectil concentrado de lucha."}

    # POISON
    _moves[80] = {"name":"Colmillo Veneno","type":7,"category":0,"power":50,"desc":"Mordisco venenoso.",
        "status_effect":Move.StatusEffect.POISON,"status_chance":0.3}
    _moves[81] = {"name":"Puya Nociva","type":7,"category":0,"power":90,"desc":"Pinchazo tóxico."}
    _moves[82] = {"name":"Lanza Mugre","type":7,"category":0,"power":120,"desc":"Lanza basura tóxica."}
    _moves[83] = {"name":"Carga Tóxica","type":7,"category":1,"power":50,"desc":"Daño duplicado si está envenenado."}
    _moves[84] = {"name":"Bomba Lodo","type":7,"category":1,"power":90,"desc":"Lanza bola de lodo venenoso."}
    _moves[85] = {"name":"Onda Tóxica","type":7,"category":1,"power":120,"desc":"Onda venenosa expansiva."}

    # GROUND
    _moves[90] = {"name":"Bucle Arena","type":8,"category":0,"power":50,"desc":"Atrapa al rival en arena."}
    _moves[91] = {"name":"Taladradora","type":8,"category":0,"power":90,"desc":"Gira como taladro en tierra."}
    _moves[92] = {"name":"Fuerza Arrolladora","type":8,"category":0,"power":120,"desc":"Embiste con fuerza terrestre."}
    _moves[93] = {"name":"Disparo Lodo","type":8,"category":1,"power":50,"desc":"Lodo para bajar velocidad.",
        "target_stat_change":{"speed":-1}}
    _moves[94] = {"name":"Tierra Viva","type":8,"category":1,"power":90,"desc":"Terremoto de energía viva."}
    _moves[95] = {"name":"Terremoto","type":8,"category":1,"power":120,"desc":"Terremoto devastador."}

    # FLYING
    _moves[100] = {"name":"Ataque Ala","type":9,"category":0,"power":50,"desc":"Golpea con las alas."}
    _moves[101] = {"name":"Vuelo","type":9,"category":0,"power":90,"desc":"Ataque aéreo en dos turnos."}
    _moves[102] = {"name":"Pájaro Osado","type":9,"category":0,"power":120,"desc":"Carga de ave suicida."}
    _moves[103] = {"name":"Aire Afilado","type":9,"category":1,"power":50,"desc":"Ráfaga de viento cortante.",
        "status_effect":Move.StatusEffect.BURN,"status_chance":0.1}
    _moves[104] = {"name":"Tajo Aéreo","type":9,"category":1,"power":90,"desc":"Corte de viento con chance de retroceso."}
    _moves[105] = {"name":"Vendaval","type":9,"category":1,"power":120,"desc":"Tormenta de viento devastadora."}

    # PSYCHIC
    _moves[110] = {"name":"Psico-corte","type":10,"category":0,"power":50,"desc":"Corte de energía psíquica."}
    _moves[111] = {"name":"Psicocarga Física","type":10,"category":0,"power":90,"desc":"Onda mental que golpea el físico."}
    _moves[112] = {"name":"Choque Fotónico","type":10,"category":0,"power":120,"desc":"Impacto de luz psíquica."}
    _moves[113] = {"name":"Confusión","type":10,"category":1,"power":50,"desc":"Onda mental leve.",
        "status_effect":Move.StatusEffect.CONFUSION,"status_chance":0.1}
    _moves[114] = {"name":"Psíquico","type":10,"category":1,"power":90,"desc":"Fuerte poder telequinético.",
        "target_stat_change":{"sp_defense":-1}}
    _moves[115] = {"name":"Premonición","type":10,"category":1,"power":120,"desc":"Ataque retrasado del futuro."}

    # BUG
    _moves[120] = {"name":"Picadura","type":11,"category":0,"power":50,"desc":"Picotazo de insecto."}
    _moves[121] = {"name":"Escaramuza","type":11,"category":0,"power":90,"desc":"Ataque sorpresa al entrar."}
    _moves[122] = {"name":"Megacuerno","type":11,"category":0,"power":120,"desc":"Embestida con un gran cuerno."}
    _moves[123] = {"name":"Rayo Señal","type":11,"category":1,"power":50,"desc":"Rayo de luz extraño."}
    _moves[124] = {"name":"Zumbido","type":11,"category":1,"power":90,"desc":"Vibración de alta frecuencia."}
    _moves[125] = {"name":"Polvo Explosivo","type":11,"category":1,"power":120,"desc":"Polvo que detona al contacto."}

    # ROCK
    _moves[130] = {"name":"Tumba Rocas","type":12,"category":0,"power":50,"desc":"Tira piedras para frenar al rival.",
        "target_stat_change":{"speed":-1}}
    _moves[131] = {"name":"Avalancha","type":12,"category":0,"power":90,"desc":"Derrumbe de rocas potentes."}
    _moves[132] = {"name":"Testarazo","type":12,"category":0,"power":120,"desc":"Cabezazo de roca temerario."}
    _moves[133] = {"name":"Poder Pasado","type":12,"category":1,"power":50,"desc":"Lanza piedras prehistóricas."}
    _moves[134] = {"name":"Joya de Luz","type":12,"category":1,"power":90,"desc":"Destello de gemas preciosas."}
    _moves[135] = {"name":"Rayo Meteórico","type":12,"category":1,"power":120,"desc":"Carga de energía del espacio."}

    # GHOST
    _moves[140] = {"name":"Puño Sombra","type":13,"category":0,"power":50,"desc":"Puño ineludible desde las sombras."}
    _moves[141] = {"name":"Garra Umbría","type":13,"category":0,"power":90,"desc":"Araña con garras fantasmales."}
    _moves[142] = {"name":"Poltergeist","type":13,"category":0,"power":120,"desc":"Controla objetos para atacar."}
    _moves[143] = {"name":"Infortunio","type":13,"category":1,"power":50,"desc":"Daño duplicado si hay problemas de estado."}
    _moves[144] = {"name":"Bola Sombra","type":13,"category":1,"power":90,"desc":"Proyectil de energía oscura."}
    _moves[145] = {"name":"Haz Espectral","type":13,"category":1,"power":120,"desc":"Rayo fantasmal destructor."}

    # DRAGON
    _moves[150] = {"name":"Garra Dragón","type":14,"category":0,"power":50,"desc":"Araña con garras de dragón."}
    _moves[151] = {"name":"Martillo Dragón","type":14,"category":0,"power":90,"desc":"Golpea con el cuerpo de dragón."}
    _moves[152] = {"name":"Enfado","type":14,"category":0,"power":120,"desc":"Furia descontrolada de dragón."}
    _moves[153] = {"name":"Dragoaliento","type":14,"category":1,"power":50,"desc":"Aliento de dragón abrasador."}
    _moves[154] = {"name":"Pulso Dragón","type":14,"category":1,"power":90,"desc":"Onda de choque mística."}
    _moves[155] = {"name":"Cometa Draco","type":14,"category":1,"power":120,"desc":"Lluvia de meteoros de dragón."}

    # DARK
    _moves[160] = {"name":"Ladrón","type":15,"category":0,"power":50,"desc":"Ataque rápido y roba objetos."}
    _moves[161] = {"name":"Triturar","type":15,"category":0,"power":90,"desc":"Mordisco triturador oscuro."}
    _moves[162] = {"name":"Golpe Oscuro","type":15,"category":0,"power":120,"desc":"Golpe crítico inevitable."}
    _moves[163] = {"name":"Alarido","type":15,"category":1,"power":50,"desc":"Grito siniestro."}
    _moves[164] = {"name":"Pulso Umbrío","type":15,"category":1,"power":90,"desc":"Onda de energía oscura."}
    _moves[165] = {"name":"Bola Oscura","type":15,"category":1,"power":120,"desc":"Onda de energía oscura máxima.",
        "status_effect":Move.StatusEffect.PARALYSIS,"status_chance":0.2}

    # STEEL
    _moves[170] = {"name":"Garra Metal","type":16,"category":0,"power":50,"desc":"Corta con garras de metal."}
    _moves[171] = {"name":"Cabeza de Hierro","type":16,"category":0,"power":90,"desc":"Cabezazo duro como el hierro."}
    _moves[172] = {"name":"Megatón Acero","type":16,"category":0,"power":120,"desc":"Golpe devastador de acero."}
    _moves[173] = {"name":"Disparo Espejo","type":16,"category":1,"power":50,"desc":"Destello de luz espejo."}
    _moves[174] = {"name":"Foco Resplandor","type":16,"category":1,"power":90,"desc":"Rayo concentrado de luz."}
    _moves[175] = {"name":"Deseo Oculto","type":16,"category":1,"power":120,"desc":"Poder misterioso del acero."}

    # FAIRY
    _moves[180] = {"name":"Choque Anímico","type":17,"category":0,"power":50,"desc":"Impacto de fuerza espiritual."}
    _moves[181] = {"name":"Carantoña","type":17,"category":0,"power":90,"desc":"Juego brusco y travieso."}
    _moves[182] = {"name":"Feerichoque","type":17,"category":0,"power":120,"desc":"Golpe mágico devastador."}
    _moves[183] = {"name":"Beso Drenaje","type":17,"category":1,"power":50,"desc":"Restaura HP al dañar."}
    _moves[184] = {"name":"Fuerza Lunar","type":17,"category":1,"power":90,"desc":"Poder de la luz lunar."}
    _moves[185] = {"name":"Luz Aniquiladora","type":17,"category":1,"power":120,"desc":"Rayo de energía pura de luz."}

func _generate_generic(type: int, category: int, power: int) -> Move:
    # Para los 108 movimientos que se generan por tipo/categoría/poder,
    # busca si ya existe uno registrado con esos parámetros
    return get_stab_move(type, category, power)
```

**Archivo:** `res://scripts/core/registry/move_registry.gd`
**Autoload:** Agregar `MoveRegistry="*res://scripts/core/registry/move_registry.gd"` a `project.godot`
**Conexión:** `Move.create_by_id(id)` pasa a llamarse `MoveRegistry.get_move(id)`
**Elimina:** La función `get_move_by_type_category_power()` de move.gd (410→~100 líneas)

---

### 1.2 AbilityRegistry — `res://scripts/core/registry/ability_registry.gd`

**Clase:** `AbilityRegistryClass extends Node` (autoload)

```gdscript
# res://scripts/core/registry/ability_registry.gd
# Autoload: AbilityRegistry
class_name AbilityRegistryClass
extends Node

var _abilities: Dictionary = {}

func _ready() -> void:
    _register_all_abilities()

func get_ability(id: int) -> Ability:
    var data: Dictionary = _abilities.get(id, {})
    if data.is_empty():
        return Ability.create(Ability.AbilityID.NONE)
    return Ability.create(data.get("enum_id", id))

func get_data(id: int) -> Dictionary:
    return _abilities.get(id, {})

func _register_all_abilities() -> void:
    _abilities[1] = {"enum_id":1,"name":"Mar de Llamas","desc":"Potencia Fuego ×1.5 cuando HP ≤ 1/3.",
        "trigger_type":"offensive_multiplier","type_boost":Enums.PokemonType.FIRE}
    _abilities[2] = {"enum_id":2,"name":"Espesura","desc":"Potencia Planta ×1.5 cuando HP ≤ 1/3.",
        "trigger_type":"offensive_multiplier","type_boost":Enums.PokemonType.GRASS}
    _abilities[3] = {"enum_id":3,"name":"Torrente","desc":"Potencia Agua ×1.5 cuando HP ≤ 1/3.",
        "trigger_type":"offensive_multiplier","type_boost":Enums.PokemonType.WATER}
    _abilities[4] = {"enum_id":4,"name":"Estática","desc":"30% de paralizar al rival con contacto.",
        "trigger_type":"on_contact_hit"}
    _abilities[5] = {"enum_id":5,"name":"Intimidación","desc":"Baja el Ataque del rival 1 stage al entrar.",
        "trigger_type":"on_battle_start"}
    _abilities[6] = {"enum_id":6,"name":"Mudar","desc":"30% de curar estado al final del turno.",
        "trigger_type":"on_turn_end"}
    _abilities[7] = {"enum_id":7,"name":"Nado Rápido","desc":"Dobla Velocidad bajo la lluvia.",
        "trigger_type":"on_speed_calc","weather":"rain"}
    _abilities[8] = {"enum_id":8,"name":"Clorofila","desc":"Dobla Velocidad bajo el sol.",
        "trigger_type":"on_speed_calc","weather":"sun"}
    _abilities[9] = {"enum_id":9,"name":"Absorbe Fuego","desc":"Inmune a Fuego. Potencia Fuego ×1.5 al recibirlo.",
        "trigger_type":"defensive_immunity","type_absorb":Enums.PokemonType.FIRE}
    _abilities[10] = {"enum_id":10,"name":"Levitación","desc":"Inmune a Tierra.",
        "trigger_type":"defensive_immunity","type_absorb":Enums.PokemonType.GROUND}
    _abilities[11] = {"enum_id":11,"name":"Robustez","desc":"Sobrevive con 1 HP si HP estaba lleno.",
        "trigger_type":"on_would_faint"}
    _abilities[12] = {"enum_id":12,"name":"Sebo","desc":"Reduce Fuego e Hielo a la mitad.",
        "trigger_type":"defensive_resist","types":[Enums.PokemonType.FIRE,Enums.PokemonType.ICE],"mult":0.5}
```

**Archivo:** `res://scripts/core/registry/ability_registry.gd`
**Autoload:** Agregar `AbilityRegistry="*res://scripts/core/registry/ability_registry.gd"`
**Conexión:** `Ability.create(id)` pasa a usar el AbilityRegistry internamente, o se llama directamente `AbilityRegistry.get_ability(id)`
**Elimina:** El match/case gigante de `Ability.create()` (51→~5 líneas)

---

### 1.3 PokedexData — `res://scripts/core/registry/pokedex_data.gd`

**Clase:** `PokedexDataClass extends Node` (autoload) o solo un `class_name PokedexData` con un const Dictionary.

**Decisión:** Mejor como **const Dictionary en un script static** (no autoload), porque solo es datos. Se accede como `PokedexData.POKEDEX[id]`.

```gdscript
# res://scripts/core/registry/pokedex_data.gd
class_name PokedexData

## Datos completos de cada especie.
## Cada entrada tiene: name, types, evo_id, evo_lvl, stats, default_moves, ability_id, evo_tier
##   evo_tier: 1=base, 2=intermedio, 3=final
##   default_moves: Array[int] — IDs de movimientos del MoveRegistry
##   ability_id: int — ID del AbilityRegistry
const POKEDEX: Dictionary = {
    # ── Línea Bulbasaur ──
    1:  {"name":"Bulbasaur",  "types":[4],    "evo_id":2,  "evo_lvl":16, "stats":[45,49,49,45,65,65],
         "default_moves":[43,40,83,80],  "ability_id":2, "evo_tier":1},
    2:  {"name":"Ivysaur",    "types":[4,7],  "evo_id":3,  "evo_lvl":32, "stats":[60,62,63,60,80,80],
         "default_moves":[43,41,84,81],  "ability_id":2, "evo_tier":2},
    3:  {"name":"Venusaur",   "types":[4,7],  "evo_id":null,"evo_lvl":0,  "stats":[80,82,83,80,100,100],
         "default_moves":[44,42,85,82],  "ability_id":2, "evo_tier":3},
    # ── Línea Charmander ──
    4:  {"name":"Charmander", "types":[1],   "evo_id":5,  "evo_lvl":16, "stats":[39,52,43,50,65,60],
         "default_moves":[4,13,60,10],   "ability_id":1, "evo_tier":1},
    5:  {"name":"Charmeleon", "types":[1],   "evo_id":6,  "evo_lvl":36, "stats":[58,64,58,65,80,80],
         "default_moves":[4,14,61,11],   "ability_id":1, "evo_tier":2},
    6:  {"name":"Charizard",  "types":[1,9], "evo_id":null,"evo_lvl":0,  "stats":[78,84,78,100,109,85],
         "default_moves":[15,102,62,12], "ability_id":1, "evo_tier":3},
    # ── Línea Squirtle ──
    7:  {"name":"Squirtle",  "types":[2],    "evo_id":8,  "evo_lvl":16, "stats":[44,48,65,43,50,64],
         "default_moves":[2,23,70,93],   "ability_id":3, "evo_tier":1},
    8:  {"name":"Wartortle", "types":[2],    "evo_id":9,  "evo_lvl":36, "stats":[59,63,80,58,65,80],
         "default_moves":[2,24,71,94],   "ability_id":3, "evo_tier":2},
    9:  {"name":"Blastoise", "types":[2],    "evo_id":null,"evo_lvl":0,  "stats":[79,83,100,78,85,105],
         "default_moves":[25,22,72,95],  "ability_id":3, "evo_tier":3},
    # ── Caterpie → Metapod → Butterfree ──
    10: {"name":"Caterpie",  "types":[11],   "evo_id":11, "evo_lvl":7,  "stats":[45,30,35,45,20,20],
         "default_moves":[120],          "ability_id":0, "evo_tier":1},
    11: {"name":"Metapod",   "types":[11],   "evo_id":12, "evo_lvl":10, "stats":[50,20,55,30,25,25],
         "default_moves":[120],          "ability_id":0, "evo_tier":2},
    12: {"name":"Butterfree","types":[11,9], "evo_id":null,"evo_lvl":0,  "stats":[60,45,50,70,80,80],
         "default_moves":[124,103,53,125],"ability_id":0, "evo_tier":3},
    # ... (continúa para las 151 entradas)
    # ── Pikachu ──
    25: {"name":"Pikachu",   "types":[3],    "evo_id":26, "evo_lvl":0,  "stats":[35,55,30,90,50,40],
         "default_moves":[30,33,113,63], "ability_id":4, "evo_tier":1},
    26: {"name":"Raichu",    "types":[3],    "evo_id":null,"evo_lvl":0,  "stats":[60,90,55,110,90,80],
         "default_moves":[31,34,114,64], "ability_id":4, "evo_tier":2},
    # ... todas las demás entradas
}
```

**Archivo:** `res://scripts/core/registry/pokedex_data.gd`
**NO es autoload** — es un script con `class_name` y un `const` estático.
**Conexión:** `Pokemon._initialize_pokemon()` consulta `PokedexData.POKEDEX[pokedex_id]` en lugar de `Pokemon.POKEDEX[pokedex_id]`
**Elimina:** El `const POKEDEX` gigante de `pokemon.gd` (341→~80 líneas)

---

### 1.4 Cómo se conectan los Pokemon con los registros

**Flujo de construcción de un Pokemon:**

```
PokedexData.POKEDEX[id] → {"default_moves":[4,13,60,10], "ability_id":1, ...}
                                  ↓                          ↓
                         MoveRegistry.get_move(4)    AbilityRegistry.get_ability(1)
                                  ↓                          ↓
                         Move Resource               Ability Resource
                                  ↓                          ↓
                         pokemon.moves[]             pokemon.ability
```

**En `pokemon.gd`._initialize_pokemon():**

```gdscript
func _initialize_pokemon() -> void:
    var data := PokedexData.POKEDEX.get(pokedex_id, {})
    if not data.is_empty():
        species_name    = data.name
        types           = (data.types as Array).map(func(t): return t as int)
        evolution_id    = data.evo_id
        evolution_level = data.evo_lvl
        evo_tier        = data.get("evo_tier", 1)
        if not stats:
            var s: Array = data.stats
            stats = PokemonStats.create(s[0], s[1], s[2], s[3], s[4], s[5])
    else:
        # fallback
        ...

    stats.recalculate(level)

    # Cargar ability desde AbilityRegistry
    ability = AbilityRegistry.get_ability(data.get("ability_id", 0) if not data.is_empty() else ability_id)

    # Cargar moves desde MoveRegistry
    moves.clear()
    var default_mids: Array = data.get("default_moves", []) if not data.is_empty() else []
    for m_id in move_ids if not move_ids.is_empty() else default_mids:
        moves.append(MoveRegistry.get_move(m_id))
```

---

## FASE 2: Refactorización del Objeto Pokemon

### 2.1 Cambios en `pokemon.gd`

**Archivo:** `res://scripts/core/pokemon.gd`

Cambios principales:
1. Eliminar `const POKEDEX` (se mueve a `PokedexData`)
2. Agregar campo `evo_tier: int`
3. Agregar campo `player_attack_power: int` (o que se pase al crear el Pokemon)
4. `_initialize_pokemon()` usa `PokedexData`, `MoveRegistry`, `AbilityRegistry`
5. Agregar método para serializar a Dictionary (para backward compat con el sistema actual)
6. Agregar método estático `from_dictionary(dict: Dictionary) -> Pokemon` para migrar

```gdscript
class_name Pokemon
extends Node

signal evolved(old_id: int, new_id: int)

@export var animated_sprite: Node
@export var pokedex_id: int = 1
@export var species_name: String = ""
@export var types: Array[int] = []
@export var evolution_id: Variant = null
@export var evolution_level: int = 0
@export var evo_tier: int = 1  # 1=base, 2=intermedio, 3=final

@export var level: int = 5
var stats: PokemonStats

@export var ability_id: int = 1
var ability: Ability

@export var move_ids: Array[int] = []
var moves: Array[Move] = []

enum Status { NONE, BURN, FREEZE, PARALYSIS, POISON, BAD_POISON, SLEEP, CONFUSION }
var status: int = Status.NONE

# ── Serialización para backward compat con Array[Dictionary] ──
func to_dictionary() -> Dictionary:
    return {
        "pokedex_id": pokedex_id,
        "name": species_name,
        "types": types.duplicate(),
        "level": level,
        "evo_id": evolution_id,
        "evo_lvl": evolution_level,
        "evo_tier": evo_tier,
        "current_hp": stats.hp_current if stats else -1,
        "move_ids": move_ids.duplicate(),
        "ability_id": ability_id,
    }

static func from_dictionary(dict: Dictionary) -> Pokemon:
    var p := Pokemon.new()
    p.pokedex_id = dict.get("pokedex_id", 1)
    p.level = dict.get("level", 5)
    p.move_ids = dict.get("move_ids", []) as Array[int]
    p.ability_id = dict.get("ability_id", 1)
    p.status = dict.get("status", Status.NONE)
    # _initialize_pokemon() se llama en _ready() o puede llamarse explícitamente
    return p
```

### 2.2 Cambios en `main_mobile.gd`

**Cambio principal:** `player_party` pasa de `Array[Dictionary]` a `Array[Pokemon]`.

```gdscript
# ANTES:
var player_party: Array[Dictionary] = []
var player_attack_power: int = 50

# DESPUÉS:
var player_party: Array[Pokemon] = []
var player_attack_power: int = 50  # Se pasa al Pokemon o se mantiene global
```

**`_find_pokemon_dictionary` → `_create_pokemon`:**

```gdscript
func _create_pokemon(pokedex_id: int, level: int = 5) -> Pokemon:
    var p := Pokemon.new()
    p.pokedex_id = pokedex_id
    p.level = level
    # _initialize_pokemon() se llama en _ready()
    return p

func _create_pokemon_by_name(p_name: String, level: int = 5) -> Pokemon:
    # Buscar por nombre en PokedexData
    for id in PokedexData.POKEDEX:
        var data: Dictionary = PokedexData.POKEDEX[id]
        if String(data.get("name", "")).nocasecmp_to(p_name) == 0:
            return _create_pokemon(id, level)
    # Fallback
    var p := Pokemon.new()
    p.species_name = p_name
    p.level = level
    return p
```

**En `_launch_battle()`:**
```gdscript
func _launch_battle(_mode_name: String, details: Dictionary) -> void:
    ...
    # Convertir player_party a formato que battle_ui entiende
    var battle_party: Array = []
    for pokemon in player_party:
        battle_party.append(pokemon.to_dictionary())
    battle_details["player_party"] = battle_party
    battle_details["player_attack_power"] = player_attack_power
    ...
```

**En `_on_battle_finished()`:**
```gdscript
func _on_battle_finished(result: String, battle_details: Dictionary = {}, hp_report: Array = []) -> void:
    for report in hp_report:
        var orig_idx: int = report.get("original_idx", -1)
        var new_hp: int = report.get("hp", 0)
        if orig_idx >= 0 and orig_idx < player_party.size():
            var p: Pokemon = player_party[orig_idx]
            if p.stats:
                p.stats.hp_current = new_hp
    ...
```

### 2.3 Elimina

- `_find_pokemon_dictionary()` (reemplazada por `_create_pokemon_by_name()`)
- El uso de `brock_config` en `main_mobile.gd` (ya no se hardcodea al pool de Brock)
- Acceso a `p["name"]`, `p["level"]`, `p["current_hp"]` → ahora son `p.species_name`, `p.level`, `p.stats.hp_current`

---

## FASE 3: Integración del Sistema de Batalla

### 3.1 Eliminar duplicados de `mobile_battle_ui.gd`

**Archivo:** `res://scripts/ui/mobile_battle_ui.gd`

**Elimina:**
- `const POKEDEX_BASE: Dictionary` (60 entradas duplicadas) → usa `PokedexData`
- `const TYPE_CHART: Dictionary` (incompleto) → usa `TypeChart` autoload
- `_calc_damage()` → usa `DamageCalc.calculate()`
- `_type_effectiveness()` → usa `TypeChart.get_total_effectiveness()`
- `_build_pokemon()` → recibe un `Pokemon` object o construye uno desde el registro

**Cambio en `_build_pokemon()`:**
```gdscript
# ANTES (línea 182-198): 
func _build_pokemon(species: String, level: int, is_player: bool) -> Dictionary:
    var key := species.to_upper()
    var base: Dictionary = POKEDEX_BASE.get(key, {})
    ...
    return { "name": species, "level": level, "hp": hp_stat, ... }

# DESPUÉS:
func _build_pokemon(p_name: String, level: int, is_player: bool) -> Dictionary:
    # Buscar en PokedexData
    var pokedex_id: int = 0
    for id in PokedexData.POKEDEX:
        if String(PokedexData.POKEDEX[id].get("name","")).nocasecmp_to(p_name) == 0:
            pokedex_id = id
            break
    var data: Dictionary = PokedexData.POKEDEX.get(pokedex_id, {})
    if data.is_empty():
        data = {"name":p_name,"types":[0],"stats":[45,50,45,45,45,45]}
    
    var stats_array: Array = data.get("stats", [45,50,45,45,45,45])
    var hp_stat: int = int(float(2 * stats_array[0] * level) / 100.0) + level + 10
    var atk_stat: int = int(float(2 * stats_array[1] * level) / 100.0) + 5
    ...
```

**Nota:** La batalla interna mantiene su propio formato Dictionary por ahora para no romper toda la UI de 813 líneas de golpe. Pero los datos vienen de `PokedexData` en lugar de un duplicado.

**Cambio en `_calc_damage()`:**
```gdscript
# ANTES (línea 572-581):
func _calc_damage(atk: Dictionary, def: Dictionary) -> int:
    var power: int = 40  # SIEMPRE 40! player_attack_power se ignora
    ...

# DESPUÉS:
func _calc_damage(atk: Dictionary, def: Dictionary) -> int:
    var power: int = 40  # Usar player_attack_power del battle context
    if battle_context.has("player_attack_power"):
        power = int(battle_context.player_attack_power) if atk.is_player else 40
    ...
```

**Variable nueva:** `var battle_context: Dictionary = {}` que se pasa desde `setup_battle()`.

**Cambio en `_type_effectiveness()`:**
```gdscript
# ANTES (línea 583-587):
func _type_effectiveness(atk_type: int, def_types: Array) -> float:
    var m := 1.0
    var chart: Dictionary = TYPE_CHART.get(atk_type, {})
    for dt in def_types: m *= chart.get(int(dt), 1.0)
    return m

# DESPUÉS:
func _type_effectiveness(atk_type: int, def_types: Array) -> float:
    var type_data := PokemonTypeData.create(atk_type)
    # Para multi-type defender:
    var total_mult := 1.0
    for dt in def_types:
        total_mult *= TypeChart.get_effectiveness(atk_type, int(dt))
    return total_mult
```

### 3.2 Usar `DamageCalc` properly

```gdscript
func _calc_damage(atk: Dictionary, def: Dictionary) -> int:
    var level: int = int(atk.level)
    var power: int = int(battle_context.get("player_attack_power", 40)) if atk.get("is_player", false) else 40
    var atk_stat: int = int(atk.atk)
    var def_stat: int = maxi(1, int(def.def))
    
    var atk_type_data := PokemonTypeData.create(int(atk.types[0]))
    var def_type_data := PokemonTypeData.create(int(def.types[0]), int(def.types[1]) if def.types.size() > 1 else -1)
    
    var result: DamageCalc.DamageResult = DamageCalc.calculate(
        int(atk.types[0]), atk_type_data, def_type_data, power, atk_stat, def_stat, level, true
    )
    return result.damage
```

---

## FASE 4: Refactorización del Sistema de Mapa

### 4.1 Estructura Separada: Map Graph Data

**Archivo:** `res://scripts/world/map_graph_data.gd`

```gdscript
# res://scripts/world/map_graph_data.gd
class_name MapGraphData
extends RefCounted

## Datos puros del grafo del mapa: nodos, conexiones, posiciones.
## SIN eventos, SIN entrenadores, SIN pools.

var layers: Array = []  # Array de Array de Dictionary
var node_events_map: Dictionary = {}  # id → String tipo de evento

func add_layer(layer_nodes: Array) -> void:
    layers.append(layer_nodes)

func get_layers() -> Array:
    return layers

func get_node_by_id(n_id: String) -> Dictionary:
    for layer in layers:
        for n_data in layer:
            if n_data.id == n_id:
                return n_data
    return {}
```

### 4.2 EventRegistry — `res://scripts/world/event_registry.gd`

```gdscript
# res://scripts/world/event_registry.gd
class_name EventRegistry
extends RefCounted

## Registra pools de eventos que el mapa puede usar.
## Cada pool es un Array de opciones que se asignan a nodos al azar.

var wild_pools: Dictionary = {}     # map_id → Array[String]
var gift_pools: Dictionary = {}    # map_id → Array[Dictionary]
var trainer_definitions: Dictionary = {}  # map_id → Array[TrainerClass]
var possible_node_types: Dictionary = {} # map_id → Array[String]
```

### 4.3 MapConfig refactorizado

**Archivo:** `res://scripts/world/map_config.gd`

```gdscript
class_name MapConfig
extends Resource

# ── Propiedades escalares (igual que antes) ──
var map_id: String = ""
var display_name: String = ""
var level_cap: int = 10
var enemy_team_size: int = 1
var trainer_level: int = 4
var wild_level: int = 4
var max_trainers: int = 4

# ── Datos del jefe ──
var boss_name: String = ""
var boss_chapter_name: String = ""
var boss_bg_color: Color = Color("1a0e0e")
var boss_team: Array = []

# ── Iconos (override en subclases) ──
var icon_grass: String    = "res://assets/sprites/objetos_mapa/frlgpng.png"
var icon_bag: String      = "res://assets/sprites/objetos_mapa/bag_1.png"
var icon_event: String    = "res://assets/sprites/objetos_mapa/000.png"
var icon_tm: String       = "res://assets/sprites/objetos_mapa/machine_tr_NORMAL.png"
var icon_pokeball: String = "res://assets/sprites/objetos_mapa/POKEBALL.png"
var icon_boss: String     = ""

# ── Métodos de datos (override en subclases) ──
func get_map_layers() -> Array:
    return []

func get_wild_pool() -> Array:
    return []

func get_gift_pool() -> Array:
    return []

func get_trainer_classes() -> Array:
    return []

func get_possible_node_types() -> Array[String]:
    return ["GRASS", "BAG", "POKEBALL", "EVENT", "TM"]

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
```

**La estructura se mantiene similar por backward compat.** El cambio principal es que los datos de pools de regalo/salvajes ya no se hardcodean inline en la subclase — se pueden cargar desde archivos separados o mantenerse en la subclase pero referenciando `PokedexData`.

### 4.4 Ejemplo: `brock_map_config.gd` simplificado

```gdscript
class_name BrockMapConfig
extends MapConfig

func _init() -> void:
    map_id = "kanto_brock"
    display_name = "Ruta 1 - Ciudad Plateada (Brock)"
    level_cap = 14
    enemy_team_size = 1
    trainer_level = 4
    wild_level = 4
    max_trainers = 4
    boss_name = "Brock - Líder de Gimnasio"
    boss_chapter_name = "Gimnasio de Pewter (Brock)"
    boss_bg_color = Color("1a0e0e")
    boss_team = [
        {"name": "Geodude", "level": 12},
        {"name": "Onix", "level": 14}
    ]
    icon_boss = "res://assets/sprites/objetos_mapa/entrenadores/brock1.PNG"

func get_wild_pool() -> Array:
    return ["Caterpie", "Pidgey", "Rattata", "Pikachu", "Nidoran♂"]

func get_gift_pool() -> Array:
    # Usa PokedexData en lugar de Pokemon.POKEDEX
    var pool: Array = []
    var gift_ids: Array[int] = [
        1, 4, 7, 10, 13, 16, 19, 21, 23, 25, 27, 29, 32, 35, 37, 39, 41, 43, 46,
        48, 50, 52, 54, 56, 58, 60, 63, 66, 69, 72, 74, 77, 79, 81, 84, 86, 88,
        90, 92, 96, 98, 100, 102, 104, 109, 111, 116, 118, 120, 129, 133, 138, 140
    ]
    for id in gift_ids:
        var data: Dictionary = PokedexData.POKEDEX.get(id, {})
        if not data.is_empty():
            pool.append({
                "pokedex_id": id,
                "name": data.name,
                "types": data.types,
                "evo_id": data.evo_id,
                "evo_lvl": data.evo_lvl,
                "stats": data.stats,
                "sprite_path": "res://assets/sprites/pokemon/pokemon izquierda/%s.png" % data.name.to_upper(),
            })
    return pool

func get_map_layers() -> Array:
    return [
        # ... (igual que antes, 7 capas con posiciones Vector2)
    ]

func get_trainer_classes() -> Array:
    return [
        _create_tc("bug_catcher","Cazabichos","res://assets/sprites/objetos_mapa/entrenadores/cazabichos1.png",["Caterpie","Weedle","Paras","Venonat"]),
        _create_tc("nerd","Cerebrito","res://assets/sprites/objetos_mapa/entrenadores/cerebrito.png",["Pikachu","Voltorb","Magnemite","Rattata","Pidgey","Meowth","Spearow"]),
        # ... (resto igual)
    ]
```

### 4.5 Flujo de como se agrega un nuevo gym

```
1. Crear res://scripts/world/regions/kanto/gym3_lt_surge/surge_map_config.gd
   → class_name SurgeMapConfig extends MapConfig
   → Definir _init() con propiedades escalares
   → Definir get_map_layers() con la estructura del mapa
   → Definir get_wild_pool(), get_gift_pool(), get_trainer_classes()
   → Definir boss_team, boss_name, etc.

2. (Opcional) Crear surge_boss_event.gd si necesita lógica especial del jefe

3. Agregar a kanto_region.gd:
   → maps.append(preload("res://scripts/world/regions/kanto/gym3_lt_surge/surge_map_config.gd").new())
```

---

## FASE 5: Integración y Orden de Migración

### Orden de refactorización (para no romper nada):

#### Paso 1: Crear archivos nuevos (sin tocar existentes)
1. `res://scripts/core/registry/move_registry.gd`
2. `res://scripts/core/registry/ability_registry.gd`
3. `res://scripts/core/registry/pokedex_data.gd`
4. Agregar autoloads en `project.godot`:
   ```
   MoveRegistry="*res://scripts/core/registry/move_registry.gd"
   AbilityRegistry="*res://scripts/core/registry/ability_registry.gd"
   ```

**Verificación:** El juego debería correr igual que antes (los nuevos autoloads no rompen nada porque nadie los usa aún).

#### Paso 2: Refactorizar `pokemon.gd`
1. Eliminar `const POKEDEX`
2. Agregar `evo_tier`
3. Cambiar `_initialize_pokemon()` para usar `PokedexData`, `MoveRegistry`, `AbilityRegistry`
4. Agregar `to_dictionary()` y `from_dictionary()`
5. Agregar `signal status_changed` si se necesita

**Verificación:** `starter_selection.gd`, `pokemon_gift_ui.gd`, y `main_mobile.gd` siguen usando Dictionary. Hay que agregar un `from_dictionary()` que funcione con el formato actual de diccionario.

#### Paso 3: Migrar `main_mobile.gd`
1. Cambiar `var player_party: Array[Dictionary]` → `Array[Pokemon]`
2. Reemplazar `_find_pokemon_dictionary()` por `_create_pokemon_by_name()`
3. Adaptar `_on_battle_finished()` para usar objetos Pokemon
4. Adaptar `_launch_battle()` para serializar Pokemon a Dictionary para battle_ui

**Verificación:** La selección de starter, el regalo, y el paso de datos a battle_ui funcionan.

#### Paso 4: Refactorizar `mobile_battle_ui.gd`
1. Eliminar `POKEDEX_BASE`
2. Eliminar `TYPE_CHART`
3. Cambiar `_build_pokemon()` para usar `PokedexData`
4. Cambiar `_calc_damage()` para usar `DamageCalc` y `player_attack_power`
5. Cambiar `_type_effectiveness()` para usar `TypeChart`

**Verificación:** Las batallas dan los mismos resultados (o mejores, porque ahora usan STAB y el tipo correcto).

#### Paso 5: Refactorizar MapConfigs
1. Cambiar `get_gift_pool()` de `BrockMapConfig` para usar `PokedexData`
2. Hacer lo mismo para `MistyMapConfig` y `LeagueMapConfig`
3. Refactorizar `kanto_route_map.gd` si es necesario

**Verificación:** El mapa funciona igual, los pools de regalo muestran los mismos Pokémon.

#### Paso 6: Limpieza
1. Eliminar `Move.get_species_type_and_category()` (ya no se necesita)
2. Eliminar la función `get_move_by_type_category_power()` de move.gd
3. Revisar que no queden referencias a `Pokemon.POKEDEX`
4. Agregar type hints a todo lo que se pueda

**Verificación final:** El juego completo funciona, las batallas son correctas, el mapa funciona, se puede agregar un nuevo gym creando solo un archivo.

---

### Archivos modificados (resumen)

| Archivo | Acción | Cambios |
|---------|--------|---------|
| `project.godot` | Modificar | +2 autoloads (MoveRegistry, AbilityRegistry) |
| `scripts/core/pokemon.gd` | Modificar | Eliminar POKEDEX, usar registros, +evo_tier, +serialización |
| `scripts/core/move.gd` | Modificar | Eliminar get_move_by_type_category_power, get_species_type_and_category |
| `scripts/core/ability.gd` | Modificar | Simplificar create() usando AbilityRegistry |
| `scripts/core/registry/move_registry.gd` | **Crear** | Registro de 108+ movimientos |
| `scripts/core/registry/ability_registry.gd` | **Crear** | Registro de 12+ habilidades |
| `scripts/core/registry/pokedex_data.gd` | **Crear** | Pokédex completa con default_moves y ability_id |
| `scripts/main_mobile.gd` | Modificar | player_party → Array[Pokemon], reemplazar _find_pokemon_dictionary |
| `scripts/ui/mobile_battle_ui.gd` | Modificar | Eliminar POKEDEX_BASE, TYPE_CHART, usar registros |
| `scripts/world/regions/kanto/gym1_brock/brock_map_config.gd` | Modificar | Usar PokedexData |
| `scripts/world/regions/kanto/gym2_misty/misty_map_config.gd` | Modificar | Usar PokedexData |
| `scripts/world/regions/kanto/pokemon_league/league_map_config.gd` | Modificar | Usar PokedexData |
| `scripts/core/damage_calculator.gd` | No cambiar | Ya funciona bien |
| `scripts/core/type_chart.gd` | No cambiar | Ya funciona bien |
| `scripts/core/pokemon_stats.gd` | No cambiar | Ya funciona bien |
| `scripts/core/pokemon_type.gd` | No cambiar | Ya funciona bien |
| `scripts/core/enums.gd` | No cambiar | Ya funciona bien |

### Archivos eliminados (completamente)

| Archivo | Razón |
|---------|-------|
| Ninguno | No eliminamos archivos, solo refactorizamos |

### Nuevos archivos creados

| Archivo | Tipo | Líneas aprox |
|---------|------|-------------|
| `scripts/core/registry/move_registry.gd` | Autoload | ~250 |
| `scripts/core/registry/ability_registry.gd` | Autoload | ~50 |
| `scripts/core/registry/pokedex_data.gd` | class_name | ~400 |

---

### Verificación por fase

- **Fase 1:** Los 3 archivos nuevos se crean. El juego corre sin errores. Los registros se pueden inspeccionar en el editor de Godot.
- **Fase 2:** La selección de starter crea objetos Pokemon. El party se muestra correctamente en party_view_ui.
- **Fase 3:** Las batallas usan el MoveRegistry, TypeChart, DamageCalc correctamente. Los tipos y STAB se aplican bien.
- **Fase 4:** El mapa funciona igual. Los pools de regalo muestran los mismos Pokémon. Se puede crear un nuevo gym solo con un archivo de config.
- **Fase 5:** No quedan duplicados. El código está limpio y con type hints.
