# [L2 执行层] story_flow.gd — 开局剧情弹窗与推进
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value, false)

func run() -> void:
	check(driver.is_visible("story", "layer"), "story visible at boot")
	var before := int(state.scene_seen.size())
	check(await fixtures.skip_story(), "story skipped")
	await fixtures.settle_main()
	check(not driver.is_visible("story", "layer"), "story closed")
	check(driver.is_visible("main", "day_label"), "back to main")
	check(int(state.scene_seen.size()) > before, "scene marked seen", str(state.scene_seen.size()))
	await shot("after_story")
