# [L2 执行层] machine_faults.gd — 故障禁用、维修、全面保养与读档
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	state.machine_faults["furnace"] = "jam"
	state.machine_durability["furnace"] = 60
	var start = state.start_machine("furnace")
	check(String(start.get("text", "")).contains("卡料"), "fault start text", String(start.get("text", "")))
	check_eq(state.machine_repair_cost("furnace"), 130, "fault repair cost")
	check_eq(state.machine_fault_name("jam"), "卡料", "fault name")
	check(String(state.repair_machine("furnace").get("text", "")).contains("已维修"), "fault repair")
	check(not state.machine_faults.has("furnace"), "fault cleared")
	check(bool(state.start_machine("furnace").get("ok", false)), "start after fault repair")
	state.machine_faults["water_purifier"] = "surge"
	state.machine_durability["water_purifier"] = 20
	state.pending_event = {"id": "repair_visit", "choices": [{"cash": -150, "rep": {}, "repair_all": true, "result": "test"}]}
	state.apply_event(0)
	check_eq(state.machine_faults.size(), 0, "repair all faults")
	check_eq(state.machine_durability.size(), 0, "repair all durability reset")
	state.machine_faults["printer"] = "contamination"
	check(state.save_game(9), "save slot9")
	state.new_game()
	check(state.load_game(9), "load slot9")
	check_eq(String(state.machine_faults.get("printer", "")), "contamination", "loaded fault")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
