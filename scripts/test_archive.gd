extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	var total := 0
	for g in gs.dialogue_archive:
		total += g.get("entries", []).size()
	print("archive groups=", gs.dialogue_archive.size(), " total=", total)
	if not gs.dialogue_archive.is_empty():
		print("first=", gs.dialogue_archive[0].get("name", ""), " entries=", gs.dialogue_archive[0].get("entries", []).size())
	quit()
