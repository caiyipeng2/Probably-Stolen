# [L2 执行层] aux_machines.gd — 17 台辅助设备与逐机器规则
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.new_game()
	state.rng.seed = 20261113

func run() -> void:
	var aux_ids := ["deal_maker", "recharger", "powerblock", "makeshift_reactor", "security_alarm",
		"storage_coordinator", "mirage_projector", "vending_machine", "vending_fountain",
		"vending_machine_core", "vending_fountain_core", "wine_rack", "animal_cage",
		"marking_pen", "vacuum_robot", "cassette_player", "ras_water_tank"]
	var aux := 0
	for m in state.machines:
		if String(m.get("id", "")) in aux_ids and m.has("special"):
			aux += 1
	check_eq(aux, 17, "passive aux specials count")
	var bad = state.install_module("furnace", "printer_module_metal")
	check(not bool(bad.get("ok", false)), "furnace rejects printer module", String(bad.get("text", "")))
	var good = state.install_module("furnace", "system_module_quality")
	check(bool(good.get("ok", false)), "furnace accepts universal module", String(good.get("text", "")))
	state.clear_modules("furnace")
	var ph := ""
	for r in state.machine_def("printer").get("recipes", []):
		var n = state.machine_recipe_name(r)
		if n.contains("{"):
			ph = n
	check_eq(ph, "", "recipe placeholders formatted")
	state.machine_toggle_active("powerblock")
	check_eq(state.max_power, 12, "powerblock max power")
	state.machine_toggle_active("powerblock")
	state.machine_toggle_active("recharger")
	state.advance_machines_one_cycle()
	check(state.next_day_power_bonus >= 3, "recharger bonus", str(state.next_day_power_bonus))
	state.machine_toggle_active("recharger")
	state.next_day_power_bonus = 0
	state.machine_toggle_active("makeshift_reactor")
	state.advance_machines_one_cycle()
	var rst = state.machine_state.get("makeshift_reactor", {})
	check_eq(int(rst.get("integrity", 0)), 82, "reactor decay")
	check(state.next_day_power_bonus >= 1, "reactor charges power", str(state.next_day_power_bonus))
	state.machine_toggle_active("makeshift_reactor")
	state.next_day_power_bonus = 0
	state.power = 100
	state.machine_toggle_active("mirage_projector")
	state.advance_machines_one_cycle()
	check_eq(state.attraction_bonus, 100, "projector attraction base")
	state.machine_toggle_active("mirage_projector")
	state.power = 100
	state.machine_toggle_active("security_alarm")
	state.advance_machines_one_cycle()
	check(state.security_alarm_active, "alarm active", str(state.security_stop_rate))
	state.machine_toggle_active("security_alarm")
	state.power = 100
	state.add_item(state.make_item("nutrifruit", 100, true, false))
	var sres = state.machine_stock_add("vending_machine", int(state.inventory[state.inventory.size() - 1]["uid"]))
	check(bool(sres.get("ok", false)), "vending stock", String(sres.get("text", "")))
	state.machine_toggle_active("vending_machine")
	state.advance_machines_one_cycle()
	check(int(state.machine_cash.get("vending_machine", 0)) > 0, "vending sale cash", str(state.machine_cash.get("vending_machine", 0)))
	var collect = state.machine_special_choice("vending_machine", "collect")
	check(bool(collect.get("ok", false)), "vending collect", String(collect.get("text", "")))
	state.machine_toggle_active("vending_machine")
	state.power = 100
	state.add_item(state.make_item("wine_bottle", 100, true, false))
	var wine_uid := int(state.inventory[state.inventory.size() - 1]["uid"])
	state.machine_stock_add("wine_rack", wine_uid)
	state.machine_toggle_active("wine_rack")
	state.advance_machines_one_cycle()
	var wstock = state.machine_stock.get("wine_rack", [])
	check(not wstock.is_empty() and int(wstock[0].get("aged_days", 0)) >= 1, "wine aging", str(wstock[0].get("aged_days", 0)) if not wstock.is_empty() else "empty")
	state.machine_toggle_active("wine_rack")
	state.power = 100
	state.add_item(state.make_item("bottled_water", 100, true, false))
	var f_uid := int(state.inventory[state.inventory.size() - 1]["uid"])
	var fadd = state.machine_stock_add("fridge", f_uid)
	check(bool(fadd.get("ok", false)), "fridge accepts water", String(fadd.get("text", "")))
	state.machine_toggle_active("fridge")
	state.advance_machines_one_cycle()
	var fstock = state.machine_stock.get("fridge", [])
	var chilled := false
	if not fstock.is_empty():
		for f in fstock[0].get("features", []):
			if String(f.get("id", "")) == "chilled":
				chilled = true
	check(chilled, "fridge chilled feature")
	state.machine_toggle_active("fridge")
	state.power = 100
	state.machine_toggle_active("moisture_farm")
	state.advance_machines_one_cycle()
	check_eq(int(state.machine_state.get("moisture_farm", {}).get("ml", 0)), 850, "moisture ml")
	state.machine_toggle_active("moisture_farm")
	state.power = 100
	state.add_item(state.make_item("rat", 100, true, false))
	var rat_uid := int(state.inventory[state.inventory.size() - 1]["uid"])
	var cadd = state.machine_stock_add("animal_cage", rat_uid)
	check(bool(cadd.get("ok", false)), "cage stock rat", String(cadd.get("text", "")))
	state.machine_toggle_active("animal_cage")
	state.advance_machines_one_cycle()
	check_eq(int(state.machine_state.get("animal_cage", {}).get("health", 0)), 100, "cage health 1 rat no wear")
	state.add_item(state.make_item("nutrifruit", 100, true, false))
	var feed_uid := int(state.inventory[state.inventory.size() - 1]["uid"])
	state.machine_stock_add("livestock_feed_dispenser", feed_uid)
	state.machine_toggle_active("livestock_feed_dispenser")
	state.advance_machines_one_cycle()
	check_eq(int(state.machine_state.get("livestock_feed_dispenser", {}).get("kcal", 0)), 500, "feed kcal")
	if state.items_def.has("feces_small"):
		state.add_item(state.make_item("feces_small", 100, true, false))
		state.machine_toggle_active("vacuum_robot")
		var before = state.next_day_power_bonus
		state.advance_machines_one_cycle()
		check(state.next_day_power_bonus > before, "vacuum incinerates feces", str(state.next_day_power_bonus))
		state.machine_toggle_active("vacuum_robot")
	state.machine_toggle_active("animal_cage")
	state.machine_toggle_active("livestock_feed_dispenser")
	state.power = 100
	state.current_customer = {"intent": "buy", "arche": {"faction": "lower", "price_mod": 1.0, "budget": 1000}, "offer": 0, "max_price": 0, "done": false}
	var deal = state.machine_special_action("deal_maker")
	check(bool(deal.get("ok", false)) and state.bargain_bonus >= 10, "deal maker bargain", String(deal.get("text", "")))
	state.current_customer = {}
	state.clear_modules("furnace")
	state.install_module("furnace", "furnace_module_blast")
	for i in range(3):
		state.add_item(state.make_item("scrap_metal", 100, true, false))
	state.set_machine_recipe("furnace", "smelt_scrap")
	var fb = state.start_machine("furnace")
	check(bool(fb.get("ok", false)), "furnace blast start", String(fb.get("text", "")))
	check_eq(int(state.machine_jobs[-1]["outputs"][0]["count"]), 2, "furnace blast output 2")
	for i in range(2):
		state.advance_machines_one_cycle()
	var fout_box = state.machine_io_container("furnace", "output")
	check(fout_box.get("children", []).size() >= 2, "furnace blast produced", str(fout_box.get("children", []).size()))
	fout_box["children"].clear()
	state.clear_modules("furnace")
	state.power = 100
	state.add_item(state.make_item("metal_ingot", 100, true, false))
	state.add_item(state.make_item("printer_chip_combat_knife", 100, true, false))
	state.set_machine_recipe("printer", "printer_chip_combat_knife")
	var p1 = state.start_machine("printer")
	check(not bool(p1.get("ok", true)), "printer metal chip requires module", String(p1.get("text", "")))
	state.install_module("printer", "printer_module_metal")
	state.install_module("printer", "printer_module_melee_batch")
	for i in range(2):
		state.add_item(state.make_item("metal_ingot", 100, true, false))
	var p2 = state.start_machine("printer")
	check(bool(p2.get("ok", false)), "printer melee start", String(p2.get("text", "")))
	check_eq(int(state.machine_jobs[-1]["outputs"][0]["count"]), 6, "melee batch +1")
	state.clear_modules("printer")
	state.machine_jobs = []
	state.set_machine_recipe("desequencer", "crypto_module_sec")
	state.add_item(state.make_item("blank_keycard", 100, true, false))
	var d1 = state.start_machine("desequencer")
	check(not bool(d1.get("ok", true)), "desequencer requires crypto chip", String(d1.get("text", "")))
	state.add_item(state.make_item("crypto_module_sec", 100, true, false))
	var d2 = state.start_machine("desequencer")
	check(bool(d2.get("ok", false)), "desequencer starts with chip", String(d2.get("text", "")))
	state.power = 100
	state.set_machine_recipe("bottle_printer", "normal")
	var b1 = state.start_machine("bottle_printer")
	check(not bool(b1.get("ok", true)), "bottle normal locked", String(b1.get("text", "")))
	for i in range(3):
		state.add_item(state.make_item("common_electronic", 100, true, false))
	for i in range(3):
		state._upgrade_action("bottle_printer", state.machine_def("bottle_printer").get("special", {}))
	state.power = 100
	var b2 = state.start_machine("bottle_printer")
	check(bool(b2.get("ok", false)), "bottle normal unlocked at 3", String(b2.get("text", "")))
	state.machine_jobs = []
	state.power = 100
	state.install_module("furnace", "system_module_quality")
	for i in range(2):
		state.add_item(state.make_item("scrap_metal", 100, true, false))
	state.set_machine_recipe("furnace", "smelt_scrap")
	var qs = state.start_machine("furnace")
	check(bool(qs.get("ok", false)), "quality furnace start", String(qs.get("text", "")))
	for i in range(2):
		state.advance_machines_one_cycle()
	var qfeat := false
	var qbox = state.machine_io_container("furnace", "output")
	for it in qbox.get("children", []):
		if String(it.get("def_id", "")) == "metal_ingot":
			for f in it.get("features", []):
				if String(f.get("id", "")) == "machine_quality":
					qfeat = true
	check(qfeat, "module quality feature on output")
	state.machine_jobs = []
	for mid in aux_ids:
		state.machine_toggle_active(mid)
	state.power = 1000
	for i in range(3):
		state.advance_machines_one_cycle()
	check(state.phase != "gameover", "all aux three nights", str(state.ending_id))

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
