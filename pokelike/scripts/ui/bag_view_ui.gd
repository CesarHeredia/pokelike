# res://scripts/ui/bag_view_ui.gd
# Pantalla de la Bolsa / Mochila
# Modo "choice": mostrar 3 objetos para elegir (desde BagEvent)
# Modo "manage": mostrar objetos guardados y asignar a Pokémon
extends Control

signal back_pressed()
signal item_chosen(item_id: int)
signal item_equipped(item_id: int, pokemon_index: int)

var mode: String = "manage"  # "choice" o "manage"
var offered_items: Array[Dictionary] = []  # Para modo choice: [{id, name, desc, icon}]
var player_party: Array = []               # Array[Dictionary] del equipo
var player_inventory: Array[int] = []     # Array de IDs de objetos en la mochila

var _selected_item_id: int = -1
var _items_container: VBoxContainer
var _detail_panel: PanelContainer
var _detail_vbox: VBoxContainer

const COL_BG    := Color("0a0d13")
const COL_PANEL := Color("111720")
const COL_TEXT  := Color("ddeeff")
const COL_MUTED := Color("6688aa")
const COL_GOLD  := Color("f1c40f")
const COL_GREEN := Color("2ecc71")

func setup_choice(items: Array[Dictionary], party: Array) -> void:
	mode = "choice"
	offered_items = items
	player_party = party

func setup_manage(inventory: Array[int], party: Array) -> void:
	mode = "manage"
	player_inventory = inventory
	player_party = party

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = COL_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	# ── Header ──
	var header := PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 56)
	var hdr_s := StyleBoxFlat.new()
	hdr_s.bg_color = Color("0d1117")
	hdr_s.border_color = COL_GOLD
	hdr_s.border_width_bottom = 2
	header.add_theme_stylebox_override("panel", hdr_s)
	root.add_child(header)

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
	if mode == "choice":
		lbl_title.text = "🎒  ELIGE UN OBJETO"
	else:
		lbl_title.text = "🎒  MOCHILA (%d objetos)" % player_inventory.size()
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 17)
	lbl_title.add_theme_color_override("font_color", COL_GOLD)
	hdr_hbox.add_child(lbl_title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(100, 0)
	hdr_hbox.add_child(spacer)

	# ── Contenido: split horizontal ──
	var content := MarginContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("margin_left", 8)
	content.add_theme_constant_override("margin_right", 8)
	content.add_theme_constant_override("margin_top", 8)
	content.add_theme_constant_override("margin_bottom", 8)
	root.add_child(content)

	var split := HBoxContainer.new()
	split.add_theme_constant_override("separation", 10)
	content.add_child(split)

	# Panel izquierdo: lista de objetos
	var items_panel := PanelContainer.new()
	items_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	items_panel.size_flags_stretch_ratio = 1.2
	var ip_s := StyleBoxFlat.new()
	ip_s.bg_color = COL_PANEL
	ip_s.set_corner_radius_all(8)
	ip_s.set_border_width_all(2)
	ip_s.border_color = Color("2c3e50")
	items_panel.add_theme_stylebox_override("panel", ip_s)
	split.add_child(items_panel)

	var items_scroll := ScrollContainer.new()
	items_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var items_margin := MarginContainer.new()
	items_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	items_margin.add_theme_constant_override("margin_left", 6)
	items_margin.add_theme_constant_override("margin_right", 6)
	items_margin.add_theme_constant_override("margin_top", 6)
	items_margin.add_theme_constant_override("margin_bottom", 6)
	items_scroll.add_child(items_margin)
	items_panel.add_child(items_scroll)

	_items_container = VBoxContainer.new()
	_items_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_items_container.add_theme_constant_override("separation", 6)
	items_margin.add_child(_items_container)

	# Panel derecho: detalle del objeto seleccionado
	_detail_panel = PanelContainer.new()
	_detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_panel.size_flags_stretch_ratio = 1.5
	var dp_s := StyleBoxFlat.new()
	dp_s.bg_color = COL_PANEL
	dp_s.set_corner_radius_all(8)
	dp_s.set_border_width_all(2)
	dp_s.border_color = COL_GOLD.darkened(0.5)
	_detail_panel.add_theme_stylebox_override("panel", dp_s)
	split.add_child(_detail_panel)

	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 12)
	detail_margin.add_theme_constant_override("margin_right", 12)
	detail_margin.add_theme_constant_override("margin_top", 12)
	detail_margin.add_theme_constant_override("margin_bottom", 12)
	_detail_panel.add_child(detail_margin)

	_detail_vbox = VBoxContainer.new()
	_detail_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_vbox.add_theme_constant_override("separation", 8)
	detail_margin.add_child(_detail_vbox)

	_build_items_list()

func _build_items_list() -> void:
	for child in _items_container.get_children():
		child.queue_free()

	if mode == "choice":
		for item_data in offered_items:
			_add_item_button(item_data.id, item_data.name, item_data.get("icon", ""))
	else:
		if player_inventory.is_empty():
			var lbl := Label.new()
			lbl.text = "Tu mochila está vacía.\nConsigue objetos en los nodos de Bolso del mapa."
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.add_theme_font_size_override("font_size", 12)
			lbl.add_theme_color_override("font_color", COL_MUTED)
			_items_container.add_child(lbl)
			return
		# Contar cantidades
		var counts: Dictionary = {}
		for id in player_inventory:
			counts[id] = counts.get(id, 0) + 1
		for id in counts:
			var item = ItemRegistry.get_item(id)
			if item:
				_add_item_button(id, "%s x%d" % [item.name, counts[id]], item.icon_path)

