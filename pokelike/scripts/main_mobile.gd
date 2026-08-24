# res://scripts/main_mobile.gd
extends Control

@onready var header_panel: PanelContainer = $TopHeader
@onready var lbl_level: Label = $TopHeader/Margin/HBox/Profile/VBox/LblLevel
@onready var lbl_gold: Label = $TopHeader/Margin/HBox/Resources/LblGold
@onready var lbl_gems: Label = $TopHeader/Margin/HBox/Resources/LblGems
@onready var lbl_energy: Label = $TopHeader/Margin/HBox/Resources/LblEnergy

@onready var screen_container: Control = $ScreenContainer

@onready var bottom_nav: PanelContainer = $BottomNav
@onready var btn_tab_party: Button = $BottomNav/Margin/HBox/BtnParty
@onready var btn_tab_bag: Button = $BottomNav/Margin/HBox/BtnBag

# Preload Scenes for Mobile Navigation
var scene_main_menu: PackedScene = preload("res://scenes/ui/main_menu_mobile.tscn")
var scene_story: PackedScene = preload("res://scenes/ui/story_mode_ui.tscn")
var scene_starter: PackedScene = preload("res://scenes/ui/starter_selection.tscn")
var scene_route_map: PackedScene = preload("res://scenes/ui/kanto_route_map.tscn")
var scene_colosseum: PackedScene = preload("res://scenes/ui/colosseum_mode_ui.tscn")
var scene_tower: PackedScene = preload("res://scenes/ui/battle_tower_ui.tscn")
var scene_battle: PackedScene = preload("res://scenes/ui/mobile_battle_ui.tscn")
var scene_gift: PackedScene = preload("res://scenes/ui/pokemon_gift_ui.tscn")
var scene_party_view: PackedScene = preload("res://scenes/ui/party_view_ui.tscn")
var scene_bag_view: PackedScene = preload("res://scenes/ui/bag_view_ui.tscn")

# Persistent game state
var chosen_starter: String = ""
var player_party: Array[Dictionary] = []  # Equipo actual (máx 6 Pokémon)
var player_attack_power: int = 50         # Empieza en 50% de potencia (50, 90, 120)
var player_inventory: Array[int] = []     # IDs de objetos en la mochila
var route_state: Dictionary = {}          # Persiste el mapa entre batallas
var pending_battle_reward: String = ""    # Recompensa pendiente al volver
var _nurse_heal_pending: bool = false     # Mostrar notificación de cura al volver al mapa

var active_screen_node: Node = null

func _ready() -> void:
	_apply_styles()
	_connect_nav()
	show_main_menu()

const UIManagerScript = preload("res://scripts/ui/ui_manager.gd")

func _apply_styles() -> void:
	if header_panel:
		header_panel.add_theme_stylebox_override("panel", UIManagerScript.create_pixel_stylebox(
			Color("11161d"), Color("2c3e50"), 0, 0
		))

func show_main_menu() -> void:
	if bottom_nav:
		bottom_nav.visible = false
	_clear_active_screen()
	var menu := scene_main_menu.instantiate()
	screen_container.add_child(menu)
	active_screen_node = menu
	menu.mode_selected.connect(_on_mode_selected)

func _on_mode_selected(mode_name: String) -> void:
	_clear_active_screen()
	match mode_name:
		"HISTORIA":
			var story_ui := scene_story.instantiate()
			screen_container.add_child(story_ui)
			active_screen_node = story_ui
			story_ui.back_pressed.connect(show_main_menu)
			story_ui.start_battle.connect(_on_story_region_selected)
		"COLISEO":
			var colosseum_ui := scene_colosseum.instantiate()
			screen_container.add_child(colosseum_ui)
			active_screen_node = colosseum_ui
			colosseum_ui.back_pressed.connect(show_main_menu)
			colosseum_ui.start_battle.connect(_launch_battle)
		"TORRE":
			var tower_ui := scene_tower.instantiate()
			screen_container.add_child(tower_ui)
			active_screen_node = tower_ui
			tower_ui.back_pressed.connect(show_main_menu)
			tower_ui.start_battle.connect(_launch_battle)

