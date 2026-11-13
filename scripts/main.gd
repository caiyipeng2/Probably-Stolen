extends Control

const FONT_PATH := "res://assets/fonts/fusion-pixel-12px-zh.ttf"
const ART_BG := "res://assets/art/shop_bg_window.png"
const ART_FG := "res://assets/art/shop_fg.png"
const C_BG := Color("#07090d")
const C_PANEL := Color("#171b24")
const C_PANEL2 := Color("#1e232e")
const C_LINE := Color("#3b4555")
const C_CYAN := Color("#63d8d2")
const C_AMBER := Color("#f0c05a")
const C_RUST := Color("#c05a3e")
const C_GREEN := Color("#7bd88f")
const C_TEXT := Color("#f2ecdd")
const C_MUTED := Color("#8d96a6")
const C_PAPER := Color("#e8dcc1")
const C_INK := Color("#2b2a25")

var font: FontFile
var game_view: Control
var bg_window: TextureRect
var customer_rect: TextureRect
var fg: TextureRect
var day_label: Label
var rent_label: Label
var cash_label: Label
var status_label: Label
var paper_goals: Label
var customer_name_label: Label
var customer_info_label: Label
var dialogue_name: Label
var dialogue_text: Label
var dialogue_hint: Label
var counter_icon: TextureRect
var counter_name: Label
var counter_price: Label
var counter_hint: Label
var display_root: Control
var grid_root: Control
var ledger_label: Label
var capacity_label: Label
var detail_panel: Panel
var detail_icon: TextureRect
var detail_name: Label
var detail_desc: Label
var detail_meta: Label
var detail_price: Label
var detail_rot_btn: Button
var detail_display_btn: Button
var detail_counter_btn: Button
var modal_layer: Control
var modal_panel: Panel
var modal_title: Label
var modal_text: Label
var modal_actions: HBoxContainer
var machine_layer: Control
var machine_list_box: VBoxContainer
var machine_scroll: ScrollContainer
var machine_name_label: Label
var machine_meta_label: Label
var machine_io_label: Label
var machine_module_label: Label
var machine_status_label: Label
var machine_jobs_label: Label
var machine_power_label: Label
var machine_start_btn: Button
var machine_repair_btn: Button
var machine_harvest_btn: Button
var minigame_layer: Control
var minigame_target_cells: Array = []
var minigame_cells: Array = []
var minigame_target: Array = []
var minigame_selected: Array = []
var minigame_status: Label
var mix_layer: Control
var mix_sliders: Array = []
var mix_value_labels: Array = []
var mix_target: Array = []
var mix_status: Label
var dna_layer: Control
var dna_target: Array = []
var dna_input: Array = []
var dna_target_label: Label
var dna_input_label: Label
var dna_status: Label
var temp_buttons: Array = []
var machine_list_buttons: Dictionary = {}
var selected_machine_id := ""
var machine_ui_timer := 0.0
var info_layer: Control
var info_title: Label
var info_tab := "network"
var info_list_box: VBoxContainer
var info_list_buttons: Dictionary = {}
var info_selected_id := ""
var info_name: Label
var info_meta: Label
var info_body: Label
var info_action: Button
var info_status: Label
var info_tab_buttons: Dictionary = {}
var archive_scroll: ScrollContainer
var archive_text: RichTextLabel
var archive_groups: Array = []
var story_layer: Control
var story_portrait: TextureRect
var story_name: Label
var story_text: Label
var story_choices: VBoxContainer
var story_node_id := ""
var combat_layer: Control
var combat_enemy_sprite: TextureRect
var combat_enemy_name: Label
var combat_enemy_bar: ProgressBar
var combat_player_bar: ProgressBar
var combat_log_label: Label
var combat_status: Label
var action_buttons: Dictionary = {}
var rail_buttons: Dictionary = {}
var rep_labels: Dictionary = {}
var tab_buttons: Dictionary = {}
var page_buttons: Array = []

var music_player: AudioStreamPlayer
var ambience_player: AudioStreamPlayer
var sfx_players: Array = []
var sfx_next := 0
var sfx_cache: Dictionary = {}
var audio_enabled := true
var audio_toggle_btn: Button
var force_public_assets := false

var selected_uid := -1
var current_page := 0
var filter_category := "all"
var dragging_uid := -1
var drag_icon: TextureButton
var drag_offset := Vector2.ZERO
var dragged := false
var bargain_price := 0
var welcome_shown := false
var last_summary: Dictionary = {}

func _ready() -> void:
	force_public_assets = "--publicassets" in OS.get_cmdline_args()
	_setup_theme()
	_setup_audio()
	_audioinfo_if_requested()
	_build_ui()
	GameState.state_changed.connect(_refresh)
	GameState.customer_changed.connect(_on_customer_changed)
	GameState.day_finished.connect(_on_day_finished)
	GameState.event_started.connect(_on_event_started)
	GameState.machine_finished.connect(_on_machine_finished)
	GameState.story_available.connect(_on_story_available)
	GameState.combat_started.connect(_on_combat_started)
	GameState.combat_updated.connect(_on_combat_updated)
	GameState.combat_finished.connect(_on_combat_finished)
	_refresh()
	_show_welcome()
	_capture_if_requested()
	_autotest_if_requested()
	_dumpui_if_requested()
	_dumpinspect_if_requested()
	_testminigame_if_requested()

func _dumpinspect_if_requested() -> void:
	if not "--dumpinspect" in OS.get_cmdline_args():
		return
	await get_tree().create_timer(0.3).timeout
	_close_modal()
	var c := GameState._gen_customer()
	var guard := 0
	while c.get("intent") != "sell" and guard < 50:
		c = GameState._gen_customer()
		guard += 1
	GameState.current_customer = c
	GameState.counter_item = c["item"]
	GameState.phase = "customer"
	_refresh()
	_open_inspection()
	await get_tree().process_frame
	print("INSPECT_MODAL ", modal_actions.get_global_rect())
	for b in modal_actions.get_children():
		if b is Button:
			print("IBTN ", b.text, " ", b.get_global_rect(), " disabled=", b.disabled)
	var first := modal_actions.get_child(0)
	if first is Button:
		print("CASH_BEFORE ", GameState.cash)
		first.pressed.emit()
		await get_tree().process_frame
		print("CASH_AFTER ", GameState.cash, " TEXT ", modal_text.text)
	get_tree().quit()


func _dumpui_if_requested() -> void:
	if not "--dumpui" in OS.get_cmdline_args():
		return
	await get_tree().create_timer(0.3).timeout
	_close_modal()
	_open_inspection()
	await get_tree().process_frame
	print("MODAL_ACTIONS ", modal_actions.get_global_rect())
	for b in modal_actions.get_children():
		if b is Button:
			print("BTN ", b.text, " ", b.get_global_rect())
	get_tree().quit()


func _autotest_if_requested() -> void:
	if not "--autotest" in OS.get_cmdline_args():
		return
	await get_tree().create_timer(0.4).timeout
	_welcome_done()
	await get_tree().process_frame
	var guard_story := 0
	while story_layer.visible and guard_story < 40:
		_story_advance()
		guard_story += 1
	if modal_layer.visible:
		_close_modal()
	var c := GameState.current_customer
	print("AUTOTEST start day=", GameState.day, " cash=", GameState.cash, " intent=", c.get("intent", "?"))
	if c.get("intent") == "buy":
		var uid := int(GameState.inventory[0]["uid"])
		GameState.add_to_display(uid)
		GameState.put_display_on_counter(uid)
		_refresh()
		print("AUTOTEST buyer offer=", c.get("offer", 0), " max=", c.get("max_price", 0))
		bargain_price = int(c.get("offer", 0))
		_refresh_bargain_modal()
		_bargain_confirm()
		print("AUTOTEST buyer done cash=", GameState.cash, " modal=", modal_text.text)
	else:
		var uid2 := int(GameState.counter_item.get("uid", -1))
		print("AUTOTEST clue1=", GameState.inspect_item(uid2, 0))
		print("AUTOTEST clue2=", GameState.inspect_item(uid2, 1))
		_refresh()
		bargain_price = int(GameState.counter_item.get("asking_price", 0))
		_refresh_bargain_modal()
		_bargain_confirm()
		print("AUTOTEST seller done cash=", GameState.cash, " inv=", GameState.inventory.size(), " modal=", modal_text.text)
	var s := GameState.finish_day()
	print("AUTOTEST summary=", s)
	_next_day()
	print("AUTOTEST next day=", GameState.day, " customers=", GameState.customers_today.size())
	_refresh()
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()


func _testminigame_if_requested() -> void:
	if not "--testminigame" in OS.get_cmdline_args():
		return
	await get_tree().create_timer(0.5).timeout
	_welcome_done()
	await get_tree().create_timer(0.1).timeout
	var guard := 0
	while story_layer.visible and guard < 40:
		_story_advance()
		guard += 1
	if modal_layer.visible:
		_close_modal()
	if GameState.inventory_count("metal_ingot") < 1:
		GameState.add_item(GameState.make_item("metal_ingot", 100, true, false))
	selected_machine_id = "printer"
	_open_printer_minigame()
	_confirm_minigame()
	print("MINIGAME fail_status=", minigame_status.text, " jobs=", GameState.machine_jobs.size())
	for i in range(16):
		minigame_selected[i] = int(minigame_target[i]) == 1
		minigame_cells[i].button_pressed = minigame_selected[i]
	_confirm_minigame()
	print("MINIGAME printer_jobs=", GameState.machine_jobs.size(), " status=", machine_status_label.text)
	selected_machine_id = "chem_mixer"
	_open_mix_minigame()
	for i in range(3):
		mix_sliders[i].set_value_no_signal(float(mix_target[i]))
	_confirm_mix()
	print("MINIGAME mix_jobs=", GameState.machine_jobs.size(), " status=", machine_status_label.text)
	selected_machine_id = "dna_lab"
	_open_dna_minigame()
	dna_input = dna_target.duplicate()
	dna_input_label.text = "你的序列： " + " ".join(dna_input)
	_confirm_dna()
	print("MINIGAME dna_jobs=", GameState.machine_jobs.size(), " status=", machine_status_label.text)
	get_tree().quit()

func _capture_if_requested() -> void:
	if "--capturearchive" in OS.get_cmdline_args():
		await get_tree().create_timer(1.0).timeout
		_welcome_done()
		await get_tree().create_timer(0.2).timeout
		var aguard := 0
		while story_layer.visible and aguard < 40:
			_story_advance()
			aguard += 1
		if modal_layer.visible:
			_close_modal()
		_open_info_tab("archive")
		await get_tree().create_timer(0.3).timeout
		var aimg := get_viewport().get_texture().get_image()
		aimg.save_png("res://_research/mockups/phone/m16_archive.png")
		get_tree().quit()
		return
	if "--captureminigame" in OS.get_cmdline_args():
		await get_tree().create_timer(1.0).timeout
		_welcome_done()
		await get_tree().create_timer(0.2).timeout
		var mguard := 0
		while story_layer.visible and mguard < 40:
			_story_advance()
			mguard += 1
		if modal_layer.visible:
			_close_modal()
		_open_printer_minigame()
		await get_tree().create_timer(0.3).timeout
		var mimg := get_viewport().get_texture().get_image()
		mimg.save_png("res://_research/mockups/phone/m7_minigame.png")
		get_tree().quit()
		return
	if "--capturetutorial" in OS.get_cmdline_args():
		await get_tree().create_timer(1.0).timeout
		_welcome_done()
		await get_tree().create_timer(0.2).timeout
		var guard := 0
		while story_layer.visible and guard < 40:
			_story_advance()
			guard += 1
		await get_tree().create_timer(0.3).timeout
		var timg := get_viewport().get_texture().get_image()
		timg.save_png("res://_research/mockups/phone/m6_tutorial.png")
		get_tree().quit()
		return
	if "--capturestory" in OS.get_cmdline_args():
		await get_tree().create_timer(1.0).timeout
		_welcome_done()
		await get_tree().create_timer(0.3).timeout
		var simg := get_viewport().get_texture().get_image()
		simg.save_png("res://_research/mockups/phone/m6_story.png")
		get_tree().quit()
		return
	if not "--capture" in OS.get_cmdline_args():
		return
	await get_tree().create_timer(1.0).timeout
	_close_modal()
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	img.save_png("res://_research/mockups/phone/m1_ui.png")
	get_tree().quit()

func _setup_theme() -> void:
	font = load(FONT_PATH)
	if font:
		font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		var th := Theme.new()
		th.default_font = font
		th.default_font_size = 30
		theme = th

func _audioinfo_if_requested() -> void:
	if not "--audioinfo" in OS.get_cmdline_args():
		return
	print("AUDIO music=", _audio_path("music_main.ogg"), " len=", music_player.stream.get_length() if music_player.stream else 0.0)
	print("AUDIO ambience=", _audio_path("ambience_station.ogg"), " len=", ambience_player.stream.get_length() if ambience_player.stream else 0.0)
	for key in ["click", "cash", "fail", "bell", "page", "shutter", "machine", "drink", "gun", "hit", "water", "soft"]:
		print("AUDIO sfx=", key, " path=", _audio_path("sfx_%s.ogg" % key))
	get_tree().quit()

