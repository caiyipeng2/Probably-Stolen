extends SceneTree
var fails := 0
func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok: fails += 1
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("normal", "original", "apprentice", [])
	check(gs.store_buy_price() == 12000, "buy price normal", str(gs.store_buy_price()))
	check(gs.mortgage_down_payment() == 2000, "down payment normal", str(gs.mortgage_down_payment()))
	check(gs.mortgage_weekly_for(12000, 2000) == 930, "weekly payment normal", str(gs.mortgage_weekly_for(12000, 2000)))
	gs.cash = 13000
	var bought: Dictionary = gs.buy_out_store()
	check(bool(bought.get("ok", false)) and gs.property_owned and gs.cash == 1000, "cash buyout", str(gs.cash))
	check(gs.achievements_unlocked.has("ACH_BUYOUT"), "buyout achievement")
	check(gs.inventory_count("deed") >= 1, "deed granted")
	var summary: Dictionary = gs.finish_day()
	check(String(summary.get("gameover", "")) == "" and int(summary.get("rent_paid", -1)) == 0, "no rent after ownership")
	gs.new_game("normal", "original", "apprentice", [])
	gs.cash = 5000
	var mort: Dictionary = gs.take_mortgage()
	check(bool(mort.get("ok", false)) and gs.is_paying_mortgage and gs.cash == 3000, "mortgage taken", str(gs.cash))
	check(gs.mortgage_week_left == 12 and gs.mortgage_weekly_payment == 930, "mortgage terms", "%d/%d" % [gs.mortgage_week_left, gs.mortgage_weekly_payment])
	gs.cash = 930 * 12
	for i in range(12):
		gs.mortgage_due = 0
		gs.finish_day()
	check(gs.property_owned and not gs.is_paying_mortgage, "mortgage paid off")
	var saved: bool = gs.save_game(2)
	gs.property_owned = false
	gs.load_game(2)
	check(saved and gs.property_owned, "property persisted")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