func _on_story_region_selected(_mode_name: String, _details: Dictionary) -> void:
	_show_route_map()

func _show_starter_selection() -> void:
	# Guardar estado del mapa si venimos de él
	if active_screen_node and active_screen_node.has_method("get_state"):
		route_state = active_screen_node.get_state()
	_clear_active_screen()
	var starter_ui := scene_starter.instantiate()
	screen_container.add_child(starter_ui)
	active_screen_node = starter_ui
	starter_ui.back_pressed.connect(func(): _show_route_map())
	starter_ui.starter_chosen.connect(func(pokemon_name: String):
		chosen_starter = pokemon_name
		var p_data := _find_pokemon_dictionary(pokemon_name)
		if player_party.size() < 6:
			player_party.append(p_data)
		print("[Starter]: ¡%s fue elegido como compañero inicial!" % pokemon_name)
		_show_route_map()
	)

func _show_route_map() -> void:
	if bottom_nav:
		bottom_nav.visible = true
	_clear_active_screen()
	var route_map := scene_route_map.instantiate()
	
	# Cargar e inyectar el MapConfig correcto según el estado de la ruta
	var map_id: String = route_state.get("map_id", "kanto_brock")
	var region := KantoRegion.new()
	var map_config := region.get_map_config(map_id)
	if map_config:
		route_map.map_config = map_config
		
	screen_container.add_child(route_map)
	active_screen_node = route_map
	route_map.back_pressed.connect(func():
		chosen_starter = ""
		player_party.clear()
		route_state.clear()
		_on_mode_selected("HISTORIA")
	)
	route_map.start_battle.connect(_launch_battle)
	route_map.reward_earned.connect(_on_reward_earned)
	route_map.gift_requested.connect(_show_gift_selection)
	route_map.starter_requested.connect(_show_starter_selection)
	route_map.item_choice_requested.connect(_show_item_choice)
	route_map.route_restarted.connect(func():
		chosen_starter = ""
		player_party.clear()
		route_state.clear()
		print("[Reinicio]: Se reinició la ruta y se vació el equipo de Pokémon. Mochila intacta.")
	)
	# Restaura el progreso del mapa si existe
	if not route_state.is_empty():
		route_map.restore_state(route_state)
	# Mostrar notificación de cura de enfermera si aplica
	if _nurse_heal_pending:
		_nurse_heal_pending = false
		await get_tree().process_frame
		if route_map and route_map.has_method("_show_notification"):
			route_map.call("_show_notification",
				"♥️ ¡La Enfermera te cuidó!\nTodo tu equipo fue curado al máximo.",
				Color("e91e8c")
			)

func _launch_battle(_mode_name: String, details: Dictionary) -> void:
	# Guarda el estado del mapa antes de salir
	if active_screen_node and active_screen_node.has_method("get_state"):
		route_state = active_screen_node.get_state()
	pending_battle_reward = details.get("reward_type", "none")
	
	var battle_details = details.duplicate()
	# Serializar player_party con held_item_id incluido
	var party_data: Array[Dictionary] = []
	for p in player_party:
		party_data.append(p if p is Dictionary else {})
	battle_details["player_party"] = party_data
	battle_details["player_pokemon"] = chosen_starter if not chosen_starter.is_empty() else "Bulbasaur"
	battle_details["player_attack_power"] = player_attack_power
	
	# Captura qué Pokémon estaban vivos ANTES de entrar al combate
	# (los que tengan hp > 0, o que aún no hayan sido debilitados)
	var pre_battle_alive: Array[bool] = []
	for p in player_party:
		var current_hp: int = int(p.get("current_hp", -1))
		if current_hp < 0:
			# Si no hay current_hp registrado, el Pokémon se considera vivo
			pre_battle_alive.append(true)
		else:
			pre_battle_alive.append(current_hp > 0)
	battle_details["pre_battle_alive"] = pre_battle_alive
	
	_clear_active_screen()
	var battle_ui := scene_battle.instantiate()
	screen_container.add_child(battle_ui)
	active_screen_node = battle_ui
	battle_ui.setup_battle(battle_details)
	battle_ui.battle_finished.connect(func(result: String, hp_report: Array):
		_on_battle_finished(result, battle_details, hp_report)
	)

