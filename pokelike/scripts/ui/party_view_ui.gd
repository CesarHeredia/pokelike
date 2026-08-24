# res://scripts/ui/party_view_ui.gd
extends Control

signal back_pressed()
signal item_removed(item_id: int, pokemon_index: int)

var party_list: Array = []
var inventory_ref: Array[int] = []  # Referencia al inventario del padre
var _current_index: int = 0
var _details_container: MarginContainer
var _roster_container: VBoxContainer
var _timers: Array[Timer] = []

const TYPE_NAMES: Dictionary = {
	0:  "NORMAL",   1:  "FUEGO",    2:  "AGUA",     3:  "ELÉCTRICO",
	4:  "PLANTA",   5:  "HIELO",    6:  "LUCHA",    7:  "VENENO",
	8:  "TIERRA",   9:  "VOLADOR",  10: "PSÍQUICO", 11: "BICHO",
	12: "ROCA",     13: "FANTASMA", 14: "DRAGÓN",   15: "SINIESTRO",
	16: "ACERO",    17: "HADA",
}

const TYPE_COLORS: Dictionary = {
	0:  Color("A8A878"), 1:  Color("F08030"), 2:  Color("6890F0"),
	3:  Color("F8D030"), 4:  Color("78C850"), 5:  Color("98D8D8"),
	6:  Color("C03028"), 7:  Color("A040A0"), 8:  Color("E0C068"),
	9:  Color("A890F0"), 10: Color("F85888"), 11: Color("A8B820"),
	12: Color("B8A038"), 13: Color("705898"), 14: Color("7038F8"),
	15: Color("705848"), 16: Color("B8B8D0"), 17: Color("EE99AC"),
}

const TYPE_ICONS: Dictionary = {
	0:  "res://assets/sprites/tipos/Normal type.png",
	1:  "res://assets/sprites/tipos/Fire type.png",
	2:  "res://assets/sprites/tipos/Water type.png",
	3:  "res://assets/sprites/tipos/Electric type.png",
	4:  "res://assets/sprites/tipos/Grass type.png",
	5:  "res://assets/sprites/tipos/Ice type.png",
	6:  "res://assets/sprites/tipos/Fighting type.png",
	7:  "res://assets/sprites/tipos/Poison type.png",
	8:  "res://assets/sprites/tipos/Ground type.png",
	9:  "res://assets/sprites/tipos/Flying type.png",
	10: "res://assets/sprites/tipos/Psychic type.png",
	11: "res://assets/sprites/tipos/Bug type.png",
	12: "res://assets/sprites/tipos/Rock type.png",
	13: "res://assets/sprites/tipos/Ghost type.png",
	14: "res://assets/sprites/tipos/Dragon type.png",
	15: "res://assets/sprites/tipos/Dark type.png",
	16: "res://assets/sprites/tipos/Steel type.png",
	17: "res://assets/sprites/tipos/Fairy type.png",
}

func setup(p_list: Array, p_inventory: Array[int] = []) -> void:
	party_list.clear()
	for item in p_list:
		if item is Dictionary:
			party_list.append(item)
	inventory_ref = p_inventory

func _ready() -> void:
	_build_ui()
	if party_list.size() > 0:
		_update_details(0)

func _hp_ratio(current: int, maximum: int) -> float:
	if maximum <= 0: return 0.0
	return float(current) / float(maximum)