func _setup_audio() -> void:
	var cfg := FileAccess.open("user://audio.json", FileAccess.READ)
	if cfg:
		var data = JSON.parse_string(cfg.get_as_text())
		if data is Dictionary:
			audio_enabled = bool(data.get("enabled", true))
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -18.0
	add_child(music_player)
	var music_path := _audio_path("music_main.ogg")
	if music_path != "":
		music_player.stream = load(music_path)
		if audio_enabled:
			music_player.play()
	ambience_player = AudioStreamPlayer.new()
	ambience_player.volume_db = -22.0
	add_child(ambience_player)
	var amb_path := _audio_path("ambience_station.ogg")
	if amb_path != "":
		ambience_player.stream = load(amb_path)
		if audio_enabled:
			ambience_player.play()
	for i in range(4):
		var p := AudioStreamPlayer.new()
		p.volume_db = -8.0
		add_child(p)
		sfx_players.append(p)

func _audio_path(name: String) -> String:
	var private_path := "res://assets_private/audio/" + name
	var public_path := "res://assets_public/audio/" + name
	if force_public_assets:
		return public_path if ResourceLoader.exists(public_path) else ""
	if ResourceLoader.exists(private_path):
		return private_path
	return public_path if ResourceLoader.exists(public_path) else ""

func _play_sfx(key: String) -> void:
	if not audio_enabled or sfx_players.is_empty():
		return
	var path := _audio_path("sfx_%s.ogg" % key)
	if path == "":
		return
	if not sfx_cache.has(path):
		sfx_cache[path] = load(path)
	var p: AudioStreamPlayer = sfx_players[sfx_next % sfx_players.size()]
	sfx_next += 1
	p.stream = sfx_cache[path]
	p.play()

