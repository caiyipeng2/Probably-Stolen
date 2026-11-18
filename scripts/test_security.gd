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
	# permits cover matching firearms
	gs.new_game()
	gs.inventory.clear()
	gs.active_permits = [{"type": "FIREARM", "level": 2}]
	gs.add_item(gs.make_item("glock_receiver", 100, true, false))
	check(gs.sec_inspection_candidates().is_empty(), "permit covers level 2 firearm")
	gs.active_permits = []
	check(gs.sec_inspection_candidates().size() == 1, "permit removed exposes firearm")
	# permit grant requires upgrade and reputation, no duplicates
	gs.new_game()
	gs.sec_inspection_pending = false
	gs.sec_officer_pending = false
	gs.inventory.clear()
	gs.owned_upgrades["GUN_PERMIT_I"] = true
	gs.rep["security"] = 20
	gs._sec_grant_permits()
	gs._sec_grant_permits()
	check(gs.sec_has_permit(1) and gs.inventory_count("permit_gun_1") == 1, "permit granted once", str(gs.active_permits))
	# permit revocation
	gs.rep["security"] = -1
	gs.sec_permit_revoke_pending = false
	gs._sec_check_permit_revocation()
	check(gs.sec_permit_revoke_pending and gs.sec_permit_revoke_levels == [1], "permit revocation queued", str(gs.sec_permit_revoke_levels))
	gs.revoke_permits()
	check(gs.active_permits.is_empty() and gs.inventory_count("permit_gun_1") == 0, "permit revoked")
	# nested permit item removed on revocation
	gs.new_game()
	gs.inventory.clear()
	var permit_bag = gs.make_item("backpack_small", 100, true, false)
	gs.add_item(permit_bag)
	gs.container_auto_add(permit_bag, gs.make_item("permit_gun_1", 100, true, false))
	gs.active_permits = [{"type": "FIREARM", "level": 1}]
	gs.sec_permit_revoke_pending = true
	gs.sec_permit_revoke_levels = [1]
	gs.revoke_permits()
	check(gs.inventory_count("permit_gun_1") == 0, "nested permit revoked")
	# fake inspector downgrades and gives no reputation loss
	gs.new_game()
	gs.inventory.clear()
	gs.rep["security"] = 0
	gs.add_item(gs.make_item("smg", 100, true, false))
	gs.sec_inspection_pending = true
	gs.sec_inspection_fake = true
	gs.sec_inspection_personality = 0
	var rf = gs.sec_resolve_inspection(true, false)
	check(bool(rf.get("fake", false)) and rf.get("result", "") == "seizure" and int(rf.get("suspicion", -1)) == 0, "fake inspector downgrades", str(rf.get("result", "")))
	check(int(gs.rep.get("security", 0)) == 0 and gs.inventory_count("sec_slip") == 0, "fake inspector no rep loss or slip")
	# lazy inspector skips trash unless thorough
	gs.new_game()
	gs.inventory.clear()
	var trash_gun = gs.make_item("glock_receiver", 100, true, false)
	gs.add_item(trash_gun)
	gs.move_to_trash(int(trash_gun.get("uid", -1)))
	gs.sec_inspection_personality = 2
	check(gs.sec_inspection_candidates().is_empty(), "lazy inspector skips trash")
	gs.sec_inspection_personality = 0
	check(gs.sec_inspection_candidates().size() == 1, "normal inspector searches trash")
	# evidence removal is repeatable with cooldown and rising price
	gs.new_game()
	gs.cash = 5000
	gs.sec_evidence = 80
	gs.sec_crimes = {"FRAUD": 300}
	var er1 = gs.buy_upgrade("EVIDENCE_REMOVAL")
	check(er1.get("ok", false) and gs.sec_evidence == 0 and gs.evidence_removal_purchases == 1, "evidence removal clears evidence", str(er1))
	check(gs.upgrade_cooldown("EVIDENCE_REMOVAL") == 14 and gs.upgrade_cost("EVIDENCE_REMOVAL") == 600, "evidence removal cooldown and cost", "%d/%d" % [gs.upgrade_cooldown("EVIDENCE_REMOVAL"), gs.upgrade_cost("EVIDENCE_REMOVAL")])
	check(not bool(gs.buy_upgrade("EVIDENCE_REMOVAL").get("ok", true)), "evidence removal blocked by cooldown")
	gs.day += 15
	var er2 = gs.buy_upgrade("EVIDENCE_REMOVAL")
	check(er2.get("ok", false) and gs.evidence_removal_purchases == 2 and gs.cash == 5000 - 500 - 600, "evidence removal second purchase", str(er2))
	# reputation perk multipliers
	gs.new_game()
	gs.rep["security"] = 60
	check(gs.sec_perk_unlocked("SEC_TRUSTED") and is_equal_approx(gs.sec_investigation_multiplier(), 0.5), "trusted halves investigation")
	gs.rep["security"] = -60
	check(gs.sec_investigation_multiplier() > 1.49 and not bool(gs.sec_perk_unlocked("SEC_TRUSTED")), "priority speeds investigation")
	gs.rep["security"] = -20
	check(is_equal_approx(gs.sec_investigation_multiplier(), 1.2), "watchlist speeds investigation")
	gs.rep["upper"] = -60
	gs.rep["security"] = 60
	check(is_equal_approx(gs.sec_investigation_multiplier(), 0.75), "petition stacks with trusted")
	gs.rep["upper"] = -60
	gs.rep["security"] = 0
	gs.add_rep("security", -10)
	check(int(gs.rep.get("security", 0)) == -20, "petition doubles security rep loss", str(gs.rep.get("security", 0)))
	# inspector countdown
	gs.new_game()
	gs.sec_inspection_pending = false
	gs.sec_officer_pending = false
	gs.sec_permit_revoke_pending = false
	gs.sec_crimes = {"FRAUD": 400}
	gs.sec_inspection_countdown = 1
	check(gs._sec_tick_inspection_countdown() and gs.sec_inspection_pending and gs.sec_inspection_countdown > 0, "inspection countdown triggers", str(gs.sec_inspection_countdown))
	gs.sec_inspection_pending = false
	# save/load extended security fields
	gs.new_game()
	gs.active_permits = [{"type": "FIREARM", "level": 1}]
	gs.trash_items = [gs.make_item("glock_receiver", 100, true, false)]
	gs.upgrade_cooldowns = {"EVIDENCE_REMOVAL": 15}
	gs.evidence_removal_purchases = 2
	gs.sec_inspection_fake = true
	gs.commit_crime("FRAUD", 123)
	gs.sec_evidence = 42
	gs.sec_bribe_tracker = 77
	gs.save_game(3)
	gs.new_game()
	gs.load_game(3)
	check(int(gs.sec_crimes.get("FRAUD", 0)) == 123 and gs.sec_evidence == 42 and gs.sec_bribe_tracker == 77, "security state saved", str(gs.sec_crimes))
	check(gs.active_permits.size() == 1 and gs.trash_items.size() == 1 and int(gs.upgrade_cooldowns.get("EVIDENCE_REMOVAL", 0)) > 0 and gs.evidence_removal_purchases == 2, "extended security state saved", "%d/%d/%d" % [gs.active_permits.size(), gs.trash_items.size(), gs.evidence_removal_purchases])
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
