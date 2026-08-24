# res://scripts/ui/mobile_battle_ui.gd
# Combate automático por turnos con selección de orden previa al combate
extends Control

signal battle_finished(result: String, hp_report: Array)

const AttackAnimRegistryScript = preload("res://scripts/core/registry/attack_animation_registry.gd")
var _attack_anim_registry = null

# ─── Datos de estadísticas base ───────────────────────────────────────────────
const POKEDEX_BASE: Dictionary = {
	"BULBASAUR":  {"hp":45,"atk":49,"def":49,"spa":65,"spd":65,"spe":45,"types":[4]},
	"CHARMANDER": {"hp":39,"atk":52,"def":43,"spa":60,"spd":50,"spe":65,"types":[1]},
	"SQUIRTLE":   {"hp":44,"atk":48,"def":65,"spa":50,"spd":64,"spe":43,"types":[2]},
	"CATERPIE":   {"hp":45,"atk":30,"def":35,"spa":20,"spd":20,"spe":45,"types":[11]},
	"METAPOD":    {"hp":50,"atk":20,"def":55,"spa":25,"spd":25,"spe":30,"types":[11]},
	"WEEDLE":     {"hp":40,"atk":35,"def":30,"spa":20,"spd":20,"spe":50,"types":[7,11]},
	"PIDGEY":     {"hp":40,"atk":45,"def":40,"spa":35,"spd":35,"spe":56,"types":[9,0]},
	"RATTATA":    {"hp":30,"atk":56,"def":35,"spa":25,"spd":35,"spe":72,"types":[0]},
	"SPEAROW":    {"hp":40,"atk":60,"def":30,"spa":31,"spd":31,"spe":70,"types":[9,0]},
	"EKANS":      {"hp":35,"atk":60,"def":44,"spa":40,"spd":54,"spe":55,"types":[7]},
	"PIKACHU":    {"hp":35,"atk":55,"def":30,"spa":50,"spd":40,"spe":90,"types":[3]},
	"SANDSHREW":  {"hp":50,"atk":75,"def":85,"spa":20,"spd":30,"spe":40,"types":[8]},
	"NIDORAN♀":   {"hp":55,"atk":47,"def":52,"spa":40,"spd":40,"spe":41,"types":[7]},
	"NIDORAN♂":   {"hp":46,"atk":57,"def":40,"spa":40,"spd":40,"spe":50,"types":[7]},
	"CLEFAIRY":   {"hp":70,"atk":45,"def":48,"spa":60,"spd":65,"spe":35,"types":[17]},
	"VULPIX":     {"hp":38,"atk":41,"def":40,"spa":50,"spd":65,"spe":65,"types":[1]},
	"JIGGLYPUFF": {"hp":115,"atk":45,"def":20,"spa":45,"spd":25,"spe":20,"types":[0,17]},
	"ZUBAT":      {"hp":40,"atk":45,"def":35,"spa":30,"spd":40,"spe":55,"types":[7,9]},
	"ODDISH":     {"hp":45,"atk":50,"def":55,"spa":75,"spd":65,"spe":30,"types":[4,7]},
	"PARAS":      {"hp":35,"atk":70,"def":55,"spa":45,"spd":55,"spe":25,"types":[11,4]},
	"VENONAT":    {"hp":60,"atk":55,"def":50,"spa":40,"spd":55,"spe":45,"types":[11,7]},
	"DIGLETT":    {"hp":10,"atk":55,"def":25,"spa":35,"spd":45,"spe":95,"types":[8]},
	"MEOWTH":     {"hp":40,"atk":45,"def":35,"spa":40,"spd":40,"spe":90,"types":[0]},
	"PSYDUCK":    {"hp":50,"atk":52,"def":48,"spa":65,"spd":50,"spe":55,"types":[2]},
	"MANKEY":     {"hp":40,"atk":80,"def":35,"spa":35,"spd":45,"spe":70,"types":[6]},
	"GROWLITHE":  {"hp":55,"atk":70,"def":45,"spa":70,"spd":50,"spe":60,"types":[1]},
	"POLIWAG":    {"hp":40,"atk":50,"def":40,"spa":40,"spd":40,"spe":90,"types":[2]},
	"ABRA":       {"hp":25,"atk":20,"def":15,"spa":105,"spd":55,"spe":90,"types":[10]},
	"MACHOP":     {"hp":70,"atk":80,"def":50,"spa":35,"spd":35,"spe":35,"types":[6]},
	"BELLSPROUT": {"hp":50,"atk":75,"def":35,"spa":70,"spd":30,"spe":40,"types":[4,7]},
	"TENTACOOL":  {"hp":40,"atk":40,"def":35,"spa":50,"spd":100,"spe":70,"types":[2,7]},
	"GEODUDE":    {"hp":40,"atk":80,"def":100,"spa":30,"spd":30,"spe":20,"types":[12,8]},
	"PONYTA":     {"hp":50,"atk":85,"def":55,"spa":65,"spd":65,"spe":90,"types":[1]},
	"SLOWPOKE":   {"hp":90,"atk":65,"def":65,"spa":40,"spd":40,"spe":15,"types":[2,10]},
	"MAGNEMITE":  {"hp":25,"atk":35,"def":70,"spa":95,"spd":55,"spe":45,"types":[3,16]},
	"DODUO":      {"hp":35,"atk":85,"def":45,"spa":35,"spd":35,"spe":75,"types":[9,0]},
	"SEEL":       {"hp":65,"atk":45,"def":55,"spa":45,"spd":70,"spe":45,"types":[2]},
	"GRIMER":     {"hp":80,"atk":80,"def":50,"spa":40,"spd":50,"spe":25,"types":[7]},
	"SHELLDER":   {"hp":30,"atk":65,"def":100,"spa":45,"spd":25,"spe":40,"types":[2]},
	"GASTLY":     {"hp":30,"atk":35,"def":30,"spa":100,"spd":35,"spe":80,"types":[13,7]},
	"ONIX":       {"hp":35,"atk":45,"def":160,"spa":30,"spd":45,"spe":70,"types":[12,8]},
	"DROWZEE":    {"hp":60,"atk":48,"def":45,"spa":43,"spd":90,"spe":42,"types":[10]},
	"KRABBY":     {"hp":30,"atk":105,"def":90,"spa":25,"spd":25,"spe":50,"types":[2]},
	"VOLTORB":    {"hp":40,"atk":30,"def":50,"spa":55,"spd":55,"spe":100,"types":[3]},
	"EXEGGCUTE":  {"hp":60,"atk":40,"def":80,"spa":60,"spd":45,"spe":40,"types":[4,10]},
	"CUBONE":     {"hp":50,"atk":50,"def":95,"spa":40,"spd":50,"spe":35,"types":[8]},
	"KOFFING":    {"hp":40,"atk":65,"def":95,"spa":60,"spd":45,"spe":35,"types":[7]},
	"RHYHORN":    {"hp":80,"atk":85,"def":95,"spa":30,"spd":30,"spe":25,"types":[8,12]},
	"CHANSEY":    {"hp":250,"atk":5,"def":5,"spa":35,"spd":105,"spe":50,"types":[0]},
	"HORSEA":     {"hp":30,"atk":40,"def":70,"spa":70,"spd":25,"spe":60,"types":[2]},
	"GOLDEEN":    {"hp":45,"atk":67,"def":60,"spa":35,"spd":50,"spe":63,"types":[2]},
	"STARYU":     {"hp":30,"atk":45,"def":55,"spa":70,"spd":70,"spe":85,"types":[2]},
	"MAGIKARP":   {"hp":20,"atk":10,"def":55,"spa":15,"spd":20,"spe":80,"types":[2]},
	"EEVEE":      {"hp":55,"atk":55,"def":50,"spa":45,"spd":65,"spe":55,"types":[0]},
	"OMANYTE":    {"hp":35,"atk":40,"def":100,"spa":90,"spd":55,"spe":35,"types":[12,2]},
	"KABUTO":     {"hp":30,"atk":80,"def":90,"spa":55,"spd":45,"spe":55,"types":[12,2]},
}

