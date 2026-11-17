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
	check(not mc.is_empty() and int(gs.container_spec(mc).get("width", 0)) == 8, "fridge stock grid")
	var food = gs.make_item("nutrifruit", 100, true, false)
	gs.add_item(food)
	var sres = gs.machine_stock_add("fridge", int(food.uid))
	check(sres.get("ok", false) and gs.machine_container("fridge").children.size() == 1, "machine stock add", sres.get("text", ""))
	var tres = gs.machine_stock_take_all("fridge")
	check(tres.get("ok", false) and gs.machine_container("fridge").children.is_empty(), "machine stock take")
	# liquid transfer
	var jug2 = gs.make_item("water_jug", 100, true, false)
	var bottle2 = gs.make_item("bottled_water", 100, true, false)
	bottle2["liquid_ml"] = 0
	var tr = gs.transfer_liquid(jug2, bottle2)
	check(tr.get("ok", false) and int(bottle2.get("liquid_ml", 0)) == 750, "liquid transfer", tr.get("text", ""))
	# lock/unlock
	var box = gs.make_item("sec_box", 100, true, false)
	check(bool(box.get("container_locked", false)), "sec box locked")
	var key = gs.make_item("sec_keycard", 100, true, false)
	gs.add_item(key)
	var lr = gs.unlock_container(box, key)
	check(lr.get("ok", false) and not bool(box.get("container_locked", true)), "sec box unlocked", lr.get("text", ""))
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
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
