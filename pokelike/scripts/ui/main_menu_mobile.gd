# res://scripts/ui/main_menu_mobile.gd
@warning_ignore("unused_signal")
extends Control

signal mode_selected(mode_name: String)

@onready var card_historia: Button = $ScrollContainer/VBoxContainer/CardHistoria
@onready var card_coliseo: Button = $ScrollContainer/VBoxContainer/CardColiseo
@onready var card_torre: Button = $ScrollContainer/VBoxContainer/CardTorre

func _ready() -> void:
	_apply_styles()
	_connect_signals()

func _apply_styles() -> void:
	# Card Historia (Emerald / Green GBA Style)
	_style_card_button(card_historia, Color("10241a"), Color("40b870"))
	# Card Coliseo (Crimson / Red GBA Style)
	_style_card_button(card_coliseo, Color("2c141a"), Color("e04040"))
	# Card Torre Batalla (Purple / GBA Style)
	_style_card_button(card_torre, Color("221430"), Color("9850e0"))

func _style_card_button(btn: Button, bg_color: Color, border_color: Color) -> void:
	if not btn:
		return
	
	var style_normal := UIManager.create_pixel_stylebox(bg_color, border_color, 4, 3)
	var style_hover := UIManager.create_pixel_stylebox(bg_color.lightened(0.1), border_color.lightened(0.2), 4, 3)
	var style_pressed := UIManager.create_pixel_stylebox(bg_color.darkened(0.1), border_color, 4, 3)

	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_stylebox_override("focus", style_hover)

	UIManager.add_touch_animation(btn)

func _connect_signals() -> void:
	if card_historia:
		card_historia.pressed.connect(func(): mode_selected.emit("HISTORIA"))
	if card_coliseo:
		card_coliseo.pressed.connect(func(): mode_selected.emit("COLISEO"))
	if card_torre:
		card_torre.pressed.connect(func(): mode_selected.emit("TORRE"))
