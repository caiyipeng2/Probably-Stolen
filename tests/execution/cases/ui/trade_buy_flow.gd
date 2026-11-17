# [L2 执行层] trade_buy_flow.gd — 顾客购买：上架→放柜台→议价→成交
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)
	await fixtures.ensure_customer_intent("buy")

func run() -> void:
	var cash_before := int(state.cash)
	var uid := int(state.inventory[0]["uid"])
	step("put item on counter")
	check(await fixtures.place_inventory_on_counter(uid), "item on counter")
	check(not state.counter_item.is_empty(), "counter item set")
	await shot("counter_item")
	step("deal")
	check(await driver.tap("main", "btn_deal"), "deal")
	await driver.root.get_tree().create_timer(0.3).timeout
	await fixtures.skip_tutorial()
	await fixtures.close_modal()
	await driver.root.get_tree().create_timer(1.5).timeout
	await shot("after_deal")
	check(state.cash > cash_before, "cash earned", "%d -> %d" % [cash_before, int(state.cash)])
	check(state.counter_item.is_empty(), "counter cleared")