func _add_item_button(item_id: int, display_name: String, icon_path: String) -> void:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 52)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var norm := StyleBoxFlat.new()
	norm.bg_color = Color("1a2230")
	norm.set_corner_radius_all(6)
	norm.set_border_width_all(1)
	norm.border_color = Color("334455")
	btn.add_theme_stylebox_override("normal", norm)

	var hov := StyleBoxFlat.new()
	hov.bg_color = Color("223040")
	hov.set_corner_radius_all(6)
	hov.set_border_width_all(2)
	hov.border_color = COL_GOLD
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", hov)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_theme_constant_override("separation", 8)
	btn.add_child(hbox)

	# Icono
	if icon_path != "" and ResourceLoader.exists(icon_path):
		var tex := TextureRect.new()
		tex.texture = load(icon_path)
		tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2(36, 36)
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hbox.add_child(tex)

	var lbl := Label.new()
	lbl.text = display_name
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", COL_TEXT)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(lbl)

	btn.pressed.connect(func(): _select_item(item_id))
	_items_container.add_child(btn)

func _select_item(item_id: int) -> void:
	_selected_item_id = item_id
	_update_detail()

func _update_detail() -> void:
	for child in _detail_vbox.get_children():
		child.queue_free()

	var item = ItemRegistry.get_item(_selected_item_id)
	if not item:
		var lbl := Label.new()
		lbl.text = "Selecciona un objeto"
		lbl.add_theme_color_override("font_color", COL_MUTED)
		_detail_vbox.add_child(lbl)
		return

	# Icono grande
	if item.icon_path != "" and ResourceLoader.exists(item.icon_path):
		var tex := TextureRect.new()
		tex.texture = load(item.icon_path)
		tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2(64, 64)
		tex.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_detail_vbox.add_child(tex)

	# Nombre
	var lbl_name := Label.new()
	lbl_name.text = item.name
	lbl_name.add_theme_font_size_override("font_size", 18)
	lbl_name.add_theme_color_override("font_color", COL_GOLD)
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_vbox.add_child(lbl_name)

	# Descripción
	var lbl_desc := Label.new()
	lbl_desc.text = item.description
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.add_theme_font_size_override("font_size", 12)
	lbl_desc.add_theme_color_override("font_color", COL_TEXT)
	_detail_vbox.add_child(lbl_desc)

	# Botón de acción
	if mode == "choice":
		var btn_equip := Button.new()
		btn_equip.text = "✅  COGER OBJETO"
		btn_equip.custom_minimum_size = Vector2(0, 42)
		btn_equip.add_theme_font_size_override("font_size", 14)
		var btn_s := StyleBoxFlat.new()
		btn_s.bg_color = COL_GREEN
		btn_s.set_corner_radius_all(6)
		btn_equip.add_theme_stylebox_override("normal", btn_s)
		btn_equip.add_theme_color_override("font_color", Color.WHITE)
		btn_equip.pressed.connect(func(): item_chosen.emit(_selected_item_id))
		_detail_vbox.add_child(btn_equip)
	else:
		# Modo manage: asignar a un Pokémon
		if not player_party.is_empty():
			var lbl_sep := Label.new()
			lbl_sep.text = "─ Asignar a ─"
			lbl_sep.add_theme_font_size_override("font_size", 11)
			lbl_sep.add_theme_color_override("font_color", COL_MUTED)
			lbl_sep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_detail_vbox.add_child(lbl_sep)

			for i in range(player_party.size()):
				var p: Dictionary = player_party[i]
				var p_name: String = String(p.get("name", "?")).to_upper()
				var p_item_id: int = int(p.get("held_item_id", 0))
				var is_equipped: bool = (p_item_id == _selected_item_id)
				var equipped_label: String = ""
				if p_item_id > 0:
					var eq_item = ItemRegistry.get_item(p_item_id)
					if eq_item:
						equipped_label = " [%s]" % eq_item.name

				var btn_p := Button.new()
				btn_p.text = "%s Nv.%d%s" % [p_name, int(p.get("level", 1)), equipped_label]
				btn_p.custom_minimum_size = Vector2(0, 38)
				btn_p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				btn_p.add_theme_font_size_override("font_size", 12)

				var pb_s := StyleBoxFlat.new()
				if is_equipped:
					pb_s.bg_color = Color("1a4020")
					pb_s.border_color = COL_GREEN
				else:
					pb_s.bg_color = Color("1a2230")
					pb_s.border_color = Color("334455")
				pb_s.set_corner_radius_all(5)
				pb_s.set_border_width_all(1)
				btn_p.add_theme_stylebox_override("normal", pb_s)
				btn_p.add_theme_color_override("font_color", COL_TEXT)

				var capture_i := i
				btn_p.pressed.connect(func(): item_equipped.emit(_selected_item_id, capture_i))
				_detail_vbox.add_child(btn_p)
