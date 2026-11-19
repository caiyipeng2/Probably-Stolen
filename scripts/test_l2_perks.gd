extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func fresh(perks: Array = []) -> Node:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("normal")
	gs.rng.seed = 20261119
	if not perks.is_empty():
		var res: Dictionary = gs.apply_starting_perks(perks)
		check(bool(res.get("ok", false)), "apply perks " + str(perks), str(res))
	return gs

func find_contraband(gs: Node) -> String:
	for k in gs.items_def.keys():
		if int(gs.items_def[k].get("contraband", 0)) > 0:
			return String(k)
	return ""

func doom_check(gs: Node, faction: String, value: int, ending: String) -> void:
	gs.phase = "open"
	gs.property_owned = false
	gs.is_paying_mortgage = false
	gs.rent_due = 99
	gs.loan_due = 99
	gs.mortgage_due = 99
	gs.cash = 1000
	gs.owned_upgrades.erase("INSURANCE")
	for k in gs.rep.keys():
		gs.rep[k] = 0
	gs.rep[faction] = value
	var s: Dictionary = gs.finish_day()
	check(String(s.get("gameover", "")) == ending, "doom ending %s" % ending, str(s.get("gameover", "")))

func _init() -> void:
	var gs = fresh()

	# --- reputation perk thresholds (negative perks infer type from sign) ---
	gs.rep["lower"] = 0
	check(not gs.rep_perk_unlocked("LLPOORREVIEWS"), "LLPOORREVIEWS locked at 0")
	gs.rep["lower"] = -20
	check(gs.rep_perk_unlocked("LLPOORREVIEWS"), "LLPOORREVIEWS unlocked at -20")
	check(not gs.rep_perk_unlocked("LLDISTRUSTED"), "LLDISTRUSTED still locked at -20")
	gs.rep["lower"] = -40
	check(gs.rep_perk_unlocked("LLDISTRUSTED"), "LLDISTRUSTED unlocked at -40")
	gs.rep["lower"] = 20
	check(gs.rep_perk_unlocked("LLREFERAL") and not gs.rep_perk_unlocked("LLTIPS"), "LLREFERAL at 20")
	gs.rep["lower"] = 60
	check(gs.rep_perk_unlocked("LLTIPS"), "LLTIPS at 60")
	gs.rep["lower"] = 80
	check(gs.rep_perk_unlocked("LLTIGHTLIPS"), "LLTIGHTLIPS at 80")
	gs.rep["lower"] = 100
	check(gs.rep_perk_unlocked("LLPILLAR"), "LLPILLAR at 100")
	gs.rep["blackmarket"] = -100
	check(gs.rep_perk_unlocked("BM_HONOR"), "BM_HONOR always active")

	# --- budget multipliers ---
	for k in gs.rep.keys():
		gs.rep[k] = 0
	gs.rep["upper"] = 100
	gs.rep["security"] = 80
	check(is_equal_approx(gs.rep_budget_mult("upper"), 1.875), "upper budget x1.875", str(gs.rep_budget_mult("upper")))
	check(is_equal_approx(gs.rep_budget_mult("lower"), 1.5), "reliable vendor budget x1.5")

	# --- upgrade discounts ---
	for k in gs.rep.keys():
		gs.rep[k] = 0
	gs.rep["lower"] = 100
	check(gs.upgrade_cost("RENOVATION1") == 459, "LLPILLAR upgrade -15%", str(gs.upgrade_cost("RENOVATION1")))

	# --- burglary / insurance ---
	for k in gs.rep.keys():
		gs.rep[k] = 0
	gs.rep["lower"] = -60
	check(gs.burglary_chance() == 30, "LLTARGET burglary +15", str(gs.burglary_chance()))
	gs.rep["security"] = 40
	check(gs.burglary_chance() == 14, "SEC_PROTECTION burglary -16", str(gs.burglary_chance()))
	check(gs.insurance_daily_cost() == 30, "LLTARGET insurance x2", str(gs.insurance_daily_cost()))
	gs.rep["security"] = 100
	check(gs.burglary_chance() == 0, "SEC_VIP no burglary")

	# --- insurance block ---
	gs.rep["blackmarket"] = -60
	check(gs.insurance_blocked(), "BM_UNINSURABLE flag")
	gs.cash = 9999
	check(not bool(gs.upgrade_available("INSURANCE").get("ok", true)), "insurance blocked by perk")

	# --- operation intel ---
	for k in gs.rep.keys():
		gs.rep[k] = 0
	var op := {"faction": "lower", "name": "工人罢工"}
	check(gs.operation_label(op) == "不明派系行动", "unknown operation hidden")
	gs.rep["lower"] = 60
	check(gs.operation_label(op) == "工人罢工", "LLTIPS reveals lower ops")

	# --- customer count modifiers ---
	for k in gs.rep.keys():
		gs.rep[k] = 0
	check(gs.customer_count_modifier() == 0, "base customer count modifier")
	gs.rep["lower"] = -20
	check(gs.customer_count_modifier() == -1, "LLPOORREVIEWS -1 customer")
	gs.rep["lower"] = 20
	check(gs.customer_count_modifier() == 1, "LLREFERAL +1 customer")

	# --- LLTIGHTLIPS evidence ---
	gs = fresh()
	gs.rep["lower"] = 80
	gs.sec_crimes = {}
	var stolen: Dictionary = gs.make_item("galaxy_blend", 100, true, true)
	var heat := int(stolen.get("stolen_heat", 0))
	gs.sec_commit_sale(stolen, 100, "lower")
	var expected_evidence := int(round(50.0 * float(heat) / 100.0))
	check(int(gs.sec_crimes.get("FENCING", 0)) == expected_evidence, "LLTIGHTLIPS halves lower evidence", str(gs.sec_crimes.get("FENCING", 0)))

	# --- contraband withheld ---
	gs = fresh()
	var cid := find_contraband(gs)
	check(cid != "", "found contraband item for test")
	if cid != "":
		gs.rep["lower"] = -40
		var it: Dictionary = gs.make_item(cid, 100, true, false)
		it["x"] = 0
		it["y"] = 0
		gs.display.append(it)
		gs.current_customer = {"intent": "buy", "want_tags": [], "arche": {"faction": "lower"}, "budget": 1000}
		check(not gs.put_display_on_counter(int(it["uid"])), "LLDISTRUSTED withholds contraband")
		gs.rep["lower"] = 0
		gs.rep["blackmarket"] = -40
		gs.current_customer = {"intent": "buy", "want_tags": [], "arche": {"faction": "blackmarket"}, "budget": 1000}
		check(not gs.put_display_on_counter(int(it["uid"])), "BM_DISTRUSTED withholds contraband")

	# --- doom endings ---
	gs = fresh()
	doom_check(gs, "lower", -100, "mob")
	doom_check(gs, "security", -100, "sec")
	doom_check(gs, "upper", -100, "hitman")
	doom_check(gs, "rev", -100, "bombed")
	doom_check(gs, "cartel", -100, "cartel_retired")

	# --- SEC_ALARM_IGNORED ---
	gs = fresh()
	gs.rep["security"] = -40
	check(not bool(gs.report_wanted("x").get("ok", true)), "SEC_ALARM_IGNORED blocks reports")

	# --- cartel perks ---
	gs = fresh()
	gs.rep["cartel"] = 50
	gs.day = 7
	var cash0: int = gs.cash
	gs._handle_cartel_weekly()
	check(gs.cash == cash0 + 350, "cartel stipend scales with rep", str(gs.cash - cash0))
	check(gs.cartel_material_cost() == 6, "reliable chemist halves rep cost")
	var r: Dictionary = gs.request_cartel_materials()
	check(bool(r.get("ok", false)) and int(gs.rep["cartel"]) == 44 and gs.inventory_count("chem_module") == 2, "cartel materials", str(r))
	gs.rep["cartel"] = 100
	gs.day = 7
	gs._handle_cartel_weekly()
	check(gs.cartel_exit_available, "authorized exit offered")
	var e: Dictionary = gs.exit_cartel()
	check(bool(e.get("ok", false)) and gs.cartel_exited and int(gs.rep["cartel"]) == 75, "exit cartel", str(e))

	# --- starting perk flags/effects ---
	gs = fresh(["perk_alert", "perk_minimalist"])
	check(gs.burglary_chance() == 0, "alert blocks burglary")
	check(gs.page_size(0)[0] == 14, "minimalist inventory 14 wide", str(gs.page_size(0)))
	gs = fresh(["perk_ascetic"])
	check(gs.page_size(0)[0] == 12, "ascetic inventory 12 wide", str(gs.page_size(0)))
	gs = fresh(["perk_awful_negotiator"])
	check(not gs.can_bargain(), "awful negotiator disables bargain")
	check(not bool(gs.bargain_choose_direction(1).get("ok", true)), "bargain rejected")
	gs = fresh(["perk_handy"])
	check(gs.inventory_count("toolbox") == 1 and gs.inventory_count("welder") == 1 and gs.inventory_count("screwdriver") == 1, "handy tools granted")
	gs = fresh(["perk_sentinel"])
	check(gs.inventory_count("large_purple_injector") == 1, "sentinel starts with injector")
	gs = fresh(["perk_tapehead"])
	check(gs.inventory_count("cassette_player") == 1, "tapehead player")
	gs = fresh(["perk_wild_favorite"])
	check(gs.upgrade_cost("RENOVATION1") == 486, "wild favorite upgrade -10%", str(gs.upgrade_cost("RENOVATION1")))
	gs = fresh(["perk_wild_bad_side"])
	check(gs.upgrade_cost("RENOVATION1") == 594, "wild bad side upgrade +10%", str(gs.upgrade_cost("RENOVATION1")))
	gs = fresh(["perk_makeshift_reactor"])
	gs.day = 1
	gs.start_day()
	check(gs.power == 20, "makeshift reactor +10 power", str(gs.power))
	gs = fresh(["perk_unsubscribed"])
	check(gs.starting_perk_active("perk_unsubscribed"), "unsubscribed flag")
	gs = fresh(["perk_illiterate"])
	check(not gs.can_read_guides(), "illiterate blocks guides")
	gs = fresh(["perk_banned_commissary"])
	check(gs.commissary_banned() and not bool(gs.commissary_buy("cig_red").get("ok", true)), "commissary banned")
	gs = fresh(["perk_tinkerer"])
	gs.rng.seed = 42
	var saves := 0
	for i in range(50):
		if gs.tinkerer_material_saved():
			saves += 1
	check(saves > 0, "tinkerer material save occurs", str(saves))

	# --- reputation gain modifiers ---
	gs = fresh(["perk_diplomatic", "perk_sycophant"])
	gs.rep["upper"] = 0
	gs.add_rep("upper", 10)
	check(int(gs.rep["upper"]) == 17, "diplomatic+sycophant upper gain", str(gs.rep["upper"]))
	gs = fresh(["perk_diplomatic", "perk_blabbermouth"])
	gs.rep["blackmarket"] = 0
	gs.add_rep("blackmarket", 10)
	check(int(gs.rep["blackmarket"]) == 7, "blabbermouth halves bm gain", str(gs.rep["blackmarket"]))
	gs = fresh(["perk_intimidating"])
	gs.sec_crimes = {}
	gs.commit_crime("FENCING", 100)
	check(int(gs.sec_crimes.get("FENCING", 0)) == 67, "intimidating crime evidence -33%")
	gs = fresh(["perk_blabbermouth"])
	gs.sec_crimes = {}
	gs.commit_crime("FENCING", 100)
	check(int(gs.sec_crimes.get("FENCING", 0)) == 133, "blabbermouth crime evidence +33%")

	# --- welfare / secret admirer / gambling / blackmail / scalper ---
	gs = fresh(["perk_welfare_program"])
	gs.day = 8
	var adjusted: int = (gs.net_worth() - gs.cash) / 3 + gs.cash
	var expected_stamp := 40
	if adjusted <= 1200:
		expected_stamp = 160
	elif adjusted <= 1800:
		expected_stamp = 120
	elif adjusted <= 2400:
		expected_stamp = 80
	gs._handle_welfare_program()
	check(gs.inventory_count("food_stamp") == 1, "welfare Monday food stamp")
	var stamp: Dictionary = {}
	for it in gs._iter_inventory_items():
		if String(it.get("def_id", "")) == "food_stamp":
			stamp = it
			break
	check(int(stamp.get("custom_base_value", 0)) == expected_stamp, "welfare stamp scales with wealth", str(stamp.get("custom_base_value", 0)) + "/" + str(expected_stamp))
	gs = fresh(["perk_secret_admirer"])
	gs.day = 2
	gs._handle_secret_admirer()
	check(gs.inventory_count("galaxy_blend") == 1, "secret admirer day 2 gift")
	gs = fresh(["perk_gambling_addiction"])
	gs.cash = 100
	gs.rng.seed = 7
	gs._handle_gambling_addiction()
	check(gs.cash != 100 and String(gs.night_log[-1]).contains("赌瘾"), "gambling daily ticket", str(gs.cash))
	gs = fresh(["perk_blackmail"])
	gs.day = 8
	gs._handle_blackmail()
	check(not gs.customers_today.is_empty() and String(gs.customers_today[-1].get("intent", "")) == "blackmail", "weekly blackmailer")
	if not gs.customers_today.is_empty():
		gs.current_customer = gs.customers_today[-1]
		var c0: int = gs.cash
		var br: Dictionary = gs.resolve_blackmail(true)
		check(bool(br.get("ok", false)) and gs.cash == c0 - 48, "blackmail paid", str(br))
	gs = fresh(["perk_sentinel"])
	gs.day = 6
	gs.customers_today = []
	gs._handle_sentinel_scalper()
	check(not gs.customers_today.is_empty() and String(gs.customers_today[-1].get("item", {}).get("def_id", "")) == "large_purple_injector", "sentinel scalper")

	# --- report bounty modifiers ---
	if not gs.wanted.is_empty():
		var wid := String(gs.wanted[0].get("id", ""))
		var reward := int(gs.wanted[0].get("reward", 0))
		gs = fresh(["perk_model_citizen"])
		gs.current_customer = {"intent": "wanted_visit", "wanted_id": wid, "done": false}
		gs.auto_customer_flow = false
		var c1: int = gs.cash
		gs.report_wanted(wid)
		check(gs.cash - c1 == int(round(float(reward) * 1.5)), "model citizen bounty +50%", str(gs.cash - c1))
		gs = fresh(["perk_convict"])
		gs.current_customer = {"intent": "wanted_visit", "wanted_id": wid, "done": false}
		gs.auto_customer_flow = false
		var c2: int = gs.cash
		gs.report_wanted(wid)
		check(gs.cash - c2 == int(round(float(reward) * 0.75)), "convict bounty -25%", str(gs.cash - c2))

	# --- customer count starting perks ---
	gs = fresh(["perk_side_street"])
	check(gs.customer_count_modifier() == -1, "side street -1 customer")
	gs = fresh(["perk_prime_real_estate"])
	check(gs.customer_count_modifier() == 1, "prime real estate +1 customer")

	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
