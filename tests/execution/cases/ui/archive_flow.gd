# [L2 执行层] archive_flow.gd — 信息网络档案页
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)

func run() -> void:
	var opened := false
	for attempt in range(3):
		await driver.tap("main", "btn_factions")
		if await driver.wait_visible("info", "list", 2000):
			opened = true
			break
	check(opened, "open info network")
	check(await driver.wait_visible("info", "list", 3000), "info list visible")
	if driver.is_visible("info", "tab_archive"):
		check(await driver.tap("info", "tab_archive"), "open archive tab")
	await driver.root.get_tree().create_timer(0.2).timeout
	var entry := driver.find_text_contains("info", "剧情顾客") as Button
	check(entry != null, "archive group found")
	if entry != null:
		check(entry.text.contains("463") or entry.text.contains("2544"), "archive entry count", entry.text)
	await shot("archive_page")
	check(await driver.tap("info", "btn_close"), "close info")