func _save_audio_setting() -> void:
	var f := FileAccess.open("user://audio.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"enabled": audio_enabled}))
		f.close()

func _on_audio_toggle() -> void:
	audio_enabled = not audio_enabled
	if music_player:
		if audio_enabled and music_player.stream:
			music_player.play()
		else:
			music_player.stop()
	if ambience_player:
		if audio_enabled and ambience_player.stream:
			ambience_player.play()
		else:
			ambience_player.stop()
	if audio_toggle_btn:
		audio_toggle_btn.text = "音效 开" if audio_enabled else "音效 关"
	_save_audio_setting()

func _style(bg: Color, border: Color, bw: int = 2) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_left = bw
	sb.border_width_right = bw
	sb.border_width_top = bw
	sb.border_width_bottom = bw
	return sb

func _panel(parent: Node, pos: Vector2, size: Vector2, bg: Color, border: Color, bw: int = 2) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = size
	p.add_theme_stylebox_override("panel", _style(bg, border, bw))
	parent.add_child(p)
	return p

func _label(parent: Node, text: String, pos: Vector2, size: Vector2, fs: int, color: Color, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = size
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(l)
	return l

func _button(parent: Node, text: String, pos: Vector2, size: Vector2, color: Color, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 26)
	b.add_theme_color_override("font_color", color)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", C_MUTED)
	b.add_theme_stylebox_override("normal", _style(C_PANEL2, C_LINE))
	b.add_theme_stylebox_override("hover", _style(Color("#252c38"), color))
	b.add_theme_stylebox_override("pressed", _style(Color("#0f1218"), color))
	b.add_theme_stylebox_override("disabled", _style(Color("#12151c"), Color("#252c38")))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.pressed.connect(cb)
	b.pressed.connect(_play_sfx.bind("click"))
	parent.add_child(b)
	return b

func _art_path(name: String) -> String:
	var private_path := "res://assets/art/" + name
	var public_path := "res://assets_public/art/" + name
	if force_public_assets:
		return public_path if ResourceLoader.exists(public_path) else private_path
	return private_path if ResourceLoader.exists(private_path) else public_path

func _customer_path(sprite: String) -> String:
	if sprite == "":
		return ""
	var private_path := "res://assets/customers/" + sprite
	var public_path := "res://assets_public/customers/" + sprite
	if force_public_assets or not ResourceLoader.exists(private_path):
		if ResourceLoader.exists(public_path):
			return public_path
		var fallback := "res://assets_public/customers/default.png"
		if ResourceLoader.exists(fallback):
			return fallback
	return private_path

func _texture_rect(parent: Node, pos: Vector2, size: Vector2, path: String) -> TextureRect:
	var tr := TextureRect.new()
	tr.position = pos
	tr.size = size
	tr.texture = load(path) if ResourceLoader.exists(path) else null
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(tr)
	return tr

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	game_view = Control.new()
	game_view.position = Vector2(210, 0)
	game_view.size = Vector2(1920, 1080)
	add_child(game_view)

	var back := ColorRect.new()
	back.color = Color("#0b0e14")
	back.size = Vector2(1920, 1080)
	game_view.add_child(back)
	bg_window = _texture_rect(game_view, Vector2.ZERO, Vector2(1920, 1080), _art_path("shop_bg_window.png"))
	customer_rect = _texture_rect(game_view, Vector2(635, 5), Vector2(677, 496), _customer_path("maleUpper_0.png"))
	fg = _texture_rect(game_view, Vector2.ZERO, Vector2(1920, 1080), _art_path("shop_fg.png"))
	var glass := ColorRect.new()
	glass.position = Vector2(650, 5)
	glass.size = Vector2(630, 515)
	glass.color = Color(0.35, 0.9, 0.9, 0.035)
	game_view.add_child(glass)

	_build_hud()
	_build_left_rail()
	_build_right_rail()
	_build_paper_note()
	_build_customer_card()
	_build_dialogue()
	_build_counter()
	_build_drawer()
	_build_modal()
	_build_machine_bay()
	_build_info_bay()
	_build_story_layer()
	_build_combat_layer()
	_build_minigame_layer()
	_build_mix_layer()
	_build_dna_layer()

func _build_hud() -> void:
	_panel(self, Vector2.ZERO, Vector2(2340, 80), C_PANEL, C_LINE)
	_label(self, "深空当铺", Vector2(24, 8), Vector2(300, 48), 36, C_AMBER)
	_label(self, "MOBILE PORT · M18", Vector2(26, 50), Vector2(300, 22), 16, C_MUTED)
	day_label = _label(self, "", Vector2(360, 18), Vector2(320, 42), 30, C_TEXT)
	rent_label = _label(self, "", Vector2(700, 18), Vector2(520, 42), 30, C_AMBER)
	_label(self, "信用点", Vector2(1560, 8), Vector2(200, 22), 18, C_MUTED)
	cash_label = _label(self, "", Vector2(1560, 24), Vector2(350, 52), 48, C_AMBER, HORIZONTAL_ALIGNMENT_RIGHT)
	audio_toggle_btn = _button(self, "音效 开" if audio_enabled else "音效 关", Vector2(1925, 14), Vector2(120, 52), C_MUTED, _on_audio_toggle)
	_button(self, "存档", Vector2(2060, 14), Vector2(120, 52), C_CYAN, _on_save)
	_button(self, "读档", Vector2(2190, 14), Vector2(120, 52), C_CYAN, _on_load)

func _build_left_rail() -> void:
	var rail := _panel(self, Vector2(0, 80), Vector2(210, 670), C_PANEL, C_LINE)
	_label(rail, "店铺", Vector2(20, 14), Vector2(170, 32), 24, C_AMBER)
	var items := [
		["顾客", "customers"], ["库存", "inventory"], ["网络", "network"],
		["手机", "phone"], ["机器", "machines"], ["派系", "factions"], ["档案", "ledger"], ["结束营业", "end_day"],
	]
	for i in range(items.size()):
		var key: String = items[i][1]
		var color := C_TEXT
		if key == "end_day":
			color = C_RUST
		var b := _button(rail, items[i][0], Vector2(20, 50 + i * 64), Vector2(170, 56), color, _on_rail.bind(key))
		rail_buttons[key] = b
	status_label = _label(rail, "营业中", Vector2(20, 606), Vector2(170, 44), 20, C_GREEN)

func _build_right_rail() -> void:
	var rail := _panel(self, Vector2(2130, 80), Vector2(210, 670), C_PANEL, C_LINE)
	_label(rail, "交涉", Vector2(20, 14), Vector2(170, 32), 24, C_AMBER)
	var actions := [
		["鉴定", "inspect", C_CYAN], ["议价", "bargain", C_AMBER], ["威胁", "threaten", C_RUST],
		["成交", "deal", C_GREEN], ["送客", "dismiss", C_MUTED],
	]
	for i in range(actions.size()):
		var key: String = actions[i][1]
		var b := _button(rail, actions[i][0], Vector2(20, 54 + i * 90), Vector2(170, 80), actions[i][2], _on_action.bind(key))
		action_buttons[key] = b
	_label(rail, "派系声望", Vector2(20, 500), Vector2(170, 24), 17, C_MUTED)
	var reps := [["lower", "下层", C_AMBER], ["upper", "上层", C_TEXT], ["security", "治安", C_CYAN], ["blackmarket", "黑市", C_RUST], ["rev", "革命", C_GREEN], ["tourist", "游客", Color("#b58cff")], ["church", "教会", C_PAPER], ["cartel", "卡特尔", Color("#d08050")]]
	for i in range(reps.size()):
		rep_labels[reps[i][0]] = _label(rail, "", Vector2(12 + (i % 2) * 100, 526 + (i / 2) * 26), Vector2(96, 22), 14, reps[i][2])


func _build_paper_note() -> void:
	var p := _panel(game_view, Vector2(40, 104), Vector2(310, 260), C_PAPER, Color("#b9a98a"), 3)
	_label(p, "今日目标", Vector2(18, 10), Vector2(200, 40), 30, C_INK)
	paper_goals = _label(p, "", Vector2(18, 58), Vector2(274, 186), 22, C_INK)
	var stamp := _panel(p, Vector2(216, 12), Vector2(76, 76), Color(0, 0, 0, 0), C_RUST, 3)
	stamp.rotation = -0.16
	_label(stamp, "营", Vector2(0, 8), Vector2(76, 60), 42, C_RUST, HORIZONTAL_ALIGNMENT_CENTER)

func _build_customer_card() -> void:
	var p := _panel(game_view, Vector2(40, 372), Vector2(340, 180), C_PANEL, C_LINE)
	_label(p, "顾客", Vector2(14, 8), Vector2(60, 26), 20, C_AMBER)
	customer_name_label = _label(p, "", Vector2(14, 36), Vector2(312, 38), 28, C_TEXT)
	customer_info_label = _label(p, "", Vector2(14, 82), Vector2(312, 88), 20, C_MUTED)

func _build_dialogue() -> void:
	var p := _panel(game_view, Vector2(1280, 170), Vector2(560, 220), C_PANEL, C_CYAN, 2)
	dialogue_name = _label(p, "", Vector2(16, 10), Vector2(528, 32), 24, C_AMBER)
	dialogue_text = _label(p, "", Vector2(16, 48), Vector2(528, 118), 28, C_TEXT)
	dialogue_hint = _label(p, "右侧选择交涉动作 · 长按物品查看详情", Vector2(16, 178), Vector2(528, 26), 20, C_MUTED)

func _build_counter() -> void:
	var p := _panel(game_view, Vector2(0, 560), Vector2(1920, 190), C_PANEL, C_RUST, 3)
	_label(p, "交易台 · COUNTER", Vector2(20, 10), Vector2(320, 34), 28, C_AMBER)
	counter_icon = _texture_rect(p, Vector2(30, 50), Vector2(100, 100), "")
	counter_name = _label(p, "", Vector2(150, 46), Vector2(500, 36), 30, C_TEXT)
	counter_price = _label(p, "", Vector2(150, 86), Vector2(500, 34), 26, C_AMBER)
	counter_hint = _label(p, "", Vector2(150, 124), Vector2(580, 44), 20, C_MUTED)
	_label(p, "展示柜", Vector2(760, 10), Vector2(200, 30), 24, C_AMBER)
	display_root = Control.new()
	display_root.position = Vector2(760, 44)
	display_root.size = Vector2(1130, 140)
	p.add_child(display_root)

func _build_drawer() -> void:
	var p := _panel(self, Vector2(0, 750), Vector2(2340, 330), C_PANEL, C_LINE, 2)
	var top := ColorRect.new()
	top.color = C_RUST
	top.position = Vector2(0, 0)
	top.size = Vector2(2340, 6)
	p.add_child(top)
	_label(p, "柜台 · COUNTER", Vector2(24, 12), Vector2(300, 40), 30, C_TEXT)
	var tabs := [["全部", "all"], ["武器", "weapon"], ["改装", "weapon_mod"], ["义体", "cyber"], ["医疗", "medical"], ["化学", "chem"], ["食物", "food"], ["文书", "document"], ["材料", "material"], ["模块", "module"], ["杂物", "misc"]]
	for i in range(tabs.size()):
		var b := _button(p, tabs[i][0], Vector2(300 + i * 106, 10), Vector2(100, 44), C_MUTED, _set_filter.bind(tabs[i][1]))
		tab_buttons[tabs[i][1]] = b
	for i in range(3):
		var pb := _button(p, str(i + 1), Vector2(1480 + i * 52, 10), Vector2(44, 44), C_MUTED, _on_page.bind(i))
		page_buttons.append(pb)
	capacity_label = _label(p, "", Vector2(1640, 18), Vector2(250, 28), 22, C_MUTED)
	_button(p, "整理", Vector2(2140, 8), Vector2(160, 48), C_CYAN, _auto_sort)
	var ledger := _panel(p, Vector2(24, 64), Vector2(330, 250), C_PAPER, Color("#b9a98a"), 3)
	_label(ledger, "今日流水", Vector2(16, 10), Vector2(200, 36), 26, C_INK)
	ledger_label = _label(ledger, "", Vector2(16, 50), Vector2(298, 186), 22, C_INK)
	grid_root = Control.new()
	grid_root.position = Vector2(378, 64)
	grid_root.size = Vector2(1052, 250)
	p.add_child(grid_root)
	detail_panel = _panel(p, Vector2(1454, 64), Vector2(862, 250), C_PAPER, Color("#b9a98a"), 3)
	detail_icon = _texture_rect(detail_panel, Vector2(16, 14), Vector2(140, 210), "")
	detail_name = _label(detail_panel, "", Vector2(170, 8), Vector2(470, 40), 34, C_INK)
	detail_desc = _label(detail_panel, "", Vector2(170, 52), Vector2(660, 52), 20, C_INK)
	detail_meta = _label(detail_panel, "", Vector2(170, 106), Vector2(660, 58), 20, C_INK)
	detail_price = _label(detail_panel, "", Vector2(620, 8), Vector2(220, 44), 34, C_RUST, HORIZONTAL_ALIGNMENT_RIGHT)
	detail_rot_btn = _button(detail_panel, "旋转", Vector2(170, 190), Vector2(120, 48), C_TEXT, _on_rotate)
	detail_display_btn = _button(detail_panel, "上架", Vector2(300, 190), Vector2(150, 48), C_TEXT, _on_display_toggle)
	detail_counter_btn = _button(detail_panel, "放柜台", Vector2(460, 190), Vector2(160, 48), C_TEXT, _on_put_counter)

func _build_modal() -> void:
	modal_layer = Control.new()
	modal_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_layer.visible = false
	modal_layer.z_index = 100
	modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(modal_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_layer.add_child(dim)
	modal_panel = _panel(modal_layer, Vector2(570, 190), Vector2(1200, 700), C_PANEL, C_CYAN, 3)
	modal_title = _label(modal_panel, "", Vector2(30, 20), Vector2(1000, 52), 36, C_AMBER)
	modal_text = _label(modal_panel, "", Vector2(30, 82), Vector2(1140, 360), 26, C_TEXT)
	modal_actions = HBoxContainer.new()
	modal_actions.position = Vector2(30, 500)
	modal_actions.size = Vector2(1140, 100)
	modal_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	modal_actions.add_theme_constant_override("separation", 16)
	modal_panel.add_child(modal_actions)
	_button(modal_panel, "关闭", Vector2(1080, 16), Vector2(90, 44), C_MUTED, _close_modal)

func _build_machine_bay() -> void:
	machine_layer = Control.new()
	machine_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	machine_layer.visible = false
	machine_layer.z_index = 110
	machine_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(machine_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	machine_layer.add_child(dim)
	var panel := _panel(machine_layer, Vector2(230, 60), Vector2(1880, 960), C_PANEL, C_CYAN, 3)
	_label(panel, "机器 · MACHINE BAY", Vector2(30, 18), Vector2(700, 52), 36, C_AMBER)
	machine_power_label = _label(panel, "", Vector2(1480, 26), Vector2(220, 32), 22, C_AMBER)
	_button(panel, "关闭", Vector2(1726, 14), Vector2(120, 48), C_MUTED, _close_machines)
	var scroll := ScrollContainer.new()
	machine_scroll = scroll
	scroll.position = Vector2(24, 84)
	scroll.size = Vector2(520, 840)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.add_theme_stylebox_override("panel", _style(C_PANEL2, C_LINE, 2))
	panel.add_child(scroll)
	machine_list_box = VBoxContainer.new()
	machine_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	machine_list_box.add_theme_constant_override("separation", 8)
	scroll.add_child(machine_list_box)
	_button(panel, "▲ 上翻", Vector2(24, 930), Vector2(240, 56), C_MUTED, _scroll_machine_list.bind(-1))
	_button(panel, "▼ 下翻", Vector2(280, 930), Vector2(240, 56), C_MUTED, _scroll_machine_list.bind(1))
	var detail := _panel(panel, Vector2(570, 80), Vector2(1280, 600), C_PANEL2, C_LINE, 2)
	machine_name_label = _label(detail, "", Vector2(24, 16), Vector2(900, 44), 36, C_TEXT)
	machine_meta_label = _label(detail, "", Vector2(24, 66), Vector2(1230, 30), 22, C_AMBER)
	machine_io_label = _label(detail, "", Vector2(24, 108), Vector2(1230, 200), 22, C_TEXT)
	machine_module_label = _label(detail, "", Vector2(24, 322), Vector2(1230, 30), 22, C_CYAN)
	var install := _button(detail, "安装模块", Vector2(24, 362), Vector2(220, 54), C_CYAN, _install_module)
	install.name = "InstallModule"
	var temps := [["低温", 1], ["标准", 2], ["高温", 3]]
	for t in temps:
		var tb := _button(detail, t[0], Vector2(270 + (int(t[1]) - 1) * 136, 362), Vector2(124, 54), C_MUTED, _set_temp.bind(int(t[1])))
		temp_buttons.append(tb)
	machine_start_btn = _button(detail, "启动生产", Vector2(24, 440), Vector2(300, 72), C_AMBER, _start_selected_machine)
	machine_repair_btn = _button(detail, "维修", Vector2(340, 440), Vector2(200, 72), C_CYAN, _repair_selected_machine)
	machine_harvest_btn = _button(detail, "收获", Vector2(560, 440), Vector2(180, 72), C_GREEN, _harvest_selected_machine)
	machine_status_label = _label(detail, "选择机器开始生产。", Vector2(760, 454), Vector2(500, 70), 22, C_MUTED)
	var jobs_panel := _panel(panel, Vector2(570, 700), Vector2(1280, 250), C_PANEL2, C_LINE, 2)
	_label(jobs_panel, "运行队列", Vector2(24, 12), Vector2(300, 32), 24, C_AMBER)
	machine_jobs_label = _label(jobs_panel, "无", Vector2(24, 50), Vector2(1230, 180), 22, C_TEXT)

func _build_info_bay() -> void:
	info_layer = Control.new()
	info_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	info_layer.visible = false
	info_layer.z_index = 120
	info_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(info_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	info_layer.add_child(dim)
	var panel := _panel(info_layer, Vector2(230, 60), Vector2(1880, 960), C_PANEL, C_CYAN, 3)
	info_title = _label(panel, "信息网络", Vector2(30, 16), Vector2(600, 48), 36, C_AMBER)
	_button(panel, "关闭", Vector2(1726, 14), Vector2(120, 48), C_MUTED, _close_info)
	var tabs := [["网络", "network"], ["专精", "professions"], ["派系", "factions"], ["顾客", "customers"], ["电话", "phone"], ["通缉", "wanted"], ["档案", "archive"]]
	for i in range(tabs.size()):
		var tb := _button(panel, tabs[i][0], Vector2(30 + i * 156, 70), Vector2(144, 44), C_MUTED, _switch_info_tab.bind(tabs[i][1]))
		info_tab_buttons[tabs[i][1]] = tb
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(24, 130)
	scroll.size = Vector2(520, 790)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.add_theme_stylebox_override("panel", _style(C_PANEL2, C_LINE, 2))
	panel.add_child(scroll)
	info_list_box = VBoxContainer.new()
	info_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_list_box.add_theme_constant_override("separation", 8)
	scroll.add_child(info_list_box)
	var detail := _panel(panel, Vector2(570, 130), Vector2(1280, 760), C_PANEL2, C_LINE, 2)
	info_name = _label(detail, "", Vector2(24, 16), Vector2(1000, 44), 34, C_TEXT)
	info_meta = _label(detail, "", Vector2(24, 64), Vector2(1230, 30), 22, C_AMBER)
	info_body = _label(detail, "", Vector2(24, 108), Vector2(1230, 500), 20, C_TEXT)
	archive_scroll = ScrollContainer.new()
	archive_scroll.position = Vector2(24, 108)
	archive_scroll.size = Vector2(1230, 500)
	archive_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	archive_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	archive_scroll.add_theme_stylebox_override("panel", _style(C_PANEL2, C_LINE, 1))
	archive_scroll.visible = false
	detail.add_child(archive_scroll)
	archive_text = RichTextLabel.new()
	archive_text.bbcode_enabled = false
	archive_text.fit_content = true
	archive_text.custom_minimum_size = Vector2(1200, 0)
	archive_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	archive_text.add_theme_font_size_override("normal_font_size", 20)
	archive_scroll.add_child(archive_text)
	info_action = _button(detail, "操作", Vector2(24, 630), Vector2(280, 64), C_AMBER, _info_action)
	info_status = _label(detail, "", Vector2(330, 640), Vector2(900, 52), 20, C_MUTED)

func _build_story_layer() -> void:
	story_layer = Control.new()
	story_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	story_layer.visible = false
	story_layer.z_index = 130
	story_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(story_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	story_layer.add_child(dim)
	var panel := _panel(story_layer, Vector2(230, 120), Vector2(1880, 840), C_PANEL, C_CYAN, 3)
	_label(panel, "剧情 · STORY", Vector2(30, 18), Vector2(600, 48), 34, C_AMBER)
	story_portrait = _texture_rect(panel, Vector2(30, 150), Vector2(460, 540), "")
	story_name = _label(panel, "", Vector2(530, 24), Vector2(1200, 42), 30, C_AMBER)
	story_text = _label(panel, "", Vector2(530, 80), Vector2(1300, 370), 28, C_TEXT)
	story_choices = VBoxContainer.new()
	story_choices.position = Vector2(530, 480)
	story_choices.size = Vector2(1300, 320)
	story_choices.add_theme_constant_override("separation", 14)
	panel.add_child(story_choices)

func _build_combat_layer() -> void:
	combat_layer = Control.new()
	combat_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	combat_layer.visible = false
	combat_layer.z_index = 140
	combat_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(combat_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.86)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	combat_layer.add_child(dim)
	var panel := _panel(combat_layer, Vector2(300, 140), Vector2(1740, 800), C_PANEL, C_RUST, 3)
	_label(panel, "战斗 · COMBAT", Vector2(30, 18), Vector2(600, 48), 34, C_RUST)
	combat_enemy_sprite = _texture_rect(panel, Vector2(30, 80), Vector2(360, 360), "")
	combat_enemy_name = _label(panel, "", Vector2(420, 80), Vector2(700, 40), 30, C_TEXT)
	combat_enemy_bar = ProgressBar.new()
	combat_enemy_bar.position = Vector2(420, 130)
	combat_enemy_bar.size = Vector2(1200, 30)
	combat_enemy_bar.show_percentage = false
	combat_enemy_bar.add_theme_stylebox_override("background", _style(Color("#241416"), C_LINE, 2))
	combat_enemy_bar.add_theme_stylebox_override("fill", _style(C_RUST, C_RUST, 1))
	panel.add_child(combat_enemy_bar)
	combat_player_bar = ProgressBar.new()
	combat_player_bar.position = Vector2(420, 176)
	combat_player_bar.size = Vector2(1200, 30)
	combat_player_bar.show_percentage = false
	combat_player_bar.add_theme_stylebox_override("background", _style(Color("#101a18"), C_LINE, 2))
	combat_player_bar.add_theme_stylebox_override("fill", _style(C_GREEN, C_GREEN, 1))
	panel.add_child(combat_player_bar)
	combat_log_label = _label(panel, "", Vector2(420, 230), Vector2(1250, 300), 22, C_TEXT)
	combat_status = _label(panel, "", Vector2(420, 530), Vector2(1250, 36), 20, C_MUTED)
	var buttons := [["攻击", "attack", C_RUST], ["防御", "guard", C_CYAN], ["技能", "skill", C_AMBER], ["逃跑", "flee", C_MUTED]]
	for i in range(buttons.size()):
		_button(panel, buttons[i][0], Vector2(420 + i * 220, 590), Vector2(200, 68), buttons[i][2], _combat_action.bind(buttons[i][1]))

func _build_minigame_layer() -> void:
	minigame_layer = Control.new()
	minigame_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minigame_layer.visible = false
	minigame_layer.z_index = 150
	minigame_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(minigame_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.84)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minigame_layer.add_child(dim)
	var panel := _panel(minigame_layer, Vector2(420, 160), Vector2(1500, 760), C_PANEL, C_CYAN, 3)
	_label(panel, "3D 打印 · 形状校准", Vector2(30, 18), Vector2(800, 48), 34, C_AMBER)
	_label(panel, "对照左侧目标图案，在右侧点亮相同格子。匹配度 ≥75%（12/16）才能启动；完美匹配可缩短打印时间。", Vector2(30, 76), Vector2(1420, 40), 20, C_MUTED)
	_label(panel, "目标图案", Vector2(90, 130), Vector2(300, 34), 24, C_CYAN)
	var target_grid := GridContainer.new()
	target_grid.columns = 4
	target_grid.position = Vector2(90, 180)
	target_grid.add_theme_constant_override("h_separation", 8)
	target_grid.add_theme_constant_override("v_separation", 8)
	panel.add_child(target_grid)
	for i in range(16):
		var cell := Panel.new()
		cell.custom_minimum_size = Vector2(90, 90)
		target_grid.add_child(cell)
		minigame_target_cells.append(cell)
	_label(panel, "你的图案（点按切换）", Vector2(820, 130), Vector2(500, 34), 24, C_AMBER)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.position = Vector2(820, 180)
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	panel.add_child(grid)
	for i in range(16):
		var b := Button.new()
		b.toggle_mode = true
		b.custom_minimum_size = Vector2(90, 90)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_stylebox_override("normal", _style(C_PANEL2, C_LINE))
		b.add_theme_stylebox_override("hover", _style(Color("#252c38"), C_AMBER))
		b.add_theme_stylebox_override("pressed", _style(Color("#6b5526"), C_AMBER, 3))
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		b.pressed.connect(_toggle_minigame_cell.bind(i))
		grid.add_child(b)
		minigame_cells.append(b)
	minigame_status = _label(panel, "", Vector2(90, 610), Vector2(700, 40), 24, C_MUTED)
	_button(panel, "启动打印", Vector2(900, 620), Vector2(240, 72), C_AMBER, _confirm_minigame)
	_button(panel, "取消", Vector2(1170, 620), Vector2(200, 72), C_MUTED, _close_minigame)

func _open_printer_minigame() -> void:
	var patterns := [
		[0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0],
		[1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1],
		[0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0],
		[0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1],
		[1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1],
	]
	minigame_target = patterns[randi() % patterns.size()].duplicate()
	minigame_selected = []
	for i in range(16):
		minigame_selected.append(false)
		minigame_cells[i].button_pressed = false
		var on := int(minigame_target[i]) == 1
		minigame_target_cells[i].add_theme_stylebox_override("panel", _style(Color(0.39, 0.85, 0.82, 0.4) if on else C_PANEL2, C_CYAN if on else C_LINE))
	minigame_status.text = "匹配度 0/16（至少 12）"
	minigame_layer.visible = true
	_play_sfx("page")

func _toggle_minigame_cell(idx: int) -> void:
	if idx < 0 or idx >= minigame_selected.size():
		return
	minigame_selected[idx] = not bool(minigame_selected[idx])
	minigame_cells[idx].button_pressed = minigame_selected[idx]
	var matched := 0
	for i in range(16):
		if (1 if minigame_selected[i] else 0) == int(minigame_target[i]):
			matched += 1
	minigame_status.text = "匹配度 %d/16（至少 12）" % matched

func _confirm_minigame() -> void:
	var matched := 0
	for i in range(16):
		if (1 if minigame_selected[i] else 0) == int(minigame_target[i]):
			matched += 1
	if matched < 12:
		minigame_status.text = "校准失败：%d/16，需要至少 12。调整后重试。" % matched
		_play_sfx("fail")
		return
	minigame_layer.visible = false
	_play_sfx("machine")
	_start_selected_machine(float(matched) / 16.0)

func _close_minigame() -> void:
	minigame_layer.visible = false
	_play_sfx("soft")

func _build_mix_layer() -> void:
	mix_layer = Control.new()
	mix_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mix_layer.visible = false
	mix_layer.z_index = 151
	mix_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(mix_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.84)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mix_layer.add_child(dim)
	var panel := _panel(mix_layer, Vector2(420, 160), Vector2(1500, 760), C_PANEL, C_CYAN, 3)
	_label(panel, "化学混合器 · 配比校准", Vector2(30, 18), Vector2(900, 48), 34, C_AMBER)
	_label(panel, "把三组试剂调到目标刻度附近（每项误差 ≤1）。越接近目标，混合耗时越短。", Vector2(30, 76), Vector2(1420, 40), 20, C_MUTED)
	var captions := ["溶剂 A", "试剂 B", "催化剂 C"]
	for i in range(3):
		_label(panel, captions[i], Vector2(90, 190 + i * 120), Vector2(180, 40), 26, C_TEXT)
		var slider := HSlider.new()
		slider.min_value = 0
		slider.max_value = 10
		slider.step = 1
		slider.value = 5
		slider.position = Vector2(300, 190 + i * 120)
		slider.size = Vector2(700, 40)
		slider.custom_minimum_size = Vector2(700, 40)
		slider.add_theme_stylebox_override("slider", _style(C_PANEL2, C_LINE))
		slider.add_theme_stylebox_override("grabber_area", _style(C_CYAN, C_CYAN))
		slider.add_theme_stylebox_override("grabber_area_highlight", _style(C_AMBER, C_AMBER))
		slider.value_changed.connect(_on_mix_changed.bind(i))
		panel.add_child(slider)
		mix_sliders.append(slider)
		var value_label := _label(panel, "5", Vector2(1040, 190 + i * 120), Vector2(100, 40), 28, C_AMBER)
		mix_value_labels.append(value_label)
	mix_status = _label(panel, "", Vector2(90, 560), Vector2(1200, 40), 24, C_MUTED)
	_button(panel, "启动混合", Vector2(800, 620), Vector2(240, 72), C_AMBER, _confirm_mix)
	_button(panel, "重置", Vector2(1070, 620), Vector2(180, 72), C_CYAN, _open_mix_minigame)
	_button(panel, "取消", Vector2(1280, 620), Vector2(180, 72), C_MUTED, _close_mix)

func _open_mix_minigame() -> void:
	mix_target = [randi_range(2, 8), randi_range(2, 8), randi_range(2, 8)]
	for i in range(3):
		mix_sliders[i].set_value_no_signal(5.0)
		mix_value_labels[i].text = "5"
	mix_status.text = "目标：溶剂 A %d · 试剂 B %d · 催化剂 C %d（误差 ≤1）" % [mix_target[0], mix_target[1], mix_target[2]]
	mix_layer.visible = true
	_play_sfx("page")

func _on_mix_changed(value: float, idx: int) -> void:
	if idx >= 0 and idx < mix_value_labels.size():
		mix_value_labels[idx].text = str(int(value))

func _confirm_mix() -> void:
	var errors := []
	for i in range(3):
		errors.append(absi(int(mix_sliders[i].value) - int(mix_target[i])))
	var max_error := 0
	var total_error := 0
	for e in errors:
		max_error = maxi(max_error, int(e))
		total_error += int(e)
	if max_error > 1:
		mix_status.text = "配比偏差过大（最大误差 %d）。调整后重试。" % max_error
		_play_sfx("fail")
		return
	var quality := 1.0 - float(total_error) / 30.0
	mix_layer.visible = false
	_play_sfx("machine")
	_start_selected_machine(clampf(quality, 0.0, 1.0))

func _close_mix() -> void:
	mix_layer.visible = false
	_play_sfx("soft")

func _build_dna_layer() -> void:
	dna_layer = Control.new()
	dna_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dna_layer.visible = false
	dna_layer.z_index = 152
	dna_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dna_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.84)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dna_layer.add_child(dim)
	var panel := _panel(dna_layer, Vector2(500, 180), Vector2(1400, 720), C_PANEL, C_CYAN, 3)
	_label(panel, "DNA 操作台 · 序列复制", Vector2(30, 18), Vector2(900, 48), 34, C_AMBER)
	_label(panel, "按目标序列依次拼接 6 个碱基。完全匹配才能启动培养；清空后可重试。", Vector2(30, 76), Vector2(1320, 40), 20, C_MUTED)
	dna_target_label = _label(panel, "", Vector2(90, 150), Vector2(1220, 60), 38, C_CYAN)
	dna_input_label = _label(panel, "", Vector2(90, 230), Vector2(1220, 60), 38, C_AMBER)
	var bases := ["A", "C", "G", "T"]
	for i in range(bases.size()):
		_button(panel, bases[i], Vector2(160 + i * 220, 360), Vector2(180, 90), C_CYAN, _dna_press.bind(bases[i]))
	dna_status = _label(panel, "", Vector2(90, 500), Vector2(1200, 40), 24, C_MUTED)
	_button(panel, "提交序列", Vector2(740, 580), Vector2(240, 72), C_AMBER, _confirm_dna)
	_button(panel, "清空", Vector2(1010, 580), Vector2(180, 72), C_CYAN, _clear_dna)
	_button(panel, "取消", Vector2(1220, 580), Vector2(180, 72), C_MUTED, _close_dna)

func _open_dna_minigame() -> void:
	var bases := ["A", "C", "G", "T"]
	dna_target = []
	for i in range(6):
		dna_target.append(bases[randi() % bases.size()])
	dna_input = []
	dna_target_label.text = "目标序列： " + " ".join(dna_target)
	dna_input_label.text = "你的序列： —"
	dna_status.text = "等待输入 6 个碱基。"
	dna_layer.visible = true
	_play_sfx("page")

func _dna_press(base: String) -> void:
	if dna_input.size() >= 6:
		return
	dna_input.append(base)
	dna_input_label.text = "你的序列： " + " ".join(dna_input)
	if dna_input.size() >= 6:
		dna_status.text = "序列已满，提交或清空。"

func _clear_dna() -> void:
	dna_input = []
	dna_input_label.text = "你的序列： —"
	dna_status.text = "等待输入 6 个碱基。"
	_play_sfx("soft")

func _confirm_dna() -> void:
	if dna_input.size() < 6:
		dna_status.text = "序列不足 6 个碱基。"
		_play_sfx("fail")
		return
	var matched := 0
	for i in range(6):
		if dna_input[i] == dna_target[i]:
			matched += 1
	if matched < 6:
		dna_status.text = "序列不匹配（%d/6），清空后重试。" % matched
		_play_sfx("fail")
		return
	dna_layer.visible = false
	_play_sfx("machine")
	_start_selected_machine(1.0)

func _close_dna() -> void:
	dna_layer.visible = false
	_play_sfx("soft")

func _refresh() -> void:
	if not is_inside_tree():
		return
	day_label.text = "第 %d 天 · 周%s" % [GameState.day, _weekday(GameState.day)]
	if GameState.rent_due <= 0:
		rent_label.text = "房租明天到期"
	else:
		rent_label.text = "房租 %d 天后到期" % GameState.rent_due
	cash_label.text = "¥ %d" % GameState.cash
	var sold := int(GameState.daily.get("sold", 0))
	var inspected := int(GameState.daily.get("inspected", 0))
	paper_goals.text = "□ 卖出 3 件商品  %d/3\n□ 鉴定 1 件物品  %d/1\n□ 支付房租 %d¥\n\n房租 %d 天后到期\n欠款 %d¥" % [sold, inspected, GameState.rent, GameState.rent_due, GameState.loan]
	var net := int(GameState.daily.get("sales", 0)) - int(GameState.daily.get("purchases", 0)) - int(GameState.daily.get("fees", 0))
	ledger_label.text = "营业收入  +%d¥\n进货支出  -%d¥\n鉴定费用  -%d¥\n------------\n净利      %+d¥\n\n今日顾客  %d 位\n已成交    %d 位" % [int(GameState.daily.get("sales", 0)), int(GameState.daily.get("purchases", 0)), int(GameState.daily.get("fees", 0)), net, GameState.customers_today.size(), sold]
	status_label.text = "营业中 · %d 位" % GameState.customers_today.size() if GameState.phase != "endday" else "已结束"
	if not GameState.machine_jobs.is_empty():
		status_label.text += " · 机器运行中"
	status_label.add_theme_color_override("font_color", C_GREEN if GameState.phase != "endday" else C_AMBER)
	if not GameState.tutorial_done and GameState.day == 1 and GameState.tutorial_step > 0:
		dialogue_hint.text = _tutorial_text()
	else:
		dialogue_hint.text = "右侧选择交涉动作 · 长按物品查看详情"
	for k in rep_labels.keys():
		var v := int(GameState.rep.get(k, 0))
		rep_labels[k].text = "%s %+d" % [_faction_short(k), v]
	_update_customer()
	_update_counter()
	_rebuild_display()
	_rebuild_grid()
	_update_detail()
	_update_action_buttons()

func _update_customer() -> void:
	var c: Dictionary = GameState.current_customer
	if c.is_empty():
		customer_rect.visible = false
		customer_name_label.text = "—"
		customer_info_label.text = "当前没有顾客。\n可以整理物品、查看档案，或结束营业。"
		dialogue_name.text = "店铺"
		dialogue_text.text = "点「结束营业」进入下一天。"
		return
	customer_rect.visible = true
	var arche: Dictionary = c.get("arche", {})
	customer_name_label.text = arche.get("name", "顾客")
	var intent_text := "出售物品" if c.get("intent") == "sell" else "想买东西"
	customer_info_label.text = "阵营：%s\n意图：%s\n今日第 %d / %d 位" % [_faction_name(arche.get("faction", "lower")), intent_text, GameState.current_index + 1, GameState.customers_today.size()]
	var sprite := String(arche.get("sprite", "maleUpper_0.png"))
	var path := _customer_path(sprite)
	if ResourceLoader.exists(path):
		customer_rect.texture = load(path)
	dialogue_name.text = "%s · %s" % [arche.get("name", "顾客"), intent_text]
	dialogue_text.text = String(c.get("line", ""))

func _update_counter() -> void:
	if GameState.counter_item.is_empty():
		counter_icon.texture = null
		counter_name.text = "等待放入物品"
		counter_price.text = ""
		if GameState.current_customer.is_empty():
			counter_hint.text = "今日营业结束，点左侧「结束营业」查看结算。"
		elif GameState.current_customer.get("intent") == "buy":
			counter_hint.text = "从右侧展示柜点选商品，或在背包选中后点「放柜台」。"
		else:
			counter_hint.text = "顾客正在从包里掏东西……"
		return
	var it: Dictionary = GameState.counter_item
	var def := GameState.get_item_def(it.get("def_id", ""))
	var cip := GameState.item_icon_path(def)
	counter_icon.texture = load(cip) if cip != "" else null
	counter_name.text = GameState.item_display_name(it)
	if GameState.current_customer.get("intent") == "sell":
		counter_price.text = "顾客开价 %d¥" % int(it.get("asking_price", 0))
		counter_hint.text = "品相 %d%% · %s · %s" % [int(it.get("condition", 100)), "已鉴定" if it.get("known", false) else "未鉴定", "序列号可疑" if it.get("stolen", false) else "来源待确认"]
	else:
		counter_price.text = "顾客出价 %d¥" % int(GameState.current_customer.get("offer", 0))
		counter_hint.text = "顾客预算 %d¥ · 可议价" % int(GameState.current_customer.get("budget", 0))

func _rebuild_display() -> void:
	_clear_children(display_root)
	for i in range(GameState.DISPLAY_SLOTS):
		var p := _panel(display_root, Vector2(i * 186, 0), Vector2(176, 136), C_PANEL2, C_LINE, 1)
		if i < GameState.display.size():
			var it: Dictionary = GameState.display[i]
			var def := GameState.get_item_def(it.get("def_id", ""))
			var dip := GameState.item_icon_path(def)
			var icon := _texture_rect(p, Vector2(8, 6), Vector2(160, 80), dip)
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_label(p, GameState.item_display_name(it), Vector2(8, 88), Vector2(160, 22), 18, C_TEXT)
			_label(p, "%d¥" % GameState.market_value(it, true), Vector2(8, 110), Vector2(160, 20), 18, C_AMBER)
			var uid := int(it["uid"])
			var btn := Button.new()
			btn.flat = true
			btn.position = Vector2.ZERO
			btn.size = Vector2(176, 136)
			btn.focus_mode = Control.FOCUS_NONE
			btn.pressed.connect(_on_display_slot.bind(uid))
			p.add_child(btn)
		else:
			_label(p, "空", Vector2(0, 54), Vector2(176, 26), 20, C_MUTED, HORIZONTAL_ALIGNMENT_CENTER)

func _rebuild_grid() -> void:
	_clear_children(grid_root)
	for y in range(GameState.GRID_H):
		for x in range(GameState.GRID_W):
			var cell := _panel(grid_root, Vector2(x * 66, y * 66), Vector2(62, 62), Color("#11151d"), Color("#2a3140"), 1)
			cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for it in GameState.inventory:
		if it.get("location", "backpack") != "backpack":
			continue
		if int(it.get("page", 0)) != current_page:
			continue
		if not _matches_filter(it):
			continue
		var def := GameState.get_item_def(it.get("def_id", ""))
		var shape := GameState.item_shape(it)
		var w := int(shape[0]) * 62 + (int(shape[0]) - 1) * 4
		var h := int(shape[1]) * 62 + (int(shape[1]) - 1) * 4
		var icon := TextureButton.new()
		icon.position = Vector2(int(it["x"]) * 66, int(it["y"]) * 66)
		icon.size = Vector2(w, h)
		var gip := GameState.item_icon_path(def)
		icon.texture_normal = load(gip) if gip != "" else null
		icon.ignore_texture_size = true
		icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.focus_mode = Control.FOCUS_NONE
		var uid := int(it["uid"])
		icon.pressed.connect(_on_item_selected.bind(uid))
		icon.gui_input.connect(_on_item_gui_input.bind(uid, icon))
		if uid == selected_uid:
			icon.self_modulate = Color(1.3, 1.2, 0.85)
		grid_root.add_child(icon)
	if current_page >= GameState.pages_unlocked:
		current_page = GameState.pages_unlocked - 1
	for i in range(page_buttons.size()):
		page_buttons[i].disabled = i >= GameState.pages_unlocked
	capacity_label.text = "容量 %d / %d" % [GameState.inventory.size(), GameState.GRID_W * GameState.GRID_H * GameState.pages_unlocked]

func _selected_item() -> Dictionary:
	for it in GameState.inventory:
		if int(it["uid"]) == selected_uid:
			return it
	for it in GameState.display:
		if int(it["uid"]) == selected_uid:
			return it
	if not GameState.counter_item.is_empty() and int(GameState.counter_item["uid"]) == selected_uid:
		return GameState.counter_item
	return {}

func _update_detail() -> void:
	var it := _selected_item()
	if it.is_empty():
		detail_icon.texture = null
		detail_name.text = "选择物品"
		detail_desc.text = "点选背包或展示柜物品查看详情。"
		detail_meta.text = ""
		detail_price.text = ""
		detail_rot_btn.disabled = true
		detail_display_btn.disabled = true
		detail_counter_btn.disabled = true
		return
	var def := GameState.get_item_def(it.get("def_id", ""))
	var tip := GameState.item_icon_path(def)
	detail_icon.texture = load(tip) if tip != "" else null
	detail_name.text = GameState.item_display_name(it)
	detail_desc.text = GameState.item_description(it)
	var tags: Array = def.get("tags", [])
	var tags_text := ""
	for t in tags:
		tags_text += (", " if tags_text != "" else "") + String(t)
	var loc := String(it.get("location", "backpack"))
	var known := bool(it.get("known", false))
	var cond := int(it.get("condition", 100))
	var auth_text := "真品" if it.get("authentic", true) else "假货"
	var stolen_text := " · 序列号被磨掉" if it.get("stolen", false) else ""
	var loc_text := _loc_name(loc)
	if loc == "backpack":
		loc_text += " · 第%d页" % (int(it.get("page", 0)) + 1)
	var feat_text := ""
	for f in it.get("features", []):
		feat_text += ("、" if feat_text != "" else "") + String(f.get("name", ""))
	if feat_text == "":
		feat_text = "无"
	detail_meta.text = "品相 %d%% · %s%s\n%s\n特征：%s · %s" % [cond, "已鉴定 · " + auth_text if known else "未鉴定", stolen_text, tags_text, feat_text, loc_text]
	if known or loc == "backpack":
		detail_price.text = "%d¥" % GameState.market_value(it, false)
	else:
		var base := int(def.get("base_value", 0))
		detail_price.text = "%d-%d¥" % [int(base * 0.5), int(base * 1.1)]
	detail_rot_btn.disabled = loc != "backpack"
	detail_display_btn.text = "下架" if loc == "display" else "上架"
	detail_display_btn.disabled = loc not in ["backpack", "display"]
	detail_counter_btn.disabled = not (loc == "display" and GameState.current_customer.get("intent") == "buy")

func _loc_name(loc: String) -> String:
	match loc:
		"backpack": return "背包"
		"display": return "展示柜"
		"counter": return "交易台"
	return loc

func _update_action_buttons() -> void:
	var c := GameState.current_customer
	var has_customer := not c.is_empty() and GameState.phase == "customer"
	var has_counter := not GameState.counter_item.is_empty()
	action_buttons["inspect"].disabled = not (has_customer and c.get("intent") == "sell" and not GameState.counter_item.get("known", false))
	action_buttons["bargain"].disabled = not (has_customer and has_counter)
	action_buttons["threaten"].disabled = not (has_customer and has_counter)
	action_buttons["deal"].disabled = not (has_customer and has_counter)
	action_buttons["dismiss"].disabled = not has_customer
	rail_buttons["end_day"].disabled = GameState.phase == "gameover"

func _matches_filter(it: Dictionary) -> bool:
	if filter_category == "all":
		return true
	var def := GameState.get_item_def(it.get("def_id", ""))
	var cat := String(def.get("category", "misc"))
	match filter_category:
		"weapon": return cat == "weapon"
		"weapon_mod": return cat == "weapon_mod"
		"chem": return cat == "chem"
		"cyber": return cat == "cyber"
		"medical": return cat == "medical"
		"food": return cat in ["food", "plant", "animal", "water"]
		"document": return cat == "document"
		"material": return cat == "material"
		"module": return cat == "module"
		"misc": return cat in ["misc", "tool", "container", "furniture"]
	return true

func _set_filter(cat: String) -> void:
	filter_category = cat
	for k in tab_buttons.keys():
		tab_buttons[k].modulate = Color(1.25, 1.12, 0.72) if k == cat else Color.WHITE
	_rebuild_grid()

func _on_page(page: int) -> void:
	current_page = clampi(page, 0, GameState.pages_unlocked - 1)
	selected_uid = -1
	_rebuild_grid()
	_update_detail()

func _auto_sort() -> void:
	var list: Array = []
	for it in GameState.inventory:
		if it.get("location", "backpack") == "backpack":
			it["x"] = -1
			it["y"] = -1
			it["page"] = -1
			list.append(it)
	list.sort_custom(func(a, b):
		var da := GameState.get_item_def(a["def_id"])
		var db := GameState.get_item_def(b["def_id"])
		return String(da.get("category", "")) < String(db.get("category", ""))
	)
	for it in list:
		GameState.auto_place(it)
	_refresh()

func _on_item_selected(uid: int) -> void:
	selected_uid = uid
	_rebuild_grid()
	_update_detail()

func _on_item_gui_input(event: InputEvent, uid: int, icon: TextureButton) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging_uid = uid
			drag_icon = icon
			drag_offset = icon.get_global_mouse_position() - icon.global_position
			icon.z_index = 10
			icon.modulate.a = 0.75
			dragged = false
		else:
			if dragging_uid == uid and drag_icon:
				var did_drag := dragged
				var icon_ref := drag_icon
				var local := icon_ref.position
				dragging_uid = -1
				drag_icon = null
				icon_ref.z_index = 0
				icon_ref.modulate.a = 1.0
				if did_drag:
					var gx := int(round(local.x / 66.0))
					var gy := int(round(local.y / 66.0))
					GameState.move_item(uid, gx, gy, current_page)
					_refresh()
				else:
					call_deferred("_on_item_selected", uid)
	elif event is InputEventMouseMotion and dragging_uid == uid and drag_icon:
		dragged = true
		drag_icon.position = drag_icon.get_global_mouse_position() - drag_offset - grid_root.global_position

func _on_display_slot(uid: int) -> void:
	selected_uid = uid
	if GameState.current_customer.get("intent") == "buy":
		GameState.put_display_on_counter(uid)
	_refresh()

func _on_rotate() -> void:
	if GameState.rotate_item(selected_uid):
		_refresh()
	else:
		_toast("这个位置放不下旋转后的物品。")

func _on_display_toggle() -> void:
	var it := _selected_item()
	if it.is_empty():
		return
	if it.get("location") == "backpack":
		if not GameState.add_to_display(selected_uid):
			_toast("展示柜已经满了。")
		elif GameState.tutorial_step == 3:
			GameState.tutorial_step = 4
	elif it.get("location") == "display":
		GameState.take_from_display(selected_uid)
	_refresh()

func _on_put_counter() -> void:
	var it := _selected_item()
	if it.is_empty():
		return
	if it.get("location") == "backpack":
		if GameState.add_to_display(selected_uid):
			GameState.put_display_on_counter(selected_uid)
	elif it.get("location") == "display":
		GameState.put_display_on_counter(selected_uid)
	_refresh()

func _on_customer_changed() -> void:
	selected_uid = int(GameState.counter_item["uid"]) if not GameState.counter_item.is_empty() else -1
	_refresh()

func _on_rail(key: String) -> void:
	match key:
		"customers":
			_open_info_tab("customers")
		"inventory":
			_toast("底部就是你的异形格背包。点选物品查看详情，拖动可以换位置。")
		"network":
			_open_network()
		"factions":
			_open_factions()
		"phone":
			_open_info_tab("phone")
		"machines":
			_open_machines()
		"ledger":
			_show_ledger_modal()
		"end_day":
			_on_end_day_pressed()

func _on_action(key: String) -> void:
	match key:
		"inspect":
			_open_inspection()
		"bargain":
			_open_bargain()
		"threaten":
			_do_threaten()
		"deal":
			_do_deal()
		"dismiss":
			_do_dismiss()

func _on_save() -> void:
	_play_sfx("soft")
	_open_save_menu("save")

func _on_load() -> void:
	_play_sfx("soft")
	_open_save_menu("load")

func _open_save_menu(mode: String) -> void:
	var actions: Array = []
	for i in range(1, 4):
		var label := "槽位 %d%s" % [i, "" if GameState.has_save(i) else "（空）"]
		if mode == "save":
			actions.append({"label": label, "cb": _save_slot.bind(i)})
		else:
			actions.append({"label": label, "cb": _load_slot.bind(i)})
	_show_modal("存档" if mode == "save" else "读档", "选择要保存/读取的槽位。", actions)

func _save_slot(slot: int) -> void:
	if GameState.save_game(slot):
		_close_modal()
		_toast("已保存到槽位 %d。" % slot)
	else:
		_toast("存档失败。")

func _load_slot(slot: int) -> void:
	if GameState.load_game(slot):
		selected_uid = -1
		current_page = 0
		_close_modal()
		_refresh()
		_toast("已读取槽位 %d。" % slot)
	else:
		_toast("槽位 %d 为空。" % slot)

func _on_end_day_pressed() -> void:
	if GameState.phase == "gameover":
		_toast("本局已经结束。点「读档」继续，或重新开始。")
		return
	if GameState.phase == "endday":
		if not last_summary.is_empty():
			_show_day_summary(last_summary)
		else:
			_toast("今天已经结束。")
		return
	if not GameState.tutorial_done and GameState.tutorial_step > 0:
		GameState.tutorial_done = true
		GameState.tutorial_step = 0
	_play_sfx("shutter")
	GameState.finish_day()

func _on_day_finished(summary: Dictionary) -> void:
	last_summary = summary
	_show_day_summary(summary)

func _show_day_summary(s: Dictionary) -> void:
	var text := "第 %d 天结算\n\n营业收入：+%d¥\n进货支出：-%d¥\n鉴定费用：-%d¥\n" % [int(s.get("day", 1)), int(s.get("sales", 0)), int(s.get("purchases", 0)), int(s.get("fees", 0))]
	if int(s.get("rent_paid", 0)) > 0:
		text += "房租支出：-%d¥\n" % int(s["rent_paid"])
	if int(s.get("loan_paid", 0)) > 0:
		text += "贷款还款：-%d¥\n" % int(s["loan_paid"])
	text += "\n当前现金：%d¥\n下次房租：%d¥（%d 天后）\n下次贷款：%d 天后" % [int(s.get("cash", 0)), int(s.get("rent", 0)), int(s.get("rent_due", 0)), int(s.get("loan_due", 0))]
	var actions: Array = []
	var go := String(s.get("gameover", ""))
	if go != "":
		var e := GameState.ending_def(go)
		if not e.is_empty():
			text += "\n\n【%s】\n%s" % [e.get("title", "结局"), e.get("text", "")]
		else:
			text += "\n\n你没能付清%s，店铺被收走了。" % ("房租" if go == "rent" else "贷款")
		actions.append({"label": "重新开始", "cb": _restart_game, "color": C_RUST})
	else:
		actions.append({"label": "今日报纸", "cb": _open_newspaper, "color": C_CYAN})
		actions.append({"label": "下一天", "cb": _next_day, "color": C_AMBER})
	_show_modal("营业结算", text, actions)

func _next_day() -> void:
	_close_modal()
	GameState.advance_day()
	_refresh()

func _restart_game() -> void:
	_close_modal()
	GameState.new_game(GameState.difficulty)
	selected_uid = -1
	current_page = 0
	last_summary = {}
	_refresh()

func _open_newspaper() -> void:
	var s: Dictionary = last_summary
	if s.is_empty():
		_close_modal()
		return
	var d := int(s.get("day", GameState.day))
	var text := "《下层区日报》  第 %d 天

" % d
	text += "头条：下层区当铺继续营业，店主撑过了今天的房租压力。
"
	text += "流水：收入 %d₵ / 进货 %d₵ / 鉴定 %d₵
" % [int(s.get("sales", 0)), int(s.get("purchases", 0)), int(s.get("fees", 0))]
	text += "现金 %d₵；房租 %d₵（%d 天后）
" % [int(s.get("cash", 0)), int(s.get("rent", 0)), int(s.get("rent_due", 0))]
	var top := ""
	var topv := -999
	for k in GameState.rep.keys():
		if int(GameState.rep[k]) > topv:
			topv = int(GameState.rep[k])
			top = _faction_name(k)
	text += "派系：%s %+d
" % [top, topv]
	if not GameState.wanted_defeated.is_empty():
		text += "通缉：已抓获 %d 名目标。
" % GameState.wanted_defeated.size()
	if not GameState.story_flags.is_empty():
		text += "传闻：你的选择已经被某些人记住。
"
	_show_modal("下层区日报", text, [{"label": "返回结算", "cb": _show_day_summary.bind(s)}, {"label": "关闭", "cb": _close_modal}])
	modal_text.add_theme_font_size_override("font_size", 20)

func _show_ledger_modal() -> void:
	var text := "第 %d 天 · 周%s\n\n营业收入：+%d¥\n进货支出：-%d¥\n鉴定费用：-%d¥\n\n现金：%d¥\n房租：%d¥（%d 天后）\n贷款：%d¥（%d 天后）" % [GameState.day, _weekday(GameState.day), int(GameState.daily.get("sales", 0)), int(GameState.daily.get("purchases", 0)), int(GameState.daily.get("fees", 0)), GameState.cash, GameState.rent, GameState.rent_due, GameState.loan, GameState.loan_due]
	_show_modal("店铺档案", text, [{"label": "关闭", "cb": _close_modal}])

func _open_machines() -> void:
	machine_layer.visible = true
	_rebuild_machine_list()
	if selected_machine_id == "" or GameState.machine_def(selected_machine_id).is_empty():
		if not GameState.machines.is_empty():
			selected_machine_id = String(GameState.machines[0].get("id", ""))
	_refresh_machine_panel()

func _close_machines() -> void:
	machine_layer.visible = false

func _rebuild_machine_list() -> void:
	_clear_children(machine_list_box)
	machine_list_buttons.clear()
	for m in GameState.machines:
		var mid := String(m.get("id", ""))
		var dur := int(GameState.machine_durability.get(mid, 100))
		var fault := String(GameState.machine_faults.get(mid, ""))
		var suffix := "（损坏）" if dur <= 0 else ("（故障）" if fault != "" else "")
		var text := "%s
%d电 · %.0fs · 耐久%d%s" % [m.get("name", mid), int(m.get("power", 0)), float(m.get("time", 0.0)), dur, suffix]
		var b := _button(machine_list_box, text, Vector2.ZERO, Vector2(480, 64), C_TEXT, _select_machine.bind(mid))
		b.custom_minimum_size = Vector2(480, 64)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		machine_list_buttons[mid] = b
	_refresh_machine_selection()

func _scroll_machine_list(direction: int) -> void:
	if machine_scroll:
		machine_scroll.scroll_vertical = maxi(0, machine_scroll.scroll_vertical + direction * 420)

func _refresh_machine_selection() -> void:
	for mid in machine_list_buttons.keys():
		machine_list_buttons[mid].modulate = Color(1.25, 1.12, 0.72) if mid == selected_machine_id else Color.WHITE

func _select_machine(machine_id: String) -> void:
	selected_machine_id = machine_id
	_refresh_machine_panel()

func _refresh_machine_panel() -> void:
	var m := GameState.machine_def(selected_machine_id)
	if m.is_empty():
		return
	var lvl := int(GameState.machine_temps.get(selected_machine_id, 2))
	var time_mul: float = [1.2, 1.0, 0.8][clampi(lvl, 1, 3) - 1]
	var power_mul: float = [1.0, 1.0, 1.5][clampi(lvl, 1, 3) - 1]
	var use_time: float = float(m.get("time", 1.0)) * time_mul
	var use_power: int = maxi(1, int(round(float(m.get("power", 0)) * power_mul)))
	if GameState.machine_modules.has(selected_machine_id):
		use_time *= 0.8
		use_power = maxi(1, use_power - 1)
	machine_name_label.text = String(m.get("name", ""))
	var dur := int(GameState.machine_durability.get(selected_machine_id, 100))
	var fault := String(GameState.machine_faults.get(selected_machine_id, ""))
	var state_text := "（已损坏）" if dur <= 0 else ("（故障：%s）" % GameState.machine_fault_name(fault) if fault != "" else "")
	var growth_job: Dictionary = {}
	for j in GameState.machine_jobs:
		if String(j.get("machine_id", "")) == selected_machine_id and bool(j.get("growth", false)):
			growth_job = j
			break
	machine_meta_label.text = "电力 %d · 耗时 %.1fs · 温度 %d°C · 耐久 %d/100%s" % [use_power, use_time, int(m.get("temp", 24)), dur, state_text]
	var ins: Array = []
	for i in m.get("inputs", []):
		var d := GameState.get_item_def(String(i.get("id", "")))
		ins.append("%sx%d" % [_short_item_name(String(i.get("id", "")), String(d.get("name", ""))), int(i.get("count", 1))])
	var outs: Array = []
	for o in m.get("outputs", []):
		var od := GameState.get_item_def(String(o.get("id", "")))
		outs.append("%sx%d" % [_short_item_name(String(o.get("id", "")), String(od.get("name", ""))), int(o.get("count", 1))])
	var held: Array = []
	for i in m.get("inputs", []):
		var iid := String(i.get("id", ""))
		var dd := GameState.get_item_def(iid)
		held.append("%sx%d" % [_short_item_name(iid, String(dd.get("name", iid))), GameState.inventory_count(iid)])
	machine_io_label.text = "输入：%s
输出：%s
原料持有：%s" % [" + ".join(ins), " + ".join(outs), " ".join(held)]
	var mod_id := String(GameState.machine_modules.get(selected_machine_id, ""))
	if mod_id == "":
		machine_module_label.text = "模块：无（安装模块：耗时 -20%，电力 -1）"
	else:
		machine_module_label.text = "模块：%s（耗时 -20%%，电力 -1）" % GameState.get_item_def(mod_id).get("name", mod_id)
	for i in range(temp_buttons.size()):
		temp_buttons[i].modulate = Color(1.25, 1.12, 0.72) if (i + 1) == lvl else Color.WHITE
	machine_power_label.text = "电力 %d/%d" % [GameState.power, GameState.max_power]
	machine_start_btn.disabled = dur <= 0 or fault != ""
	for j in GameState.machine_jobs:
		if String(j.get("machine_id", "")) == selected_machine_id:
			machine_start_btn.disabled = true
	if machine_harvest_btn:
		var ready := not growth_job.is_empty() and bool(growth_job.get("ready", false))
		machine_harvest_btn.disabled = not ready
		if not growth_job.is_empty():
			if ready:
				machine_status_label.text = "作物可收获（剩余 %d 次）。" % int(growth_job.get("harvests_left", 0))
			else:
				machine_status_label.text = "作物生长中：%.1fs。" % float(growth_job.get("remaining", 0.0))
	if machine_repair_btn:
		machine_repair_btn.text = "维修 %d₵" % GameState.machine_repair_cost(selected_machine_id)
		machine_repair_btn.disabled = dur >= 100 and fault == ""
	_refresh_machine_jobs()
	_refresh_machine_selection()

func _short_item_name(id: String, fallback: String) -> String:
	match id:
		"water_bottle_full": return "纯净水"
		"water_tablet": return "净水药片"
		"bottled_water_premium": return "瓶装泉水"
		"scrap_metal": return "废金属"
		"metal_ingot": return "金属锭"
		"printer_plastic": return "打印塑料"
		"printed_gun": return "打印手枪"
	if fallback.length() <= 8:
		return fallback
	return fallback.substr(0, 8)

func _refresh_machine_jobs() -> void:
	if GameState.machine_jobs.is_empty():
		machine_jobs_label.text = "无"
		return
	var text := ""
	for j in GameState.machine_jobs:
		if bool(j.get("growth", false)):
			if bool(j.get("ready", false)):
				text += "· %s  可收获（剩余 %d 次）
" % [j.get("name", ""), int(j.get("harvests_left", 0))]
			else:
				text += "· %s  生长中 %.1fs
" % [j.get("name", ""), float(j.get("remaining", 0.0))]
		else:
			text += "· %s  剩余 %.1fs
" % [j.get("name", ""), float(j.get("remaining", 0.0))]
	machine_jobs_label.text = text

func _harvest_selected_machine() -> void:
	var res := GameState.harvest_machine(selected_machine_id)
	_play_sfx("cash" if bool(res.get("ok", false)) else "fail")
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))

func _repair_selected_machine() -> void:
	var res := GameState.repair_machine(selected_machine_id)
	_play_sfx("machine" if bool(res.get("ok", false)) else "fail")
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))

func _start_selected_machine(quality: float = -1.0) -> void:
	if quality < 0.0 and selected_machine_id in ["printer", "chem_mixer", "dna_lab"]:
		var check := GameState.start_machine(selected_machine_id, 0.0, true)
		if not bool(check.get("ok", false)):
			machine_status_label.text = String(check.get("text", ""))
			_play_sfx("fail")
			return
		match selected_machine_id:
			"printer": _open_printer_minigame()
			"chem_mixer": _open_mix_minigame()
			"dna_lab": _open_dna_minigame()
		return
	var res := GameState.start_machine(selected_machine_id, maxf(quality, 0.0))
	if bool(res.get("ok", false)):
		_play_sfx("machine")
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))