func _hp_bar_color(ratio: float) -> Color:
	if ratio > 0.5:
		return Color("2ecc71")  # Verde
	elif ratio > 0.25:
		return Color("f1c40f")  # Amarillo
	else:
		return Color("e74c3c")  # Rojo

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color("0a0e14")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var outer := VBoxContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("separation", 0)
	add_child(outer)

	# Cabecera
	var header := PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 60)
	var hdr_style := StyleBoxFlat.new()
	hdr_style.bg_color = Color("0d1117")
	hdr_style.border_color = Color("2ecc71")
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

	var btn_back := Button.new()
	btn_back.text = "◀ VOLVER"
	btn_back.custom_minimum_size = Vector2(100, 36)
	btn_back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn_back.add_theme_font_size_override("font_size", 11)
	btn_back.pressed.connect(func(): back_pressed.emit())
	hdr_hbox.add_child(btn_back)

	var lbl_title := Label.new()
	lbl_title.text = "EQUIPO (%d/6)" % party_list.size()
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 17)
	lbl_title.add_theme_color_override("font_color", Color("2ecc71"))
	hdr_hbox.add_child(lbl_title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(100, 0)
	hdr_hbox.add_child(spacer)

	# Contenido
	var content_margin := MarginContainer.new()
	content_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_margin.add_theme_constant_override("margin_left", 8)
	content_margin.add_theme_constant_override("margin_right", 8)
	content_margin.add_theme_constant_override("margin_top", 10)
	content_margin.add_theme_constant_override("margin_bottom", 10)
	outer.add_child(content_margin)

	if party_list.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "¡Tu equipo está vacío!\nElige tu starter o captura Pokémon en las Pokébolas del mapa."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		empty_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		empty_lbl.add_theme_color_override("font_color", Color("888888"))
		empty_lbl.add_theme_font_size_override("font_size", 14)
		content_margin.add_child(empty_lbl)
		return

	var split_hbox := HBoxContainer.new()
	split_hbox.add_theme_constant_override("separation", 12)
	content_margin.add_child(split_hbox)

	# Panel Izquierdo: Detalles
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

	# Panel Derecho: Lista del equipo
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
	for i in range(party_list.size()):
		var data: Dictionary = party_list[i]
		var type_id: int = (data.get("types", [0]) as Array)[0]
		var border_color: Color = TYPE_COLORS.get(type_id, Color("888888"))
		var bg_color: Color = border_color.darkened(0.75)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 70)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var norm := StyleBoxFlat.new()
		norm.bg_color = bg_color
		norm.set_border_width_all(2)
		norm.border_color = border_color.darkened(0.4)
		norm.set_corner_radius_all(8)

		var hov := StyleBoxFlat.new()
		hov.bg_color = bg_color.lightened(0.1)
		hov.set_border_width_all(2)
		hov.border_color = border_color
		hov.set_corner_radius_all(8)

		btn.add_theme_stylebox_override("normal", norm)
		btn.add_theme_stylebox_override("hover", hov)
		btn.add_theme_stylebox_override("pressed", hov)

		var hbox := HBoxContainer.new()
		hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(hbox)

		var sprite_path: String = data.get("sprite_path", data.get("sprite", ""))
		if sprite_path != "" and ResourceLoader.exists(sprite_path):
			var sprite_tex := load(sprite_path) as Texture2D
			if sprite_tex:
				var tex_h := sprite_tex.get_height()
				var atlas := AtlasTexture.new()
				atlas.atlas = sprite_tex
				atlas.region = Rect2(0, 0, tex_h, tex_h)
				var tr := TextureRect.new()
				tr.texture = atlas
				tr.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				tr.custom_minimum_size = Vector2(45, 45)
				tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
				hbox.add_child(tr)

		var lbl := Label.new()
		var p_name: String = String(data.get("name", "POKÉMON")).to_upper()
		var lvl: int = int(data.get("level", 1))

		var BattleUI = preload("res://scripts/ui/mobile_battle_ui.gd")
		var base: Dictionary = BattleUI.POKEDEX_BASE.get(p_name, {"hp":45})
		var max_hp: int = int(float(2 * base.hp * lvl) / 100.0) + lvl + 10

		var current_hp: int = int(data.get("current_hp", max_hp))
		if current_hp < 0: current_hp = max_hp

		lbl.text = "%s Nv.%d\n%d/%d HP" % [p_name, lvl, current_hp, max_hp]
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.add_theme_font_size_override("font_size", 12)
		if current_hp <= 0:
			lbl.add_theme_color_override("font_color", Color("e74c3c"))
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hbox.add_child(lbl)

		var capture_i := i
		btn.pressed.connect(func(): _update_details(capture_i))
		_roster_container.add_child(btn)

