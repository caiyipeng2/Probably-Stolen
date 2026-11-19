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
const UI_PANEL_TEX := "res://assets_private/ui_panels/"
const WALKER_TEX := "res://assets_private/walkers/walker1_%d.png"

var font: FontFile
var game_view: Control
var bg_window: TextureRect
var customer_rect: TextureRect
var customer_idle_tween: Tween
var customer_shadow_tween: Tween
var customer_shown_key := ""
var walker_layer: Control
var walkers: Array = []
var walker_textures: Array = []
var walker_far_timer := 1.5
var walker_mid_timer := 2.0
var fg: TextureRect
var day_label: Label
var rent_label: Label
var cash_label: Label
var status_label: Label
var paper_goals: Label
var customer_name_label: Label
var customer_info_label: Label
var queue_label: Label
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
var detail_inspect_btn: Button
var detail_open_btn: Button
var detail_liquid_btn: Button
var detail_split_btn: Button
var detail_equip_btn: Button
var modal_layer: Control
var modal_panel: Panel
var modal_title: Label
var modal_text: Label
var modal_actions: HBoxContainer
var summary_tabs: HBoxContainer
var summary_tab := "overview"
var modal_close_btn: Button
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
var machine_recipe_btn: Button
var machine_aux_btn: Button
var machine_special_btn: Button
var machine_stock_btn: Button
var machine_take_btn: Button
var machine_stock_grid_btn: Button
var machine_io_in_btn: Button
var machine_io_out_btn: Button
var inspection_layer: Control
var inspection_title: Label
var inspection_info: Label
var inspection_pixel_icon: TextureRect
var inspection_pixel_meta: Label
var inspection_actions: VBoxContainer
var inspection_status: Label
var inspection_appraisal_input: LineEdit
var inspection_uid := -1
var container_layer: Control
var container_title: Label
var container_info: Label
var container_grid: Control
var container_actions: VBoxContainer
var open_container_uid := -1
var container_stack: Array = []
var container_selected_uid := -1
var showcase_layer: Control
var showcase_grid: Control
var showcase_info: Label
var showcase_actions: VBoxContainer
var showcase_selected_uid := -1
var trash_layer: Control
var trash_grid: Control
var trash_info: Label
var trash_actions: VBoxContainer
var trash_selected_uid := -1
var inspection_owned := false
var promotion_prompt_day := -1
var select_layer: Control
var select_list: VBoxContainer
var select_title: Label
var select_cb: Callable
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
var info_icon: TextureRect
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
var combat_impact: TextureRect
var combat_enemy_name: Label
var combat_enemy_bar: ProgressBar
var combat_player_bar: ProgressBar
var combat_log_label: Label
var combat_status: Label
var combat_actions_box: HFlowContainer
var action_buttons: Dictionary = {}
var rail_buttons: Dictionary = {}
var rep_labels: Dictionary = {}
var tab_buttons: Dictionary = {}
var page_buttons: Array = []

var music_player: AudioStreamPlayer
var radio_player: AudioStreamPlayer
var radio_index := 0
var radio_playing := false
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
var drag_source := "main"
const CONTAINER_CELL := 46
const CONTAINER_STEP := 50
const UI_WINDOWS_PATH := "user://ui_windows.json"
var container_panel: Panel
var container_positions: Dictionary = {}
var window_dragging := false
var window_drag_offset := Vector2.ZERO
var barter_layer: Control
var barter_title: Label
var barter_line: Label
var barter_want: Label
var barter_offer_box: Control
var barter_page: Label
var barter_accept_btn: Button
var barter_prev_btn: Button
var barter_next_btn: Button
var barter_status: Label
var wholesale_layer: Control
var wholesale_title: Label
var wholesale_line: Label
var wholesale_box: Control
var wholesale_total_label: Label
var wholesale_buy_btn: Button
var wholesale_status: Label
var phone_layer: Control
var phone_number_label: Label
var phone_status_label: Label
var phone_book_box: Control
var phone_dlg_panel: Panel
var phone_dlg_speaker: Label
var phone_dlg_text: Label
var phone_dlg_choices: VBoxContainer
var phone_dlg_cont_btn: Button
var phone_pages: Array = []
var phone_page_index := 0
var phone_dialog_sid := ""
var phone_dialog_choices: Array = []
var commissary_layer: Control
var commissary_credit_label: Label
var commissary_list: VBoxContainer
var commissary_status: Label
var bargain_price := 0
var welcome_shown := false
var last_summary: Dictionary = {}
var newgame_layer: Control
var ng_page := "menu"
var ng_start_type := "apprentice"
var ng_perks: Array = []
var ng_difficulty := "normal"
var ng_campaign := "original"
var ng_skip_intro := false
var news_archive: Array = []
var input_layer: Control
var input_title: Label
var input_field: LineEdit
var input_cb: Callable
var queue_portrait_rects: Array = []
var poster_layer: Control
var poster_image: TextureRect
var poster_status: Label
var receipt_stamp: Label
var bell_button: Button
var room_ambience_player: AudioStreamPlayer
var shop_poster: TextureRect

func _ready() -> void:
	force_public_assets = "--publicassets" in OS.get_cmdline_args()
	_setup_theme()
	_setup_audio()
	_load_window_positions()
	_audioinfo_if_requested()
	_build_ui()
	GameState.state_changed.connect(_refresh)
	GameState.customer_changed.connect(_on_customer_changed)
	GameState.day_finished.connect(_on_day_finished)
	GameState.event_started.connect(_on_event_started)
	GameState.machine_finished.connect(_on_machine_finished)
	GameState.music_toggled.connect(_on_music_toggled)
	GameState.story_available.connect(_on_story_available)
	GameState.inspection_arrived.connect(_on_inspection_arrived)
	GameState.security_officer_arrived.connect(_on_security_officer_arrived)
	GameState.permit_revoke_arrived.connect(_on_permit_revoke_arrived)
	GameState.achievement_unlocked.connect(_on_achievement_unlocked)
	GameState.news_ready.connect(_on_news_ready)
	GameState.combat_hit.connect(_on_combat_hit)
	GameState.combat_started.connect(_on_combat_started)
	GameState.combat_updated.connect(_on_combat_updated)
	GameState.combat_finished.connect(_on_combat_finished)
	_refresh()
	_build_newgame_layer()
	_build_input_layer()
	_build_poster_layer()
	_show_new_game_menu()
	_capture_if_requested()
	_autotest_if_requested()
	_dumpui_if_requested()
	_dumpinspect_if_requested()
	_testminigame_if_requested()
	_testmachineui_if_requested()
	_testinspect_if_requested()
	_testcontainerui_if_requested()
	_testbarterui_if_requested()
	_testphoneui_if_requested()
	_testcombatui_if_requested()
	_testsecurityui_if_requested()
	_testpresentationui_if_requested()
	_testp0ui_if_requested()
	_testp1ui_if_requested()
	_testspaceui_if_requested()
	_testp2ui_if_requested()

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
	selected_machine_id = "chem_finisher"
	_open_mix_minigame()
	for i in range(3):
		mix_sliders[i].set_value_no_signal(float(mix_target[i]))
	_confirm_mix()
	print("MINIGAME mix_jobs=", GameState.machine_jobs.size(), " status=", machine_status_label.text)
	selected_machine_id = "plant_dna_manipulator"
	_open_dna_minigame()
	dna_input = dna_target.duplicate()
	dna_input_label.text = "你的序列： " + " ".join(dna_input)
	_confirm_dna()
	print("MINIGAME dna_jobs=", GameState.machine_jobs.size(), " status=", machine_status_label.text)
	get_tree().quit()

func _testmachineui_if_requested() -> void:
	if not "--testmachineui" in OS.get_cmdline_args():
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
	_open_machines()
	selected_machine_id = "printer"
	_refresh_machine_panel()
	print("MUI printer io=", machine_io_label.text.replace("\n", " | "))
	selected_machine_id = "recharger"
	_refresh_machine_panel()
	print("MUI recharger aux=", machine_aux_btn.visible, " special=", machine_special_btn.visible, " rule=", machine_io_label.text.replace("\n", " | "))
	print("MUI recharger toggle=", GameState.machine_toggle_active("recharger").get("text", ""))
	selected_machine_id = "vending_machine"
	_refresh_machine_panel()
	print("MUI vending stockbtn=", machine_stock_btn.visible, " rule=", machine_io_label.text.replace("\n", " | "))
	GameState.machine_toggle_active("vending_machine")
	_refresh_machine_panel()
	print("MUI vending special=", machine_special_btn.text, " stock=", machine_stock_btn.visible)
	selected_machine_id = "makeshift_reactor"
	_refresh_machine_panel()
	print("MUI reactor special=", machine_special_btn.text)
	selected_machine_id = "animal_cage"
	_refresh_machine_panel()
	print("MUI cage special=", machine_special_btn.text, " stock=", machine_stock_btn.visible)
	selected_machine_id = "hydroponic"
	_refresh_machine_panel()
	print("MUI hydro recipe=", machine_recipe_btn.text, " io=", machine_io_label.text.replace("\n", " | "))
	selected_machine_id = "fridge"
	_refresh_machine_panel()
	print("MUI fridge gridbtn=", machine_stock_grid_btn.visible, " text=", machine_stock_grid_btn.text)
	_open_machine_stock_grid()
	await get_tree().process_frame
	print("MUI fridge container=", container_title.text, " ", container_info.text)
	selected_machine_id = "furnace"
	_refresh_machine_panel()
	print("MUI furnace io in=", machine_io_in_btn.visible, " ", machine_io_in_btn.text, " out=", machine_io_out_btn.visible, " ", machine_io_out_btn.text)
	_open_machine_io("input")
	await get_tree().process_frame
	print("MUI furnace input=", container_title.text, " ", container_info.text)
	_close_container()
	get_tree().quit()

func _testinspect_if_requested() -> void:
	if not "--testinspect" in OS.get_cmdline_args():
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
	var cig := GameState.make_item("cig_red", 100, false, false)
	GameState.counter_item = cig
	GameState.current_customer = {"intent": "sell", "arche": {"faction": "lower", "name": "测试顾客", "sprite": "maleUpper_0.png"}, "item": cig, "patience": 3, "done": false}
	GameState.phase = "customer"
	_open_inspection()
	await get_tree().process_frame
	print("INSPECT title=", inspection_title.text)
	print("INSPECT info=", inspection_info.text.replace("\n", " | "))
	for b in inspection_actions.get_children():
		if b is Button:
			print("INSPECT BTN ", b.text)
	GameState.inspect_counter_with_tool("magnifier")
	_refresh_inspection_modal()
	print("INSPECT after magnifier=", inspection_info.text.replace("\n", " | ").substr(0, 400))
	GameState.confront_counter_item(String(cig.issues[0]))
	_refresh_inspection_modal()
	print("INSPECT after confront=", inspection_status.text)
	var app_item := GameState.make_item("hand_steel", 100, true, false)
	app_item.appraisal_value = 620
	GameState.counter_item = app_item
	GameState.current_customer = {"intent": "appraise", "arche": {"faction": "lower", "name": "估价客", "sprite": "maleUpper_0.png"}, "item": app_item, "patience": 3, "done": false, "impatience": 0}
	GameState.phase = "customer"
	_open_inspection()
	await get_tree().process_frame
	print("APPRAISE input_visible=", inspection_appraisal_input.visible, " default=", inspection_appraisal_input.text)
	inspection_appraisal_input.text = "620"
	_submit_appraisal()
	await get_tree().process_frame
	print("APPRAISE modal=", modal_title.text, " ", modal_text.text.replace("\n", " | ").substr(0, 300))
	get_tree().quit()

func _testcontainerui_if_requested() -> void:
	if not "--testcontainerui" in OS.get_cmdline_args():
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
	var bag := GameState.make_item("backpack_large", 100, true, false)
	GameState.add_item(bag)
	var fruit := GameState.make_item("nutrifruit", 100, true, false)
	GameState.add_item(fruit)
	GameState.move_item_to_container(int(fruit.uid), int(bag.uid))
	_open_container(int(bag.uid))
	await get_tree().process_frame
	print("CUI title=", container_title.text)
	print("CUI info=", container_info.text)
	for b in container_actions.get_children():
		if b is Button:
			print("CUI BTN ", b.text)
	print("CUI grid_children=", container_grid.get_child_count())
	_open_container(int(fruit.uid))
	print("CUI noncontainer_open=", container_layer.visible)
	_open_container(int(bag.uid))
	GameState.container_remove_child(bag, int(fruit.uid))
	GameState.add_item(fruit)
	_rebuild_container_grid()
	print("CUI after take children=", bag.children.size(), " info=", container_info.text)
	_refresh()
	print("CUI grid page_dim=", GameState.page_size(current_page), " cap=", capacity_label.text)
	get_tree().quit()

func _testbarterui_if_requested() -> void:
	if not "--testbarterui" in OS.get_cmdline_args():
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
	GameState.inventory.clear()
	GameState.add_item(GameState.make_item("nutrifruit", 100, true, false))
	GameState.add_item(GameState.make_item("processed_meat", 100, true, false))
	GameState.current_customer = {
		"arche": {"faction": "lower"}, "intent": "barter", "done": false,
		"line": "我想用这些东西和你换点吃的。", "barter_name": "穷拾荒者",
		"barter_conditions": [{"tag": "FOOD", "count": 2}],
		"barter_offers": [{"items": [{"id": "blood_bag", "count": 2}]}, {"items": [{"id": "scrap_metal", "count": 3}]}],
		"barter_index": 0, "barter_accept_key": "dialog_barter_food_normal_accept", "barter_done_key": "dialog_barter_food_normal_done",
	}
	_open_barter()
	await get_tree().process_frame
	print("BUI title=", barter_title.text)
	print("BUI want=", barter_want.text)
	print("BUI page=", barter_page.text, " accept_disabled=", barter_accept_btn.disabled)
	print("BUI offer_cards=", barter_offer_box.get_child_count())
	_barter_accept()
	await get_tree().process_frame
	print("BUI after accept done=", bool(GameState.current_customer.get("done", false)), " wire=", GameState.inventory_count("blood_bag"), " line=", barter_line.text.substr(0, 20))
	print("BUI accept_visible=", barter_accept_btn.visible, " status=", barter_status.text)
	get_tree().quit()

func _testphoneui_if_requested() -> void:
	if not "--testphoneui" in OS.get_cmdline_args():
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
	GameState.cash = 10000
	GameState.buy_upgrade("BREWER")
	_open_phone()
	await get_tree().process_frame
	print("PUI layer=", phone_layer.visible, " book_buttons=", phone_book_box.get_child_count())
	_phone_key("8")
	_phone_key("8")
	_phone_key("1")
	_phone_key("5")
	print("PUI number=", phone_number_label.text)
	_phone_dial()
	await get_tree().process_frame
	print("PUI dialog=", phone_dlg_panel.visible, " speaker=", phone_dlg_speaker.text, " pages=", phone_pages.size(), " text=", phone_dlg_text.text.substr(0, 24))
	for i in range(phone_pages.size() - 1):
		_phone_next_page()
	print("PUI choices=", phone_dlg_choices.get_child_count(), " cont_visible=", phone_dlg_cont_btn.visible)
	_phone_choose("intro_end")
	await get_tree().process_frame
	print("PUI after intro book=", phone_book_box.get_child_count(), " state=", GameState.phone_client("red_imp").get("state", ""), " future=", GameState.future_customers.size())
	_close_phone()
	get_tree().quit()

