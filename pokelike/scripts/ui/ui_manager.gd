# res://scripts/ui/ui_manager.gd
@warning_ignore("unused_signal")
extends Node

## Signal emitted when changing active mobile UI screen
signal screen_changed(screen_name: String)
signal player_stats_updated(level: int, gold: int, gems: int, energy: int)
signal show_notification(message: String, is_success: bool)

# Global trainer state for header display
var trainer_name: String = "Entrenador Red"
var trainer_title: String = "Campeón de la Liga"
var gym_badges: int = 8
var pokedex_count: int = 151
var pokedollars: int = 24500
var energy_current: int = 90
var energy_max: int = 100

# Retro Pokémon Type Colors (GBA Palette)
const TYPE_COLORS: Dictionary = {
	"NORMAL": Color("a8a878"),
	"FUEGO": Color("f08030"),
	"AGUA": Color("6890f0"),
	"PLANTA": Color("78c850"),
	"ELÉCTRICO": Color("f8d030"),
	"HIELO": Color("98d8d8"),
	"LUCHA": Color("c03028"),
	"VENENO": Color("a040a0"),
	"TIERRA": Color("e0c068"),
	"VOLADOR": Color("a890f0"),
	"PSIQUICO": Color("f85888"),
	"BICHO": Color("a8b820"),
	"ROCA": Color("b8a038"),
	"FANTASMA": Color("705898"),
	"DRAGÓN": Color("7038f8"),
	"SINIESTRO": Color("705848"),
	"ACERO": Color("b8b8d0"),
	"HADA": Color("ee99ac")
}

# Pixel Art StyleBox Generator with crisp borders & sharp pixel shadows
static func create_pixel_stylebox(
	bg_color: Color = Color("182030"), 
	border_color: Color = Color("e8e8e0"), 
	corner_radius: int = 4,
	border_width: int = 3
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	style.content_margin_left = 10
	style.content_margin_top = 10
	style.content_margin_right = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color("05080e")
	style.shadow_size = 0
	style.shadow_offset = Vector2(4, 4)
	return style

# Retro Classic Pokemon Text Frame StyleBox (Cream White BG, Dark Slate Border)
static func create_pokemon_text_frame() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("f8f8f0")
	style.border_color = Color("202840")
	style.set_border_width_all(4)
	style.set_corner_radius_all(4)
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	style.shadow_color = Color("101420")
	style.shadow_size = 0
	style.shadow_offset = Vector2(4, 4)
	return style

# Touch bounce animation
static func add_touch_animation(node: Control) -> void:
	if not node:
		return
	node.pivot_offset = node.size / 2.0
	node.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton or event is InputEventScreenTouch:
			if event.is_pressed():
				var tween := node.create_tween()
				tween.tween_property(node, "scale", Vector2(0.96, 0.96), 0.06)
			else:
				var tween := node.create_tween()
				tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.08)
	)