func _install_module() -> void:
	var res := GameState.install_module(selected_machine_id)
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))

func _set_temp(level: int) -> void:
	GameState.set_machine_temp(selected_machine_id, level)
	_refresh_machine_panel()
	machine_status_label.text = "温度已切换，耗时与电力已更新。"

func _on_machine_finished(message: String) -> void:
	_refresh()
	if machine_layer and machine_layer.visible:
		_refresh_machine_panel()
		machine_status_label.text = message
	else:
		_toast(message)

func _process(delta: float) -> void:
	if machine_layer == null or not machine_layer.visible:
		return
	machine_ui_timer += delta
	if machine_ui_timer >= 0.25:
		machine_ui_timer = 0.0
		_refresh_machine_jobs()
		machine_power_label.text = "电力 %d/%d" % [GameState.power, GameState.max_power]

func _open_info_tab(tab: String) -> void:
	info_layer.visible = true
	info_tab = tab
	info_selected_id = ""
	_refresh_info_tabs()
	_rebuild_info_list()
	_refresh_info_detail()

func _close_info() -> void:
	info_layer.visible = false

func _switch_info_tab(tab: String) -> void:
	info_tab = tab
	info_selected_id = ""
	_refresh_info_tabs()
	_rebuild_info_list()
	_refresh_info_detail()

