# res://scripts/ui/pokemon_gift_ui.gd
extends Control

signal pokemon_chosen(pokemon_name: String)
signal gift_declined()

# Pool completo de primera fase con sprites disponibles en "pokemon izquierda"
# Se pasa desde el exterior según el gimnasio activo
var gift_pool: Array[Dictionary] = []

var _current_index: int = 0
var _details_container: MarginContainer
var _roster_container: VBoxContainer
var _timers: Array[Timer] = []
var _chosen_three: Array[Dictionary] = []

# Mapa de tipos a nombres legibles
const TYPE_NAMES: Dictionary = {
	0:  "NORMAL",
	1:  "FUEGO",
	2:  "AGUA",
	3:  "ELÉCTRICO",
	4:  "PLANTA",
	5:  "HIELO",
	6:  "LUCHA",
	7:  "VENENO",
	8:  "TIERRA",
	9:  "VOLADOR",
	10: "PSÍQUICO",
	11: "BICHO",
	12: "ROCA",
	13: "FANTASMA",
	14: "DRAGÓN",
	15: "SINIESTRO",
	16: "ACERO",
	17: "HADA",
}

const TYPE_COLORS: Dictionary = {
	0:  Color("A8A878"),
	1:  Color("F08030"),
	2:  Color("6890F0"),
	3:  Color("F8D030"),
	4:  Color("78C850"),
	5:  Color("98D8D8"),
	6:  Color("C03028"),
	7:  Color("A040A0"),
	8:  Color("E0C068"),
	9:  Color("A890F0"),
	10: Color("F85888"),
	11: Color("A8B820"),
	12: Color("B8A038"),
	13: Color("705898"),
	14: Color("7038F8"),
	15: Color("705848"),
	16: Color("B8B8D0"),
	17: Color("EE99AC"),
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

# ── Llamar desde fuera antes de add_child ────────────────────────────────────
func setup(pool: Array) -> void:
	gift_pool.clear()
	for p in pool:
		gift_pool.append(p as Dictionary)

func _ready() -> void:
	# Elegir 3 aleatorios del pool (sin repetir)
	_pick_three()
	_build_ui()
	if _chosen_three.size() > 0:
		_update_details(0)

func _pick_three() -> void:
	var shuffled := gift_pool.duplicate()
	shuffled.shuffle()
	_chosen_three = shuffled.slice(0, min(3, shuffled.size()))

# ── Construcción del UI (idéntico a starter_selection) ──────────────────────

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Fondo oscuro
	var bg := ColorRect.new()
	bg.color = Color("0a0e14")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var outer := VBoxContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("separation", 0)
	add_child(outer)

	# ── Cabecera ─────────────────────────────────────────────────────────────
	var header := PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 60)
	var hdr_style := StyleBoxFlat.new()
	hdr_style.bg_color = Color("0d1117")
	hdr_style.set_border_width_all(0)
	hdr_style.border_color = Color("e74c3c")
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

	# Botón atrás
	var btn_back := Button.new()
	btn_back.text = "◀ RECHAZAR"
	btn_back.custom_minimum_size = Vector2(100, 36)
	btn_back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn_back.add_theme_font_size_override("font_size", 11)
	btn_back.add_theme_color_override("font_color", Color("e74c3c"))
	var back_style := StyleBoxFlat.new()
	back_style.bg_color = Color("1a1f28")
	back_style.set_border_width_all(1)
	back_style.border_color = Color("e74c3c")
	back_style.set_corner_radius_all(4)
	btn_back.add_theme_stylebox_override("normal", back_style)
	btn_back.pressed.connect(func(): gift_declined.emit())
	hdr_hbox.add_child(btn_back)

	# Título
	var lbl_title := Label.new()
	lbl_title.text = "🎁  ¡POKÉMON DE REGALO!"
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 17)
	lbl_title.add_theme_color_override("font_color", Color("f1c40f"))
	hdr_hbox.add_child(lbl_title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(100, 0)
	hdr_hbox.add_child(spacer)

	# Subtítulo debajo del header
	var subtitle_margin := MarginContainer.new()
	subtitle_margin.add_theme_constant_override("margin_left", 0)
	subtitle_margin.add_theme_constant_override("margin_right", 0)
	subtitle_margin.add_theme_constant_override("margin_top", 6)
	subtitle_margin.add_theme_constant_override("margin_bottom", 0)
	outer.add_child(subtitle_margin)

	var subtitle := Label.new()
	subtitle.text = "¡Elige uno de estos 3 Pokémon! El resto desaparecerá..."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", Color("888888"))
	subtitle_margin.add_child(subtitle)

	# ── Contenido dividido ────────────────────────────────────────────────────
	var content_margin := MarginContainer.new()
	content_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_margin.add_theme_constant_override("margin_left", 8)
	content_margin.add_theme_constant_override("margin_right", 8)
	content_margin.add_theme_constant_override("margin_top", 10)
	content_margin.add_theme_constant_override("margin_bottom", 10)
	outer.add_child(content_margin)

	var split_hbox := HBoxContainer.new()
	split_hbox.add_theme_constant_override("separation", 12)
	content_margin.add_child(split_hbox)

	# Panel izquierdo: detalles
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

	# Panel derecho: lista
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
	for i in range(_chosen_three.size()):
		var data: Dictionary = _chosen_three[i]
		var type_id: int = (data.types as Array)[0]
		var border_color: Color = TYPE_COLORS.get(type_id, Color("888888"))
		var bg_color: Color = border_color.darkened(0.75)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 80)
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

		# Sprite desde "pokemon izquierda"
		var sprite_path: String = data.get("sprite_path", "")
		if sprite_path != "":
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
				tr.custom_minimum_size = Vector2(50, 50)
				tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
				hbox.add_child(tr)

		var lbl := Label.new()
		lbl.text = data.name.to_upper()
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", border_color)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hbox.add_child(lbl)

		var capture_i := i
		btn.pressed.connect(func(): _update_details(capture_i))
		_roster_container.add_child(btn)