const TYPE_CHART: Dictionary = {
	1:  {4:2.0, 2:0.5, 5:0.5, 12:0.5, 1:0.5, 14:0.5},
	2:  {1:2.0, 12:2.0, 8:2.0, 2:0.5, 4:0.5, 14:0.5},
	3:  {2:2.0, 9:2.0, 8:0.0, 4:0.5, 3:0.5, 14:0.5},
	4:  {2:2.0, 12:2.0, 8:2.0, 4:0.5, 1:0.5, 7:0.5, 9:0.5},
	6:  {0:2.0, 5:2.0, 12:2.0, 9:0.5, 7:0.5, 13:0.5},
	7:  {4:2.0, 0:0.5, 12:0.5, 13:0.0, 7:0.5},
	8:  {1:2.0, 12:2.0, 3:2.0, 7:2.0, 8:0.5, 4:0.5, 9:0.0},
	9:  {6:2.0, 11:2.0, 4:2.0, 12:0.5, 3:0.5},
	11: {4:2.0, 12:0.5, 6:0.5, 9:0.5, 13:0.5},
	12: {1:2.0, 9:2.0, 11:2.0, 6:0.5, 8:0.5, 2:0.5},
}

# ─── Estado ───────────────────────────────────────────────────────────────────
var player_team:  Array[Dictionary] = []
var enemy_team:   Array[Dictionary] = []
var active_p_idx: int = 0
var active_e_idx: int = 0
var turn_count:   int = 0
var _battle_over: bool = false
var _battle_started: bool = false
var _sprite_timers: Array[Timer] = []
var _battle_context: Dictionary = {}  # Datos del contexto de batalla (player_attack_power, etc.)

# ─── Estado de objetos durante la batalla ─────────────────────────────────────
var _metronome_counters: Dictionary = {}  # name → count de turnos usando metronomo
var _life_orb_boosts: Dictionary = {}     # name → boost acumulado por Life Orb

# ─── Drag & Drop reorder ──────────────────────────────────────────────────────
var _drag_item: Dictionary = {}       # El pokémon que se arrastra
var _drag_ghost: PanelContainer = null
var _drag_from_idx: int = -1
var _drag_offset: Vector2 = Vector2.ZERO
var _player_cards: Array = []         # Array de Dictionaries con info de card UI
var _party_indices: Array[int] = []   # Índice original en player_party para cada player_team[i]

# ─── Nodos UI construidos en código ──────────────────────────────────────────
var _root_vbox: VBoxContainer
var _header_hbox: HBoxContainer
var _lbl_title: Label
var _lbl_turn: Label
var _stage_hbox: HBoxContainer
var _player_scroll: ScrollContainer
var _player_vbox: VBoxContainer
var _enemy_scroll: ScrollContainer
var _enemy_vbox: VBoxContainer
var _log_panel: PanelContainer
var _lbl_log: Label
var _lbl_sublog: Label
var _btn_start: Button
var _lbl_hint: Label

# ─── Colores ──────────────────────────────────────────────────────────────────
const COL_BG      := Color("0a0d13")
const COL_PANEL   := Color("111720")
const COL_PLAYER  := Color("2ecc71")
const COL_ENEMY   := Color("e74c3c")
const COL_TEXT    := Color("ddeeff")
const COL_MUTED   := Color("6688aa")
const COL_YELLOW  := Color("f1c40f")

