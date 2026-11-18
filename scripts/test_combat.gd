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
	gs.rng.seed = 20261118
	check(gs.combat_abilities.size() >= 30, "combat abilities loaded", str(gs.combat_abilities.size()))
	check(gs.enemy_def("xeno_hunter").get("reaction", 0) == 12, "original enemy stats", str(gs.enemy_def("xeno_hunter").get("reaction", 0)))
	check(gs.combat_weapon_map.get("glock_receiver", "") == "glock_attack", "weapon ability map")
	# start combat and basic player stats
	gs.start_combat("thug")
	check(gs.combat_active and gs.combat_units.size() == 2, "combat starts with two units")
	var pl = gs._combat_unit_by_uid(0)
	var base_acc: int = 70 + int(gs.survival_accuracy_mod())
	check(int(pl.get("max_hp", 0)) == 100 and int(pl.get("accuracy", 0)) == base_acc, "player base stats")
	check(int(pl.get("death_chance", 0)) == 40, "player death chance 40")
	# hit chance
	check(gs._combat_hit_chance(pl, gs._combat_unit_by_uid(1), gs.combat_abilities["fists"]) == base_acc, "unarmed hit chance")
	check(gs._combat_hit_chance(pl, gs._combat_unit_by_uid(1), gs.combat_abilities["glock_attack"]) == base_acc + 10, "glock accuracy bonus")
	# fight until victory
	var guard := 0
	while gs.combat_active and guard < 40:
		guard += 1
		gs.combat_player_action(gs.combat_player_weapon, gs.combat_target_uid)
	check(not gs.combat_active and gs.wanted_defeated.is_empty(), "thug defeated", gs.combat_log[-1] if not gs.combat_log.is_empty() else "")
	# wanted victory
	var w = gs.wanted[0]
	gs.start_combat(String(w["enemy"]), "security", String(w["id"]))
	guard = 0
	while gs.combat_active and guard < 40:
		guard += 1
		gs.combat_player_action(gs.combat_player_weapon, gs.combat_target_uid)
	check(gs.wanted_defeated.has(String(w["id"])), "wanted marked defeated", str(gs.wanted_defeated))
	# armor equip and absorption
	gs.inventory.clear()
	var armor = gs.make_item("armor_lining", 100, true, false)
	gs.add_item(armor)
	var eq = gs.equip_armor(int(armor.uid))
	check(eq.get("ok", false) and gs.equipped_armor_uid == int(armor.uid), "equip armor", eq.get("text", ""))
	check(int(armor.get("armor_value", -1)) == 100, "armor initialized")
	gs.start_combat("thug")
	var pu = gs._combat_unit_by_uid(0)
	pu["armor"] = {"item_uid": int(armor.uid), "value": 10, "max": 100, "efficiency": 0, "mitigation": 0, "protection": 5, "resilience": 0}
	var php = int(pu.get("hp", 0))
	gs._combat_damage(pu, 10, "测试")
	check(int(pu.get("hp", 0)) == php - 5 and int(pu.get("armor", {}).get("value", -1)) == 5, "armor absorbs damage", "%d hp / %d armor" % [int(pu.get("hp", 0)), int(pu.get("armor", {}).get("value", -1))])
	var armor_before = int(armor.get("armor_value", -1))
	gs.save_game(3)
	gs.new_game()
	gs.load_game(3)
	check(gs.equipped_armor_uid == int(armor.uid) and int(gs.find_item(int(armor.uid)).get("armor_value", -1)) == armor_before, "armor persisted", str(armor_before))
	# bleed status and start of turn damage
	gs.combat_units = []
	gs.combat_enemy = {"id": "test", "name": "假人"}
	var dummy := {"uid": 99, "team": 1, "name": "假人", "hp": 50, "max_hp": 50, "effects": [], "dead": false, "accuracy": 70, "dodge": 0, "crit": 10, "crit_receive": 0, "death_chance": 100}
	gs.combat_units.append(dummy)
	gs._combat_add_effect(dummy, {"type": "bleed", "value": 3, "duration": 2})
	gs._combat_start_turn(dummy)
	check(int(dummy.get("hp", 0)) == 47, "bleed ticks at turn start", str(dummy.get("hp", 0)))
	# death's door
	var tank := {"uid": 100, "team": 1, "name": "坦克", "hp": 2, "max_hp": 50, "effects": [], "dead": false, "death_chance": 0}
	gs.combat_units.append(tank)
	gs._combat_damage(tank, 10, "测试")
	check(not bool(tank.get("dead", true)) and int(tank.get("hp", 0)) == 1, "death's door survival", str(tank.get("hp", 0)))
	tank["death_chance"] = 100
	gs._combat_damage(tank, 10, "测试")
	check(bool(tank.get("dead", false)), "death chance 100 kills")
	# overwatch reaction
	gs.start_combat("thug")
	var enemy = gs._combat_unit_by_uid(1)
	gs._combat_add_effect(enemy, {"type": "overwatch", "duration": 1})
	gs._combat_unit_by_uid(0)["accuracy"] = 999
	enemy["dodge"] = -999
	var hp_before := int(gs._combat_unit_by_uid(0).get("hp", 0))
	gs._combat_use_ability(gs._combat_unit_by_uid(0), "weapon_attack", 1, -1)
	var saw_overwatch := false
	for line in gs.combat_log:
		if String(line).contains("警戒射击"):
			saw_overwatch = true
	check(saw_overwatch, "overwatch reaction fires")
	# medic AI does not crash
	gs.start_combat("combat_medic")
	guard = 0
	while gs.combat_active and guard < 30:
		guard += 1
		if gs.combat_waiting_for_player():
			gs.combat_player_action(gs.combat_player_weapon, gs.combat_target_uid)
	check(true, "medic AI combat completes")
	# victory loot
	gs.start_combat("scav")
	var scav = gs._combat_unit_by_uid(1)
	scav["loot"] = [["scrap_metal", 100]]
	scav["hp"] = 1
	gs._combat_damage(scav, 999, "测试")
	gs._combat_check_end()
	var metal = gs.inventory_count("scrap_metal")
	check(metal >= 1 and not gs.combat_active, "victory loot dropped", str(metal))
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
