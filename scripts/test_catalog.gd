extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	print("items=", gs.items_def.size(), " tradable=", gs.tradable_pool.size())
	print("sample=", gs.tradable_pool.slice(0, 12))
	for id in ["beis_icecream", "bandage_item", "hand_gold", "water_bottle_full"]:
		var d = gs.items_def.get(id, {})
		print(id, " name=", d.get("name", "?"), " value=", d.get("base_value", 0), " icon=", d.get("icon", ""), " category=", d.get("category", ""))
	quit()
