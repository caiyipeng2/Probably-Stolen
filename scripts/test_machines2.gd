extends SceneTree
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	for id in ["auto_butcher", "blender", "feed_dispenser"]:
		var r = gs.start_machine(id)
		print(id, " start=", r)
		gs._process(15.0)
	print("meat_scrap=", gs.inventory_count("meat_scrap"), " juice=", gs.inventory_count("processed_juice"), " feed=", gs.inventory_count("industrial_fish_feed"))
	quit()
