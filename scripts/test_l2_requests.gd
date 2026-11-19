extends SceneTree
var fails := 0
func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok: fails += 1
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("normal", "original", "apprentice", [])
	check(gs.store_request_defs.get("requests", []).size() == 29, "store request catalogue", str(gs.store_request_defs.get("requests", []).size()))
	gs.owned_upgrades["MARKETPLACE_REQUESTS"] = true
	gs.day = 9
	gs._marketplace_unlock()
	check(gs.marketplace_unlocked_day == 9 and not gs.store_requests.is_empty(), "marketplace unlock requests", str(gs.store_requests.size()))
	gs.add_item(gs.make_item("eng_box", 100, true, false))
	gs.day = 10
	gs._add_store_request_by_id("meteor_ll")
	var before_cash: int = gs.cash
	var res: Dictionary = gs.fill_store_request("meteor_ll")
	check(bool(res.get("ok", false)) and gs.cash > before_cash, "fill request reward", str(res.get("text", "")))
	check(not gs.store_requests.any(func(r): return String(r.get("id", "")) == "meteor_ll"), "request removed")
	gs.add_item(gs.make_item("toilet_paper", 100, true, false))
	gs.add_item(gs.make_item("toilet_paper", 100, true, false))
	gs.add_item(gs.make_item("toilet_paper", 100, true, false))
	gs.add_item(gs.make_item("toilet_paper", 100, true, false))
	gs._add_store_request_by_id("unique_georgio_tp")
	var dup: bool = gs._add_store_request_by_id("unique_georgio_tp")
	check(not dup and gs.store_request_seen.has("unique_georgio_tp"), "unique request not duplicated")
	var saved: bool = gs.save_game(2)
	gs.store_requests = []
	gs.load_game(2)
	check(saved and not gs.store_requests.is_empty(), "store requests persisted")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
