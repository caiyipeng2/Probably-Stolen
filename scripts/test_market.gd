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
	var apple: Dictionary = gs.make_item("nutrifruit", 100, true, false)
	gs.market_modifiers["FOOD"] = 0
	var base: int = gs.market_value(apple, false)
	gs.market_modifiers["FOOD"] = 50
	check(gs.market_value(apple, false) > base, "food shortage raises price", "%d>%d" % [gs.market_value(apple, false), base])
	gs.market_modifiers["FOOD"] = -20
	check(gs.market_value(apple, false) < base, "food surplus lowers price")
	gs.market_modifiers["FOOD"] = 40
	gs.customers_today = []
	gs.start_day()
	var shortage := false
	for c in gs.customers_today:
		if String(c.get("market_kind", "")) == "shortage" and String(c.get("market_type", "")) == "FOOD":
			shortage = true
	check(shortage, "shortage customer spawned")
	gs.market_modifiers["FOOD"] = -40
	gs.customers_today = []
	gs.start_day()
	var surplus := false
	for c in gs.customers_today:
		if String(c.get("market_kind", "")) == "surplus" and String(c.get("market_type", "")) == "FOOD":
			surplus = true
	check(surplus, "surplus customer spawned")
	gs.pending_event = {"choices": [{"market": {"MEDICAL": 45}}]}
	gs.apply_event(0)
	check(int(gs.market_modifiers.get("MEDICAL", 0)) == 45, "event market modifier", str(gs.market_modifiers.get("MEDICAL", 0)))
	gs.rent_due = 1
	gs.cash = 1000
	gs.customers_today = []
	gs.start_day()
	var rent_c: Dictionary = {}
	for c in gs.customers_today:
		if String(c.get("intent", "")) == "rent":
			rent_c = c
	check(not rent_c.is_empty(), "landlord due customer appears")
	gs.current_customer = rent_c
	var rent_before: int = gs.rent
	var rent_pay: Dictionary = gs.pay_rent_early()
	check(bool(rent_pay.get("ok", false)) and gs.rent_due == 7 and gs.cash < 1000, "rent paid early", str(rent_pay))
	gs.loan_due = 1
	gs.cash = 1000
	gs.customers_today = []
	gs.start_day()
	var loan_c: Dictionary = {}
	for c in gs.customers_today:
		if String(c.get("intent", "")) == "loan":
			loan_c = c
	check(not loan_c.is_empty(), "loan shark due customer appears")
	gs.current_customer = loan_c
	var loan_pay: Dictionary = gs.pay_loan_early()
	check(bool(loan_pay.get("ok", false)) and gs.loan_due == 12, "loan paid early", str(loan_pay))
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
