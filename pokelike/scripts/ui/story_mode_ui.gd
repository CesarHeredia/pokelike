# res://scripts/ui/story_mode_ui.gd
@warning_ignore("unused_signal")
extends Control

signal start_battle(mode_name: String, details: Dictionary)
signal back_pressed()

@onready var btn_back: Button = $Header/BtnBack
@onready var container_gens: VBoxContainer = $Scroll/VBoxContainer/GensContainer

# 9 Pokemon Generations Data
const GENERATIONS: Array[Dictionary] = [
	{
		"gen": 1,
		"name": "1ª GENERACIÓN: KANTO",
		"region": "Pueblo Paleta • Liga Kanto",
		"desc": "Comienza tu viaje con Bulbasaur, Charmander o Squirtle y desafía a los 8 Líderes de Kanto.",
		"is_unlocked": true,
		"color": Color("27ae60"),
		"border": Color("40b870"),
		"enemy": "Rival Gary (Blastoise Lv.45)"
	},
	{
		"gen": 2,
		"name": "2ª GENERACIÓN: JOHTO",
		"region": "Pueblo Primavera • Liga Johto",
		"desc": "Explora Johto y se el campeón frente a Lance en la Liga Pokémon.",
		"is_unlocked": false,
		"color": Color("2c141a"),
		"border": Color("445060"),
		"enemy": "Entrenador Rojo (Pikachu Lv.80)"
	},
	{
		"gen": 3,
		"name": "3ª GENERACIÓN: HOENN",
		"region": "Villa Raíz • Liga Hoenn",
		"desc": "Enfréntate al Equipo Magma y Equipo Aqua por la región de Hoenn.",
		"is_unlocked": false,
		"color": Color("2c141a"),
		"border": Color("445060"),
		"enemy": "Campeón Máximo (Metagross Lv.58)"
	},
	{
		"gen": 4,
		"name": "4ª GENERACIÓN: SINNOH",
		"region": "Pueblo Hojaverde • Liga Sinnoh",
		"desc": "Viaja por el Monte Corona y enfréntate a la Campeona Cintia.",
		"is_unlocked": false,
		"color": Color("2c141a"),
		"border": Color("445060"),
		"enemy": "Campeona Cintia (Garchomp Lv.66)"
	},
	{
		"gen": 5,
		"name": "5ª GENERACIÓN: TESELIA",
		"region": "Pueblo Arcilla • Liga Teselia",
		"desc": "Detén los planes del Equipo Plasma y la utopía de N.",
		"is_unlocked": false,
		"color": Color("2c141a"),
		"border": Color("445060"),
		"enemy": "N (Reshiram/Zekrom Lv.52)"
	},
	{
		"gen": 6,
		"name": "6ª GENERACIÓN: KALOS",
		"region": "Pueblo Boceto • Liga Kalos",
		"desc": "Descubre el secreto de la Megaevolución en la región de Kalos.",
		"is_unlocked": false,
		"color": Color("2c141a"),
		"border": Color("445060"),
		"enemy": "Dianta (Gardevoir Lv.68)"
	},
	{
		"gen": 7,
		"name": "7ª GENERACIÓN: ALOLA",
		"region": "Pueblo Tuki • Recorrido Insular",
		"desc": "Supera las Pruebas de los Capitanes y los Pokémon Dominantes.",
		"is_unlocked": false,
		"color": Color("2c141a"),
		"border": Color("445060"),
		"enemy": "Profesor Kukui (Incineror Lv.65)"
	},
	{
		"gen": 8,
		"name": "8ª GENERACIÓN: GALAR",
		"region": "Pueblo Yarda • Liga Galar",
		"desc": "Compite en los grandes estadios con el fenómeno Dinamax.",
		"is_unlocked": false,
		"color": Color("2c141a"),
		"border": Color("445060"),
		"enemy": "Campeón Lionel (Charizard Lv.70)"
	},
	{
		"gen": 9,
		"name": "9ª GENERACIÓN: PALDEA",
		"region": "Cabo Poco • Academia Naranja",
		"desc": "Embárcate en la Búsqueda del Tesoro y el fenómeno Teracristalización.",
		"is_unlocked": false,
		"color": Color("2c141a"),
		"border": Color("445060"),
		"enemy": "Supercampeona Sagi (Glimmora Lv.66)"
	}
]

