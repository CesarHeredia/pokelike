# res://scripts/ui/battle_tower_ui.gd
@warning_ignore("unused_signal")
extends Control

signal start_battle(mode_name: String, details: Dictionary)
signal back_pressed()

@onready var panel_main: PanelContainer = $Scroll/VBox/PanelMain
@onready var btn_back: Button = $Header/BtnBack
@onready var btn_challenge: Button = $Scroll/VBox/PanelMain/Margin/VBox/BtnChallenge

func _ready() -> void:
	if btn_back:
		btn_back.pressed.connect(func(): back_pressed.emit())
	if btn_challenge:
		btn_challenge.pressed.connect(func():
			start_battle.emit("TORRE", {
				"chapter": "Cúpula Élite - Piso 28",
				"enemy_name": "Guardián del Piso 28",
				"enemy_pokemon": "Mewtwo Lv.52",
				"bg_color": Color("221430")
			})
		)
	_apply_styles()

func _apply_styles() -> void:
	if panel_main:
		panel_main.add_theme_stylebox_override("panel", UIManager.create_pixel_stylebox(
			Color("221430"), Color("9850e0"), 4, 3
		))
	if btn_challenge:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("7830c0")
		style.border_color = Color("f8f8f0")
		style.set_border_width_all(3)
		style.set_corner_radius_all(4)
		style.content_margin_top = 12
		style.content_margin_bottom = 12
		btn_challenge.add_theme_stylebox_override("normal", style)
		btn_challenge.add_theme_font_size_override("font_size", 16)
