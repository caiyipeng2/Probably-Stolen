# [L2 执行层] containers.gd — 嵌套容器、冰箱、网格、锁箱、分堆、液体
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.new_game()
	state.rng.seed = 20261115

func run() -> void:
	check(state.containers_def.size() >= 30, "container defs", str(state.containers_def.size()))
	var bag = state.make_item("backpack_large", 100, true, false)
	check(state.is_container_item(bag), "backpack container")
	check(int(state.container_spec(bag).get("width", 0)) == 8 and int(state.container_spec(bag).get("height", 0)) == 9, "backpack 8x9")
	state.add_item(bag)
	var fruit = state.make_item("nutrifruit", 100, true, false)
	state.add_item(fruit)
	var before_val = state.effective_value(bag)
	var before_count = state.inventory_count("nutrifruit")
	var moved = state.move_item_to_container(int(fruit.uid), int(bag.uid))
	check(moved and bag.children.size() == 1, "move into backpack", str(bag.children.size()))
	check(state.inventory_count("nutrifruit") == before_count, "nested count recursive", str(state.inventory_count("nutrifruit")))
	check(state.find_item(int(fruit.uid)).size() > 0, "find nested item")
	check(state.effective_value(bag) > before_val, "container value includes child", "%d -> %d" % [before_val, state.effective_value(bag)])
	check(not state.container_can_accept(bag, state.make_item("backpack_small", 100, true, false)), "no backpack nesting")
	var seedp = state.make_item("nutrifruit_seed_packet", 100, true, false)
	check(state.is_container_item(seedp), "seed packet container")
	check(state.container_can_accept(seedp, state.make_item("nutrifruit_seed", 100, true, false)), "seed packet accepts seed")
	check(not state.container_can_accept(seedp, state.make_item("nutrifruit", 100, true, false)), "seed packet rejects fruit")
	var ammo = state.make_item("ammo_box", 100, true, false)
	var bullet = state.make_item("small_pistol_ammo", 100, true, false)
	check(state.is_container_item(ammo), "ammo box container")
	check(state.container_can_accept(ammo, bullet), "ammo box accepts ammo")
	check(not state.container_can_accept(ammo, state.make_item("nutrifruit", 100, true, false)), "ammo box rejects food")
	var gun = state.make_item("handmade_pistol", 100, true, false)
	check(state.is_container_item(gun), "gun slot container")
	check(state.container_can_accept(gun, state.make_item("silencer", 100, true, false)), "gun accepts barrel mod")
	check(not state.container_can_accept(gun, state.make_item("nutrifruit", 100, true, false)), "gun rejects food")
	var jug = state.make_item("water_jug", 100, true, false)
	check(int(jug.get("liquid_ml", 0)) == 6000, "water jug 6000ml", str(jug.get("liquid_ml")))
	check(state.can_place(state.make_item("nutrifruit", 100, true, false), 1, 1, false, -1, 2), "hidden 2x2 placement")
	check(not state.can_place(state.make_item("nutrifruit", 100, true, false), 2, 0, false, -1, 2), "hidden boundary")
	check(state.remove_inventory("nutrifruit", state.inventory_count("nutrifruit")), "remove nested item")
	check(bag.children.is_empty(), "bag emptied", str(bag.children.size()))
	state.add_item(state.make_item("nutrifruit", 100, true, false))
	var f2 = state.inventory[state.inventory.size() - 1]
	state.move_item_to_container(int(f2.uid), int(bag.uid))
	state.save_game(9)
	state.new_game()
	state.load_game(9)
	var bag2 = state.find_item(int(bag.uid))
	check(not bag2.is_empty() and bag2.children.size() == 1, "nested save/load", str(bag2.get("children", []).size()))
	state.machine_stock["fridge"] = []
	var mc = state.machine_container("fridge")
	check(not mc.is_empty() and state.container_effective_width(state.container_spec(mc)) == 8, "fridge stock grid")
	check(state.container_zones(state.container_spec(mc)).size() == 2, "fridge two zones")
	state.machine_upgrades["fridge"] = 2
	state.machine_container_items.erase("fridge")
	var mc2 = state.machine_container("fridge")
	check(int(state.container_spec(mc2).get("height", 0)) == 4, "fridge capacity upgrade", str(state.container_spec(mc2)))
	state.machine_upgrades["fridge"] = 0
	state.machine_container_items.erase("fridge")
	var water = state.make_item("bottled_water", 100, true, false)
	state.add_item(water)
	var sres = state.machine_stock_add("fridge", int(water.uid))
	check(sres.get("ok", false) and state.machine_container("fridge").children.size() == 1, "fridge chill add", sres.get("text", ""))
	var chill_child = state.machine_container("fridge").children[0]
	check(state.container_zone_at(state.container_spec(state.machine_container("fridge")), int(chill_child.get("x", 0))).get("id", "") == "chill", "water lands in chill zone", str(chill_child.get("x", 0)))
	var fruit2 = state.make_item("nutrifruit", 100, true, false)
	state.add_item(fruit2)
	var fstat = state.machine_stock_add("fridge", int(fruit2.uid))
	check(not fstat.get("ok", false), "fridge rejects fruit", fstat.get("text", ""))
	var ice = state.make_item("beis_icecream", 100, true, false)
	state.add_item(ice)
	check(state.machine_stock_add("fridge", int(ice.uid)).get("ok", false), "ice cream stored")
	var fspec = state.container_spec(state.machine_container("fridge"))
	var ice_child = {}
	for ch in state.machine_container("fridge").children:
		if String(ch.get("def_id", "")) == "beis_icecream":
			ice_child = ch
	check(not ice_child.is_empty() and state.container_zone_at(fspec, int(ice_child.get("x", 0))).get("id", "") == "freeze", "ice cream lands in freeze")
	state.power = 99
	state._run_fridge("fridge", state.machine_def("fridge").get("special", {}))
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
	var tres = state.machine_stock_take_all("fridge")
	check(tres.get("ok", false) and state.machine_container("fridge").children.is_empty(), "machine stock take")
	var before_size = state.inventory.size()
	var a1 = state.make_item("small_pistol_ammo", 100, true, false)
	var a2 = state.make_item("small_pistol_ammo", 100, true, false)
	state.add_item(a1)
	state.add_item(a2)
	check(state.inventory.size() == before_size + 1, "ammo stacks", str(state.inventory.size()))
	check(state.inventory_count("small_pistol_ammo") == 2, "ammo count", str(state.inventory_count("small_pistol_ammo")))
	check(state.remove_inventory("small_pistol_ammo", 1) and state.inventory_count("small_pistol_ammo") == 1, "ammo partial remove")
	var a3 = state.make_item("small_pistol_ammo", 100, true, false)
	a3["unit_count"] = 4
	state.add_item(a3)
	var stack_uid := -1
	for it in state.inventory:
		if String(it.get("def_id", "")) == "small_pistol_ammo" and int(it.get("unit_count", 1)) > 1:
			stack_uid = int(it.get("uid", -1))
	var split_res = state.split_stack(stack_uid)
	check(split_res.get("ok", false) and state.inventory_count("small_pistol_ammo") == 5, "stack split count", split_res.get("text", ""))
	var has_extra := false
	for it in state.inventory:
		if String(it.get("def_id", "")) == "small_pistol_ammo" and int(it.get("unit_count", 1)) == 2:
			has_extra = true
	check(has_extra, "stack split makes separate pile")
	var jug2 = state.make_item("water_jug", 100, true, false)
	var bottle2 = state.make_item("bottled_water", 100, true, false)
	bottle2["liquid_ml"] = 0
	var tr = state.transfer_liquid(jug2, bottle2)
	check(tr.get("ok", false) and int(bottle2.get("liquid_ml", 0)) == 750, "liquid transfer", tr.get("text", ""))
	var jug3 = state.make_item("water_jug", 100, true, false)
	state.add_item(jug3)
	var sp = state.split_liquid(jug3)
	check(sp.get("ok", false) and int(jug3.get("liquid_ml", 0)) == 3000, "liquid split", sp.get("text", ""))
	var pitcher = state.make_item("water_pitcher", 100, true, false)
	check(state.is_liquid_container(pitcher) and state.is_container_item(pitcher), "pitcher is liquid container")
	check(int(state.container_spec(pitcher).get("filter_slots", 0)) == 1, "pitcher filter slot")
	state.add_item(pitcher)
	var filt = state.make_item("water_filter", 100, true, false)
	state.add_item(filt)
	check(state.move_item_to_container(int(filt.uid), int(pitcher.uid)), "filter fits pitcher")
	check(int(state.container_filter_at(pitcher).get("uid", -1)) == int(filt.uid), "filter in slot")
	pitcher["liquid_ml"] = 0
	pitcher["liquid_purity"] = 0
	var muddy = state.make_item("water_jug", 100, true, false)
	muddy["liquid_ml"] = 6000
	muddy["liquid_purity"] = 1000
	state.transfer_liquid(muddy, pitcher)
	check(int(pitcher.get("liquid_ml", 0)) == 3000 and int(pitcher.get("liquid_purity", 0)) >= 8500, "filter purifies water", str(pitcher.get("liquid_purity", 0)))
	check(int(filt.get("condition", 100)) < 100, "filter wears", str(filt.get("condition", 100)))
	check(int(state.container_filter_slots(state.container_def("ras_water_tank"))) == 4, "ras tank four filter slots")
	state.power = 99
	var fin = state.machine_io_container("furnace", "input")
	var fout = state.machine_io_container("furnace", "output")
	check(int(state.container_spec(fin).get("width", 0)) == 9 and int(state.container_spec(fout).get("height", 0)) == 6, "furnace io grids")
	for i in range(2):
		var scrap = state.make_item("scrap_metal", 100, true, false)
		state.add_item(scrap)
		check(state.move_item_to_container(int(scrap.uid), int(fin.uid)), "scrap into furnace input")
	var fstart = state.start_machine("furnace")
	check(fstart.get("ok", false) and fin.get("children", []).is_empty(), "furnace consumes input grid", fstart.get("text", ""))
	for j in state.machine_jobs:
		if String(j.get("machine_id", "")) == "furnace":
			j["remaining"] = 1
	state.advance_machines_one_cycle()
	var out_has_ingot := false
	for ch in fout.get("children", []):
		if String(ch.get("def_id", "")) == "metal_ingot":
			out_has_ingot = true
	check(out_has_ingot, "furnace output lands in grid")
	var din = state.machine_io_container("desequencer", "input")
	var dout = state.machine_io_container("desequencer", "output")
	check(int(state.container_spec(din).get("slots", []).size()) == 1, "desequencer input slot")
	var blank = state.make_item("blank_keycard", 100, true, false)
	state.add_item(blank)
	check(state.move_item_to_container(int(blank.uid), int(din.uid)), "blank card into slot")
	var chip = state.make_item("crypto_module_sec", 100, true, false)
	state.add_item(chip)
	var dstart = state.start_machine("desequencer")
	check(dstart.get("ok", false) and din.get("children", []).is_empty(), "desequencer consumes slot", dstart.get("text", ""))
	for j in state.machine_jobs:
		if String(j.get("machine_id", "")) == "desequencer":
			j["remaining"] = 1
	state.advance_machines_one_cycle()
	var out_card := false
	for ch in dout.get("children", []):
		if String(ch.get("def_id", "")) == "sec_keycard":
			out_card = true
	check(out_card, "desequencer result in output slot")
	var box = state.make_item("sec_box", 100, true, false)
	check(bool(box.get("container_locked", false)), "sec box locked")
	var key = state.make_item("sec_keycard", 100, true, false)
	state.add_item(key)
	var lr = state.unlock_container(box, key)
	check(lr.get("ok", false) and not bool(box.get("container_locked", true)), "sec box unlocked", lr.get("text", ""))
	check(int(box.get("custom_base_value", 0)) == 15 and not bool(box.get("stolen", true)) and bool(box.get("contraband_cleared", false)), "unlock clears crate status")
	check(state.loot_tables.size() == 5 and not box.get("children", []).is_empty(), "unlock generates loot", str(box.get("children", []).size()))
	state.display = []
	var added := 0
	for i in range(36):
		var d: Dictionary = state.make_item("nutrifruit", 100, true, false)
		state.add_item(d)
		if state.add_to_display(int(d.uid)):
			added += 1
	check(added == 35, "showcase 7x5 capacity", str(added))
	check(int(state.display[0].get("x", -1)) >= 0 and int(state.display[0].get("y", -1)) >= 0, "showcase positions")
	state.inventory.clear()
	var ga = state.make_item("glock_receiver", 100, true, false)
	var gm = state.item_mask_cells(ga)
	check(gm.size() == 2 and bool(gm[0]) and not bool(gm[1]), "alpha shape mask", str(gm))
	ga["page"] = 0
	ga["x"] = 0
	ga["y"] = 0
	state.inventory.append(ga)
	var gb = state.make_item("glock_receiver", 100, true, false)
	check(state.can_place(gb, 1, 0, false, -1, 0), "alpha mask allows tuck")
	check(not state.can_place(gb, 0, 0, false, -1, 0), "alpha mask blocks overlap")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