func _refresh_info_tabs() -> void:
	for k in info_tab_buttons.keys():
		info_tab_buttons[k].modulate = Color(1.25, 1.12, 0.72) if k == info_tab else Color.WHITE

func _rebuild_info_list() -> void:
	_clear_children(info_list_box)
	info_list_buttons.clear()
	match info_tab:
		"network":
			for u in GameState.upgrades:
				var uid := String(u.get("id", ""))
				var owned := GameState.owned_upgrades.has(uid)
				var text := "%s · %s" % [u.get("name", uid), "已拥有" if owned else "%d₵" % int(u.get("cost", 0))]
				_add_info_button(text, uid)
		"professions":
			for p in GameState.professions:
				_add_info_button(String(p.get("name", p.get("id", ""))), String(p.get("id", "")))
		"factions":
			for f in GameState.factions:
				var fid := String(f.get("id", ""))
				_add_info_button("%s  %+d" % [f.get("name", fid), int(GameState.rep.get(fid, 0))], fid)
		"customers":
			for c in GameState.customer_defs:
				var cid := String(c.get("id", ""))
				_add_info_button("%s · %s" % [c.get("name", cid), _faction_short(String(c.get("faction", "")))], cid)
		"phone":
			for c in GameState.commissions:
				var d := GameState.get_item_def(String(c.get("item_id", "")))
				_add_info_button("%s x%d · %d₵" % [d.get("name", c.get("item_id", "")), int(c.get("count", 1)), int(c.get("reward", 0))], String(c.get("id", "")))
		"wanted":
			for w in GameState.wanted:
				var wid := String(w.get("id", ""))
				var done := GameState.wanted_defeated.has(wid)
				_add_info_button("%s · %d₵%s" % [w.get("name", wid), int(w.get("reward", 0)), " · 已击败" if done else ""], wid)
		"archive":
			archive_groups = GameState.dialogue_archive
			for g in archive_groups:
				_add_info_button("%s · %d" % [g.get("name", g.get("id", "")), g.get("entries", []).size()], String(g.get("id", "")))
	if info_selected_id == "" and not info_list_buttons.is_empty():
		info_selected_id = String(info_list_buttons.keys()[0])
	_refresh_info_selection()

