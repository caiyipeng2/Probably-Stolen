extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()

	check(gs.client_sprite_pools.size() >= 25, "client sprite pools loaded", str(gs.client_sprite_pools.size()))
	var s1: String = gs._random_client_sprite("lower")
	var s2: String = gs._random_client_sprite("security")
	check(s1.ends_with(".png") and s2.ends_with(".png") and s1 != s2, "faction sprite selection", s1 + " / " + s2)

	check(gs.faction_ops.size() == 17, "faction operation data", str(gs.faction_ops.size()))
	check(gs.afterhour_defs.size() == 7, "afterhour event data", str(gs.afterhour_defs.size()))

	gs.new_game("normal", "original", "apprentice", [])
	gs.day = 5
	gs._apply_afterhour_event()
	check(gs.afterhour_today == "fri_restock", "friday restock applied", gs.afterhour_today)
	check(int(gs.afterhour_mods.get("commissary_restock_percent", 0)) == 35, "restock percent")

	gs.day = 8
	gs.faction_ops = [{"id": "test_op", "faction": "security", "name": "测试行动", "duration": 2, "cooldown": 0, "bm": -10, "rev": 5, "sec": 20, "unrest": -15, "text": "测试。"}]
	gs.operation_cooldowns = {}
	gs.rng.seed = 12345
	var applied := false
	for i in range(80):
		gs._roll_faction_operation()
		if not gs.active_operations.is_empty():
			applied = true
			break
	check(applied, "faction operation can trigger")
	check(int(gs.faction_power.get("sec", 0)) == 20 and int(gs.faction_power.get("bm", 0)) == -10, "faction power changed", str(gs.faction_power))

	gs.new_game("normal", "original", "apprentice", [])
	gs.day = 4
	gs._apply_afterhour_event()
	gs.unlock_hireling()
	gs.dispatch_hireling()
	gs._resolve_hireling_expedition()
	check(bool(gs.afterhour_mods.get("injury_immunity", false)), "thursday immunity present")
	check(not String(gs.hireling_expedition.get("log", "")).is_empty(), "expedition with afterhour mods", String(gs.hireling_expedition.get("log", "")))

	gs.new_game("normal", "original", "apprentice", [])
	var jug: Dictionary = gs.make_item("water_jug", 100, true, false)
	gs.add_item(jug)
	var jug_uid := int(jug.get("uid", -1))
	jug["liquid_ml"] = 0
	jug["liquid_contents"] = {}
	var filled: Dictionary = gs.fill_liquid_from_faucet(jug_uid)
	check(bool(filled.get("ok", false)) and int(gs.find_item(jug_uid).get("liquid_ml", 0)) > 0, "faucet fill", str(filled.get("text", "")))
	gs.store_water_ml = 0
	var drained: Dictionary = gs.drain_liquid_container(jug_uid)
	check(bool(drained.get("ok", false)) and int(gs.find_item(jug_uid).get("liquid_ml", 0)) == 0, "drain empty container", str(drained.get("text", "")))
	var injector: Dictionary = gs.make_item("turquoise_injector", 100, true, false)
	gs.add_item(injector)
	gs.use_consumable(int(injector.get("uid", -1)))
	check(gs.next_combat_accuracy_bonus == 5, "injector combat buff", str(gs.next_combat_accuracy_bonus))

	gs.current_customer = {"intent": "sell", "arche": {"faction": "lower", "name": "卖家"}, "item": {"def_id": "handmade_pistol", "asking_price": 100, "min_price": 70, "stolen": true, "uid": 999}, "patience": 3, "done": false}
	var pv: Dictionary = gs.bargain_preview(20)
	check(int(pv.get("success", 0)) > 0 and int(pv.get("leave", 0)) > 0, "bargain preview", str(pv))
	gs.rng.seed = 7
	var black: Dictionary = gs.blackmail_bargain()
	check(bool(black.get("ok", false)), "blackmail action", str(black.get("text", "")))

	gs.new_game("normal", "original", "apprentice", [])
	gs.current_customer = {"intent": "expedition", "arche": {"faction": "lower", "name": "组织者"}, "party": "pirateRookieTriple", "done": false}
	var exp_res: Dictionary = gs.start_expedition()
	check(bool(exp_res.get("ok", false)) and gs.expedition_rooms.size() == 2, "raid rooms built", str(gs.expedition_rooms.size()))
	var adv: bool = gs.advance_expedition()
	check(adv and not gs.expedition_loot_log.is_empty(), "raid room loot", str(gs.expedition_loot_log))
	check(gs.raid_action_points == 100, "raid action points reset", str(gs.raid_action_points))

	gs.new_game("normal", "original", "apprentice", [])
	gs.faction_power = {"rev": 5, "bm": -10, "sec": 20, "civil_unrest": -15}
	var saved: bool = gs.save_game(2)
	gs.faction_power = {}
	gs.load_game(2)
	check(saved and int(gs.faction_power.get("sec", 0)) == 20, "faction power persisted")

	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
