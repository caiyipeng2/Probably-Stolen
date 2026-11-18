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
	check(gs.showcase_size() == [7, 5], "base showcase size", str(gs.showcase_size()))
	gs.owned_upgrades["SHOWCASE_I"] = true
	check(gs.showcase_size() == [8, 6], "showcase I size", str(gs.showcase_size()))
	gs.owned_upgrades["SHOWCASE_II"] = true
	check(gs.showcase_size() == [9, 7], "showcase II size", str(gs.showcase_size()))
	var it: Dictionary = gs.make_item("nutrifruit", 100, true, false)
	check(gs.display_can_place(it, 8, 6, false), "showcase expanded placement")
	gs.poster_pulled = false
	var hidden: Dictionary = gs.make_item("glock_receiver", 100, true, false)
	hidden["page"] = 2
	hidden["location"] = "backpack"
	gs.inventory.append(hidden)
	gs.sec_inspection_personality = 0
	check(not gs.sec_inspection_candidates().has(hidden), "poster closed hides compartment")
	gs.toggle_poster()
	check(gs.sec_inspection_candidates().has(hidden), "poster pulled exposes compartment")
	var box: Dictionary = gs.make_item("sec_box", 100, true, false)
	gs.add_item(box)
	check(gs.breach_container(int(box.uid)).get("ok", true) == false, "breach needs tool")
	gs.add_item(gs.make_item("crowbar", 100, true, false))
	box["container_spec"]["lock_difficulty"] = -1000
	var unlocked := false
	for i in range(5):
		if bool(gs.breach_container(int(box.uid)).get("ok", false)):
			unlocked = true
			break
	check(unlocked and not bool(box.get("container_locked", true)), "crowbar breaches lock")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
