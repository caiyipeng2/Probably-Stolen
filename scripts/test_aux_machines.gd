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
	gs.rng.seed = 20261113
	var aux_ids := ["deal_maker", "recharger", "powerblock", "makeshift_reactor", "security_alarm",
		"storage_coordinator", "mirage_projector", "vending_machine", "vending_fountain",
		"vending_machine_core", "vending_fountain_core", "wine_rack", "animal_cage",
		"marking_pen", "vacuum_robot", "cassette_player", "ras_water_tank"]
	var aux := 0
	for m in gs.machines:
		if String(m.get("id", "")) in aux_ids and m.has("special"):
			aux += 1
	check(aux == 17, "passive aux specials count", str(aux))

	# module type gate
	var bad = gs.install_module("furnace", "printer_module_metal")
	check(not bad.get("ok", false), "furnace rejects printer module", bad.get("text", ""))
	var good = gs.install_module("furnace", "system_module_quality")
	check(good.get("ok", false), "furnace accepts universal module", good.get("text", ""))
	gs.clear_modules("furnace")

	# recipe placeholders
	var ph := ""
	for r in gs.machine_def("printer").get("recipes", []):
		var n = gs.machine_recipe_name(r)
		if n.contains("{"):
			ph = n
	check(ph == "", "recipe placeholders formatted", ph)

	# powerblock
	gs.machine_toggle_active("powerblock")
	check(gs.max_power == 12, "powerblock max power", str(gs.max_power))
	gs.machine_toggle_active("powerblock")

	# recharger
	gs.machine_toggle_active("recharger")
	gs.advance_machines_one_cycle()
	check(gs.next_day_power_bonus >= 3, "recharger bonus", str(gs.next_day_power_bonus))
	gs.machine_toggle_active("recharger")

	# reactor
	gs.next_day_power_bonus = 0
	gs.machine_toggle_active("makeshift_reactor")
	gs.advance_machines_one_cycle()
	var rst = gs.machine_state.get("makeshift_reactor", {})
	check(int(rst.get("integrity", 0)) == 82, "reactor decay", str(rst))
	check(gs.next_day_power_bonus >= 1, "reactor charges power", str(gs.next_day_power_bonus))
	gs.machine_toggle_active("makeshift_reactor")

	# projector
	gs.next_day_power_bonus = 0
	gs.power = 100
	gs.machine_toggle_active("mirage_projector")
	gs.advance_machines_one_cycle()
	check(gs.attraction_bonus == 100, "projector attraction base", str(gs.attraction_bonus))
	gs.machine_toggle_active("mirage_projector")

	# alarm
	gs.power = 100
	gs.machine_toggle_active("security_alarm")
	gs.advance_machines_one_cycle()
	check(gs.security_alarm_active, "alarm active", str(gs.security_stop_rate))
	gs.machine_toggle_active("security_alarm")

	# vending
	gs.power = 100
	var vend_uid = gs.make_item("nutrifruit", 100, true, false)["uid"]
	gs.add_item(gs.make_item("nutrifruit", 100, true, false))
	var sres = gs.machine_stock_add("vending_machine", int(gs.inventory[gs.inventory.size() - 1]["uid"]))
	check(sres.get("ok", false), "vending stock", sres.get("text", ""))
	gs.machine_toggle_active("vending_machine")
	gs.advance_machines_one_cycle()
	check(int(gs.machine_cash.get("vending_machine", 0)) > 0, "vending sale cash", str(gs.machine_cash.get("vending_machine", 0)))
	var collect = gs.machine_special_choice("vending_machine", "collect")
	check(collect.get("ok", false), "vending collect", collect.get("text", ""))
	gs.machine_toggle_active("vending_machine")

	# wine
	gs.power = 100
	gs.add_item(gs.make_item("wine_bottle", 100, true, false))
	var wine_uid = int(gs.inventory[gs.inventory.size() - 1]["uid"])
	gs.machine_stock_add("wine_rack", wine_uid)
	gs.machine_toggle_active("wine_rack")
	gs.advance_machines_one_cycle()
	var wstock = gs.machine_stock.get("wine_rack", [])
	check(not wstock.is_empty() and int(wstock[0].get("aged_days", 0)) >= 1, "wine aging", str(wstock[0].get("aged_days", 0)) if not wstock.is_empty() else "empty")
	gs.machine_toggle_active("wine_rack")

	# fridge
	gs.power = 100
	gs.add_item(gs.make_item("nutrifruit", 100, true, false))
	var f_uid = int(gs.inventory[gs.inventory.size() - 1]["uid"])
	gs.machine_stock_add("fridge", f_uid)
	gs.machine_toggle_active("fridge")
	gs.advance_machines_one_cycle()
	var fstock = gs.machine_stock.get("fridge", [])
	var chilled := false
	if not fstock.is_empty():
		for f in fstock[0].get("features", []):
			if String(f.get("id", "")) == "chilled":
				chilled = true
	check(chilled, "fridge chilled feature")
	gs.machine_toggle_active("fridge")

	# moisture farm
	gs.power = 100
	gs.machine_toggle_active("moisture_farm")
	gs.advance_machines_one_cycle()
	check(int(gs.machine_state.get("moisture_farm", {}).get("ml", 0)) == 850, "moisture ml", str(gs.machine_state.get("moisture_farm", {})))
	gs.machine_toggle_active("moisture_farm")

	# cage + feed + vacuum
	gs.power = 100
	gs.add_item(gs.make_item("rat", 100, true, false))
	var rat_uid = int(gs.inventory[gs.inventory.size() - 1]["uid"])
	var cadd = gs.machine_stock_add("animal_cage", rat_uid)
	check(cadd.get("ok", false), "cage stock rat", cadd.get("text", ""))
	gs.machine_toggle_active("animal_cage")
	gs.advance_machines_one_cycle()
	check(int(gs.machine_state.get("animal_cage", {}).get("health", 0)) == 100, "cage health 1 rat no wear", str(gs.machine_state.get("animal_cage", {})))
	gs.add_item(gs.make_item("nutrifruit", 100, true, false))
	var feed_uid = int(gs.inventory[gs.inventory.size() - 1]["uid"])
	gs.machine_stock_add("livestock_feed_dispenser", feed_uid)
	gs.machine_toggle_active("livestock_feed_dispenser")
	gs.advance_machines_one_cycle()
	check(int(gs.machine_state.get("livestock_feed_dispenser", {}).get("kcal", 0)) == 500, "feed kcal", str(gs.machine_state.get("livestock_feed_dispenser", {})))
	if gs.items_def.has("feces_small"):
		gs.add_item(gs.make_item("feces_small", 100, true, false))
		gs.machine_toggle_active("vacuum_robot")
		var before = gs.next_day_power_bonus
		gs.advance_machines_one_cycle()
		check(gs.next_day_power_bonus > before, "vacuum incinerates feces", str(gs.next_day_power_bonus))
		gs.machine_toggle_active("vacuum_robot")
	gs.machine_toggle_active("animal_cage")
	gs.machine_toggle_active("livestock_feed_dispenser")

	# deal maker
	gs.power = 100
	gs.current_customer = {"intent": "buy", "arche": {"faction": "lower", "price_mod": 1.0, "budget": 1000}, "offer": 0, "max_price": 0, "done": false}
	var deal = gs.machine_special_action("deal_maker")
	check(deal.get("ok", false) and gs.bargain_bonus >= 10, "deal maker bargain", deal.get("text", ""))
	gs.current_customer = {}

	# furnace blast module
	gs.clear_modules("furnace")
	gs.install_module("furnace", "furnace_module_blast")
	gs.add_item(gs.make_item("scrap_metal", 100, true, false))
	gs.add_item(gs.make_item("scrap_metal", 100, true, false))
	gs.add_item(gs.make_item("scrap_metal", 100, true, false))
	gs.set_machine_recipe("furnace", "smelt_scrap")
	var fb = gs.start_machine("furnace")
	check(fb.get("ok", false), "furnace blast start", fb.get("text", ""))
	check(int(gs.machine_jobs[-1]["outputs"][0]["count"]) == 2, "furnace blast output 2", str(gs.machine_jobs[-1]["outputs"]))
	for i in range(2):
		gs.advance_machines_one_cycle()
	check(gs.inventory_count("metal_ingot") >= 2, "furnace blast produced", str(gs.inventory_count("metal_ingot")))
	gs.clear_modules("furnace")

	# printer melee batch + module requirement
	gs.power = 100
	gs.add_item(gs.make_item("metal_ingot", 100, true, false))
	gs.add_item(gs.make_item("metal_ingot", 100, true, false))
	gs.add_item(gs.make_item("printer_chip_combat_knife", 100, true, false))
	gs.set_machine_recipe("printer", "printer_chip_combat_knife")
	var p1 = gs.start_machine("printer")
	check(not p1.get("ok", false), "printer metal chip requires module", p1.get("text", ""))
	gs.install_module("printer", "printer_module_metal")
	gs.install_module("printer", "printer_module_melee_batch")
	gs.add_item(gs.make_item("metal_ingot", 100, true, false))
	gs.add_item(gs.make_item("metal_ingot", 100, true, false))
	var p2 = gs.start_machine("printer")
	check(p2.get("ok", false), "printer melee start", p2.get("text", ""))
	check(int(gs.machine_jobs[-1]["outputs"][0]["count"]) == 6, "melee batch +1", str(gs.machine_jobs[-1]["outputs"]))
	gs.clear_modules("printer")
	gs.machine_jobs = []

	# desequencer chip gate
	gs.set_machine_recipe("desequencer", "crypto_module_sec")
	gs.add_item(gs.make_item("blank_keycard", 100, true, false))
	var d1 = gs.start_machine("desequencer")
	check(not d1.get("ok", false), "desequencer requires crypto chip", d1.get("text", ""))
	gs.add_item(gs.make_item("crypto_module_sec", 100, true, false))
	var d2 = gs.start_machine("desequencer")
	check(d2.get("ok", false), "desequencer starts with chip", d2.get("text", ""))

	# bottle printer unlock
	gs.power = 100
	gs.set_machine_recipe("bottle_printer", "normal")
	var b1 = gs.start_machine("bottle_printer")
	check(not b1.get("ok", false), "bottle normal locked", b1.get("text", ""))
	for i in range(3):
		gs.add_item(gs.make_item("common_electronic", 100, true, false))
	for i in range(3):
		gs._upgrade_action("bottle_printer", gs.machine_def("bottle_printer").get("special", {}))
	gs.power = 100
	var b2 = gs.start_machine("bottle_printer")
	check(b2.get("ok", false), "bottle normal unlocked at 3", b2.get("text", ""))
	gs.machine_jobs = []

	# quality module output feature
	gs.power = 100
	gs.install_module("furnace", "system_module_quality")
	gs.add_item(gs.make_item("scrap_metal", 100, true, false))
	gs.add_item(gs.make_item("scrap_metal", 100, true, false))
	gs.set_machine_recipe("furnace", "smelt_scrap")
	var q0 = gs.inventory_count("metal_ingot")
	var qs = gs.start_machine("furnace")
	check(qs.get("ok", false), "quality furnace start", qs.get("text", ""))
	for i in range(2):
		gs.advance_machines_one_cycle()
	var qfeat := false
	for it in gs.inventory:
		if String(it.get("def_id", "")) == "metal_ingot":
			for f in it.get("features", []):
				if String(f.get("id", "")) == "machine_quality":
					qfeat = true
	check(qfeat, "module quality feature on output")

	# stress: all auxiliary machines active for three nights
	gs.machine_jobs = []
	for mid in aux_ids:
		gs.machine_toggle_active(mid)
	gs.power = 1000
	for i in range(3):
		gs.advance_machines_one_cycle()
	check(gs.phase != "gameover", "all aux three nights", str(gs.ending_id))

	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
