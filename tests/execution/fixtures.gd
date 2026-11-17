# [L2 执行层] fixtures.gd — 通用前置/后置动作，禁止写业务断言
extends RefCounted

var driver
var state

func _init(desktop_driver, game_state) -> void:
	driver = desktop_driver
	state = game_state

func close_modal() -> bool:
	for key in ["btn_close", "btn_know", "btn_continue"]:
		if driver.is_visible("modal", key):
			return await driver.tap("modal", key)
	return false

func skip_tutorial() -> bool:
	if driver.is_visible("tutorial", "btn_skip"):
		await driver.tap("tutorial", "btn_skip")
		await driver.root.get_tree().create_timer(0.2).timeout
		return true
	return false

func settle_main() -> bool:
	await driver.root.get_tree().create_timer(0.5).timeout
	for i in range(4):
		await skip_tutorial()
		if driver.is_visible("story", "layer"):
			await skip_story()
		await close_modal()
		await driver.root.get_tree().create_timer(0.2).timeout
	return driver.is_visible("main", "day_label")

func skip_story() -> bool:
	var guard := 0
	while guard < 40:
		if driver.is_visible("story", "btn_continue"):
			await driver.tap("story", "btn_continue")
		elif await driver.tap_first_in("story_choices"):
			pass
		else:
			break
		await driver.root.get_tree().create_timer(0.1).timeout
		guard += 1
	return not driver.root.story_layer.visible

func boot_to_main(difficulty := "normal", mode := "mobile", seed_value := 20261117, skip_story_after := true) -> bool:
	seed(seed_value)
	state.rng.seed = seed_value
	var welcome_key := "btn_original" if mode == "original" else ("btn_easy" if difficulty == "easy" else ("btn_hard" if difficulty == "hard" else "btn_normal"))
	if not await driver.wait_visible("welcome", welcome_key, 8000):
		return false
	var dismissed := false
	for attempt in range(3):
		await driver.tap("welcome", welcome_key)
		var deadline := Time.get_ticks_msec() + 2000
		while driver.is_visible("welcome", welcome_key) and Time.get_ticks_msec() < deadline:
			await driver.root.get_tree().create_timer(0.05).timeout
		if not driver.is_visible("welcome", welcome_key):
			dismissed = true
			break
	if not dismissed:
		return false
	await driver.root.get_tree().create_timer(0.3).timeout
	if driver.is_visible("tutorial", "btn_skip"):
		await driver.tap("tutorial", "btn_skip")
	await driver.root.get_tree().create_timer(0.2).timeout
	if skip_story_after:
		await settle_main()
	return await driver.wait_visible("main", "day_label", 5000)

func ensure_customer_intent(intent: String) -> bool:
	var label := "出售物品" if intent == "sell" else ("委托估价" if intent == "appraise" else "想买东西")
	var guard := 0
	while guard < 8:
		await skip_tutorial()
		await close_modal()
		var info: String = driver.read_text("main", "customer_info")
		if info.contains(label):
			return true
		if not await driver.tap("main", "btn_dismiss"):
			return false
		await driver.root.get_tree().create_timer(0.25).timeout
		await skip_story()
		await skip_tutorial()
		guard += 1
	return false

func place_inventory_on_counter(uid: int) -> bool:
	if not await driver.tap_item_uid(uid):
		return false
	if not await driver.tap("main", "detail_display_btn"):
		return false
	await driver.root.get_tree().process_frame
	var display := driver.root.find_child("display_%d" % uid, true, false) as Control
	if display == null:
		return false
	if not await driver.tap_control(display):
		return false
	await driver.root.get_tree().process_frame
	return await driver.tap("main", "detail_counter_btn")

func end_day() -> bool:
	if not await driver.tap("main", "btn_end_day"):
		return false
	if not await driver.wait_visible("modal", "btn_next_day", 5000):
		return false
	if not await driver.tap("modal", "btn_next_day"):
		return false
	return await driver.wait_visible("main", "day_label", 5000)

func open_machines() -> bool:
	if not await driver.tap("main", "btn_machines"):
		return false
	return await driver.wait_visible("machines", "btn_close", 5000)

func select_machine(key: String) -> bool:
	var spec: Dictionary = driver.ui_map.get("screens", {}).get("machines", {}).get(key, {})
	var text := String(spec.get("text_contains", ""))
	for attempt in range(3):
		var scroll = driver.root.get("machine_scroll")
		if scroll is ScrollContainer:
			scroll.scroll_vertical = 0
			await driver.root.get_tree().process_frame
		var btn: Control = null
		for i in range(10):
			btn = driver.find_text_contains("machines", text)
			if btn != null:
				break
			await driver.tap("machines", "btn_scroll_down")
		if btn != null:
			if scroll is ScrollContainer:
				scroll.ensure_control_visible(btn)
				await driver.root.get_tree().process_frame
			if await driver.tap_control(btn):
				await driver.root.get_tree().create_timer(0.3).timeout
				if driver.read_text("machines", "title").contains(text):
					return true
		await driver.root.get_tree().create_timer(0.2).timeout
	return false

func reset_machine_scroll() -> void:
	var scroll = driver.root.get("machine_scroll")
	if scroll is ScrollContainer:
		scroll.scroll_vertical = 0
		await driver.root.get_tree().create_timer(0.2).timeout

func open_minigame(machine_id: String) -> bool:
	var main = driver.root
	state.power = 100
	state.add_item(state.make_item("metal_ingot", 100, true, false))
	state.add_item(state.make_item("printer_plastic", 100, true, false))
	if state.items_def.has("dream_cap"):
		state.add_item(state.make_item("dream_cap", 100, true, false))
		state.add_item(state.make_item("dream_cap", 100, true, false))
	state.add_item(state.make_item("nutrifruit_seed", 100, true, false))
	state.add_item(state.make_item("common_chemical", 100, true, false))
	main.call("_refresh")
	await driver.root.get_tree().process_frame
	main.selected_machine_id = machine_id
	match machine_id:
		"printer":
			main.call("_open_printer_minigame")
		"chem_finisher":
			main.call("_open_mix_minigame")
		"plant_dna_manipulator":
			main.call("_open_dna_minigame")
		_:
			return false
	await driver.root.get_tree().process_frame
	return true