## Setup (llamado desde main_mobile.gd) ────────────────────────────────────────
func setup_battle(details: Dictionary) -> void:
	_battle_context = details.duplicate()
	var trainer_name: String = details.get("enemy_name", "Entrenador")

	player_team.clear()
	_party_indices.clear()
	_metronome_counters.clear()
	_life_orb_boosts.clear()
	var raw_party: Array = details.get("player_party", [])
	if raw_party.size() > 0:
		for i in range(raw_party.size()):
			var item = raw_party[i]
			var pname: String = String(item.get("name", "Bulbasaur")) if item is Dictionary else String(item)
			var plvl: int = int(item.get("level", 5)) if item is Dictionary else 5
			var poke := _build_pokemon(pname, plvl, true)
			# Guardar held_item_id
			if item is Dictionary:
				poke.held_item_id = int(item.get("held_item_id", 0))
			# Aplicar HP persistido si existe
			if item is Dictionary:
				var saved_hp: int = int(item.get("current_hp", -1))
				if saved_hp == 0:
					# Estaba debilitado antes del combate
					poke.hp = 0
					poke.fainted = true
				elif saved_hp > 0:
					# HP parcial persistido
					poke.hp = min(saved_hp, poke.max_hp)
				# saved_hp == -1 significa HP lleno (valor por defecto)
			player_team.append(poke)
			_party_indices.append(i)
	else:
		player_team.append(_build_pokemon(
			details.get("player_pokemon", "Bulbasaur"), 5, true))
		_party_indices.append(0)

	enemy_team.clear()
	# 1. Equipo de entrenador específico (nodo TRAINER)
	var trainer_team: Array = details.get("trainer_team", [])
	if trainer_team.size() > 0:
		for t_poke in trainer_team:
			var tname: String = String(t_poke.get("name", "Rattata")) if t_poke is Dictionary else String(t_poke)
			var tlvl: int = int(t_poke.get("level", 5)) if t_poke is Dictionary else 5
			enemy_team.append(_build_pokemon(tname, tlvl, false))
	# 2. Brock (jefe de gimnasio)
	elif "Brock" in trainer_name:
		enemy_team.append(_build_pokemon("Geodude", 12, false))
		enemy_team.append(_build_pokemon("Onix",    14, false))
	# 3. Pokémon salvaje
	else:
		var w: String = details.get("wild_name", "")
		if w.is_empty():
			w = details.get("enemy_pokemon", "Rattata").split(" ")[0]
		enemy_team.append(_build_pokemon(w, details.get("wild_level", 4), false))

	# Si _ready ya corrió, actualizar UI
	if is_inside_tree():
		_rebuild_ui()


func _ready() -> void:
	_build_full_ui()

# ─── Construcción de datos de Pokémon ─────────────────────────────────────────
func _build_pokemon(species: String, level: int, is_player: bool) -> Dictionary:
	var key := species.to_upper().strip_edges()
	var base: Dictionary = POKEDEX_BASE.get(key, {})
	if base.is_empty():
		base = {"hp":45,"atk":50,"def":45,"spa":45,"spd":45,"spe":45,"types":[0]}
	var hp_stat: int = int(float(2 * base.hp * level) / 100.0) + level + 10
	var atk_stat: int = int(float(2 * base.atk * level) / 100.0) + 5
	var def_stat: int = int(float(2 * base.def * level) / 100.0) + 5
	var spa_stat: int = int(float(2 * base.spa * level) / 100.0) + 5
	var spd_stat: int = int(float(2 * base.spd * level) / 100.0) + 5
	var poke_type: int = base.get("types", [0])[0]
	# Asignar ataque base según la stat ofensiva base más alta (sin escalar por nivel)
	var base_atk: int = base.get("atk", 50)
	var base_spa: int = base.get("spa", 50)
	var poke_category: int
	var poke_power: int = 50
	if base_spa >= base_atk:
		poke_category = Move.Category.SPECIAL
	else:
		poke_category = Move.Category.PHYSICAL
	var poke := {
		"name": species, "level": level, "is_player": is_player,
		"types": base.get("types", [0]),
		"hp": hp_stat, "max_hp": hp_stat,
		"atk": atk_stat, "def": def_stat,
		"spa": spa_stat, "spd": spd_stat,
		"spe": int(float(2 * base.spe * level) / 100.0) + 5,
		"fainted": false,
		"held_item_id": 0,
		"move_type": poke_type,
		"move_category": poke_category,
		"move_power": poke_power,
	}
	return poke

## Aplica los efectos pasivos del objeto equipado a un Pokémon del diccionario de batalla.
func _apply_held_item_passives(poke: Dictionary) -> void:
	var item_id: int = int(poke.get("held_item_id", 0))
	if item_id <= 0:
		return
	var item = ItemRegistry.get_item(item_id)
	if not item:
		return
	match item.effect_type:
		ItemRegistry.EffectType.STAT_BOOST_ATK:
			# Everstone: +50% ATK y ATK_SP
			poke.atk = int(poke.atk * (1.0 + item.effect_value))
			poke.spa = int(poke.spa * (1.0 + item.effect_value))
		ItemRegistry.EffectType.STAT_BOOST_DEF:
			# Eviolite: +50% DEF y DEF_SP
			poke.def = int(poke.def * (1.0 + item.effect_value))
			poke.spd = int(poke.spd * (1.0 + item.effect_value))