func _add_info_button(text: String, id: String) -> void:
	var b := _button(info_list_box, text, Vector2.ZERO, Vector2(480, 56), C_TEXT, _select_info_entry.bind(id))
	b.custom_minimum_size = Vector2(480, 56)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 18)
	info_list_buttons[id] = b

func _refresh_info_selection() -> void:
	for k in info_list_buttons.keys():
		info_list_buttons[k].modulate = Color(1.25, 1.12, 0.72) if k == info_selected_id else Color.WHITE

func _select_info_entry(id: String) -> void:
	info_selected_id = id
	_refresh_info_selection()
	_refresh_info_detail()

func _refresh_info_detail() -> void:
	info_name.text = ""
	info_meta.text = ""
	info_body.text = ""
	info_status.text = ""
	info_action.visible = false
	info_action.disabled = false
	info_body.visible = true
	archive_scroll.visible = false
	match info_tab:
		"network":
			var u := GameState.upgrade_def(info_selected_id)
			if u.is_empty():
				return
			info_name.text = String(u.get("name", ""))
			var owned := GameState.owned_upgrades.has(info_selected_id)
			info_meta.text = "%d₵ · 效果：%s" % [int(u.get("cost", 0)), u.get("desc", "")]
			info_body.text = String(u.get("desc", "")) + "

