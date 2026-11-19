extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func fresh(perks: Array = []) -> Node:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("normal")
	gs.rng.seed = 20261119
	if not perks.is_empty():
		var res: Dictionary = gs.apply_starting_perks(perks)
		check(bool(res.get("ok", false)), "apply perks " + str(perks), str(res))
	gs.phase = "endday"
	gs.afterhours_visits_left = 2 if gs.starting_perk_active("perk_speedy") else 1
	return gs

func _init() -> void:
	var gs = fresh()
	check(gs.scav_attempts_max() == 5, "base scav attempts 5", str(gs.scav_attempts_max()))
	gs.phase = "open"
	check(not bool(gs.afterhours_travel("dumping_ground").get("ok", true)), "travel blocked before closing")
	gs.phase = "endday"
	var t: Dictionary = gs.afterhours_travel("dumping_ground")
	check(bool(t.get("ok", false)) and gs.afterhours_visits_left == 0 and gs.afterhours_went_out and gs.last_afterhour_outing_day == gs.day, "travel sets night state", str(t))
	check(gs.scav_attempts_left() == 5, "scav attempts reset on travel", str(gs.scav_attempts_left()))
	for i in range(gs.inventory.size() - 1, -1, -1):
		if String(gs.inventory[i].get("def_id", "")) == "flashlight":
			gs.inventory.remove_at(i)
	check(is_equal_approx(gs.scav_minor_chance(), 5.0), "base minor wound chance 5%", str(gs.scav_minor_chance()))
	gs.afterhour_mods = {"injury_immunity": 1}
	var inv0: int = gs.inventory.size()
	var stats0 := int(gs.run_stats.get("scavenge_attempts", 0))
	var s: Dictionary = gs.scavenge_dumping_ground()
	check(bool(s.get("ok", false)) and gs.scav_attempts_left() == 4, "scavenge consumes attempt", str(s))
	check(gs.inventory.size() > inv0 and int(gs.run_stats.get("scavenge_attempts", 0)) == stats0 + 1, "scavenge yields loot", str(gs.inventory.size() - inv0))
	check(int(gs.run_stats.get("scavenged_value", 0)) > 0, "scavenge value tracked")
	for i in range(10):
		gs.scavenge_dumping_ground()
	check(gs.scav_attempts_left() == 0 and not bool(gs.scavenge_dumping_ground().get("ok", true)), "scavenge stops at zero")

	gs = fresh(["perk_proficient_scavenger"])
	check(gs.scav_attempts_max() == 7, "proficient scavenger +2", str(gs.scav_attempts_max()))
	gs = fresh(["perk_careful_scavenger"])
	check(gs.scav_attempts_max() == 3, "careful scavenger -2", str(gs.scav_attempts_max()))
	check(is_equal_approx(gs.scav_minor_chance(), 0.0) and is_equal_approx(gs.scav_major_chance(), 0.0), "careful scavenger never injured")
	gs = fresh(["perk_maimed"])
	check(gs.scav_attempts_max() == 0, "maimed cannot scavenge")
	gs.phase = "endday"
	gs.afterhours_visits_left = 1
	var locs: Array = []
	for l in gs.afterhours_locations():
		locs.append(String(l.get("id", "")))
	check(not locs.has("dumping_ground"), "maimed hides dumping ground")
	check(not bool(gs.afterhours_travel("dumping_ground").get("ok", true)), "maimed travel blocked")
	gs = fresh(["perk_degenerative_osteoarthritis"])
	gs.day = 8
	check(gs.scav_attempts_max() == 4, "osteoarthritis week 2 -1", str(gs.scav_attempts_max()))
	gs.day = 22
	check(gs.scav_attempts_max() == 0, "osteoarthritis late game 0", str(gs.scav_attempts_max()))
	check(gs.inventory_count("topical_bandage_item") == 2, "osteoarthritis starts with bandages")

	gs = fresh()
	gs.cash = 5000
	gs.phase = "endday"
	gs.afterhours_visits_left = 1
	check(bool(gs.afterhours_travel("dr_jackson").get("ok", false)), "travel jackson")
	check(gs.jackson_stock.size() == 4, "jackson stock 4", str(gs.jackson_stock.size()))
	var price := int(gs.jackson_stock[0].get("price", 0))
	var item_id := String(gs.jackson_stock[0].get("item", {}).get("def_id", ""))
	var cash0: int = gs.cash
	var b: Dictionary = gs.jackson_buy(0)
	check(bool(b.get("ok", false)) and gs.cash == cash0 - price and gs.jackson_stock.size() == 3, "jackson purchase", str(b))
	check(gs.inventory_count(item_id) == 1, "jackson item added")
	gs.afterhours_return()

	gs = fresh()
	gs.rep["lower"] = -80
	gs.phase = "endday"
	gs.afterhours_visits_left = 1
	var locs2: Array = []
	for l in gs.afterhours_locations():
		locs2.append(String(l.get("id", "")))
	check(not locs2.has("dr_jackson"), "LLAVOIDED hides jackson")
	check(not bool(gs.afterhours_travel("dr_jackson").get("ok", true)), "LLAVOIDED travel blocked")

	gs = fresh(["perk_banned_commissary"])
	gs.phase = "endday"
	gs.afterhours_visits_left = 1
	var locs3: Array = []
	for l in gs.afterhours_locations():
		locs3.append(String(l.get("id", "")))
	check(not locs3.has("commissary"), "banned commissary hidden")

	gs = fresh(["perk_agoraphobia"])
	gs.phase = "endday"
	gs.afterhours_visits_left = 1
	gs.afterhours_travel("dr_jackson")
	gs.afterhours_return()
	gs.afterhours_visits_left = 1
	gs.day += 1
	check(gs.afterhours_block_reason().contains("广场恐惧症"), "agoraphobia rest blocks next night", gs.afterhours_block_reason())
	gs.day += 2
	check(gs.afterhours_block_reason() == "", "agoraphobia rested", gs.afterhours_block_reason())

	gs = fresh()
	gs.wounds = 7
	gs.phase = "endday"
	gs.afterhours_visits_left = 1
	check(gs.afterhours_block_reason().contains("伤势严重"), "serious wounds block outings")

	gs = fresh()
	gs.went_out_last_night = true
	check(gs.customer_count_modifier() == -1, "night out costs one customer")
	gs = fresh(["perk_short_sleeper"])
	gs.went_out_last_night = true
	check(gs.customer_count_modifier() == 0, "short sleeper keeps customers")

	gs = fresh()
	gs.day = 1
	gs.start_day()
	check(gs.afterhours_visits_left == 1, "one outing per night", str(gs.afterhours_visits_left))
	gs = fresh(["perk_speedy"])
	gs.day = 1
	gs.start_day()
	check(gs.afterhours_visits_left == 2, "speedy two outings", str(gs.afterhours_visits_left))

	gs = fresh()
	gs.went_out_last_night = true
	gs.last_afterhour_outing_day = 3
	gs.afterhours_visits_left = 1
	gs.save_game(3)
	gs.new_game("normal")
	gs.load_game(3)
	check(gs.last_afterhour_outing_day == 3 and gs.afterhours_visits_left >= 1, "afterhours state saved")

	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
