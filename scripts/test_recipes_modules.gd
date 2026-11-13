extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	var recipes := 0
	for m in gs.machines:
		recipes += m.get("recipes", []).size()
	print("machines=", gs.machines.size(), " recipes=", recipes, " modules=", gs.modules_def.size())
	gs.set_machine_recipe("printer", "printer_chip_pistol_double")
	print("printer recipe=", gs.machine_recipe("printer").get("id", ""), " cycles=", gs.machine_recipe("printer").get("cycles", 0))
	var r = gs.start_machine("printer")
	print("printer start=", r.get("text", ""), " remaining=", gs.machine_jobs[0].get("remaining", 0) if not gs.machine_jobs.is_empty() else -1)
	gs.install_module("furnace", "system_module_performance")
	var f = gs.start_machine("furnace")
	print("furnace module start=", f.get("text", ""), " remaining=", gs.machine_jobs[-1].get("remaining", 0) if not gs.machine_jobs.is_empty() else -1)
	gs.save_game()
	gs.new_game()
	gs.load_game()
	print("loaded recipe=", gs.machine_recipes.get("printer", ""), " module=", gs.machine_modules.get("furnace", ""))
	quit()