func _update_details(index: int) -> void:
	_current_index = index
	var data: Dictionary = party_list[index]

	for child in _details_container.get_children():
		child.queue_free()
	for t in _timers:
		if is_instance_valid(t):
			t.queue_free()
	_timers.clear()

	var type_id: int = (data.get("types", [0]) as Array)[0]
	var type_color: Color = TYPE_COLORS.get(type_id, Color("888888"))

	var panel := _details_container.get_parent() as PanelContainer
	var sb := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	sb.border_color = type_color
	panel.add_theme_stylebox_override("panel", sb)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_details_container.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(vbox)

	# Número + nombre
	var hdr := HBoxContainer.new()
	hdr.alignment = BoxContainer.ALIGNMENT_CENTER
	var lnum := Label.new()
	lnum.text = "#%03d" % data.get("pokedex_id", 0)
	lnum.add_theme_color_override("font_color", Color("888888"))
	var lname := Label.new()
	var lvl: int = int(data.get("level", 1))
	lname.text = "  " + String(data.get("name", "POKÉMON")).to_upper() + " Nv." + str(lvl)
	lname.add_theme_font_size_override("font_size", 20)
	lname.add_theme_color_override("font_color", type_color)
	hdr.add_child(lnum)
	hdr.add_child(lname)
	vbox.add_child(hdr)

	# Sprite animado
	var sprite_path: String = data.get("sprite_path", data.get("sprite", ""))
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		var sprite_tex := load(sprite_path) as Texture2D
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
						captured_atlas.region = Rect2(current_frame[0] * tex_h, 0, tex_h, tex_h)
				)

	# Tipos + evolución
	var info_hbox := HBoxContainer.new()
	info_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	info_hbox.add_theme_constant_override("separation", 12)

	var type_icons: Array = data.get("types", [type_id])
	var type_box := HBoxContainer.new()
	type_box.add_theme_constant_override("separation", 4)
	for tid in type_icons:
		var icon_path: String = TYPE_ICONS.get(tid, "")
		if icon_path != "" and ResourceLoader.exists(icon_path):
			var tex := TextureRect.new()
			tex.texture = load(icon_path)
			tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex.custom_minimum_size = Vector2(24, 24)
			type_box.add_child(tex)
	info_hbox.add_child(type_box)

	var evo_lbl := Label.new()
	if data.get("evo_id", null) != null:
		var evo_lvl: int = data.get("evo_lvl", 0)
		evo_lbl.text = "Evoluciona en Nv.%d" % evo_lvl if evo_lvl > 0 else "Evoluciona con piedra"
	else:
		evo_lbl.text = "Sin evolución"
	evo_lbl.add_theme_font_size_override("font_size", 12)
	evo_lbl.add_theme_color_override("font_color", Color("aaaaaa"))
	info_hbox.add_child(evo_lbl)

	vbox.add_child(info_hbox)

	# ── Estats del Pokémon ──
	var stats_box := VBoxContainer.new()
	stats_box.add_theme_constant_override("separation", 4)
	vbox.add_child(stats_box)

	var stats_data = data.get("stats", [50, 50, 50, 50, 50, 50])
	var s_hp: int = 50
	var s_atk: int = 50
	var s_def: int = 50
	var s_spa: int = 50
	var s_spd: int = 50
	var s_spe: int = 50

	if stats_data is Array and stats_data.size() >= 6:
		s_hp = stats_data[0]
		s_atk = stats_data[1]
		s_def = stats_data[2]
		s_spa = stats_data[3]
		s_spd = stats_data[4]
		s_spe = stats_data[5]
	elif stats_data is Dictionary:
		s_hp = stats_data.get("HP", 50)
		s_atk = stats_data.get("ATK", 50)
		s_def = stats_data.get("DEF", 50)
		s_spa = stats_data.get("SPA", 50)
		s_spd = stats_data.get("SPD", 50)
		s_spe = stats_data.get("SPE", 50)

	var p_name: String = String(data.get("name", "POKÉMON")).to_upper()
	var BattleUI = preload("res://scripts/ui/mobile_battle_ui.gd")
	var base: Dictionary = BattleUI.POKEDEX_BASE.get(p_name, {"hp":45})
	var max_hp: int = int(float(2 * base.hp * lvl) / 100.0) + lvl + 10
	var current_hp: int = int(data.get("current_hp", max_hp))
	if current_hp < 0: current_hp = max_hp

	# Barra HP con colores dinámicos
	_add_stat_bar(stats_box, "HP", current_hp, _hp_bar_color(_hp_ratio(current_hp, max_hp)), float(max_hp), true)
	_add_stat_bar(stats_box, "Ataque", s_atk, type_color)
	_add_stat_bar(stats_box, "Defensa", s_def, type_color)
	_add_stat_bar(stats_box, "Atq.Esp", s_spa, type_color)
	_add_stat_bar(stats_box, "Def.Esp", s_spd, type_color)
	_add_stat_bar(stats_box, "Velocidad", s_spe, type_color)

	# ── Ataque del Pokémon ──
	var sep_label := Label.new()
	sep_label.text = "─ ATAQUE ─"
	sep_label.add_theme_font_size_override("font_size", 11)
	sep_label.add_theme_color_override("font_color", Color("6688aa"))
	sep_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sep_label)

	var base_atk: int = base.get("atk", 50)
	var base_spa: int = base.get("spa", 50)
	var poke_first_type: int = (data.get("types", [0]) as Array)[0]
	var move_cat: int
	if base_spa >= base_atk:
		move_cat = Move.Category.SPECIAL
	else:
		move_cat = Move.Category.PHYSICAL
	var move_power: int = 50
	var resolved_move: Move = Move.get_move_by_type_category_power(poke_first_type, move_cat, move_power)

	var move_box := HBoxContainer.new()
	move_box.add_theme_constant_override("separation", 6)

	# Icono físico/especial
	var icon_path: String = ""
	if move_cat == Move.Category.PHYSICAL:
		icon_path = "res://assets/sprites/movimientos/Clase_físico_HGSS.png"
	else:
		icon_path = "res://assets/sprites/movimientos/Clase_especial_XY.png"
	if icon_path != "" and ResourceLoader.exists(icon_path):
		var icon_tex := TextureRect.new()
		icon_tex.texture = load(icon_path)
		icon_tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_tex.custom_minimum_size = Vector2(20, 20)
		move_box.add_child(icon_tex)

	var m_color: Color = Enums.type_color(poke_first_type)
	var lbl_name := Label.new()
	lbl_name.text = resolved_move.move_name
	lbl_name.add_theme_font_size_override("font_size", 12)
	lbl_name.add_theme_color_override("font_color", m_color)
	move_box.add_child(lbl_name)

	var lbl_info := Label.new()
	lbl_info.text = "P:%d" % move_power
	lbl_info.add_theme_font_size_override("font_size", 10)
	lbl_info.add_theme_color_override("font_color", Color("888888"))
	move_box.add_child(lbl_info)

	vbox.add_child(move_box)

	# ── Objeto equipado ──
	var item_sep := Label.new()
	item_sep.text = "─ OBJETO ─"
	item_sep.add_theme_font_size_override("font_size", 11)
	item_sep.add_theme_color_override("font_color", Color("6688aa"))
	item_sep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(item_sep)

	var held_item_id: int = int(data.get("held_item_id", 0))
	if held_item_id > 0:
		var item = ItemRegistry.get_item(held_item_id) if ItemRegistry else null
		if item:
			var item_btn := Button.new()
			item_btn.custom_minimum_size = Vector2(0, 44)
			item_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			var btn_s := StyleBoxFlat.new()
			btn_s.bg_color = Color("1a2230")
			btn_s.set_corner_radius_all(6)
			btn_s.set_border_width_all(2)
			btn_s.border_color = Color("f1c40f").darkened(0.4)
			item_btn.add_theme_stylebox_override("normal", btn_s)

			var btn_h := StyleBoxFlat.new()
			btn_h.bg_color = Color("223040")
			btn_h.set_corner_radius_all(6)
			btn_h.set_border_width_all(2)
			btn_h.border_color = Color("f1c40f")
			item_btn.add_theme_stylebox_override("hover", btn_h)
			item_btn.add_theme_stylebox_override("pressed", btn_h)

			var item_hbox := HBoxContainer.new()
			item_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			item_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
			item_hbox.add_theme_constant_override("separation", 8)
			item_btn.add_child(item_hbox)

			if item.icon_path != "" and ResourceLoader.exists(item.icon_path):
				var item_tex := TextureRect.new()
				item_tex.texture = load(item.icon_path)
				item_tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				item_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				item_tex.custom_minimum_size = Vector2(28, 28)
				item_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
				item_hbox.add_child(item_tex)

			var item_lbl := Label.new()
			item_lbl.text = item.name
			item_lbl.add_theme_font_size_override("font_size", 13)
			item_lbl.add_theme_color_override("font_color", Color("f1c40f"))
			item_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			item_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			item_hbox.add_child(item_lbl)

			var capture_idx := index
			item_btn.pressed.connect(func(): _show_item_dialog(held_item_id, capture_idx))
			vbox.add_child(item_btn)
		else:
			var no_item := Label.new()
			no_item.text = "Objeto desconocido (#%d)" % held_item_id
			no_item.add_theme_font_size_override("font_size", 11)
			no_item.add_theme_color_override("font_color", Color("888888"))
			vbox.add_child(no_item)
	else:
		var no_item := Label.new()
		no_item.text = "Ningún objeto equipado"
		no_item.add_theme_font_size_override("font_size", 11)
		no_item.add_theme_color_override("font_color", Color("555555"))
		vbox.add_child(no_item)

