extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func fresh(diff: String) -> Node:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game(diff)
	gs.rng.seed = 20261119
	return gs

func _init() -> void:
	var gs0 = fresh("normal")
	var rules: Dictionary = gs0.difficulty_rules
	check(rules.size() == 4, "four difficulty presets", str(rules.size()))
	var keys: Array = []
	for k in rules["normal"].keys():
		keys.append(String(k))
	check(keys.size() == 41, "41 difficulty fields", str(keys.size()))
	var src := FileAccess.get_file_as_string("res://scripts/game_state.gd") + FileAccess.get_file_as_string("res://scripts/main.gd")
	var missing: Array = []
	for k in keys:
		if not src.contains(k):
			missing.append(k)
	check(missing.is_empty(), "every difficulty field has a consumer", "、".join(missing))

	var cozy = fresh("cozy")
	var normal = fresh("normal")
	var hard = fresh("hard")
	var challenge = fresh("challenge")
	check(cozy.rent_due == 8 and hard.rent_due == 6, "landlord grace at start", str(cozy.rent_due) + "/" + str(hard.rent_due))
	check(cozy.sec_trash_capacity() == 12 and hard.sec_trash_capacity() == 15, "janitorial trash capacity", str(cozy.sec_trash_capacity()) + "/" + str(hard.sec_trash_capacity()))
	check(hard.power == 13 and normal.power == 10, "start power bonus", str(hard.power) + "/" + str(normal.power))
	check(normal.wild_favor_credit == 200 and cozy.wild_favor_credit == 300, "network intro favor", str(normal.wild_favor_credit))
	check(normal.insurance_daily_cost() == 15 and hard.insurance_daily_cost() == 30, "insurance cost multiplier", str(hard.insurance_daily_cost()))
	check(int(cozy.upgrade_cost("INSURANCE")) == 250 and int(hard.upgrade_cost("INSURANCE")) == 335, "start insurance bonus", str(hard.upgrade_cost("INSURANCE")))
	check(int(hard.upgrade_cost("MARKETPLACE_REQUESTS")) - 900 == 2000, "vendor permit fee", str(hard.upgrade_cost("MARKETPLACE_REQUESTS")))
	check(cozy._appraisal_fee_percent(1) == 15 and hard._appraisal_fee_percent(1) == 30, "appraisal join multiplier", str(hard._appraisal_fee_percent(1)))
	check(int(hard.machine_repair_cost("fridge")) == int(normal.machine_repair_cost("fridge")) * 2, "power cost multiplier", str(hard.machine_repair_cost("fridge")))

	var cozy_ret := {"id": "retired_gunsmith", "name": "退休枪匠", "sell_mode": "wholesale", "wholesale_discount": [-10, -10], "wholesale_stock": []}
	var normal_ret := {"id": "retired_gunsmith", "name": "退休枪匠", "sell_mode": "wholesale", "wholesale_discount": [-10, -10], "wholesale_stock": []}
	var c_cozy = fresh("cozy")
	var c_norm = fresh("normal")
	var ret_cozy: Dictionary = c_cozy._gen_special_customer({"id": "retired_gunsmith", "name": "退休枪匠", "sell_mode": "wholesale", "wholesale_discount": [-10, -10], "wholesale_stock": []})
	var ret_norm: Dictionary = c_norm._gen_special_customer({"id": "retired_gunsmith", "name": "退休枪匠", "sell_mode": "wholesale", "wholesale_discount": [-10, -10], "wholesale_stock": []})
	check(int(ret_norm.get("wholesale_discount", 0)) > int(ret_cozy.get("wholesale_discount", 0)), "retired supplier markup", str(ret_norm.get("wholesale_discount", 0)) + "/" + str(ret_cozy.get("wholesale_discount", 0)))

	c_cozy = fresh("cozy")
	c_norm = fresh("normal")
	var cour_cozy: Dictionary = c_cozy._gen_courier_customer({"customer": "courrier", "supplier": "red_imp", "stock_type": 0, "day": 1, "free": false})
	var cour_norm: Dictionary = c_norm._gen_courier_customer({"customer": "courrier", "supplier": "red_imp", "stock_type": 0, "day": 1, "free": false})
	check(int(cour_norm.get("wholesale_discount", 0)) == int(cour_cozy.get("wholesale_discount", 0)), "supplier markup normal baseline", str(cour_norm.get("wholesale_discount", 0)))
	var c_hard = fresh("hard")
	var cour_hard: Dictionary = c_hard._gen_courier_customer({"customer": "courrier", "supplier": "red_imp", "stock_type": 0, "day": 1, "free": false})
	check(int(cour_hard.get("wholesale_discount", 0)) > int(cour_norm.get("wholesale_discount", 0)), "supplier markup on hard", str(cour_hard.get("wholesale_discount", 0)))

	c_cozy = fresh("cozy")
	c_norm = fresh("normal")
	c_cozy.apply_starting_perks(["perk_sentinel"])
	c_norm.apply_starting_perks(["perk_sentinel"])
	c_cozy.day = 48
	c_norm.day = 48
	c_cozy._handle_sentinel_scalper()
	c_norm._handle_sentinel_scalper()
	check(int(c_norm.customers_today[-1].get("item", {}).get("asking_price", 0)) > int(c_cozy.customers_today[-1].get("item", {}).get("asking_price", 0)), "scalper markup", str(c_norm.customers_today[-1].get("item", {}).get("asking_price", 0)) + "/" + str(c_cozy.customers_today[-1].get("item", {}).get("asking_price", 0)))

	c_norm = fresh("normal")
	c_norm.cash = 5000
	c_norm.owned_upgrades.erase("WILD_FIXER")
	var before: int = c_norm.cash
	c_norm.buy_upgrade("WILD_FIXER")
	var normal_gain: int = c_norm.cash - before + int(c_norm.upgrade_cost("WILD_FIXER"))
	c_cozy = fresh("cozy")
	c_cozy.cash = 5000
	var before2: int = c_cozy.cash
	c_cozy.buy_upgrade("WILD_FIXER")
	var cozy_gain: int = c_cozy.cash - before2 + int(c_cozy.upgrade_cost("WILD_FIXER"))
	check(cozy_gain > normal_gain, "wild refund + intro favor", str(cozy_gain) + "/" + str(normal_gain))

	c_norm = fresh("normal")
	c_norm.aug_introduced = true
	c_norm.aug_presence = 94
	c_norm.nightly_survival()
	check(c_norm.aug_presence == 100 and c_norm.phase != "gameover", "aug rise but normal does not game over", str(c_norm.aug_presence) + "/" + str(c_norm.ending_id))
	c_cozy = fresh("challenge")
	c_cozy.aug_introduced = true
	c_cozy.aug_presence = 99
	c_cozy.nightly_survival()
	var challenge_aug_over: bool = c_cozy.phase == "gameover" and c_cozy.ending_id == "aug"
	c_cozy = fresh("cozy")
	c_cozy.aug_introduced = true
	c_cozy.aug_presence = 99
	c_cozy.nightly_survival()
	check(challenge_aug_over and not (c_cozy.phase == "gameover" and c_cozy.ending_id == "aug"), "aug gameover by difficulty", str(challenge_aug_over))

	var u_norm := {"uid": 1, "team": 1, "name": "改造体", "is_aug": true, "death_chance": 100}
	var u_cozy := {"uid": 2, "team": 1, "name": "改造体", "is_aug": true, "death_chance": 100}
	c_norm = fresh("normal")
	c_norm.aug_presence = 50
	c_norm._combat_death_roll(u_norm)
	c_cozy = fresh("cozy")
	c_cozy.aug_presence = 50
	c_cozy._combat_death_roll(u_cozy)
	check(c_cozy.aug_presence == 25 and c_norm.aug_presence == 25, "aug kill presence drop", str(c_cozy.aug_presence))

	c_norm = fresh("normal")
	c_norm.current_customer = {"intent": "wanted_visit", "wanted_id": "w_lou", "done": false}
	c_norm.cash = 1000
	var lou: Dictionary = c_norm.engage_wanted_visit()
	check(bool(lou.get("ok", false)) and c_norm.cash == 250, "lou demand paid", str(lou) + " cash=" + str(c_norm.cash))
	c_norm.phase = "open"
	c_norm.current_customer = {"intent": "wanted_visit", "wanted_id": "w_lou", "done": false}
	c_norm.cash = 100
	check(c_norm.engage_wanted_visit().get("text", "") == "你向目标扑了过去。", "lou demand too high -> fight")

	c_norm = fresh("normal")
	c_norm.cash = 1000
	check(c_norm.show_display_tip() and c_norm.show_event_countdown(), "display/event UI flags normal")
	c_cozy = fresh("hard")
	check(not c_cozy.show_display_tip() and not c_cozy.show_event_countdown(), "display/event UI flags hard")

	check(cozy.afterhours_visits_left == 1, "afterhours field still intact")

	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