func _testcombatui_if_requested() -> void:
	if not "--testcombatui" in OS.get_cmdline_args():
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
	GameState.start_combat("thug")
	await get_tree().process_frame
	print("CUI layer=", combat_layer.visible, " status=", combat_status.text.replace("
", " | "))
	print("CUI skills=", combat_actions_box.get_child_count())
	for b in combat_actions_box.get_children():
		if b is Button:
			print("CUI BTN ", b.text)
	guard = 0
	while GameState.combat_active and guard < 40:
		guard += 1
		if GameState.combat_waiting_for_player():
			GameState.combat_player_action(GameState.combat_player_weapon, GameState.combat_target_uid)
			_update_combat_ui()
	await get_tree().process_frame
	print("CUI end active=", GameState.combat_active, " log=", " / ".join(GameState.combat_log.slice(maxi(0, GameState.combat_log.size() - 4))))
	get_tree().quit()

func _testsecurityui_if_requested() -> void:
	if not "--testsecurityui" in OS.get_cmdline_args():
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
	GameState.sec_crimes = {"WEAPON_TRAFFICKING": 500}
	GameState.sec_evidence = 100
	GameState.sec_officer_pending = true
	_on_security_officer_arrived()
	await get_tree().process_frame
	print("SUI officer title=", modal_title.text, " actions=", modal_actions.get_child_count())
	_close_modal()
	GameState.sec_officer_pending = false
	GameState.sec_inspection_pending = true
	GameState.sec_inspection_personality = 1
	GameState.cash = 500
	_on_inspection_arrived()
	await get_tree().process_frame
	print("SUI inspection title=", modal_title.text, " actions=", modal_actions.get_child_count())
	_close_modal()
	GameState.sec_inspection_pending = false
	GameState.sec_inspection_personality = 2
	GameState.sec_inspection_pending = true
	GameState.sec_inspection_fake = false
	_on_inspection_arrived()
	await get_tree().process_frame
	print("SUI lazy title=", modal_title.text)
	_close_modal()
	GameState.sec_inspection_pending = false
	var trash_item := GameState.make_item("handmade_pistol", 100, true, false)
	GameState.add_item(trash_item)
	var moved := GameState.move_to_trash(int(trash_item.get("uid", -1)))
	_open_trash()
	await get_tree().process_frame
	print("SUI trash moved=", moved, " count=", GameState.trash_items.size(), " title=", trash_info.text.substr(0, 24))
	_close_trash()
	GameState.active_permits = [{"type": "FIREARM", "level": 1}]
	GameState.sec_permit_revoke_pending = true
	GameState.sec_permit_revoke_levels = [1]
	_on_permit_revoke_arrived()
	await get_tree().process_frame
	print("SUI permit title=", modal_title.text, " actions=", modal_actions.get_child_count())
	_close_modal()
	GameState.sec_permit_revoke_pending = false
	GameState.sec_permit_revoke_levels = []
	_open_info_tab("security")
	await get_tree().process_frame
	print("SUI tab name=", info_name.text, " meta=", info_meta.text)
	print("SUI body=", info_body.text.replace("
", " | ").substr(0, 120))
	_open_info_tab("network")
	info_selected_id = "EVIDENCE_REMOVAL"
	_refresh_info_detail()
	await get_tree().process_frame
	print("SUI evidence removal status=", info_status.text, " action=", info_action.text)
	GameState.procurement_orders = []
	GameState.current_customer = GameState._gen_procurement_offer_customer()
	_open_procurement_offer()
	await get_tree().process_frame
	print("SUI procurement title=", modal_title.text, " actions=", modal_actions.get_child_count())
	_close_modal()
	_open_info_tab("perks")
	info_selected_id = "perk_saving"
	_refresh_info_detail()
	await get_tree().process_frame
	print("SUI perk title=", info_name.text, " status=", info_status.text)
	_open_info_tab("rep_perks")
	info_selected_id = "SEC_TRUSTED"
	_refresh_info_detail()
	await get_tree().process_frame
	print("SUI rep perk title=", info_name.text, " meta=", info_meta.text)
	for u in GameState.special_customers.get("unique", []):
		if String(u.get("id", "")) == "information_dealer":
			GameState.current_customer = GameState._gen_special_customer(u)
			_open_information_dealer()
			await get_tree().process_frame
			print("SUI info title=", modal_title.text, " actions=", modal_actions.get_child_count())
			_close_modal()
			break
	for u in GameState.special_customers.get("unique", []):
		if String(u.get("id", "")) == "expedition_organizer":
			GameState.current_customer = GameState._gen_special_customer(u)
			_open_expedition()
			await get_tree().process_frame
			print("SUI expedition title=", modal_title.text, " actions=", modal_actions.get_child_count())
			_close_modal()
			break
	get_tree().quit()

func _capture_if_requested() -> void:
	if "--capturepresentation" in OS.get_cmdline_args():
		await get_tree().create_timer(1.0).timeout
		_welcome_done()
		await get_tree().create_timer(0.2).timeout
		var pguard := 0
		while story_layer.visible and pguard < 40:
			_story_advance()
			pguard += 1
		if modal_layer.visible:
			_close_modal()
		GameState.customers_today = [{"dummy": true}, {"dummy": true}, {"dummy": true}]
		GameState.phase = "customer"
		walker_far_timer = 0.0
		walker_mid_timer = 0.0
		_update_walkers(0.1)
		customer_rect.modulate = Color.WHITE
		await get_tree().create_timer(0.7).timeout
		get_viewport().get_texture().get_image().save_png("res://_research/mockups/m35_shop_walkers.png")
		_show_receipt("治安查抄单", "查获违禁品：手枪 ×1\n罚款：200₵\n盖章：治安部")
		await get_tree().create_timer(0.4).timeout
		get_viewport().get_texture().get_image().save_png("res://_research/mockups/m35_receipt.png")
		_show_news("号外：夜里有雨", "治安部今晚加强巡逻，黑市暂时关门。", [{"label": "知道了", "cb": _close_modal}])
		await get_tree().create_timer(0.4).timeout
		get_viewport().get_texture().get_image().save_png("res://_research/mockups/m35_news.png")
		get_tree().quit()
		return
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
	room_ambience_player = AudioStreamPlayer.new()
	room_ambience_player.volume_db = -20.0
	add_child(room_ambience_player)
	radio_player = AudioStreamPlayer.new()
	radio_player.volume_db = -14.0
	add_child(radio_player)
	for i in range(4):
		var p := AudioStreamPlayer.new()
		p.volume_db = -8.0
		add_child(p)
		sfx_players.append(p)

func _audio_path(name: String) -> String:
	var original_path := "res://assets_private/audio_original/" + name
	var private_path := "res://assets_private/audio/" + name
	var public_path := "res://assets_public/audio/" + name
	if force_public_assets:
		return public_path if ResourceLoader.exists(public_path) else ""
	if ResourceLoader.exists(original_path):
		return original_path
	if ResourceLoader.exists(private_path):
		return private_path
	return public_path if ResourceLoader.exists(public_path) else ""

func _play_room_ambience(file_name: String) -> void:
	if not audio_enabled or room_ambience_player == null:
		return
	var path := _audio_path(file_name)
	if path == "":
		return
	var st = load(path)
	if st is AudioStreamOggVorbis:
		st.loop = true
	room_ambience_player.stream = st
	room_ambience_player.play()

func _stop_room_ambience() -> void:
	if room_ambience_player:
		room_ambience_player.stop()

func _ring_bell() -> void:
	_play_named_sfx("new_bell.ogg")
	var res := GameState.summon_customer()
	_refresh()
	if not bool(res.get("ok", false)):
		_toast(String(res.get("text", "")))

func _play_named_sfx(file_name: String) -> void:
	if not audio_enabled or sfx_players.is_empty():
		return
	var path := _audio_path(file_name)
	if path == "":
		return
	if not sfx_cache.has(path):
		sfx_cache[path] = load(path)
	var p: AudioStreamPlayer = sfx_players[sfx_next % sfx_players.size()]
	sfx_next += 1
	p.stream = sfx_cache[path]
	p.play()

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

func _toggle_radio() -> void:
	if radio_player == null:
		return
	if radio_playing:
		radio_player.stop()
		radio_playing = false
		_toast("电台关闭。")
		return
	var songs := [
		"01_a_bao_a_qu", "02_the_wailing", "03_long_star_river", "04_deluge",
		"05_spellsinger_radio_edition", "06_golden_lotus", "07_junkyard_jockey",
	]
	var qualities := ["pristine", "slightly_degraded", "very_degraded"]
	var song := String(songs[radio_index % songs.size()])
	var quality := String(qualities[int(floor(float(radio_index) / float(songs.size()))) % qualities.size()])
	radio_index += 1
	var path := _audio_path("%s_%s.ogg" % [song, quality])
	if path == "":
		_toast("电台没有信号。")
		return
	radio_player.stream = load(path)
	radio_player.play()
	radio_playing = true
	_toast("电台：%s（%s）" % [song.replace("_", " ").capitalize(), quality.replace("_", " ")])

func _on_music_toggled(on: bool) -> void:
	if music_player == null:
		return
	if on and audio_enabled and music_player.stream:
		music_player.play()
	elif not on:
		music_player.stop()

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

func _tex_style(tex_name: String, margin: int, fallback_bg: Color, fallback_border: Color, bw: int = 2) -> StyleBox:
	var path := UI_PANEL_TEX + tex_name
	if ResourceLoader.exists(path):
		var sb := StyleBoxTexture.new()
		sb.texture = load(path)
		sb.texture_margin_left = margin
		sb.texture_margin_right = margin
		sb.texture_margin_top = margin
		sb.texture_margin_bottom = margin
		return sb
	return _style(fallback_bg, fallback_border, bw)

func _panel(parent: Node, pos: Vector2, size: Vector2, bg: Color, border: Color, bw: int = 2) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = size
	if bg == C_PANEL:
		p.add_theme_stylebox_override("panel", _tex_style("panel.png", 4, bg, border, bw))
	else:
		p.add_theme_stylebox_override("panel", _style(bg, border, bw))
	parent.add_child(p)
	return p

func _slot_cell(parent: Node, pos: Vector2, size: Vector2) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = size
	p.add_theme_stylebox_override("panel", _tex_style("slot_frame.png", 10, Color("#11151d"), Color("#2a3140"), 1))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	_texture_rect(game_view, Vector2.ZERO, Vector2(1920, 1080), _art_path("shop_scene_base.png"))
	bg_window = _texture_rect(game_view, Vector2.ZERO, Vector2(1920, 1080), _art_path("shop_bg_window.png"))
	shop_poster = _texture_rect(game_view, Vector2(420, 120), Vector2(100, 120), "")
	var shop_poster_path := "res://assets_private/posters/" + ("poster_down_crop.png" if GameState.poster_pulled else "poster_crop.png")
	if ResourceLoader.exists(shop_poster_path):
		shop_poster.texture = load(shop_poster_path)
	shop_poster.z_index = 2
	walker_layer = Control.new()
	walker_layer.position = Vector2.ZERO
	walker_layer.size = Vector2(1920, 1080)
	walker_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_view.add_child(walker_layer)
	customer_rect = _texture_rect(game_view, Vector2(635, 5), Vector2(677, 496), _customer_path("maleUpper_0.png"))
	fg = _texture_rect(game_view, Vector2.ZERO, Vector2(1920, 1080), _art_path("shop_fg.png"))
	for i in range(2):
		var qp := _texture_rect(game_view, Vector2(1200, 130 + i * 190), Vector2(100, 170), "")
		qp.visible = false
		qp.modulate = Color(0.62, 0.62, 0.72, 0.85)
		queue_portrait_rects.append(qp)
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
	bell_button = _button(game_view, "按铃 · 召唤顾客", Vector2(720, 630), Vector2(480, 80), C_GREEN, _ring_bell)
	bell_button.z_index = 6
	bell_button.add_theme_font_size_override("font_size", 30)
	_build_drawer()
	_build_modal()
	_build_inspection_layer()
	_build_container_layer()
	_build_showcase_layer()
	_build_trash_layer()
	_build_barter_layer()
	_build_wholesale_layer()
	_build_phone_layer()
	_build_commissary_layer()
	_build_machine_bay()
	_build_info_bay()
	_build_story_layer()
	_build_combat_layer()
	_build_minigame_layer()
	_build_select_layer()
	_build_mix_layer()
	_build_dna_layer()

func _build_hud() -> void:
	_panel(self, Vector2.ZERO, Vector2(2340, 80), C_PANEL, C_LINE)
	_label(self, "深空当铺", Vector2(24, 8), Vector2(300, 48), 36, C_AMBER)
	_label(self, "MOBILE PORT · M22", Vector2(26, 50), Vector2(300, 22), 16, C_MUTED)
	day_label = _label(self, "", Vector2(360, 18), Vector2(320, 42), 30, C_TEXT)
	rent_label = _label(self, "", Vector2(700, 18), Vector2(520, 42), 30, C_AMBER)
	_label(self, "信用点", Vector2(1560, 8), Vector2(200, 22), 18, C_MUTED)
	cash_label = _label(self, "", Vector2(1380, 24), Vector2(400, 52), 46, C_AMBER, HORIZONTAL_ALIGNMENT_RIGHT)
	_button(self, "状态", Vector2(1790, 14), Vector2(120, 52), C_GREEN, _open_status)
	audio_toggle_btn = _button(self, "音效 开" if audio_enabled else "音效 关", Vector2(1925, 14), Vector2(120, 52), C_MUTED, _on_audio_toggle)
	_button(self, "存档", Vector2(2060, 14), Vector2(120, 52), C_CYAN, _on_save)
	_button(self, "读档", Vector2(2190, 14), Vector2(120, 52), C_CYAN, _on_load)

func _build_left_rail() -> void:
	var rail := _panel(self, Vector2(0, 80), Vector2(210, 670), C_PANEL, C_LINE)
	_label(rail, "店铺", Vector2(20, 14), Vector2(170, 32), 24, C_AMBER)
	var items := [
		["顾客", "customers"], ["库存", "inventory"], ["网络", "network"],
		["手机", "phone"], ["机器", "machines"], ["派系", "factions"], ["档案", "ledger"],
		["设施", "facilities"], [GameState.loc("UI", "ui_end_day", "结束营业"), "end_day"],
	]
	for i in range(items.size()):
		var key: String = items[i][1]
		var color := C_TEXT
		if key == "end_day":
			color = C_RUST
		var b := _button(rail, items[i][0], Vector2(20, 46 + i * 54), Vector2(170, 48), color, _on_rail.bind(key))
		rail_buttons[key] = b
	_button(rail, "电台", Vector2(20, 556), Vector2(170, 44), C_AMBER, _toggle_radio)
	status_label = _label(rail, "营业中", Vector2(20, 612), Vector2(170, 40), 20, C_GREEN)

func _build_right_rail() -> void:
	var rail := _panel(self, Vector2(2130, 80), Vector2(210, 670), C_PANEL, C_LINE)
	_label(rail, "交涉", Vector2(20, 14), Vector2(170, 32), 24, C_AMBER)
	var actions := [
		["鉴定", "inspect", C_CYAN], ["议价", "bargain", C_AMBER], ["威胁", "threaten", C_RUST],
		["成交", "deal", C_GREEN], ["送客", "dismiss", C_MUTED],
		["下一件", "next_item", C_MUTED],
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
	customer_info_label = _label(p, "", Vector2(14, 82), Vector2(312, 70), 20, C_MUTED)
	queue_label = _label(p, "", Vector2(14, 150), Vector2(312, 24), 16, C_CYAN)

func _build_dialogue() -> void:
	var p := _panel(game_view, Vector2(1280, 170), Vector2(560, 220), C_PANEL, C_CYAN, 2)
	var bubble_style := _style(C_PANEL, C_CYAN, 2)
	bubble_style.corner_radius_top_left = 18
	bubble_style.corner_radius_top_right = 18
	bubble_style.corner_radius_bottom_left = 18
	bubble_style.corner_radius_bottom_right = 18
	p.add_theme_stylebox_override("panel", bubble_style)
	var dtail := ColorRect.new()
	dtail.position = Vector2(-10, 60)
	dtail.size = Vector2(22, 22)
	dtail.rotation = 0.78
	dtail.color = C_PANEL
	dtail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(dtail)
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
	var page_names := ["前", "背", "隐"]
	for i in range(3):
		var pb := _button(p, page_names[i], Vector2(1380 + i * 48, 10), Vector2(42, 44), C_MUTED, _on_page_pressed.bind(i))
		page_buttons.append(pb)
	capacity_label = _label(p, "", Vector2(1470, 18), Vector2(100, 28), 22, C_MUTED)
	_button(p, "海报", Vector2(1575, 8), Vector2(95, 48), C_RUST, _toggle_poster_ui)
	_button(p, "垃圾桶", Vector2(1675, 8), Vector2(105, 48), C_MUTED, _open_trash)
	_button(p, "展示柜", Vector2(1785, 8), Vector2(125, 48), C_CYAN, _open_showcase)
	_button(p, "整理", Vector2(1915, 8), Vector2(150, 48), C_CYAN, _auto_sort)
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
	detail_inspect_btn = _button(detail_panel, "验货", Vector2(630, 190), Vector2(110, 48), C_CYAN, _on_inspect_owned)
	detail_open_btn = _button(detail_panel, "打开", Vector2(750, 190), Vector2(100, 48), C_GREEN, _on_open_selected_container)
	detail_liquid_btn = _button(detail_panel, "倒液", Vector2(750, 190), Vector2(100, 48), C_CYAN, _on_liquid_transfer)
	detail_split_btn = _button(detail_panel, "分瓶", Vector2(630, 190), Vector2(100, 48), C_CYAN, _on_split_pressed)
	detail_equip_btn = _button(detail_panel, "装备", Vector2(630, 190), Vector2(110, 48), C_GREEN, _on_equip_armor)
	detail_equip_btn.visible = false

func _build_modal() -> void:
	modal_layer = Control.new()
	modal_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_layer.visible = false
	modal_layer.z_index = 200
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
	summary_tabs = HBoxContainer.new()
	summary_tabs.position = Vector2(30, 440)
	summary_tabs.size = Vector2(1140, 48)
	summary_tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	summary_tabs.add_theme_constant_override("separation", 8)
	summary_tabs.visible = false
	modal_panel.add_child(summary_tabs)
	for pair in [["总览", "overview"], ["收入", "credits"], ["支出", "expenses"], ["店铺", "station"], ["夜间", "nights"], ["治安", "security"]]:
		var tb := _button(summary_tabs, String(pair[0]), Vector2.ZERO, Vector2(170, 44), C_TEXT, _summary_tab_pick.bind(String(pair[1])))
		tb.custom_minimum_size = Vector2(170, 44)
		tb.add_theme_font_size_override("font_size", 20)
		tb.set_meta("tab", String(pair[1]))
	receipt_stamp = _label(modal_panel, "治安部
查抄专用章", Vector2(880, 540), Vector2(260, 120), 30, Color("#a23a2e"), HORIZONTAL_ALIGNMENT_CENTER)
	receipt_stamp.rotation = -0.18
	receipt_stamp.visible = false
	modal_close_btn = _button(modal_panel, "关闭", Vector2(1080, 16), Vector2(90, 44), C_MUTED, _close_modal)

func _build_inspection_layer() -> void:
	inspection_layer = Control.new()
	inspection_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inspection_layer.visible = false
	inspection_layer.z_index = 150
	inspection_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(inspection_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inspection_layer.add_child(dim)
	var panel := _panel(inspection_layer, Vector2(260, 30), Vector2(1820, 1020), C_PANEL, C_CYAN, 3)
	inspection_title = _label(panel, "验货", Vector2(30, 16), Vector2(900, 48), 34, C_AMBER)
	_button(panel, "关闭", Vector2(1660, 14), Vector2(130, 48), C_MUTED, _close_inspection)
	var left := _panel(panel, Vector2(30, 80), Vector2(1100, 880), C_PANEL2, C_LINE, 2)
	inspection_pixel_icon = _texture_rect(left, Vector2(20, 20), Vector2(260, 260), "")
	inspection_pixel_meta = _label(left, "", Vector2(20, 286), Vector2(260, 80), 18, C_AMBER)
	inspection_pixel_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var lscroll := ScrollContainer.new()
	lscroll.position = Vector2(300, 20)
	lscroll.size = Vector2(780, 840)
	lscroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lscroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	lscroll.add_theme_stylebox_override("panel", _style(C_PANEL, C_LINE, 1))
	left.add_child(lscroll)
	inspection_info = _label(lscroll, "", Vector2(10, 10), Vector2(750, 800), 21, C_TEXT)
	inspection_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspection_info.custom_minimum_size = Vector2(750, 800)
	var right := _panel(panel, Vector2(1150, 80), Vector2(640, 880), C_PANEL2, C_LINE, 2)
	_label(right, "工具与操作", Vector2(20, 14), Vector2(300, 32), 24, C_AMBER)
	var rscroll := ScrollContainer.new()
	rscroll.position = Vector2(20, 54)
	rscroll.size = Vector2(600, 620)
	rscroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rscroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	rscroll.add_theme_stylebox_override("panel", _style(C_PANEL, C_LINE, 1))
	right.add_child(rscroll)
	inspection_actions = VBoxContainer.new()
	inspection_actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspection_actions.add_theme_constant_override("separation", 8)
	rscroll.add_child(inspection_actions)
	inspection_status = _label(right, "", Vector2(20, 686), Vector2(600, 70), 16, C_MUTED)
	inspection_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspection_appraisal_input = LineEdit.new()
	inspection_appraisal_input.position = Vector2(20, 770)
	inspection_appraisal_input.size = Vector2(380, 52)
	inspection_appraisal_input.placeholder_text = "输入估价"
	inspection_appraisal_input.add_theme_font_size_override("font_size", 22)
	right.add_child(inspection_appraisal_input)
	var submit := _button(right, "提交估价", Vector2(410, 770), Vector2(210, 52), C_AMBER, _submit_appraisal)
	submit.name = "AppraisalSubmit"

func _build_container_layer() -> void:
	container_layer = Control.new()
	container_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container_layer.visible = false
	container_layer.z_index = 140
	container_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(container_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container_layer.add_child(dim)
	var panel := _panel(container_layer, Vector2(420, 30), Vector2(1000, 700), C_PANEL, C_CYAN, 3)
	container_panel = panel
	var dragbar := Control.new()
	dragbar.position = Vector2.ZERO
	dragbar.size = Vector2(1000, 62)
	dragbar.mouse_filter = Control.MOUSE_FILTER_STOP
	dragbar.gui_input.connect(_on_container_window_input)
	panel.add_child(dragbar)
	panel.move_child(dragbar, 0)
	container_title = _label(panel, "容器", Vector2(24, 12), Vector2(700, 46), 32, C_AMBER)
	container_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_button(panel, "关闭", Vector2(850, 10), Vector2(130, 48), C_MUTED, _close_container)
	var left := _panel(panel, Vector2(20, 70), Vector2(600, 610), C_PANEL2, C_LINE, 2)
	container_info = _label(left, "", Vector2(14, 10), Vector2(570, 54), 18, C_TEXT)
	container_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container_grid = Control.new()
	container_grid.position = Vector2(14, 70)
	container_grid.size = Vector2(570, 520)
	left.add_child(container_grid)
	var right := _panel(panel, Vector2(630, 70), Vector2(350, 610), C_PANEL2, C_LINE, 2)
	_label(right, "容器操作", Vector2(16, 10), Vector2(300, 32), 22, C_AMBER)
	container_actions = VBoxContainer.new()
	container_actions.position = Vector2(16, 50)
	container_actions.size = Vector2(318, 540)
	container_actions.add_theme_constant_override("separation", 8)
	right.add_child(container_actions)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _build_showcase_layer() -> void:
	showcase_layer = Control.new()
	showcase_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	showcase_layer.visible = false
	showcase_layer.z_index = 140
	showcase_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(showcase_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	showcase_layer.add_child(dim)
	var panel := _panel(showcase_layer, Vector2(500, 90), Vector2(1360, 880), C_PANEL, C_CYAN, 3)
	_label(panel, "展示柜 · SHOWCASE", Vector2(30, 16), Vector2(700, 46), 34, C_AMBER)
	_button(panel, "关闭", Vector2(1200, 14), Vector2(130, 48), C_MUTED, _close_showcase)
	var left := _panel(panel, Vector2(24, 80), Vector2(930, 770), C_PANEL2, C_LINE, 2)
	showcase_info = _label(left, "", Vector2(16, 12), Vector2(900, 54), 20, C_TEXT)
	showcase_grid = Control.new()
	showcase_grid.position = Vector2(16, 72)
	showcase_grid.size = Vector2(900, 680)
	left.add_child(showcase_grid)
	var right := _panel(panel, Vector2(970, 80), Vector2(360, 770), C_PANEL2, C_LINE, 2)
	_label(right, "展示柜操作", Vector2(20, 12), Vector2(300, 32), 24, C_AMBER)
	showcase_actions = VBoxContainer.new()
	showcase_actions.position = Vector2(20, 56)
	showcase_actions.size = Vector2(320, 660)
	showcase_actions.add_theme_constant_override("separation", 10)
	right.add_child(showcase_actions)

func _build_trash_layer() -> void:
	trash_layer = Control.new()
	trash_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	trash_layer.visible = false
	trash_layer.z_index = 145
	trash_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(trash_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	trash_layer.add_child(dim)
	var panel := _panel(trash_layer, Vector2(680, 230), Vector2(980, 620), C_PANEL, C_MUTED, 3)
	_label(panel, "垃圾桶 · TRASH", Vector2(30, 16), Vector2(700, 46), 34, C_AMBER)
	_button(panel, "关闭", Vector2(820, 14), Vector2(130, 48), C_MUTED, _close_trash)
	var left := _panel(panel, Vector2(24, 80), Vector2(620, 520), C_PANEL2, C_LINE, 2)
	trash_info = _label(left, "", Vector2(16, 12), Vector2(590, 44), 20, C_TEXT)
	trash_grid = Control.new()
	trash_grid.position = Vector2(16, 64)
	trash_grid.size = Vector2(580, 440)
	left.add_child(trash_grid)
	var right := _panel(panel, Vector2(660, 80), Vector2(296, 520), C_PANEL2, C_LINE, 2)
	_label(right, "垃圾桶操作", Vector2(20, 12), Vector2(260, 32), 24, C_AMBER)
	trash_actions = VBoxContainer.new()
	trash_actions.position = Vector2(20, 56)
	trash_actions.size = Vector2(256, 440)
	trash_actions.add_theme_constant_override("separation", 10)
	right.add_child(trash_actions)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _load_window_positions() -> void:
	container_positions = {}
	if not FileAccess.file_exists(UI_WINDOWS_PATH):
		return
	var f := FileAccess.open(UI_WINDOWS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		container_positions = parsed

func _save_window_positions() -> void:
	var f := FileAccess.open(UI_WINDOWS_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(container_positions))

func _container_window_key() -> String:
	var it := GameState.find_item(open_container_uid)
	if it.is_empty():
		return ""
	if it.has("_window_key"):
		return String(it.get("_window_key", ""))
	return String(it.get("def_id", ""))

func _apply_container_window_pos() -> void:
	if container_panel == null:
		return
	var key := _container_window_key()
	var pos := Vector2(420, 56)
	if container_positions.has(key):
		var saved = container_positions[key]
		if saved is Dictionary:
			pos = Vector2(float(saved.get("x", 420)), float(saved.get("y", 56)))
	pos.x = clampf(pos.x, 0, 2340 - container_panel.size.x)
	pos.y = clampf(pos.y, 48, 1080 - container_panel.size.y)
	container_panel.position = pos

func _on_container_window_input(event: InputEvent) -> void:
	if container_panel == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			window_dragging = true
			window_drag_offset = event.global_position - container_panel.global_position
		else:
			window_dragging = false
			var key := _container_window_key()
			if key != "":
				container_positions[key] = {"x": container_panel.position.x, "y": container_panel.position.y}
				_save_window_positions()
	elif event is InputEventMouseMotion and window_dragging:
		var p: Vector2 = event.global_position - window_drag_offset
		p.x = clampf(p.x, 0, 2340 - container_panel.size.x)
		p.y = clampf(p.y, 48, 1080 - container_panel.size.y)
		container_panel.position = p

func _open_container(uid: int) -> void:
	var it := GameState.find_item(uid)
	if it.is_empty() or not GameState.is_container_item(it):
		_toast("这件物品不是可打开的容器。")
		return
	if open_container_uid >= 0 and open_container_uid != uid:
		container_stack.append(open_container_uid)
	open_container_uid = uid
	container_selected_uid = -1
	container_layer.visible = true
	_play_sfx("open_case")
	move_child(container_layer, get_child_count() - 1)
	_apply_container_window_pos()
	_rebuild_container_grid()

func _close_container() -> void:
	container_layer.visible = false
	open_container_uid = -1
	container_stack.clear()
	container_selected_uid = -1

func _container_back() -> void:
	if container_stack.is_empty():
		return
	open_container_uid = int(container_stack.pop_back())
	container_selected_uid = -1
	_rebuild_container_grid()

func _container_action(label: String, cb: Callable, color: Color = C_CYAN) -> void:
	var b := _button(container_actions, label, Vector2.ZERO, Vector2(310, 52), color, cb)
	b.custom_minimum_size = Vector2(310, 52)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 18)

func _rebuild_container_grid() -> void:
	var it := GameState.find_item(open_container_uid)
	if it.is_empty():
		_close_container()
		return
	var spec := GameState.container_spec(it)
	container_title.text = "容器 · %s" % GameState.item_display_name(it)
	var kind := String(spec.get("kind", "grid"))
	var children: Array = it.get("children", [])
	var cap_text := ""
	if kind == "slots":
		cap_text = "槽位 %d/%d" % [children.size(), spec.get("slots", []).size()]
	elif kind == "liquid":
		cap_text = "液体 %d/%d ml" % [int(it.get("liquid_ml", 0)), int(spec.get("capacity_ml", 0))]
	else:
		cap_text = "格数 %d / %d" % [children.size(), GameState.container_effective_width(spec) * int(spec.get("height", 0))]
	var lock_text := "  ·  已锁定" if bool(it.get("container_locked", false)) else ""
	var zone_text := ""
	var zones := GameState.container_zones(spec)
	if not zones.is_empty():
		var parts: Array = []
		for z in zones:
			var zc := 0
			for ch in children:
				if GameState.container_zone_at(spec, int(ch.get("x", 0))).get("id", "") == z.get("id"):
					zc += 1
			parts.append("%s %d/%d" % [String(z.get("label", z.get("id", ""))), zc, int(z.get("width", 1)) * int(spec.get("height", 1))])
		zone_text = "  ·  " + " · ".join(parts)
	container_info.text = "%s  ·  %s  ·  内容估值 %d₵%s%s" % [GameState.item_display_name(it), cap_text, GameState.effective_value(it), zone_text, lock_text]
	_clear_children(container_grid)
	_clear_children(container_actions)
	if kind == "liquid":
		var fslots := GameState.container_filter_slots(spec)
		for i in range(fslots):
			var fch := GameState.container_filter_at(it, i)
			var flabel := "滤芯 %d：空" % (i + 1)
			var fuid := -1
			if not fch.is_empty():
				fuid = int(fch.get("uid", -1))
				flabel = "滤芯 %d：%s（%d%%）" % [i + 1, GameState.item_display_name(fch), int(fch.get("condition", 100))]
			var fb := _button(container_grid, flabel, Vector2(0, i * 90), Vector2(340, 70), C_PANEL2 if fuid < 0 else C_PANEL, _container_select_child.bind(fuid))
			fb.add_theme_font_size_override("font_size", 18)
		_container_action("装入滤芯", _container_store_select)
	elif kind == "slots":
		var slots: Array = spec.get("slots", [])
		for i in range(slots.size()):
			var slot: Dictionary = slots[i]
			var sid := String(slot.get("id", ""))
			var label := "%s：空" % sid
			var child_uid := -1
			for ch in children:
				if String(ch.get("slot_id", "")) == sid:
					child_uid = int(ch.get("uid", -1))
					label = "%s：%s" % [sid, GameState.item_display_name(ch)]
					break
			var b := _button(container_grid, label, Vector2((i % 3) * 190, int(i / 3) * 100), Vector2(180, 74), C_PANEL2 if child_uid < 0 else C_PANEL, _container_select_child.bind(child_uid))
			b.add_theme_font_size_override("font_size", 18)
		_container_action("存入模块", _container_store_select)
	else:
		for y in range(int(spec.get("height", 1))):
			for x in range(int(spec.get("width", 1))):
				var cell_zone := GameState.container_zone_at(spec, x)
				if not zones.is_empty() and cell_zone.is_empty():
					continue
				if cell_zone.is_empty():
					_slot_cell(container_grid, Vector2(x * CONTAINER_STEP, y * CONTAINER_STEP), Vector2(CONTAINER_CELL, CONTAINER_CELL))
				else:
					var edge := Color("#2f5b6e") if String(cell_zone.get("id", "")) == "chill" else Color("#4a5f8f")
					var fill := Color("#101820") if String(cell_zone.get("id", "")) == "chill" else Color("#131826")
					var cell := _panel(container_grid, Vector2(x * CONTAINER_STEP, y * CONTAINER_STEP), Vector2(CONTAINER_CELL, CONTAINER_CELL), fill, edge, 1)
					cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not zones.is_empty():
			for z in zones:
				var zl := Label.new()
				zl.text = String(z.get("label", z.get("id", "")))
				zl.position = Vector2(int(z.get("x", 0)) * CONTAINER_STEP, int(spec.get("height", 1)) * CONTAINER_STEP + 4)
				zl.size = Vector2(int(z.get("width", 1)) * CONTAINER_STEP, 24)
				zl.add_theme_font_size_override("font_size", 18)
				zl.add_theme_color_override("font_color", C_MUTED)
				zl.mouse_filter = Control.MOUSE_FILTER_IGNORE
				container_grid.add_child(zl)
		var grid_fslots := GameState.container_filter_slots(spec)
		for i in range(grid_fslots):
			var gfc := GameState.container_filter_at(it, i)
			var gflabel := "滤芯 %d：空" % (i + 1)
			var gfuid := -1
			if not gfc.is_empty():
				gfuid = int(gfc.get("uid", -1))
				gflabel = "滤芯 %d：%s（%d%%）" % [i + 1, GameState.item_display_name(gfc), int(gfc.get("condition", 100))]
			var gfb := _button(container_grid, gflabel, Vector2(i % 2 * 180, int(spec.get("height", 1)) * CONTAINER_STEP + 36 + int(i / 2) * 74), Vector2(170, 62), C_PANEL2 if gfuid < 0 else C_PANEL, _container_select_child.bind(gfuid))
			gfb.add_theme_font_size_override("font_size", 16)
		for ch in children:
			if String(ch.get("slot_id", "")) != "":
				continue
			var def := GameState.get_item_def(String(ch.get("def_id", "")))
			var shape := GameState.item_shape(ch)
			var w := int(shape[0]) * CONTAINER_CELL + (int(shape[0]) - 1) * 4
			var h := int(shape[1]) * CONTAINER_CELL + (int(shape[1]) - 1) * 4
			var icon := TextureButton.new()
			icon.position = Vector2(int(ch.get("x", 0)) * CONTAINER_STEP, int(ch.get("y", 0)) * CONTAINER_STEP)
			icon.size = Vector2(w, h)
			var gip := GameState.item_icon_path(def)
			icon.texture_normal = load(gip) if gip != "" else null
			icon.ignore_texture_size = true
			icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon.focus_mode = Control.FOCUS_NONE
			var cuid := int(ch.get("uid", -1))
			icon.pressed.connect(_container_select_child.bind(cuid))
			icon.gui_input.connect(_on_drag_gui_input.bind(cuid, icon, "container"))
			if cuid == container_selected_uid:
				icon.self_modulate = Color(1.3, 1.2, 0.85)
			container_grid.add_child(icon)
			_add_count_badge(container_grid, icon.position, icon.size, int(ch.get("unit_count", 1)))
		_container_action("存入物品", _container_store_select)
		if GameState.container_filter_slots(spec) > 0:
			_container_action("装入滤芯", _container_store_select)
	var selected := GameState.find_item(container_selected_uid) if container_selected_uid >= 0 else {}
	if not selected.is_empty():
		_container_action("取出到背包", _container_take_selected, C_AMBER)
		if GameState.is_stackable_item(selected) and int(selected.get("unit_count", 1)) > 1:
			_container_action("分堆", _container_split_selected, C_CYAN)
		if GameState.is_container_item(selected):
			_container_action("打开选中容器", _container_open_selected, C_CYAN)
	if not children.is_empty():
		_container_action("全部取出", _container_take_all, C_GREEN)
	if bool(it.get("container_locked", false)):
		_container_action("使用门禁卡", _container_unlock_select, C_RUST)
		_container_action("撬锁", _container_breach, C_RUST)
	if not container_stack.is_empty():
		_container_action("返回上层", _container_back, C_MUTED)
	_refresh_container_actions()

func _container_breach() -> void:
	if open_container_uid < 0:
		return
	var res := GameState.breach_container(open_container_uid)
	_play_sfx("machine" if bool(res.get("ok", false)) else "fail")
	_rebuild_container_grid()
	_refresh()

func _container_select_child(uid: int) -> void:
	container_selected_uid = uid
	_rebuild_container_grid()

func _refresh_container_actions() -> void:
	pass

func _container_split_selected() -> void:
	if container_selected_uid < 0:
		return
	var res := GameState.split_stack(container_selected_uid)
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	_toast(String(res.get("text", "")))
	_rebuild_container_grid()

func _container_take_all() -> void:
	var parent := GameState.find_item(open_container_uid)
	if parent.is_empty():
		return
	if bool(parent.get("container_locked", false)):
		_toast("容器已锁定，需要对应钥匙。")
		return
	var moved := 0
	var blocked := false
	for ch in parent.get("children", []).duplicate():
		var uid := int(ch.get("uid", -1))
		var item := GameState.container_remove_child(parent, uid)
		if item.is_empty():
			continue
		item["location"] = "backpack"
		if GameState.add_item(item):
			moved += 1
		else:
			GameState.container_auto_add(parent, item)
			blocked = true
			break
	container_selected_uid = -1
	_toast("取出 %d 件%s。" % [moved, "，背包空间不足" if blocked else ""])
	_rebuild_container_grid()
	_refresh()

func _container_take_selected() -> void:
	var parent := GameState.find_item(open_container_uid)
	if parent.is_empty() or container_selected_uid < 0:
		return
	if bool(parent.get("container_locked", false)):
		_toast("容器已锁定，需要对应钥匙。")
		return
	var child := GameState.container_remove_child(parent, container_selected_uid)
	if child.is_empty():
		_toast("没有选中容器内的物品。")
		return
	child["location"] = "backpack"
	if not GameState.add_item(child):
		GameState.container_auto_add(parent, child)
		_toast("背包空间不足，物品留在容器里。")
	else:
		container_selected_uid = -1
	_rebuild_container_grid()
	_refresh()

func _container_open_selected() -> void:
	var child := GameState.find_item(container_selected_uid)
	if child.is_empty() or not GameState.is_container_item(child):
		_toast("选中的物品不是容器。")
		return
	_open_container(container_selected_uid)

func _container_unlock_select() -> void:
	var items: Array = []
	for it in GameState.inventory:
		var did := String(it.get("def_id", ""))
		if did.ends_with("_keycard"):
			items.append({"id": str(it.get("uid", 0)), "label": GameState.item_display_name(it)})
	if items.is_empty():
		_toast("背包里没有门禁卡。")
		return
	_open_select("使用门禁卡", items, _container_unlock_choice)

func _container_unlock_choice(uid_text: String) -> void:
	var key := GameState.find_item(int(uid_text))
	var parent := GameState.find_item(open_container_uid)
	if key.is_empty() or parent.is_empty():
		return
	var res := GameState.unlock_container(parent, key)
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	_rebuild_container_grid()
	_refresh()

func _container_store_select() -> void:
	var parent := GameState.find_item(open_container_uid)
	if parent.is_empty():
		return
	var items: Array = []
	for it in GameState.inventory:
		if int(it.get("uid", -1)) == int(parent.get("uid", -2)):
			continue
		if GameState.container_can_accept(parent, it):
			items.append({"id": str(it.get("uid", 0)), "label": "%s · 品相 %d%%" % [GameState.item_display_name(it), int(it.get("condition", 100))]})
	if items.is_empty():
		_toast("背包里没有能放入这个容器的物品。")
		return
	_open_select("存入 · %s" % GameState.item_display_name(parent), items, _container_store_choice)

func _container_store_choice(uid_text: String) -> void:
	if GameState.move_item_to_container(int(uid_text), open_container_uid):
		container_selected_uid = int(uid_text)
	else:
		_toast("放不下。")
	_rebuild_container_grid()
	_refresh()

func _open_showcase() -> void:
	if GameState.show_display_tip():
		_toast("提示：展示柜里的物品更容易被顾客看到，也会影响店铺吸引力。")
	showcase_layer.visible = true
	move_child(showcase_layer, get_child_count() - 1)
	showcase_selected_uid = -1
	_rebuild_showcase()

func _close_showcase() -> void:
	showcase_layer.visible = false
	showcase_selected_uid = -1

func _rebuild_showcase() -> void:
	_clear_children(showcase_grid)
	_clear_children(showcase_actions)
	var total := 0
	for it in GameState.display:
		total += GameState.effective_value(it)
	showcase_info.text = "展示品 %d 件 · 网格 7×5 · 总估值 %d₵" % [GameState.display.size(), total]
	var show_size := GameState.showcase_size()
	for y in range(int(show_size[1])):
		for x in range(int(show_size[0])):
			_slot_cell(showcase_grid, Vector2(x * 56, y * 56), Vector2(52, 52))
	for it in GameState.display:
		var def := GameState.get_item_def(String(it.get("def_id", "")))
		var shape := GameState.item_shape(it)
		var w := int(shape[0]) * 52 + (int(shape[0]) - 1) * 4
		var h := int(shape[1]) * 52 + (int(shape[1]) - 1) * 4
		var icon := TextureButton.new()
		icon.position = Vector2(int(it.get("x", 0)) * 56, int(it.get("y", 0)) * 56)
		icon.size = Vector2(w, h)
		var gip := GameState.item_icon_path(def)
		icon.texture_normal = load(gip) if gip != "" else null
		icon.ignore_texture_size = true
		icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.focus_mode = Control.FOCUS_NONE
		var uid := int(it.get("uid", -1))
		icon.pressed.connect(_showcase_select.bind(uid))
		icon.gui_input.connect(_on_drag_gui_input.bind(uid, icon, "showcase"))
		if uid == showcase_selected_uid:
			icon.self_modulate = Color(1.3, 1.2, 0.85)
		showcase_grid.add_child(icon)
		_add_count_badge(showcase_grid, icon.position, icon.size, int(it.get("unit_count", 1)))
	_showcase_action("整理展示柜", _showcase_arrange, C_CYAN)
	if showcase_selected_uid >= 0:
		_showcase_action("下架到背包", _showcase_take, C_AMBER)
		if GameState.current_customer.get("intent") == "buy":
			_showcase_action("放到柜台", _showcase_counter, C_GREEN)

func _showcase_action(label: String, cb: Callable, color: Color = C_CYAN) -> void:
	var b := _button(showcase_actions, label, Vector2.ZERO, Vector2(310, 52), color, cb)
	b.custom_minimum_size = Vector2(310, 52)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 18)

func _showcase_select(uid: int) -> void:
	showcase_selected_uid = uid
	_rebuild_showcase()

func _showcase_take() -> void:
	if showcase_selected_uid < 0:
		return
	GameState.take_from_display(showcase_selected_uid)
	showcase_selected_uid = -1
	_rebuild_showcase()
	_refresh()

func _showcase_counter() -> void:
	if showcase_selected_uid < 0:
		return
	if GameState.put_display_on_counter(showcase_selected_uid):
		_close_showcase()
		_refresh()

func _showcase_arrange() -> void:
	var list: Array = GameState.display.duplicate()
	GameState.display = []
	for it in list:
		GameState.display_auto_place(it)
		GameState.display.append(it)
	_rebuild_showcase()
	_refresh()

func _open_trash() -> void:
	trash_layer.visible = true
	move_child(trash_layer, get_child_count() - 1)
	trash_selected_uid = -1
	_rebuild_trash()

func _close_trash() -> void:
	trash_layer.visible = false
	trash_selected_uid = -1

func _rebuild_trash() -> void:
	_clear_children(trash_grid)
	_clear_children(trash_actions)
	trash_info.text = "垃圾 %d/%d · 检查官会翻找垃圾桶，懒惰的检查官会跳过。" % [GameState.trash_items.size(), GameState.sec_trash_capacity()]
	for i in range(GameState.sec_trash_capacity()):
		var col := i % 4
		var row := int(floor(float(i) / 4.0))
		var cell := _panel(trash_grid, Vector2(col * 72, row * 72), Vector2(68, 68), Color("#11151d"), Color("#2a3140"), 1)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for it in GameState.trash_items:
		var def := GameState.get_item_def(String(it.get("def_id", "")))
		var shape := GameState.item_shape(it)
		var w := int(shape[0]) * 64 + (int(shape[0]) - 1) * 4
		var h := int(shape[1]) * 64 + (int(shape[1]) - 1) * 4
		var icon := TextureButton.new()
		icon.position = Vector2(int(it.get("x", 0)) * 72, int(it.get("y", 0)) * 72)
		icon.size = Vector2(w, h)
		var gip := GameState.item_icon_path(def)
		icon.texture_normal = load(gip) if gip != "" else null
		icon.ignore_texture_size = true
		icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.focus_mode = Control.FOCUS_NONE
		var uid := int(it.get("uid", -1))
		icon.pressed.connect(_trash_select.bind(uid))
		icon.gui_input.connect(_on_drag_gui_input.bind(uid, icon, "trash"))
		if uid == trash_selected_uid:
			icon.self_modulate = Color(1.3, 1.2, 0.85)
		trash_grid.add_child(icon)
		_add_count_badge(trash_grid, icon.position, icon.size, int(it.get("unit_count", 1)))
	if trash_selected_uid >= 0:
		var b := _button(trash_actions, "取回背包", Vector2.ZERO, Vector2(256, 52), C_CYAN, _trash_take)
		b.custom_minimum_size = Vector2(256, 52)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 18)

func _trash_select(uid: int) -> void:
	trash_selected_uid = uid
	_rebuild_trash()

func _trash_take() -> void:
	if trash_selected_uid < 0:
		return
	if GameState.take_from_trash(trash_selected_uid):
		trash_selected_uid = -1
		_rebuild_trash()
		_refresh()

func _build_barter_layer() -> void:
	barter_layer = Control.new()
	barter_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	barter_layer.visible = false
	barter_layer.z_index = 145
	barter_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(barter_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	barter_layer.add_child(dim)
	var panel := _panel(barter_layer, Vector2(470, 120), Vector2(1400, 780), C_PANEL, C_AMBER, 3)
	barter_title = _label(panel, "以物易物", Vector2(28, 14), Vector2(1000, 48), 34, C_AMBER)
	_button(panel, "离开", Vector2(1230, 12), Vector2(140, 48), C_MUTED, _close_barter)
	barter_line = _label(panel, "", Vector2(28, 66), Vector2(1340, 64), 24, C_TEXT)
	barter_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	barter_want = _label(panel, "", Vector2(28, 136), Vector2(1340, 40), 22, C_CYAN)
	_label(panel, "对方拿出", Vector2(28, 186), Vector2(300, 30), 22, C_AMBER)
	barter_offer_box = Control.new()
	barter_offer_box.position = Vector2(28, 222)
	barter_offer_box.size = Vector2(1340, 260)
	panel.add_child(barter_offer_box)
	barter_prev_btn = _button(panel, "◀ 上一组", Vector2(28, 500), Vector2(200, 56), C_MUTED, _barter_cycle.bind(-1))
	barter_page = _label(panel, "", Vector2(250, 508), Vector2(300, 40), 24, C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	barter_next_btn = _button(panel, "下一组 ▶", Vector2(570, 500), Vector2(200, 56), C_MUTED, _barter_cycle.bind(1))
	barter_accept_btn = _button(panel, "接受交换", Vector2(920, 494), Vector2(280, 68), C_GREEN, _barter_accept)
	barter_status = _label(panel, "", Vector2(28, 590), Vector2(1340, 160), 22, C_MUTED)
	barter_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _open_barter() -> void:
	if barter_layer == null:
		return
	barter_layer.visible = true
	move_child(barter_layer, get_child_count() - 1)
	_rebuild_barter()

func _close_barter() -> void:
	if barter_layer:
		barter_layer.visible = false
	GameState.next_customer()

func _barter_cycle(offset: int) -> void:
	GameState.cycle_barter_offer(offset)
	_rebuild_barter()

func _rebuild_barter() -> void:
	var c := GameState.current_customer
	if c.is_empty() or c.get("intent") != "barter":
		if barter_layer:
			barter_layer.visible = false
		return
	barter_title.text = "以物易物 · %s" % String(c.get("barter_name", "顾客"))
	var done := bool(c.get("done", false))
	var line_key := String(c.get("barter_done_key", "")) if done else ""
	var line_text := String(c.get("line", ""))
	if done and line_key != "":
		var extra := String(GameState.dialogue_lines.get(line_key, ""))
		if extra != "":
			line_text = line_text + "\n" + extra
	barter_line.text = line_text
	var cond_parts: Array = []
	var satisfied := true
	for cond in c.get("barter_conditions", []):
		var need := int(cond.get("count", 1))
		var have := GameState.barter_condition_count(cond)
		if have < need:
			satisfied = false
		cond_parts.append("%s ×%d（持有 %d）" % [GameState.barter_condition_label(cond), need, have])
	barter_want.text = "对方想要：" + ("、".join(cond_parts) if not cond_parts.is_empty() else "任意物品")
	_clear_children(barter_offer_box)
	var items: Array = GameState.barter_offer_items(c)
	for i in range(items.size()):
		var entry: Dictionary = items[i]
		var did := String(entry.get("id", ""))
		var def := GameState.get_item_def(did)
		var pos := Vector2((i % 5) * 266, int(i / 5) * 128)
		var card := _panel(barter_offer_box, pos, Vector2(250, 116), C_PANEL2, C_LINE, 1)
		var ip := GameState.item_icon_path(def)
		var icon := _texture_rect(card, Vector2(8, 8), Vector2(96, 96), ip)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label(card, GameState.item_display_name({"def_id": did}), Vector2(112, 14), Vector2(130, 50), 20, C_TEXT)
		_label(card, "×%d" % int(entry.get("count", 1)), Vector2(112, 66), Vector2(130, 30), 20, C_AMBER)
	barter_page.text = "报价 %d/%d" % [int(c.get("barter_index", 0)) + 1, maxi(1, GameState.barter_offer_count(c))]
	var multi := GameState.barter_offer_count(c) > 1 and not done
	barter_prev_btn.visible = multi
	barter_next_btn.visible = multi
	barter_accept_btn.visible = not done
	barter_accept_btn.disabled = done or not satisfied
	barter_status.text = "交换完成后对方会带走所需物品。" if not done else "交易完成，点「离开」送走顾客。"
	if not done and not satisfied:
		barter_status.text += "\n背包里缺少对方想要的东西。"

func _barter_accept() -> void:
	var res := GameState.accept_barter()
	_play_sfx("cash" if bool(res.get("ok", false)) else "fail")
	if not bool(res.get("ok", false)):
		barter_status.text = String(res.get("text", ""))
		return
	_refresh()
	_rebuild_barter()

func _build_wholesale_layer() -> void:
	wholesale_layer = Control.new()
	wholesale_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wholesale_layer.visible = false
	wholesale_layer.z_index = 146
	wholesale_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(wholesale_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wholesale_layer.add_child(dim)
	var panel := _panel(wholesale_layer, Vector2(470, 120), Vector2(1400, 780), C_PANEL, C_CYAN, 3)
	wholesale_title = _label(panel, "批发", Vector2(28, 14), Vector2(1000, 48), 34, C_AMBER)
	_button(panel, "离开", Vector2(1230, 12), Vector2(140, 48), C_MUTED, _close_wholesale)
	wholesale_line = _label(panel, "", Vector2(28, 66), Vector2(1340, 70), 24, C_TEXT)
	wholesale_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label(panel, "整车货物", Vector2(28, 150), Vector2(300, 30), 22, C_CYAN)
	wholesale_box = Control.new()
	wholesale_box.position = Vector2(28, 186)
	wholesale_box.size = Vector2(1340, 340)
	panel.add_child(wholesale_box)
	wholesale_total_label = _label(panel, "", Vector2(28, 540), Vector2(900, 44), 28, C_AMBER)
	wholesale_buy_btn = _button(panel, "买下全部", Vector2(920, 530), Vector2(280, 68), C_GREEN, _wholesale_buy)
	wholesale_status = _label(panel, "", Vector2(28, 620), Vector2(1340, 120), 22, C_MUTED)
	wholesale_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _open_wholesale() -> void:
	if wholesale_layer == null:
		return
	wholesale_layer.visible = true
	move_child(wholesale_layer, get_child_count() - 1)
	_rebuild_wholesale()

func _close_wholesale() -> void:
	if wholesale_layer:
		wholesale_layer.visible = false
	GameState.next_customer()

func _rebuild_wholesale() -> void:
	var c := GameState.current_customer
	if c.is_empty() or c.get("intent") != "wholesale":
		if wholesale_layer:
			wholesale_layer.visible = false
		return
	wholesale_title.text = "批发 · %s" % String(c.get("wholesale_name", "快递员"))
	var done := bool(c.get("done", false))
	var line := String(c.get("line", ""))
	if done:
		var dk := String(GameState.dialogue_lines.get(String(c.get("wholesale_done_key", "")), ""))
		if dk != "":
			line += "\n" + dk
	wholesale_line.text = line
	_clear_children(wholesale_box)
	var stock: Array = c.get("wholesale_stock", [])
	for i in range(stock.size()):
		var it: Dictionary = stock[i]
		var def := GameState.get_item_def(String(it.get("def_id", "")))
		var pos := Vector2((i % 5) * 266, int(i / 5) * 150)
		var card := _panel(wholesale_box, pos, Vector2(250, 138), C_PANEL2, C_LINE, 1)
		var ip := GameState.item_icon_path(def)
		var icon := _texture_rect(card, Vector2(8, 8), Vector2(110, 110), ip)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label(card, GameState.item_display_name(it), Vector2(122, 12), Vector2(120, 62), 18, C_TEXT)
		_label(card, "%d₵" % GameState.effective_value(it), Vector2(122, 80), Vector2(120, 28), 18, C_MUTED)
	var total := GameState.wholesale_total(c)
	var free := bool(c.get("wholesale_free", false))
	var disc := int(c.get("wholesale_discount", -20))
	wholesale_total_label.text = "整批 %d 件 · %s" % [stock.size(), "免费" if free else "总价 %d₵（%d%%）" % [total, disc]]
	wholesale_buy_btn.text = "收下" if free else "买下全部"
	wholesale_buy_btn.disabled = done or (not free and GameState.cash < total)
	wholesale_buy_btn.visible = not done
	wholesale_status.text = "按整批价一次买下全部货物。" if not done else "货物已处理，点「离开」送走快递员。"
	if not done and not free and GameState.cash < total:
		wholesale_status.text += "\n现金不足。"

func _wholesale_buy() -> void:
	var res := GameState.buy_wholesale()
	_play_sfx("cash" if bool(res.get("ok", false)) else "fail")
	if not bool(res.get("ok", false)):
		wholesale_status.text = String(res.get("text", ""))
		return
	_refresh()
	if String(res.get("next_intent", "")) == "buy":
		wholesale_layer.visible = false
		_toast("顾客收下货物，开始看展示柜。")
		return
	_rebuild_wholesale()

func _open_wanted_visit() -> void:
	var c := GameState.current_customer
	if c.is_empty() or String(c.get("intent", "")) != "wanted_visit":
		return
	var w := GameState.wanted_def(String(c.get("wanted_id", "")))
	var body := "通缉目标：%s
悬赏：%d₵

%s" % [String(w.get("name", "")), int(w.get("reward", 0)), String(w.get("desc", ""))]
	_show_modal("通缉目标", body, [
		{"label": "报警举报", "cb": _report_wanted_ui, "color": C_GREEN},
		{"label": "动手", "cb": _engage_wanted_ui, "color": C_RUST},
		{"label": "放走", "cb": _decline_procurement, "color": C_MUTED},
	])
	modal_close_btn.visible = false

func _report_wanted_ui() -> void:
	var res := GameState.report_wanted(String(GameState.current_customer.get("wanted_id", "")))
	_show_modal("治安部", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _engage_wanted_ui() -> void:
	var res := GameState.engage_wanted_visit()
	_close_modal()
	if not bool(res.get("ok", false)):
		_toast(String(res.get("text", "")))

func _open_due_customer(kind: String) -> void:
	var c := GameState.current_customer
	if c.is_empty():
		return
	var amount := int(c.get("amount", 0))
	var title := "房东" if kind == "rent" else "放贷人"
	var actions: Array = [{"label": "支付 %d₵" % amount, "cb": _pay_due.bind(kind), "color": C_GREEN}]
	if kind == "rent" and GameState.can_buy_out_store():
		actions.append({"label": "买断 %d₵" % GameState.store_buy_price(), "cb": _buy_out_ui, "color": C_AMBER})
	actions.append({"label": "稍后", "cb": _decline_procurement, "color": C_MUTED})
	_show_modal(title, String(c.get("line", "")) + "

应付：%d₵" % amount, actions)
	modal_close_btn.visible = false

func _buy_out_ui() -> void:
	var res := GameState.buy_out_store()
	_close_modal()
	_refresh()
	_show_modal("产权", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _open_property() -> void:
	if GameState.property_owned:
		_show_modal("产权", "店铺已归你所有，不再支付房租。", [{"label": "关闭", "cb": _close_modal}])
		return
	var price := GameState.store_buy_price()
	var down := GameState.mortgage_down_payment()
	var weekly := GameState.mortgage_weekly_for(price, down)
	var text := "买断价：%d₵
按揭：首付 %d₵ · 每周 %d₵ · %d 周" % [price, down, weekly, int(GameState.diff_rule("mortgage_weeks", 12))]
	if GameState.is_paying_mortgage:
		text = "按揭中：剩余 %d 周 · 每周 %d₵ · 下次扣款 %d 天后" % [GameState.mortgage_week_left, GameState.mortgage_weekly_payment, GameState.mortgage_due]
	var actions: Array = []
	if GameState.is_paying_mortgage:
		actions.append({"label": "提前还一期", "cb": _pay_mortgage_ui, "color": C_GREEN})
	else:
		actions.append({"label": "买断 %d₵" % price, "cb": _buy_out_ui, "color": C_AMBER})
		actions.append({"label": "申请按揭", "cb": _take_mortgage_ui, "color": C_CYAN})
	actions.append({"label": "关闭", "cb": _close_modal})
	_show_modal("产权 · 店铺", text, actions)

func _take_mortgage_ui() -> void:
	var res := GameState.take_mortgage()
	_close_modal()
	_refresh()
	_show_modal("按揭", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _pay_mortgage_ui() -> void:
	var res := GameState.pay_mortgage_week()
	_close_modal()
	_refresh()
	_show_modal("按揭", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _pay_due(kind: String) -> void:
	var res: Dictionary = GameState.pay_rent_early() if kind == "rent" else GameState.pay_loan_early()
	_close_modal()
	_refresh()
	_toast(String(res.get("text", "")))

func _open_gun_order() -> void:
	var c := GameState.current_customer
	if c.is_empty() or String(c.get("intent", "")) != "gun_order":
		return
	GameState.gun_order = c
	var reqs: Array = []
	for k in c.get("require", {}).keys():
		reqs.append("%s > %d" % [String(k), int(c["require"][k])])
	var bonus_lines: Array = []
	for b in c.get("bonuses", []):
		bonus_lines.append("%s > %d → +%d₵" % [String(b.get("stat", "")), int(b.get("min", 0)), int(b.get("add", 0))])
	var text := "订单要求：" + ("、".join(reqs) if not reqs.is_empty() else "任意枪械")
	if not bonus_lines.is_empty():
		text += "
附加奖励：" + "；".join(bonus_lines)
	if bool(c.get("service", false)):
		text += "
维修订单：费用 %d₵，整备后可交付。" % int(c.get("fee", 0))
	var actions: Array = [{"label": "选择枪械交付", "cb": _gun_order_pick, "color": C_AMBER}]
	if bool(c.get("service", false)):
		actions.append({"label": "支付维修费", "cb": _gun_order_repair_ui, "color": C_CYAN})
	actions.append({"label": "离开", "cb": _gun_order_leave})
	_show_modal("枪械订单 · %s" % String(c.get("arche", {}).get("name", "买家")), text, actions)

func _gun_order_pick() -> void:
	var items: Array = []
	for it in GameState.gun_order_candidates():
		var ev := GameState.gun_order_eval(it)
		var did := String(it.get("def_id", ""))
		var stats := GameState.gun_def_stats(did, String(it.get("condition", "")))
		var stat_text := "FP%d ACC%d REL%d" % [int(stats.get("firepower", 0)), int(stats.get("accuracy", 0)), int(stats.get("reliability", 0))]
		items.append({"id": str(int(it.get("uid", -1))), "label": "%s · %s · %s" % [GameState.item_display_name(it), stat_text, String(ev.get("text", ""))]})
	if items.is_empty():
		_toast("背包和展示柜里没有可交付的枪械。")
		return
	_open_select("选择交付枪械", items, _gun_order_deliver_uid)

func _gun_order_deliver_uid(id: String) -> void:
	var res := GameState.deliver_gun_order(int(id))
	_play_sfx("cash" if bool(res.get("ok", false)) else "fail")
	_refresh()
	_show_modal("枪械订单", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _gun_order_repair_ui() -> void:
	var res := GameState.gun_order_repair()
	_play_sfx("machine" if bool(res.get("ok", false)) else "fail")
	_refresh()
	_show_modal("维修", String(res.get("text", "")), [{"label": "返回订单", "cb": _open_gun_order}])

func _gun_order_leave() -> void:
	GameState.release_gun_order()
	_refresh()

func _open_expedition() -> void:
	var c := GameState.current_customer
	if c.is_empty() or String(c.get("intent", "")) != "expedition":
		return
	var party: Dictionary = GameState.combat_parties.get(String(c.get("party", "")), {})
	var body := String(c.get("line", "")) + "

目标：%s" % String(party.get("name", "未知区域"))
	var actions: Array = [{"label": "出发", "cb": _start_expedition_ui, "color": C_RUST}]
	if not GameState.hireling.is_empty():
		actions.append({"label": "派遣 Juan", "cb": _dispatch_hireling_ui, "color": C_AMBER})
	actions.append({"label": "拒绝", "cb": _decline_procurement, "color": C_MUTED})
	_show_modal("探险 · %s" % String(c.get("arche", {}).get("name", "组织者")), body, actions)
	modal_close_btn.visible = false

func _dispatch_hireling_ui() -> void:
	var res := GameState.dispatch_hireling()
	_play_sfx("phone_calling" if bool(res.get("ok", false)) else "fail")
	_close_modal()
	GameState.complete_customer(false)
	_refresh()
	_toast(String(res.get("text", "")))

func _open_hireling_return() -> void:
	var c := GameState.current_customer
	if c.is_empty() or String(c.get("intent", "")) != "hireling_return":
		return
	_show_modal("Juan 的探险报告", String(c.get("line", "")), [
		{"label": "收下日志", "cb": _hireling_report_done, "color": C_GREEN},
	])

func _hireling_report_done() -> void:
	_close_modal()
	GameState.complete_customer(true)
	_refresh()

func _start_expedition_ui() -> void:
	var res := GameState.start_expedition()
	_close_modal()
	if not bool(res.get("ok", false)):
		_toast(String(res.get("text", "")))

func _open_information_dealer() -> void:
	var c := GameState.current_customer
	if c.is_empty() or String(c.get("intent", "")) != "information":
		return
	var cost := int(c.get("service_cost", 50))
	var body := String(c.get("line", "")) + "

情报价格：%d₵" % cost
	_show_modal("情报商人 · %s" % String(c.get("arche", {}).get("name", "线人")), body, [
		{"label": "购买情报 %d₵" % cost, "cb": _buy_information_ui, "color": C_GREEN},
		{"label": "离开", "cb": _decline_procurement, "color": C_MUTED},
	])
	modal_close_btn.visible = false

func _buy_information_ui() -> void:
	var res := GameState.buy_information()
	_show_modal("情报商人", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _open_gift() -> void:
	var c := GameState.current_customer
	if c.is_empty() or String(c.get("intent", "")) != "gift":
		return
	_show_modal("上层区施恩人", String(c.get("line", "")) + "\n\n这是一份无偿捐赠。", [
		{"label": "收下捐赠", "cb": _accept_gift_ui, "color": C_GREEN},
		{"label": "婉拒", "cb": _decline_gift_ui, "color": C_MUTED},
	])
	modal_close_btn.visible = false

func _accept_gift_ui() -> void:
	var res := GameState.accept_charity_gift()
	_close_modal()
	_toast(String(res.get("text", "")))
	_refresh()

func _decline_gift_ui() -> void:
	GameState.complete_customer(false)
	_close_modal()
	_refresh()

func _open_blackmail() -> void:
	var c := GameState.current_customer
	if c.is_empty() or String(c.get("intent", "")) != "blackmail":
		return
	var amount := int(c.get("amount", 0))
	_show_modal("敲诈者", String(c.get("line", "")), [
		{"label": "支付 %d₵" % amount, "cb": _blackmail_pay_ui, "color": C_RUST},
		{"label": "拒绝", "cb": _blackmail_refuse_ui, "color": C_MUTED},
	])
	modal_close_btn.visible = false

func _blackmail_pay_ui() -> void:
	var res := GameState.resolve_blackmail(true)
	_close_modal()
	_toast(String(res.get("text", "")))
	_refresh()

func _blackmail_refuse_ui() -> void:
	var res := GameState.resolve_blackmail(false)
	_close_modal()
	_toast(String(res.get("text", "")))
	_refresh()

func _open_procurement_offer() -> void:
	var c := GameState.current_customer
	if c.is_empty() or String(c.get("intent", "")) != "procurement_offer":
		return
	var item := GameState.get_item_def(String(c.get("item_id", "")))
	var body := String(c.get("line", ""))
	body += "

需要：%s ×%d
期限：%d 天
报酬：%d₵" % [String(item.get("name", c.get("item_id", ""))), int(c.get("count", 0)), int(c.get("days", 0)), int(c.get("reward", 0))]
	_show_modal("采购委托 · %s" % String(c.get("arche", {}).get("name", "客户")), body, [
		{"label": "接受委托", "cb": _accept_procurement_ui, "color": C_GREEN},
		{"label": "拒绝", "cb": _decline_procurement, "color": C_MUTED},
	])
	modal_close_btn.visible = false

func _accept_procurement_ui() -> void:
	var res := GameState.accept_procurement()
	_show_modal("采购委托", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _decline_procurement() -> void:
	GameState.complete_customer(true)
	_close_modal()

func _open_procurement_collect() -> void:
	var c := GameState.current_customer
	if c.is_empty() or String(c.get("intent", "")) != "procurement_collect":
		return
	var item := GameState.get_item_def(String(c.get("item_id", "")))
	var have := GameState.inventory_count(String(c.get("item_id", "")))
	var body := String(c.get("line", ""))
	body += "

需要：%s ×%d（持有 %d）
报酬：%d₵" % [String(item.get("name", c.get("item_id", ""))), int(c.get("count", 0)), have, int(c.get("reward", 0))]
	_show_modal("采购交付 · %s" % String(c.get("arche", {}).get("name", "客户")), body, [
		{"label": "交付货物", "cb": _collect_procurement_ui, "color": C_GREEN},
		{"label": "离开", "cb": _decline_procurement, "color": C_MUTED},
	])
	modal_close_btn.visible = false

func _collect_procurement_ui() -> void:
	var res := GameState.collect_procurement()
	if bool(res.get("ok", false)):
		_show_modal("采购交付", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])
	else:
		_show_modal("采购交付", String(res.get("text", "")), [{"label": "离开", "cb": _decline_procurement, "color": C_MUTED}])

func _build_phone_layer() -> void:
	phone_layer = Control.new()
	phone_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	phone_layer.visible = false
	phone_layer.z_index = 148
	phone_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(phone_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	phone_layer.add_child(dim)
	var panel := _panel(phone_layer, Vector2(220, 50), Vector2(1900, 980), C_PANEL, C_CYAN, 3)
	_label(panel, "手机 · PHONE", Vector2(28, 14), Vector2(700, 48), 34, C_AMBER)
	_button(panel, "关闭", Vector2(1710, 12), Vector2(160, 48), C_MUTED, _close_phone)
	var left := _panel(panel, Vector2(28, 76), Vector2(540, 860), C_PANEL2, C_LINE, 2)
	phone_number_label = _label(left, "", Vector2(20, 20), Vector2(500, 60), 40, C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	phone_status_label = _label(left, "输入电话号码", Vector2(20, 84), Vector2(500, 32), 20, C_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	var keys := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "清空", "0", "退格"]
	for i in range(keys.size()):
		var k := String(keys[i])
		var btn := _button(left, k, Vector2(30 + (i % 3) * 165, 140 + int(i / 3) * 96), Vector2(150, 80), C_TEXT, _phone_key.bind(k))
		btn.add_theme_font_size_override("font_size", 30)
	_button(left, "拨号", Vector2(30, 540), Vector2(480, 88), C_GREEN, _phone_dial)
	_button(left, "挂断", Vector2(30, 650), Vector2(480, 70), C_RUST, _close_phone)
	var right := _panel(panel, Vector2(600, 76), Vector2(1240, 860), C_PANEL2, C_LINE, 2)
	_label(right, "电话簿", Vector2(24, 16), Vector2(400, 36), 28, C_AMBER)
	var quick := [["治安部", "sec"], ["补给站", "commissary"], ["怀尔德助手", "wild"], ["奥丁", "rev"]]
	for i in range(quick.size()):
		var qb := _button(right, quick[i][0], Vector2(24 + i * 250, 60), Vector2(230, 56), C_CYAN, _phone_quick.bind(String(quick[i][1])))
		qb.add_theme_font_size_override("font_size", 20)
	phone_book_box = VBoxContainer.new()
	phone_book_box.position = Vector2(24, 136)
	phone_book_box.size = Vector2(500, 680)
	phone_book_box.add_theme_constant_override("separation", 8)
	right.add_child(phone_book_box)
	phone_dlg_panel = _panel(phone_layer, Vector2(500, 110), Vector2(1340, 800), C_PANEL, C_AMBER, 3)
	phone_dlg_panel.visible = false
	phone_dlg_speaker = _label(phone_dlg_panel, "", Vector2(28, 16), Vector2(900, 44), 30, C_AMBER)
	phone_dlg_text = _label(phone_dlg_panel, "", Vector2(28, 72), Vector2(1280, 420), 26, C_TEXT)
	phone_dlg_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	phone_dlg_choices = VBoxContainer.new()
	phone_dlg_choices.position = Vector2(28, 510)
	phone_dlg_choices.size = Vector2(1280, 250)
	phone_dlg_choices.add_theme_constant_override("separation", 10)
	phone_dlg_panel.add_child(phone_dlg_choices)
	phone_dlg_cont_btn = _button(phone_dlg_panel, "继续", Vector2(560, 700), Vector2(220, 64), C_CYAN, _phone_next_page)
	_button(phone_dlg_panel, "挂断", Vector2(1080, 700), Vector2(220, 64), C_RUST, _phone_hangup)

func _open_phone() -> void:
	phone_layer.visible = true
	move_child(phone_layer, get_child_count() - 1)
	phone_number_label.text = ""
	phone_status_label.text = "输入电话号码"
	phone_dlg_panel.visible = false
	_rebuild_phone_book()

func _close_phone() -> void:
	phone_layer.visible = false
	phone_dlg_panel.visible = false

func _rebuild_phone_book() -> void:
	_clear_children(phone_book_box)
	var contacts := GameState.phone_book_contacts()
	if contacts.is_empty():
		var l := Label.new()
		l.text = "还没有已拨通的联系人。购买信息网络里的供应商名片后，按名片号码拨号。"
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(1200, 60)
		l.add_theme_font_size_override("font_size", 20)
		l.add_theme_color_override("font_color", C_MUTED)
		phone_book_box.add_child(l)
		return
	for c in contacts:
		var b := Button.new()
		b.text = "%s · %s" % [String(c.get("name", "")), String(c.get("status", ""))]
		b.custom_minimum_size = Vector2(1200, 62)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 22)
		b.pressed.connect(_phone_call_contact.bind(String(c.get("id", ""))))
		phone_book_box.add_child(b)

func _phone_key(k: String) -> void:
	if k == "清空":
		phone_number_label.text = ""
	elif k == "退格":
		phone_number_label.text = phone_number_label.text.substr(0, maxi(0, phone_number_label.text.length() - 1))
	elif phone_number_label.text.length() < 6:
		phone_number_label.text += k

func _phone_dial() -> void:
	var num := phone_number_label.text
	if num == "":
		phone_status_label.text = "请输入号码"
		return
	var sid := GameState.phone_contact_by_number(num)
	if sid == "":
		phone_status_label.text = GameState.loc("UI", "ui_phone_no_answer", "无人接听")
		_play_sfx("phone_wrong")
		return
	phone_status_label.text = GameState.loc("UI", "ui_phone_in_call", "通话中")
	_play_sfx("phone_calling")
	_phone_call_contact(sid)

func _phone_quick(sid: String) -> void:
	phone_number_label.text = GameState.phone_number_of(sid)
	_phone_call_contact(sid)

func _phone_call_contact(sid: String) -> void:
	var res := GameState.phone_dial(sid)
	if not bool(res.get("ok", false)):
		phone_status_label.text = String(res.get("text", GameState.loc("UI", "ui_phone_no_answer", "无人接听")))
		_play_sfx("fail")
		return
	phone_dialog_sid = sid
	phone_pages = res.get("pages", [])
	if phone_pages.is_empty():
		phone_pages = ["……"]
	phone_dialog_choices = res.get("choices", [])
	phone_page_index = 0
	phone_dlg_speaker.text = String(res.get("speaker", GameState.phone_contacts.get(sid, {}).get("name", sid)))
	phone_dlg_panel.visible = true
	_phone_render_page()

func _phone_render_page() -> void:
	_clear_children(phone_dlg_choices)
	phone_dlg_text.text = String(phone_pages[clampi(phone_page_index, 0, phone_pages.size() - 1)])
	var last := phone_page_index >= phone_pages.size() - 1
	phone_dlg_cont_btn.visible = not last
	phone_dlg_cont_btn.disabled = last
	if not last:
		return
	for ch in phone_dialog_choices:
		var b := Button.new()
		b.text = String(ch.get("label", ch.get("id", "")))
		b.custom_minimum_size = Vector2(1260, 62)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 22)
		b.pressed.connect(_phone_choose.bind(String(ch.get("id", ""))))
		phone_dlg_choices.add_child(b)

func _phone_next_page() -> void:
	phone_page_index = mini(phone_page_index + 1, phone_pages.size() - 1)
	_phone_render_page()

func _phone_choose(choice: String) -> void:
	var res := GameState.phone_choose(phone_dialog_sid, choice)
	phone_dlg_panel.visible = false
	phone_status_label.text = String(res.get("toast", "通话结束"))
	if res.has("after_text") and String(res.get("after_text", "")) != "":
		phone_status_label.text = String(res.get("toast", "")) + " " + String(res.get("after_text", ""))
	var opened := String(res.get("open", ""))
	if opened == "network":
		_close_phone()
		_open_network()
	elif opened == "commissary":
		_close_phone()
		_open_commissary()
	phone_number_label.text = ""
	_rebuild_phone_book()

func _phone_hangup() -> void:
	_play_sfx("phone_drop")
	phone_dlg_panel.visible = false
	phone_status_label.text = "已挂断"
	phone_number_label.text = ""

func _build_commissary_layer() -> void:
	commissary_layer = Control.new()
	commissary_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	commissary_layer.visible = false
	commissary_layer.z_index = 149
	commissary_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(commissary_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	commissary_layer.add_child(dim)
	var panel := _panel(commissary_layer, Vector2(360, 60), Vector2(1620, 940), C_PANEL, C_CYAN, 3)
	_label(panel, "补给站 · COMMISSARY", Vector2(30, 14), Vector2(800, 48), 34, C_AMBER)
	_button(panel, "关闭", Vector2(1430, 12), Vector2(160, 48), C_MUTED, _close_commissary)
	commissary_credit_label = _label(panel, "", Vector2(30, 74), Vector2(900, 40), 24, C_TEXT)
	_button(panel, "兑换食品券", Vector2(950, 70), Vector2(260, 54), C_GREEN, _commissary_redeem)
	commissary_list = VBoxContainer.new()
	commissary_list.position = Vector2(30, 140)
	commissary_list.size = Vector2(1560, 620)
	commissary_list.add_theme_constant_override("separation", 8)
	panel.add_child(commissary_list)
	commissary_status = _label(panel, "", Vector2(30, 780), Vector2(1560, 100), 22, C_MUTED)
	commissary_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _open_commissary() -> void:
	if GameState.commissary_banned():
		_toast("你被配给站拒之门外。")
		return
	_play_room_ambience("amb_comissionary_ambience.ogg")
	commissary_layer.visible = true
	move_child(commissary_layer, get_child_count() - 1)
	_rebuild_commissary()

func _close_commissary() -> void:
	_stop_room_ambience()
	commissary_layer.visible = false

func _rebuild_commissary() -> void:
	_clear_children(commissary_list)
	commissary_credit_label.text = "兑换券：%d · 食品券可在「兑换食品券」一键兑换" % GameState.commissary_credit
	for it in GameState.commissary_defs:
		var did := String(it.get("id", ""))
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(1560, 70)
		row.add_theme_constant_override("separation", 12)
		commissary_list.add_child(row)
		var name_l := Label.new()
		name_l.text = String(GameState.get_item_def(did).get("name", did))
		name_l.custom_minimum_size = Vector2(620, 60)
		name_l.add_theme_font_size_override("font_size", 24)
		name_l.add_theme_color_override("font_color", C_TEXT)
		row.add_child(name_l)
		var price_l := Label.new()
		price_l.text = "%d 兑换券" % int(it.get("price", 0))
		price_l.custom_minimum_size = Vector2(300, 60)
		price_l.add_theme_font_size_override("font_size", 22)
		price_l.add_theme_color_override("font_color", C_AMBER)
		row.add_child(price_l)
		var stock_l := Label.new()
		stock_l.text = "库存 %d/%d" % [int(GameState.commissary_stock.get(did, 0)), int(it.get("max", 0))]
		stock_l.custom_minimum_size = Vector2(260, 60)
		stock_l.add_theme_font_size_override("font_size", 20)
		stock_l.add_theme_color_override("font_color", C_MUTED)
		row.add_child(stock_l)
		var buy := Button.new()
		buy.text = "兑换"
		buy.custom_minimum_size = Vector2(220, 60)
		buy.focus_mode = Control.FOCUS_NONE
		buy.add_theme_font_size_override("font_size", 22)
		buy.disabled = int(GameState.commissary_stock.get(did, 0)) <= 0 or GameState.commissary_credit < int(it.get("price", 0))
		buy.pressed.connect(_commissary_buy.bind(did))
		row.add_child(buy)

func _commissary_redeem() -> void:
	var res := GameState.commissary_redeem_stamps()
	commissary_status.text = String(res.get("text", ""))
	_rebuild_commissary()
	_refresh()

func _commissary_buy(id: String) -> void:
	var res := GameState.commissary_buy(id)
	commissary_status.text = String(res.get("text", ""))
	_rebuild_commissary()
	_refresh()

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
	machine_io_label = _label(detail, "", Vector2(24, 100), Vector2(1230, 220), 20, C_TEXT)
	machine_module_label = _label(detail, "", Vector2(24, 322), Vector2(1230, 30), 22, C_CYAN)
	var install := _button(detail, "安装模块", Vector2(24, 362), Vector2(220, 54), C_CYAN, _open_module_select)
	machine_recipe_btn = _button(detail, "配方", Vector2(660, 362), Vector2(290, 54), C_AMBER, _open_recipe_select)
	machine_stock_grid_btn = _button(detail, "库存网格", Vector2(660, 362), Vector2(290, 54), C_CYAN, _open_machine_stock_grid)
	install.name = "InstallModule"
	var temps := [["低温", 1], ["标准", 2], ["高温", 3]]
	for t in temps:
		var tb := _button(detail, t[0], Vector2(254 + (int(t[1]) - 1) * 130, 362), Vector2(120, 54), C_MUTED, _set_temp.bind(int(t[1])))
		temp_buttons.append(tb)
	machine_aux_btn = _button(detail, "启用", Vector2(960, 362), Vector2(290, 54), C_CYAN, _toggle_machine_active)
	machine_start_btn = _button(detail, "启动生产", Vector2(24, 440), Vector2(300, 72), C_AMBER, _start_selected_machine)
	machine_repair_btn = _button(detail, "维修", Vector2(340, 440), Vector2(190, 72), C_CYAN, _repair_selected_machine)
	machine_harvest_btn = _button(detail, "收获", Vector2(540, 440), Vector2(180, 72), C_GREEN, _harvest_selected_machine)
	machine_special_btn = _button(detail, "特殊操作", Vector2(730, 440), Vector2(230, 72), C_AMBER, _machine_special_pressed)
	machine_stock_btn = _button(detail, "存入", Vector2(970, 440), Vector2(130, 72), C_CYAN, _open_machine_stock)
	machine_take_btn = _button(detail, "取回", Vector2(1110, 440), Vector2(130, 72), C_MUTED, _take_machine_stock)
	machine_io_in_btn = _button(detail, "输入网格", Vector2(24, 596), Vector2(300, 54), C_CYAN, _open_machine_io_input)
	machine_io_out_btn = _button(detail, "输出网格", Vector2(340, 596), Vector2(300, 54), C_GREEN, _open_machine_io_output)
	machine_status_label = _label(detail, "选择机器开始生产。", Vector2(24, 520), Vector2(1230, 64), 20, C_MUTED)
	var jobs_panel := _panel(panel, Vector2(570, 760), Vector2(1280, 190), C_PANEL2, C_LINE, 2)
	_label(jobs_panel, "运行队列", Vector2(24, 12), Vector2(300, 32), 24, C_AMBER)
	machine_jobs_label = _label(jobs_panel, "无", Vector2(24, 50), Vector2(1230, 130), 22, C_TEXT)

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
	var tabs := [["网络", "network"], ["专精", "professions"], ["估价", "appraisal"], ["派系", "factions"], ["顾客", "customers"], ["电话", "phone"], ["治安", "security"], ["通缉", "wanted"], ["天赋", "perks"], ["声望", "rep_perks"], ["档案", "archive"], ["状态", "status"], ["成就", "achievements"], ["统计", "stats"], ["新闻", "news"], ["地图", "map"], ["笔记", "notebook"], ["委托", "requests"]]
	for i in range(tabs.size()):
		var tb := _button(panel, tabs[i][0], Vector2(20 + i * 96, 70), Vector2(92, 44), C_MUTED, _switch_info_tab.bind(tabs[i][1]))
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
	info_name = _label(detail, "", Vector2(24, 16), Vector2(940, 44), 34, C_TEXT)
	info_icon = _texture_rect(detail, Vector2(1160, 16), Vector2(96, 96), "")
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
	for ly in [0, 1010]:
		var bar := ColorRect.new()
		bar.position = Vector2(0, ly)
		bar.size = Vector2(2340, 70)
		bar.color = Color.BLACK
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		story_layer.add_child(bar)
	story_portrait = _texture_rect(panel, Vector2(30, 150), Vector2(460, 540), "")
	var bubble := _panel(panel, Vector2(500, 60), Vector2(1320, 420), C_PANEL2, C_LINE, 2)
	var bubble_style := _style(C_PANEL2, C_LINE, 2)
	bubble_style.corner_radius_top_left = 22
	bubble_style.corner_radius_top_right = 22
	bubble_style.corner_radius_bottom_left = 22
	bubble_style.corner_radius_bottom_right = 22
	bubble.add_theme_stylebox_override("panel", bubble_style)
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tail := ColorRect.new()
	tail.position = Vector2(480, 300)
	tail.size = Vector2(28, 28)
	tail.rotation = 0.78
	tail.color = C_PANEL2
	tail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(tail)
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
	combat_impact = _texture_rect(panel, Vector2(30, 80), Vector2(360, 360), "")
	combat_impact.visible = false
	combat_impact.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	combat_log_label = _label(panel, "", Vector2(420, 230), Vector2(1250, 280), 22, C_TEXT)
	combat_status = _label(panel, "", Vector2(420, 510), Vector2(1250, 56), 20, C_MUTED)
	combat_actions_box = HFlowContainer.new()
	combat_actions_box.position = Vector2(420, 576)
	combat_actions_box.size = Vector2(1260, 200)
	combat_actions_box.add_theme_constant_override("h_separation", 12)
	combat_actions_box.add_theme_constant_override("v_separation", 10)
	panel.add_child(combat_actions_box)

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
	if bell_button:
		var remaining := GameState.customers_today.size() - GameState.current_index - 1
		bell_button.visible = GameState.phase == "open" and GameState.current_customer.is_empty() and remaining > 0
		bell_button.disabled = remaining <= 0
		bell_button.text = "按铃 · 召唤下一位（剩 %d）" % maxi(0, remaining)
	_rebuild_display()
	_rebuild_grid()
	_update_detail()
	_update_action_buttons()
	if GameState.pending_promotion and promotion_prompt_day != GameState.day:
		promotion_prompt_day = GameState.day
		_show_promotion_modal()

func _update_customer() -> void:
	var c: Dictionary = GameState.current_customer
	if c.is_empty():
		customer_rect.visible = false
		customer_rect.modulate = Color.WHITE
		customer_shown_key = ""
		customer_name_label.text = "—"
		queue_label.text = ""
		for qp in queue_portrait_rects:
			qp.visible = false
		customer_info_label.text = "当前没有顾客。\n可以整理物品、查看档案，或结束营业。"
		dialogue_name.text = "店铺"
		dialogue_text.text = "点「结束营业」进入下一天。"
		return
	customer_rect.visible = true
	var arche: Dictionary = c.get("arche", {})
	customer_name_label.text = arche.get("name", "顾客")
	var intent_text := "出售物品" if c.get("intent") == "sell" else ("委托估价" if c.get("intent") == "appraise" else "想买东西")
	customer_info_label.text = "阵营：%s\n意图：%s\n今日第 %d / %d 位" % [_faction_name(arche.get("faction", "lower")), intent_text, GameState.current_index + 1, GameState.customers_today.size()]
	var waiting := GameState.customers_today.size() - GameState.current_index - 1
	var next_names: Array = []
	for i in range(GameState.current_index + 1, mini(GameState.customers_today.size(), GameState.current_index + 3)):
		var nc: Dictionary = GameState.customers_today[i]
		next_names.append(String(nc.get("arche", {}).get("name", "顾客")))
	queue_label.text = "排队 %d 位%s" % [waiting, ("：" + "、".join(next_names)) if not next_names.is_empty() else ""]
	for qi in range(queue_portrait_rects.size()):
		var qp: TextureRect = queue_portrait_rects[qi]
		var qidx := GameState.current_index + 1 + qi
		if qidx < GameState.customers_today.size():
			var qarche: Dictionary = GameState.customers_today[qidx].get("arche", {})
			var qpath := _customer_path(String(qarche.get("sprite", "maleUpper_0.png")))
			qp.texture = load(qpath) if ResourceLoader.exists(qpath) else null
			qp.visible = qp.texture != null
		else:
			qp.visible = false
	var sprite := String(arche.get("sprite", "maleUpper_0.png"))
	var path := _customer_path(sprite)
	if ResourceLoader.exists(path):
		customer_rect.texture = load(path)
	var ckey := "%d|%d|%s" % [GameState.day, GameState.current_index, String(arche.get("name", ""))]
	if ckey != customer_shown_key:
		customer_shown_key = ckey
		_play_customer_walkin()
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
	elif GameState.current_customer.get("intent") == "appraise":
		counter_price.text = "委托估价"
		counter_hint.text = "点右侧「估价」查看属性并提交估价。"
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

const GRID_CELL := 54
const GRID_STEP := 58

func _add_count_badge(parent: Control, at: Vector2, size: Vector2, count: int) -> void:
	if count <= 1:
		return
	var l := Label.new()
	l.text = "×%d" % count
	l.position = at + Vector2(maxf(0.0, size.x - 42.0), maxf(0.0, size.y - 26.0))
	l.size = Vector2(40, 24)
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", C_AMBER)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)

func _rebuild_grid() -> void:
	_clear_children(grid_root)
	var dims := GameState.page_size(current_page)
	for y in range(int(dims[1])):
		for x in range(int(dims[0])):
			var cell := _panel(grid_root, Vector2(x * GRID_STEP, y * GRID_STEP), Vector2(GRID_CELL, GRID_CELL), Color("#11151d"), Color("#2a3140"), 1)
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
		var w := int(shape[0]) * GRID_CELL + (int(shape[0]) - 1) * (GRID_STEP - GRID_CELL)
		var h := int(shape[1]) * GRID_CELL + (int(shape[1]) - 1) * (GRID_STEP - GRID_CELL)
		var icon := TextureButton.new()
		icon.position = Vector2(int(it["x"]) * GRID_STEP, int(it["y"]) * GRID_STEP)
		icon.size = Vector2(w, h)
		var gip := GameState.item_icon_path(def)
		icon.texture_normal = load(gip) if gip != "" else null
		icon.ignore_texture_size = true
		icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.focus_mode = Control.FOCUS_NONE
		var uid := int(it["uid"])
		icon.pressed.connect(_on_item_selected.bind(uid))
		icon.gui_input.connect(_on_drag_gui_input.bind(uid, icon, "main"))
		if uid == selected_uid:
			icon.self_modulate = Color(1.3, 1.2, 0.85)
		grid_root.add_child(icon)
		_add_count_badge(grid_root, icon.position, icon.size, int(it.get("unit_count", 1)))
	if current_page >= GameState.pages_unlocked:
		current_page = GameState.pages_unlocked - 1
	for i in range(page_buttons.size()):
		page_buttons[i].disabled = i >= GameState.pages_unlocked
	capacity_label.text = "物品 %d · %s" % [GameState.inventory.size(), ["前台", "背后", "隐藏格"][current_page]]

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
		detail_inspect_btn.disabled = true
		detail_open_btn.disabled = true
		detail_liquid_btn.disabled = true
		detail_split_btn.disabled = true
		detail_equip_btn.visible = false
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
	var container_text := ""
	var cspec := GameState.container_spec(it)
	if GameState.is_container_item(it):
		container_text = "\n容器：%d 件" % it.get("children", []).size()
		if String(cspec.get("kind", "")) == "slots":
			container_text += " / %d 槽" % cspec.get("slots", []).size()
		else:
			container_text += " / %d 格" % (int(cspec.get("width", 0)) * int(cspec.get("height", 0)))
	elif GameState.is_liquid_container(it):
		container_text = "\n液体：%d/%d ml · 纯度 %d%%" % [int(it.get("liquid_ml", 0)), int(cspec.get("capacity_ml", 0)), int(it.get("liquid_purity", 0)) / 100]
	var weight_text := ""
	var wt := GameState.item_weight(it)
	if wt > 0:
		weight_text = "\n重量：%d g" % wt
	var card_sid := GameState.phone_card_contact(String(it.get("def_id", "")))
	if card_sid != "":
		weight_text += "\n名片电话：%s" % GameState.phone_number_of(card_sid)
	detail_meta.text = "品相 %d%% · %s%s\n%s\n特征：%s · %s%s%s" % [cond, "已鉴定 · " + auth_text if known else "未鉴定", stolen_text, tags_text, feat_text, loc_text, container_text, weight_text]
	if known or loc == "backpack":
		detail_price.text = "%d¥" % GameState.market_value(it, false)
	else:
		var base := int(def.get("base_value", 0))
		detail_price.text = "%d-%d¥" % [int(base * 0.5), int(base * 1.1)]
	detail_rot_btn.disabled = loc != "backpack"
	detail_display_btn.text = "下架" if loc == "display" else "上架"
	detail_display_btn.disabled = loc not in ["backpack", "display"]
	detail_counter_btn.disabled = not (loc == "display" and GameState.current_customer.get("intent") == "buy")
	detail_inspect_btn.disabled = loc not in ["backpack", "display"]
	detail_open_btn.disabled = not GameState.is_container_item(it)
	detail_liquid_btn.disabled = not GameState.is_liquid_container(it)
	var is_stack := GameState.is_stackable_item(it) and int(it.get("unit_count", 1)) > 1
	detail_split_btn.disabled = not (GameState.is_liquid_container(it) or is_stack)
	detail_split_btn.text = "分瓶" if GameState.is_liquid_container(it) else "分堆"
	detail_open_btn.visible = not GameState.is_liquid_container(it) or GameState.is_container_item(it)
	detail_liquid_btn.visible = GameState.is_liquid_container(it)
	detail_split_btn.visible = GameState.is_liquid_container(it) or is_stack
	detail_inspect_btn.visible = not GameState.is_liquid_container(it) and not GameState.is_armor_item(it)
	detail_equip_btn.visible = GameState.is_armor_item(it)
	detail_equip_btn.text = "卸下" if GameState.equipped_armor_uid == int(it.get("uid", -1)) else "装备"

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
	var intent := String(c.get("intent", ""))
	action_buttons["inspect"].disabled = not (has_customer and intent in ["sell", "appraise"])
	action_buttons["inspect"].text = "估价" if intent == "appraise" else "鉴定"
	action_buttons["bargain"].disabled = not (has_customer and has_counter and intent == "sell" and GameState.can_bargain())
	action_buttons["threaten"].disabled = not (has_customer and has_counter and intent == "sell")
	action_buttons["deal"].disabled = not (has_customer and has_counter and intent == "sell")
	action_buttons["next_item"].disabled = not (has_customer and intent == "sell" and GameState.current_customer.get("items", []).size() > 1)
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

func _on_page_pressed(page: int) -> void:
	if page == 2 and not GameState.poster_pulled:
		_toast("先拉下海报，才能打开隐藏格。")
		return
	_on_page(page)

func _build_poster_layer() -> void:
	poster_layer = Control.new()
	poster_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	poster_layer.z_index = 150
	poster_layer.visible = false
	poster_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(poster_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	poster_layer.add_child(dim)
	var panel := _panel(poster_layer, Vector2(620, 160), Vector2(1100, 760), C_PANEL, C_RUST, 3)
	_label(panel, "海报 · POSTER", Vector2(30, 18), Vector2(600, 46), 34, C_AMBER)
	_button(panel, "关闭", Vector2(940, 14), Vector2(120, 48), C_MUTED, _close_poster)
	poster_image = _texture_rect(panel, Vector2(230, 100), Vector2(640, 360), "")
	poster_status = _label(panel, "", Vector2(30, 500), Vector2(1040, 80), 24, C_TEXT)
	_button(panel, "拉下/拉起", Vector2(360, 620), Vector2(220, 64), C_RUST, _poster_apply)
	_button(panel, "关闭", Vector2(600, 620), Vector2(140, 64), C_MUTED, _close_poster)

func _toggle_poster_ui() -> void:
	poster_layer.visible = true
	move_child(poster_layer, get_child_count() - 1)
	_refresh_poster_preview()

func _refresh_poster_preview() -> void:
	var pulled := GameState.poster_pulled
	var path := "res://assets_private/posters/" + ("poster_down_crop.png" if pulled else "poster_crop.png")
	if ResourceLoader.exists(path):
		poster_image.texture = load(path)
	if shop_poster:
		shop_poster.texture = poster_image.texture
	poster_status.text = "当前：%s
%s" % ["已拉下（隐藏格开放）" if pulled else "已拉起（隐藏格封闭）", "拉下海报会露出墙后的隐藏格；再次拉起可以遮住它。"]

func _poster_apply() -> void:
	GameState.toggle_poster()
	_play_sfx("page")
	_refresh_poster_preview()
	_refresh()

func _close_poster() -> void:
	poster_layer.visible = false

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

func _on_drag_gui_input(event: InputEvent, uid: int, icon: TextureButton, source: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging_uid = uid
			drag_icon = icon
			drag_source = source
			var drag_item := GameState.find_item(uid)
			if drag_item.is_empty():
				_play_sfx("pickup")
			else:
				_play_sfx(GameState.item_drag_sfx_key(drag_item, "drag"))
			drag_offset = icon.get_global_mouse_position() - icon.global_position
			icon.z_index = 10
			icon.modulate.a = 0.75
			dragged = false
		else:
			if dragging_uid == uid and drag_icon:
				var did_drag := dragged
				var icon_ref := drag_icon
				dragging_uid = -1
				drag_icon = null
				icon_ref.z_index = 0
				icon_ref.modulate.a = 1.0
				if did_drag:
					_finish_drag(uid, source)
				else:
					match source:
						"main": call_deferred("_on_item_selected", uid)
						"container": _container_select_child(uid)
						"showcase": _showcase_select(uid)
						"trash": _trash_select(uid)
	elif event is InputEventMouseMotion and dragging_uid == uid and drag_icon:
		dragged = true
		var parent_ctrl := drag_icon.get_parent() as Control
		if parent_ctrl:
			drag_icon.position = drag_icon.get_global_mouse_position() - drag_offset - parent_ctrl.global_position

func _finish_drag(uid: int, source: String) -> void:
	var drop_item := GameState.find_item(uid)
	var mouse := get_global_mouse_position()
	var handled := false
	var target := ""
	if container_layer and container_layer.visible and container_grid.get_global_rect().has_point(mouse):
		target = "container"
	elif showcase_layer and showcase_layer.visible and showcase_grid.get_global_rect().has_point(mouse):
		target = "showcase"
	elif trash_layer and trash_layer.visible and trash_grid.get_global_rect().has_point(mouse):
		target = "trash"
	elif grid_root.get_global_rect().has_point(mouse):
		target = "main"
	if target == "trash":
		if source != "trash":
			handled = GameState.move_to_trash(uid)
		else:
			handled = true
	elif target == "container":
		var gx := int(floor((mouse.x - container_grid.global_position.x) / float(CONTAINER_STEP)))
		var gy := int(floor((mouse.y - container_grid.global_position.y) / float(CONTAINER_STEP)))
		var parent := GameState.find_item(open_container_uid)
		if source == "container" and not parent.is_empty() and not GameState._find_child_item(parent, uid).is_empty():
			handled = GameState.container_move_child(parent, uid, gx, gy, bool(GameState.find_item(uid).get("rotated", false)))
		else:
			handled = GameState.move_item_to_container(uid, open_container_uid, gx, gy)
	elif target == "showcase":
		var sx := int(floor((mouse.x - showcase_grid.global_position.x) / 56.0))
		var sy := int(floor((mouse.y - showcase_grid.global_position.y) / 56.0))
		if source == "showcase":
			handled = GameState.move_display_item(uid, sx, sy)
		else:
			handled = GameState.place_item_in_showcase(uid, sx, sy)
	elif target == "main":
		var gx2 := int(floor((mouse.x - grid_root.global_position.x) / float(GRID_STEP)))
		var gy2 := int(floor((mouse.y - grid_root.global_position.y) / float(GRID_STEP)))
		if source == "main":
			handled = GameState.move_item(uid, gx2, gy2, current_page)
		else:
			handled = GameState.place_item_in_player(uid, current_page, gx2, gy2)
	if not drop_item.is_empty():
		_play_sfx(GameState.item_drag_sfx_key(drop_item, "drop"))
	if not handled:
		_toast("这个位置放不下。")
	_refresh()
	if container_layer.visible:
		_rebuild_container_grid()
	if showcase_layer.visible:
		_rebuild_showcase()
	if trash_layer.visible:
		_rebuild_trash()

func _on_display_slot(uid: int) -> void:
	selected_uid = uid
	if GameState.current_customer.get("intent") == "buy":
		if not GameState.put_display_on_counter(uid):
			_toast("这位顾客不收这种货。")
	_refresh()

func _on_equip_armor() -> void:
	var it := _selected_item()
	if it.is_empty():
		return
	var res: Dictionary
	if GameState.equipped_armor_uid == int(it.get("uid", -1)):
		res = GameState.unequip_armor()
	else:
		res = GameState.equip_armor(int(it.get("uid", -1)))
	_toast(String(res.get("text", "")))
	_refresh()
	_update_detail()

func _on_split_pressed() -> void:
	var it := _selected_item()
	if it.is_empty():
		return
	var res := GameState.split_liquid(it) if GameState.is_liquid_container(it) else GameState.split_stack(selected_uid)
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	_refresh()
	_toast(String(res.get("text", "")))

func _on_liquid_transfer() -> void:
	var src := _selected_item()
	if src.is_empty() or not GameState.is_liquid_container(src):
		return
	var items: Array = []
	for it in GameState.inventory:
		if int(it.get("uid", -1)) == int(src.get("uid", -2)):
			continue
		if GameState.is_liquid_container(it):
			var spec := GameState.container_spec(it)
			items.append({"id": str(it.get("uid", 0)), "label": "%s · %d/%d ml" % [GameState.item_display_name(it), int(it.get("liquid_ml", 0)), int(spec.get("capacity_ml", 0))]})
	if items.is_empty():
		_toast("背包里没有其它液体容器。")
		return
	_open_select("倒入 · %s" % GameState.item_display_name(src), items, _liquid_transfer_choice.bind(int(src.get("uid", -1))))

func _liquid_transfer_choice(target_text: String, source_uid: int) -> void:
	var src := GameState.find_item(source_uid)
	var dst := GameState.find_item(int(target_text))
	if src.is_empty() or dst.is_empty():
		return
	var res := GameState.transfer_liquid(src, dst)
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	_refresh()
	_toast(String(res.get("text", "")))

func _on_open_selected_container() -> void:
	var it := _selected_item()
	if it.is_empty() or not GameState.is_container_item(it):
		_toast("这件物品不是容器。")
		return
	_open_container(int(it.get("uid", -1)))

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

func _play_customer_walkin() -> void:
	if customer_rect == null:
		return
	if customer_shadow_tween:
		customer_shadow_tween.kill()
	customer_rect.modulate = Color(0.22, 0.2, 0.3)
	var tw := create_tween()
	tw.tween_callback(_play_sfx.bind("step_left"))
	tw.tween_interval(0.22)
	tw.tween_callback(_play_sfx.bind("step_right"))
	tw.tween_property(customer_rect, "modulate", Color.WHITE, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	customer_shadow_tween = tw

func _start_customer_idle() -> void:
	if customer_idle_tween:
		customer_idle_tween.kill()
	if customer_rect == null:
		return
	customer_idle_tween = create_tween().set_loops()
	customer_idle_tween.tween_property(customer_rect, "position:y", 8.0, 1.2).set_trans(Tween.TRANS_SINE)
	customer_idle_tween.tween_property(customer_rect, "position:y", 5.0, 1.2).set_trans(Tween.TRANS_SINE)

func _on_customer_changed() -> void:
	_play_named_sfx("new_bell.ogg")
	_start_customer_idle()
	selected_uid = int(GameState.counter_item["uid"]) if not GameState.counter_item.is_empty() else -1
	var intent := String(GameState.current_customer.get("intent", "")) if not GameState.current_customer.is_empty() else ""
	if intent == "barter":
		if wholesale_layer:
			wholesale_layer.visible = false
		_open_barter()
	elif intent == "wholesale":
		if barter_layer:
			barter_layer.visible = false
		_open_wholesale()
	elif intent == "procurement_offer":
		if barter_layer:
			barter_layer.visible = false
		if wholesale_layer:
			wholesale_layer.visible = false
		_open_procurement_offer()
	elif intent == "procurement_collect":
		if barter_layer:
			barter_layer.visible = false
		if wholesale_layer:
			wholesale_layer.visible = false
		_open_procurement_collect()
	elif intent == "information":
		if barter_layer:
			barter_layer.visible = false
		if wholesale_layer:
			wholesale_layer.visible = false
		_open_information_dealer()
	elif intent == "gift":
		if barter_layer:
			barter_layer.visible = false
		if wholesale_layer:
			wholesale_layer.visible = false
		_open_gift()
	elif intent == "blackmail":
		if barter_layer:
			barter_layer.visible = false
		if wholesale_layer:
			wholesale_layer.visible = false
		_open_blackmail()
	elif intent == "hireling_return":
		_open_hireling_return()
	elif intent == "gun_order":
		if barter_layer:
			barter_layer.visible = false
		if wholesale_layer:
			wholesale_layer.visible = false
		_open_gun_order()
	elif intent == "expedition":
		if barter_layer:
			barter_layer.visible = false
		if wholesale_layer:
			wholesale_layer.visible = false
		_open_expedition()
	elif intent == "rent":
		_open_due_customer("rent")
	elif intent == "loan":
		_open_due_customer("loan")
	elif intent == "wanted_visit":
		_open_wanted_visit()
	else:
		if barter_layer:
			barter_layer.visible = false
		if wholesale_layer:
			wholesale_layer.visible = false
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
			_open_phone()
		"machines":
			_open_machines()
		"ledger":
			_show_ledger_modal()
		"facilities":
			_open_facilities()
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
		"next_item":
			_skip_sell_item()
		"dismiss":
			_do_dismiss()

func _skip_sell_item() -> void:
	var res := GameState.skip_current_sell_item()
	_toast(String(res.get("text", "")))
	_refresh()

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
		if mode == "load" and GameState.has_save(i):
			var prev := _save_preview(i)
			label += " · 第 %d 天 · %d₵" % [int(prev.get("day", 0)), int(prev.get("cash", 0))]
		if mode == "save":
			actions.append({"label": label, "cb": _save_slot.bind(i)})
		else:
			actions.append({"label": label, "cb": _load_slot.bind(i)})
	_show_modal("存档" if mode == "save" else "读档", "选择要保存/读取的槽位。", actions)

func _save_preview(slot: int) -> Dictionary:
	var f := FileAccess.open("user://save_%d.json" % slot, FileAccess.READ)
	if f == null:
		return {}
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	return data if data is Dictionary else {}

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
		if GameState.sec_officer_pending:
			_on_security_officer_arrived()
		elif GameState.sec_permit_revoke_pending:
			_on_permit_revoke_arrived()
		elif GameState.sec_inspection_pending:
			_on_inspection_arrived()
		else:
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
			GameState.finish_day()
		return
	if not GameState.tutorial_done and GameState.tutorial_step > 0:
		GameState.tutorial_done = true
		GameState.tutorial_step = 0
		GameState.unlock_achievement("ACH_TUTORIAL")
	_play_sfx("shutter")
	GameState.finish_day()

func _on_day_finished(summary: Dictionary) -> void:
	last_summary = summary
	_show_day_summary(summary)

func _show_day_summary(s: Dictionary) -> void:
	last_summary = s
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
		if GameState.afterhours_visits_left > 0:
			actions.append({"label": "夜间外出（剩 %d 次）" % GameState.afterhours_visits_left, "cb": _open_afterhours_map_deferred, "color": C_GREEN})
		if not GameState.starting_perk_active("perk_unsubscribed"):
			actions.append({"label": "今日报纸", "cb": _open_newspaper, "color": C_CYAN})
		actions.append({"label": "下一天", "cb": _next_day, "color": C_AMBER})
	_show_modal("营业结算", "", actions)
	summary_tabs.visible = true
	_summary_tab_pick("overview")

func _summary_tab_pick(tab: String) -> void:
	summary_tab = tab
	var sections: Dictionary = GameState.day_summary_sections(last_summary)
	modal_text.text = String(sections.get(tab, ""))
	for b in summary_tabs.get_children():
		if b is Button:
			b.modulate = Color(1.25, 1.12, 0.72) if String(b.get_meta("tab", "")) == tab else Color.WHITE

func _return_to_day_summary() -> void:
	if last_summary.is_empty():
		_close_modal()
		return
	last_summary["cash"] = GameState.cash
	_show_day_summary(last_summary)

func _open_afterhours_map_deferred() -> void:
	call_deferred("_open_afterhours_map")

func _open_afterhours_map() -> void:
	var text := "第 %d 天 · 夜间\n今夜还可外出 %d 次。\n\n" % [GameState.day, GameState.afterhours_visits_left]
	var reason := GameState.afterhours_block_reason()
	var actions: Array = []
	if reason == "":
		text += "去哪儿？"
		for loc in GameState.afterhours_locations():
			actions.append({"label": String(loc.get("name", "")), "cb": _afterhours_travel_deferred.bind(String(loc.get("id", ""))), "color": C_CYAN})
	else:
		text += reason
	actions.append({"label": "回店睡觉", "cb": _return_to_day_summary, "color": C_MUTED})
	_show_modal("夜间外出", text, actions)
	modal_close_btn.visible = false

func _afterhours_travel_deferred(loc_id: String) -> void:
	call_deferred("_afterhours_travel_ui", loc_id)

func _afterhours_travel_ui(loc_id: String) -> void:
	var res := GameState.afterhours_travel(loc_id)
	if not bool(res.get("ok", false)):
		_toast(String(res.get("text", "")))
		return
	match loc_id:
		"dumping_ground":
			_play_room_ambience("amb_dumps_ambience.ogg")
			_open_scavenge_ui(String(res.get("text", "")))
		"dr_jackson":
			_open_jackson_ui()
		"commissary":
			_close_modal()
			_open_commissary()

func _open_scavenge_ui(prefix: String = "") -> void:
	var left := GameState.scav_attempts_left()
	var text := prefix + "\n\n"
	text += "剩余搜索：%d 次\n轻伤风险：%.1f%%\n重伤风险：%.1f%%\n\n垃圾堆里有旧金属、电子件，偶尔也有值钱货。" % [left, GameState.scav_minor_chance(), GameState.scav_major_chance()]
	var actions: Array = []
	if left > 0:
		actions.append({"label": "搜索一次", "cb": _scavenge_once_ui, "color": C_GREEN})
	actions.append({"label": "离开垃圾场", "cb": _afterhours_return_ui, "color": C_MUTED})
	_show_modal("垃圾倾倒场", text, actions)

func _scavenge_once_ui() -> void:
	_play_named_sfx("debris_short.ogg")
	var res := GameState.scavenge_dumping_ground()
	_open_scavenge_ui(String(res.get("text", "")))
	if String(res.get("wounded", "")) != "":
		_play_named_sfx("sfx_step_left.ogg")

func _open_jackson_ui() -> void:
	var lines: Array = ["杰克逊医生的柜台亮着灯。\n"]
	var actions: Array = []
	for i in range(GameState.jackson_stock.size()):
		var entry: Dictionary = GameState.jackson_stock[i]
		var it: Dictionary = entry.get("item", {})
		lines.append("%s · %d₵" % [GameState.item_display_name(it), int(entry.get("price", 0))])
		actions.append({"label": "买下 %s（%d₵）" % [GameState.item_display_name(it), int(entry.get("price", 0))], "cb": _jackson_buy_ui.bind(i), "color": C_CYAN})
	actions.append({"label": "离开", "cb": _afterhours_return_ui, "color": C_MUTED})
	_show_modal("杰克逊医生", "\n".join(lines), actions)
	modal_close_btn.visible = false

func _jackson_buy_ui(index: int) -> void:
	var res := GameState.jackson_buy(index)
	_toast(String(res.get("text", "")))
	_open_jackson_ui()

func _afterhours_return_ui() -> void:
	GameState.afterhours_return()
	_stop_room_ambience()
	_open_afterhours_map()

func _next_day() -> void:
	_close_modal()
	GameState.advance_day()
	_refresh()

func _restart_game() -> void:
	_close_modal()
	GameState.new_game(GameState.difficulty, GameState.campaign_mode)
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
	if machine_status_label:
		machine_status_label.text = "已选择：%s。" % String(GameState.machine_def(selected_machine_id).get("name", selected_machine_id))

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
%d电 · %d夜 · 耐久%d%s" % [m.get("name", mid), int(m.get("power", 0)), int(m.get("cycles", 2)), dur, suffix]
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
	machine_status_label.text = "已选择：%s。" % String(GameState.machine_def(machine_id).get("name", machine_id))

func _refresh_machine_panel() -> void:
	var m := GameState.machine_def(selected_machine_id)
	if m.is_empty():
		return
	var recipe := GameState.machine_recipe(selected_machine_id)
	var use_cycles := 1
	var use_power := 0
	if not recipe.is_empty():
		use_cycles = GameState.machine_recipe_cycles(selected_machine_id, recipe)
		use_power = GameState.machine_recipe_power(selected_machine_id, recipe)
	else:
		use_power = GameState.machine_aux_power(selected_machine_id)
	var sums := GameState.machine_module_sums(selected_machine_id)
	var mods := GameState.machine_module_ids(selected_machine_id)
	var lvl := int(GameState.machine_temps.get(selected_machine_id, 2))
	var active := GameState.machine_is_active(selected_machine_id)
	var sp: Dictionary = m.get("special", {})
	var kind := String(sp.get("kind", ""))
	machine_name_label.text = String(m.get("name", ""))
	var dur := int(GameState.machine_durability.get(selected_machine_id, 100))
	var fault := String(GameState.machine_faults.get(selected_machine_id, ""))
	var state_text := "（已损坏）" if dur <= 0 else ("（故障：%s）" % GameState.machine_fault_name(fault) if fault != "" else "")
	var growth_job: Dictionary = {}
	for j in GameState.machine_jobs:
		if String(j.get("machine_id", "")) == selected_machine_id and bool(j.get("growth", false)):
			growth_job = j
			break
	var upgrade_lv := int(GameState.machine_upgrades.get(selected_machine_id, 0))
	var meta := "电力 %d · 周期 %d 夜 · 温度 %d°C · 耐久 %d/100 · 模块 %d/%d" % [use_power, use_cycles, int(m.get("temp", 24)), dur, mods.size(), int(m.get("module_slots", 1))]
	if upgrade_lv > 0:
		meta += " · 升级 %d" % upgrade_lv
	machine_meta_label.text = meta + state_text
	var active_inputs: Array = recipe.get("inputs", []) if not recipe.is_empty() else []
	var active_outputs: Array = recipe.get("outputs", []) if not recipe.is_empty() else []
	var ins: Array = []
	for i in active_inputs:
		var d := GameState.get_item_def(String(i.get("id", "")))
		ins.append("%sx%d" % [_short_item_name(String(i.get("id", "")), String(d.get("name", ""))), int(i.get("count", 1))])
	var outs: Array = []
	for o in active_outputs:
		var od := GameState.get_item_def(String(o.get("id", "")))
		outs.append("%sx%d" % [_short_item_name(String(o.get("id", "")), String(od.get("name", ""))), int(o.get("count", 1))])
	var held: Array = []
	for i in active_inputs:
		var iid := String(i.get("id", ""))
		var dd := GameState.get_item_def(iid)
		held.append("%sx%d" % [_short_item_name(iid, String(dd.get("name", iid))), GameState.inventory_count(iid)])
	var rule := String(m.get("rule_text", ""))
	if recipe.is_empty():
		machine_io_label.text = "规则：%s\n库存：%s\n待收现金：%d₵" % [rule, GameState.machine_stock_summary(selected_machine_id) if kind in ["vending", "fountain", "wine", "fridge", "cage", "feed"] else "—", int(GameState.machine_cash.get(selected_machine_id, 0))]
	else:
		var recipe_label := GameState.machine_recipe_name(recipe)
		var extra := ""
		if recipe.has("water_ml"):
			extra = "\n耗水：%dml/夜" % int(recipe.get("water_ml", 0))
		if recipe.has("volume_ul"):
			extra = "\n目标体积：%dμl" % int(recipe.get("volume_ul", 0))
		var req_text := ""
		for req in recipe.get("requires_modules", []):
			if not mods.has(String(req)):
				req_text += " 缺少模块：" + GameState.module_name(String(req))
		for req in recipe.get("requires_items", []):
			if GameState.inventory_count(String(req)) < 1:
				req_text += " 缺少芯片：" + String(GameState.get_item_def(String(req)).get("name", req))
		machine_io_label.text = "配方：%s\n输入：%s\n输出：%s\n原料持有：%s\n规则：%s%s%s" % [recipe_label, " + ".join(ins) if not ins.is_empty() else "无", " + ".join(outs), " ".join(held) if not held.is_empty() else "无", rule, extra, req_text]
	var mod_names: Array = []
	for mm in mods:
		mod_names.append(GameState.module_name(String(mm)))
	machine_module_label.text = "模块：无" if mods.is_empty() else "模块：%s（性能 %+d / 效率 %+d / 品质 %+d）" % [", ".join(mod_names), int(sums["performance"]), int(sums["efficiency"]), int(sums["quality"])]
	machine_recipe_btn.text = "配方：%s" % (GameState.machine_recipe_name(recipe) if not recipe.is_empty() else "无")
	machine_recipe_btn.disabled = m.get("recipes", []).size() <= 1
	var has_grid_stock: bool = not GameState.container_def(selected_machine_id).is_empty() and String(GameState.container_def(selected_machine_id).get("kind", "")) == "grid"
	machine_recipe_btn.visible = not has_grid_stock
	machine_stock_grid_btn.visible = has_grid_stock
	if has_grid_stock:
		machine_stock_grid_btn.text = "库存网格 %d/%d" % [GameState._stock_items(selected_machine_id).size(), GameState.machine_stock_limit(selected_machine_id)]
	for i in range(temp_buttons.size()):
		temp_buttons[i].modulate = Color(1.25, 1.12, 0.72) if (i + 1) == lvl else Color.WHITE
	machine_power_label.text = "电力 %d/%d" % [GameState.power, GameState.max_power]
	machine_start_btn.disabled = recipe.is_empty() or dur <= 0 or fault != "" or bool(m.get("passive", false))
	for j in GameState.machine_jobs:
		if String(j.get("machine_id", "")) == selected_machine_id:
			machine_start_btn.disabled = true
	if machine_harvest_btn:
		var ready := not growth_job.is_empty() and bool(growth_job.get("ready", false))
		machine_harvest_btn.disabled = not ready
		machine_harvest_btn.visible = selected_machine_id in ["hydroponic", "ras"]
		if not growth_job.is_empty():
			if ready:
				machine_status_label.text = "作物可收获（剩余 %d 次）。" % int(growth_job.get("harvests_left", 0))
			else:
				machine_status_label.text = "作物生长中：%d 夜。" % int(growth_job.get("remaining", 0))
	if machine_repair_btn:
		machine_repair_btn.text = "维修 %d₵" % GameState.machine_repair_cost(selected_machine_id)
		machine_repair_btn.disabled = dur >= 100 and fault == ""
	if machine_aux_btn:
		machine_aux_btn.visible = not sp.is_empty() and kind not in ["core"] and recipe.is_empty()
		machine_aux_btn.text = "停用" if active else "启用"
		machine_aux_btn.disabled = sp.is_empty() or dur <= 0 or fault != ""
	if machine_stock_btn:
		machine_stock_btn.visible = kind in ["vending", "fountain", "wine", "fridge", "cage", "feed", "butcher"]
		machine_stock_btn.disabled = not active
	if machine_take_btn:
		machine_take_btn.visible = kind in ["vending", "fountain", "wine", "fridge", "cage", "feed", "butcher"]
		machine_take_btn.disabled = GameState.machine_stock_summary(selected_machine_id).is_empty()
	var io := GameState.machine_io_spec(selected_machine_id)
	if machine_io_in_btn:
		var has_io_in := io.get("input", {}) is Dictionary and not (io.get("input", {}) as Dictionary).is_empty()
		machine_io_in_btn.visible = has_io_in
		machine_io_in_btn.disabled = dur <= 0 or fault != ""
		if has_io_in:
			var in_box := GameState.machine_io_container(selected_machine_id, "input")
			var in_spec := GameState.container_spec(in_box)
			var in_slots: Array = in_spec.get("slots", [])
			var in_cap: int = in_slots.size() if String(in_spec.get("kind", "")) == "slots" else int(in_spec.get("width", 0)) * int(in_spec.get("height", 0))
			machine_io_in_btn.text = "输入网格 %d/%d" % [in_box.get("children", []).size(), in_cap]
	if machine_io_out_btn:
		var has_io_out := io.get("output", {}) is Dictionary and not (io.get("output", {}) as Dictionary).is_empty()
		machine_io_out_btn.visible = has_io_out
		machine_io_out_btn.disabled = dur <= 0 or fault != ""
		if has_io_out:
			var out_box := GameState.machine_io_container(selected_machine_id, "output")
			var out_spec := GameState.container_spec(out_box)
			var out_slots: Array = out_spec.get("slots", [])
			var out_cap: int = out_slots.size() if String(out_spec.get("kind", "")) == "slots" else int(out_spec.get("width", 0)) * int(out_spec.get("height", 0))
			machine_io_out_btn.text = "输出网格 %d/%d" % [out_box.get("children", []).size(), out_cap]
	if machine_special_btn:
		var action_kinds := ["bargain", "vending", "fountain", "reactor", "cage", "bottle_printer", "fridge", "ras", "storage_preset", "music", "mark", "purify", "distill", "heat", "butcher"]
		machine_special_btn.visible = kind in action_kinds
		match kind:
			"bargain": machine_special_btn.text = "启用 Deal Maker"
			"vending", "fountain": machine_special_btn.text = "收取/升级"
			"reactor", "cage": machine_special_btn.text = "维修/升级"
			"bottle_printer", "fridge", "ras": machine_special_btn.text = "升级"
			"storage_preset": machine_special_btn.text = "货架预设"
			"music": machine_special_btn.text = "播放/停止"
			"mark": machine_special_btn.text = "标记"
			"purify": machine_special_btn.text = "净化"
			"distill": machine_special_btn.text = "蒸馏"
			"heat": machine_special_btn.text = "加热"
			"butcher": machine_special_btn.text = "屠宰"
			_: machine_special_btn.text = "特殊操作"
		machine_special_btn.disabled = dur <= 0 or fault != "" or (kind in ["mark", "purify", "distill", "heat", "butcher"] and not active)
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
		if GameState.night_log.is_empty():
			machine_jobs_label.text = "无"
		else:
			var logs: Array = GameState.night_log.slice(maxi(0, GameState.night_log.size() - 4))
			machine_jobs_label.text = "昨夜：\n" + "\n".join(logs)
		return
	var text := ""
	for j in GameState.machine_jobs:
		if bool(j.get("growth", false)):
			if bool(j.get("ready", false)):
				text += "· %s  可收获（剩余 %d 次）
" % [j.get("name", ""), int(j.get("harvests_left", 0))]
			else:
				text += "· %s  生长中 %d 夜
" % [j.get("name", ""), int(j.get("remaining", 0))]
		else:
			text += "· %s  剩余 %d 夜
" % [j.get("name", ""), int(j.get("remaining", 0))]
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
	if quality < 0.0 and selected_machine_id in ["printer", "chem_finisher", "plant_dna_manipulator"]:
		var check := GameState.start_machine(selected_machine_id, 0.0, true)
		if not bool(check.get("ok", false)):
			machine_status_label.text = String(check.get("text", ""))
			_play_sfx("fail")
			return
		match selected_machine_id:
			"printer": _open_printer_minigame()
			"chem_finisher": _open_mix_minigame()
			"plant_dna_manipulator": _open_dna_minigame()
		return
	var res := GameState.start_machine(selected_machine_id, maxf(quality, 0.0))
	if bool(res.get("ok", false)):
		_play_sfx("machine")
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))

func _build_select_layer() -> void:
	select_layer = Control.new()
	select_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	select_layer.visible = false
	select_layer.z_index = 178
	select_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(select_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.84)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	select_layer.add_child(dim)
	var panel := _panel(select_layer, Vector2(420, 80), Vector2(1500, 920), C_PANEL, C_CYAN, 3)
	select_title = _label(panel, "", Vector2(30, 18), Vector2(1200, 48), 34, C_AMBER)
	_button(panel, "关闭", Vector2(1320, 14), Vector2(120, 48), C_MUTED, _close_select)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(24, 88)
	scroll.size = Vector2(1450, 790)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.add_theme_stylebox_override("panel", _style(C_PANEL2, C_LINE, 1))
	panel.add_child(scroll)
	select_list = VBoxContainer.new()
	select_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select_list.add_theme_constant_override("separation", 8)
	scroll.add_child(select_list)

func _open_select(title: String, items: Array, cb: Callable) -> void:
	move_child(select_layer, get_child_count() - 1)
	select_title.text = title
	select_cb = cb
	_clear_children(select_list)
	for item in items:
		var label := String(item.get("label", item.get("id", "")))
		var b := _button(select_list, label, Vector2.ZERO, Vector2(1420, 56), C_TEXT, _choose_select.bind(String(item.get("id", ""))))
		b.custom_minimum_size = Vector2(1420, 56)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 20)
	select_layer.visible = true
	_play_sfx("page")

func _choose_select(id: String) -> void:
	select_layer.visible = false
	if select_cb.is_valid():
		select_cb.call(id)

func _close_select() -> void:
	select_layer.visible = false
	_play_sfx("soft")

func _open_machine_stock_grid() -> void:
	var parent := GameState.machine_container(selected_machine_id)
	if parent.is_empty():
		_toast("这台机器没有库存网格。")
		return
	_open_container(int(parent.get("uid", -1)))

func _open_recipe_select() -> void:
	var m := GameState.machine_def(selected_machine_id)
	var items: Array = []
	var lv := int(GameState.machine_upgrades.get(selected_machine_id, 0))
	for r in m.get("recipes", []):
		var lock := int(r.get("unlock_upgrade", 0))
		var suffix := ""
		if lock > lv:
			suffix += "（需升级 %d 级）" % lock
		for req in r.get("requires_items", []):
			if GameState.inventory_count(String(req)) < 1:
				suffix += "（缺芯片：%s）" % String(GameState.get_item_def(String(req)).get("name", req))
		var cyc := GameState.machine_recipe_cycles(selected_machine_id, r)
		var pw := GameState.machine_recipe_power(selected_machine_id, r)
		items.append({"id": r.get("id", ""), "label": "%s · %d 夜 · %d 电%s" % [GameState.machine_recipe_name(r), cyc, pw, suffix]})
	if items.is_empty():
		_toast("这台机器没有可选配方。")
		return
	_open_select("选择配方 · %s" % m.get("name", ""), items, _choose_recipe)

func _choose_recipe(id: String) -> void:
	GameState.set_machine_recipe(selected_machine_id, id)
	_refresh_machine_panel()

func _open_module_select() -> void:
	var m := GameState.machine_def(selected_machine_id)
	var allowed: Array = m.get("module_types", [])
	var installed := GameState.machine_module_ids(selected_machine_id)
	var items: Array = []
	items.append({"id": "__clear__", "label": "清空全部模块"})
	for md in GameState.modules_def:
		if not allowed.has(String(md.get("type", ""))):
			continue
		var mark := " · 已安装" if installed.has(String(md.get("id", ""))) else ""
		items.append({"id": md.get("id", ""), "label": "%s · 性能%+d / 效率%+d / 品质%+d%s" % [md.get("name", md.get("id", "")), int(md.get("performance", 0)), int(md.get("efficiency", 0)), int(md.get("quality", 0)), mark]})
	if items.size() <= 1:
		_toast("这台机器没有可用模块。")
		return
	_open_select("安装模块 · %s（槽位 %d/%d）" % [m.get("name", ""), installed.size(), int(m.get("module_slots", 1))], items, _choose_module)

func _choose_module(id: String) -> void:
	if id == "__clear__":
		GameState.clear_modules(selected_machine_id)
	elif id != "":
		_play_sfx("battery_insert")
		GameState.install_module(selected_machine_id, id)
	_refresh_machine_panel()

func _toggle_machine_active() -> void:
	var res := GameState.machine_toggle_active(selected_machine_id)
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))

func _open_machine_io_input() -> void:
	_open_machine_io("input")

func _open_machine_io_output() -> void:
	_open_machine_io("output")

func _open_machine_io(side: String) -> void:
	var box := GameState.machine_io_container(selected_machine_id, side)
	if box.is_empty():
		_toast("这台机器没有%s网格。" % ("输入" if side == "input" else "输出"))
		return
	_open_container(int(box.get("uid", -1)))

func _machine_special_pressed() -> void:
	var res := GameState.machine_special_action(selected_machine_id)
	if res.has("select_options"):
		var items: Array = []
		for o in res.get("select_options", []):
			items.append({"id": o.get("id", ""), "label": o.get("label", o.get("id", ""))})
		_open_select(String(res.get("text", "选择操作")), items, _machine_special_choice.bind(selected_machine_id))
		return
	if res.has("select"):
		_open_service_select(String(res.get("select", "")))
		return
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))

func _machine_special_choice(id: String, mid: String) -> void:
	var res := GameState.machine_special_choice(mid, id)
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))

func _open_service_select(kind: String) -> void:
	var items: Array = []
	for it in GameState.inventory:
		var did := String(it.get("def_id", ""))
		var def := GameState.get_item_def(did)
		var tags: Array = def.get("tags", [])
		var ok := false
		if kind in ["purify", "distill", "heat"]:
			ok = GameState.is_water_container_item(did)
		elif kind in ["mark", "butcher"]:
			ok = did == "rat" or tags.has("animal_item_tag") or tags.has("animal")
		if ok:
			items.append({"id": str(it.get("uid", 0)), "label": "%s · 品相 %d%%" % [String(def.get("name", did)), int(it.get("condition", 100))]})
	if items.is_empty():
		_toast("背包里没有可处理的物品。")
		return
	_open_select("选择物品 · %s" % GameState.machine_def(selected_machine_id).get("name", ""), items, _service_choice.bind(selected_machine_id, kind))

func _service_choice(uid_text: String, mid: String, kind: String) -> void:
	var res := GameState.apply_item_service(mid, int(uid_text))
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))

func _open_machine_stock() -> void:
	var items: Array = []
	for it in GameState.inventory:
		if GameState._eligible_for_stock(selected_machine_id, it):
			var did := String(it.get("def_id", ""))
			var def := GameState.get_item_def(did)
			items.append({"id": str(it.get("uid", 0)), "label": "%s · 品相 %d%% · 估值 %d₵" % [String(def.get("name", did)), int(it.get("condition", 100)), GameState.effective_value(it)]})
	if items.is_empty():
		_toast("背包里没有可存入的物品。")
		return
	_open_select("存入 · %s" % GameState.machine_def(selected_machine_id).get("name", ""), items, _stock_choice)

func _stock_choice(uid_text: String) -> void:
	var res := GameState.machine_stock_add(selected_machine_id, int(uid_text))
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))

func _take_machine_stock() -> void:
	var res := GameState.machine_stock_take_all(selected_machine_id)
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	_refresh_machine_panel()
	machine_status_label.text = String(res.get("text", ""))
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
	_update_walkers(delta)
	if machine_layer == null or not machine_layer.visible:
		return
	machine_ui_timer += delta
	if machine_ui_timer >= 0.25:
		machine_ui_timer = 0.0
		_refresh_machine_jobs()
		machine_power_label.text = "电力 %d/%d" % [GameState.power, GameState.max_power]

func _walker_sprite(frame: int) -> Texture2D:
	if walker_textures.is_empty():
		for i in range(8):
			var path := WALKER_TEX % i
			walker_textures.append(load(path) if ResourceLoader.exists(path) else null)
	if walker_textures.is_empty():
		return null
	return walker_textures[frame % walker_textures.size()]

func _walker_rate_multiplier() -> float:
	if GameState.phase != "customer" and GameState.phase != "open":
		return 0.0
	var n := GameState.customers_today.size()
	if n <= 0:
		return 0.0
	if n <= 2:
		return 0.25
	return 1.0

func _spawn_walker(far: bool) -> void:
	if walker_layer == null or walkers.size() >= 20:
		return
	var tex := _walker_sprite(0)
	if tex == null:
		return
	var rect := TextureRect.new()
	rect.texture = tex
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var dir := 1 if GameState.rng.randf() > 0.5 else -1
	var scale := 0.34 if far else 0.46
	var h := 273.0 * scale
	var x := 884.0 if far else 832.0
	if dir < 0:
		x = 1086.0 if far else 1134.0
	var base_y := 338.0 if far else 356.0
	rect.size = Vector2(143.0 * scale, h)
	rect.position = Vector2(x, base_y - h)
	rect.flip_h = dir < 0
	rect.modulate = Color(0.18, 0.17, 0.23, 0.85) if far else Color(0.24, 0.22, 0.3, 0.95)
	walker_layer.add_child(rect)
	walkers.append({
		"rect": rect,
		"dir": dir,
		"speed": (20.0 if far else 30.0) * GameState.rng.randf_range(0.85, 1.15),
		"far": far,
		"frame_t": 0.0,
		"x": x,
		"y": base_y - h,
	})

func _update_walkers(delta: float) -> void:
	if walker_layer == null:
		return
	var mult := _walker_rate_multiplier()
	if mult > 0.0:
		walker_far_timer -= delta * mult
		walker_mid_timer -= delta * mult
	if walker_far_timer <= 0.0 and mult > 0.0:
		walker_far_timer = GameState.rng.randf_range(2.0, 5.0)
		_spawn_walker(true)
	if walker_mid_timer <= 0.0 and mult > 0.0:
		walker_mid_timer = GameState.rng.randf_range(2.0, 5.0)
		_spawn_walker(false)
	if walkers.is_empty():
		return
	var alive: Array = []
	for w in walkers:
		var rect: TextureRect = w.get("rect")
		if rect == null or not is_instance_valid(rect):
			continue
		var x := float(w.get("x", 0.0)) + int(w.get("dir", 1)) * float(w.get("speed", 20.0)) * delta
		var frame_t := float(w.get("frame_t", 0.0)) + delta
		rect.texture = _walker_sprite(int(frame_t * 10.0))
		rect.position = Vector2(x, float(w.get("y", 0.0)))
		var far := bool(w.get("far", true))
		var out := (x < 783.0 or x > 1187.0) if far else (x < 680.0 or x > 1290.0)
		if out:
			rect.queue_free()
		else:
			w["x"] = x
			w["frame_t"] = frame_t
			alive.append(w)
	walkers = alive

func _open_labeler_select() -> void:
	var items: Array = []
	for it in GameState.inventory:
		var did := String(it.get("def_id", ""))
		if did in ["labeler", "labeler_blue"]:
			continue
		items.append({"id": str(int(it.get("uid", -1))), "label": GameState.item_display_name(it)})
	if items.is_empty():
		_toast("没有可贴标的物品。")
		return
	_open_select("贴标：选择物品", items, _labeler_pick)

func _labeler_pick(id: String) -> void:
	var uid := int(id)
	_open_input("贴标签", "输入新的物品标签（最多 24 字）", func(text: String) -> void:
		var res := GameState.relabel_item(uid, text)
		_refresh()
		_toast(String(res.get("text", "")))
	)

func _map_locations() -> Array:
	return [
		{"id": "shop", "name": "当铺", "tag": "当前位置", "body": "你的店铺。顾客在门口排队，展示柜与机器都在这里。"},
		{"id": "blackmarket", "name": "黑市", "tag": "声望 %+d" % int(GameState.rep.get("blackmarket", 0)), "body": "销赃、违禁品与黑市联系人。势力值 %+d。" % int(GameState.faction_power.get("bm", 0))},
		{"id": "security", "name": "治安部", "tag": "声望 %+d" % int(GameState.rep.get("security", 0)), "body": "检查、许可证与通缉。势力值 %+d，内乱 %+d。" % [int(GameState.faction_power.get("sec", 0)), int(GameState.faction_power.get("civil_unrest", 0))]},
		{"id": "clinic", "name": "医疗站", "tag": "生命服务", "body": "治疗伤口、购买注射剂与器官。"},
		{"id": "commissary", "name": "补给站", "tag": "兑换券 %d" % int(GameState.commissary_credit), "body": "用食品券兑换生活物资。"},
		{"id": "dump", "name": "垃圾场", "tag": "拾荒地点", "body": "Juan 的探险目的地，也是夜间的拾荒区域。"},
	]

func _notebook_entries() -> Array:
	var notes: Array = []
	var sold := int(GameState.daily.get("sold", 0))
	var inspected := int(GameState.daily.get("inspected", 0))
	notes.append({"id": "daily", "title": "每日目标", "body": "卖出 3 件商品：%d/3
鉴定 1 件物品：%d/1
房租 %d₵，%d 天后到期
欠款 %d₵，%d 天后到期" % [sold, inspected, GameState.rent, GameState.rent_due, GameState.loan, GameState.loan_due]})
	if not GameState.commissions.is_empty():
		var lines: Array = []
		for c in GameState.commissions:
			lines.append("%s ×%d → %d₵" % [GameState.get_item_def(String(c.get("item_id", ""))).get("name", c.get("item_id", "")), int(c.get("count", 1)), int(c.get("reward", 0))])
		notes.append({"id": "requests", "title": "派系委托", "body": "
".join(lines)})
	if not GameState.procurement_orders.is_empty():
		var plines: Array = []
		for o in GameState.procurement_orders:
			plines.append("%s ×%d，第 %d 天前交货" % [GameState.get_item_def(String(o.get("item_id", ""))).get("name", ""), int(o.get("count", 0)), int(o.get("due_day", 0))])
		notes.append({"id": "procurement", "title": "采购订单", "body": "
".join(plines)})
	if not GameState.active_operations.is_empty():
		var olines: Array = []
		for op in GameState.active_operations:
			olines.append("%s（至第 %d 天）" % [GameState.operation_label(op), int(op.get("until", 0))])
		notes.append({"id": "operations", "title": "派系行动", "body": "
".join(olines)})
	if not GameState.pending_story.is_empty():
		notes.append({"id": "story", "title": "剧情线索", "body": "当前剧情：%s" % GameState.pending_story})
	notes.append({"id": "tips", "title": "生存提示", "body": "口渴 %d/1000，伤口 %d/10。
今日夜间事件：%s" % [GameState.thirst, GameState.wounds, String(GameState.afterhour_mods.get("name", "无"))]})
	return notes

func _open_options() -> void:
	var fs := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_show_modal("选项", "音效：%s
全屏：%s
语言：简体中文（原版 12 语种未移植）
存档槽位：3 个" % ["开启" if audio_enabled else "关闭", "是" if fs else "否"], [
		{"label": "切换音效", "cb": _on_audio_toggle},
		{"label": "切换全屏", "cb": _toggle_fullscreen},
		{"label": "存档", "cb": _on_save},
		{"label": "读档", "cb": _on_load},
	])

func _toggle_fullscreen() -> void:
	var fs := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fs else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_open_options()

func _open_status() -> void:
	_open_info_tab("status")

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
				var owned := GameState.upgrade_owned(uid)
				var state_text := "已拥有"
				if uid == "EVIDENCE_REMOVAL":
					var cd := GameState.upgrade_cooldown(uid)
					state_text = ("冷却 %d 天 · " % cd if cd > 0 else "") + "%d₵" % GameState.upgrade_cost(uid)
				elif not owned:
					state_text = "%d₵" % GameState.upgrade_cost(uid)
				var text := "%s · %s" % [u.get("name", uid), state_text]
				_add_info_button(text, uid)
		"professions":
			for p in GameState.professions:
				_add_info_button(String(p.get("name", p.get("id", ""))), String(p.get("id", "")))
		"appraisal":
			_add_info_button("鉴定师等级 · " + GameState.appraisal_rank_name(), "rank")
			for t in GameState.appraisal_item_defs:
				var unlocked := int(t.get("unlock_rank", 0)) <= GameState.appraiser_level
				_add_info_button("%s · %s" % [t.get("name", t.get("id", "")), "已解锁" if unlocked else "需 %d 级" % int(t.get("unlock_rank", 0))], String(t.get("id", "")))
			_add_info_button("晋升申请", "promotion")
		"factions":
			for f in GameState.factions:
				var fid := String(f.get("id", ""))
				_add_info_button("%s  %+d" % [f.get("name", fid), int(GameState.rep.get(fid, 0))], fid)
		"perks":
			for p in GameState.starting_perks:
				var chosen := GameState.starting_perk_ids.has(String(p.get("id", "")))
				_add_info_button("%s%s" % [p.get("name", p.get("id", "")), " · 已选" if chosen else ""], String(p.get("id", "")))
		"rep_perks":
			for p in GameState.rep_perk_defs:
				var pid := String(p.get("id", ""))
				var pname := GameState.loc("RepPerkTable", "rep_perk_%s_name" % pid, pid)
				_add_info_button("%s %s" % ["●" if GameState.rep_perk_unlocked(pid) else "○", pname], pid)
		"customers":
			for c in GameState.customer_defs:
				var cid := String(c.get("id", ""))
				_add_info_button("%s · %s" % [c.get("name", cid), _faction_short(String(c.get("faction", "")))], cid)
		"phone":
			for c in GameState.commissions:
				var d := GameState.get_item_def(String(c.get("item_id", "")))
				_add_info_button("%s x%d · %d₵" % [d.get("name", c.get("item_id", "")), int(c.get("count", 1)), int(c.get("reward", 0))], String(c.get("id", "")))
		"security":
			_add_info_button("案件档案 · 证据 %d/100" % GameState.sec_evidence, "case")
		"wanted":
			for w in GameState.wanted:
				var wid := String(w.get("id", ""))
				var done := GameState.wanted_defeated.has(wid)
				_add_info_button("%s · %d₵%s" % [w.get("name", wid), int(w.get("reward", 0)), " · 已击败" if done else ""], wid)
		"archive":
			archive_groups = GameState.dialogue_archive
			for g in archive_groups:
				_add_info_button("%s · %d" % [g.get("name", g.get("id", "")), g.get("entries", []).size()], String(g.get("id", "")))
		"status":
			for it in GameState.inventory:
				if GameState.can_use_consumable(it):
					_add_info_button("%s ×%d" % [GameState.item_display_name(it), int(it.get("unit_count", 1))], str(int(it.get("uid", -1))))
		"achievements":
			for a in GameState.achievement_defs:
				var aid := String(a.get("id", ""))
				var got := GameState.achievements_unlocked.has(aid)
				_add_info_button("%s %s" % ["●" if got else "○", String(a.get("name", aid))], aid)
		"map":
			for loc in _map_locations():
				_add_info_button("%s · %s" % [String(loc.get("name", "")), String(loc.get("tag", ""))], String(loc.get("id", "")))
		"notebook":
			if not GameState.can_read_guides():
				_add_info_button("文盲 · 无法阅读指南", "illiterate")
			else:
				for note in _notebook_entries():
					_add_info_button(String(note.get("title", "")), String(note.get("id", "")))
		"requests":
			for req in GameState.store_requests:
				_add_info_button("%s · %s×%d · %d₵" % [_faction_short(String(req.get("faction", ""))), GameState.item_display_name({"def_id": String(req.get("item_id", ""))}), int(req.get("count", 1)), int(req.get("credits", 0))], String(req.get("id", "")))
		"news":
			for i in range(news_archive.size() - 1, -1, -1):
				var ni: Dictionary = news_archive[i]
				_add_info_button("%s · %s" % [String(ni.get("title", "新闻")), String(ni.get("day", ""))], str(i))
		"stats":
			for key in GameState.run_stats.keys():
				var val = GameState.run_stats[key]
				if val is Dictionary:
					continue
				_add_info_button(_stat_label(String(key)), String(key))
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
	if info_icon:
		info_icon.texture = null
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
			var uicon := "res://assets_private/ui_icons/" + info_selected_id + ".png"
			if ResourceLoader.exists(uicon):
				info_icon.texture = load(uicon)
			var avail := GameState.upgrade_available(info_selected_id)
			var cost := int(avail.get("cost", 0))
			var udesc := String(u.get("desc", ""))
			if info_selected_id == "EVIDENCE_REMOVAL":
				udesc = udesc.replace("{0}", str(int(GameState.security_defs.get("evidence_removal", {}).get("cooldown_days", 14))))
			elif info_selected_id.begins_with("GUN_PERMIT"):
				for p in GameState.security_defs.get("permits", []):
					if String(p.get("id", "")) == info_selected_id:
						udesc = udesc.replace("{0}", str(int(p.get("threshold", 0))))
			udesc = udesc.replace("{1}", "1")
			info_meta.text = "价格 %d₵" % cost
			var status := String(avail.get("reason", ""))
			var extra := "购买后立即生效，状态随存档保存。"
			if info_selected_id.begins_with("GUN_PERMIT"):
				extra = "购买后需达到对应治安声望才会在次日签发；声望跌破门槛会被吊销。"
			elif info_selected_id == "EVIDENCE_REMOVAL":
				extra = "可重复购买；每次购买后价格 +%d₵，冷却 %d 天。" % [int(GameState.security_defs.get("evidence_removal", {}).get("cost_step", 100)), int(GameState.security_defs.get("evidence_removal", {}).get("cooldown_days", 14))]
			info_body.text = udesc + "

" + extra + "

状态：" + status
			info_action.visible = true
			info_action.text = ("清除证据 %d₵" if info_selected_id == "EVIDENCE_REMOVAL" else "购买 %d₵") % cost
			info_action.disabled = not bool(avail.get("ok", false))
			info_status.text = status
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
		"appraisal":
			var r: Dictionary = GameState.appraisal_rank_data()
			if info_selected_id == "rank":
				info_name.text = "鉴定师等级 · " + GameState.appraisal_rank_name()
				info_meta.text = "底费 %d₵ · 吸引率 %d%% · 晋升进度 %.0f/%.0f" % [int(r.get("base_fee", 0)), GameState.appraisal_attraction_chance(), GameState.appraisal_progress, float(r.get("progress_to_promote", 0))]
				var pcts: Array = r.get("fee_percent", [])
				var body := "可接受评级与抽成：\n"
				for i in range(pcts.size()):
					body += "  %s：%s\n" % [GameState._appraisal_grade_name(i + 1), ("拒绝" if int(pcts[i]) <= 0 else "%d%%" % int(pcts[i]))]
				body += "\n证书："
				for c in GameState.inventory:
					if String(c.get("def_id", "")).begins_with("cert"):
						body += GameState.item_display_name(c) + " "
				info_body.text = body
			elif info_selected_id == "promotion":
				var cost := GameState.promotion_cost()
				info_name.text = "晋升申请"
				info_meta.text = "下一等级花费：%d₵" % cost
				info_body.text = "当前进度：%.0f / %.0f\n达到阈值后可申请晋升；拒绝可延期 7 天。\n" % [GameState.appraisal_progress, float(r.get("progress_to_promote", 0))]
				info_action.visible = true
				info_action.text = "晋升 %d₵" % cost
				info_action.disabled = GameState.appraiser_level >= 3 or GameState.appraisal_progress < float(r.get("progress_to_promote", 0)) or GameState.cash < cost
				info_status.text = "已是最高等级" if GameState.appraiser_level >= 3 else ("进度不足" if GameState.appraisal_progress < float(r.get("progress_to_promote", 0)) else ("现金不足" if GameState.cash < cost else "可晋升"))
			else:
				var t := GameState._appraisal_type_def(info_selected_id)
				if t.is_empty():
					return
				info_name.text = String(t.get("name", ""))
				info_meta.text = "解锁等级 %d · 基础价值 %d₵" % [int(t.get("unlock_rank", 0)), int(t.get("base_value", 0))]
				info_body.text = "可估价的物品：%s\n最高鉴定师等级可解锁全部三类。" % "、".join(t.get("item_ids", []))
		"factions":
			var f := GameState.faction_def(info_selected_id)
			if f.is_empty():
				return
			var v := int(GameState.rep.get(info_selected_id, 0))
			var tier := GameState.faction_tier(info_selected_id)
			info_name.text = String(f.get("name", ""))
			var ficon := "res://assets_private/ui_icons/" + info_selected_id.to_upper() + ".png"
			if ResourceLoader.exists(ficon):
				info_icon.texture = load(ficon)
			info_meta.text = "声望 %+d · 已解锁 %d/%d 档" % [v, tier, f.get("perks", []).size()]
			var body := ""
			for perk in f.get("perks", []):
				var unlocked := v >= int(perk.get("threshold", 999))
				body += "%s %d · %s — %s
" % ["[已解锁]" if unlocked else "[未解锁]", int(perk.get("threshold", 0)), perk.get("name", ""), perk.get("desc", "")]
			var pkeys := {"security": "sec", "blackmarket": "bm", "rev": "rev"}
			if pkeys.has(info_selected_id):
				body += "
势力值：%+d" % int(GameState.faction_power.get(String(pkeys[info_selected_id]), 0))
			body += "
内乱：%+d" % int(GameState.faction_power.get("civil_unrest", 0))
			if not GameState.active_operations.is_empty():
				var opnames: Array = []
				for op in GameState.active_operations:
					opnames.append(GameState.operation_label(op))
				body += "
进行中：" + "、".join(opnames)
			info_body.text = body
		"perks":
			var p := GameState.starting_perk_def(info_selected_id)
			if p.is_empty():
				return
			info_name.text = String(p.get("name", info_selected_id))
			info_meta.text = "开局天赋 · %s" % ("已选择" if GameState.starting_perk_chosen else "可选择")
			info_body.text = String(p.get("desc", ""))
			info_action.visible = true
			info_action.text = "选择天赋"
			info_action.disabled = GameState.starting_perk_chosen
			info_status.text = "本局已选择：%s" % GameState.starting_perk_def(GameState.starting_perk_id).get("name", GameState.starting_perk_id) if GameState.starting_perk_chosen else "选择后立即生效"
		"rep_perks":
			var rp := GameState.rep_perk_def(info_selected_id)
			if rp.is_empty():
				return
			var rpname := GameState.loc("RepPerkTable", "rep_perk_%s_name" % info_selected_id, info_selected_id)
			var rpdesc := GameState.loc("RepPerkTable", "rep_perk_%s_desc" % info_selected_id, "")
			info_name.text = rpname
			info_meta.text = "%s %d · %s" % ["≤" if int(rp.get("type", 1)) < 0 else "≥", int(rp.get("threshold", 0)), "已解锁" if GameState.rep_perk_unlocked(info_selected_id) else "未解锁"]
			info_body.text = rpdesc
			info_status.text = "声望特权"
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
		"security":
			info_name.text = "治安部档案"
			info_meta.text = "证据 %d/100 · 预计判决：%s · 案件探员：%s" % [GameState.sec_evidence, GameState.sec_projected_sentence(), GameState.sec_case_officer()]
			var crime_lines: Array = []
			for cid in GameState.sec_crimes.keys():
				if int(GameState.sec_crimes[cid]) > 0:
					crime_lines.append("%s：%d₵" % [GameState.sec_crime_name(String(cid)), int(GameState.sec_crimes[cid])])
			var body := "总犯罪值：%d₵
最大案件：%s
贿赂参考：%d₵" % [GameState.sec_total_crime(), GameState.sec_biggest_crime(), GameState.sec_bribe_amount()]
			body += "
" + ("
".join(crime_lines) if not crime_lines.is_empty() else "目前没有犯罪记录。")
			var neg_perks: Array = []
			var pos_perks: Array = []
			for pid in GameState.security_defs.get("reputation_perks", {}).keys():
				var pd: Dictionary = GameState.security_defs["reputation_perks"][pid]
				var threshold := int(pd.get("threshold", 0))
				var pname := GameState.loc("RepPerkTable", "rep_perk_%s_name" % pid, String(pid))
				var mark := "●" if GameState.sec_perk_unlocked(String(pid)) else "○"
				if int(pd.get("type", 1)) < 0:
					neg_perks.append("%s%s≤%d" % [mark, pname, threshold])
				else:
					pos_perks.append("%s%s≥%d" % [mark, pname, threshold])
			body += "
治安特权（●已解锁 ○未解锁）：
负面：" + "、".join(neg_perks) + "
正面：" + "、".join(pos_perks)
			var permit_text := "无"
			if not GameState.active_permits.is_empty():
				var plist: Array = []
				for p in GameState.active_permits:
					plist.append("%s级" % str(int(p.get("level", 0))))
				permit_text = "、".join(plist)
			body += "
武器许可证：%s" % permit_text
			info_body.text = body
			info_status.text = "治安声望 %+d" % int(GameState.rep.get("security", 0))
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
		"status":
			var lines: Array = []
			lines.append("口渴：%d/%d（%s）" % [GameState.thirst, GameState.thirst_max, _thirst_label()])
			lines.append("伤口：%d/10（%s）" % [GameState.wounds, "稳定" if GameState.wound_stable else "未处理"])
			var add_lines: Array = []
			var addiction_names := {"nicotine": "尼古丁", "alcohol": "酒精", "narcotic": "麻醉品"}
			for k in ["nicotine", "alcohol", "narcotic"]:
				if bool(GameState.perk_flags.get("addiction_" + k, false)):
					add_lines.append("%s 第 %d 天" % [addiction_names[k], int(GameState.addiction_days.get(k, 0))])
			lines.append("成瘾：" + ("、".join(add_lines) if not add_lines.is_empty() else "无"))
			lines.append("日历：第 %d 天 · 周%s · 房租 %d 天后 · 欠款 %d 天后" % [GameState.day, _weekday(GameState.day), GameState.rent_due, GameState.loan_due])
			if not GameState.afterhour_today.is_empty():
				lines.append("今日夜间事件：" + String(GameState.afterhour_mods.get("name", GameState.afterhour_today)))
			if not GameState.active_operations.is_empty():
				var opn: Array = []
				for op in GameState.active_operations:
					opn.append(GameState.operation_label(op))
				lines.append("派系行动：" + "、".join(opn))
			if not GameState.night_log.is_empty():
				lines.append("日志：" + String(GameState.night_log[-1]))
			if bool(GameState.perk_flags.get("sentinel", false)):
				lines.append("哨兵注射剂：%d 天 · 负荷 %d/20" % [GameState.sentinel_days, GameState.sentinel_pool])
			info_name.text = "身体状态"
			info_meta.text = "价格惩罚 %+d%%" % int(GameState.addiction_price_mod() * 100.0)
			var body := "
".join(lines)
			if info_selected_id != "":
				var it := GameState.find_item(int(info_selected_id))
				if not it.is_empty():
					body += "

选中：" + GameState.item_display_name(it)
					info_action.visible = true
					info_action.text = "使用"
					info_action.disabled = false
			info_body.text = body
		"achievements":
			var adef := {}
			for a in GameState.achievement_defs:
				if String(a.get("id", "")) == info_selected_id:
					adef = a
					break
			info_name.text = String(adef.get("name", info_selected_id))
			var got := GameState.achievements_unlocked.has(info_selected_id)
			info_meta.text = "● 已解锁 · 第 %d 天" % int(GameState.achievements_unlocked.get(info_selected_id, 0)) if got else "○ 未解锁"
			info_body.text = String(adef.get("desc", ""))
			info_status.text = "已解锁 %d/%d" % [GameState.achievements_unlocked.size(), GameState.achievement_defs.size()]
		"map":
			var loc := {}
			for l in _map_locations():
				if String(l.get("id", "")) == info_selected_id:
					loc = l
					break
			info_name.text = String(loc.get("name", ""))
			info_meta.text = String(loc.get("tag", ""))
			info_body.text = String(loc.get("body", ""))
		"notebook":
			if not GameState.can_read_guides():
				info_name.text = "文盲"
				info_meta.text = "本局笔记 · 第 %d 天" % GameState.day
				info_body.text = "你不识字，无法阅读任何指南或笔记。"
				return
			var note := {}
			for n in _notebook_entries():
				if String(n.get("id", "")) == info_selected_id:
					note = n
					break
			info_name.text = String(note.get("title", ""))
			info_meta.text = "本局笔记 · 第 %d 天" % GameState.day
			info_body.text = String(note.get("body", ""))
		"requests":
			var req := {}
			for r in GameState.store_requests:
				if String(r.get("id", "")) == info_selected_id:
					req = r
					break
			if req.is_empty():
				info_name.text = "没有请求"
				return
			var item_name := String(req.get("custom_name", ""))
			if item_name == "":
				item_name = GameState.item_display_name({"def_id": String(req.get("item_id", ""))})
			info_name.text = "商店请求 · %s" % _faction_short(String(req.get("faction", "")))
			info_meta.text = "%s ×%d · 剩余 %d 天" % [item_name, int(req.get("count", 1)), int(req.get("days", 0))]
			info_body.text = "报酬：%d₵ + %s 声望 %+d
交付后物品从背包扣除。
当前持有：%d" % [int(req.get("credits", 0)), _faction_short(String(req.get("faction", ""))), int(req.get("rep", 0)), GameState.inventory_count(String(req.get("item_id", "")))]
			info_action.visible = true
			info_action.text = "交付"
			info_action.disabled = GameState.inventory_count(String(req.get("item_id", ""))) < int(req.get("count", 1))
			info_status.text = "可交付" if not info_action.disabled else "物品不足"
		"news":
			var nidx := int(info_selected_id)
			if nidx < 0 or nidx >= news_archive.size():
				return
			var news: Dictionary = news_archive[nidx]
			info_name.text = String(news.get("title", "新闻"))
			info_meta.text = "第 %s 天 · 站内新闻" % String(news.get("day", ""))
			info_body.text = String(news.get("text", ""))
		"stats":
			info_name.text = _stat_label(info_selected_id)
			info_meta.text = "本局运行统计"
			info_body.text = str(GameState.run_stats.get(info_selected_id, 0))
			info_status.text = "第 %d 天 · 净资产 %d₵" % [GameState.day, GameState.net_worth()]

func _thirst_label() -> String:
	if GameState.thirst <= 0:
		return "极度脱水"
	if GameState.thirst <= 150:
		return "脱水"
	if GameState.thirst <= 500:
		return "口渴"
	if GameState.thirst >= 800:
		return "水分充足"
	return "正常"

func _stat_label(key: String) -> String:
	var names := {
		"total_sales": "总销售额", "items_sold": "售出物品", "stock_spent": "进货支出",
		"customers_served": "接待顾客", "best_day_sales": "最佳单日销售", "best_day": "最佳单日",
		"rent_paid": "已付房租", "power_spent": "电力支出", "insurance_spent": "保险支出",
		"bribes": "贿赂支出", "inspections": "被检查次数", "inspections_passed": "通过检查",
		"goods_seized": "被没收货物", "burglaries": "失窃次数", "burglary_losses": "失窃损失",
		"scavenge_attempts": "拾荒次数", "scavenged_value": "拾荒价值",
		"injuries_minor": "轻伤", "injuries_major": "重伤", "criminals_reported": "举报罪犯",
		"perfect_appraisals": "完美鉴定", "augs_shot": "击毙义体人", "wrongful_reports": "误报",
		"items_bought": "购入物品", "best_flip_value": "最佳倒卖", "best_find_value": "最佳拾荒发现",
		"days_played": "经营天数",
	}
	return String(names.get(key, key))

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
		"requests":
			var res := GameState.fill_store_request(info_selected_id)
			_refresh()
			_rebuild_info_list()
			_refresh_info_detail()
			info_status.text = String(res.get("text", ""))
		"status":
			var uit := GameState.find_item(int(info_selected_id))
			if not uit.is_empty() and String(uit.get("def_id", "")) in ["labeler", "labeler_blue"]:
				_open_labeler_select()
				return
			var res := GameState.use_consumable(int(info_selected_id))
			_refresh()
			_rebuild_info_list()
			_refresh_info_detail()
			info_status.text = String(res.get("text", ""))
		"perks":
			var res := GameState.choose_starting_perk(info_selected_id)
			_refresh()
			_rebuild_info_list()
			_refresh_info_detail()
			info_status.text = String(res.get("text", ""))
		"appraisal":
			if info_selected_id == "promotion":
				var res := GameState.promote_appraiser()
				_refresh()
				_rebuild_info_list()
				_refresh_info_detail()
				info_status.text = String(res.get("text", ""))
		"phone":
			var res := GameState.deliver_commission(info_selected_id)
			_refresh()
			info_selected_id = ""
			_rebuild_info_list()
			_refresh_info_detail()
			info_status.text = String(res.get("text", ""))
		"security":
			info_name.text = "治安部档案"
			info_meta.text = "证据 %d/100 · 预计判决：%s · 案件探员：%s" % [GameState.sec_evidence, GameState.sec_projected_sentence(), GameState.sec_case_officer()]
			var crime_lines: Array = []
			for cid in GameState.sec_crimes.keys():
				if int(GameState.sec_crimes[cid]) > 0:
					crime_lines.append("%s：%d₵" % [GameState.sec_crime_name(String(cid)), int(GameState.sec_crimes[cid])])
			var body := "总犯罪值：%d₵
最大案件：%s
贿赂参考：%d₵" % [GameState.sec_total_crime(), GameState.sec_biggest_crime(), GameState.sec_bribe_amount()]
			body += "
" + ("
".join(crime_lines) if not crime_lines.is_empty() else "目前没有犯罪记录。")
			var neg_perks: Array = []
			var pos_perks: Array = []
			for pid in GameState.security_defs.get("reputation_perks", {}).keys():
				var pd: Dictionary = GameState.security_defs["reputation_perks"][pid]
				var threshold := int(pd.get("threshold", 0))
				var pname := GameState.loc("RepPerkTable", "rep_perk_%s_name" % pid, String(pid))
				var mark := "●" if GameState.sec_perk_unlocked(String(pid)) else "○"
				if int(pd.get("type", 1)) < 0:
					neg_perks.append("%s%s≤%d" % [mark, pname, threshold])
				else:
					pos_perks.append("%s%s≥%d" % [mark, pname, threshold])
			body += "
治安特权（●已解锁 ○未解锁）：
负面：" + "、".join(neg_perks) + "
正面：" + "、".join(pos_perks)
			var permit_text := "无"
			if not GameState.active_permits.is_empty():
				var plist: Array = []
				for p in GameState.active_permits:
					plist.append("%s级" % str(int(p.get("level", 0))))
				permit_text = "、".join(plist)
			body += "
武器许可证：%s" % permit_text
			info_body.text = body
			info_status.text = "治安声望 %+d" % int(GameState.rep.get("security", 0))
		"wanted":
			var w := GameState.wanted_def(info_selected_id)
			if w.is_empty() or GameState.wanted_defeated.has(info_selected_id):
				return
			info_layer.visible = false
			GameState.start_combat(String(w.get("enemy", "")), "security", info_selected_id)

func _open_network() -> void:
	_open_info_tab("network")

func _open_facilities() -> void:
	_play_room_ambience("amb_dumps_ambience.ogg")
	var text := "水龙头剩余 %d ml。

设施：水龙头/排水槽、床铺、卷帘门、录音机。
床铺可以直接结束营业；水龙头可灌满液体容器。" % GameState.store_water_ml
	_show_modal("店铺设施", text, [
		{"label": "水龙头灌满", "cb": _facility_fill_select, "color": C_CYAN},
		{"label": "排水槽倒空", "cb": _facility_drain_select, "color": C_CYAN},
		{"label": "床铺：结束营业", "cb": _facility_sleep, "color": C_RUST},
		{"label": "产权/按揭", "cb": _open_property, "color": C_AMBER},
		{"label": "卡特尔事务", "cb": _open_cartel, "color": C_AMBER},
		{"label": "枪械改装", "cb": _open_gun_mod, "color": C_AMBER},
		{"label": "选项", "cb": _open_options},
		{"label": "关闭", "cb": _close_modal},
	])

func _open_cartel() -> void:
	var cost := GameState.cartel_material_cost()
	var lines: Array = []
	lines.append("卡特尔声望：%d" % int(GameState.rep.get("cartel", 0)))
	lines.append("材料申请：消耗 %d 声望，获得 2 个化学模块。" % cost)
	if GameState.cartel_exited:
		lines.append("你已金盆洗手，不再与卡特尔往来。")
	elif GameState.cartel_exit_available:
		lines.append("接头人已为你安排好退路，可以金盆洗手。")
	else:
		lines.append("退路尚未安排（声望 100 解锁）。")
	var actions: Array = []
	if not GameState.cartel_exited and int(GameState.rep.get("cartel", 0)) >= cost:
		actions.append({"label": "申请材料（-%d 声望）" % cost, "cb": _cartel_materials_ui, "color": C_GREEN})
	if not GameState.cartel_exited and GameState.cartel_exit_available:
		actions.append({"label": "金盆洗手", "cb": _cartel_exit_ui, "color": C_RUST})
	actions.append({"label": "返回", "cb": _open_facilities, "color": C_MUTED})
	_show_modal("卡特尔事务", "\n".join(lines), actions)

func _cartel_materials_ui() -> void:
	var res := GameState.request_cartel_materials()
	_close_modal()
	_toast(String(res.get("text", "")))
	_refresh()

func _cartel_exit_ui() -> void:
	var res := GameState.exit_cartel()
	_close_modal()
	_toast(String(res.get("text", "")))
	_refresh()

func _gun_slot_name(slot: String) -> String:
	match slot:
		"stock": return "枪托"
		"rail": return "导轨"
		"underbarrel": return "下挂"
		"barrel": return "枪管"
		"magazine": return "弹匣"
		"special1": return "特殊1"
		"special2": return "特殊2"
		"special3": return "特殊3"
	return slot

func _open_gun_mod() -> void:
	_close_modal()
	var guns := GameState.gun_mod_gun_list()
	if guns.is_empty():
		_toast("背包里没有可改装的枪械。")
		return
	_open_select("枪械改装：选择枪械", guns, _gun_mod_pick_gun)

func _gun_mod_pick_gun(gun_id: String) -> void:
	var gun := GameState.find_item(int(gun_id))
	if gun.is_empty():
		_open_gun_mod()
		return
	var items: Array = []
	var mods: Dictionary = gun.get("gun_mods", {})
	for slot in GameState.gun_mod_defs.get("slots", []):
		var s := String(slot)
		var label := ""
		if mods.has(s):
			var mid := String(mods[s].get("def_id", ""))
			label = "%s：%s（点击卸下）" % [_gun_slot_name(s), String(GameState.get_item_def(mid).get("name", mid))]
		else:
			label = "%s：空（点击安装）" % _gun_slot_name(s)
		items.append({"id": s, "label": label})
	items.append({"id": "__back__", "label": "返回"})
	_open_select("改装 %s" % GameState.item_display_name(gun), items, _gun_mod_pick_slot.bind(int(gun_id)))

func _gun_mod_pick_slot(slot: String, gun_id: int) -> void:
	if slot == "__back__":
		_open_gun_mod()
		return
	var gun := GameState.find_item(gun_id)
	if gun.is_empty():
		_open_gun_mod()
		return
	var mods: Dictionary = gun.get("gun_mods", {})
	if mods.has(slot):
		var res := GameState.gun_remove_mod(gun_id, slot)
		_toast(String(res.get("text", "")))
		_gun_mod_pick_gun(str(gun_id))
		return
	var choices := GameState.gun_owned_mods_for(gun, slot)
	if choices.is_empty():
		_toast("没有可用的%s配件。" % _gun_slot_name(slot))
		_gun_mod_pick_gun(str(gun_id))
		return
	_open_select("%s · 选择配件" % _gun_slot_name(slot), choices, _gun_mod_pick_mod.bind(gun_id, slot))

func _gun_mod_pick_mod(mod_id: String, gun_id: int, slot: String) -> void:
	var res := GameState.gun_install_mod(gun_id, int(mod_id))
	_toast(String(res.get("text", "")))
	_gun_mod_pick_gun(str(gun_id))

func _facility_fill_select() -> void:
	var items: Array = []
	for it in GameState.inventory:
		if GameState.is_liquid_container(it):
			items.append({"id": str(int(it.get("uid", -1))), "label": "%s · %d ml" % [GameState.item_display_name(it), int(it.get("liquid_ml", 0))]})
	if items.is_empty():
		_toast("没有液体容器。")
		return
	_close_modal()
	_open_select("水龙头：选择容器", items, _facility_fill_uid)

func _facility_fill_uid(id: String) -> void:
	_play_named_sfx("pour_water.ogg")
	var res := GameState.fill_liquid_from_faucet(int(id))
	_open_facilities()
	_toast(String(res.get("text", "")))

func _facility_drain_select() -> void:
	var items: Array = []
	for it in GameState.inventory:
		if GameState.is_liquid_container(it) and int(it.get("liquid_ml", 0)) > 0:
			items.append({"id": str(int(it.get("uid", -1))), "label": "%s · %d ml" % [GameState.item_display_name(it), int(it.get("liquid_ml", 0))]})
	if items.is_empty():
		_toast("没有可倒空的容器。")
		return
	_close_modal()
	_open_select("排水槽：选择容器", items, _facility_drain_uid)

func _facility_drain_uid(id: String) -> void:
	_play_named_sfx("pour_water.ogg")
	var res := GameState.drain_liquid_container(int(id))
	_open_facilities()
	_toast(String(res.get("text", "")))

func _facility_sleep() -> void:
	_close_modal()
	_on_end_day_pressed()

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
		story_portrait.modulate.a = 0.0
		create_tween().tween_property(story_portrait, "modulate:a", 1.0, 0.25)
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
	var extra := "

—— 本局统计 ——
经营 %d 天 · 净资产 %d₵ · 总销售 %d₵ · 售出 %d 件 · 接待 %d 位
检查 %d 次 · 失窃 %d 次 · 拾荒价值 %d₵ · 举报 %d 人" % [
		int(GameState.run_stats.get("days_played", GameState.day)), GameState.net_worth(),
		int(GameState.run_stats.get("total_sales", 0)), int(GameState.run_stats.get("items_sold", 0)),
		int(GameState.run_stats.get("customers_served", 0)), int(GameState.run_stats.get("inspections", 0)),
		int(GameState.run_stats.get("burglaries", 0)), int(GameState.run_stats.get("scavenged_value", 0)),
		int(GameState.run_stats.get("criminals_reported", 0)),
	]
	_show_modal(String(e.get("title", "结局")), String(e.get("text", "")) + extra, [{"label": "重新开始", "cb": _restart_game, "color": C_RUST}, {"label": "关闭", "cb": _close_modal}])

func _close_story() -> void:
	story_layer.visible = false
	story_node_id = ""
	var nxt := GameState.take_queued_story()
	if nxt != "" and not GameState.story_node(nxt).is_empty():
		_show_story(nxt)
	else:
		_maybe_show_tutorial()
		_refresh()

func _security_result_modal(res: Dictionary) -> void:
	_refresh()
	if GameState.phase == "gameover" and GameState.ending_id != "":
		var e := GameState.ending_def(GameState.ending_id)
		var body := String(res.get("text", ""))
		if not e.is_empty():
			body += "\n\n【%s】\n%s" % [e.get("title", "结局"), e.get("text", "")]
		_show_modal("结局", body, [{"label": "重新开始", "cb": _restart_game, "color": C_RUST}, {"label": "关闭", "cb": _close_modal}])
		return
	var lines: Array = [String(res.get("text", ""))]
	if int(res.get("fine", 0)) > 0:
		lines.append("罚款：%d₵" % int(res.get("fine", 0)))
	var seized: Array = res.get("seized", [])
	if not seized.is_empty():
		var names: Array = []
		for it in seized:
			names.append(String(it.get("name", "")))
		lines.append("没收：%s" % "、".join(names))
	_show_modal("治安部", "\n".join(lines), [{"label": "关闭", "cb": _close_modal}])

func _security_accept_interview() -> void:
	_security_result_modal(GameState.sec_resolve_officer(false))

func _security_pay_fine() -> void:
	_security_result_modal(GameState.sec_resolve_officer(true))

func _security_refuse() -> void:
	_security_result_modal(GameState.sec_resolve_officer(false))

func _on_security_officer_arrived() -> void:
	if not GameState.sec_officer_pending:
		return
	var total := GameState.sec_total_crime()
	var body := "治安部探员上门。\n\n证据：%d/100\n最大案件：%s\n总犯罪值：%d₵\n预计判决：%s" % [GameState.sec_evidence, GameState.sec_biggest_crime(), total, GameState.sec_projected_sentence()]
	var fine := total
	if GameState.sec_evidence < 95 or total <= 0:
		_show_modal("治安部探员", body, [{"label": "接受问询", "cb": _security_accept_interview}])
	elif total < 300:
		_show_modal("治安部探员", body + "\n\n探员开出 %d₵ 罚款。" % fine, [
			{"label": "支付 %d₵" % fine, "cb": _security_pay_fine},
			{"label": "拒绝付款", "cb": _security_refuse, "color": C_RUST},
		])
	else:
		_show_modal("治安部探员", body, [{"label": "接受判决", "cb": _security_refuse}])

func _inspection_accept() -> void:
	_security_result_modal(GameState.sec_resolve_inspection(true, false))

func _inspection_bribe() -> void:
	_security_result_modal(GameState.sec_resolve_inspection(false, true))

func _on_inspection_arrived() -> void:
	_play_named_sfx("alarm2.ogg")
	if not GameState.sec_inspection_pending:
		return
	var title := "治安检查"
	if GameState.sec_inspection_personality == 1:
		title = GameState.loc("ClientName", "name_shady_security_inspector", "可疑的治安部盘查员")
	elif GameState.sec_inspection_personality == 2:
		title = GameState.loc("ClientName", "name_lazy_security_inspector", "懒惰的治安部盘查员")
	else:
		title = GameState.loc("ClientName", "name_security_inspector", "治安部盘查员")
	var body := String(GameState.dialogue_lines.get("dialog_inspection_routine_1", "别紧张。"))
	body += " " + String(GameState.dialogue_lines.get("dialog_inspection_routine_2", "这是一次例行治安盘查。"))
	body += "

" + String(GameState.dialogue_lines.get("dialog_sec_inspect_last_open", "检查官要求检查你的柜台与库存。"))
	body += "

最近案件：%s
证据：%d/100" % [GameState.sec_biggest_crime(), GameState.sec_evidence]
	if GameState.sec_inspection_fake and GameState.sec_perk_unlocked("SEC_VIP"):
		body += "

他的制服似乎不太合身……"
	var actions: Array = [{"label": "接受检查", "cb": _inspection_accept}]
	if GameState.sec_inspection_personality == 1 and GameState.cash >= GameState.sec_bribe_amount():
		var amt := GameState.sec_bribe_amount()
		actions.append({"label": "贿赂 %d₵" % amt, "color": C_RUST, "cb": _inspection_bribe})
	_show_modal(title, body, actions)

func _on_permit_revoke_arrived() -> void:
	if not GameState.sec_permit_revoke_pending:
		return
	var lines: Array = [
		String(GameState.dialogue_lines.get("dialog_sec_revoke_1", "你好。鉴于你近期的所作所为，")),
		String(GameState.dialogue_lines.get("dialog_sec_revoke_2", "现正式吊销你的许可证。")),
		String(GameState.dialogue_lines.get("dialog_sec_revoke_3", "祝你当班平安。")),
	]
	var levels: Array = []
	for level in GameState.sec_permit_revoke_levels:
		levels.append(str(level))
	lines.append("吊销等级：%s" % "、".join(levels))
	_show_modal("治安部", "
".join(lines), [{"label": "交还许可证", "cb": _permit_revoke_confirm, "color": C_RUST}])

func _permit_revoke_confirm() -> void:
	var res := GameState.revoke_permits()
	_security_result_modal(res)
	_refresh()

func _on_combat_hit(uid: int, amount: int) -> void:
	_play_sfx("hit")
	_play_combat_impact(uid == 0)
	if combat_enemy_sprite == null:
		return
	var is_player := uid == 0
	var host := combat_enemy_sprite.get_parent()
	var base_pos := combat_enemy_sprite.position
	var lbl := Label.new()
	lbl.text = "-%d" % amount
	lbl.position = base_pos + Vector2(160 if not is_player else 120, 20)
	lbl.add_theme_font_size_override("font_size", 34)
	lbl.add_theme_color_override("font_color", Color("#ff7a6a") if is_player else Color("#ffd166"))
	lbl.add_theme_constant_override("outline_size", 8)
	lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.02, 0.95))
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(lbl)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 60.0, 0.7)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.7)
	tw.chain().tween_callback(lbl.queue_free)
	if not is_player:
		var shake := create_tween()
		shake.tween_property(combat_enemy_sprite, "position:x", base_pos.x + 10.0, 0.05)
		shake.tween_property(combat_enemy_sprite, "position:x", base_pos.x - 8.0, 0.05)
		shake.tween_property(combat_enemy_sprite, "position:x", base_pos.x, 0.05)

func _play_combat_impact(is_player: bool) -> void:
	if combat_impact == null:
		return
	combat_impact.visible = true
	var prefix := "wound" if is_player else "body"
	var count := 6 if is_player else 8
	for i in range(count):
		var path := "res://assets_private/shot_anim/shot_animation_%s_%d.png" % [prefix, i]
		if ResourceLoader.exists(path):
			combat_impact.texture = load(path)
		await get_tree().create_timer(0.05).timeout
		if not is_instance_valid(combat_impact):
			return
	combat_impact.visible = false

func _on_combat_started() -> void:
	combat_layer.visible = true
	_update_combat_ui()

func _on_combat_updated() -> void:
	_update_combat_ui()

func _on_combat_finished(victory: bool, message: String) -> void:
	_play_sfx("cash" if victory else "fail")
	combat_layer.visible = false
	var was_expedition := GameState.combat_context == "expedition"
	var was_wanted_visit := GameState.combat_context == "wanted_visit"
	_refresh()
	if GameState.combat_context == "space_encounter":
		var reward := int(GameState.space_pending_reward.get("cash", 0))
		if victory:
			GameState.cash += reward
			GameState.space_log.append("击退海盗，获得 %d₵。" % reward)
		GameState.space_pending_reward = {}
		_show_modal("太空战斗", "战斗结束。" if victory else "你被击退了。", [{"label": "返回舰船", "cb": _open_space}])
		return
	if GameState.combat_context == "space_station":
		if victory and GameState.advance_space_raid():
			_show_modal("站点战斗", "房间清理完毕，进入下一层。", [{"label": "继续", "cb": _close_modal}])
			return
		_show_modal("站点", "站点已清理。" if victory else "你被击退了。", [{"label": "返回舰船", "cb": _open_space}])
		return
	if victory and was_expedition:
		var loot_text := "
".join(GameState.expedition_loot_log)
		if GameState.advance_expedition():
			_show_modal("探险 · 房间清理", loot_text + "

进入下一层（行动点 %d）。" % GameState.raid_action_points, [{"label": "继续", "cb": _close_modal}])
			return
		_show_modal("探险完成", loot_text if loot_text != "" else "没有额外战利品。", [{"label": "离开", "cb": _close_modal}])
		GameState.next_customer()
	elif victory and was_wanted_visit:
		GameState.next_customer()
	if not victory and GameState.phase == "gameover" and GameState.ending_id != "":
		var e := GameState.ending_def(GameState.ending_id)
		var body := message
		if not e.is_empty():
			body += "\n\n【%s】\n%s" % [e.get("title", "结局"), e.get("text", "")]
		_show_modal("结局", body, [{"label": "重新开始", "cb": _restart_game, "color": C_RUST}, {"label": "关闭", "cb": _close_modal}])
		return
	_show_modal("战斗结果", message, [{"label": "关闭", "cb": _close_modal}])

func _combat_effect_text(u: Dictionary) -> String:
	var parts: Array = []
	for e in u.get("effects", []):
		var dur := int(e.get("duration", 0))
		if dur <= 0:
			continue
		match String(e.get("type", "")):
			"bleed": parts.append("流血×%d" % dur)
			"stun": parts.append("眩晕×%d" % dur)
			"buff": parts.append("增益×%d" % dur)
			"debuff": parts.append("减益×%d" % dur)
			"overwatch": parts.append("警戒")
			"retaliate": parts.append("反击")
			"overtime_heal": parts.append("恢复×%d" % dur)
	return "、".join(parts)

func _update_combat_ui() -> void:
	if GameState.combat_enemy.is_empty():
		return
	var e := GameState.combat_enemy
	combat_enemy_name.text = String(e.get("name", ""))
	var path := _customer_path(String(e.get("sprite", "")))
	combat_enemy_sprite.texture = load(path) if ResourceLoader.exists(path) else null
	var emax := maxi(1, int(e.get("max_hp", e.get("hp", 40))))
	combat_enemy_bar.max_value = emax
	combat_enemy_bar.value = clampi(int(e.get("hp", 40)), 0, emax)
	combat_player_bar.max_value = GameState.combat_player_max
	combat_player_bar.value = clampi(GameState.combat_player_hp, 0, GameState.combat_player_max)
	combat_log_label.text = "
".join(GameState.combat_log.slice(maxi(0, GameState.combat_log.size() - 8)))
	var pl := GameState._combat_unit_by_uid(0)
	var effects_p := _combat_effect_text(pl)
	var effects_e := _combat_effect_text(e)
	var turn_text := "你的回合" if GameState.combat_waiting_for_player() else "敌人行动中"
	var weapon_name := String(GameState.combat_abilities.get(GameState.combat_player_weapon, {}).get("name", "徒手"))
	var armor_text := ""
	var p_armor: Dictionary = pl.get("armor", {}) if not pl.is_empty() else {}
	if not p_armor.is_empty():
		armor_text = " · 护甲 %d/%d" % [int(p_armor.get("value", 0)), int(p_armor.get("max", 0))]
	combat_status.text = "第 %d 回合 · %s · 武器：%s%s%s
敌人 HP %d/%d%s · 你的 HP %d/%d%s" % [
		GameState.combat_round, turn_text, weapon_name, armor_text,
		(" · 弹药 %d/%d" % [GameState.combat_mag_rounds, GameState.combat_mag_size]) if GameState.combat_is_gun else "",
		int(e.get("hp", 0)), emax, ("（" + effects_e + "）") if effects_e != "" else "",
		GameState.combat_player_hp, GameState.combat_player_max, ("（" + effects_p + "）") if effects_p != "" else ""]
	_clear_children(combat_actions_box)
	if not GameState.combat_waiting_for_player():
		return
	var foes := GameState._combat_enemies_of(pl)
	if foes.size() > 1:
		for f in foes:
			var tb := _button(combat_actions_box, "目标：%s" % String(f.get("name", "")), Vector2.ZERO, Vector2(170, 54), C_AMBER if int(f.get("uid", -1)) == GameState.combat_target_uid else C_MUTED, _combat_target.bind(int(f.get("uid", -1))))
			tb.custom_minimum_size = Vector2(170, 54)
	for skill in GameState.combat_player_skills():
		var sid := String(skill.get("id", ""))
		var iuid := int(skill.get("item_uid", -1))
		var b := _button(combat_actions_box, String(skill.get("name", sid)), Vector2.ZERO, Vector2(170, 64), C_RUST if iuid < 0 and sid not in ["brace_ability", "overwatch"] else C_CYAN, _combat_use_skill.bind(sid, iuid))
		b.custom_minimum_size = Vector2(170, 64)
		b.add_theme_font_size_override("font_size", 19)
	var flee := _button(combat_actions_box, "无法逃跑", Vector2.ZERO, Vector2(170, 64), C_MUTED, _toast.bind("原版战斗中无法逃跑。"))
	flee.disabled = true
	flee.custom_minimum_size = Vector2(170, 64)

func _combat_target(uid: int) -> void:
	GameState.combat_select_target(uid)
	_update_combat_ui()

func _combat_use_skill(id: String, item_uid: int) -> void:
	if not GameState.combat_waiting_for_player():
		return
	var sfx_key := "soft"
	if item_uid < 0:
		sfx_key = "shotgun" if id.contains("shotgun") else ("gun" if id.contains("attack") else "soft")
	_play_sfx(sfx_key)
	if item_uid < 0 and (id.contains("attack") or id.contains("shotgun")):
		_combat_muzzle_flash()
	GameState.combat_player_action(id, GameState.combat_target_uid, item_uid)
	_update_combat_ui()

func _combat_muzzle_flash() -> void:
	if combat_layer == null:
		return
	var flash := ColorRect.new()
	flash.color = Color(1.0, 0.86, 0.45, 0.28)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	combat_layer.add_child(flash)
	if combat_enemy_sprite != null:
		var line := Line2D.new()
		line.width = 3.0
		line.default_color = Color(1.0, 0.85, 0.45, 0.85)
		var enemy_pos := combat_enemy_sprite.global_position - combat_layer.global_position + combat_enemy_sprite.size * 0.5
		line.points = PackedVector2Array([Vector2(140, 430), enemy_pos])
		combat_layer.add_child(line)
		var ltw := create_tween()
		ltw.tween_property(line, "modulate:a", 0.0, 0.16)
		ltw.tween_callback(line.queue_free)
	var tw := create_tween()
	tw.tween_property(flash, "color:a", 0.0, 0.18)
	tw.tween_callback(flash.queue_free)

func _combat_action(action: String) -> void:
	if not GameState.combat_active:
		return
	_play_sfx("gun" if action == "attack" else "soft")
	GameState.combat_action(action)
	_update_combat_ui()

func _toast(text: String) -> void:
	_show_modal("提示", text, [{"label": "知道了", "cb": _close_modal}])

func _show_modal(title: String, text: String, actions: Array) -> void:
	if receipt_stamp:
		receipt_stamp.visible = false
	if summary_tabs:
		summary_tabs.visible = false
	modal_panel.add_theme_stylebox_override("panel", _tex_style("window_frame.png", 8, C_PANEL, C_CYAN, 3))
	modal_title.add_theme_color_override("font_color", C_AMBER)
	modal_text.add_theme_color_override("font_color", C_TEXT)
	move_child(modal_layer, get_child_count() - 1)
	modal_layer.modulate.a = 0.0
	create_tween().tween_property(modal_layer, "modulate:a", 1.0, 0.15)
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
	modal_close_btn.visible = true
	modal_layer.visible = true

func _show_receipt(title: String, text: String) -> void:
	var body := "— — — — — — — — — —
" + text + "
— — — — — — — — — —
收费项目已登记在案"
	_show_modal(title, body, [{"label": "收起", "cb": _close_modal}])
	if receipt_stamp:
		receipt_stamp.visible = true
	modal_panel.add_theme_stylebox_override("panel", _tex_style("inspection_receipt.png", 14, Color("#efe6cf"), Color("#8a7a5a"), 3))
	modal_title.add_theme_color_override("font_color", Color("#4a3423"))
	modal_text.add_theme_color_override("font_color", Color("#2b241b"))

func _show_news(title: String, text: String, actions: Array) -> void:
	_show_modal(title, text, actions)
	modal_panel.add_theme_stylebox_override("panel", _tex_style("newspaper.png", 22, Color("#d8d2bd"), Color("#8a8570"), 3))
	modal_title.add_theme_color_override("font_color", Color("#6f2320"))
	modal_text.add_theme_color_override("font_color", Color("#2b2a24"))
	for b in modal_actions.get_children():
		if b is Button:
			b.add_theme_stylebox_override("normal", _style(Color("#cdc7b2"), Color("#8a8570"), 2))
			b.add_theme_stylebox_override("hover", _style(Color("#e0dac5"), Color("#6f5a45"), 2))
			b.add_theme_stylebox_override("pressed", _style(Color("#b7b19c"), Color("#6f5a45"), 2))
			b.add_theme_color_override("font_color", Color("#2b2a24"))
			b.add_theme_color_override("font_hover_color", Color("#4a3423"))
			b.add_theme_color_override("font_pressed_color", Color("#4a3423"))

func _testp2ui_if_requested() -> void:
	if not "--testp2ui" in OS.get_cmdline_args():
		return
	await get_tree().create_timer(0.6).timeout
	_welcome_done()
	await get_tree().create_timer(0.2).timeout
	if modal_layer.visible:
		_close_modal()
	_toggle_poster_ui()
	await get_tree().process_frame
	print("P2UI poster visible=", poster_layer.visible, " texture=", poster_image.texture != null)
	_poster_apply()
	print("P2UI poster pulled=", GameState.poster_pulled)
	_close_poster()
	_show_receipt("测试查抄单", "罚款 100₵")
	await get_tree().process_frame
	print("P2UI receipt stamp=", receipt_stamp.visible, " text=", modal_title.text)
	_close_modal()
	_play_named_sfx("new_bell.ogg")
	print("P2UI audio bell ok")
	await get_tree().process_frame
	get_tree().quit(0)

func _testspaceui_if_requested() -> void:
	if not "--testspaceui" in OS.get_cmdline_args():
		return
	await get_tree().create_timer(0.6).timeout
	print("SPUI menu=", newgame_layer.visible)
	_space_pick_ship("cargo_ship")
	await get_tree().process_frame
	print("SPUI space title=", modal_title.text, " actions=", modal_actions.get_child_count())
	_space_scan_ui()
	await get_tree().process_frame
	print("SPUI scan rows=", select_list.get_child_count(), " select=", select_layer.visible)
	_close_select()
	_close_modal()
	await get_tree().process_frame
	get_tree().quit(0)

func _testp1ui_if_requested() -> void:
	if not "--testp1ui" in OS.get_cmdline_args():
		return
	await get_tree().create_timer(0.6).timeout
	_welcome_done()
	await get_tree().create_timer(0.2).timeout
	if modal_layer.visible:
		_close_modal()
	_open_facilities()
	await get_tree().process_frame
	_play_named_sfx("new_bell.ogg")
	print("P1UI facilities title=", modal_title.text, " actions=", modal_actions.get_child_count())
	_close_modal()
	_open_info_tab("news")
	print("P1UI news tab=", info_tab, " rows=", info_list_buttons.size())
	_close_info()
	GameState.current_customer = {"intent": "sell", "arche": {"faction": "lower", "name": "卖家"}, "item": {"uid": 999, "def_id": "handmade_pistol", "asking_price": 100, "min_price": 70, "known": true, "condition": 80}, "patience": 3, "done": false}
	GameState.counter_item = GameState.current_customer["item"]
	GameState.current_index = 0
	GameState.phase = "customer"
	_refresh()
	print("P1UI queue=", queue_label.text)
	_open_bargain()
	await get_tree().process_frame
	bargain_price = 80
	_refresh_bargain_modal()
	await get_tree().process_frame
	print("P1UI bargain preview=", "成功" in modal_text.text, " actions=", modal_actions.get_child_count())
	_close_modal()
	_switch_info_tab("map")
	print("P1UI map rows=", info_list_buttons.size())
	_switch_info_tab("notebook")
	print("P1UI notebook rows=", info_list_buttons.size())
	_close_info()
	var vis_qp := 0
	for qp in queue_portrait_rects:
		if qp.visible:
			vis_qp += 1
	print("P1UI queue portraits=", vis_qp)
	_open_options()
	await get_tree().process_frame
	print("P1UI options actions=", modal_actions.get_child_count())
	_close_modal()
	_open_save_menu("load")
	await get_tree().process_frame
	print("P1UI load slots=", modal_actions.get_child_count())
	_close_modal()
	await get_tree().process_frame
	get_tree().quit(0)

func _testp0ui_if_requested() -> void:
	if not "--testp0ui" in OS.get_cmdline_args():
		return
	await get_tree().create_timer(0.6).timeout
	print("P0UI menu=", newgame_layer.visible, " page=", ng_page)
	_ng_goto("start")
	print("P0UI start page=", ng_page, " professions=", GameState.professions.size())
	_ng_pick_start("water_merchant")
	GameState.run_count = 1
	_ng_goto("perks")
	_ng_toggle_perk("perk_saving")
	print("P0UI perks=", ng_perks, " points=", GameState.starting_perk_points(ng_perks))
	_ng_goto("difficulty")
	_ng_pick_difficulty("cozy")
	_ng_start()
	await get_tree().process_frame
	print("P0UI started type=", GameState.start_type_id, " cash=", GameState.cash, " layer=", newgame_layer.visible)
	if modal_layer.visible:
		_close_modal()
	_open_status()
	print("P0UI status tab=", info_tab, " title=", info_name.text, " meta=", info_meta.text)
	_switch_info_tab("achievements")
	print("P0UI achievements=", info_list_buttons.size())
	_switch_info_tab("stats")
	print("P0UI stats rows=", info_list_buttons.size())
	_close_info()
	GameState.current_customer = {"intent": "gun_order", "arche": {"faction": "lower", "name": "买家"}, "require": {"accuracy": 10}, "bonuses": [], "base": 100, "done": false}
	GameState.gun_order = GameState.current_customer
	_open_gun_order()
	await get_tree().process_frame
	print("P0UI gun title=", modal_title.text, " actions=", modal_actions.get_child_count())
	_close_modal()
	GameState.current_customer = {"intent": "expedition", "arche": {"faction": "lower", "name": "组织者"}, "party": "pirateRookieTriple", "done": false, "line": "去探险吗？"}
	GameState.unlock_hireling()
	_open_expedition()
	await get_tree().process_frame
	print("P0UI expedition actions=", modal_actions.get_child_count())
	_close_modal()
	await get_tree().process_frame
	get_tree().quit(0)

func _testpresentationui_if_requested() -> void:
	if not "--testpresentationui" in OS.get_cmdline_args():
		return
	await get_tree().create_timer(0.5).timeout
	_welcome_done()
	await get_tree().process_frame
	if modal_layer.visible:
		_close_modal()
	_show_receipt("查抄单", "罚款 100₵")
	await get_tree().process_frame
	var rstyle := modal_panel.get_theme_stylebox("panel")
	print("PRUI receipt style=", rstyle is StyleBoxTexture)
	_show_news("号外", "夜里不太平。", [{"label": "知道了", "cb": _close_modal}])
	await get_tree().process_frame
	var nstyle := modal_panel.get_theme_stylebox("panel")
	print("PRUI news style=", nstyle is StyleBoxTexture, " buttons=", modal_actions.get_child_count())
	_close_modal()
	var slot := _slot_cell(modal_actions, Vector2.ZERO, Vector2(52, 52))
	await get_tree().process_frame
	var sstyle := slot.get_theme_stylebox("panel")
	print("PRUI slot style=", sstyle is StyleBoxTexture)
	GameState.customers_today = [{"dummy": true}]
	GameState.phase = "customer"
	walker_far_timer = 0.0
	walker_mid_timer = 0.0
	_update_walkers(0.25)
	await get_tree().process_frame
	print("PRUI walkers=", walkers.size(), " nodes=", walker_layer.get_child_count())
	if walkers.size() > 0:
		var before := (walkers[0]["rect"] as TextureRect).texture
		_update_walkers(0.35)
		await get_tree().process_frame
		print("PRUI walker frame advanced=", (walkers[0]["rect"] as TextureRect).texture != before)
	_play_customer_walkin()
	print("PRUI walkin tint=", customer_rect.modulate)
	await get_tree().process_frame
	get_tree().quit(0)

func _close_modal() -> void:
	_stop_room_ambience()
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

func _build_input_layer() -> void:
	input_layer = Control.new()
	input_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input_layer.z_index = 170
	input_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	input_layer.visible = false
	add_child(input_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input_layer.add_child(dim)
	var panel := _panel(input_layer, Vector2(620, 390), Vector2(1100, 300), C_PANEL, C_CYAN, 3)
	input_title = _label(panel, "输入", Vector2(30, 20), Vector2(1000, 42), 30, C_AMBER)
	input_field = LineEdit.new()
	input_field.position = Vector2(30, 90)
	input_field.size = Vector2(1040, 64)
	input_field.add_theme_font_size_override("font_size", 26)
	input_field.add_theme_stylebox_override("normal", _style(C_PANEL2, C_LINE, 2))
	input_field.add_theme_stylebox_override("focus", _style(Color("#252c38"), C_CYAN, 2))
	panel.add_child(input_field)
	_button(panel, "取消", Vector2(780, 200), Vector2(140, 64), C_MUTED, _input_cancel)
	_button(panel, "确定", Vector2(940, 200), Vector2(140, 64), C_CYAN, _input_confirm)

func _open_input(title: String, placeholder: String, cb: Callable) -> void:
	input_title.text = title
	input_field.text = ""
	input_field.placeholder_text = placeholder
	input_cb = cb
	input_layer.visible = true
	move_child(input_layer, get_child_count() - 1)
	input_field.grab_focus()

func _input_confirm() -> void:
	var text := input_field.text
	input_layer.visible = false
	if input_cb.is_valid():
		input_cb.call(text)

func _input_cancel() -> void:
	input_layer.visible = false

func _build_newgame_layer() -> void:
	newgame_layer = Control.new()
	newgame_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	newgame_layer.z_index = 160
	newgame_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	newgame_layer.visible = false
	add_child(newgame_layer)

func _show_new_game_menu() -> void:
	ng_page = "menu"
	newgame_layer.visible = true
	move_child(newgame_layer, get_child_count() - 1)
	_ng_render()

func _ng_render() -> void:
	_clear_children(newgame_layer)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.94)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	newgame_layer.add_child(dim)
	var panel := _panel(newgame_layer, Vector2(300, 36), Vector2(1740, 1008), C_PANEL, C_CYAN, 3)
	_label(panel, "深空当铺", Vector2(40, 22), Vector2(800, 60), 52, C_AMBER)
	_label(panel, "PROBABLY STOLEN · MOBILE PORT", Vector2(44, 84), Vector2(800, 28), 18, C_MUTED)
	if ng_page == "menu":
		_label(panel, "一间当铺，一条空间站走廊，和一堆来路不明的东西。", Vector2(44, 150), Vector2(1500, 40), 26, C_TEXT)
		_button(panel, "新游戏", Vector2(80, 260), Vector2(420, 90), C_AMBER, _ng_goto.bind("start"))
		var cont := _button(panel, "继续游戏", Vector2(80, 380), Vector2(420, 90), C_CYAN, _ng_continue)
		cont.disabled = not GameState.has_save(1)
		_button(panel, "设置", Vector2(80, 500), Vector2(420, 90), C_MUTED, _ng_settings)
		_button(panel, "制作人员", Vector2(80, 620), Vector2(420, 90), C_MUTED, _ng_credits)
		_button(panel, "舰船层（遗留）", Vector2(560, 620), Vector2(420, 70), C_CYAN, _space_entry)
		var info := "原版活跃流程：选择开局 → 分配天赋 → 选择难度 → 开店。\n首局不开放开局天赋（原版规则）。"
		_label(panel, info, Vector2(560, 280), Vector2(1080, 160), 24, C_MUTED)
		_label(panel, "当前存档：%s" % ("槽位 1 · 第 %d 天" % GameState.day if GameState.has_save(1) else "无"), Vector2(560, 470), Vector2(900, 40), 22, C_MUTED)
		_button(panel, "关闭菜单继续当前局", Vector2(560, 760), Vector2(420, 70), C_MUTED, _ng_close)
	elif ng_page == "start":
		_label(panel, "选择开局", Vector2(44, 140), Vector2(800, 50), 34, C_AMBER)
		var active: Array = []
		for p in GameState.professions:
			if not bool(p.get("coming_soon", false)):
				active.append(p)
		for i in range(active.size()):
			var p: Dictionary = active[i]
			var pid := String(p.get("id", ""))
			var col := i % 3
			var row := int(i / 3)
			var txt := "%s\n%s" % [String(p.get("name", pid)), _ng_wrap(String(p.get("desc", "")), 22)]
			var b := _button(panel, txt, Vector2(50 + col * 550, 210 + row * 200), Vector2(510, 180), C_TEXT, _ng_pick_start.bind(pid))
			b.add_theme_font_size_override("font_size", 20)
			b.modulate = Color(1.25, 1.12, 0.72) if pid == ng_start_type else Color.WHITE
		_label(panel, "已选：%s" % _ng_start_name(), Vector2(50, 840), Vector2(900, 40), 24, C_GREEN)
		_button(panel, "返回", Vector2(50, 900), Vector2(220, 64), C_MUTED, _ng_goto.bind("menu"))
		_button(panel, "下一步：天赋", Vector2(1450, 900), Vector2(260, 64), C_AMBER, _ng_goto.bind("perks"))
	elif ng_page == "perks":
		var pts := GameState.starting_perk_points(ng_perks)
		_label(panel, "开局天赋（%d/3 点 · 槽位 %d/%d）" % [pts, ng_perks.size(), GameState.starting_perk_slots(ng_perks)], Vector2(44, 132), Vector2(1200, 40), 30, C_AMBER)
		var first_run := GameState.run_count <= 0
		if first_run:
			_label(panel, "首局不可选天赋：完成首局后，新开局有 3 点可分配。", Vector2(44, 168), Vector2(1400, 30), 20, C_RUST)
		var scroll := ScrollContainer.new()
		scroll.position = Vector2(44, 210)
		scroll.size = Vector2(1660, 650)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		panel.add_child(scroll)
		var grid := GridContainer.new()
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 10)
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(grid)
		for p in GameState.starting_perks:
			var pid := String(p.get("id", ""))
			var meta := GameState.starting_perk_meta_def(pid)
			if meta.is_empty():
				continue
			var cost := int(meta.get("cost", 0))
			var cost_text := ("+%d" % cost) if cost > 0 else str(cost)
			var b := _button(grid, "%s  %s" % [String(p.get("name", pid)), cost_text], Vector2.ZERO, Vector2(402, 70), C_TEXT, _ng_toggle_perk.bind(pid))
			b.custom_minimum_size = Vector2(402, 70)
			b.add_theme_font_size_override("font_size", 17)
			b.modulate = Color(1.25, 1.12, 0.72) if ng_perks.has(pid) else Color.WHITE
			b.disabled = first_run
		var valid := GameState.starting_perks_valid(ng_perks)
		_label(panel, String(valid.get("text", "")), Vector2(44, 872), Vector2(1100, 30), 20, C_MUTED)
		_button(panel, "返回", Vector2(44, 912), Vector2(220, 64), C_MUTED, _ng_goto.bind("start"))
		var nxt := _button(panel, "下一步：难度", Vector2(1440, 912), Vector2(270, 64), C_AMBER, _ng_goto.bind("difficulty"))
		nxt.disabled = not bool(valid.get("ok", false))
	elif ng_page == "difficulty":
		_label(panel, "选择难度", Vector2(44, 132), Vector2(800, 44), 34, C_AMBER)
		var diffs := ["cozy", "normal", "hard", "challenge"]
		for i in range(diffs.size()):
			var did: String = diffs[i]
			var d: Dictionary = GameState.DIFFICULTY.get(did, {})
			var b := _button(panel, "%s\n起始现金 %d₵ · 房租 %d₵" % [String(d.get("name", did)), int(d.get("cash", 600)), int(d.get("rent", 200))], Vector2(70 + i * 410, 220), Vector2(380, 180), C_TEXT, _ng_pick_difficulty.bind(did))
			b.add_theme_font_size_override("font_size", 22)
			b.modulate = Color(1.25, 1.12, 0.72) if did == ng_difficulty else Color.WHITE
		_button(panel, "日程：%s" % ("原版 45 天" if ng_campaign == "original" else "移动 10 天"), Vector2(70, 450), Vector2(500, 70), C_CYAN, _ng_toggle_campaign)
		_button(panel, "跳过开场：%s" % ("是" if ng_skip_intro else "否"), Vector2(600, 450), Vector2(400, 70), C_CYAN, _ng_toggle_skip)
		var preview := "开局：%s\n天赋：%d 个（%d 点）\n难度：%s\n日程：%s" % [_ng_start_name(), ng_perks.size(), GameState.starting_perk_points(ng_perks), String(GameState.DIFFICULTY.get(ng_difficulty, {}).get("name", ng_difficulty)), "原版 45 天" if ng_campaign == "original" else "移动 10 天"]
		_label(panel, preview, Vector2(70, 570), Vector2(1200, 200), 24, C_TEXT)
		_button(panel, "返回", Vector2(44, 912), Vector2(220, 64), C_MUTED, _ng_goto.bind("perks"))
		_button(panel, "开始营业", Vector2(1400, 900), Vector2(300, 76), C_GREEN, _ng_start)
	_button(panel, "关闭", Vector2(1570, 20), Vector2(120, 48), C_MUTED, _ng_close)

func _space_entry() -> void:
	var items: Array = []
	for sh in GameState.space_ships:
		items.append({"id": String(sh.get("id", "")), "label": "%s · %s · 船体 %d · 燃料 %d" % [String(sh.get("name", "")), String(sh.get("class", "")), int(sh.get("hull", 0)), int(sh.get("fuel", 0))]})
	if items.is_empty():
		_toast("没有可用舰船。")
		return
	_open_select("选择舰船 · 遗留模式", items, _space_pick_ship)

func _space_pick_ship(id: String) -> void:
	var res := GameState.space_start(id)
	if not bool(res.get("ok", false)):
		_toast(String(res.get("text", "")))
		return
	_open_space()

func _open_space() -> void:
	if not GameState.space_mode:
		_space_entry()
		return
	var actions: Array = [
		{"label": "扫描航线", "cb": _space_scan_ui, "color": C_CYAN},
		{"label": "停靠" if GameState.space_at_station else "无站点", "cb": _space_dock_ui, "color": C_AMBER},
		{"label": "等待一天", "cb": _space_wait_ui},
		{"label": "返回店铺", "cb": _space_leave_ui, "color": C_RUST},
	]
	_show_modal("舰船 · LEGACY SPACE LAYER", GameState.space_state_text(), actions)

func _space_scan_ui() -> void:
	_play_named_sfx("ping_sonar.ogg")
	var pois := GameState.space_scan()
	var items: Array = []
	for poi in pois:
		items.append({"id": String(poi.get("id", "")), "label": "%s · %d 距离 · %s" % [String(poi.get("name", "")), int(poi.get("distance", 0)), String(poi.get("desc", ""))]})
	if items.is_empty():
		_toast("没有可扫描的航线。")
		return
	_close_modal()
	_open_select("扫描结果（4 条航线）", items, _space_travel_ui)

func _space_travel_ui(id: String) -> void:
	var poi: Dictionary = {}
	for p in GameState.space_scanned:
		if String(p.get("id", "")) == id:
			poi = p
			break
	if poi.is_empty():
		return
	_play_named_sfx("notif_nav_ready.ogg")
	var res := GameState.space_travel(poi)
	if not bool(res.get("ok", false)):
		_open_space()
		_toast(String(res.get("text", "")))
		return
	if res.get("encounter", null) != null:
		var enc: Dictionary = res["encounter"]
		var actions: Array = []
		for opt in enc.get("options", []):
			actions.append({"label": String(opt.get("label", "")), "cb": _space_option.bind(String(opt.get("id", "")))})
		_show_modal(String(enc.get("title", "太空遭遇")), String(enc.get("text", "")), actions)
		return
	_show_modal("抵达", String(res.get("text", "")), [
		{"label": "停靠" if GameState.space_at_station else "继续", "cb": _space_dock_ui if GameState.space_at_station else _open_space, "color": C_AMBER},
		{"label": "扫描航线", "cb": _space_scan_ui},
	])

func _space_option(id: String) -> void:
	var res := GameState.space_resolve(id)
	if bool(res.get("combat", false)):
		_close_modal()
		return
	_show_modal("太空遭遇", String(res.get("text", "")), [{"label": "继续", "cb": _open_space}])

func _space_dock_ui() -> void:
	var res := GameState.space_dock()
	if not bool(res.get("ok", false)):
		_open_space()
		_toast(String(res.get("text", "")))
		return
	_close_modal()

func _space_wait_ui() -> void:
	GameState.space_wait()
	_open_space()

func _space_leave_ui() -> void:
	GameState.space_leave()
	_close_modal()

func _ng_goto(page: String) -> void:
	ng_page = page
	_ng_render()

func _ng_pick_start(pid: String) -> void:
	ng_start_type = pid
	_ng_render()

func _ng_toggle_perk(pid: String) -> void:
	if ng_perks.has(pid):
		ng_perks.erase(pid)
	else:
		ng_perks.append(pid)
	var check := GameState.starting_perks_valid(ng_perks)
	if not bool(check.get("ok", false)):
		ng_perks.erase(pid)
	_ng_render()

func _ng_pick_difficulty(did: String) -> void:
	ng_difficulty = did
	_ng_render()

func _ng_toggle_campaign() -> void:
	ng_campaign = "mobile" if ng_campaign == "original" else "original"
	_ng_render()

func _ng_toggle_skip() -> void:
	ng_skip_intro = not ng_skip_intro
	_ng_render()

func _ng_start_name() -> String:
	for p in GameState.professions:
		if String(p.get("id", "")) == ng_start_type:
			return String(p.get("name", ng_start_type))
	return ng_start_type

func _ng_wrap(text: String, width: int) -> String:
	var out := ""
	var line := 0
	for ch in text:
		out += ch
		line += 1
		if line >= width:
			out += "\n"
			line = 0
	return out

func _ng_start() -> void:
	var perks: Array = [] if GameState.run_count <= 0 else ng_perks.duplicate()
	GameState.new_game(ng_difficulty, ng_campaign, ng_start_type, perks)
	GameState.record_new_game_start()
	newgame_layer.visible = false
	if ng_skip_intro:
		GameState.tutorial_done = true
		GameState.pending_story = ""
		GameState.story_queue.clear()
		_close_modal()
	else:
		_welcome_done()
	_refresh()

func _ng_continue() -> void:
	if GameState.load_game(1):
		newgame_layer.visible = false
		_close_modal()
		_refresh()
		_toast("已读取槽位 1。")

func _ng_close() -> void:
	newgame_layer.visible = false

func _ng_settings() -> void:
	_show_modal("设置", "音效与音乐当前为%s。\n存档：1/2/3 三个槽位，可在游戏顶栏或信息页操作。" % ("开启" if audio_enabled else "关闭"), [
		{"label": "切换音效", "cb": _on_audio_toggle},
		{"label": "关闭", "cb": _close_modal},
	])

func _ng_credits() -> void:
	_show_modal("制作人员", "原版：Probably Stolen 开发组\n移动移植：Qoder 1:1 还原项目\n字体：Fusion Pixel 12px\n音频与美术素材来自本地正版安装（私有构建，不随公开仓库分发）。", [{"label": "关闭", "cb": _close_modal}])


	if welcome_shown:
		return
	welcome_shown = true
	_show_modal("欢迎来到下层区", "你盘下了一间当铺，欠着导师 200¥ 贷款，7 天后要交房租。\n\n流程：看顾客拿出什么 → 点「鉴定」验货 → 点「议价」或直接「成交」→ 结束营业结算。\n\n选择难度开始：简单（800₵ 启动资金、房租 150₵）、普通（600₵ / 200₵）、困难（450₵ / 260₵，敌人伤害更高）。", [
		{"label": "简单", "cb": _choose_difficulty.bind("easy"), "color": C_GREEN},
		{"label": "普通", "cb": _choose_difficulty.bind("normal"), "color": C_AMBER},
		{"label": "困难", "cb": _choose_difficulty.bind("hard"), "color": C_RUST},
		{"label": "原版 1:1", "cb": _choose_original, "color": C_CYAN},
	])

func _choose_difficulty(id: String) -> void:
	GameState.new_game(id)
	_welcome_done()

func _choose_original() -> void:
	GameState.new_game("normal", "original")
	_welcome_done()

func _welcome_done() -> void:
	if newgame_layer:
		newgame_layer.visible = false
	_close_modal()
	if GameState.pending_story != "" and not story_layer.visible:
		_show_story(GameState.pending_story)
	else:
		_maybe_show_tutorial()

func _tutorial_text() -> String:
	match GameState.tutorial_step:
		1: return "教程 1/4：先按铃召唤顾客，再点右侧「鉴定」检查物品。"
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
	GameState.unlock_achievement("ACH_TUTORIAL")
	_close_modal()
	_refresh()

func _on_inspect_owned() -> void:
	if selected_uid < 0:
		_toast("先选择一件物品。")
		return
	if not GameState.current_customer.is_empty():
		_toast("先送走当前顾客再自检物品。")
		return
	var it := GameState.find_item(selected_uid)
	if it.is_empty():
		_toast("没有找到这件物品。")
		return
	inspection_owned = true
	GameState.counter_item = it
	inspection_uid = -1
	_open_inspection()

func _open_inspection() -> void:
	if not inspection_owned:
		if GameState.current_customer.is_empty():
			_toast("现在没有顾客。")
			return
		var intent := String(GameState.current_customer.get("intent", ""))
		if intent not in ["sell", "appraise"]:
			_toast("这位顾客不是来出售或估价的。")
			return
	if GameState.counter_item.is_empty():
		_toast("柜台上没有物品。")
		return
	_play_sfx("page")
	if GameState.tutorial_step == 1:
		GameState.tutorial_step = 2
		_refresh()
	_close_modal()
	inspection_layer.visible = true
	if inspection_uid != int(GameState.counter_item.get("uid", -1)):
		inspection_uid = int(GameState.counter_item.get("uid", -1))
		inspection_appraisal_input.text = str(int(GameState.get_item_def(String(GameState.counter_item.get("def_id", ""))).get("base_value", 100)))
	_refresh_inspection_modal()

func _close_inspection() -> void:
	inspection_layer.visible = false
	if inspection_owned:
		GameState.counter_item = {}
		inspection_owned = false
		_refresh()
	_play_sfx("soft")

func _inspection_action_button(label: String, cb: Callable, color: Color = C_CYAN) -> void:
	var b := _button(inspection_actions, label, Vector2.ZERO, Vector2(560, 50), color, cb)
	b.custom_minimum_size = Vector2(560, 50)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 19)

func _refresh_inspection_modal() -> void:
	var it: Dictionary = GameState.counter_item
	if it.is_empty():
		return
	var def := GameState.get_item_def(it["def_id"])
	var family := String(it.get("family", "generic"))
	var fam: Dictionary = GameState.inspection_families.get(family, {})
	var intent := "owned" if inspection_owned else String(GameState.current_customer.get("intent", ""))
	var cname := "自检" if inspection_owned else String(GameState.current_customer.get("arche", {}).get("name", "顾客"))
	inspection_title.text = "%s · %s" % [GameState.loc("UI", "ui_inspection_panel_title", "物品鉴定"), GameState.item_display_name(it)]
	var text := "物品：%s\n家族：%s\n品相：%d%%\n顾客：%s（%s）\n" % [
		GameState.item_display_name(it),
		String(fam.get("name", family if family != "generic" else "普通物品")),
		int(it.get("condition", 100)), cname, "估价委托" if intent == "appraise" else ("自检物品" if intent == "owned" else "出售物品")]
	if bool(it.get("family_seen", false)) and not fam.is_empty():
		text += "\n【目视属性】\n" + GameState._family_attr_text(it) + "\n"
	text += "\n【公开特征】\n"
	var features: Array = it.get("feature_list", [])
	if features.is_empty():
		text += "· 无明显异常\n"
	else:
		for i in range(features.size()):
			var f: Dictionary = features[i]
			var shown := String(f.get("real_label", "")) if bool(f.get("exposed", false)) else String(f.get("public_label", ""))
			var mark := "已揭露" if bool(f.get("exposed", false)) else ("已发现" if bool(f.get("discovered", false)) else "未发现")
			text += "· %s：%s（%s）\n" % [String(f.get("label", f.get("id", ""))), shown, mark]
	var notes: Array = it.get("inspect_notes", [])
	if not notes.is_empty():
		text += "\n【工具记录】\n"
		for n in notes:
			text += "· " + String(n) + "\n"
	if not inspection_owned and String(it.get("family", "")) in ["cigarette", "stamp", "injector"]:
		text += "\n【对质】\n观察属性后判断真伪；对质成功会让顾客降价。\n"
	if intent == "appraise":
		text += "\n【估价】\n输入你认为的真实价值，误差越小评级越高。\n"
	inspection_info.text = text
	var icon_path := GameState.item_icon_path(def)
	inspection_pixel_icon.texture = load(icon_path) if icon_path != "" else null
	inspection_pixel_meta.text = "%s
品相 %d%% · %s" % [GameState.item_display_name(it), int(it.get("condition", 100)), String(fam.get("name", "普通物品"))]
	_clear_children(inspection_actions)
	var tools := GameState.inspection_tools_for_counter()
	var relevant := ["magnifier", "flashlight", "scale"]
	if family == "water":
		relevant = ["magnifier", "water_test_strip", "flashlight"]
	elif family == "chem":
		relevant = ["magnifier", "chem_scanner"]
	elif family == "plant":
		relevant = ["magnifier", "plant_analyser", "scale"]
	elif family in ["cigarette", "stamp", "injector", "hand", "ribwich", "plasma", "berry"]:
		relevant = ["magnifier", "flashlight", "scale"]
	for t in tools:
		if not relevant.has(String(t.get("id", ""))):
			continue
		var label := "%s" % String(t.get("label", t.get("id", "")))
		if int(t.get("count", 1)) > 1:
			label += " ×%d" % int(t.get("count", 1))
		_inspection_action_button(label, _inspect_tool.bind(String(t.get("id", ""))))
	for i in range(features.size()):
		var f: Dictionary = features[i]
		if bool(f.get("discovered", false)) and not bool(f.get("exposed", false)):
			_inspection_action_button("揭露：" + String(f.get("label", "")), _expose_counter_feature.bind(i), C_AMBER)
	if not inspection_owned and String(it.get("family", "")) in ["cigarette", "stamp", "injector"] and not bool(it.get("confronted", false)):
		_inspection_action_button(GameState.loc("UI", "ui_inspection_panel_confront_button", "对质"), _open_confront_select, C_RUST)
	if intent == "appraise":
		inspection_appraisal_input.visible = true
		inspection_appraisal_input.get_parent().get_node_or_null("AppraisalSubmit").visible = true
	else:
		inspection_appraisal_input.visible = false
		inspection_appraisal_input.get_parent().get_node_or_null("AppraisalSubmit").visible = false
	if inspection_status.text == "":
		inspection_status.text = "选择工具进一步检查。"

func _inspect_tool(tool_id: String) -> void:
	var res := GameState.inspect_counter_with_tool(tool_id)
	_play_sfx("click" if bool(res.get("ok", false)) else "fail")
	inspection_status.text = String(res.get("text", "")).split("
")[0]
	_refresh_inspection_modal()
	inspection_status.text = String(res.get("text", "")).split("
")[0]

func _expose_counter_feature(index: int) -> void:
	var res := GameState.expose_counter_feature(index)
	_play_sfx("cash" if bool(res.get("ok", false)) else "fail")
	inspection_status.text = String(res.get("text", ""))
	_refresh_inspection_modal()

func _open_confront_select() -> void:
	var it: Dictionary = GameState.counter_item
	var items: Array = []
	for opt in GameState._family_issue_options(it):
		items.append({"id": opt.get("id", ""), "label": opt.get("label", opt.get("id", ""))})
	if items.is_empty():
		_toast("没有可对质的问题。")
		return
	_open_select("选择对质理由", items, _confront_choice)

func _confront_choice(issue_id: String) -> void:
	var res := GameState.confront_counter_item(issue_id)
	_play_sfx("cash" if bool(res.get("ok", false)) else "fail")
	inspection_status.text = String(res.get("text", ""))
	_refresh_inspection_modal()

func _show_promotion_modal() -> void:
	var cost := GameState.promotion_cost()
	var text := "鉴定委员会愿意提升你的等级。\n\n当前：%s\n下一级花费：%d₵\n晋升后底费与抽成提高，并解锁新的估价品类。\n现金：%d₵" % [GameState.appraisal_rank_name(), cost, GameState.cash]
	_show_modal("鉴定师晋升", text, [
		{"label": "接受晋升", "cb": _accept_promotion, "color": C_AMBER},
		{"label": "延期 7 天", "cb": _decline_promotion.bind(false)},
		{"label": "拒绝", "cb": _decline_promotion.bind(true), "color": C_RUST},
		{"label": "关闭", "cb": _close_modal},
	])

func _accept_promotion() -> void:
	var res := GameState.promote_appraiser()
	_refresh()
	_show_modal("晋升结果", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _decline_promotion(forever: bool) -> void:
	GameState.decline_promotion(forever)
	_refresh()
	_show_modal("晋升", "已延期 7 天。" if not forever else "已永久拒绝晋升。", [{"label": "关闭", "cb": _close_modal}])

func _submit_appraisal() -> void:
	var value := int(inspection_appraisal_input.text.strip_edges())
	if value <= 0:
		inspection_status.text = "请输入有效的估价。"
		return
	var res := GameState.appraise_counter_item(value)
	if bool(res.get("ok", false)):
		inspection_layer.visible = false
		_play_sfx("cash")
		_refresh()
		var actions: Array = [{"label": "关闭", "cb": _close_modal}]
		_show_modal("估价结果", String(res.get("text", "")) + "\n\n" + String(res.get("slip", "")), actions)
	else:
		_play_sfx("fail")
		inspection_status.text = String(res.get("text", ""))
		if bool(res.get("walkout", false)):
			inspection_layer.visible = false
			_refresh()
			_show_modal("估价失败", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])
		else:
			_refresh_inspection_modal()
			inspection_status.text = String(res.get("text", ""))

func _open_bargain() -> void:
	if not GameState.can_bargain():
		_toast("你不善议价，无法与顾客讨价还价。")
		return
	if GameState.current_customer.get("intent") == "appraise":
		_open_inspection()
		return
	if GameState.current_customer.is_empty() or GameState.counter_item.is_empty():
		_toast("当前没有可议价的物品。")
		return
	_play_sfx("soft")
	if bool(GameState.current_customer.get("bargain_locked", false)):
		bargain_price = GameState.bargain_locked_price()
	elif GameState.current_customer.get("intent") == "sell":
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
	var direction := int(c.get("bargain_direction", 0))
	var locked := bool(c.get("bargain_locked", false))
	if locked:
		bargain_price = int(c.get("bargain_price", bargain_price))
	var text := ""
	if c.get("intent") == "sell":
		text = "顾客开价：%d¥\n你的报价：%d¥\n现金：%d¥" % [int(it.get("asking_price", 0)), bargain_price, GameState.cash]
	else:
		text = "顾客出价：%d¥\n你的报价：%d¥\n顾客预算：%d¥\n现金：%d¥" % [int(c.get("offer", 0)), bargain_price, int(c.get("budget", 0)), GameState.cash]
	if direction == 0:
		text += "\n\n请选择压价或抬价（只能选一次，之后不可更改）。"
	elif not locked:
		text += "\n\n已选择%s：请选择幅度（锁定后不可更改）。" % ("压价" if direction < 0 else "抬价")
	else:
		text += "\n\n已锁定：%s %d%%。" % ["压价" if direction < 0 else "抬价", int(c.get("bargain_percent", 0))]
	if locked:
		var pv: Dictionary = GameState.bargain_preview(absi(int(c.get("bargain_percent", 0))))
		text += "\n成功 %d%% · 离店 %d%% · 声望 %+d" % [int(pv.get("success", 0)), int(pv.get("leave", 0)), int(pv.get("rep", 0))]
	var actions: Array = []
	if direction == 0:
		actions.append({"label": "压价", "cb": _bargain_pick_direction.bind(-1), "color": C_CYAN})
		actions.append({"label": "抬价", "cb": _bargain_pick_direction.bind(1), "color": C_AMBER})
	elif not locked:
		actions.append({"label": "5%", "cb": _bargain_pick_percent.bind(5)})
		actions.append({"label": "10%", "cb": _bargain_pick_percent.bind(10)})
		actions.append({"label": "15%", "cb": _bargain_pick_percent.bind(15)})
	else:
		actions.append({"label": "报价", "cb": _bargain_confirm, "color": C_AMBER})
	actions.append({"label": "勒索", "cb": _do_blackmail, "color": C_RUST})
	actions.append({"label": "威胁", "cb": _do_threaten, "color": C_RUST})
	if GameState.aug_introduced and not bool(c.get("aug_scanned", false)) and GameState.inventory_count("aug_scanner") > 0:
		actions.append({"label": "扫描义体", "cb": _do_scan_aug, "color": C_CYAN})
	if GameState.aug_introduced and not bool(c.get("aug_threatened", false)):
		actions.append({"label": "威胁义体", "cb": _do_threaten_aug, "color": C_RUST})
	if bool(c.get("aug_scanned", false)) and bool(c.get("is_aug", false)):
		actions.append({"label": "举报义体", "cb": _do_report_aug, "color": C_GREEN})
	_show_modal("议价 · " + GameState.item_display_name(it), text, actions)

func _on_news_ready(title: String, text: String) -> void:
	news_archive.append({"title": title, "text": text, "day": str(GameState.day)})
	if news_archive.size() > 40:
		news_archive.pop_front()
	_show_news(title, text, [{"label": "关闭", "cb": _close_modal}])

func _on_achievement_unlocked(aid: String) -> void:
	var aname := aid
	for a in GameState.achievement_defs:
		if String(a.get("id", "")) == aid:
			aname = String(a.get("name", aid))
			break
	_toast("成就解锁：%s" % aname)

func _do_scan_aug() -> void:
	var res := GameState.scan_aug_customer()
	_refresh()
	_show_modal("义体扫描", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _do_threaten_aug() -> void:
	var res := GameState.threaten_aug()
	_refresh()
	_show_modal("威胁义体", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _do_report_aug() -> void:
	var res := GameState.report_aug()
	_refresh()
	_show_modal("举报义体", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _bargain_pick_direction(direction: int) -> void:
	var res := GameState.bargain_choose_direction(direction)
	if not bool(res.get("ok", false)):
		_toast(String(res.get("text", "")))
		return
	_refresh_bargain_modal()

func _bargain_pick_percent(percent: int) -> void:
	var res := GameState.bargain_choose_percent(percent)
	if not bool(res.get("ok", false)):
		_toast(String(res.get("text", "")))
		return
	bargain_price = int(res.get("price", bargain_price))
	_refresh_bargain_modal()

func _bargain_confirm() -> void:
	if not bool(GameState.current_customer.get("bargain_locked", false)):
		_toast("先选择压价或抬价，并锁定幅度。")
		return
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

func _do_blackmail() -> void:
	_play_sfx("hit")
	var res := GameState.blackmail_bargain()
	_refresh()
	_show_modal("勒索", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

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
	if GameState.show_event_countdown():
		event = event.duplicate(true)
		event["text"] = String(event.get("text", "")) + "\n\n事件倒计时：%d 天。" % int(event.get("days", 3))
	var title := String(event.get("title", "夜间事件"))
	if String(event.get("display_key", "")) != "":
		title = GameState.loc("Mechanic", String(event.get("display_key", "")), title)
	var text := String(event.get("text", ""))
	if String(event.get("news_key", "")) != "":
		text = GameState.loc("Mechanic", String(event.get("news_key", "")), text)
	if String(event.get("desc_key", "")) != "":
		text = GameState.loc("Mechanic", String(event.get("desc_key", "")), text)
	var actions: Array = []
	var choices: Array = event.get("choices", [])
	for i in range(choices.size()):
		actions.append({"label": choices[i].get("label", "选择"), "cb": _on_event_choice.bind(i, choices[i].get("result", ""))})
	_show_news(title, text, actions)

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
		GameState.start_combat(String(choice.get("combat", "")), "security", "", String(ev.get("id", "")), String(choice.get("party", "")))
	else:
		_show_modal("事件结果", result, [{"label": "继续", "cb": _close_modal}])






