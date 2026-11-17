# [L2 执行层] inspection.gd — 验货工具、对质、估价与晋升
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.new_game()
	state.rng.seed = 20261114

func run() -> void:
	check_eq(state.inspection_families.size(), 7, "families=7")
	check_eq(state.appraisal_ranks.size(), 4, "ranks=4")
	check_eq(state.appraisal_item_defs.size(), 3, "appraisal items=3")
	var cig = state.make_item("cig_red", 100, false, false)
	check_eq(String(cig.family), "cigarette", "cig family")
	check(cig.issues.size() > 0, "cig has issue", str(cig.issues))
	check_eq(state._attr_label("cigarette", "lettering", 2), "印刷模糊", "cig label int")
	check_eq(state._attr_label("cigarette", "lettering", 2.0), "印刷模糊", "cig label float")
	state.counter_item = cig
	state.current_customer = {"intent": "sell", "arche": {"faction": "lower", "name": "测试顾客"}, "item": cig, "patience": 3, "done": false}
	var r1 = state.inspect_counter_with_tool("magnifier")
	check(bool(r1.get("ok", false)) and bool(cig.family_seen), "magnifier report", String(r1.get("text", "")).substr(0, 30))
	var c1 = state.confront_counter_item(String(cig.issues[0]))
	check(bool(c1.get("ok", false)), "confront correct", String(c1.get("text", "")))
	check(bool(cig.confronted), "confronted flag")
	var c2 = state.confront_counter_item("__genuine__")
	check(not bool(c2.get("ok", true)), "second confront blocked", String(c2.get("text", "")))
	var cig2 = state.make_item("cig_black", 100, false, false)
	state.counter_item = cig2
	state.current_customer = {"intent": "sell", "arche": {"faction": "lower", "name": "测试顾客"}, "item": cig2, "patience": 3, "done": false}
	var wrong_issue := ""
	for opt in state._family_issue_options(cig2):
		if not cig2.issues.has(String(opt.id)):
			wrong_issue = String(opt.id)
			break
	if wrong_issue == "":
		wrong_issue = "__genuine__"
	var rep_before = int(state.rep.get("lower", 0))
	var c3 = state.confront_counter_item(wrong_issue)
	check(not bool(c3.get("ok", true)) and int(state.rep.get("lower", 0)) == rep_before - 2, "wrong confront rep -2", String(c3.get("text", "")))
	var water = state.make_item("water_jug", 10, true, false)
	state.counter_item = water
	state.current_customer = {"intent": "sell", "arche": {"faction": "lower", "name": "测试顾客"}, "item": water, "patience": 3, "done": false}
	var strips_before = state.inventory_count("water_test_strip")
	var w1 = state.inspect_counter_with_tool("water_test_strip")
	check(bool(w1.get("ok", false)) and state.inventory_count("water_test_strip") == strips_before - 1, "strip consumed", String(w1.get("text", "")))
	var water_feature = null
	for f in water.feature_list:
		if String(f.category) == "CATEGORY_WATER_PURITY":
			water_feature = f
	check(water_feature != null and bool(water_feature.exposed), "water exposed")
	var h = state.make_item("hand_gold", 100, true, false)
	h.attrs = {"material": "GOLD_PLATED", "interface": "NEURAL", "marking": "FULL", "condition": "NONE", "armored": "NONE", "bladed": "NONE"}
	check_eq(state._hand_value(h.attrs), 620, "hand deluxe 620")
	h.attrs = {"material": "ALUMINUM_ALLOY", "interface": "UNSPECIFIED", "marking": "SYMBOL", "condition": "DAMAGE", "armored": "NONE", "bladed": "NONE"}
	check_eq(state._hand_value(h.attrs), 50, "hand junk min 50")
	var rib = state.make_item("ribwich", 100, true, false)
	rib.attrs = {"wrap": 0, "pickles": 0, "meat": 0, "bun": 0, "davre_logo": 0, "ribwich_logo": -1, "production": "425-01", "year": 425, "month": 1, "facility": 1}
	check_eq(state._ribwich_value(rib.attrs), 330, "ribwich first run")
	rib.attrs["facility"] = 36
	check_eq(state._ribwich_value(rib.attrs), 40, "ribwich counterfeit 40")
	var plasma = state.make_item("plasma_fuel", 100, true, false)
	plasma.attrs = {"wear": "NONE", "crack": "NONE", "uncovered": "NONE", "reinforced": "NONE", "color": "HIGH_QUALITY", "seal": "IGNITION_LAB"}
	check_eq(state._plasma_value(plasma.attrs), 1200, "plasma lab 1200")
	state.appraiser_level = 0
	state.cash = 1000
	var app_item = state.make_item("hand_steel", 100, true, false)
	app_item.appraisal_value = 620
	state.counter_item = app_item
	state.current_customer = {"intent": "appraise", "arche": {"faction": "lower", "name": "估价客"}, "item": app_item, "patience": 3, "done": false, "impatience": 0}
	var cash_before = state.cash
	var a1 = state.appraise_counter_item(620)
	check(bool(a1.get("ok", false)), "appraise perfect", String(a1.get("text", "")))
	check_eq(state.cash, cash_before + 113, "appraise fee 113")
	check_eq(state.appraisal_progress, 10.0, "progress +10")
	var slip := false
	for it in state.inventory:
		if String(it.get("def_id", "")) == "appraisal_slip":
			slip = true
	check(slip, "slip created")
	check_eq(state.appraisal_precision(1000, 1000), 1, "precision perfect")
	check_eq(state.appraisal_precision(1000, 750), 5, "precision low 75")
	check_eq(state.appraisal_precision(1000, 1250), 5, "precision high 125")
	check_eq(state.appraisal_precision(1000, 920), 2, "precision near low")
	state.appraisal_progress = 95.0
	state.counter_item = app_item
	state.current_customer = {"intent": "appraise", "arche": {"faction": "lower", "name": "估价客"}, "item": app_item, "patience": 3, "done": false, "impatience": 0}
	state.cash = 1000
	var a2 = state.appraise_counter_item(620)
	check(bool(a2.get("ok", false)) and bool(state.pending_promotion), "promotion ready", str(state.appraisal_progress))
	state.cash = 1000
	var p1 = state.promote_appraiser()
	check(bool(p1.get("ok", false)) and state.appraiser_level == 1, "promote rank 1", String(p1.get("text", "")))
	var certs := 0
	for it in state.inventory:
		if String(it.get("def_id", "")).begins_with("cert"):
			certs += 1
	check(certs >= 1, "certificate added", str(certs))
	state.appraiser_level = 2
	check_eq(state.appraisal_types_unlocked().size(), 3, "all appraisal types at rank2")
	var ac = state._gen_appraisal_customer()
	check(String(ac.get("intent", "")) == "appraise" and not ac.get("item", {}).is_empty(), "appraisal customer generated")
	check_eq(state._appraisal_fee_percent(1), 21, "rank2 perfect fee 21")
	check_eq(state._appraisal_fee_percent(4), 0, "rank2 grade4 refused")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
