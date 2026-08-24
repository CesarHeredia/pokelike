# res://scripts/ui/starter_selection.gd
extends Control

signal starter_chosen(pokemon_name: String)
signal back_pressed()

const STARTERS: Array[Dictionary] = [
	{
		"name": "BULBASAUR",
		"sprite": "res://assets/sprites/pokemon/pokemon izquierda/BULBASAUR.png",
		"frame_size": 38,
		"frame_count": 99,
		"type": "PLANTA",
		"type_icons": [
			"res://assets/sprites/tipos/Grass type.png",
		],
		"type_color": Color("4CAF50"),
		"desc": "Un Pokémon extraño que lleva una semilla en su espalda.",
		"bg": Color("1a2e1a"),
		"border": Color("4CAF50"),
		"num": "#001",
		"ability": "Espesura",
		"stats": {"HP": 45, "ATK": 49, "DEF": 49, "SPE": 45, "SPA": 65, "SPD": 65},
	},
	{
		"name": "CHARMANDER",
		"sprite": "res://assets/sprites/pokemon/pokemon izquierda/CHARMANDER.png",
		"frame_size": 42,
		"frame_count": 107,
		"type": "FUEGO",
		"type_icons": ["res://assets/sprites/tipos/Fire type.png"],
		"type_color": Color("FF6D00"),
		"desc": "La llama de su cola indica su estado de salud y ánimo.",
		"bg": Color("2e1a0a"),
		"border": Color("FF6D00"),
		"num": "#004",
		"ability": "Mar de Llamas",
		"stats": { "HP": 39, "ATK": 52, "DEF": 43, "SPA": 60, "SPD": 50, "SPE": 65 },
	},
	{
		"name": "SQUIRTLE",
		"sprite": "res://assets/sprites/pokemon/pokemon izquierda/SQUIRTLE.png",
		"frame_size": 43,
		"frame_count": 51,
		"type": "AGUA",
		"type_icons": ["res://assets/sprites/tipos/Water type.png"],
		"type_color": Color("29B6F6"),
		"desc": "Usa su dura concha para esconderse y lanzar chorros de agua.",
		"bg": Color("0a1e2e"),
		"border": Color("29B6F6"),
		"num": "#007",
		"ability": "Torrente",
		"stats": { "HP": 44, "ATK": 48, "DEF": 65, "SPA": 50, "SPD": 64, "SPE": 43 },
	},
]

var _current_index: int = 0
var _details_container: MarginContainer
var _roster_container: VBoxContainer
var _timers: Array[Timer] = []


func _ready() -> void:
	_build_ui()
	_update_details(_current_index)


