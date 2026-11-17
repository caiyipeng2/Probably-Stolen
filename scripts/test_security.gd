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
	check(gs.security_defs.get("crimes", {}).size() >= 8, "security data loaded")
	# crime ledger
	gs.commit_crime("WEAPON_TRAFFICKING", 120)
	gs.commit_crime("DRUG_TRAFFICKING", 80)
	check(gs.sec_total_crime() == 200, "crime total", str(gs.sec_total_crime()))
	check(gs.sec_biggest_crime().contains("武器"), "biggest crime")
	check(gs.sec_projected_sentence() == "罚款", "fine sentence")
	gs.commit_crime("CARD_TRAFFICKING", 1500)
	check(gs.sec_projected_sentence() == "处决", "execution sentence", gs.sec_projected_sentence())
	# sale crimes
	gs.sec_crimes.clear()
	var stolen = gs.make_item("hand_steel", 100, true, true)
	gs.sec_commit_sale(stolen, 100, "lower")
	check(int(gs.sec_crimes.get("FENCING", 0)) > 0, "fencing crime", str(gs.sec_crimes.get("FENCING", 0)))
	var gun = gs.make_item("glock_receiver", 100, true, false)
	gs.sec_commit_sale(gun, 100, "lower")
	check(int(gs.sec_crimes.get("WEAPON_TRAFFICKING", 0)) >= 100, "weapon trafficking", str(gs.sec_crimes.get("WEAPON_TRAFFICKING", 0)))
	# stolen heat + decay
	var low = gs.make_item("scrap_metal", 100, true, true)
	check(not bool(low.get("stolen", true)), "low value stolen disabled")
	var high = gs.make_item("hand_gold", 100, true, true)
	check(int(high.get("stolen_heat", 0)) >= 50, "stolen heat initialized", str(high.get("stolen_heat", 0)))
	gs._decay_stolen_item(high)
	var once = int(high.get("stolen_heat", 0))
	gs._decay_stolen_item(high)
	check(int(high.get("stolen_heat", 0)) < once, "stolen heat decays")
	# nightly evidence + officer dispatch
	gs.sec_crimes = {"WEAPON_TRAFFICKING": 1200}
	gs.sec_evidence = 0
	gs.sec_officer_pending = false
	gs.day = 10
	for i in range(20):
		gs._sec_on_new_day()
	check(gs.sec_evidence >= 100 and gs.sec_officer_pending, "evidence reaches 100 and officer pending", "%d/%s" % [gs.sec_evidence, gs.sec_officer_pending])
	check(int(gs.sec_crimes.get("WEAPON_TRAFFICKING", 0)) < 1200, "crimes decay nightly")
	# officer fine
	gs.phase = "open"
	gs.ending_id = ""
	gs.sec_crimes = {"WEAPON_TRAFFICKING": 200}
	gs.sec_evidence = 100
	gs.sec_officer_pending = true
	gs.owned_upgrades.erase("SEC_GRACE")
	gs.cash = 1000
	var r = gs.sec_resolve_officer(true)
	check(r.get("ok", false) and gs.cash == 800 and gs.sec_total_crime() == 0, "officer fine paid", r.get("text", ""))
	# officer arrest
	gs.phase = "open"
	gs.ending_id = ""
	gs.sec_crimes = {"WEAPON_TRAFFICKING": 500}
	gs.sec_evidence = 100
	gs.sec_officer_pending = true
	gs.sec_resolve_officer(false)
	check(gs.phase == "gameover" and gs.ending_id == "arrest", "officer arrest")
	# grace avoids arrest
	gs.phase = "open"
	gs.ending_id = ""
	gs.sec_officer_pending = true
	gs.owned_upgrades["SEC_GRACE"] = true
	gs.sec_resolve_officer(false)
	check(gs.phase != "gameover", "grace avoids arrest")
	# execution
	gs.phase = "open"
	gs.ending_id = ""
	gs.sec_crimes = {"CARD_TRAFFICKING": 1600}
	gs.sec_evidence = 100
	gs.sec_officer_pending = true
	gs.sec_resolve_officer(false)
	check(gs.phase == "gameover" and gs.ending_id == "execution", "execution ending")
	# inspection: mid-level contraband seizure
	gs.new_game()
	gs.rng.seed = 20261119
	gs.inventory.clear()
	gs.display.clear()
	gs.counter_item = {}
	var contraband = gs.make_item("glock_receiver", 100, true, false)
	gs.add_item(contraband)
	gs.sec_inspection_pending = true
	gs.sec_inspection_personality = 0
	var before = gs.inventory_count("glock_receiver")
	var r2 = gs.sec_resolve_inspection(true, false)
	check(r2.get("result", "") == "seizure" and gs.inventory_count("glock_receiver") == before - 1, "mid contraband seized", r2.get("result", ""))
	# inspection: low level warning keeps item
	gs.new_game()
	gs.rng.seed = 20261119
	gs.inventory.clear()
	var lowgun = gs.make_item("printed_gun", 100, true, false)
	gs.add_item(lowgun)
	gs.sec_inspection_pending = true
	var r3 = gs.sec_resolve_inspection(true, false)
	check(r3.get("result", "") == "warning" and gs.inventory_count("printed_gun") == 1, "low contraband warning keeps item", r3.get("result", ""))
	# high contraband fine
	gs.new_game()
	gs.rng.seed = 20261119
	gs.inventory.clear()
	gs.cash = 5000
	gs.add_item(gs.make_item("smg", 100, true, false))
	gs.sec_inspection_pending = true
	var r3b = gs.sec_resolve_inspection(true, false)
	check(r3b.get("result", "") == "fine" and int(r3b.get("fine", 0)) > 0, "high contraband fine", r3b.get("result", ""))
	# critical contraband arrest/grace
	gs.new_game()
	gs.inventory.clear()
	gs.add_item(gs.make_item("crypto_module_cmd", 100, true, false))
	gs.sec_inspection_pending = true
	var r3c = gs.sec_resolve_inspection(true, false)
	check(r3c.get("result", "") == "arrest" and gs.phase == "gameover", "critical contraband arrest", r3c.get("result", ""))
	# bribe
	gs.new_game()
	gs.cash = 1000
	gs.sec_inspection_pending = true
	gs.sec_inspection_personality = 1
	var bamt = gs.sec_bribe_amount()
	var r4 = gs.sec_resolve_inspection(false, true)
	check(r4.get("result", "") == "bribed" and gs.cash == 1000 - bamt, "inspection bribed", r4.get("text", ""))
	# locked container concealed
	gs.new_game()
	gs.inventory.clear()
	var sec_box = gs.make_item("sec_box", 100, true, false)
	gs.add_item(sec_box)
	var locked_gun = gs.make_item("glock_receiver", 100, true, false)
	gs.container_auto_add(sec_box, locked_gun)
	var cand = gs.sec_inspection_candidates()
	check(not cand.has(locked_gun), "locked container conceals contents")
	# dirty water sale crimes
	gs.new_game()
	var dirty = gs.make_item("water_jug", 100, true, false)
	dirty["liquid_ml"] = 3000
	dirty["liquid_purity"] = 1000
	gs.sec_commit_sale(dirty, 50, "lower")
	check(int(gs.sec_crimes.get("FRAUD", 0)) > 0 and int(gs.sec_crimes.get("ENDANGERMENT", 0)) > 0, "dirty water sale crimes", str(gs.sec_crimes))
	# concealed hidden page blocks rep gain
	gs.new_game()
	gs.inventory.clear()
	gs.rep["security"] = 0
	var hidden_gun = gs.make_item("glock_receiver", 100, true, false)
	hidden_gun["page"] = 2
	hidden_gun["location"] = "backpack"
	gs.inventory.append(hidden_gun)
	gs.sec_inspection_pending = true
	gs.sec_inspection_personality = 0
	gs.sec_resolve_inspection(true, false)
	check(int(gs.rep.get("security", 0)) == 0, "concealed blocks rep gain", str(gs.rep.get("security", 0)))
	# save/load
	gs.commit_crime("FRAUD", 123)
	gs.sec_evidence = 42
	gs.sec_bribe_tracker = 77
	gs.save_game(3)
	gs.new_game()
	gs.load_game(3)
	check(int(gs.sec_crimes.get("FRAUD", 0)) == 123 and gs.sec_evidence == 42 and gs.sec_bribe_tracker == 77, "security state saved", str(gs.sec_crimes))
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
