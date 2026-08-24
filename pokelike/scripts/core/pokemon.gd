# res://scripts/core/pokemon.gd
class_name Pokemon
extends Node

## Emitido cuando el Pokémon evoluciona. Pasa el nuevo ID de la Pokédex.
signal evolved(old_id: int, new_id: int)

## Referencia al nodo animado (por ejemplo, AnimatedSprite2D)
@export var animated_sprite: Node

## ── Datos básicos ─────────────────────────────────────────────────────────────
@export var pokedex_id: int = 1
@export var species_name: String = "Charmander"
@export var types: Array[int] = [Enums.PokemonType.FIRE]

## ID de la siguiente evolución en la Pokédex (null = sin evolución)
@export var evolution_id: Variant = null
## Nivel en el que se produce la evolución (0 = no evoluciona por nivel)
@export var evolution_level: int = 0

## ── Nivel y estadísticas ──────────────────────────────────────────────────────
@export var level: int = 5
var stats: PokemonStats

## ── Habilidad (por ID numérico) ───────────────────────────────────────────────
@export var ability_id: int = 1
var ability: Ability

## ── Ataques (por ID numérico) ─────────────────────────────────────────────────
@export var move_ids: Array[int] = [1]
var moves: Array[Move] = []

## ── Objeto equipado (ID del ItemRegistry, 0 = ninguno) ───────────────────────
@export var held_item_id: int = 0

## ── Estado de combate ─────────────────────────────────────────────────────────
enum Status { NONE, BURN, FREEZE, PARALYSIS, POISON, BAD_POISON, SLEEP, CONFUSION }
var status: int = Status.NONE