func _show_item_dialog(item_id: int, pokemon_index: int) -> void:
	var item = ItemRegistry.get_item(item_id) if ItemRegistry else null
	if not item:
		return

	# Overlay oscuro
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# Panel del diálogo
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var dialog := PanelContainer.new()
	dialog.custom_minimum_size = Vector2(280, 0)
	var ds := StyleBoxFlat.new()
	ds.bg_color = Color("111720")
	ds.set_corner_radius_all(10)
	ds.set_border_width_all(2)
	ds.border_color = Color("f1c40f")
	dialog.add_theme_stylebox_override("panel", ds)
	center.add_child(dialog)

	var d_margin := MarginContainer.new()
	d_margin.add_theme_constant_override("margin_left", 16)
	d_margin.add_theme_constant_override("margin_right", 16)
	d_margin.add_theme_constant_override("margin_top", 14)
	d_margin.add_theme_constant_override("margin_bottom", 14)
	dialog.add_child(d_margin)

	var d_vbox := VBoxContainer.new()
	d_vbox.add_theme_constant_override("separation", 10)
	d_margin.add_child(d_vbox)

	# Icono + nombre
	var item_header := HBoxContainer.new()
	item_header.alignment = BoxContainer.ALIGNMENT_CENTER
	item_header.add_theme_constant_override("separation", 8)
	d_vbox.add_child(item_header)

	if item.icon_path != "" and ResourceLoader.exists(item.icon_path):
		var tex := TextureRect.new()
		tex.texture = load(item.icon_path)
		tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2(32, 32)
		item_header.add_child(tex)

	var lbl_item_name := Label.new()
	lbl_item_name.text = item.name
	lbl_item_name.add_theme_font_size_override("font_size", 16)
	lbl_item_name.add_theme_color_override("font_color", Color("f1c40f"))
	item_header.add_child(lbl_item_name)

	# Descripción
	var lbl_desc := Label.new()
	lbl_desc.text = item.description
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.add_theme_font_size_override("font_size", 11)
	lbl_desc.add_theme_color_override("font_color", Color("cccccc"))
	d_vbox.add_child(lbl_desc)

	# Botones
	var btn_hbox := HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 12)
	d_vbox.add_child(btn_hbox)

	var poke_name: String = String(party_list[pokemon_index].get("name", "?"))

	var btn_keep := Button.new()
	btn_keep.text = "MANTENER"
	btn_keep.custom_minimum_size = Vector2(120, 40)
	btn_keep.add_theme_font_size_override("font_size", 13)
	var keep_s := StyleBoxFlat.new()
	keep_s.bg_color = Color("2c3e50")
	keep_s.set_corner_radius_all(6)
	btn_keep.add_theme_stylebox_override("normal", keep_s)
	btn_keep.add_theme_color_override("font_color", Color("ffffff"))
	btn_keep.pressed.connect(func():
		overlay.queue_free()
		center.queue_free()
	)
	btn_hbox.add_child(btn_keep)

	var btn_remove := Button.new()
	btn_remove.text = "QUITAR"
	btn_remove.custom_minimum_size = Vector2(120, 40)
	btn_remove.add_theme_font_size_override("font_size", 13)
	var rem_s := StyleBoxFlat.new()
	rem_s.bg_color = Color("8b0000")
	rem_s.set_corner_radius_all(6)
	btn_remove.add_theme_stylebox_override("normal", rem_s)
	btn_remove.add_theme_color_override("font_color", Color("ffffff"))
	btn_remove.pressed.connect(func():
		overlay.queue_free()
		center.queue_free()
		# Devolver objeto al inventario
		inventory_ref.append(item_id)
		party_list[pokemon_index]["held_item_id"] = 0
		print("[Mochila]: %s devolvió \"%s\" a la mochila." % [poke_name, item.name])
		item_removed.emit(item_id, pokemon_index)
		_update_details(_current_index)
	)
	btn_hbox.add_child(btn_remove)

