# res://scripts/ui/kanto_route_map.gd
@warning_ignore("unused_signal")
extends Control

signal start_battle(mode_name: String, details: Dictionary)
signal back_pressed()
signal reward_earned(reward: Dictionary)
signal gift_requested(gift_pool: Array)
signal starter_requested()
signal item_choice_requested(items: Array)
signal route_restarted()

@onready var btn_back: Button = $Header/BtnBack
@onready var btn_restart: Button = $Header/BtnRestart
@onready var map_canvas: Control = $Scroll/MapContainer/MapCanvas
@onready var nodes_container: Control = $Scroll/MapContainer/NodesContainer
@onready var scroll_container: ScrollContainer = $Scroll

# ── Configuración de mapa (Inyectada externamente) ───────────────────────────
var map_config: MapConfig
var map_layers: Array = []

var node_buttons: Dictionary = {}
var current_layer: int = 0
var completed_nodes: Array[String] = []
# Entrenador asignado a cada nodo TRAINER (id_nodo -> info)
var node_trainer_map: Dictionary = {}

# ── Inicialización ────────────────────────────────────────────────────────────

func _ready() -> void:
	if not map_config:
		map_config = preload("res://scripts/world/regions/kanto/gym1_brock/brock_map_config.gd").new()
	
	map_layers = map_config.get_map_layers()
	
	if btn_back:
		btn_back.pressed.connect(func():
			_show_confirmation_dialog(
				"⚠️ ¿SALIR DE LA REGIONAL?",
				"Si sales ahora, el progreso de tu partida no se guardará. ¿Deseas salir a la selección de regiones o seguir jugando?",
				"SALIR A REGIONES",
				func(): back_pressed.emit()
			)
		)
	if btn_restart:
		btn_restart.pressed.connect(func():
			_show_confirmation_dialog(
				"🔄 ¿REINICIAR RUTA?",
				"Esto reiniciará tu posición al inicio de la región y aleatorizará las funciones de todos los nodos del mapa.\n¿Deseas reiniciar?",
				"REINICIAR RUTA",
				func(): randomize_map_nodes(true)
			)
		)
	
	# La pokébola inicial (0_0) debe ser clickeada por el jugador para elegir starter
	current_layer = 0
	
	# Auto-aleatorizar los nodos al cargar por primera vez
	randomize_map_nodes(false)
	
	_apply_map_background()
	
	# Scrollear hasta arriba para ver la pokébola de starters
	await get_tree().process_frame
	if scroll_container:
		scroll_container.scroll_vertical = 0

## Guarda el estado del mapa (para persistir entre pantallas)
func get_state() -> Dictionary:
	return {
		"map_id": map_config.map_id if map_config else "kanto_brock",
		"completed": completed_nodes.duplicate(),
		"layer": current_layer,
		"node_types": _get_node_types_map(),
		"trainer_map": node_trainer_map.duplicate()
	}

## Restaura el estado al volver de una batalla
func restore_state(state: Dictionary) -> void:
	if state.is_empty():
		return
	
	# Asegurarnos de tener el MapConfig correcto al restaurar
	var map_id = state.get("map_id", "kanto_brock")
	var region = KantoRegion.new()
	map_config = region.get_map_config(map_id)
	map_layers = map_config.get_map_layers()
	
	completed_nodes = state.get("completed", ["0_0"])
	current_layer   = state.get("layer", 1)
	
	var t_map = state.get("trainer_map", {})
	if t_map is Dictionary:
		node_trainer_map = t_map.duplicate()
		
	var node_types = state.get("node_types", {})
	if node_types is Dictionary and not node_types.is_empty():
		_apply_node_types_map(node_types)
		
	_build_route_nodes()
	_apply_map_background()

func _apply_map_background() -> void:
	if not map_config or map_config.map_bg_image == "":
		return
	var grass_bg: ColorRect = $Scroll/MapContainer/GrassBg
	if not grass_bg:
		return
	var tex: Texture2D = load(map_config.map_bg_image)
	if tex == null:
		return
	var bg := TextureRect.new()
	bg.texture = tex
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grass_bg.get_parent().add_child(bg)
	grass_bg.get_parent().move_child(bg, grass_bg.get_index())
	grass_bg.queue_free()

func _get_node_types_map() -> Dictionary:
	var types_map := {}
	for layer in map_layers:
		for n_data in layer:
			types_map[n_data.id] = n_data.type
	return types_map

func _apply_node_types_map(types_map: Dictionary) -> void:
	for layer in map_layers:
		for n_data in layer:
			var id: String = n_data.id
			if types_map.has(id):
				var type: String = types_map[id]
				n_data["type"] = type
				_update_node_icon_and_label(n_data, type)