# ─── Construcción completa de UI ─────────────────────────────────────────────
func _build_full_ui() -> void:
	# Fondo
	var bg := ColorRect.new()
	bg.color = COL_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# VBox raíz que ocupa toda la pantalla
	_root_vbox = VBoxContainer.new()
	_root_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root_vbox.add_theme_constant_override("separation", 6)
	_root_vbox.add_theme_constant_override("margin_left", 0)
	add_child(_root_vbox)

	# ── Header ──────────────────────────────────────────────────────────────
	var header_margin := MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 10)
	header_margin.add_theme_constant_override("margin_right", 10)
	header_margin.add_theme_constant_override("margin_top", 8)
	_root_vbox.add_child(header_margin)

	_header_hbox = HBoxContainer.new()
	_header_hbox.add_theme_constant_override("separation", 8)
	header_margin.add_child(_header_hbox)



	_lbl_title = Label.new()
	_lbl_title.text = "⚔️  ORDENAR EQUIPO"
	_lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_title.add_theme_font_size_override("font_size", 15)
	_lbl_title.add_theme_color_override("font_color", COL_TEXT)
	_header_hbox.add_child(_lbl_title)

	_lbl_turn = Label.new()
	_lbl_turn.text = ""
	_lbl_turn.custom_minimum_size = Vector2(80, 0)
	_lbl_turn.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_turn.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lbl_turn.add_theme_font_size_override("font_size", 11)
	_lbl_turn.add_theme_color_override("font_color", COL_YELLOW)
	_header_hbox.add_child(_lbl_turn)

	# ── Hint (pre-batalla) ──────────────────────────────────────────────────
	_lbl_hint = Label.new()
	_lbl_hint.text = "↕  Arrastra las tarjetas para ordenar quién pelea primero"
	_lbl_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_hint.add_theme_font_size_override("font_size", 11)
	_lbl_hint.add_theme_color_override("font_color", COL_MUTED)
	_root_vbox.add_child(_lbl_hint)

	# ── Stage (dos columnas) ─────────────────────────────────────────────────
	_stage_hbox = HBoxContainer.new()
	_stage_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stage_hbox.add_theme_constant_override("separation", 8)
	var stage_margin := MarginContainer.new()
	stage_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage_margin.add_theme_constant_override("margin_left", 8)
	stage_margin.add_theme_constant_override("margin_right", 8)
	stage_margin.add_child(_stage_hbox)
	_root_vbox.add_child(stage_margin)

	# Columna Jugador
	var player_col := VBoxContainer.new()
	player_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_col.add_theme_constant_override("separation", 4)
	_stage_hbox.add_child(player_col)

	var lbl_p_header := Label.new()
	lbl_p_header.text = "TU EQUIPO"
	lbl_p_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_p_header.add_theme_font_size_override("font_size", 12)
	lbl_p_header.add_theme_color_override("font_color", COL_PLAYER)
	player_col.add_child(lbl_p_header)

	_player_scroll = ScrollContainer.new()
	_player_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_player_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	player_col.add_child(_player_scroll)

	_player_vbox = VBoxContainer.new()
	_player_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_player_vbox.add_theme_constant_override("separation", 6)
	_player_scroll.add_child(_player_vbox)

	# Columna Enemigo
	var enemy_col := VBoxContainer.new()
	enemy_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_col.add_theme_constant_override("separation", 4)
	_stage_hbox.add_child(enemy_col)

	var lbl_e_header := Label.new()
	lbl_e_header.text = "RIVAL"
	lbl_e_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_e_header.add_theme_font_size_override("font_size", 12)
	lbl_e_header.add_theme_color_override("font_color", COL_ENEMY)
	enemy_col.add_child(lbl_e_header)

	_enemy_scroll = ScrollContainer.new()
	_enemy_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_enemy_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	enemy_col.add_child(_enemy_scroll)

	_enemy_vbox = VBoxContainer.new()
	_enemy_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_enemy_vbox.add_theme_constant_override("separation", 6)
	_enemy_scroll.add_child(_enemy_vbox)

	# ── Log de combate ───────────────────────────────────────────────────────
	_log_panel = _make_panel(COL_PANEL, Color("334455"), 2)
	_log_panel.custom_minimum_size = Vector2(0, 70)
	var log_margin := MarginContainer.new()
	log_margin.add_theme_constant_override("margin_left", 8)
	log_margin.add_theme_constant_override("margin_right", 8)
	_log_panel.add_child(log_margin)
	var log_inner_margin := MarginContainer.new()
	log_inner_margin.add_theme_constant_override("margin_left", 10)
	log_inner_margin.add_theme_constant_override("margin_right", 10)
	log_inner_margin.add_theme_constant_override("margin_top", 8)
	log_inner_margin.add_theme_constant_override("margin_bottom", 8)
	var log_vbox := VBoxContainer.new()
	log_vbox.add_theme_constant_override("separation", 2)
	_lbl_log = Label.new()
	_lbl_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_log.add_theme_font_size_override("font_size", 13)
	_lbl_log.add_theme_color_override("font_color", COL_TEXT)
	_lbl_sublog = Label.new()
	_lbl_sublog.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_sublog.add_theme_font_size_override("font_size", 11)
	_lbl_sublog.add_theme_color_override("font_color", COL_MUTED)
	log_vbox.add_child(_lbl_log)
	log_vbox.add_child(_lbl_sublog)
	log_inner_margin.add_child(log_vbox)
	log_margin.add_child(log_inner_margin)
	_root_vbox.add_child(_log_panel)

	# ── Botón Start ──────────────────────────────────────────────────────────
	var btn_margin := MarginContainer.new()
	btn_margin.add_theme_constant_override("margin_left", 8)
	btn_margin.add_theme_constant_override("margin_right", 8)
	btn_margin.add_theme_constant_override("margin_bottom", 10)
	_btn_start = _make_button("▶  INICIAR COMBATE", Color("e74c3c"))
	_btn_start.custom_minimum_size = Vector2(0, 46)
	_btn_start.add_theme_font_size_override("font_size", 16)
	_btn_start.pressed.connect(_on_start_pressed)
	btn_margin.add_child(_btn_start)
	_root_vbox.add_child(btn_margin)

	_log("Ordena tu equipo y presiona INICIAR.", "")
	_rebuild_ui()

# ─── Reconstruir tarjetas de equipo ──────────────────────────────────────────
func _rebuild_ui() -> void:
	if not _player_vbox or not _enemy_vbox:
		return

	for c in _player_vbox.get_children(): c.queue_free()
	for c in _enemy_vbox.get_children():  c.queue_free()
	for t in _sprite_timers:
		if is_instance_valid(t): t.queue_free()
	_sprite_timers.clear()
	_player_cards.clear()

	for i in range(player_team.size()):
		var card_data := _add_team_card(player_team[i], _player_vbox, COL_PLAYER, i, true)
		_player_cards.append(card_data)

	for i in range(enemy_team.size()):
		_add_team_card(enemy_team[i], _enemy_vbox, COL_ENEMY, i, false)

