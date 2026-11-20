extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func fresh() -> Node:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("normal")
	gs.rng.seed = 20261119
	return gs

func _init() -> void:
	var gs = fresh()
	gs.day = 5
	gs.cash = 777
	check(gs.save_game(3), "save slot 3")
	check(gs.has_save(3), "has_save after write")
	var meta: Dictionary = gs.save_meta(3)
	check(int(meta.get("day", 0)) == 5 and int(meta.get("cash", 0)) == 777, "metadata day/cash", str(meta))
	check(String(meta.get("saved_at_text", "")) != "", "metadata saved time")
	check(gs.save_slot_label(3).contains("第 5 天"), "slot label shows day", gs.save_slot_label(3))

	gs.day = 6
	gs.cash = 888
	check(gs.save_game(3), "second save")
	var prev := {}
	var pf := FileAccess.open("user://save_3_prev.json", FileAccess.READ)
	if pf:
		prev = JSON.parse_string(pf.get_as_text())
		pf.close()
	check(int(prev.get("day", 0)) == 5, "previous save kept as backup", str(prev.get("day", 0)))

	var cf := FileAccess.open("user://save_3.json", FileAccess.WRITE)
	cf.store_string("not json at all")
	cf.close()
	var gs2 = fresh()
	check(gs2.load_game(3), "load falls back to backup")
	check(gs2.day == 5, "backup day restored", str(gs2.day))
	check(gs2.night_log.size() > 0 and String(gs2.night_log[-1]).contains("备份"), "recovery logged", str(gs2.night_log[-1] if not gs2.night_log.is_empty() else ""))
	var restored := {}
	var rf := FileAccess.open("user://save_3.json", FileAccess.READ)
	if rf:
		restored = JSON.parse_string(rf.get_as_text())
		rf.close()
	check(not restored.is_empty(), "primary restored from backup")

	var rep: Dictionary = gs2.repair_save(3)
	check(bool(rep.get("ok", false)), "repair_save ok", str(rep))
	check(gs2.save_slot_label(3).contains("第 5 天"), "label after repair", gs2.save_slot_label(3))

	var src := FileAccess.get_file_as_string("res://scripts/main.gd")
	check(src.contains("save_slot_label") and src.contains("repair_save"), "load UI uses metadata and repair")

	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
