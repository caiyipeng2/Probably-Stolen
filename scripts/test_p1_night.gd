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
	gs.display.clear()
	var item: Dictionary = gs.make_item("hand_gold", 100, true, false)
	item["x"] = 0
	item["y"] = 0
	gs.display.append(item)
	gs.owned_upgrades["INSURANCE"] = true
	var cash0: int = gs.cash
	for i in range(200):
		gs._night_burglary()
		if gs.display.is_empty():
			break
	check(gs.display.is_empty(), "night burglary steals display item")
	check(gs.cash > cash0, "insurance pays burglary value", str(gs.cash - cash0))
	var cash1: int = gs.cash
	var summary = gs.finish_day()
	check(gs.cash <= cash1 - 15 or String(summary.get("gameover", "")) != "", "insurance premium charged", str(cash1 - gs.cash))
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
