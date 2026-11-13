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
	gs.rng.seed = 20261114
	check(gs.inspection_families.size() == 7, "families=7", str(gs.inspection_families.size()))
	check(gs.appraisal_ranks.size() == 4, "ranks=4", str(gs.appraisal_ranks.size()))
	check(gs.appraisal_item_defs.size() == 3, "appraisal items=3", str(gs.appraisal_item_defs.size()))

	# cigarette counterfeit
	var cig = gs.make_item("cig_red", 100, false, false)
	check(String(cig.family) == "cigarette", "cig family", cig.family)
	check(cig.issues.size() > 0, "cig has issue", str(cig.issues))
	check(gs._attr_label("cigarette", "lettering", 2) == "印刷模糊", "cig label int", gs._attr_label("cigarette", "lettering", 2))
	check(gs._attr_label("cigarette", "lettering", 2.0) == "印刷模糊", "cig label float", gs._attr_label("cigarette", "lettering", 2.0))
	gs.counter_item = cig
	gs.current_customer = {"intent": "sell", "arche": {"faction": "lower", "name": "测试顾客"}, "item": cig, "patience": 3, "done": false}
	var r1 = gs.inspect_counter_with_tool("magnifier")
	check(r1.get("ok", false) and cig.family_seen, "magnifier report", r1.get("text", "").substr(0, 30))
	var c1 = gs.confront_counter_item(String(cig.issues[0]))
	check(c1.get("ok", false), "confront correct", c1.get("text", ""))
	check(cig.confronted, "confronted flag")
	var value_after = gs.effective_value(cig)
	var c2 = gs.confront_counter_item("__genuine__")
	check(not c2.get("ok", false), "second confront blocked", c2.get("text", ""))

	# wrong confront
	var cig2 = gs.make_item("cig_black", 100, false, false)
	gs.counter_item = cig2
	gs.current_customer = {"intent": "sell", "arche": {"faction": "lower", "name": "测试顾客"}, "item": cig2, "patience": 3, "done": false}
	var wrong_issue := ""
	for opt in gs._family_issue_options(cig2):
		if not cig2.issues.has(String(opt.id)):
			wrong_issue = String(opt.id)
			break
	if wrong_issue == "":
		wrong_issue = "__genuine__"
	var rep_before = int(gs.rep.get("lower", 0))
	var c3 = gs.confront_counter_item(wrong_issue)
	check(not c3.get("ok", false) and int(gs.rep.get("lower", 0)) == rep_before - 2, "wrong confront rep -2", c3.get("text", ""))

	# water strip
	var water = gs.make_item("water_jug", 10, true, false)
	gs.counter_item = water
	gs.current_customer = {"intent": "sell", "arche": {"faction": "lower", "name": "测试顾客"}, "item": water, "patience": 3, "done": false}
	var strips_before = gs.inventory_count("water_test_strip")
	var w1 = gs.inspect_counter_with_tool("water_test_strip")
	check(w1.get("ok", false) and gs.inventory_count("water_test_strip") == strips_before - 1, "strip consumed", w1.get("text", ""))
	var water_feature = null
	for f in water.feature_list:
		if String(f.category) == "CATEGORY_WATER_PURITY":
			water_feature = f
	check(water_feature != null and bool(water_feature.exposed), "water exposed")

	# hand values
	var h = gs.make_item("hand_gold", 100, true, false)
	h.attrs = {"material": "GOLD_PLATED", "interface": "NEURAL", "marking": "FULL", "condition": "NONE", "armored": "NONE", "bladed": "NONE"}
	check(gs._hand_value(h.attrs) == 620, "hand deluxe 620", str(gs._hand_value(h.attrs)))
	h.attrs = {"material": "ALUMINUM_ALLOY", "interface": "UNSPECIFIED", "marking": "SYMBOL", "condition": "DAMAGE", "armored": "NONE", "bladed": "NONE"}
	check(gs._hand_value(h.attrs) == 50, "hand junk min 50", str(gs._hand_value(h.attrs)))

	# ribwich values
	var rib = gs.make_item("ribwich", 100, true, false)
	rib.attrs = {"wrap": 0, "pickles": 0, "meat": 0, "bun": 0, "davre_logo": 0, "ribwich_logo": -1, "production": "425-01", "year": 425, "month": 1, "facility": 1}
	check(gs._ribwich_value(rib.attrs) == 330, "ribwich first run", str(gs._ribwich_value(rib.attrs)))
	rib.attrs["facility"] = 36
	check(gs._ribwich_value(rib.attrs) == 40, "ribwich counterfeit 40", str(gs._ribwich_value(rib.attrs)))

	# plasma values
	var plasma = gs.make_item("plasma_fuel", 100, true, false)
	plasma.attrs = {"wear": "NONE", "crack": "NONE", "uncovered": "NONE", "reinforced": "NONE", "color": "HIGH_QUALITY", "seal": "IGNITION_LAB"}
	check(gs._plasma_value(plasma.attrs) == 1200, "plasma lab 1200", str(gs._plasma_value(plasma.attrs)))

	# appraisal flow
	gs.appraiser_level = 0
	gs.cash = 1000
	var app_item = gs.make_item("hand_steel", 100, true, false)
	app_item.appraisal_value = 620
	gs.counter_item = app_item
	gs.current_customer = {"intent": "appraise", "arche": {"faction": "lower", "name": "估价客"}, "item": app_item, "patience": 3, "done": false, "impatience": 0}
	var cash_before = gs.cash
	var a1 = gs.appraise_counter_item(620)
	check(a1.get("ok", false), "appraise perfect", a1.get("text", ""))
	check(gs.cash == cash_before + 113, "appraise fee 113", str(gs.cash - cash_before))
	check(gs.appraisal_progress == 10.0, "progress +10", str(gs.appraisal_progress))
	var slip = false
	for it in gs.inventory:
		if String(it.get("def_id", "")) == "appraisal_slip":
			slip = true
	check(slip, "slip created")

	# precision windows
	check(gs.appraisal_precision(1000, 1000) == 1, "precision perfect")
	check(gs.appraisal_precision(1000, 750) == 5, "precision low 75")
	check(gs.appraisal_precision(1000, 1250) == 5, "precision high 125")
	check(gs.appraisal_precision(1000, 920) == 2, "precision near low")

	# rank progress and promotion
	gs.appraisal_progress = 95.0
	gs.counter_item = app_item
	gs.current_customer = {"intent": "appraise", "arche": {"faction": "lower", "name": "估价客"}, "item": app_item, "patience": 3, "done": false, "impatience": 0}
	gs.cash = 1000
	var a2 = gs.appraise_counter_item(620)
	check(a2.get("ok", false) and gs.pending_promotion, "promotion ready", str(gs.appraisal_progress))
	gs.cash = 1000
	var p1 = gs.promote_appraiser()
	check(p1.get("ok", false) and gs.appraiser_level == 1, "promote rank 1", p1.get("text", ""))
	var certs = 0
	for it in gs.inventory:
		if String(it.get("def_id", "")).begins_with("cert"):
			certs += 1
	check(certs >= 1, "certificate added", str(certs))

	# appraisal customer pool
	gs.appraiser_level = 2
	check(gs.appraisal_types_unlocked().size() == 3, "all appraisal types at rank2", str(gs.appraisal_types_unlocked().size()))
	var ac = gs._gen_appraisal_customer()
	check(String(ac.get("intent", "")) == "appraise" and not ac.get("item", {}).is_empty(), "appraisal customer generated")

	# base value/fee percentages
	check(gs._appraisal_fee_percent(1) == 21, "rank2 perfect fee 21", str(gs._appraisal_fee_percent(1)))
	check(gs._appraisal_fee_percent(4) == 0, "rank2 grade4 refused", str(gs._appraisal_fee_percent(4)))

	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
