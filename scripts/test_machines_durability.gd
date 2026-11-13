extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	gs.machine_durability["furnace"] = 1
	print("start=", gs.start_machine("furnace").get("ok", false))
	for i in range(3): gs.advance_machines_one_cycle()
	print("durability after job=", gs.machine_durability.get("furnace", 100), " ingot=", gs.inventory_count("metal_ingot"))
	print("start broken=", gs.start_machine("furnace").get("text", ""))
	print("repair cost=", gs.machine_repair_cost("furnace"), " result=", gs.repair_machine("furnace").get("text", ""))
	print("durability repaired=", gs.machine_durability.get("furnace", 100))
	for i in range(2):
		gs.add_item(gs.make_item("scrap_metal", 100, true, false))
	print("start repaired=", gs.start_machine("furnace").get("ok", false))
	gs.machine_durability["water_purifier"] = 42
	gs.save_game()
	gs.new_game()
	gs.load_game()
	print("loaded durability=", gs.machine_durability.get("water_purifier", -1))
	quit()
