extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	gs.rng.seed = 20261119
	check(gs.combat_parties.size() == 11, "party data", str(gs.combat_parties.size()))
	gs.start_combat("field_technician", "lower", "", "", "standard")
	var enemies := 0
	for u in gs.combat_units:
		if int(u.get("team", 0)) == 1:
			enemies += 1
	check(enemies == 3, "standard party size", str(enemies))
	check(gs.combat_units.size() == 4, "player plus party", str(gs.combat_units.size()))
	for u in gs.combat_units:
		if int(u.get("team", 0)) == 1:
			gs._combat_damage(u, 999, "测试")
	gs._combat_check_end()
	check(not gs.combat_active, "party defeated ends combat")
	gs.start_combat("pirate_chief", "lower", "", "", "pirateChielfVeteranFull")
	enemies = 0
	for u in gs.combat_units:
		if int(u.get("team", 0)) == 1:
			enemies += 1
	check(enemies == 4, "pirate full party size", str(enemies))
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