# ── Datos de evolución por especie ─────────────────────────────────────────────
# Formato: { pokedex_id: { "name", "types", "evolution_id", "evolution_level", "stats": [hp,atk,def,spe,spa,spd] } }
const POKEDEX: Dictionary = {
	# ── Línea Bulbasaur ────────────────────────────────────────────────────────
	1:  {"name":"Bulbasaur",  "types":[4],    "evo_id":2,    "evo_lvl":16, "stats":[45,49,49,45,65,65]},
	2:  {"name":"Ivysaur",   "types":[4,7],  "evo_id":3,    "evo_lvl":32, "stats":[60,62,63,60,80,80]},
	3:  {"name":"Venusaur",  "types":[4,7],  "evo_id":null, "evo_lvl":0,  "stats":[80,82,83,80,100,100]},
	# ── Línea Charmander ───────────────────────────────────────────────────────
	4:  {"name":"Charmander", "types":[1],   "evo_id":5,    "evo_lvl":16, "stats":[39,52,43,50,65,60]},
	5:  {"name":"Charmeleon", "types":[1],   "evo_id":6,    "evo_lvl":36, "stats":[58,64,58,65,80,80]},
	6:  {"name":"Charizard",  "types":[1,9], "evo_id":null, "evo_lvl":0,  "stats":[78,84,78,100,109,85]},
	# ── Línea Squirtle ─────────────────────────────────────────────────────────
	7:  {"name":"Squirtle",  "types":[2],    "evo_id":8,    "evo_lvl":16, "stats":[44,48,65,43,50,64]},
	8:  {"name":"Wartortle", "types":[2],    "evo_id":9,    "evo_lvl":36, "stats":[59,63,80,58,65,80]},
	9:  {"name":"Blastoise", "types":[2],    "evo_id":null, "evo_lvl":0,  "stats":[79,83,100,78,85,105]},
	# ── Caterpie → Metapod → Butterfree ───────────────────────────────────────
	10: {"name":"Caterpie",  "types":[11],   "evo_id":11,   "evo_lvl":7,  "stats":[45,30,35,45,20,20]},
	11: {"name":"Metapod",   "types":[11],   "evo_id":12,   "evo_lvl":10, "stats":[50,20,55,30,25,25]},
	12: {"name":"Butterfree","types":[11,9], "evo_id":null, "evo_lvl":0,  "stats":[60,45,50,70,80,80]},
	# ── Weedle → Kakuna → Beedrill ────────────────────────────────────────────
	13: {"name":"Weedle",    "types":[7,11], "evo_id":14,   "evo_lvl":7,  "stats":[40,35,30,50,20,20]},
	14: {"name":"Kakuna",    "types":[7,11], "evo_id":15,   "evo_lvl":10, "stats":[45,25,50,35,25,25]},
	15: {"name":"Beedrill",  "types":[7,11], "evo_id":null, "evo_lvl":0,  "stats":[65,90,40,75,45,80]},
	# ── Pidgey → Pidgeotto → Pidgeot ──────────────────────────────────────────
	16: {"name":"Pidgey",    "types":[9,0],  "evo_id":17,   "evo_lvl":18, "stats":[40,45,40,56,35,35]},
	17: {"name":"Pidgeotto", "types":[9,0],  "evo_id":18,   "evo_lvl":36, "stats":[63,60,55,71,50,50]},
	18: {"name":"Pidgeot",   "types":[9,0],  "evo_id":null, "evo_lvl":0,  "stats":[83,80,75,101,70,70]},
	# ── Rattata → Raticate ────────────────────────────────────────────────────
	19: {"name":"Rattata",   "types":[0],    "evo_id":20,   "evo_lvl":20, "stats":[30,56,35,72,25,35]},
	20: {"name":"Raticate",  "types":[0],    "evo_id":null, "evo_lvl":0,  "stats":[55,81,60,97,50,70]},
	# ── Spearow → Fearow ──────────────────────────────────────────────────────
	21: {"name":"Spearow",   "types":[9,0],  "evo_id":22,   "evo_lvl":20, "stats":[40,60,30,70,31,31]},
	22: {"name":"Fearow",    "types":[9,0],  "evo_id":null, "evo_lvl":0,  "stats":[65,90,65,100,61,61]},
	# ── Ekans → Arbok ─────────────────────────────────────────────────────────
	23: {"name":"Ekans",     "types":[7],    "evo_id":24,   "evo_lvl":22, "stats":[35,60,44,55,40,54]},
	24: {"name":"Arbok",     "types":[7],    "evo_id":null, "evo_lvl":0,  "stats":[60,95,69,80,65,79]},
	# ── Pikachu → Raichu ──────────────────────────────────────────────────────
	25: {"name":"Pikachu",   "types":[3],    "evo_id":26,   "evo_lvl":0,  "stats":[35,55,30,90,50,40]},  # Evoluciona con piedra
	26: {"name":"Raichu",    "types":[3],    "evo_id":null, "evo_lvl":0,  "stats":[60,90,55,110,90,80]},
	# ── Sandshrew → Sandslash ─────────────────────────────────────────────────
	27: {"name":"Sandshrew", "types":[8],    "evo_id":28,   "evo_lvl":22, "stats":[50,75,85,40,20,30]},
	28: {"name":"Sandslash", "types":[8],    "evo_id":null, "evo_lvl":0,  "stats":[75,100,110,65,45,55]},
	# ── Nidoran♀ → Nidorina → Nidoqueen ──────────────────────────────────────
	29: {"name":"Nidoran♀",  "types":[7],    "evo_id":30,   "evo_lvl":16, "stats":[55,47,52,41,40,40]},
	30: {"name":"Nidorina",  "types":[7],    "evo_id":31,   "evo_lvl":0,  "stats":[70,62,67,56,55,55]},  # Evoluciona con piedra
	31: {"name":"Nidoqueen", "types":[7,8],  "evo_id":null, "evo_lvl":0,  "stats":[90,92,87,76,75,85]},
	# ── Nidoran♂ → Nidorino → Nidoking ───────────────────────────────────────
	32: {"name":"Nidoran♂",  "types":[7],    "evo_id":33,   "evo_lvl":16, "stats":[46,57,40,50,40,40]},
	33: {"name":"Nidorino",  "types":[7],    "evo_id":34,   "evo_lvl":0,  "stats":[61,72,57,65,55,55]},  # Evoluciona con piedra
	34: {"name":"Nidoking",  "types":[7,8],  "evo_id":null, "evo_lvl":0,  "stats":[81,102,77,85,85,75]},
	# ── Clefairy → Clefable ───────────────────────────────────────────────────
	35: {"name":"Clefairy",  "types":[17],   "evo_id":36,   "evo_lvl":0,  "stats":[70,45,48,35,60,65]},
	36: {"name":"Clefable",  "types":[17],   "evo_id":null, "evo_lvl":0,  "stats":[95,70,73,60,85,90]},
	# ── Vulpix → Ninetales ────────────────────────────────────────────────────
	37: {"name":"Vulpix",    "types":[1],    "evo_id":38,   "evo_lvl":0,  "stats":[38,41,40,65,50,65]},
	38: {"name":"Ninetales", "types":[1],    "evo_id":null, "evo_lvl":0,  "stats":[73,76,75,100,81,100]},
	# ── Jigglypuff → Wigglytuff ───────────────────────────────────────────────
	39: {"name":"Jigglypuff","types":[0,17], "evo_id":40,   "evo_lvl":0,  "stats":[115,45,20,20,45,25]},
	40: {"name":"Wigglytuff","types":[0,17], "evo_id":null, "evo_lvl":0,  "stats":[140,70,45,45,75,50]},
	# ── Zubat → Golbat ────────────────────────────────────────────────────────
	41: {"name":"Zubat",     "types":[7,9],  "evo_id":42,   "evo_lvl":22, "stats":[40,45,35,55,30,40]},
	42: {"name":"Golbat",    "types":[7,9],  "evo_id":null, "evo_lvl":0,  "stats":[75,80,70,90,65,75]},
	# ── Oddish → Gloom → Vileplume ────────────────────────────────────────────
	43: {"name":"Oddish",    "types":[4,7],  "evo_id":44,   "evo_lvl":21, "stats":[45,50,55,30,75,65]},
	44: {"name":"Gloom",     "types":[4,7],  "evo_id":45,   "evo_lvl":0,  "stats":[60,65,70,40,85,75]},
	45: {"name":"Vileplume", "types":[4,7],  "evo_id":null, "evo_lvl":0,  "stats":[75,80,85,50,100,90]},
	# ── Paras → Parasect ──────────────────────────────────────────────────────
	46: {"name":"Paras",     "types":[11,4], "evo_id":47,   "evo_lvl":24, "stats":[35,70,55,25,45,55]},
	47: {"name":"Parasect",  "types":[11,4], "evo_id":null, "evo_lvl":0,  "stats":[60,95,80,30,60,80]},
	# ── Venonat → Venomoth ────────────────────────────────────────────────────
	48: {"name":"Venonat",   "types":[11,7], "evo_id":49,   "evo_lvl":31, "stats":[60,55,50,45,40,55]},
	49: {"name":"Venomoth",  "types":[11,7], "evo_id":null, "evo_lvl":0,  "stats":[70,65,60,90,90,75]},
	# ── Diglett → Dugtrio ─────────────────────────────────────────────────────
	50: {"name":"Diglett",   "types":[8],    "evo_id":51,   "evo_lvl":26, "stats":[10,55,25,95,35,45]},
	51: {"name":"Dugtrio",   "types":[8],    "evo_id":null, "evo_lvl":0,  "stats":[35,100,50,120,50,70]},
	# ── Meowth → Persian ──────────────────────────────────────────────────────
	52: {"name":"Meowth",    "types":[0],    "evo_id":53,   "evo_lvl":28, "stats":[40,45,35,90,40,40]},
	53: {"name":"Persian",   "types":[0],    "evo_id":null, "evo_lvl":0,  "stats":[65,70,60,115,65,65]},
	# ── Psyduck → Golduck ─────────────────────────────────────────────────────
	54: {"name":"Psyduck",   "types":[2],    "evo_id":55,   "evo_lvl":33, "stats":[50,52,48,55,65,50]},
	55: {"name":"Golduck",   "types":[2],    "evo_id":null, "evo_lvl":0,  "stats":[80,82,78,85,95,80]},
	# ── Mankey → Primeape ─────────────────────────────────────────────────────
	56: {"name":"Mankey",    "types":[6],    "evo_id":57,   "evo_lvl":28, "stats":[40,80,35,70,35,45]},
	57: {"name":"Primeape",  "types":[6],    "evo_id":null, "evo_lvl":0,  "stats":[65,105,60,95,60,70]},
	# ── Growlithe → Arcanine ──────────────────────────────────────────────────
	58: {"name":"Growlithe", "types":[1],    "evo_id":59,   "evo_lvl":0,  "stats":[55,70,45,60,70,50]},
	59: {"name":"Arcanine",  "types":[1],    "evo_id":null, "evo_lvl":0,  "stats":[90,110,80,95,100,80]},
	# ── Poliwag → Poliwhirl → Poliwrath ───────────────────────────────────────
	60: {"name":"Poliwag",   "types":[2],    "evo_id":61,   "evo_lvl":25, "stats":[40,50,40,90,40,40]},
	61: {"name":"Poliwhirl", "types":[2],    "evo_id":62,   "evo_lvl":0,  "stats":[65,65,65,90,50,50]},
	62: {"name":"Poliwrath", "types":[2,6],  "evo_id":null, "evo_lvl":0,  "stats":[90,95,95,70,70,85]},
	# ── Abra → Kadabra → Alakazam ─────────────────────────────────────────────
	63: {"name":"Abra",      "types":[10],   "evo_id":64,   "evo_lvl":16, "stats":[25,20,15,90,105,55]},
	64: {"name":"Kadabra",   "types":[10],   "evo_id":65,   "evo_lvl":0,  "stats":[40,35,30,105,120,70]},
	65: {"name":"Alakazam",  "types":[10],   "evo_id":null, "evo_lvl":0,  "stats":[55,50,45,120,135,85]},
	# ── Machop → Machoke → Machamp ────────────────────────────────────────────
	66: {"name":"Machop",    "types":[6],    "evo_id":67,   "evo_lvl":28, "stats":[70,80,50,35,35,35]},
	67: {"name":"Machoke",   "types":[6],    "evo_id":68,   "evo_lvl":0,  "stats":[80,100,70,45,50,50]},
	68: {"name":"Machamp",   "types":[6],    "evo_id":null, "evo_lvl":0,  "stats":[90,130,80,55,65,65]},
	# ── Bellsprout → Weepinbell → Victreebel ──────────────────────────────────
	69: {"name":"Bellsprout","types":[4,7],  "evo_id":70,   "evo_lvl":21, "stats":[50,75,35,40,70,30]},
	70: {"name":"Weepinbell","types":[4,7],  "evo_id":71,   "evo_lvl":0,  "stats":[65,90,50,55,85,45]},
	71: {"name":"Victreebel","types":[4,7],  "evo_id":null, "evo_lvl":0,  "stats":[80,105,65,70,100,60]},
	# ── Tentacool → Tentacruel ────────────────────────────────────────────────
	72: {"name":"Tentacool", "types":[2,7],  "evo_id":73,   "evo_lvl":30, "stats":[40,40,35,70,50,100]},
	73: {"name":"Tentacruel","types":[2,7],  "evo_id":null, "evo_lvl":0,  "stats":[80,70,65,100,80,120]},
	# ── Geodude → Graveler → Golem ────────────────────────────────────────────
	74: {"name":"Geodude",   "types":[12,8], "evo_id":75,   "evo_lvl":25, "stats":[40,80,100,20,30,30]},
	75: {"name":"Graveler",  "types":[12,8], "evo_id":76,   "evo_lvl":0,  "stats":[55,95,115,35,45,45]},
	76: {"name":"Golem",     "types":[12,8], "evo_id":null, "evo_lvl":0,  "stats":[80,120,130,45,55,65]},
	# ── Ponyta → Rapidash ─────────────────────────────────────────────────────
	77: {"name":"Ponyta",    "types":[1],    "evo_id":78,   "evo_lvl":40, "stats":[50,85,55,90,65,65]},
	78: {"name":"Rapidash",  "types":[1],    "evo_id":null, "evo_lvl":0,  "stats":[65,100,70,105,80,80]},
	# ── Slowpoke → Slowbro ────────────────────────────────────────────────────
	79: {"name":"Slowpoke",  "types":[2,10], "evo_id":80,   "evo_lvl":37, "stats":[90,65,65,15,40,40]},
	80: {"name":"Slowbro",   "types":[2,10], "evo_id":null, "evo_lvl":0,  "stats":[95,75,110,30,100,80]},
	# ── Magnemite → Magneton ──────────────────────────────────────────────────
	81: {"name":"Magnemite", "types":[3,16], "evo_id":82,   "evo_lvl":30, "stats":[25,35,70,45,95,55]},
	82: {"name":"Magneton",  "types":[3,16], "evo_id":null, "evo_lvl":0,  "stats":[50,60,95,70,120,70]},
	# ── Doduo → Dodrio ────────────────────────────────────────────────────────
	84: {"name":"Doduo",     "types":[9,0],  "evo_id":85,   "evo_lvl":31, "stats":[35,85,45,75,35,35]},
	85: {"name":"Dodrio",    "types":[9,0],  "evo_id":null, "evo_lvl":0,  "stats":[60,110,70,100,60,60]},
	# ── Seel → Dewgong ────────────────────────────────────────────────────────
	86: {"name":"Seel",      "types":[2],    "evo_id":87,   "evo_lvl":34, "stats":[65,45,55,45,45,70]},
	87: {"name":"Dewgong",   "types":[2,5],  "evo_id":null, "evo_lvl":0,  "stats":[90,70,80,70,70,95]},
	# ── Grimer → Muk ──────────────────────────────────────────────────────────
	88: {"name":"Grimer",    "types":[7],    "evo_id":89,   "evo_lvl":38, "stats":[80,80,50,25,40,50]},
	89: {"name":"Muk",       "types":[7],    "evo_id":null, "evo_lvl":0,  "stats":[105,105,75,50,65,100]},
	# ── Shellder → Cloyster ───────────────────────────────────────────────────
	90: {"name":"Shellder",  "types":[2],    "evo_id":91,   "evo_lvl":0,  "stats":[30,65,100,40,45,25]},
	91: {"name":"Cloyster",  "types":[2,5],  "evo_id":null, "evo_lvl":0,  "stats":[50,95,180,70,85,45]},
	# ── Gastly → Haunter → Gengar ─────────────────────────────────────────────
	92: {"name":"Gastly",    "types":[13,7], "evo_id":93,   "evo_lvl":25, "stats":[30,35,30,80,100,35]},
	93: {"name":"Haunter",   "types":[13,7], "evo_id":94,   "evo_lvl":0,  "stats":[45,50,45,95,115,55]},
	94: {"name":"Gengar",    "types":[13,7], "evo_id":null, "evo_lvl":0,  "stats":[60,65,60,110,130,75]},
	# ── Onix ──────────────────────────────────────────────────────────────────
	95: {"name":"Onix",      "types":[12,8], "evo_id":null, "evo_lvl":0,  "stats":[35,45,160,70,30,45]},
	# ── Drowzee → Hypno ───────────────────────────────────────────────────────
	96: {"name":"Drowzee",   "types":[10],   "evo_id":97,   "evo_lvl":26, "stats":[60,48,45,42,43,90]},
	97: {"name":"Hypno",     "types":[10],   "evo_id":null, "evo_lvl":0,  "stats":[85,73,70,67,73,115]},
	# ── Krabby → Kingler ──────────────────────────────────────────────────────
	98: {"name":"Krabby",    "types":[2],    "evo_id":99,   "evo_lvl":28, "stats":[30,105,90,50,25,25]},
	99: {"name":"Kingler",   "types":[2],    "evo_id":null, "evo_lvl":0,  "stats":[55,130,115,75,50,50]},
	# ── Voltorb → Electrode ───────────────────────────────────────────────────
	100:{"name":"Voltorb",   "types":[3],    "evo_id":101,  "evo_lvl":30, "stats":[40,30,50,100,55,55]},
	101:{"name":"Electrode", "types":[3],    "evo_id":null, "evo_lvl":0,  "stats":[60,50,70,140,80,80]},
	# ── Exeggcute → Exeggutor ─────────────────────────────────────────────────
	102:{"name":"Exeggcute", "types":[4,10], "evo_id":103,  "evo_lvl":0,  "stats":[60,40,80,40,60,45]},
	103:{"name":"Exeggutor", "types":[4,10], "evo_id":null, "evo_lvl":0,  "stats":[95,95,85,55,125,65]},
	# ── Cubone → Marowak ──────────────────────────────────────────────────────
	104:{"name":"Cubone",    "types":[8],    "evo_id":105,  "evo_lvl":28, "stats":[50,50,95,35,40,60]},
	105:{"name":"Marowak",   "types":[8],    "evo_id":null, "evo_lvl":0,  "stats":[60,80,110,45,50,80]},
	# ── Hitmonlee ─────────────────────────────────────────────────────────────
	106:{"name":"Hitmonlee", "types":[6],    "evo_id":null, "evo_lvl":0,  "stats":[50,120,53,87,35,110]},
	# ── Hitmonchan ────────────────────────────────────────────────────────────
	107:{"name":"Hitmonchan","types":[6],    "evo_id":null, "evo_lvl":0,  "stats":[50,105,79,76,35,110]},
	# ── Lickitung ─────────────────────────────────────────────────────────────
	108:{"name":"Lickitung", "types":[0],    "evo_id":null, "evo_lvl":0,  "stats":[90,55,75,30,60,75]},
	# ── Koffing → Weezing ─────────────────────────────────────────────────────
	109:{"name":"Koffing",   "types":[7],    "evo_id":110,  "evo_lvl":35, "stats":[40,65,95,35,60,45]},
	110:{"name":"Weezing",   "types":[7],    "evo_id":null, "evo_lvl":0,  "stats":[65,90,120,60,85,70]},
	# ── Rhyhorn → Rhydon ──────────────────────────────────────────────────────
	111:{"name":"Rhyhorn",   "types":[12,8], "evo_id":112,  "evo_lvl":42, "stats":[80,85,95,25,30,30]},
	112:{"name":"Rhydon",    "types":[12,8], "evo_id":null, "evo_lvl":0,  "stats":[105,130,120,40,45,45]},
	# ── Chansey ───────────────────────────────────────────────────────────────
	113:{"name":"Chansey",   "types":[0],    "evo_id":null, "evo_lvl":0,  "stats":[250,5,5,50,35,105]},
	# ── Tangela ───────────────────────────────────────────────────────────────
	114:{"name":"Tangela",   "types":[4],    "evo_id":null, "evo_lvl":0,  "stats":[65,55,115,60,100,40]},
	# ── Kangaskhan ────────────────────────────────────────────────────────────
	115:{"name":"Kangaskhan","types":[0],    "evo_id":null, "evo_lvl":0,  "stats":[105,95,80,90,40,45]},
	# ── Horsea → Seadra ───────────────────────────────────────────────────────
	116:{"name":"Horsea",    "types":[2],    "evo_id":117,  "evo_lvl":32, "stats":[30,40,70,60,70,25]},
	117:{"name":"Seadra",    "types":[2],    "evo_id":null, "evo_lvl":0,  "stats":[55,65,95,85,95,45]},
	# ── Goldeen → Seaking ─────────────────────────────────────────────────────
	118:{"name":"Goldeen",   "types":[2],    "evo_id":119,  "evo_lvl":33, "stats":[45,67,60,63,35,50]},
	119:{"name":"Seaking",   "types":[2],    "evo_id":null, "evo_lvl":0,  "stats":[80,92,65,68,65,80]},
	# ── Staryu → Starmie ──────────────────────────────────────────────────────
	120:{"name":"Staryu",    "types":[2],    "evo_id":121,  "evo_lvl":0,  "stats":[30,45,55,85,70,70]},
	121:{"name":"Starmie",   "types":[2,10], "evo_id":null, "evo_lvl":0,  "stats":[60,75,85,115,100,100]},
	# ── Mr. Mime ──────────────────────────────────────────────────────────────
	122:{"name":"Mr. Mime",  "types":[10,17],"evo_id":null, "evo_lvl":0,  "stats":[40,45,65,90,100,120]},
	# ── Scyther ───────────────────────────────────────────────────────────────
	123:{"name":"Scyther",   "types":[11,9], "evo_id":null, "evo_lvl":0,  "stats":[70,110,80,105,55,80]},
	# ── Jynx ──────────────────────────────────────────────────────────────────
	124:{"name":"Jynx",      "types":[5,10], "evo_id":null, "evo_lvl":0,  "stats":[65,50,35,95,115,95]},
	# ── Electabuzz ────────────────────────────────────────────────────────────
	125:{"name":"Electabuzz","types":[3],    "evo_id":null, "evo_lvl":0,  "stats":[65,83,57,105,95,85]},
	# ── Magmar ────────────────────────────────────────────────────────────────
	126:{"name":"Magmar",    "types":[1],    "evo_id":null, "evo_lvl":0,  "stats":[65,95,57,93,100,85]},
	# ── Pinsir ────────────────────────────────────────────────────────────────
	127:{"name":"Pinsir",    "types":[11],   "evo_id":null, "evo_lvl":0,  "stats":[65,125,100,85,55,70]},
	# ── Tauros ────────────────────────────────────────────────────────────────
	128:{"name":"Tauros",    "types":[0],    "evo_id":null, "evo_lvl":0,  "stats":[75,100,95,110,40,70]},
	# ── Magikarp → Gyarados ───────────────────────────────────────────────────
	129:{"name":"Magikarp",  "types":[2],    "evo_id":130,  "evo_lvl":20, "stats":[20,10,55,80,15,20]},
	130:{"name":"Gyarados",  "types":[2,9],  "evo_id":null, "evo_lvl":0,  "stats":[95,125,79,81,60,100]},
	# ── Lapras ────────────────────────────────────────────────────────────────
	131:{"name":"Lapras",    "types":[2,5],  "evo_id":null, "evo_lvl":0,  "stats":[130,85,80,60,85,95]},
	# ── Ditto ─────────────────────────────────────────────────────────────────
	132:{"name":"Ditto",     "types":[0],    "evo_id":null, "evo_lvl":0,  "stats":[48,48,48,48,48,48]},
	# ── Eevee → Vaporeon/Jolteon/Flareon ──────────────────────────────────────
	133:{"name":"Eevee",     "types":[0],    "evo_id":null, "evo_lvl":0,  "stats":[55,55,50,55,45,65]},
	134:{"name":"Vaporeon",  "types":[2],    "evo_id":null, "evo_lvl":0,  "stats":[130,65,60,65,110,95]},
	135:{"name":"Jolteon",   "types":[3],    "evo_id":null, "evo_lvl":0,  "stats":[65,65,60,130,110,95]},
	136:{"name":"Flareon",   "types":[1],    "evo_id":null, "evo_lvl":0,  "stats":[65,130,60,65,95,110]},
	# ── Porygon ───────────────────────────────────────────────────────────────
	137:{"name":"Porygon",   "types":[0],    "evo_id":null, "evo_lvl":0,  "stats":[65,60,70,40,85,75]},
	# ── Omanyte → Omastar ─────────────────────────────────────────────────────
	138:{"name":"Omanyte",   "types":[12,2], "evo_id":139,  "evo_lvl":40, "stats":[35,40,100,35,90,55]},
	139:{"name":"Omastar",   "types":[12,2], "evo_id":null, "evo_lvl":0,  "stats":[70,60,125,55,115,70]},
	# ── Kabuto → Kabutops ─────────────────────────────────────────────────────
	140:{"name":"Kabuto",    "types":[12,2], "evo_id":141,  "evo_lvl":40, "stats":[30,80,90,55,55,45]},
	141:{"name":"Kabutops",  "types":[12,2], "evo_id":null, "evo_lvl":0,  "stats":[60,115,105,80,65,70]},
	# ── Aerodactyl ────────────────────────────────────────────────────────────
	142:{"name":"Aerodactyl","types":[12,9], "evo_id":null, "evo_lvl":0,  "stats":[80,105,65,130,60,75]},
	# ── Snorlax ───────────────────────────────────────────────────────────────
	143:{"name":"Snorlax",   "types":[0],    "evo_id":null, "evo_lvl":0,  "stats":[160,110,65,30,65,110]},
	# ── Articuno / Zapdos / Moltres / Mewtwo / Mew ────────────────────────────
	144:{"name":"Articuno",  "types":[5,9],  "evo_id":null, "evo_lvl":0,  "stats":[90,85,100,85,95,125]},
	145:{"name":"Zapdos",    "types":[3,9],  "evo_id":null, "evo_lvl":0,  "stats":[90,90,85,100,125,90]},
	146:{"name":"Moltres",   "types":[1,9],  "evo_id":null, "evo_lvl":0,  "stats":[90,100,90,90,125,85]},
	150:{"name":"Mewtwo",    "types":[10],   "evo_id":null, "evo_lvl":0,  "stats":[106,110,90,130,154,90]},
	151:{"name":"Mew",       "types":[10],   "evo_id":null, "evo_lvl":0,  "stats":[100,100,100,100,100,100]},
}

