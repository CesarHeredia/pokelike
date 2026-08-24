# res://scripts/core/enums.gd
# Autoload singleton: "Enums"
# Contiene todos los enums globales del juego.
extends Node

## Los 18 tipos de Pokémon en orden canónico.
## Se usa como índice numérico en TypeChart.
enum PokemonType {
	NORMAL    = 0,
	FIRE      = 1,
	WATER     = 2,
	ELECTRIC  = 3,
	GRASS     = 4,
	ICE       = 5,
	FIGHTING  = 6,
	POISON    = 7,
	GROUND    = 8,
	FLYING    = 9,
	PSYCHIC   = 10,
	BUG       = 11,
	ROCK      = 12,
	GHOST     = 13,
	DRAGON    = 14,
	DARK      = 15,
	STEEL     = 16,
	FAIRY     = 17,
}

## Devuelve el nombre legible de un tipo.
func type_name(t: int) -> String:
	match t:
		PokemonType.NORMAL:   return "Normal"
		PokemonType.FIRE:     return "Fuego"
		PokemonType.WATER:    return "Agua"
		PokemonType.ELECTRIC: return "Eléctrico"
		PokemonType.GRASS:    return "Planta"
		PokemonType.ICE:      return "Hielo"
		PokemonType.FIGHTING: return "Lucha"
		PokemonType.POISON:   return "Veneno"
		PokemonType.GROUND:   return "Tierra"
		PokemonType.FLYING:   return "Volador"
		PokemonType.PSYCHIC:  return "Psíquico"
		PokemonType.BUG:      return "Bicho"
		PokemonType.ROCK:     return "Roca"
		PokemonType.GHOST:    return "Fantasma"
		PokemonType.DRAGON:   return "Dragón"
		PokemonType.DARK:     return "Siniestro"
		PokemonType.STEEL:    return "Acero"
		PokemonType.FAIRY:    return "Hada"
	return "???"

## Color representativo de cada tipo (para UI).
func type_color(t: int) -> Color:
	match t:
		PokemonType.NORMAL:   return Color("A8A878")
		PokemonType.FIRE:     return Color("F08030")
		PokemonType.WATER:    return Color("6890F0")
		PokemonType.ELECTRIC: return Color("F8D030")
		PokemonType.GRASS:    return Color("78C850")
		PokemonType.ICE:      return Color("98D8D8")
		PokemonType.FIGHTING: return Color("C03028")
		PokemonType.POISON:   return Color("A040A0")
		PokemonType.GROUND:   return Color("E0C068")
		PokemonType.FLYING:   return Color("A890F0")
		PokemonType.PSYCHIC:  return Color("F85888")
		PokemonType.BUG:      return Color("A8B820")
		PokemonType.ROCK:     return Color("B8A038")
		PokemonType.GHOST:    return Color("705898")
		PokemonType.DRAGON:   return Color("7038F8")
		PokemonType.DARK:     return Color("705848")
		PokemonType.STEEL:    return Color("B8B8D0")
		PokemonType.FAIRY:    return Color("EE99AC")
	return Color("888888")