func _update_details(index: int) -> void:
	_current_index = index
	var data: Dictionary = _chosen_three[index]

	for child in _details_container.get_children():
		child.queue_free()
	for t in _timers:
		if is_instance_valid(t):
			t.queue_free()
	_timers.clear()

	var type_id: int = (data.types as Array)[0]
	var type_color: Color = TYPE_COLORS.get(type_id, Color("888888"))
	var type_name: String = TYPE_NAMES.get(type_id, "???")

	# Actualizar borde del panel según el tipo
	var panel := _details_container.get_parent() as PanelContainer
	var sb := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	sb.border_color = type_color
	panel.add_theme_stylebox_override("panel", sb)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	_details_container.add_child(vbox)

	# Número + nombre
	var stats_data: Array = data.get("stats", [50, 50, 50, 50, 50, 50])
	var evo_lbl_text: String = "No evoluciona"
	if data.get("evo_id", null) != null:
		var evo_lvl: int = data.get("evo_lvl", 0)
		evo_lbl_text = "Evoluciona en Nv.%d" % evo_lvl if evo_lvl > 0 else "Evoluciona con piedra"

	var hdr := HBoxContainer.new()
	hdr.alignment = BoxContainer.ALIGNMENT_CENTER
	var lnum := Label.new()
	lnum.text = "#%03d" % data.get("pokedex_id", 0)
	lnum.add_theme_color_override("font_color", Color("888888"))
	var lname := Label.new()
	lname.text = "  " + data.name.to_upper()
	lname.add_theme_font_size_override("font_size", 20)
	lname.add_theme_color_override("font_color", type_color)
	hdr.add_child(lnum)
	hdr.add_child(lname)
	vbox.add_child(hdr)

	# Sprite animado
	var sprite_path: String = data.get("sprite_path", "")
	if sprite_path != "":
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
						captured_atlas.region = Rect2(current_frame[0] * tex_h, 0, tex_h, tex_h),
				)

	# Tipo + evolución
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
		else:
			var tname_lbl := Label.new()
			tname_lbl.text = TYPE_NAMES.get(tid, "?")
			tname_lbl.add_theme_font_size_override("font_size", 11)
			tname_lbl.add_theme_color_override("font_color", TYPE_COLORS.get(tid, Color.WHITE))
			type_box.add_child(tname_lbl)
	info_hbox.add_child(type_box)

	var evo_label := Label.new()
	evo_label.text = evo_lbl_text
	evo_label.add_theme_font_size_override("font_size", 11)
	evo_label.add_theme_color_override("font_color", Color("aaaaaa"))
	info_hbox.add_child(evo_label)
	vbox.add_child(info_hbox)

	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 10)
	vbox.add_child(sep)

	# Barras de stats (HP, ATK, DEF, SPE, SPA, SPD)
	var stats_box := VBoxContainer.new()
	stats_box.add_theme_constant_override("separation", 4)
	vbox.add_child(stats_box)
	var snames := ["HP", "Ataque", "Defensa", "Velocidad", "Atq.Esp", "Def.Esp"]
	for si in range(min(6, stats_data.size())):
		_add_stat_bar(stats_box, snames[si], stats_data[si], type_color)

	var sep2 := HSeparator.new()
	sep2.add_theme_constant_override("separation", 10)
	vbox.add_child(sep2)

	var flex := Control.new()
	flex.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(flex)

	# Botón ELEGIR
	var btn_choose := Button.new()
	btn_choose.text = "¡ELEGIR!"
	btn_choose.custom_minimum_size = Vector2(0, 45)
	btn_choose.add_theme_font_size_override("font_size", 16)
	btn_choose.add_theme_color_override("font_color", Color.WHITE)
	var cstyle := StyleBoxFlat.new()
	cstyle.bg_color = type_color
	cstyle.set_corner_radius_all(6)
	var cstyle_hov := cstyle.duplicate() as StyleBoxFlat
	cstyle_hov.bg_color = type_color.lightened(0.2)
	btn_choose.add_theme_stylebox_override("normal", cstyle)
	btn_choose.add_theme_stylebox_override("hover", cstyle_hov)
	btn_choose.add_theme_stylebox_override("pressed", cstyle_hov)

	var pname: String = data.name
	btn_choose.pressed.connect(func(): pokemon_chosen.emit(pname))
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
	bar.max_value = 160.0
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
	lval.custom_minimum_size = Vector2(28, 0)
	lval.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lval.add_theme_font_size_override("font_size", 11)
	lval.add_theme_color_override("font_color", color)
	hbox.add_child(lval)

	parent.add_child(hbox)