" + ("已拥有" if owned else "购买后立即生效，状态随存档保存。")
			info_action.visible = true
			info_action.text = "购买 %d₵" % int(u.get("cost", 0))
			info_action.disabled = owned or GameState.cash < int(u.get("cost", 0))
			info_status.text = "已拥有" if owned else ("现金不足" if GameState.cash < int(u.get("cost", 0)) else "可购买")
		"professions":
			var p := {}
			for x in GameState.professions:
				if String(x.get("id", "")) == info_selected_id:
					p = x
					break
			if p.is_empty():
				return
			var items: Array = []
			for entry in p.get("items", []):
				var d := GameState.get_item_def(String(entry[0]))
				items.append("%sx%d" % [d.get("name", entry[0]), int(entry[1])])
			info_name.text = String(p.get("name", ""))
			info_meta.text = "启动资金 +%d₵ · %s" % [int(p.get("cash", 0)), "、".join(items) if not items.is_empty() else "无额外物品"]
			info_body.text = String(p.get("desc", ""))
			info_action.visible = true
			info_action.text = "选择专精"
			info_action.disabled = GameState.profession_chosen
			info_status.text = "已选择：%s" % GameState.profession_id if GameState.profession_chosen else "仅本局第一次选择生效"
		"factions":
			var f := GameState.faction_def(info_selected_id)
			if f.is_empty():
				return
			var v := int(GameState.rep.get(info_selected_id, 0))
			var tier := GameState.faction_tier(info_selected_id)
			info_name.text = String(f.get("name", ""))
			info_meta.text = "声望 %+d · 已解锁 %d/%d 档" % [v, tier, f.get("perks", []).size()]
			var body := ""
			for perk in f.get("perks", []):
				var unlocked := v >= int(perk.get("threshold", 999))
				body += "%s %d · %s — %s
" % ["[已解锁]" if unlocked else "[未解锁]", int(perk.get("threshold", 0)), perk.get("name", ""), perk.get("desc", "")]
			info_body.text = body
		"customers":
			var c := {}
			for x in GameState.customer_defs:
				if String(x.get("id", "")) == info_selected_id:
					c = x
					break
			if c.is_empty():
				return
			info_name.text = String(c.get("name", ""))
			info_meta.text = "%s · %s · 预算 %d-%d₵" % [_faction_name(String(c.get("faction", ""))), "出售" if c.get("intent") == "sell" else "购买", int(c.get("budget", [0, 0])[0]), int(c.get("budget", [0, 0])[1])]
			info_body.text = String(c.get("greet", "")) + "

偏好：" + "、".join(c.get("prefer_tags", []))
		"phone":
			var c := {}
			for x in GameState.commissions:
				if String(x.get("id", "")) == info_selected_id:
					c = x
					break
			if c.is_empty():
				return
			var d := GameState.get_item_def(String(c.get("item_id", "")))
			info_name.text = "委托 · " + String(d.get("name", ""))
			info_meta.text = "%s · 报酬 %d₵ · 声望 +%d" % [_faction_name(String(c.get("faction", ""))), int(c.get("reward", 0)), int(c.get("rep", 0))]
			info_body.text = "需求：%s x%d

交付后从背包扣除物品，现金与派系声望立即结算。" % [d.get("name", c.get("item_id", "")), int(c.get("count", 1))]
			info_action.visible = true
			info_action.text = "交付委托"
			info_action.disabled = GameState.inventory_count(String(c.get("item_id", ""))) < int(c.get("count", 1))
			info_status.text = "背包数量不足" if info_action.disabled else "可交付"
		"wanted":
			var w := GameState.wanted_def(info_selected_id)
			if w.is_empty():
				return
			info_name.text = String(w.get("name", ""))
			info_meta.text = "悬赏 %d₵ · 目标：%s" % [int(w.get("reward", 0)), GameState.enemy_def(String(w.get("enemy", ""))).get("name", "")]
			info_body.text = String(w.get("desc", ""))
			info_action.visible = true
			info_action.text = "追捕"
			info_action.disabled = GameState.wanted_defeated.has(info_selected_id)
			info_status.text = "已击败" if info_action.disabled else "可追捕"
		"archive":
			var group: Dictionary = {}
			for g in archive_groups:
				if String(g.get("id", "")) == info_selected_id:
					group = g
					break
			info_name.text = String(group.get("name", "对话档案"))
			var entries: Array = group.get("entries", [])
			info_meta.text = "%d 条原版对话（私有内容）" % entries.size()
			info_body.visible = false
			archive_scroll.visible = true
			var body := ""
			for e in entries:
				body += String(e.get("text", "")) + "

"
			archive_text.text = body
			archive_scroll.scroll_vertical = 0
			info_status.text = "共 %d 条" % entries.size()

func _info_action() -> void:
	match info_tab:
		"network":
			var res := GameState.buy_upgrade(info_selected_id)
			_refresh()
			_rebuild_info_list()
			_refresh_info_detail()
			info_status.text = String(res.get("text", ""))
		"professions":
			var res := GameState.apply_profession(info_selected_id)
			_refresh()
			_refresh_info_detail()
			info_status.text = String(res.get("text", ""))
		"phone":
			var res := GameState.deliver_commission(info_selected_id)
			_refresh()
			info_selected_id = ""
			_rebuild_info_list()
			_refresh_info_detail()
			info_status.text = String(res.get("text", ""))
		"wanted":
			var w := GameState.wanted_def(info_selected_id)
			if w.is_empty() or GameState.wanted_defeated.has(info_selected_id):
				return
			info_layer.visible = false
			GameState.start_combat(String(w.get("enemy", "")), "security", info_selected_id)

func _open_network() -> void:
	_open_info_tab("network")

func _open_factions() -> void:
	_open_info_tab("factions")

func _on_story_available(node_id: String) -> void:
	if story_layer.visible:
		return
	_show_story(node_id)

func _show_story(node_id: String) -> void:
	var node := GameState.story_node(node_id)
	if node.is_empty():
		GameState.mark_story_seen(node_id)
		return
	story_node_id = node_id
	story_layer.visible = true
	story_name.text = String(node.get("speaker", "剧情"))
	story_text.text = String(node.get("text", ""))
	var portrait := String(node.get("portrait", ""))
	var path := _customer_path(portrait)
	if ResourceLoader.exists(path):
		story_portrait.texture = load(path)
		story_portrait.visible = true
	else:
		story_portrait.texture = null
		story_portrait.visible = false
	_clear_children(story_choices)
	var choices: Array = node.get("choices", [])
	if choices.is_empty():
		var b := _button(story_choices, "继续", Vector2.ZERO, Vector2(1260, 60), C_TEXT, _story_advance)
		b.custom_minimum_size = Vector2(1260, 60)
		b.add_theme_font_size_override("font_size", 24)
	else:
		for i in range(choices.size()):
			var label := String(choices[i].get("text", "选择"))
			var b := _button(story_choices, label, Vector2.ZERO, Vector2(1260, 60), C_AMBER, _story_choose.bind(i))
			b.custom_minimum_size = Vector2(1260, 60)
			b.add_theme_font_size_override("font_size", 24)
			if not GameState.choice_available(choices[i]):
				b.text = "[条件不足] " + label
				b.disabled = true

func _story_advance() -> void:
	_play_sfx("page")
	var node := GameState.story_node(story_node_id)
	var nxt := String(node.get("next", ""))
	GameState.mark_story_seen(story_node_id)
	if nxt != "":
		_show_story(nxt)
	else:
		_close_story()

func _story_choose(index: int) -> void:
	_play_sfx("soft")
	var node := GameState.story_node(story_node_id)
	var choices: Array = node.get("choices", [])
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	if not GameState.choice_available(choice):
		_toast("条件不足，无法选择。")
		return
	GameState.apply_story_effects(choice.get("effects", {}))
	var ending := GameState.resolve_ending(String(choice.get("ending", "")))
	var nxt := String(choice.get("next", node.get("next", "")))
	GameState.mark_story_seen(story_node_id)
	if ending != "":
		GameState.set_ending(ending)
		_close_story()
		_show_ending(ending)
	elif nxt != "":
		_show_story(nxt)
	else:
		_close_story()

func _show_ending(id: String) -> void:
	var e := GameState.ending_def(id)
	if e.is_empty():
		return
	_show_modal(String(e.get("title", "结局")), String(e.get("text", "")), [{"label": "重新开始", "cb": _restart_game, "color": C_RUST}, {"label": "关闭", "cb": _close_modal}])

func _close_story() -> void:
	story_layer.visible = false
	story_node_id = ""
	var nxt := GameState.take_queued_story()
	if nxt != "" and not GameState.story_node(nxt).is_empty():
		_show_story(nxt)
	else:
		_maybe_show_tutorial()
		_refresh()

func _on_combat_started() -> void:
	combat_layer.visible = true
	_update_combat_ui()

func _on_combat_updated() -> void:
	_update_combat_ui()

