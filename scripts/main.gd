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
var machine_name_label: Label
var machine_meta_label: Label
var machine_io_label: Label
var machine_module_label: Label
var machine_status_label: Label
var machine_jobs_label: Label
var machine_power_label: Label
var machine_start_btn: Button
var temp_buttons: Array = []
var machine_list_buttons: Dictionary = {}
var selected_machine_id := ""
var machine_ui_timer := 0.0
var action_buttons: Dictionary = {}
var rail_buttons: Dictionary = {}
var rep_labels: Dictionary = {}
var tab_buttons: Dictionary = {}
var page_buttons: Array = []

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
	_setup_theme()
	_build_ui()
	GameState.state_changed.connect(_refresh)
	GameState.customer_changed.connect(_on_customer_changed)
	GameState.day_finished.connect(_on_day_finished)
	GameState.event_started.connect(_on_event_started)
	GameState.machine_finished.connect(_on_machine_finished)
	_refresh()
	_show_welcome()
	_capture_if_requested()
	_autotest_if_requested()
	_dumpui_if_requested()
	_dumpinspect_if_requested()

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


func _capture_if_requested() -> void:
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
	parent.add_child(b)
	return b

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
	bg_window = _texture_rect(game_view, Vector2.ZERO, Vector2(1920, 1080), ART_BG)
	customer_rect = _texture_rect(game_view, Vector2(635, 5), Vector2(677, 496), "res://assets/customers/maleUpper_0.png")
	fg = _texture_rect(game_view, Vector2.ZERO, Vector2(1920, 1080), ART_FG)
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

func _build_hud() -> void:
	_panel(self, Vector2.ZERO, Vector2(2340, 80), C_PANEL, C_LINE)
	_label(self, "深空当铺", Vector2(24, 8), Vector2(300, 48), 36, C_AMBER)
	_label(self, "MOBILE PORT · M1", Vector2(26, 50), Vector2(300, 22), 16, C_MUTED)
	day_label = _label(self, "", Vector2(360, 18), Vector2(320, 42), 30, C_TEXT)
	rent_label = _label(self, "", Vector2(700, 18), Vector2(520, 42), 30, C_AMBER)
	_label(self, "信用点", Vector2(1560, 8), Vector2(200, 22), 18, C_MUTED)
	cash_label = _label(self, "", Vector2(1580, 24), Vector2(420, 52), 48, C_AMBER, HORIZONTAL_ALIGNMENT_RIGHT)
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
	_label(p, "右侧选择交涉动作 · 长按物品查看详情", Vector2(16, 178), Vector2(528, 26), 20, C_MUTED)

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
	machine_status_label = _label(detail, "选择机器开始生产。", Vector2(350, 454), Vector2(900, 70), 22, C_MUTED)
	var jobs_panel := _panel(panel, Vector2(570, 700), Vector2(1280, 250), C_PANEL2, C_LINE, 2)
	_label(jobs_panel, "运行队列", Vector2(24, 12), Vector2(300, 32), 24, C_AMBER)
	machine_jobs_label = _label(jobs_panel, "无", Vector2(24, 50), Vector2(1230, 180), 22, C_TEXT)

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
	var path := "res://assets/customers/" + sprite
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
	counter_name.text = String(def.get("name", ""))
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
			_label(p, String(def.get("name", "")), Vector2(8, 88), Vector2(160, 22), 18, C_TEXT)
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
	detail_name.text = String(def.get("name", ""))
	detail_desc.text = String(def.get("description", ""))
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
			_toast("今日共 %d 位顾客，当前第 %d 位。" % [GameState.customers_today.size(), GameState.current_index + 1])
		"inventory":
			_toast("底部就是你的异形格背包。点选物品查看详情，拖动可以换位置。")
		"network":
			_open_network()
		"factions":
			_open_factions()
		"phone":
			_toast("手机/短信系统将在 M4 模块开放。M1 先跑通经营循环。")
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
	if GameState.save_game():
		_toast("已保存到存档位 1。")
	else:
		_toast("存档失败。")

func _on_load() -> void:
	if GameState.load_game():
		selected_uid = -1
		current_page = 0
		_refresh()
		_toast("已读取存档位 1。")
	else:
		_toast("没有找到可读取的存档。")

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
	if String(s.get("gameover", "")) != "":
		text += "\n\n你没能付清%s，店铺被收走了。" % ("房租" if s["gameover"] == "rent" else "贷款")
		actions.append({"label": "重新开始", "cb": _restart_game, "color": C_RUST})
	else:
		actions.append({"label": "下一天", "cb": _next_day, "color": C_AMBER})
	_show_modal("营业结算", text, actions)

func _next_day() -> void:
	_close_modal()
	GameState.advance_day()
	_refresh()

func _restart_game() -> void:
	_close_modal()
	GameState.new_game()
	selected_uid = -1
	current_page = 0
	last_summary = {}
	_refresh()

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
		var text := "%s
%d电 · %.0fs" % [m.get("name", mid), int(m.get("power", 0)), float(m.get("time", 0.0))]
		var b := _button(machine_list_box, text, Vector2.ZERO, Vector2(480, 64), C_TEXT, _select_machine.bind(mid))
		b.custom_minimum_size = Vector2(480, 64)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		machine_list_buttons[mid] = b
	_refresh_machine_selection()

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
	machine_meta_label.text = "电力 %d · 耗时 %.1fs · 温度 %d°C" % [use_power, use_time, int(m.get("temp", 24))]
	var ins: Array = []
	for i in m.get("inputs", []):
		var d := GameState.get_item_def(String(i.get("id", "")))
		ins.append("%sx%d" % [_short_item_name(String(i.get("id", "")), String(d.get("name", ""))), int(i.get("count", 1))])
	var outs: Array = []
	for o in m.get("outputs", []):
		var od := GameState.get_item_def(String(o.get("id", "")))
		outs.append("%sx%d" % [_short_item_name(String(o.get("id", "")), String(od.get("name", ""))), int(o.get("count", 1))])
	machine_io_label.text = "输入：%s
