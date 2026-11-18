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
	gs.sec_inspection_pending = false
	check(gs.procurement_defs.get("templates", []).size() == 2, "procurement templates", str(gs.procurement_defs.get("templates", []).size()))
	gs.procurement_orders = [{"template_id": "machinist"}]
	var nurse: Dictionary = gs._gen_procurement_offer_customer()
	gs.procurement_orders = []
	check(String(nurse.get("procurement_id", "")) == "nurse" and int(nurse.get("count", 0)) == 5, "nurse offer", str(nurse.get("procurement_id", "")))
	check(int(nurse.get("reward", 0)) >= 100 and int(nurse.get("reward", 0)) <= 125, "nurse reward range", str(nurse.get("reward", 0)))
	gs.customers_today = []
	gs.current_customer = nurse
	var accepted: Dictionary = gs.accept_procurement()
	check(bool(accepted.get("ok", false)) and gs.procurement_orders.size() == 1, "procurement accepted", str(accepted))
	var order: Dictionary = gs.procurement_orders[0]
	check(int(order.get("due_day", 0)) == 1 + 3, "nurse deadline", str(order.get("due_day", 0)))
	check(gs.inventory_count("procurement_slip") == 1, "procurement slip granted")
	var collect: Dictionary = gs._gen_procurement_collect_customer(order)
	gs.current_customer = collect
	for i in range(5):
		gs.add_item(gs.make_item("blood_bag", 100, true, false))
	var cash_before: int = gs.cash
	var delivered: Dictionary = gs.collect_procurement()
	check(bool(delivered.get("ok", false)) and gs.procurement_orders.is_empty(), "procurement delivered", str(delivered))
	check(gs.cash == cash_before + int(order.get("reward", 0)) and gs.inventory_count("blood_bag") == 0, "procurement payment and consumption")
	gs.new_game()
	gs.sec_inspection_pending = false
	gs.day = 10
	gs.procurement_orders = [{"id": "pr_test", "template_id": "machinist", "item_id": "metal_ingot", "count": 3, "due_day": 14, "reward": 195, "client_name": "机械师"}]
	gs.save_game(2)
	gs.new_game()
	gs.load_game(2)
	check(gs.procurement_orders.size() == 1 and int(gs.procurement_orders[0].get("count", 0)) == 3, "procurement orders saved", str(gs.procurement_orders))
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
