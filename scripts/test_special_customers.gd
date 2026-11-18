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
	check(gs.special_customers.get("tier", []).size() == 3, "tier templates", str(gs.special_customers.get("tier", []).size()))
	check(gs.special_customers.get("retired", []).size() == 5, "retired templates", str(gs.special_customers.get("retired", []).size()))
	var repair: Dictionary = gs._gen_special_customer(gs.special_customers["tier"][0])
	check(repair.get("intent", "") == "buy" and repair.get("want_tags", []).has("MATERIAL"), "repairman buy", str(repair.get("want_tags", [])))
	var gunsmith: Dictionary = gs._gen_special_customer(gs.special_customers["retired"][0])
	check(gunsmith.get("intent", "") == "wholesale" and gunsmith.get("wholesale_stock", []).size() >= 8, "gunsmith stock", str(gunsmith.get("wholesale_stock", []).size()))
	gs.day = 2
	gs.customers_today = []
	gs.start_day()
	var found_tier := false
	for c in gs.customers_today:
		if String(c.get("special_id", "")) == "lowerRepairman":
			found_tier = true
	check(found_tier, "tier day 2 scheduled")
	gs.owned_upgrades["RETIRED_GUNSMITH"] = true
	gs.day = 4
	gs.customers_today = []
	gs.start_day()
	var found_gun := false
	for c in gs.customers_today:
		if String(c.get("special_id", "")) == "retired_gunsmith":
			found_gun = true
	check(found_gun, "retired gunsmith weekday 4 scheduled")
	var info_t: Dictionary = {}
	for u in gs.special_customers.get("unique", []):
		if String(u.get("id", "")) == "information_dealer":
			info_t = u
	var info_c: Dictionary = gs._gen_special_customer(info_t)
	gs.current_customer = info_c
	gs.cash = 500
	var before_notes: int = gs.inventory_count("handnote")
	var info_res: Dictionary = gs.buy_information()
	check(bool(info_res.get("ok", false)) and gs.cash == 450 and gs.inventory_count("handnote") == before_notes + 1, "information dealer sells tip", str(info_res))
	var exp_t: Dictionary = {}
	for u in gs.special_customers.get("unique", []):
		if String(u.get("id", "")) == "expedition_organizer":
			exp_t = u
	var exp_c: Dictionary = gs._gen_special_customer(exp_t)
	gs.current_customer = exp_c
	var exp_res: Dictionary = gs.start_expedition()
	check(bool(exp_res.get("ok", false)) and gs.combat_active, "expedition starts party combat", str(exp_res))
	check(gs.expedition_rooms.size() == 2 and gs.advance_expedition(), "expedition has next room")
	check(gs.expedition_room_index == 1 and gs.combat_active, "expedition room 2 starts")
	gs.owned_upgrades.erase("RETIRED_GUNSMITH")
	gs.day = 4
	gs.customers_today = []
	gs.start_day()
	var absent := true
	for c in gs.customers_today:
		if String(c.get("special_id", "")) == "retired_gunsmith":
			absent = false
	check(absent, "retired gunsmith requires upgrade")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
