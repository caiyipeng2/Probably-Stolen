# [L2 执行层] map_builder.gd — 导航到关键界面并导出语义控件百分比矩形
extends Node

const DesktopDriver = preload("res://tests/control/desktop_driver.gd")
const Fixtures = preload("res://tests/execution/fixtures.gd")

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if not "--qa-visible" in args:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_POPUP, true)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
		DisplayServer.window_set_position(Vector2i(-8000, -8000))
	var main = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(0.5).timeout
	var driver := DesktopDriver.new(main)
	var fixtures = Fixtures.new(driver, GameState)
	var out := {}
	seed(20261117)
	GameState.rng.seed = 20261117
	out["welcome"] = driver.dump_screen("welcome")
	var dismissed := false
	for attempt in range(3):
		await driver.tap("welcome", "btn_original")
		var deadline := Time.get_ticks_msec() + 2000
		while driver.is_visible("welcome", "btn_original") and Time.get_ticks_msec() < deadline:
			await get_tree().create_timer(0.05).timeout
		if not driver.is_visible("welcome", "btn_original"):
			dismissed = true
			break
	if not dismissed:
		push_error("welcome not dismissed")
		get_tree().quit(2)
		return
	await driver.wait_visible("tutorial", "btn_skip", 5000)
	out["tutorial"] = driver.dump_screen("tutorial")
	await driver.tap("tutorial", "btn_skip")
	await fixtures.settle_main()
	out["main"] = driver.dump_screen("main")
	out["main"]["detail_open_btn"] = _rect_pct_rect(main.get("detail_open_btn").get_global_rect())
	for def_id in ["backpack_small", "nutrifruit"]:
		var uid := _find_uid(def_id)
		if uid > 0:
			var node := main.find_child("item_%d" % uid, true, false) as Control
			if node != null:
				out["main"]["item." + def_id] = _rect_pct_rect(node.get_global_rect())
	await driver.tap("main", "btn_inspect")
	await driver.wait_visible("inspection", "info", 3000)
	out["inspection"] = driver.dump_screen("inspection")
	await driver.tap("inspection", "btn_close")
	await fixtures.settle_main()
	await driver.tap("main", "btn_bargain")
	await driver.wait_visible("modal", "btn_quote", 3000)
	out["modal"] = driver.dump_screen("modal")
	await driver.tap("modal", "btn_close")
	await driver.tap("main", "btn_deal")
	await get_tree().create_timer(0.3).timeout
	await fixtures.settle_main()
	out["modal"].merge(driver.dump_screen("modal"), true)
	if _find_uid("backpack_small") > 0:
		await driver.tap_item_def("backpack_small")
		await driver.tap("main", "detail_open_btn")
		await driver.wait_visible("container", "title", 3000)
		out["container"] = driver.dump_screen("container")
		var grid: Control = main.get("container_grid")
		out["container"]["cell_2_2"] = _rect_pct_rect(Rect2(grid.global_position + Vector2(2 * 50, 2 * 50), Vector2(42, 42)))
		await driver.tap("container", "btn_close")
	await fixtures.open_machines()
	out["machines"] = driver.dump_screen("machines")
	await fixtures.select_machine("list_furnace")
	out["machines_detail"] = driver.dump_screen("machines")
	out["machines"].merge(out["machines_detail"], true)
	await driver.tap("machines", "btn_close")
	await driver.tap("main", "btn_factions")
	await get_tree().create_timer(0.2).timeout
	out["info"] = driver.dump_screen("info")
	await driver.tap("info", "btn_close")
	await driver.tap("main", "btn_end_day")
	await driver.wait_visible("modal", "btn_next_day", 3000)
	out["modal"].merge(driver.dump_screen("modal"), true)
	var out_path := _arg(OS.get_cmdline_user_args(), "--qa-out", "user://control_map.json")
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(out, "\t"))
	get_tree().quit(0)

func _find_uid(def_id: String) -> int:
	for it in GameState.inventory:
		if String(it.get("def_id", "")) == def_id:
			return int(it["uid"])
	return -1

func _rect_pct_rect(r: Rect2) -> Dictionary:
	var view := get_viewport().get_visible_rect().size
	return {"x": r.position.x / view.x, "y": r.position.y / view.y,
			"w": r.size.x / view.x, "h": r.size.y / view.y}

func _arg(args: PackedStringArray, name: String, fallback: String) -> String:
	for a in args:
		if a.begins_with(name + "="):
			return a.substr(name.length() + 1)
	return fallback