输出：%s
原料持有：废金属x%d 打印塑料x%d 金属锭x%d 化学品x%d" % [" + ".join(ins), " + ".join(outs), GameState.inventory_count("scrap_metal"), GameState.inventory_count("printer_plastic"), GameState.inventory_count("metal_ingot"), GameState.inventory_count("common_chemical")]
	var mod_id := String(GameState.machine_modules.get(selected_machine_id, ""))
	if mod_id == "":
		machine_module_label.text = "模块：无（安装模块：耗时 -20%，电力 -1）"
	else:
		machine_module_label.text = "模块：%s（耗时 -20%%，电力 -1）" % GameState.get_item_def(mod_id).get("name", mod_id)
	for i in range(temp_buttons.size()):
		temp_buttons[i].modulate = Color(1.25, 1.12, 0.72) if (i + 1) == lvl else Color.WHITE
	machine_power_label.text = "电力 %d/%d" % [GameState.power, GameState.max_power]
	machine_start_btn.disabled = false
	for j in GameState.machine_jobs:
		if String(j.get("machine_id", "")) == selected_machine_id:
			machine_start_btn.disabled = true
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
		text += "· %s  剩余 %.1fs
" % [j.get("name", ""), float(j.get("remaining", 0.0))]
	machine_jobs_label.text = text

func _start_selected_machine() -> void:
	var res := GameState.start_machine(selected_machine_id)
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

func _open_factions() -> void:
	var text := "派系声望

"
	for f in GameState.factions:
		var fid := String(f.get("id", ""))
		var v := int(GameState.rep.get(fid, 0))
		var next := GameState.faction_next_perk(fid)
		var next_text := "已满"
		if not next.is_empty():
			next_text = "下一档 %d：%s" % [int(next.get("threshold", 0)), next.get("name", "")]
		text += "%s  %+d  %s
" % [f.get("name", fid), v, next_text]
	_show_modal("派系声望", text, [{"label": "关闭", "cb": _close_modal}])
	modal_text.add_theme_font_size_override("font_size", 19)

func _open_network() -> void:
	var text := "网络升级 · 现金 %d₵

" % GameState.cash
	var actions: Array = []
	for u in GameState.upgrades:
		var uid := String(u.get("id", ""))
		var owned := GameState.owned_upgrades.has(uid)
		text += "%s  %d₵  %s
" % [u.get("name", uid), int(u.get("cost", 0)), "已拥有" if owned else u.get("desc", "")]
		if not owned:
			actions.append({"label": "%s %d" % [u.get("name", uid), int(u.get("cost", 0))], "cb": _buy_upgrade.bind(uid), "color": C_AMBER})
	actions.append({"label": "关闭", "cb": _close_modal})
	_show_modal("网络升级", text, actions)
	modal_text.add_theme_font_size_override("font_size", 17)

func _buy_upgrade(uid: String) -> void:
	var res := GameState.buy_upgrade(uid)
	_refresh()
	if res.get("ok", false):
		_show_modal("网络升级", String(res.get("text", "")), [{"label": "继续", "cb": _open_network}, {"label": "关闭", "cb": _close_modal}])
	else:
		_toast(String(res.get("text", "购买失败")))

func _toast(text: String) -> void:
	_show_modal("提示", text, [{"label": "知道了", "cb": _close_modal}])

func _show_modal(title: String, text: String, actions: Array) -> void:
	modal_title.text = title
	modal_text.add_theme_font_size_override("font_size", 26)
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
	_show_modal("欢迎来到下层区", "你盘下了一间当铺，欠着导师 200¥ 贷款，7 天后要交 200¥ 房租。\n\n流程：看顾客拿出什么 → 点「鉴定」验货 → 点「议价」或直接「成交」→ 结束营业结算。\n\n底部是你的异形格背包，展示柜里的商品才能卖给想买东西的顾客。", [{"label": "开始营业", "cb": _close_modal}])

func _open_inspection() -> void:
	if GameState.current_customer.is_empty() or GameState.current_customer.get("intent") != "sell":
		_toast("只有顾客出售物品时才需要鉴定。")
		return
	if GameState.counter_item.is_empty():
		_toast("柜台上没有物品。")
		return
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
	var text := "物品：%s\n品相：%d%%\n\n选择鉴定方式。鉴定费从现金扣除，两次以上可得出结论。" % [def.get("name", ""), int(it.get("condition", 100))]
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
	_show_modal("鉴定 · " + String(def.get("name", "")), text, actions)

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
	_show_modal("议价 · " + String(def.get("name", "")), text, actions)

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
	var res := GameState.threaten()
	_refresh()
	_show_modal("威胁", String(res.get("text", "")), [{"label": "关闭", "cb": _close_modal}])

func _do_deal() -> void:
	var res := GameState.accept_current()
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
	GameState.apply_event(index)
	_refresh()
	_show_modal("事件结果", result, [{"label": "继续", "cb": _close_modal}])






