extends SceneTree
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	print("start pages=", gs.pages_unlocked, " inv=", gs.inventory.size())
	var containers=[]
	for id in gs.items_def:
		if String(gs.items_def[id].get("category","")) == "container":
			containers.append(id)
	print("containers=", containers.size(), " sample=", containers.slice(0,5))
	if gs.items_def.has("backpack_large"):
		gs.add_item(gs.make_item("backpack_large"))
		print("after one container pages=", gs.pages_unlocked, " inv=", gs.inventory.size())
	if containers.size()>1:
		gs.add_item(gs.make_item(containers[1]))
		print("after two containers pages=", gs.pages_unlocked, " inv=", gs.inventory.size())
	quit()