func _on_battle_finished(result: String, battle_details: Dictionary = {}, hp_report: Array = []) -> void:
	# Guardar el HP resultante del combate
	for report in hp_report:
		var orig_idx: int = report.get("original_idx", -1)
		var new_hp: int = report.get("hp", 0)
		if orig_idx >= 0 and orig_idx < player_party.size():
			player_party[orig_idx]["current_hp"] = new_hp
			
	var reward: String = pending_battle_reward
	
	if (result == "VICTORY" or result == "WIN"):
		match reward:
			"level_up", "trainer_win":
				# 'level_up' (Hierba) da +1, 'trainer_win' (Entrenador) da +2
				var base_gain: int = 2 if reward == "trainer_win" else 1
				# Subir nivel a todos los Pokémon que estaban VIVOS antes de entrar al combate
				var pre_alive: Array = battle_details.get("pre_battle_alive", [])
				for i in range(player_party.size()):
					var was_alive: bool = true
					if i < pre_alive.size():
						was_alive = bool(pre_alive[i])
					if was_alive:
						var lvl_gain: int = base_gain
						# Lucky Egg: +1 nivel extra al ganar
						var p_item_id: int = int(player_party[i].get("held_item_id", 0))
						if p_item_id == 12:  # Huevo Suerte
							lvl_gain += 1
						var old_lvl: int = int(player_party[i].get("level", 1))
						player_party[i]["level"] = old_lvl + lvl_gain
						print("[Level Up]: %s subió al nivel %d! (+%d)" % [player_party[i].get("name", "?"), old_lvl + lvl_gain, lvl_gain])
					else:
						print("[Level Up]: %s estaba debilitado, no subió de nivel." % player_party[i].get("name", "?"))
			"nurse_heal":
				# La Enfermera cura todo el equipo
				for p in player_party:
					p["current_hp"] = -1   # -1 = HP pleno (se recalcula en el siguiente combate)
				print("[Curación]: ¡La Enfermera curó a todo tu equipo!")
				_nurse_heal_pending = true
	
	pending_battle_reward = ""
	
	if result == "DEFEAT":
		print("[Derrota]: ¡Tu equipo ha sido debilitado! Reiniciando partida...")
		chosen_starter = ""
		player_party.clear()
		route_state.clear()
		player_attack_power = 50
		_on_mode_selected("HISTORIA")
	else:
		_show_route_map()

func _show_gift_selection(gift_pool: Array) -> void:
	# Guardar estado del mapa antes de salir
	if active_screen_node and active_screen_node.has_method("get_state"):
		route_state = active_screen_node.get_state()
	_clear_active_screen()
	var gift_ui := scene_gift.instantiate()
	gift_ui.setup(gift_pool)
	screen_container.add_child(gift_ui)
	active_screen_node = gift_ui
	gift_ui.pokemon_chosen.connect(func(pokemon_name: String):
		if player_party.size() < 6:
			var p_data := _find_pokemon_dictionary(pokemon_name)
			player_party.append(p_data)
			print("[Regalo]: ¡%s fue recibido como Pokémon de regalo! (Equipo: %d/6)" % [pokemon_name, player_party.size()])
		else:
			print("[Regalo]: ¡Tu equipo ya está lleno! No puedes llevar a %s." % pokemon_name)
		_show_route_map()
	)
	gift_ui.gift_declined.connect(func():
		print("[Regalo]: El jugador rechazó el Pokémon de regalo.")
		_show_route_map()
	)

func _on_reward_earned(reward: Dictionary) -> void:
	var rtype: String = reward.get("type", "")
	match rtype:
		"tm_upgrade":
			if player_attack_power == 50:
				player_attack_power = 90
			elif player_attack_power == 90:
				player_attack_power = 120
			print("[Recompensa]: MT aplicada - el ataque del equipo subió de nivel a potencia %d" % player_attack_power)

