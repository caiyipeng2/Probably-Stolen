extends SceneTree

var fails := 0
func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok: fails += 1

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	gs.rng.seed = 20261115
	check(gs.containers_def.size() >= 30, "container defs", str(gs.containers_def.size()))
	var bag = gs.make_item("backpack_large", 100, true, false)
	check(gs.is_container_item(bag), "backpack container")
	check(int(gs.container_spec(bag).get("width", 0)) == 8 and int(gs.container_spec(bag).get("height", 0)) == 9, "backpack 8x9")
	gs.add_item(bag)
	var fruit = gs.make_item("nutrifruit", 100, true, false)
	gs.add_item(fruit)
	var before_val = gs.effective_value(bag)
	var before_count = gs.inventory_count("nutrifruit")
	var moved = gs.move_item_to_container(int(fruit.uid), int(bag.uid))
	check(moved and bag.children.size() == 1, "move into backpack", str(bag.children.size()))
	check(gs.inventory_count("nutrifruit") == before_count, "nested count recursive", str(gs.inventory_count("nutrifruit")))
	check(gs.find_item(int(fruit.uid)).size() > 0, "find nested item")
	check(gs.effective_value(bag) > before_val, "container value includes child", "%d -> %d" % [before_val, gs.effective_value(bag)])
	check(not gs.container_can_accept(bag, gs.make_item("backpack_small", 100, true, false)), "no backpack nesting")
	var seedp = gs.make_item("nutrifruit_seed_packet", 100, true, false)
	check(gs.is_container_item(seedp), "seed packet container")
	check(gs.container_can_accept(seedp, gs.make_item("nutrifruit_seed", 100, true, false)), "seed packet accepts seed")
	check(not gs.container_can_accept(seedp, gs.make_item("nutrifruit", 100, true, false)), "seed packet rejects fruit")
	var ammo = gs.make_item("ammo_box", 100, true, false)
	var bullet = gs.make_item("small_pistol_ammo", 100, true, false)
	check(gs.is_container_item(ammo), "ammo box container")
	check(gs.container_can_accept(ammo, bullet), "ammo box accepts ammo")
	check(not gs.container_can_accept(ammo, gs.make_item("nutrifruit", 100, true, false)), "ammo box rejects food")
	var gun = gs.make_item("handmade_pistol", 100, true, false)
	check(gs.is_container_item(gun), "gun slot container")
	check(gs.container_can_accept(gun, gs.make_item("silencer", 100, true, false)), "gun accepts barrel mod")
	check(not gs.container_can_accept(gun, gs.make_item("nutrifruit", 100, true, false)), "gun rejects food")
	var jug = gs.make_item("water_jug", 100, true, false)
	check(int(jug.get("liquid_ml", 0)) == 6000, "water jug 6000ml", str(jug.get("liquid_ml")))
	check(gs.can_place(gs.make_item("nutrifruit", 100, true, false), 1, 1, false, -1, 2), "hidden 2x2 placement")
	check(not gs.can_place(gs.make_item("nutrifruit", 100, true, false), 2, 0, false, -1, 2), "hidden boundary")
	# remove nested
	check(gs.remove_inventory("nutrifruit", gs.inventory_count("nutrifruit")), "remove nested item")
	check(bag.children.is_empty(), "bag emptied", str(bag.children.size()))
	# save/load nested
	gs.add_item(gs.make_item("nutrifruit", 100, true, false))
	var f2 = gs.inventory[gs.inventory.size() - 1]
	gs.move_item_to_container(int(f2.uid), int(bag.uid))
	gs.save_game(9)
	gs.new_game()
	gs.load_game(9)
	var bag2 = gs.find_item(int(bag.uid))
	check(not bag2.is_empty() and bag2.children.size() == 1, "nested save/load", str(bag2.get("children", []).size()))
	# machine stock grids
	gs.machine_stock["fridge"] = []
	var mc = gs.machine_container("fridge")
	check(not mc.is_empty() and gs.container_effective_width(gs.container_spec(mc)) == 8, "fridge stock grid")
	check(gs.container_zones(gs.container_spec(mc)).size() == 2, "fridge two zones")
	gs.machine_upgrades["fridge"] = 2
	gs.machine_container_items.erase("fridge")
	var mc2 = gs.machine_container("fridge")
	check(int(gs.container_spec(mc2).get("height", 0)) == 4, "fridge capacity upgrade", str(gs.container_spec(mc2)))
	gs.machine_upgrades["fridge"] = 0
	gs.machine_container_items.erase("fridge")
	# zone acceptance
	var water = gs.make_item("bottled_water", 100, true, false)
	gs.add_item(water)
	var sres = gs.machine_stock_add("fridge", int(water.uid))
	check(sres.get("ok", false) and gs.machine_container("fridge").children.size() == 1, "fridge chill add", sres.get("text", ""))
	var chill_child = gs.machine_container("fridge").children[0]
	check(gs.container_zone_at(gs.container_spec(gs.machine_container("fridge")), int(chill_child.get("x", 0))).get("id", "") == "chill", "water lands in chill zone", str(chill_child.get("x", 0)))
	var fruit2 = gs.make_item("nutrifruit", 100, true, false)
	gs.add_item(fruit2)
	var fstat = gs.machine_stock_add("fridge", int(fruit2.uid))
	check(not fstat.get("ok", false), "fridge rejects fruit", fstat.get("text", ""))
	var ice = gs.make_item("beis_icecream", 100, true, false)
	gs.add_item(ice)
	check(gs.machine_stock_add("fridge", int(ice.uid)).get("ok", false), "ice cream stored")
	var fspec = gs.container_spec(gs.machine_container("fridge"))
	var ice_child = {}
	for ch in gs.machine_container("fridge").children:
		if String(ch.get("def_id", "")) == "beis_icecream":
			ice_child = ch
	check(not ice_child.is_empty() and gs.container_zone_at(fspec, int(ice_child.get("x", 0))).get("id", "") == "freeze", "ice cream lands in freeze")
	# cold features after nightly run
	gs.power = 99
	gs._run_fridge("fridge", gs.machine_def("fridge").get("special", {}))
	var has_chilled := false
	for f in water.get("features", []):
		if String(f.get("id", "")) == "chilled":
			has_chilled = true
	check(has_chilled, "water chilled overnight")
	var has_frozen := false
	for f in ice.get("features", []):
		if String(f.get("id", "")) == "frozen":
			has_frozen = true
	check(has_frozen, "ice cream frozen overnight")
	var tres = gs.machine_stock_take_all("fridge")
	check(tres.get("ok", false) and gs.machine_container("fridge").children.is_empty(), "machine stock take")
	# ammo stacking
	var before_size = gs.inventory.size()
	var a1 = gs.make_item("small_pistol_ammo", 100, true, false)
	var a2 = gs.make_item("small_pistol_ammo", 100, true, false)
	gs.add_item(a1)
	gs.add_item(a2)
	check(gs.inventory.size() == before_size + 1, "ammo stacks", str(gs.inventory.size()))
	check(gs.inventory_count("small_pistol_ammo") == 2, "ammo count", str(gs.inventory_count("small_pistol_ammo")))
	check(gs.remove_inventory("small_pistol_ammo", 1) and gs.inventory_count("small_pistol_ammo") == 1, "ammo partial remove")
	# stack split
	var a3 = gs.make_item("small_pistol_ammo", 100, true, false)
	a3["unit_count"] = 4
	gs.add_item(a3)
	var stack_uid := -1
	for it in gs.inventory:
		if String(it.get("def_id", "")) == "small_pistol_ammo" and int(it.get("unit_count", 1)) > 1:
			stack_uid = int(it.get("uid", -1))
	var split_res = gs.split_stack(stack_uid)
	check(split_res.get("ok", false) and gs.inventory_count("small_pistol_ammo") == 5, "stack split count", split_res.get("text", ""))
	var has_extra := false
	for it in gs.inventory:
		if String(it.get("def_id", "")) == "small_pistol_ammo" and int(it.get("unit_count", 1)) == 2:
			has_extra = true
	check(has_extra, "stack split makes separate pile")
	# liquid transfer
	var jug2 = gs.make_item("water_jug", 100, true, false)
	var bottle2 = gs.make_item("bottled_water", 100, true, false)
	bottle2["liquid_ml"] = 0
	var tr = gs.transfer_liquid(jug2, bottle2)
	check(tr.get("ok", false) and int(bottle2.get("liquid_ml", 0)) == 750, "liquid transfer", tr.get("text", ""))
	# liquid split
	var jug3 = gs.make_item("water_jug", 100, true, false)
	gs.add_item(jug3)
	var sp = gs.split_liquid(jug3)
	check(sp.get("ok", false) and int(jug3.get("liquid_ml", 0)) == 3000, "liquid split", sp.get("text", ""))
	# liquid filter slots
	var pitcher = gs.make_item("water_pitcher", 100, true, false)
	check(gs.is_liquid_container(pitcher) and gs.is_container_item(pitcher), "pitcher is liquid container")
	check(int(gs.container_spec(pitcher).get("filter_slots", 0)) == 1, "pitcher filter slot")
	gs.add_item(pitcher)
	var filt = gs.make_item("water_filter", 100, true, false)
	gs.add_item(filt)
	check(gs.move_item_to_container(int(filt.uid), int(pitcher.uid)), "filter fits pitcher")
	check(int(gs.container_filter_at(pitcher).get("uid", -1)) == int(filt.uid), "filter in slot")
	pitcher["liquid_ml"] = 0
	pitcher["liquid_purity"] = 0
	var muddy = gs.make_item("water_jug", 100, true, false)
	muddy["liquid_ml"] = 6000
	muddy["liquid_purity"] = 1000
	gs.transfer_liquid(muddy, pitcher)
	check(int(pitcher.get("liquid_ml", 0)) == 3000 and int(pitcher.get("liquid_purity", 0)) >= 8500, "filter purifies water", str(pitcher.get("liquid_purity", 0)))
	check(int(filt.get("condition", 100)) < 100, "filter wears", str(filt.get("condition", 100)))
	check(int(gs.container_filter_slots(gs.container_def("ras_water_tank"))) == 4, "ras tank four filter slots")
	# machine input/output grids
	gs.power = 99
	var fin = gs.machine_io_container("furnace", "input")
	var fout = gs.machine_io_container("furnace", "output")
	check(int(gs.container_spec(fin).get("width", 0)) == 9 and int(gs.container_spec(fout).get("height", 0)) == 6, "furnace io grids")
	for i in range(2):
		var scrap = gs.make_item("scrap_metal", 100, true, false)
		gs.add_item(scrap)
		check(gs.move_item_to_container(int(scrap.uid), int(fin.uid)), "scrap into furnace input")
	var fstart = gs.start_machine("furnace")
	check(fstart.get("ok", false) and fin.get("children", []).is_empty(), "furnace consumes input grid", fstart.get("text", ""))
	for j in gs.machine_jobs:
		if String(j.get("machine_id", "")) == "furnace":
			j["remaining"] = 1
	gs.advance_machines_one_cycle()
	var out_has_ingot := false
	for ch in fout.get("children", []):
		if String(ch.get("def_id", "")) == "metal_ingot":
			out_has_ingot = true
	check(out_has_ingot, "furnace output lands in grid")
	# slot input/output machine
	var din = gs.machine_io_container("desequencer", "input")
	var dout = gs.machine_io_container("desequencer", "output")
	check(int(gs.container_spec(din).get("slots", []).size()) == 1, "desequencer input slot")
	var blank = gs.make_item("blank_keycard", 100, true, false)
	gs.add_item(blank)
	check(gs.move_item_to_container(int(blank.uid), int(din.uid)), "blank card into slot")
	var chip = gs.make_item("crypto_module_sec", 100, true, false)
	gs.add_item(chip)
	var dstart = gs.start_machine("desequencer")
	check(dstart.get("ok", false) and din.get("children", []).is_empty(), "desequencer consumes slot", dstart.get("text", ""))
	for j in gs.machine_jobs:
		if String(j.get("machine_id", "")) == "desequencer":
			j["remaining"] = 1
	gs.advance_machines_one_cycle()
	var out_card := false
	for ch in dout.get("children", []):
		if String(ch.get("def_id", "")) == "sec_keycard":
			out_card = true
	check(out_card, "desequencer result in output slot")
	# lock/unlock
	var box = gs.make_item("sec_box", 100, true, false)
	check(bool(box.get("container_locked", false)), "sec box locked")
	var key = gs.make_item("sec_keycard", 100, true, false)
	gs.add_item(key)
	var lr = gs.unlock_container(box, key)
	check(lr.get("ok", false) and not bool(box.get("container_locked", true)), "sec box unlocked", lr.get("text", ""))
	check(int(box.get("custom_base_value", 0)) == 15 and not bool(box.get("stolen", true)) and bool(box.get("contraband_cleared", false)), "unlock clears crate status")
	check(gs.loot_tables.size() == 5 and not box.get("children", []).is_empty(), "unlock generates loot", str(box.get("children", []).size()))
	# showcase 7x5
	gs.display = []
	var added := 0
	for i in range(36):
		var d: Dictionary = gs.make_item("nutrifruit", 100, true, false)
		gs.add_item(d)
		if gs.add_to_display(int(d.uid)):
			added += 1
	check(added == 35, "showcase 7x5 capacity", str(added))
	check(int(gs.display[0].get("x", -1)) >= 0 and int(gs.display[0].get("y", -1)) >= 0, "showcase positions")
	# alpha-derived item shape masks
	gs.inventory.clear()
	var ga = gs.make_item("glock_receiver", 100, true, false)
	var gm = gs.item_mask_cells(ga)
	check(gm.size() == 2 and bool(gm[0]) and not bool(gm[1]), "alpha shape mask", str(gm))
	ga["page"] = 0
	ga["x"] = 0
	ga["y"] = 0
	gs.inventory.append(ga)
	var gb = gs.make_item("glock_receiver", 100, true, false)
	check(gs.can_place(gb, 1, 0, false, -1, 0), "alpha mask allows tuck")
	check(not gs.can_place(gb, 0, 0, false, -1, 0), "alpha mask blocks overlap")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
