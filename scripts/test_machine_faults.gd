extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	gs.machine_faults["furnace"] = "jam"
	gs.machine_durability["furnace"] = 60
	print("fault start=", gs.start_machine("furnace").get("text", ""))
	print("fault cost=", gs.machine_repair_cost("furnace"), " name=", gs.machine_fault_name("jam"))
	print("fault repair=", gs.repair_machine("furnace").get("text", ""), " fault=", gs.machine_faults.has("furnace"))
	print("fault start2=", gs.start_machine("furnace").get("ok", false))
	gs.machine_faults["purifier"] = "surge"
	gs.machine_durability["purifier"] = 20
	gs.pending_event = {"id": "repair_visit", "choices": [{"cash": -150, "rep": {}, "repair_all": true, "result": "test"}]}
	gs.apply_event(0)
	print("repair_all faults=", gs.machine_faults.size(), " durability=", gs.machine_durability.size())
	gs.machine_faults["printer"] = "contamination"
	gs.save_game()
	gs.new_game()
	gs.load_game()
	print("loaded fault=", gs.machine_faults.get("printer", ""))
	quit()
