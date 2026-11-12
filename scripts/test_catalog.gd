extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	print("items=", gs.items_def.size(), " tradable=", gs.tradable_pool.size())
	print("sample=", gs.tradable_pool.slice(0, 12))
	for id in ["beis_icecream", "bandage_item", "hand_gold", "water_bottle_full"]:
		var d = gs.items_def.get(id, {})
		print(id, " name=", d.get("name", "?"), " value=", d.get("base_value", 0), " icon=", d.get("icon", ""), " category=", d.get("category", ""))
	gs.new_game()
	for i in range(40):
		gs.add_item(gs.make_item("cig_red"))
	var pages := {}
	for it in gs.inventory:
		var pg := int(it.get("page", 0))
		pages[pg] = int(pages.get(pg, 0)) + 1
	print("pages=", pages, " inv=", gs.inventory.size())
	quit()