func _move_category_str(cat: int) -> String:
	match cat:
		0: return "Físico"
		1: return "Especial"
		_: return "Estado"

func _add_stat_bar(parent: Control, sname: String, val: int, color: Color, max_val: float = 150.0, is_hp: bool = false) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var lname := Label.new()
	lname.text = sname
	lname.custom_minimum_size = Vector2(70, 0)
	lname.add_theme_font_size_override("font_size", 11)
	lname.add_theme_color_override("font_color", Color("cccccc"))
	hbox.add_child(lname)

	var bar := ProgressBar.new()
	bar.max_value = max_val
	bar.value = float(val)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.custom_minimum_size = Vector2(0, 10)
	bar.show_percentage = false

	var bg_sbox := StyleBoxFlat.new()
	bg_sbox.bg_color = Color("1c2530")
	bg_sbox.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg_sbox)

	var fill_sbox := StyleBoxFlat.new()
	fill_sbox.bg_color = color
	fill_sbox.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill_sbox)
	hbox.add_child(bar)

	var lval := Label.new()
	if is_hp:
		lval.text = "%d/%d" % [val, int(max_val)]
	else:
		lval.text = "%d" % val
	lval.custom_minimum_size = Vector2(30, 0)
	lval.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lval.add_theme_font_size_override("font_size", 11)
	lval.add_theme_color_override("font_color", Color("ffffff"))
	hbox.add_child(lval)

	parent.add_child(hbox)
