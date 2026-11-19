extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func _entry(gs, pid: String) -> Dictionary:
	for e in gs.client_pools.get("general", []):
		if String(e.get("id", "")) == pid:
			return e
	for pool in gs.client_pools.get("faction_pools", []):
		for e in pool.get("entries", []):
			if String(e.get("id", "")) == pid:
				return e
	return {}

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	gs.rng.seed = 20261119
	gs.sec_inspection_pending = false
	check(gs.client_pools.get("general", []).size() == 18, "general pool size", str(gs.client_pools.get("general", []).size()))
	var sizes: Array = []
	for p in gs.client_pools.get("faction_pools", []):
		sizes.append(p.get("entries", []).size())
	check(sizes == [4, 4, 1], "faction pool sizes", str(sizes))
	check(gs.client_attractiveness_tier() == 0, "base attraction tier 0")
	gs.owned_upgrades["RENOVATION1"] = true
	check(gs.store_attractiveness() == 400 and gs.client_attractiveness_tier() == 1, "renovation raises tier", "%d/%d" % [gs.store_attractiveness(), gs.client_attractiveness_tier()])
	gs.owned_upgrades["RENOVATION2"] = true
	gs.owned_upgrades["RENOVATION3"] = true
	check(gs.client_attractiveness_tier() == 2, "three renovations reach tier 2", str(gs.store_attractiveness()))
	var pools: Array = gs.client_pools.get("faction_pools", [])
	var bm: Dictionary = pools[0]
	var ul: Dictionary = pools[1]
	var rev: Dictionary = pools[2]
	gs.rep["blackmarket"] = 0
	check(gs._pool_chance(bm) == 7, "blackmarket base chance", str(gs._pool_chance(bm)))
	gs.rep["blackmarket"] = 30
	check(gs._pool_chance(bm) == 19, "blackmarket rep 30 chance + broker perk", str(gs._pool_chance(bm)))
	gs.rep["blackmarket"] = 60
	check(gs._pool_chance(bm) == 22, "blackmarket rep 60 chance + broker perk", str(gs._pool_chance(bm)))
	gs.rep["upper"] = 30
	check(gs._pool_chance(ul) == 12, "upper rep 30 chance", str(gs._pool_chance(ul)))
	gs.rep["rev"] = 30
	check(gs._pool_chance(rev) == 6, "rev rep 30 chance", str(gs._pool_chance(rev)))
	gs.rep["rev"] = -40
	check(gs._pool_chance(rev) == 0, "rev blacklisted chance", str(gs._pool_chance(rev)))
	var merchant := _entry(gs, "merchant")
	var mc: Dictionary = gs._gen_pool_customer(merchant, "lower")
	check(mc.get("intent", "") == "buy" and bool(mc.get("exclude_contraband", false)), "merchant buy all except contraband")
	check(int(mc.get("budget", 0)) > 0 and String(mc.get("arche", {}).get("name", "")) != "", "merchant budget/name", "%d/%s" % [int(mc.get("budget", 0)), mc.get("arche", {}).get("name", "")])
	var spacer := _entry(gs, "spacerFood")
	var sc: Dictionary = gs._gen_pool_customer(spacer, "lower")
	check(sc.get("want_tags", []).has("FOOD"), "spacer food tags", str(sc.get("want_tags", [])))
	var junker := _entry(gs, "junker")
	var jc: Dictionary = gs._gen_pool_customer(junker, "lower")
	check(jc.get("intent", "") == "wholesale" and bool(jc.get("sellbuy", false)), "junker wholesale sellbuy")
	check(jc.get("wholesale_stock", []).size() >= 6 and int(jc.get("wholesale_discount", 0)) < 0, "junker stock/discount", "%d/%d" % [jc.get("wholesale_stock", []).size(), int(jc.get("wholesale_discount", 0))])
	var stamp := _entry(gs, "stampSeller")
	var stc: Dictionary = gs._gen_pool_customer(stamp, "lower")
	check(stc.get("intent", "") == "sell" and String(stc.get("item", {}).get("def_id", "")) == "food_stamp", "stamp seller counter item")
	var addict := _entry(gs, "addictGeneralBarter")
	var bc: Dictionary = gs._gen_pool_customer(addict, "lower")
	check(bc.get("intent", "") == "barter" and String(bc.get("barter_client", "")) == "addict_general", "barter pool maps client", str(bc.get("barter_client", "")))
	gs.client_cooldowns["merchant"] = 2
	var seen_merchant := false
	for i in range(40):
		var picked: Dictionary = gs._weighted_client_entry(gs.client_pools.get("general", []), 0)
		if String(picked.get("id", "")) == "merchant":
			seen_merchant = true
	check(not seen_merchant, "cooldown excludes entry")
	gs.client_cooldowns.erase("merchant")
	gs.display.clear()
	gs.current_customer = gs._gen_pool_customer(_entry(gs, "merchant"), "lower")
	var gun: Dictionary = gs.make_item("glock_receiver", 100, true, false)
	gun["x"] = 0
	gun["y"] = 0
	gs.display.append(gun)
	gs.put_display_on_counter(int(gun.get("uid", -1)))
	check(int(gs.current_customer.get("offer", 1)) == 0, "merchant rejects contraband", str(gs.current_customer.get("offer", 1)))
	gs.display.clear()
	var food: Dictionary = gs.make_item("nutrifruit", 100, true, false)
	food["x"] = 0
	food["y"] = 0
	gs.display.append(food)
	gs.put_display_on_counter(int(food.get("uid", -1)))
	check(int(gs.current_customer.get("offer", 0)) > 0, "merchant buys allowed item", str(gs.current_customer.get("offer", 0)))
	gs.current_customer = gs._gen_pool_customer(_entry(gs, "junker"), "lower")
	gs.cash = 10000
	var sb: Dictionary = gs.buy_wholesale()
	check(String(sb.get("next_intent", "")) == "buy" and String(gs.current_customer.get("intent", "")) == "buy", "sellbuy moves to buy phase", str(sb.get("text", "")))
	gs.current_customer = gs._gen_pool_customer(_entry(gs, "scavBlood"), "lower")
	var blood_sale: Dictionary = gs.buy_wholesale()
	check(String(blood_sale.get("next_intent", "")) == "" and String(gs.current_customer.get("intent", "")) == "wholesale", "zero-budget sellbuy ends after sale")
	var stamp_c: Dictionary = gs._gen_pool_customer(_entry(gs, "stampSeller"), "lower")
	check(stamp_c.get("items", []).size() == 4, "multi-item counter stock", str(stamp_c.get("items", []).size()))
	gs.cash = 10000
	gs.current_customer = stamp_c
	gs.counter_item = stamp_c.get("item", {})
	var first_uid := int(gs.current_customer.get("item", {}).get("uid", -1))
	var bought_first: Dictionary = gs.make_offer(int(gs.current_customer.get("item", {}).get("asking_price", 0)))
	check(bool(bought_first.get("accepted", false)) and int(gs.current_customer.get("item_index", 0)) == 1, "multi-item advances after buy", str(bought_first.get("text", "")))
	check(gs.find_item(first_uid).is_empty() == false, "bought item moved to inventory")
	for i in range(2):
		gs.skip_current_sell_item()
	check(int(gs.current_customer.get("item_index", 0)) == 3, "multi-item skip advances", str(gs.current_customer.get("item_index", 0)))
	gs.skip_current_sell_item()
	check(String(gs.current_customer.get("pool_id", "")) != "stampSeller", "multi-item completes after last item")
	gs.client_cooldowns = {"merchant": 3, "foodBankBuyer": 6}
	gs.save_game(2)
	gs.new_game()
	gs.load_game(2)
	check(int(gs.client_cooldowns.get("merchant", 0)) == 3 and int(gs.client_cooldowns.get("foodBankBuyer", 0)) == 6, "client cooldowns saved", str(gs.client_cooldowns))
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