# ── Construcción del mapa ────────────────────────────────────────────────────

func _build_route_nodes() -> void:
	if not nodes_container:
		return
	for child in nodes_container.get_children():
		child.queue_free()
	node_buttons.clear()
	
	for layer in map_layers:
		for n_data in layer:
			var btn := _create_node_button(n_data)
			node_buttons[n_data.id] = btn
			nodes_container.add_child(btn)
	
	if map_canvas:
		map_canvas.queue_redraw()

func _create_node_button(n_data: Dictionary) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(76, 76)
	btn.size = Vector2(76, 76)
	btn.position = (n_data.pos as Vector2) - Vector2(38, 38)
	btn.flat = false
	
	# Ícono PNG en el botón
	var tex := load(n_data.icon) as Texture2D
	if tex:
		var tw := tex.get_width()
		var th := tex.get_height()
		# Recortar la primera frame (mirando al frente) de la grilla 4x4 para sprites de personajes
		if th > 50 and n_data.type in ["BOSS", "EVENT", "START", "TRAINER"]:
			var rows := 4
			var cols := 4
			if tw % 4 != 0 and tw % 3 == 0:
				cols = 3
			var frame_w := tw / cols
			var frame_h := th / rows
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(0, 0, frame_w, frame_h)
			btn.icon = atlas
		else:
			btn.icon = tex
			
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.expand_icon = true
	else:
		btn.text = "?"
		btn.add_theme_font_size_override("font_size", 20)
	
	var n_id: String       = n_data.id
	var is_completed: bool = completed_nodes.has(n_id)
	var is_reachable: bool = _is_node_reachable(n_data)
	
	_style_node_button(btn, is_completed, is_reachable, n_data)
	
	if is_reachable and not is_completed:
		btn.pressed.connect(func(): _on_node_selected(n_data))
	else:
		btn.disabled = true
	
	return btn

func _is_node_reachable(n_data: Dictionary) -> bool:
	var n_id: String    = n_data.id
	var n_layer: int    = int(n_id.split("_")[0])
	
	if n_layer != current_layer:
		return false
	if n_layer == 0:
		return true
	
	var prev_layer: Array = map_layers[n_layer - 1]
	for prev_node in prev_layer:
		if completed_nodes.has(prev_node.id) and prev_node.next.has(n_id):
			return true
	return false

func _style_node_button(btn: Button, is_completed: bool, is_reachable: bool, n_data: Dictionary) -> void:
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(10)
	style.set_border_width_all(3)
	style.bg_color = Color.TRANSPARENT # Fondo transparente para quitar el cuadro negro
	
	if is_completed:
		# Nodo completado: resaltado para mostrar el recorrido
		style.border_color = Color("2ecc71")
		style.set_border_width_all(4)
		style.bg_color = Color(0.16, 0.68, 0.44, 0.3)
		btn.modulate = Color(1, 1, 1, 1.0)
	elif is_reachable:
		var tc           := _get_type_color(n_data.type)
		style.border_color = tc
		btn.modulate = Color(1, 1, 1, 0.85)
	else:
		style.border_color = Color("222222")
		btn.modulate     = Color(1, 1, 1, 0.25)
	
	btn.add_theme_stylebox_override("normal",   style)
	btn.add_theme_stylebox_override("hover",    style)
	btn.add_theme_stylebox_override("pressed",  style)
	btn.add_theme_stylebox_override("disabled", style)

func _get_type_color(type: String) -> Color:
	match type:
		"GRASS":    return Color("4CAF50")
		"BAG":      return Color("f1c40f")
		"POKEBALL": return Color("e91e8c")
		"EVENT":    return Color("9b59b6")
		"TM":       return Color("3498db")
		"BOSS":     return Color("e74c3c")
		"START":    return Color("2ecc71")
		"STARTER":  return Color("e91e8c")
		"TRAINER":  return Color("e67e22")
	return Color("888888")

# ── Eventos de Nodo ──────────────────────────────────────────────────────────

func _on_node_selected(n_data: Dictionary) -> void:
	completed_nodes.append(n_data.id)
	current_layer = int(n_data.id.split("_")[0]) + 1
	_build_route_nodes()
	
	# Inyectar el trainer_map en el contexto del nodo si es de tipo TRAINER
	var context: Dictionary = n_data.duplicate()
	if n_data.type == "TRAINER" and node_trainer_map.has(n_data.id):
		var t_data: Dictionary = node_trainer_map[n_data.id]
		context["trainer_idx"] = t_data.trainer_idx
		context["pokemon"] = t_data.pokemon
		
	var event: NodeEvent = map_config.create_node_event(n_data)
	var result: Dictionary = event.execute(map_config, context)
	
	_handle_event_result(result)

