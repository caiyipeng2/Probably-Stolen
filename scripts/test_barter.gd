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
	gs.rng.seed = 20261117
	check(gs.barter_offer_defs.size() == 6, "barter client definitions", str(gs.barter_offer_defs.size()))
	check(gs.dialogue_lines.has("dialog_barter_accept"), "barter dialogue loaded")
	var c = gs._gen_barter_customer()
	check(c.get("intent", "") == "barter" and not c.get("barter_offers", []).is_empty(), "barter customer generated", str(c.get("barter_client", "")))
	# condition: FOOD tag, remove two food items
	gs.inventory.clear()
	gs.display.clear()
	gs.add_item(gs.make_item("nutrifruit", 100, true, false))
	gs.add_item(gs.make_item("processed_meat", 100, true, false))
	var c2 := {
		"arche": {"faction": "lower"}, "intent": "barter", "done": false, "line": "",
		"barter_name": "测试", "barter_want": "",
		"barter_conditions": [{"tag": "FOOD", "count": 2}],
		"barter_offers": [{"items": [{"id": "wire", "count": 3}]}],
		"barter_index": 0,
	}
	gs.current_customer = c2
	check(gs.barter_condition_satisfied(c2), "food condition satisfied", str(gs.barter_condition_count({"tag": "FOOD", "count": 2})))
	var res = gs.accept_barter()
	check(res.get("ok", false) and gs.inventory_count("wire") == 3, "barter accepted and items swapped", res.get("text", ""))
	check(gs.inventory_count("nutrifruit") == 0 and gs.inventory_count("processed_meat") == 0, "required food consumed")
	check(bool(gs.current_customer.get("done", false)), "barter marked done")
	# specific injector + blacklist
	gs.inventory.clear()
	var bad = gs.make_item("pink_alt_injector", 100, true, false)
	bad["features"].append({"id": "starch_grade", "name": "淀粉级", "mod": -20})
	gs.add_item(bad)
	var cond = {"item": "pink_alt_injector", "blacklist": ["starch_grade", "junk_grade", "impurity"]}
	check(not gs.barter_condition_satisfied({"barter_conditions": [cond]}), "blacklisted injector rejected")
	var good = gs.make_item("pink_alt_injector", 100, true, false)
	gs.add_item(good)
	check(gs.barter_condition_satisfied({"barter_conditions": [cond]}), "genuine injector accepted")
	# offer cycling
	gs.current_customer = {
		"intent": "barter", "barter_offers": [{"items": [{"id": "wire", "count": 1}]}, {"items": [{"id": "blood_bag", "count": 2}]}], "barter_index": 0,
	}
	gs.cycle_barter_offer(1)
	check(int(gs.current_customer.get("barter_index", 0)) == 1, "offer set cycles")
	check(int(gs.barter_offer_items(gs.current_customer)[0].get("count", 0)) == 2, "current offer items")
	# insufficient condition
	gs.inventory.clear()
	gs.current_customer = {
		"arche": {"faction": "lower"}, "intent": "barter", "done": false, "line": "",
		"barter_conditions": [{"tag": "FOOD", "count": 1}],
		"barter_offers": [{"items": [{"id": "wire", "count": 1}]}], "barter_index": 0,
	}
	var fail_res = gs.accept_barter()
	check(not fail_res.get("ok", false), "barter rejects missing items", fail_res.get("text", ""))
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