func _add_team_card(p: Dictionary, parent: VBoxContainer, accent: Color, idx: int, is_player: bool) -> Dictionary:
	var card := _make_panel(COL_PANEL, accent.darkened(0.3), 2)
	card.custom_minimum_size = Vector2(0, 90)
	parent.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	margin.add_child(hbox)

	# Numero de orden (solo jugador)
	if is_player and not _battle_started:
		var order_lbl := Label.new()
		order_lbl.text = str(idx + 1)
		order_lbl.custom_minimum_size = Vector2(18, 0)
		order_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		order_lbl.add_theme_font_size_override("font_size", 18)
		order_lbl.add_theme_color_override("font_color",
			accent if idx == 0 else Color("667788"))
		hbox.add_child(order_lbl)

	# Sprite
	var sprite_holder := Control.new()
	sprite_holder.custom_minimum_size = Vector2(72, 72)
	hbox.add_child(sprite_holder)
	var tex := _load_sprite(p.name, p.is_player)
	if tex:
		_render_sprite(sprite_holder, tex)

	# Info vertical
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	hbox.add_child(info)

	var lbl_name := Label.new()
	lbl_name.text = "%s  Nv.%d" % [p.name.to_upper(), p.level]
	lbl_name.add_theme_font_size_override("font_size", 12)
	lbl_name.add_theme_color_override("font_color", accent)
	info.add_child(lbl_name)

	var lbl_stats := Label.new()
	var move_name: String = _get_move_display_name(p)
	lbl_stats.text = "%s | ATK:%d  DEF:%d  VEL:%d" % [move_name, p.atk, p.def, p.spe]
	lbl_stats.add_theme_font_size_override("font_size", 10)
	lbl_stats.add_theme_color_override("font_color", COL_MUTED)
	info.add_child(lbl_stats)

	# HP Bar
	var bar := ProgressBar.new()
	bar.max_value = float(p.max_hp)
	bar.value    = float(p.hp)
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 10)
	_style_hp_bar(bar, float(p.hp) / float(p.max_hp))
	info.add_child(bar)

	var lbl_hp := Label.new()
	lbl_hp.text = "%d / %d HP" % [p.hp, p.max_hp]
	lbl_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_hp.add_theme_font_size_override("font_size", 10)
	lbl_hp.add_theme_color_override("font_color", COL_MUTED)
	info.add_child(lbl_hp)

	# ── Drag handle (solo jugador pre-batalla) ────────────────────────────
	var card_data: Dictionary = {
		"p": p, "card": card, "bar": bar, "lbl_hp": lbl_hp,
		"sprite_holder": sprite_holder,
		"style": card.get_theme_stylebox("panel"),
	}

	if is_player and not _battle_started:
		# Flechas para reordenar en lugar de drag (más confiable en mobile)
		var btn_hbox := HBoxContainer.new()
		hbox.add_child(btn_hbox)

		var btn_up := Button.new()
		btn_up.text = "▲"
		btn_up.custom_minimum_size = Vector2(32, 32)
		btn_up.disabled = (idx == 0)
		btn_up.add_theme_font_size_override("font_size", 14)
		_style_small_btn(btn_up, Color("334466"))
		btn_up.pressed.connect(func(): _reorder(idx, idx - 1))
		btn_hbox.add_child(btn_up)

		var btn_dn := Button.new()
		btn_dn.text = "▼"
		btn_dn.custom_minimum_size = Vector2(32, 32)
		btn_dn.disabled = (idx >= player_team.size() - 1)
		btn_dn.add_theme_font_size_override("font_size", 14)
		_style_small_btn(btn_dn, Color("334466"))
		btn_dn.pressed.connect(func(): _reorder(idx, idx + 1))
		btn_hbox.add_child(btn_dn)

	return card_data

# ─── Reordenar equipo ─────────────────────────────────────────────────────────
func _reorder(from_idx: int, to_idx: int) -> void:
	if to_idx < 0 or to_idx >= player_team.size():
		return
	var tmp: Dictionary = player_team[from_idx]
	player_team[from_idx] = player_team[to_idx]
	player_team[to_idx]   = tmp
	# Sincronizar los índices originales
	if from_idx < _party_indices.size() and to_idx < _party_indices.size():
		var tmp_idx: int = _party_indices[from_idx]
		_party_indices[from_idx] = _party_indices[to_idx]
		_party_indices[to_idx]   = tmp_idx
	_rebuild_ui()

# ─── Inicio del combate ───────────────────────────────────────────────────────
func _on_start_pressed() -> void:
	_battle_started = true
	_battle_over    = false
	active_p_idx    = 0
	active_e_idx    = 0
	turn_count      = 0

	# Restaurar HP de enemigos (los jugadores ya tienen su HP correcto desde setup_battle)
	for e in enemy_team:  e.hp = e.max_hp; e.fainted = false

	# Aplicar efectos pasivos de objetos equipados
	for p in player_team: _apply_held_item_passives(p)
	for e in enemy_team: _apply_held_item_passives(e)

	_lbl_title.text = "⚔️  COMBATE AUTOMÁTICO"
	if _lbl_hint: _lbl_hint.visible = false
	if _btn_start: _btn_start.visible = false
	_rebuild_ui()
	_highlight_active()
	_log("¡Comienza el combate!", "El orden de turnos se basa en la Velocidad.")
	_schedule_turn(2.0)

# ─── Lógica de turnos ────────────────────────────────────────────────────────
func _schedule_turn(delay: float) -> void:
	if _battle_over: return
	var t := Timer.new()
	t.wait_time = delay
	t.one_shot  = true
	t.autostart = true
	add_child(t)
	t.timeout.connect(func():
		t.queue_free()
		_execute_turn()
	)

func _execute_turn() -> void:
	if _battle_over: return

	var pp: Dictionary = player_team[active_p_idx]
	var ep: Dictionary = enemy_team[active_e_idx]
	if pp.fainted or ep.fainted: _advance_active(); _schedule_turn(0.5); return

	turn_count += 1
	if _lbl_turn: _lbl_turn.text = "TURNO %d" % turn_count

	# 1. Primer ataque (el más rápido)
	if pp.spe >= ep.spe:
		await _do_attack(pp, ep, "Tu")
		_refresh_card(ep)
		if ep.hp <= 0:
			_on_enemy_fainted(); return
		await get_tree().create_timer(1.0).timeout
		if _battle_over: return

		await _do_attack(ep, pp, "El rival")
		_refresh_card(pp)
		if pp.hp <= 0:
			_on_player_fainted(); return
	else:
		await _do_attack(ep, pp, "El rival")
		_refresh_card(pp)
		if pp.hp <= 0:
			_on_player_fainted(); return
		await get_tree().create_timer(1.0).timeout
		if _battle_over: return

		await _do_attack(pp, ep, "Tu")
		_refresh_card(ep)
		if ep.hp <= 0:
			_on_enemy_fainted(); return

	# 2. Efectos de fin de turno (objetos)
	_apply_end_of_turn_effects(pp, ep)

	# 3. Siguiente turno
	_schedule_turn(1.5)