func _handle_event_result(result: Dictionary) -> void:
	match result.get("type", ""):
		"starter":
			starter_requested.emit()
		"gift":
			gift_requested.emit(result.get("pool", []))
		"reward":
			var reward: Dictionary = result.get("reward", {})
			var notif: Dictionary = result.get("notification", {})
			if not notif.is_empty():
				_show_notification(notif.get("text", ""), notif.get("color", Color.WHITE))
			reward_earned.emit(reward)
		"notification":
			_show_notification(result.get("text", ""), result.get("color", Color.WHITE))
		"item_choice":
			item_choice_requested.emit(result.get("items", []))
		"battle":
			var mode: String = result.get("battle_mode", "HISTORIA")
			var details: Dictionary = result.get("details", {})
			start_battle.emit(mode, details)
		"none":
			pass

# ── Notificaciones flotantes ─────────────────────────────────────────────────

func _show_notification(text: String, color: Color) -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var notif := PanelContainer.new()
	var ns := StyleBoxFlat.new()
	ns.bg_color = Color("0d1117dd")
	ns.set_border_width_all(2)
	ns.border_color = color
	ns.set_corner_radius_all(10)
	notif.add_theme_stylebox_override("panel", ns)
	notif.custom_minimum_size = Vector2(240, 70)
	center.add_child(notif)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	notif.add_child(margin)
	
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", 13)
	margin.add_child(lbl)
	
	add_child(center)
	
	var tween := create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(center.queue_free)

# ── Dibujo de líneas de conexión entrecortadas (llamado por MapCanvas) ────────

func draw_map_paths(canvas: Control) -> void:
	if not canvas:
		return
	for layer in map_layers:
		for n_data in layer:
			for next_id in n_data.next:
				var target := _find_node_data(next_id)
				if not target.is_empty():
					var is_active := completed_nodes.has(n_data.id)
					var line_col  := Color("2ecc71") if is_active else Color(0.3, 0.4, 0.52, 0.8)
					var thickness := 3.0 if is_active else 2.0
					var dash_l   := 8.0 if is_active else 6.0
					var gap_l    := 5.0 if is_active else 6.0
					_draw_dashed_line(canvas, n_data.pos, target.pos, line_col, thickness, dash_l, gap_l)

func _draw_dashed_line(canvas: Control, from: Vector2, to: Vector2, color: Color, width: float, dash_len: float, gap_len: float) -> void:
	var diff := to - from
	var dist := diff.length()
	if dist < 0.001:
		return
	var dir := diff / dist
	var curr := 0.0
	var draw_segment := true
	while curr < dist:
		var step: float = dash_len if draw_segment else gap_len
		var next_pos: float = minf(curr + step, dist)
		if draw_segment:
			canvas.draw_line(from + dir * curr, from + dir * next_pos, color, width)
		curr = next_pos
		draw_segment = not draw_segment

func _find_node_data(n_id: String) -> Dictionary:
	for layer in map_layers:
		for n_data in layer:
			if n_data.id == n_id:
				return n_data
	return {}

# ── Aleatorización de Nodos y Modales de Confirmación ────────────────────────