func _build_ui() -> void:
	# Root fills viewport
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Dark BG
	var bg := ColorRect.new()
	bg.color = Color("0a0e14")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Outer VBox
	var outer := VBoxContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("separation", 0)
	add_child(outer)

	# Header
	var header := PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 60)
	var hdr_style := StyleBoxFlat.new()
	hdr_style.bg_color = Color("0d1117")
	hdr_style.set_border_width_all(0)
	hdr_style.border_color = Color("f1c40f")
	hdr_style.border_width_bottom = 2
	header.add_theme_stylebox_override("panel", hdr_style)
	outer.add_child(header)

	var hdr_margin := MarginContainer.new()
	hdr_margin.add_theme_constant_override("margin_left", 12)
	hdr_margin.add_theme_constant_override("margin_right", 12)
	header.add_child(hdr_margin)

	var hdr_hbox := HBoxContainer.new()
	hdr_hbox.add_theme_constant_override("separation", 10)
	hdr_margin.add_child(hdr_hbox)

	# Back / Random button
	var btn_back := Button.new()
	btn_back.text = "🎲 AZAR / ATRÁS"
	btn_back.custom_minimum_size = Vector2(110, 36)
	btn_back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn_back.add_theme_font_size_override("font_size", 11)
	btn_back.add_theme_color_override("font_color", Color("f1c40f"))
	var back_style := StyleBoxFlat.new()
	back_style.bg_color = Color("1a1f28")
	back_style.set_border_width_all(1)
	back_style.border_color = Color("f1c40f")
	back_style.set_corner_radius_all(4)
	btn_back.add_theme_stylebox_override("normal", back_style)
	btn_back.pressed.connect(
		func():
			var random_starter: String = String(STARTERS[randi() % STARTERS.size()]["name"])
			starter_chosen.emit(random_starter)
	)
	hdr_hbox.add_child(btn_back)

	# Title
	var lbl_title := Label.new()
	lbl_title.text = "ELIGE TU COMPAÑERO"
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 18)
	lbl_title.add_theme_color_override("font_color", Color("f1c40f"))
	hdr_hbox.add_child(lbl_title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(80, 0)
	hdr_hbox.add_child(spacer)

	# Split Content
	var content_margin := MarginContainer.new()
	content_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_margin.add_theme_constant_override("margin_left", 8)
	content_margin.add_theme_constant_override("margin_right", 8)
	content_margin.add_theme_constant_override("margin_top", 12)
	content_margin.add_theme_constant_override("margin_bottom", 12)
	outer.add_child(content_margin)

	var split_hbox := HBoxContainer.new()
	split_hbox.add_theme_constant_override("separation", 12)
	content_margin.add_child(split_hbox)

	# Left Column: Details
	var details_panel := PanelContainer.new()
	details_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_panel.size_flags_stretch_ratio = 2.0
	var detail_style := StyleBoxFlat.new()
	detail_style.bg_color = Color("11161d")
	detail_style.set_corner_radius_all(8)
	detail_style.set_border_width_all(2)
	detail_style.border_color = Color("2c3e50")
	details_panel.add_theme_stylebox_override("panel", detail_style)
	split_hbox.add_child(details_panel)

	_details_container = MarginContainer.new()
	_details_container.add_theme_constant_override("margin_left", 12)
	_details_container.add_theme_constant_override("margin_right", 12)
	_details_container.add_theme_constant_override("margin_top", 12)
	_details_container.add_theme_constant_override("margin_bottom", 12)
	details_panel.add_child(_details_container)

	# Right Column: Roster
	var roster_panel := PanelContainer.new()
	roster_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_panel.size_flags_stretch_ratio = 1.0
	var roster_style := StyleBoxFlat.new()
	roster_style.bg_color = Color("11161d")
	roster_style.set_corner_radius_all(8)
	roster_style.set_border_width_all(2)
	roster_style.border_color = Color("2c3e50")
	roster_panel.add_theme_stylebox_override("panel", roster_style)
	split_hbox.add_child(roster_panel)

	var roster_scroll := ScrollContainer.new()
	roster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var roster_margin := MarginContainer.new()
	roster_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_margin.add_theme_constant_override("margin_left", 8)
	roster_margin.add_theme_constant_override("margin_right", 8)
	roster_margin.add_theme_constant_override("margin_top", 8)
	roster_margin.add_theme_constant_override("margin_bottom", 8)
	roster_scroll.add_child(roster_margin)
	roster_panel.add_child(roster_scroll)

	_roster_container = VBoxContainer.new()
	_roster_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_roster_container.add_theme_constant_override("separation", 10)
	roster_margin.add_child(_roster_container)

	_build_roster_list()


func _build_roster_list() -> void:
	for i in range(STARTERS.size()):
		var data = STARTERS[i]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 80)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var norm := StyleBoxFlat.new()
		norm.bg_color = data.bg
		norm.set_border_width_all(2)
		norm.border_color = (data.border as Color).darkened(0.5)
		norm.set_corner_radius_all(8)

		var hov := StyleBoxFlat.new()
		hov.bg_color = (data.bg as Color).lightened(0.1)
		hov.set_border_width_all(2)
		hov.border_color = data.border
		hov.set_corner_radius_all(8)

		btn.add_theme_stylebox_override("normal", norm)
		btn.add_theme_stylebox_override("hover", hov)
		btn.add_theme_stylebox_override("pressed", hov)

		var hbox := HBoxContainer.new()
		hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(hbox)

		var sprite_tex := load(data.sprite) as Texture2D
		if sprite_tex:
			var tex_h := sprite_tex.get_height()
			var atlas := AtlasTexture.new()
			atlas.atlas = sprite_tex
			atlas.region = Rect2(0, 0, tex_h, tex_h)
			var tr := TextureRect.new()
			tr.texture = atlas
			tr.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.custom_minimum_size = Vector2(50, 50)
			tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hbox.add_child(tr)

		var lbl := Label.new()
		lbl.text = data.name
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hbox.add_child(lbl)

		btn.pressed.connect(
			func():
				_update_details(i),
		)
		_roster_container.add_child(btn)


