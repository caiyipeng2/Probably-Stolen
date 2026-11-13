extends SceneTree
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	for k in range(3):
		gs.add_item(gs.make_item("nutrifruit", 100, true, false))
	for id in ["auto_butcher", "blender", "livestock_feed_dispenser"]:
		var r = gs.start_machine(id)
		print(id, " start=", r)
		for i in range(3): gs.advance_machines_one_cycle()
	print("meat_scrap=", gs.inventory_count("meat_scrap"), " juice=", gs.inventory_count("processed_juice"), " feed=", gs.inventory_count("industrial_fish_feed"))
	quit()
