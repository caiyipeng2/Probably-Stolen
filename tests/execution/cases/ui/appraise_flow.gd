# [L2 执行层] appraise_flow.gd — 估价输入与提交
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)
	await fixtures.ensure_customer_intent("appraise")

func run() -> void:
	check(driver.read_text("main", "customer_info").contains("委托估价"), "appraise customer")
	check(driver.read_text("main", "btn_inspect").contains("估价"), "action renamed to appraise")
	check(await driver.tap("main", "btn_inspect"), "open appraisal")
	check(await driver.wait_visible("inspection", "input", 3000), "input visible")
	var value := int(state.counter_item.get("appraisal_value", 620))
	var cash_before := int(state.cash)
	var progress_before := float(state.appraisal_progress)
	check(driver.type_text("inspection", "input", str(value)), "type appraisal")
	check(await driver.tap("inspection", "btn_submit"), "submit appraisal")
	await driver.root.get_tree().create_timer(0.3).timeout
	await fixtures.skip_tutorial()
	await fixtures.close_modal()
	await shot("after_appraisal")
	check(state.cash > cash_before, "appraisal fee earned", "%d -> %d" % [cash_before, int(state.cash)])
	check(float(state.appraisal_progress) > progress_before, "appraisal progress", str(state.appraisal_progress))
