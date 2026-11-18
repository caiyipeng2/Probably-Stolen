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
	check(gs.wanted.size() >= 24, "wanted roster 24+", str(gs.wanted.size()))
	var w: Dictionary = gs.wanted[0]
	var cash0: int = gs.cash
	gs.current_customer = {"intent": "wanted_visit", "wanted_id": String(w["id"]), "arche": {"name": String(w["name"])}, "done": false}
	gs.customers_today = []
	var rep: Dictionary = gs.report_wanted(String(w["id"]))
	check(bool(rep.get("ok", false)) and gs.cash == cash0 + int(w["reward"]) and gs.wanted_defeated.has(String(w["id"])), "wanted report reward", str(rep))
	var cash1: int = gs.cash
	gs.current_customer = {}
	var false_rep: Dictionary = gs.report_wanted("")
	check(bool(false_rep.get("ok", false)) and gs.cash == cash1 - 100, "false report fine", str(false_rep))
	var w2: Dictionary = gs.wanted[1]
	gs.current_customer = {"intent": "wanted_visit", "wanted_id": String(w2["id"]), "arche": {"name": String(w2["name"])}, "done": false}
	var eng: Dictionary = gs.engage_wanted_visit()
	check(bool(eng.get("ok", false)) and gs.combat_active, "wanted visit combat", str(eng))
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