func _do_attack(attacker: Dictionary, defender: Dictionary, side: String) -> void:
	var a_type: int = int(attacker.get("move_type", 0))
	var a_cat: int = int(attacker.get("move_category", 0))
	var a_pow: int = int(attacker.get("move_power", 50))
	print("[Combate] %s usa %s (tipo:%d cat:%d pow:%d)" % [attacker.name.to_upper(), _get_move_display_name(attacker), a_type, a_cat, a_pow])
	# Reproducir animación del ataque en el defensor
	await _play_attack_animation(defender, a_type, a_cat, a_pow)

	var dmg := _calc_damage(attacker, defender)
	defender.hp = max(0, defender.hp - dmg)

	var eff := _type_effectiveness(int(attacker.types[0]) if attacker.types.size() > 0 else 0, defender.types)
	var eff_txt := ""
	if   eff >= 2.0: eff_txt = "¡Es muy efectivo! ×%.0f" % eff
	elif eff == 0.0: eff_txt = "No le afecta…"
	elif eff < 1.0:  eff_txt = "No es muy efectivo… (×%.1f)" % eff

	# Life Orb: cada vez que hace daño, +10% ATK/ATK_SP acumulable
	var atk_item_id: int = int(attacker.get("held_item_id", 0))
	if atk_item_id == 5:  # Life Orb
		var atk_name: String = String(attacker.get("name", ""))
		if not _life_orb_boosts.has(atk_name):
			_life_orb_boosts[atk_name] = 0.0
		_life_orb_boosts[atk_name] += 0.1
		attacker.atk = int(attacker.atk * 1.1)
		attacker.spa = int(attacker.spa * 1.1)
		eff_txt += " [Vidaesfera +10%]"

	# Metronomo: incrementar contador de turnos
	if atk_item_id == 7:  # Metronome
		var atk_name: String = String(attacker.get("name", ""))
		if not _metronome_counters.has(atk_name):
			_metronome_counters[atk_name] = 0
		_metronome_counters[atk_name] += 1

	_log(
		"%s %s usó %s → %d de daño a %s." % [side, attacker.name.to_upper(), _get_move_display_name(attacker), dmg, defender.name.to_upper()],
		eff_txt
	)
	_refresh_card(defender)

func _apply_end_of_turn_effects(player_poke: Dictionary, enemy_poke: Dictionary) -> void:
	# Aplicar efectos a ambos Pokémon vivos
	for poke in [player_poke, enemy_poke]:
		if poke.fainted or poke.hp <= 0:
			continue
		var item_id: int = int(poke.get("held_item_id", 0))
		if item_id <= 0:
			continue
		var item = ItemRegistry.get_item(item_id)
		if not item:
			continue
		var poke_name: String = String(poke.get("name", "?"))
		match item.effect_type:
			ItemRegistry.EffectType.HEAL_PER_TURN:
				# Restos: cura 10% HP
				var heal_amount: int = maxi(1, int(poke.max_hp * item.effect_value))
				if poke.hp < poke.max_hp:
					poke.hp = mini(poke.hp + heal_amount, poke.max_hp)
					_log("%s restauró %d HP." % [poke_name.to_upper(), heal_amount], "")
					_refresh_card(poke)
			ItemRegistry.EffectType.RECOIL_BOOST:
				# Vidaesfera: quita 5% HP al final del turno
				var recoil: int = maxi(1, int(poke.max_hp * 0.05))
				poke.hp = max(1, poke.hp - recoil)
				_log("%s perdió %d HP por Vidaesfera." % [poke_name.to_upper(), recoil], "")
				_refresh_card(poke)

func _calc_damage(atk: Dictionary, def: Dictionary) -> int:
	var move_power: int = int(atk.get("move_power", 50))
	var atk_stat: int = int(atk.atk)
	var def_stat: int = int(def.def)
	var atk_level: int = int(atk.level)
	def_stat = max(def_stat, 1)

	# Usar stat correcto según categoría del movimiento (físico → ATK, especial → SPA)
	var move_cat: int = int(atk.get("move_category", Move.Category.PHYSICAL))
	if move_cat == Move.Category.SPECIAL:
		atk_stat = int(atk.spa)

	# Aplicar boost de tipo del objeto equipado (Hard Stone, Metal Coat, etc.)
	var atk_item_id: int = int(atk.get("held_item_id", 0))
	if atk_item_id > 0:
		var atk_item = ItemRegistry.get_item(atk_item_id)
		if atk_item and atk_item.effect_type == ItemRegistry.EffectType.TYPE_BOOST:
			var atk_type: int = int(atk.types[0]) if atk.types.size() > 0 else 0
			if atk_type in atk_item.effect_types:
				move_power = int(move_power * (1.0 + atk_item.effect_value))

	# Aplicar boost acumulado de Metronomo
	var atk_name: String = String(atk.get("name", ""))
	if _metronome_counters.has(atk_name) and _metronome_counters[atk_name] > 0:
		var metro_boost: float = _metronome_counters[atk_name] * 0.1
		move_power = int(move_power * (1.0 + metro_boost))

	# Aplicar boost acumulado de Life Orb
	if _life_orb_boosts.has(atk_name) and _life_orb_boosts[atk_name] > 0:
		move_power = int(move_power * (1.0 + _life_orb_boosts[atk_name]))

	var base: float = float((2 * atk_level / 5 + 2) * move_power * atk_stat) / float(def_stat * 50) + 2.0
	base *= _type_effectiveness(int(atk.types[0]) if atk.types.size() > 0 else 0, def.types)
	base *= float(randi_range(85, 100)) / 100.0
	return max(1, int(base))

func _type_effectiveness(atk_type: int, def_types: Array) -> float:
	var m := 1.0
	var chart: Dictionary = TYPE_CHART.get(atk_type, {})
	for dt in def_types: m *= chart.get(int(dt), 1.0)
	return m

func _advance_active() -> void:
	if player_team[active_p_idx].fainted:
		var next_p: int = active_p_idx + 1
		while next_p < player_team.size() and player_team[next_p].fainted:
			next_p += 1
		if next_p < player_team.size():
			active_p_idx = next_p
	if enemy_team[active_e_idx].fainted:
		var next_e: int = active_e_idx + 1
		while next_e < enemy_team.size() and enemy_team[next_e].fainted:
			next_e += 1
		if next_e < enemy_team.size():
			active_e_idx = next_e

func _on_enemy_fainted() -> void:
	enemy_team[active_e_idx].fainted = true
	_refresh_card(enemy_team[active_e_idx])
	_log("¡%s rival fue derrotado! 💥" % enemy_team[active_e_idx].name.to_upper(), "")

	var next_e: int = active_e_idx + 1
	while next_e < enemy_team.size() and enemy_team[next_e].fainted: next_e += 1

	if next_e >= enemy_team.size():
		_battle_over = true
		await get_tree().create_timer(1.5).timeout
		_log("🎉 ¡Ganaste el combate!", "Todos los rivales fueron derrotados.")
		await get_tree().create_timer(2.0).timeout
		battle_finished.emit("VICTORY", _build_hp_report())
	else:
		active_e_idx = next_e
		_log("¡El rival envió a %s!" % enemy_team[active_e_idx].name.to_upper(), "")
		_highlight_active()
		_schedule_turn(1.8)