func _ready() -> void:
	_initialize_pokemon()

## Inicializa el Pokémon cargando sus datos desde POKEDEX
func _initialize_pokemon() -> void:
	var data := POKEDEX.get(pokedex_id, {}) as Dictionary
	if not data.is_empty():
		species_name    = data["name"]
		types           = (data["types"] as Array).map(func(t): return t as int)
		evolution_id    = data["evo_id"]
		evolution_level = data["evo_lvl"]
		if not stats:
			var s: Array = data["stats"]
			stats = PokemonStats.create(s[0], s[1], s[2], s[3], s[4], s[5])
	else:
		evolution_id    = null
		evolution_level = 0
		if not stats:
			stats = PokemonStats.create(50, 50, 50, 50, 50, 50)

	# 1. Recalcular las stats al nivel actual
	stats.recalculate(level)

	# 2. Configurar Habilidad por ID
	ability = Ability.create(ability_id)

	# 3. Configurar Ataques por ID
	moves.clear()
	for m_id in move_ids:
		moves.append(Move.create_by_id(m_id))

	# 4. Reproducir animación idle si existe
	if animated_sprite and animated_sprite.has_method("play"):
		animated_sprite.play("idle")

## Comprueba si el Pokémon puede evolucionar al nivel actual y lo hace.
## Devuelve true si evolucionó.
func check_evolution() -> bool:
	if evolution_id == null:
		return false
	if evolution_level <= 0:
		return false
	if level < evolution_level:
		return false
	# Verificar si el objeto equipado impide la evolución
	if held_item_id > 0:
		var item_data = ItemRegistry.get_item(held_item_id)
		if item_data and item_data.prevents_evolution:
			return false
	evolve()
	return true