func randomize_map_nodes(is_restart: bool = false) -> void:
	if is_restart:
		completed_nodes.clear()
		current_layer = 0
	
	node_trainer_map.clear()
	
	# Recoger todos los IDs de nodos intermedios (capas 1 a n-2)
	var all_node_ids: Array[String] = []
	for l_idx in range(1, map_layers.size() - 1):
		for n_data in map_layers[l_idx]:
			all_node_ids.append(n_data.id)
	
	# Elegir aleatoriamente hasta max_trainers nodos que serán TRAINER
	var trainer_slots: Array[String] = []
	var shuffled_ids := all_node_ids.duplicate()
	shuffled_ids.shuffle()
	for i in range(min(map_config.max_trainers, shuffled_ids.size())):
		trainer_slots.append(shuffled_ids[i])
	
	# Asignar entrenadores aleatorios sin repetir al inicio
	var trainer_classes := map_config.get_trainer_classes()
	var trainer_indices: Array[int] = []
	for i in range(trainer_classes.size()): trainer_indices.append(i)
	trainer_indices.shuffle()
	var tidx: int = 0
	for node_id in trainer_slots:
		var t_idx: int = trainer_indices[tidx % trainer_indices.size()]
		var trainer: TrainerClass = trainer_classes[t_idx]
		var pool: Array = trainer.pokemon_pool
		var chosen_poke: String = pool[randi() % pool.size()] if not pool.is_empty() else "Rattata"
		# Guardar índice del entrenador Y el Pokémon elegido
		node_trainer_map[node_id] = {"trainer_idx": t_idx, "pokemon": chosen_poke}
		tidx += 1
	
	# Asignar tipos a todos los nodos
	for l_idx in range(1, map_layers.size() - 1):
		for n_data in map_layers[l_idx]:
			var nid: String = n_data.id
			if nid in trainer_slots:
				n_data["type"] = "TRAINER"
				var t_data: Dictionary = node_trainer_map.get(nid, {})
				var t_idx: int = int(t_data.get("trainer_idx", 0))
				var trainer: TrainerClass = trainer_classes[t_idx % trainer_classes.size()]
				n_data["icon"]  = trainer.sprite_path
				n_data["label"] = trainer.display_name
			else:
				var possible_types := map_config.get_possible_node_types()
				var new_type: String = possible_types[randi() % possible_types.size()]
				n_data["type"] = new_type
				_update_node_icon_and_label(n_data, new_type)

	_build_route_nodes()
	
	if is_restart:
		route_restarted.emit()
		await get_tree().process_frame
		if scroll_container:
			scroll_container.scroll_vertical = 0

func _update_node_icon_and_label(n_data: Dictionary, type: String) -> void:
	match type:
		"STARTER":
			n_data["icon"] = map_config.icon_pokeball
			n_data["label"] = "¡Elige tu Starter!"
		"GRASS":
			n_data["icon"] = map_config.icon_grass
			n_data["label"] = "Hierba Alta"
		"BAG":
			n_data["icon"] = map_config.icon_bag
			n_data["label"] = "Bolso"
		"POKEBALL":
			n_data["icon"] = map_config.icon_pokeball
			n_data["label"] = "Pokébola"
		"EVENT":
			n_data["icon"] = map_config.icon_event
			n_data["label"] = "Evento ?"
		"TM":
			n_data["icon"] = map_config.icon_tm
			n_data["label"] = "MT"
		"BOSS":
			n_data["icon"] = map_config.icon_boss
			n_data["label"] = map_config.display_name
		"TRAINER":
			var t_data: Dictionary = node_trainer_map.get(n_data.id, {})
			var t_idx: int = int(t_data.get("trainer_idx", 0))
			var trainer_classes := map_config.get_trainer_classes()
			var trainer: TrainerClass = trainer_classes[t_idx % trainer_classes.size()]
			n_data["icon"]  = trainer.sprite_path
			n_data["label"] = trainer.display_name

func _show_confirmation_dialog(title_text: String, msg_text: String, confirm_btn_text: String, on_confirm: Callable) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.8)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var center_container := CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center_container)
	
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 160)
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color("11161d")
	ps.set_border_width_all(2)
	ps.border_color = Color("e74c3c")
	ps.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", ps)
	center_container.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var lbl_title := Label.new()
	lbl_title.text = title_text
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 15)
	lbl_title.add_theme_color_override("font_color", Color("e74c3c"))
	vbox.add_child(lbl_title)

	var lbl_msg := Label.new()
	lbl_msg.text = msg_text
	lbl_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_msg.add_theme_font_size_override("font_size", 12)
	lbl_msg.add_theme_color_override("font_color", Color("cccccc"))
	vbox.add_child(lbl_msg)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox)

	var btn_cancel := Button.new()
	btn_cancel.text = "SEGUIR JUGANDO"
	btn_cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_cancel.custom_minimum_size = Vector2(0, 36)
	btn_cancel.add_theme_font_size_override("font_size", 11)
	btn_cancel.pressed.connect(func(): overlay.queue_free())
	hbox.add_child(btn_cancel)

	var btn_confirm := Button.new()
	btn_confirm.text = confirm_btn_text
	btn_confirm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_confirm.custom_minimum_size = Vector2(0, 36)
	btn_confirm.add_theme_font_size_override("font_size", 11)
	var confirm_style := StyleBoxFlat.new()
	confirm_style.bg_color = Color("c03028")
	confirm_style.set_corner_radius_all(6)
	btn_confirm.add_theme_stylebox_override("normal", confirm_style)
	btn_confirm.pressed.connect(func():
		overlay.queue_free()
		on_confirm.call()
	)
	hbox.add_child(btn_confirm)

	add_child(overlay)
