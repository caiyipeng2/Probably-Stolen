# [L2 执行层] growth.gd — 水培播种、成熟与收获周期
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	var start = state.start_machine("hydroponic")
	check(String(start.get("text", "")).contains("已播种"), "seeded", String(start.get("text", "")))
	var early = state.harvest_machine("hydroponic")
	check(String(early.get("text", "")).contains("不能收获"), "not ready", String(early.get("text", "")))
	for i in range(5):
		state.advance_machines_one_cycle()
	check(bool(state.machine_jobs[0].get("ready", false)), "ready")
	check_eq(int(state.machine_jobs[0].get("harvests_left", 0)), 3, "harvests left")
	var texts := []
	for i in range(3):
		var h = state.harvest_machine("hydroponic")
		texts.append(String(h.get("text", "")))
		for j in range(5):
			state.advance_machines_one_cycle()
	check(texts[0].contains("还可收获 2 次"), "harvest 1", texts[0])
	check(texts[1].contains("还可收获 1 次"), "harvest 2", texts[1])
	check(texts[2].contains("作物已耗尽"), "harvest 3", texts[2])
	check_eq(state.machine_jobs.size(), 0, "jobs cleared")
	check_eq(state.inventory_count("nutrifruit"), 2, "fruit count")
	state.add_item(state.make_item("nutrifruit_seed", 100, true, false))
	state.add_item(state.make_item("water_jug", 100, true, false))
	var replant = state.start_machine("hydroponic")
	check(String(replant.get("text", "")).contains("已播种"), "replant", String(replant.get("text", "")))

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
