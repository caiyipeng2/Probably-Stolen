# [L2 执行层] inspect_flow.gd — 验货面板与放大镜
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)
	check(await fixtures.ensure_customer_intent("sell"), "sell customer")
	check(driver.read_text("main", "customer_info").contains("出售物品"), "sell info", driver.read_text("main", "customer_info"))

func run() -> void:
	check(await driver.tap("main", "btn_inspect"), "open inspection")
	check(await driver.wait_visible("inspection", "info", 3000), "inspection visible")
	var info: String = driver.read_text("inspection", "info")
	check(info.length() > 0 and info.contains("特征"), "inspection info", info.substr(0, 80))
	await shot("inspect_initial")
	if driver.is_visible("inspection", "btn_magnifier"):
		check(await driver.tap("inspection", "btn_magnifier"), "use magnifier")
		await driver.root.get_tree().create_timer(0.2).timeout
		check(driver.read_text("inspection", "info").contains("工具记录"), "tool note added")
		await shot("inspect_tool")
	check(await driver.tap("inspection", "btn_close"), "close inspection")
	check(not driver.is_visible("inspection", "info"), "inspection closed")