func _on_player_fainted() -> void:
	player_team[active_p_idx].fainted = true
	_refresh_card(player_team[active_p_idx])
	_log("¡Tu %s fue derrotado! 😭" % player_team[active_p_idx].name.to_upper(), "")

	var next_p: int = active_p_idx + 1
	while next_p < player_team.size() and player_team[next_p].fainted: next_p += 1

	if next_p >= player_team.size():
		_battle_over = true
		await get_tree().create_timer(1.5).timeout
		_log("😭 ¡Perdiste el combate!", "Todos tus Pokémon fueron derrotados.")
		await get_tree().create_timer(2.0).timeout
		battle_finished.emit("DEFEAT", _build_hp_report())
	else:
		active_p_idx = next_p
		_log("¡Adelante, %s!" % player_team[active_p_idx].name.to_upper(), "")
		_highlight_active()
		_schedule_turn(1.8)

func _build_hp_report() -> Array:
	var report: Array = []
	for i in range(player_team.size()):
		var p: Dictionary = player_team[i]
		var orig_idx: int = _party_indices[i] if i < _party_indices.size() else i
		report.append({"original_idx": orig_idx, "hp": p.hp})
	return report

# ─── Actualizar UI de una tarjeta ─────────────────────────────────────────────
func _refresh_card(p: Dictionary) -> void:
	# Buscar en _player_cards
	for cd in _player_cards:
		if cd.get("p") == p:
			_update_card_data(cd, p)
			return
	# Buscar en hijos del enemy_vbox
	_refresh_enemy_cards()

func _update_card_data(cd: Dictionary, p: Dictionary) -> void:
	var bar: ProgressBar = cd.get("bar")
	var lbl: Label       = cd.get("lbl_hp")
	if bar:
		bar.value = float(p.hp)
		_style_hp_bar(bar, float(p.hp) / float(p.max_hp))
	if lbl: lbl.text = "%d / %d HP" % [p.hp, p.max_hp]
	# Atenuar si debilitado
	var card: PanelContainer = cd.get("card")
	if card and p.fainted:
		var tw := create_tween()
		tw.tween_property(card, "modulate", Color(1,1,1,0.3), 0.5)

func _refresh_enemy_cards() -> void:
	if not _enemy_vbox: return
	for i in range(enemy_team.size()):
		if i >= _enemy_vbox.get_child_count(): break
		var card := _enemy_vbox.get_child(i)
		# Obtener bar y lbl del card
		var ep: Dictionary = enemy_team[i]
		# Recorrer la jerarquía buscando ProgressBar y Labels
		_refresh_card_children(card, ep)

func _refresh_card_children(node: Node, p: Dictionary) -> void:
	for child in node.get_children():
		if child is ProgressBar:
			child.value = float(p.hp)
			_style_hp_bar(child, float(p.hp) / float(p.max_hp))
		elif child is Label and "/" in child.text and "HP" in child.text:
			child.text = "%d / %d HP" % [p.hp, p.max_hp]
		_refresh_card_children(child, p)
	if node is PanelContainer and p.fainted:
		var tw := create_tween()
		tw.tween_property(node, "modulate", Color(1,1,1,0.3), 0.5)

# ─── Resaltar activo ──────────────────────────────────────────────────────────
func _highlight_active() -> void:
	for i in range(_player_cards.size()):
		var cd: Dictionary = _player_cards[i]
		var card := cd.get("card") as PanelContainer
		if not card: continue
		var s := StyleBoxFlat.new()
		s.bg_color = COL_PANEL
		s.set_corner_radius_all(8)
		if i == active_p_idx and not player_team[i].fainted:
			s.set_border_width_all(3)
			s.border_color = COL_PLAYER
		else:
			s.set_border_width_all(1)
			s.border_color = COL_PLAYER.darkened(0.5)
		card.add_theme_stylebox_override("panel", s)

	if not _enemy_vbox: return
	for i in range(enemy_team.size()):
		if i >= _enemy_vbox.get_child_count(): break
		var card := _enemy_vbox.get_child(i) as PanelContainer
		if not card: continue
		var s := StyleBoxFlat.new()
		s.bg_color = COL_PANEL
		s.set_corner_radius_all(8)
		if i == active_e_idx and not enemy_team[i].fainted:
			s.set_border_width_all(3)
			s.border_color = COL_ENEMY
		else:
			s.set_border_width_all(1)
			s.border_color = COL_ENEMY.darkened(0.5)
		card.add_theme_stylebox_override("panel", s)

# ─── Animaciones de ataque ───────────────────────────────────────────────────
func _get_attack_anim_registry() -> Dictionary:
	if _attack_anim_registry == null:
		_attack_anim_registry = AttackAnimRegistryScript.new()
	return _attack_anim_registry.anims

func _find_card_for_pokemon(p: Dictionary) -> Dictionary:
	for cd in _player_cards:
		if cd.get("p") == p:
			return cd
	# Buscar en tarjetas enemigas por nodo directo
	return {}

