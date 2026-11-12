extends SceneTree
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	var n := 0
	var names_fb := 0
	var values_fb := 0
	var no_icon := 0
	for id in gs.tradable_pool:
		n += 1
		var d = gs.items_def[id]
		if String(d.get("name", "")) == id:
			names_fb += 1
		if not bool(d.get("unit_value_found", true)):
			values_fb += 1
		if String(d.get("icon", "")) == "":
			no_icon += 1
	print("defs=", gs.items_def.size(), " tradable=", n, " names_fb=", names_fb, " values_fb=", values_fb, " no_icon=", no_icon, " pages=", gs.pages_unlocked)
	quit()