func _update_details(index: int) -> void:
	_current_index = index
	var data = STARTERS[index]

	for child in _details_container.get_children():
		child.queue_free()
	for t in _timers:
		if is_instance_valid(t):
			t.queue_free()
	_timers.clear()

	var panel = _details_container.get_parent() as PanelContainer
	var sb = panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	sb.border_color = data.border
	panel.add_theme_stylebox_override("panel", sb)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	_details_container.add_child(vbox)

	var hdr := HBoxContainer.new()
	var lnum := Label.new()
	lnum.text = data.num
	lnum.add_theme_color_override("font_color", Color("888888"))
	var lname := Label.new()
	lname.text = data.name
	lname.add_theme_font_size_override("font_size", 20)
	lname.add_theme_color_override("font_color", data.type_color)
	hdr.add_child(lnum)
	hdr.add_child(lname)
	hdr.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hdr)

	var sprite_tex := load(data.sprite) as Texture2D
	if sprite_tex:
		var tex_h := sprite_tex.get_height()
		var tex_w := sprite_tex.get_width()
		var fcount: int = maxi(1, tex_w / tex_h)
		
		var atlas := AtlasTexture.new()
		atlas.atlas = sprite_tex
		atlas.region = Rect2(0, 0, tex_h, tex_h)
		var tr := TextureRect.new()
		tr.texture = atlas
		tr.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(160, 160)
		tr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		vbox.add_child(tr)

		if fcount > 1:
			var timer := Timer.new()
			timer.wait_time = 0.08
			timer.autostart = true
			add_child(timer)
			_timers.append(timer)

			var current_frame := [0]
			var captured_atlas := atlas
			timer.timeout.connect(
				func():
					current_frame[0] = (current_frame[0] + 1) % fcount
					captured_atlas.region = Rect2(current_frame[0] * tex_h, 0, tex_h, tex_h),
			)

	var info_hbox := HBoxContainer.new()
	info_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	info_hbox.add_theme_constant_override("separation", 15)

	var type_box := HBoxContainer.new()
	type_box.add_theme_constant_override("separation", 5)
	for icon_path in data.get("type_icons", []):
		var tex := TextureRect.new()
		tex.texture = load(icon_path)
		tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2(24, 24)
		type_box.add_child(tex)
	info_hbox.add_child(type_box)

	var abl_label := Label.new()
	abl_label.text = "Habilidad: " + data.ability
	abl_label.add_theme_font_size_override("font_size", 12)
	abl_label.add_theme_color_override("font_color", Color("cccccc"))
	info_hbox.add_child(abl_label)

	vbox.add_child(info_hbox)

	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 10)
	vbox.add_child(sep)

	var stats_box := VBoxContainer.new()
	stats_box.add_theme_constant_override("separation", 4)
	vbox.add_child(stats_box)

	var stats = data.stats
	_add_stat_bar(stats_box, "HP", stats.HP, data.type_color)
	_add_stat_bar(stats_box, "Ataque", stats.ATK, data.type_color)
	_add_stat_bar(stats_box, "Defensa", stats.DEF, data.type_color)
	_add_stat_bar(stats_box, "Velocidad", stats.SPE, data.type_color)
	_add_stat_bar(stats_box, "Atq.Esp", stats.SPA, data.type_color)
	_add_stat_bar(stats_box, "Def.Esp", stats.SPD, data.type_color)

	var sep2 := HSeparator.new()
	sep2.add_theme_constant_override("separation", 10)
	vbox.add_child(sep2)

	var desc_label := Label.new()
	desc_label.text = data.desc
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color("aaaaaa"))
	vbox.add_child(desc_label)

	var flex := Control.new()
	flex.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(flex)

	var btn_choose := Button.new()
	btn_choose.text = "¡ELEGIR!"
	btn_choose.custom_minimum_size = Vector2(0, 45)
	btn_choose.add_theme_font_size_override("font_size", 16)
	btn_choose.add_theme_color_override("font_color", Color.WHITE)
	var cstyle := StyleBoxFlat.new()
	cstyle.bg_color = data.type_color
	cstyle.set_corner_radius_all(6)
	var cstyle_hov := cstyle.duplicate() as StyleBoxFlat
	cstyle_hov.bg_color = (data.type_color as Color).lightened(0.2)
	btn_choose.add_theme_stylebox_override("normal", cstyle)
	btn_choose.add_theme_stylebox_override("hover", cstyle_hov)
	btn_choose.add_theme_stylebox_override("pressed", cstyle_hov)

	var pname: String = data.name
	btn_choose.pressed.connect(
		func():
			starter_chosen.emit(pname),
	)
	vbox.add_child(btn_choose)


func _add_stat_bar(parent: Control, sname: String, val: int, color: Color) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var lname := Label.new()
	lname.text = sname
	lname.custom_minimum_size = Vector2(65, 0)
	lname.add_theme_font_size_override("font_size", 11)
	lname.add_theme_color_override("font_color", Color("cccccc"))
	hbox.add_child(lname)

	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = float(val)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.custom_minimum_size = Vector2(0, 10)
	bar.show_percentage = false

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("222222")
	bg.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", bg)

	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("fill", fill)
	hbox.add_child(bar)

	var lval := Label.new()
	lval.text = str(val)
	lval.custom_minimum_size = Vector2(25, 0)
	lval.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lval.add_theme_font_size_override("font_size", 11)
	lval.add_theme_color_override("font_color", color)
	hbox.add_child(lval)

	parent.add_child(hbox)
