# res://scripts/ui/colosseum_mode_ui.gd
@warning_ignore("unused_signal")
extends Control

signal start_battle(mode_name: String, details: Dictionary)
signal back_pressed()

@onready var panel_main: PanelContainer = $Scroll/VBox/PanelMain
@onready var btn_back: Button = $Header/BtnBack
@onready var btn_search: Button = $Scroll/VBox/PanelMain/Margin/VBox/BtnSearch
@onready var lbl_status: Label = $Scroll/VBox/PanelMain/Margin/VBox/LblStatus

var is_searching: bool = false

func _ready() -> void:
	if btn_back:
		btn_back.pressed.connect(func(): back_pressed.emit())
	if btn_search:
		btn_search.pressed.connect(_on_search_pressed)
	_apply_styles()

func _apply_styles() -> void:
	if panel_main:
		panel_main.add_theme_stylebox_override("panel", UIManager.create_pixel_stylebox(
			Color("2c141a"), Color("e04040"), 4, 3
		))
	if btn_search:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("c83030")
		style.border_color = Color("f8f8f0")
		style.set_border_width_all(3)
		style.set_corner_radius_all(4)
		style.content_margin_top = 12
		style.content_margin_bottom = 12
		btn_search.add_theme_stylebox_override("normal", style)
		btn_search.add_theme_font_size_override("font_size", 16)

func _on_search_pressed() -> void:
	if is_searching:
		return
	is_searching = true
	btn_search.text = "🔍 BUSCANDO RIVAL EN EL COLISEO..."
	if lbl_status:
		lbl_status.text = "Emparejando con entrenador de rango similar..."
	
	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(func():
		is_searching = false
		btn_search.text = "⚔️ ¡RIVAL ENCONTRADO! ENTRAR A COMBATE"
		start_battle.emit("COLISEO", {
			"chapter": "Frente Batalla - PVP",
			"enemy_name": "Maestro Ash",
			"enemy_pokemon": "Charizard Lv.50",
			"bg_color": Color("2c141a")
		})
	)