func _ready() -> void:
	if btn_back:
		btn_back.pressed.connect(func(): back_pressed.emit())
	_build_generation_cards()

func _build_generation_cards() -> void:
	if not container_gens:
		return
	
	for child in container_gens.get_children():
		child.queue_free()

	for gen_data in GENERATIONS:
		# Full-Card Button for Touch Usability
		var card_btn := Button.new()
		card_btn.custom_minimum_size = Vector2(0, 140)
		card_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var margin := MarginContainer.new()
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin.add_theme_constant_override("margin_left", 14)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 14)
		margin.add_theme_constant_override("margin_bottom", 12)
		card_btn.add_child(margin)

		var vbox := VBoxContainer.new()
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_theme_constant_override("separation", 6)
		margin.add_child(vbox)

		# Header HBox (Icon + Title)
		var hbox := HBoxContainer.new()
		hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(hbox)

		var lbl_icon := Label.new()
		lbl_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl_icon.add_theme_font_size_override("font_size", 24)
		lbl_icon.text = "🟢" if gen_data.is_unlocked else "🔒"
		hbox.add_child(lbl_icon)

		var title_vbox := VBoxContainer.new()
		title_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(title_vbox)

		var lbl_title := Label.new()
		lbl_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl_title.text = gen_data.name
		lbl_title.add_theme_font_size_override("font_size", 16)
		lbl_title.add_theme_color_override("font_color", Color("ffffff") if gen_data.is_unlocked else Color("88909a"))
		title_vbox.add_child(lbl_title)

		var lbl_region := Label.new()
		lbl_region.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl_region.text = gen_data.region
		lbl_region.add_theme_font_size_override("font_size", 12)
		lbl_region.add_theme_color_override("font_color", Color("46e09e") if gen_data.is_unlocked else Color("66707c"))
		title_vbox.add_child(lbl_region)

		# Description
		var lbl_desc := Label.new()
		lbl_desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl_desc.text = gen_data.desc
		lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_desc.add_theme_font_size_override("font_size", 12)
		lbl_desc.add_theme_color_override("font_color", Color("a0a8b4") if gen_data.is_unlocked else Color("55606d"))
		vbox.add_child(lbl_desc)

		# Status Footer
		var lbl_footer := Label.new()
		lbl_footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl_footer.add_theme_font_size_override("font_size", 13)

		if gen_data.is_unlocked:
			var bg := Color("10241a")
			var border := Color("40b870")
			var style_norm := UIManager.create_pixel_stylebox(bg, border, 4, 3)
			var style_hov := UIManager.create_pixel_stylebox(bg.lightened(0.1), border.lightened(0.2), 4, 3)
			card_btn.add_theme_stylebox_override("normal", style_norm)
			card_btn.add_theme_stylebox_override("hover", style_hov)
			card_btn.add_theme_stylebox_override("pressed", style_norm)
			
			lbl_footer.text = "🔴 TOCA PARA ENTRAR A KANTO ➔"
			lbl_footer.add_theme_color_override("font_color", Color("40b870"))
			
			UIManager.add_touch_animation(card_btn)
			card_btn.pressed.connect(func():
				start_battle.emit("HISTORIA", {
					"chapter": gen_data.name + " (" + gen_data.region + ")",
					"enemy_name": "Rival Gary",
					"enemy_pokemon": gen_data.enemy,
					"bg_color": Color("10241a")
				})
			)
		else:
			var bg := Color("141820")
			var border := Color("333d4a")
			var style_locked := UIManager.create_pixel_stylebox(bg, border, 4, 2)
			card_btn.add_theme_stylebox_override("normal", style_locked)
			card_btn.add_theme_stylebox_override("hover", style_locked)
			card_btn.add_theme_stylebox_override("pressed", style_locked)

			lbl_footer.text = "🔒 BLOQUEADO (Completa la Generación anterior)"
			lbl_footer.add_theme_color_override("font_color", Color("778290"))
			card_btn.pressed.connect(func():
				print("[UI]: 🔒 Esta generación se desbloqueará al completar la anterior.")
			)

		vbox.add_child(lbl_footer)
		container_gens.add_child(card_btn)
