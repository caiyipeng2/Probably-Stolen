# [L2 执行层] machines2.gd — 屠宰/搅拌/饲料辅助设备
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	for k in range(3):
		state.add_item(state.make_item("nutrifruit", 100, true, false))
	for id in ["auto_butcher", "blender", "livestock_feed_dispenser"]:
		var r = state.start_machine(id)
		if id == "blender":
			check(bool(r.get("ok", false)), "blender start", String(r.get("text", "")))
		else:
			check(not bool(r.get("ok", true)), id + " is aux", String(r.get("text", "")))
			check(String(r.get("text", "")).contains("辅助设备"), id + " aux text")
		for i in range(3):
			state.advance_machines_one_cycle()
	check_eq(state.inventory_count("meat_scrap"), 2, "meat scrap")
	check_eq(state.inventory_count("processed_juice"), 0, "juice")
	check_eq(state.inventory_count("industrial_fish_feed"), 2, "feed")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