## Fuerza la evolución inmediata al siguiente Pokémon de la línea.
func evolve() -> void:
	if evolution_id == null:
		return
	var old_id := pokedex_id
	pokedex_id = evolution_id as int
	stats = null  # Forzar recarga de stats
	_initialize_pokemon()
	evolved.emit(old_id, pokedex_id)

## Sube un nivel, recalcula stats y comprueba si evoluciona.
## Devuelve true si hubo evolución.
func level_up() -> bool:
	level += 1
	recalculate_stats()
	return check_evolution()

## Recalcula todas las estadísticas según el nivel actual.
## Preserva el HP: si el HP Máximo sube, la diferencia se suma al HP Actual.
func recalculate_stats() -> void:
	if stats:
		stats.recalculate(level)

## Delegación de daño a stats
func take_damage(amount: int) -> bool:
	if stats:
		return stats.take_damage(amount)
	return false

## ── Serialización ─────────────────────────────────────────────────────────────
func to_dictionary() -> Dictionary:
	return {
		"pokedex_id": pokedex_id,
		"name": species_name,
		"types": types.duplicate(),
		"level": level,
		"evo_id": evolution_id,
		"evo_lvl": evolution_level,
		"current_hp": stats.hp_current if stats else -1,
		"move_ids": move_ids.duplicate(),
		"ability_id": ability_id,
		"held_item_id": held_item_id,
	}

static func from_dictionary(dict: Dictionary) -> Pokemon:
	var p := Pokemon.new()
	p.pokedex_id = dict.get("pokedex_id", 1)
	p.level = dict.get("level", 5)
	p.move_ids = dict.get("move_ids", [1]) as Array[int]
	p.ability_id = dict.get("ability_id", 1)
	p.held_item_id = dict.get("held_item_id", 0)
	p.status = dict.get("status", Status.NONE)
	return p

## ¿El Pokémon puede evolucionar (tiene evolución por nivel)?
func can_evolve_by_level() -> bool:
	return evolution_id != null and evolution_level > 0

## Nivel de evolución formateado para mostrar en UI (0 = sin evolución por nivel)
func evolution_level_display() -> String:
	if not can_evolve_by_level():
		return "Sin evolución"
	return "Nivel %d → %s" % [evolution_level, POKEDEX.get(evolution_id as int, {}).get("name", "?")]
