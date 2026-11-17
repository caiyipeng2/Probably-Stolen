# [L2 执行层] trade_sell_flow.gd — 顾客出售：鉴定→议价→成交→日结
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)
	await fixtures.ensure_customer_intent("sell")

func run() -> void:
	var cash_before := int(state.cash)
	step("inspect counter item")
	check(await driver.tap("main", "btn_inspect"), "open inspection")
	check(await driver.wait_visible("inspection", "info", 3000), "inspection visible")
	var info: String = driver.read_text("inspection", "info")
	check(info.length() > 0 and info.contains("特征"), "inspection info", info.substr(0, 80))
	await shot("inspect_open")
	check(await driver.tap("inspection", "btn_close"), "close inspection")
	await fixtures.settle_main()
	step("bargain and deal")
	check(await driver.tap("main", "btn_bargain"), "open bargain")
	check(await driver.wait_visible("modal", "btn_quote", 3000), "bargain modal")
	await shot("bargain_modal")
	check(await driver.tap("modal", "btn_quote"), "quote")
	await driver.root.get_tree().create_timer(0.2).timeout
	check(driver.read_text("modal", "title").contains("议价"), "bargain result", driver.read_text("modal", "title"))
	check(await driver.tap("modal", "btn_close"), "close bargain result")
	check(await driver.tap("main", "btn_deal"), "deal")
	await driver.root.get_tree().create_timer(0.3).timeout
	await fixtures.settle_main()
	await driver.root.get_tree().create_timer(1.5).timeout
	await shot("after_deal")
	check(state.cash < cash_before, "cash spent", "%d -> %d" % [cash_before, int(state.cash)])
	step("end day")
	check(await fixtures.end_day(), "next day")
	check(driver.read_text("main", "day_label").contains("第 2 天"), "day 2")
	await shot("day2_main")