func _clear_active_screen() -> void:
	for child in screen_container.get_children():
		child.queue_free()
	active_screen_node = null

func _connect_nav() -> void:
	if btn_tab_party:
		btn_tab_party.pressed.connect(_show_party_view)
	if btn_tab_bag:
		btn_tab_bag.pressed.connect(_show_bag_view)

func _show_party_view() -> void:
	if active_screen_node and active_screen_node.has_method("get_state"):
		route_state = active_screen_node.get_state()
	_clear_active_screen()
	var party_ui := scene_party_view.instantiate()
	party_ui.setup(player_party, player_inventory)
	screen_container.add_child(party_ui)
	active_screen_node = party_ui
	party_ui.back_pressed.connect(_show_route_map)
	party_ui.item_removed.connect(func(item_id: int, pokemon_index: int):
		_show_party_view()
	)

func _show_item_choice(items: Array) -> void:
	# Guardar estado del mapa si venimos de él
	if active_screen_node and active_screen_node.has_method("get_state"):
		route_state = active_screen_node.get_state()
	_clear_active_screen()
	var bag_ui := scene_bag_view.instantiate()
	bag_ui.setup_choice(items, player_party)
	screen_container.add_child(bag_ui)
	active_screen_node = bag_ui
	bag_ui.back_pressed.connect(_show_route_map)
	bag_ui.item_chosen.connect(func(item_id: int):
		player_inventory.append(item_id)
		var item_name: String = ItemRegistry.get_item_name(item_id)
		print("[Bolso]: ¡Objeto \"%s\" añadido a la mochila! (%d objetos)" % [item_name, player_inventory.size()])
		_show_route_map()
	)

func _show_bag_view() -> void:
	# Guardar estado del mapa si venimos de él
	if active_screen_node and active_screen_node.has_method("get_state"):
		route_state = active_screen_node.get_state()
	_clear_active_screen()
	var bag_ui := scene_bag_view.instantiate()
	bag_ui.setup_manage(player_inventory, player_party)
	screen_container.add_child(bag_ui)
	active_screen_node = bag_ui
	bag_ui.back_pressed.connect(_show_route_map)
	bag_ui.item_equipped.connect(func(item_id: int, pokemon_index: int):
		if pokemon_index >= 0 and pokemon_index < player_party.size():
			# Quitar el objeto anterior si ya tenía uno
			var old_item_id: int = int(player_party[pokemon_index].get("held_item_id", 0))
			if old_item_id > 0:
				player_inventory.append(old_item_id)
			# Equipar el nuevo objeto
			player_party[pokemon_index]["held_item_id"] = item_id
			# Quitar del inventario (solo una instancia)
			var idx: int = player_inventory.find(item_id)
			if idx >= 0:
				player_inventory.remove_at(idx)
			var item_name: String = ItemRegistry.get_item_name(item_id)
			var poke_name: String = String(player_party[pokemon_index].get("name", "?"))
			print("[Mochila]: %s equipó \"%s\"." % [poke_name, item_name])
			# Refrescar la UI
			_show_bag_view()
	)

func _find_pokemon_dictionary(p_name: String) -> Dictionary:
	var result: Dictionary = {}
	var brock_config = preload("res://scripts/world/regions/kanto/gym1_brock/brock_map_config.gd").new()
	for p in brock_config.get_gift_pool():
		if String(p.get("name", "")).nocasecmp_to(p_name) == 0:
			result = (p as Dictionary).duplicate()
			break
	if result.is_empty():
		result = {
			"pokedex_id": 0,
			"name": p_name,
			"types": [0],
			"stats": [50, 50, 50, 50, 50, 50],
			"sprite_path": "res://assets/sprites/pokemon/pokemon izquierda/%s.png" % p_name.to_upper()
		}
	if not result.has("level"):
		result["level"] = 5
	return result

func _show_toast(text: String) -> void:
	print("[UI Notification]: ", text)
