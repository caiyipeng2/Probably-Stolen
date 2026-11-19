extends SceneTree
var fails := 0
func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok: fails += 1
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("normal", "original", "water_merchant", [])
	check(gs.current_customer.is_empty() or gs.auto_customer_flow, "headless auto flow test baseline")
	gs.auto_customer_flow = false
	gs.customers_today = [{"arche": {"faction": "lower", "name": "A"}, "intent": "sell", "item": {"uid": 901, "def_id": "nutrifruit", "asking_price": 100, "min_price": 70, "known": true, "condition": 100}, "done": false}, {"arche": {"faction": "lower", "name": "B"}, "intent": "sell", "item": {"uid": 902, "def_id": "nutrifruit", "asking_price": 100, "min_price": 70, "known": true, "condition": 100}, "done": false}]
	gs.current_index = -1
	gs.current_customer = {}
	gs.phase = "open"
	var ring: Dictionary = gs.summon_customer()
	check(bool(ring.get("ok", false)) and gs.current_customer.get("arche", {}).get("name", "") == "A", "bell summons first customer")
	var c: Dictionary = gs.current_customer
	check(c.get("bargain_direction", 0) == 0, "bargain direction unlocked")
	var d: Dictionary = gs.bargain_choose_direction(-1)
	check(bool(d.get("ok", false)) and int(gs.current_customer.get("bargain_direction", 0)) == -1, "bargain discount chosen")
	var p: Dictionary = gs.bargain_choose_percent(10)
	check(bool(p.get("ok", false)) and bool(gs.current_customer.get("bargain_locked", false)), "bargain lock applied", str(p.get("price", 0)))
	var again: Dictionary = gs.bargain_choose_direction(1)
	check(not bool(again.get("ok", false)), "bargain direction cannot change")
	var again2: Dictionary = gs.bargain_choose_percent(5)
	check(not bool(again2.get("ok", false)), "bargain percent cannot change")
	gs.add_item(gs.make_item("nutrifruit", 100, true, false))
	gs.complete_customer(true)
	check(gs.current_customer.is_empty() and gs.phase == "open", "manual flow waits for bell")
	var ring2: Dictionary = gs.summon_customer()
	check(bool(ring2.get("ok", false)) and gs.current_customer.get("arche", {}).get("name", "") == "B", "bell summons next customer")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
