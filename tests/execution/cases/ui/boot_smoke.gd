# [L2 执行层] boot_smoke.gd — 欢迎页到主界面的最小闭环
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)

func run() -> void:
	step("main screen after boot")
	check(not driver.is_visible("welcome", "btn_normal"), "welcome dismissed")
	check(driver.is_visible("main", "day_label"), "main visible")
	var day: String = driver.read_text("main", "day_label")
	var cash: String = driver.read_text("main", "cash_label")
	check(day.contains("第 1 天"), "day 1", day)
	check(cash.contains("600"), "cash 600", cash)
	check(driver.read_text("main", "customer_info").contains("意图："), "customer intent shown")
	await shot("main_day1")
