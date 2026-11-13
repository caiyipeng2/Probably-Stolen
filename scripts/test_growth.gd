extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	print("start=", gs.start_machine("hydroponic").get("text", ""))
	print("harvest before ready=", gs.harvest_machine("hydroponic").get("text", ""))
	for i in range(5): gs.advance_machines_one_cycle()
	print("ready=", gs.machine_jobs[0].get("ready", false), " left=", gs.machine_jobs[0].get("harvests_left", 0))
	for i in range(3):
		print("harvest ", i + 1, "=", gs.harvest_machine("hydroponic").get("text", ""))
		for j in range(5): gs.advance_machines_one_cycle()
	print("jobs after=", gs.machine_jobs.size(), " fruit=", gs.inventory_count("nutrifruit"))
	gs.add_item(gs.make_item("nutrifruit_seed", 100, true, false))
	gs.add_item(gs.make_item("water_jug", 100, true, false))
	print("replant=", gs.start_machine("hydroponic").get("text", ""))
	quit()