func _play_attack_animation(defender: Dictionary, move_type: int, move_category: int, move_power: int) -> void:
	var anims: Dictionary = _get_attack_anim_registry()
	if not anims.has(move_type):
		return
	if not anims[move_type].has(move_category):
		return
	var by_power: Dictionary = anims[move_type][move_category]
	var anim_data: Dictionary = {}
	# Buscar por potencia específica, luego fallback vacío
	var pkey := str(move_power)
	if by_power.has(pkey):
		anim_data = by_power[pkey]
	elif by_power.has(""):
		anim_data = by_power[""]
	if anim_data.is_empty():
		return

	var path: String = anim_data.get("path", "")
	if path == "" or not ResourceLoader.exists(path):
		return

	var tex := load(path) as Texture2D
	if tex == null:
		return

	var cols: int = anim_data.get("cols", 8)
	var rows: int = anim_data.get("rows", 6)
	var fps: float = anim_data.get("fps", 14.0)
	var frame_count: int = cols * rows
	var tex_w: int = tex.get_width()
	var tex_h: int = tex.get_height()
	var frame_w: float = tex_w / float(cols)
	var frame_h: float = tex_h / float(rows)

	# Encontrar el sprite_holder del defensor
	var sprite_holder: Control = null
	# Buscar en player_cards
	for cd in _player_cards:
		if cd.get("p") == defender:
			sprite_holder = cd.get("sprite_holder")
			break
	# Si no se encontró, buscar en enemy vbox
	if sprite_holder == null and _enemy_vbox:
		var enemy_idx := enemy_team.find(defender)
		if enemy_idx >= 0 and enemy_idx < _enemy_vbox.get_child_count():
			var card_node := _enemy_vbox.get_child(enemy_idx) as PanelContainer
			if card_node:
				sprite_holder = _find_sprite_holder_recursive(card_node)
	if sprite_holder == null:
		return

	# Crear overlay de animación según posición configurada
	var anim_rect := TextureRect.new()
	anim_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	anim_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var pos_type: String = anim_data.get("position", "full")
	match pos_type:
		"bottom":
			# Anclar a la parte inferior (patas del pokemon)
			anim_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			anim_rect.anchor_top = 0.5
			anim_rect.offset_top = 0
		"big":
			# Cubrir todo el sprite con margen extra
			anim_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			anim_rect.offset_left = -12
			anim_rect.offset_top = -12
			anim_rect.offset_right = 12
			anim_rect.offset_bottom = 12
		"centered":
			# Tamaño fijo centrado para sprites anchos
			var sz := Vector2(80, 40)
			anim_rect.custom_minimum_size = sz
			anim_rect.size = sz
			anim_rect.position = (sprite_holder.size - sz) / 2
		_:
			# "full" por defecto
			anim_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	anim_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anim_rect.z_index = 100
	sprite_holder.add_child(anim_rect)

	# Animar frames usando AtlasTexture
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(0, 0, frame_w, frame_h)
	anim_rect.texture = atlas

	var current_frame := 0
	var frame_duration: float = 1.0 / fps
	for i in range(frame_count):
		atlas.region = Rect2(
			float(i % cols) * frame_w,
			float(i / cols) * frame_h,
			frame_w, frame_h
		)
		await get_tree().create_timer(frame_duration).timeout
		if not is_instance_valid(anim_rect):
			return

	# Quitar overlay
	if is_instance_valid(anim_rect):
		anim_rect.queue_free()

func _find_sprite_holder_recursive(node: Node) -> Control:
	if node is Control and node.custom_minimum_size == Vector2(72, 72):
		return node
	for child in node.get_children():
		var result := _find_sprite_holder_recursive(child)
		if result:
			return result
	return null

func _get_move_display_name(p: Dictionary) -> String:
	var move_type: int = int(p.get("move_type", 0))
	var move_cat: int = int(p.get("move_category", 0))
	var move_power: int = int(p.get("move_power", 50))
	var m: Move = Move.get_move_by_type_category_power(move_type, move_cat, move_power)
	return m.move_name

# ─── Sprites ──────────────────────────────────────────────────────────────────
func _load_sprite(species: String, is_player: bool) -> Texture2D:
	var folder := "pokemon derecha" if is_player else "pokemon izquierda"
	var base := species.to_upper().strip_edges()
	if "NIDORAN" in base:
		if "♀" in species: base = "NIDORANfE"
		elif "♂" in species: base = "NIDORANM"
	for path in [
		"res://assets/sprites/pokemon/%s/%s.PNG" % [folder, base],
		"res://assets/sprites/pokemon/%s/%s.png" % [folder, base],
	]:
		if ResourceLoader.exists(path): return load(path)
	return null

func _render_sprite(container: Control, texture: Texture2D) -> void:
	for c in container.get_children(): c.queue_free()
	var tw := texture.get_width()
	var th := texture.get_height()
	var fcount: int = maxi(1, tw / max(th, 1))
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(0, 0, th, th)
	var tr := TextureRect.new()
	tr.texture = atlas
	tr.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_child(tr)
	if fcount > 1:
		var timer := Timer.new()
		timer.wait_time = 0.10
		timer.autostart = true
		add_child(timer)
		_sprite_timers.append(timer)
		var frame := [0]
		timer.timeout.connect(func():
			frame[0] = (frame[0] + 1) % fcount
			atlas.region = Rect2(frame[0] * th, 0, th, th)
		)

# ─── Helpers UI ───────────────────────────────────────────────────────────────
func _make_panel(bg: Color, border: Color, border_w: int) -> PanelContainer:
	var p := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_border_width_all(border_w)
	s.border_color = border
	s.set_corner_radius_all(8)
	p.add_theme_stylebox_override("panel", s)
	return p

func _make_button(txt: String, bg: Color) -> Button:
	var b := Button.new()
	b.text = txt
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(6)
	s.set_border_width_all(2)
	s.border_color = bg.lightened(0.3)
	s.content_margin_top    = 6
	s.content_margin_bottom = 6
	s.content_margin_left   = 10
	s.content_margin_right  = 10
	b.add_theme_stylebox_override("normal", s)
	var sh := StyleBoxFlat.new()
	sh.bg_color = bg.darkened(0.2)
	sh.set_corner_radius_all(6)
	sh.set_border_width_all(2)
	sh.border_color = bg.lightened(0.3)
	b.add_theme_stylebox_override("hover", sh)
	b.add_theme_color_override("font_color", Color("ffffff"))
	return b

func _style_small_btn(b: Button, bg: Color) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(4)
	s.set_border_width_all(1)
	s.border_color = bg.lightened(0.3)
	b.add_theme_stylebox_override("normal", s)
	b.add_theme_color_override("font_color", Color("ffffff"))

func _style_hp_bar(bar: ProgressBar, ratio: float) -> void:
	var fill_col: Color
	if   ratio > 0.5:  fill_col = Color("2ecc71")
	elif ratio > 0.25: fill_col = Color("f1c40f")
	else:              fill_col = Color("e74c3c")
	var bg_s := StyleBoxFlat.new()
	bg_s.bg_color = Color("1a2030")
	bg_s.set_corner_radius_all(3)
	var fill_s := StyleBoxFlat.new()
	fill_s.bg_color = fill_col
	fill_s.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg_s)
	bar.add_theme_stylebox_override("fill", fill_s)

func _log(main: String, sub: String) -> void:
	if _lbl_log:    _lbl_log.text    = main
	if _lbl_sublog: _lbl_sublog.text = sub
