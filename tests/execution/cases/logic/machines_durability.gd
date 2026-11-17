# [L2 执行层] machines_durability.gd — 耐久磨损、损坏、维修与读档
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	state.machine_durability["furnace"] = 1
	check(bool(state.start_machine("furnace").get("ok", false)), "start with low durability")
	for i in range(3):
		state.advance_machines_one_cycle()
	check_eq(int(state.machine_durability.get("furnace", 100)), 0, "durability depleted")
	check_eq(state.inventory_count("metal_ingot"), 0, "no ingot when broken")
	check(String(state.start_machine("furnace").get("text", "")).contains("已损坏"), "start broken text")
	check_eq(state.machine_repair_cost("furnace"), 100, "repair cost")
	check(String(state.repair_machine("furnace").get("text", "")).contains("已维修"), "repair result")
	check_eq(int(state.machine_durability.get("furnace", 100)), 100, "durability repaired")
	for i in range(2):
		state.add_item(state.make_item("scrap_metal", 100, true, false))
	check(bool(state.start_machine("furnace").get("ok", false)), "start after repair")
	state.machine_durability["water_purifier"] = 42
	check(state.save_game(9), "save slot9")
	state.new_game()
	check(state.load_game(9), "load slot9")
	check_eq(float(state.machine_durability.get("water_purifier", -1)), 42.0, "loaded durability")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