func _on_combat_finished(victory: bool, message: String) -> void:
	_play_sfx("cash" if victory else "fail")
	combat_layer.visible = false
	_refresh()
	if not victory and GameState.phase == "gameover" and GameState.ending_id != "":
		var e := GameState.ending_def(GameState.ending_id)
		var body := message
		if not e.is_empty():
			body += "\n\n【%s】\n%s" % [e.get("title", "结局"), e.get("text", "")]
		_show_modal("结局", body, [{"label": "重新开始", "cb": _restart_game, "color": C_RUST}, {"label": "关闭", "cb": _close_modal}])
		return
	_show_modal("战斗结果", message, [{"label": "关闭", "cb": _close_modal}])

func _update_combat_ui() -> void:
	if GameState.combat_enemy.is_empty():
		return
	var e := GameState.combat_enemy
	combat_enemy_name.text = String(e.get("name", ""))
	var path := _customer_path(String(e.get("sprite", "")))
	combat_enemy_sprite.texture = load(path) if ResourceLoader.exists(path) else null
	combat_enemy_bar.max_value = maxi(1, int(e.get("hp", 40)))
	combat_enemy_bar.value = clampi(GameState.combat_enemy_hp, 0, int(e.get("hp", 40)))
	combat_player_bar.max_value = GameState.combat_player_max
	combat_player_bar.value = clampi(GameState.combat_player_hp, 0, GameState.combat_player_max)
	combat_log_label.text = "
".join(GameState.combat_log.slice(maxi(0, GameState.combat_log.size() - 8)))
	combat_status.text = "敌人 HP %d/%d · 你的 HP %d/%d · 技能冷却 %d" % [GameState.combat_enemy_hp, int(e.get("hp", 40)), GameState.combat_player_hp, GameState.combat_player_max, GameState.combat_skill_cd]

func _combat_action(action: String) -> void:
	if not GameState.combat_active:
		return
	_play_sfx("gun" if action == "attack" else "soft")
	GameState.combat_action(action)
	_update_combat_ui()

func _toast(text: String) -> void:
	_show_modal("提示", text, [{"label": "知道了", "cb": _close_modal}])

func _show_modal(title: String, text: String, actions: Array) -> void:
	modal_title.text = title
	modal_text.add_theme_font_size_override("font_size", 26)
	modal_text.add_theme_constant_override("line_spacing", 6)
	modal_text.text = text
	_clear_children(modal_actions)
	var n := actions.size()
	var bw := 200 if n <= 4 else 140
	var fs := 26 if n <= 4 else 19
	modal_actions.add_theme_constant_override("separation", 16 if n <= 4 else 8)
	for a in actions:
		var b := _button(modal_actions, String(a.get("label", "确定")), Vector2.ZERO, Vector2(bw, 64), a.get("color", C_CYAN), a.get("cb", _close_modal))
		b.custom_minimum_size = Vector2(bw, 64)
		b.add_theme_font_size_override("font_size", fs)
	modal_layer.visible = true

func _close_modal() -> void:
	modal_layer.visible = false

func _clear_children(node: Node) -> void:
	for c in node.get_children():
		node.remove_child(c)
		c.queue_free()

func _weekday(d: int) -> String:
	return ["一", "二", "三", "四", "五", "六", "日"][(d - 1) % 7]

func _faction_name(k: String) -> String:
	match k:
		"lower": return "下层区"
		"security": return "治安部"
		"blackmarket": return "黑市"
		"upper": return "上层区"
		"rev": return "革命军"
		"tourist": return "游客"
		"church": return "教会"
		"cartel": return "卡特尔"
	return k

func _faction_short(k: String) -> String:
	match k:
		"lower": return "下层"
		"upper": return "上层"
		"security": return "治安"
		"blackmarket": return "黑市"
		"rev": return "革命"
		"tourist": return "游客"
		"church": return "教会"
		"cartel": return "卡特尔"
	return k

func _show_welcome() -> void:
	if welcome_shown:
		return
	welcome_shown = true
	_show_modal("欢迎来到下层区", "你盘下了一间当铺，欠着导师 200¥ 贷款，7 天后要交房租。\n\n流程：看顾客拿出什么 → 点「鉴定」验货 → 点「议价」或直接「成交」→ 结束营业结算。\n\n选择难度开始：简单（800₵ 启动资金、房租 150₵）、普通（600₵ / 200₵）、困难（450₵ / 260₵，敌人伤害更高）。", [
		{"label": "简单", "cb": _choose_difficulty.bind("easy"), "color": C_GREEN},
		{"label": "普通", "cb": _choose_difficulty.bind("normal"), "color": C_AMBER},
		{"label": "困难", "cb": _choose_difficulty.bind("hard"), "color": C_RUST},
	])

func _choose_difficulty(id: String) -> void:
	GameState.new_game(id)
	_welcome_done()

func _welcome_done() -> void:
	_close_modal()
	if GameState.pending_story != "" and not story_layer.visible:
		_show_story(GameState.pending_story)
	else:
		_maybe_show_tutorial()

func _tutorial_text() -> String:
	match GameState.tutorial_step:
		1: return "教程 1/4：先点右侧「鉴定」检查顾客的物品。"
		2: return "教程 2/4：点「议价」砍价，或直接「成交」。"
		3: return "教程 3/4：选中背包物品点「上架」，展示柜商品才能卖给买家。"
		4: return "教程 4/4：点左侧「结束营业」进入下一天。"
	return "右侧选择交涉动作 · 长按物品查看详情"

func _show_tutorial(step: int) -> void:
	GameState.tutorial_step = step
	var body := ""
	match step:
		1:
			body = "顾客上门后，先把柜台上的物品看清楚。\n点右侧「鉴定」可以验出真伪、品相与赃物。\n鉴定会收费，两次以上才能得出结论。"
		2:
			body = "鉴定完可以点「议价」调整报价，也可以直接「成交」。\n压价太狠会让顾客失去耐心。"
		3:
			body = "收下的货要卖给买家，先选中物品点「上架」。\n只有展示柜里的商品才能放到交易台。"
		4:
			body = "今天的顾客接待完后，点左侧「结束营业」结算。\n房租每 7 天到期，贷款第 12 天到期。"
		_:
			body = "教程已完成。"
	_show_modal("新手教程 %d/4" % step, body, [
		{"label": "知道了", "cb": _close_modal},
		{"label": "跳过教程", "cb": _skip_tutorial},
	])

func _maybe_show_tutorial() -> void:
	if GameState.tutorial_done or GameState.day != 1:
		return
	if story_layer.visible or modal_layer.visible:
		return
	if GameState.tutorial_step <= 0:
		_show_tutorial(1)

func _skip_tutorial() -> void:
	GameState.tutorial_done = true
	GameState.tutorial_step = 0
	_close_modal()
	_refresh()

func _open_inspection() -> void:
	if GameState.current_customer.is_empty() or GameState.current_customer.get("intent") != "sell":
		_toast("只有顾客出售物品时才需要鉴定。")
		return
	if GameState.counter_item.is_empty():
		_toast("柜台上没有物品。")
		return
	_play_sfx("page")
	if GameState.tutorial_step == 1:
		GameState.tutorial_step = 2
		_refresh()
	_refresh_inspection_modal()

func _inspection_methods(itype: String) -> Array:
	match itype:
		"water": return ["水质试纸 5¥", "UV 灯 5¥", "扫描仪 10¥"]
		"cig": return ["检查封口 5¥", "查批次码 5¥", "扫描烟丝 10¥"]
		"cyber": return ["看材质 10¥", "测磨损 10¥", "查序列号 10¥"]
		"weapon": return ["看材质 10¥", "测磨损 10¥", "查序列号 10¥"]
	return ["看外观 5¥", "查标签 5¥", "问来源 5¥"]

func _refresh_inspection_modal() -> void:
	var it: Dictionary = GameState.counter_item
	if it.is_empty():
		_toast("柜台上没有物品。")
		return
	var def := GameState.get_item_def(it["def_id"])
	var itype := String(def.get("inspect_type", "generic"))
	var text := "物品：%s\n品相：%d%%\n\n选择鉴定方式。鉴定费从现金扣除，两次以上可得出结论。" % [GameState.item_display_name(it), int(it.get("condition", 100))]
	if not it.get("clues", []).is_empty():
		var clue_text := ""
		for c in it["clues"]:
			clue_text += "\n· " + String(c)
		text += "\n\n已获得线索：" + clue_text
	if it.get("known", false):
		text += "\n\n鉴定结论：\n" + GameState._true_desc(it)
	var actions: Array = []
	if it.get("known", false):
		actions.append({"label": "关闭", "cb": _close_modal})
		actions.append({"label": "去议价", "cb": _open_bargain, "color": C_AMBER})
	else:
		var methods := _inspection_methods(itype)
		for i in range(methods.size()):
			actions.append({"label": methods[i], "cb": _inspect_method.bind(i)})
		actions.append({"label": "关闭", "cb": _close_modal})
	_show_modal("鉴定 · " + GameState.item_display_name(it), text, actions)

func _inspect_method(method: int) -> void:
	var clue := GameState.inspect_item(int(GameState.counter_item.get("uid", -1)), method)
	_refresh()
	if not GameState.counter_item.is_empty() and GameState.counter_item.get("known", false):
		_refresh_inspection_modal()
	else:
		_refresh_inspection_modal()

func _open_bargain() -> void:
	if GameState.current_customer.is_empty() or GameState.counter_item.is_empty():
		_toast("当前没有可议价的物品。")
		return
	_play_sfx("soft")
	if GameState.current_customer.get("intent") == "sell":
		bargain_price = int(GameState.counter_item.get("asking_price", 0))
	else:
		bargain_price = int(GameState.current_customer.get("offer", 0))
	_refresh_bargain_modal()

func _refresh_bargain_modal() -> void:
	var c: Dictionary = GameState.current_customer
	var it: Dictionary = GameState.counter_item
	if c.is_empty() or it.is_empty():
		_close_modal()
		return
	var def := GameState.get_item_def(it["def_id"])
	var text := ""
	if c.get("intent") == "sell":
		text = "顾客开价：%d¥\n你的报价：%d¥\n\n压低价格会降低成交率；鉴定后再出价更安全。\n现金：%d¥" % [int(it.get("asking_price", 0)), bargain_price, GameState.cash]
	else:
		text = "顾客出价：%d¥\n你的报价：%d¥\n\n顾客预算：%d¥\n现金：%d¥" % [int(c.get("offer", 0)), bargain_price, int(c.get("budget", 0)), GameState.cash]
	var actions: Array = [
		{"label": "-10%", "cb": _bargain_adjust.bind(0.9)},
		{"label": "-5%", "cb": _bargain_adjust.bind(0.95)},
		{"label": "+5%", "cb": _bargain_adjust.bind(1.05)},
		{"label": "+10%", "cb": _bargain_adjust.bind(1.1)},
		{"label": "报价", "cb": _bargain_confirm, "color": C_AMBER},
		{"label": "威胁", "cb": _do_threaten, "color": C_RUST},
	]
	_show_modal("议价 · " + GameState.item_display_name(it), text, actions)

func _bargain_adjust(factor: float) -> void:
	bargain_price = maxi(1, int(round(float(bargain_price) * factor)))
	_refresh_bargain_modal()

func _bargain_confirm() -> void:
	var res: Dictionary = {}
	if GameState.current_customer.get("intent") == "sell":
		res = GameState.make_offer(bargain_price)
	else:
		res = GameState.make_sell_offer(bargain_price)
	_refresh()
	var actions: Array = [{"label": "关闭", "cb": _close_modal}]
	if res.has("counter"):
		bargain_price = int(res["counter"])
		actions.append({"label": "继续议价", "cb": _refresh_bargain_modal, "color": C_AMBER})
	_show_modal("议价结果", String(res.get("text", "")), actions)

func _do_threaten() -> void:
	_play_sfx("hit")
	var res := GameState.threaten()
	_refresh()
	_show_modal("威胁", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _do_deal() -> void:
	var res := GameState.accept_current()
	_play_sfx("cash" if bool(res.get("accepted", false)) else "fail")
	if bool(res.get("accepted", false)) and GameState.tutorial_step == 2:
		GameState.tutorial_step = 3
	_refresh()
	_show_modal("成交", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _do_dismiss() -> void:
	if GameState.current_customer.is_empty():
		return
	GameState.complete_customer(false)
	_refresh()

func _on_event_started(event: Dictionary) -> void:
	var text := String(event.get("text", ""))
	var actions: Array = []
	var choices: Array = event.get("choices", [])
	for i in range(choices.size()):
		actions.append({"label": choices[i].get("label", "选择"), "cb": _on_event_choice.bind(i, choices[i].get("result", ""))})
	_show_modal(String(event.get("title", "夜间事件")), text, actions)

func _on_event_choice(index: int, result: String) -> void:
	_play_sfx("page")
	var ev: Dictionary = GameState.pending_event
	var choice: Dictionary = {}
	var choices: Array = ev.get("choices", [])
	if index >= 0 and index < choices.size():
		choice = choices[index]
	GameState.apply_event(index)
	_refresh()
	if GameState.phase == "gameover" and GameState.ending_id != "":
		_close_modal()
		_show_ending(GameState.ending_id)
		return
	if choice.has("combat"):
		_close_modal()
		GameState.start_combat(String(choice.get("combat", "")), "security", "", String(ev.get("id", "")))
	else:
		_show_modal("事件结果", result, [{"label": "继续", "cb": _close_modal}])






