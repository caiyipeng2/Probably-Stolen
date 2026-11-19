extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func fresh() -> Node:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("normal")
	gs.rng.seed = 20261119
	return gs

func _init() -> void:
	var gs = fresh()
	check(gs.gun_mod_defs.get("mods", {}).size() >= 20, "gun mod data loaded", str(gs.gun_mod_defs.get("mods", {}).size()))
	check(is_equal_approx(float(gs.gun_def_stats("handmade_pistol", 100).get("accuracy", 0)), float(gs.gun_def_stats("handmade_pistol", "new").get("accuracy", 0))), "numeric condition maps to tier")
	check(int(gs.gun_def_stats("handmade_pistol", 100).get("accuracy", 0)) > int(gs.gun_def_stats("handmade_pistol", "good").get("accuracy", 0)), "new condition beats good")

	var gun: Dictionary = gs.make_item("handmade_pistol", 100, true, false)
	gs.add_item(gun)
	var rds: Dictionary = gs.make_item("rds", 100, true, false)
	gs.add_item(rds)
	var ext: Dictionary = gs.make_item("mag_22_ext", 100, true, false)
	gs.add_item(ext)
	var base: Dictionary = gs.gun_item_stats(gun)
	check(int(base.get("mag_size", 0)) == 8, "base magazine 8", str(base.get("mag_size", 0)))
	var r1: Dictionary = gs.gun_install_mod(int(gun["uid"]), int(rds["uid"]))
	check(bool(r1.get("ok", false)), "install rail mod", str(r1))
	check(gs.inventory_count("rds") == 0, "mod leaves inventory")
	var modded: Dictionary = gs.gun_item_stats(gun)
	check(int(modded.get("accuracy", 0)) == int(base.get("accuracy", 0)) + 35, "rail accuracy bonus", str(modded.get("accuracy", 0)))
	var r2: Dictionary = gs.gun_install_mod(int(gun["uid"]), int(ext["uid"]))
	check(bool(r2.get("ok", false)), "install extended mag", str(r2))
	check(int(gs.gun_item_stats(gun).get("mag_size", 0)) == 16, "extended mag 16", str(gs.gun_item_stats(gun).get("mag_size", 0)))
	gs.gun_order = {"require": {"accuracy": int(base.get("accuracy", 0)) + 30}, "base": 100, "bonuses": []}
	var ev: Dictionary = gs.gun_order_eval(gun)
	check(bool(ev.get("met", false)), "mods count for gun order", str(ev))
	var r3: Dictionary = gs.gun_remove_mod(int(gun["uid"]), "rail")
	check(bool(r3.get("ok", false)) and gs.inventory_count("rds") == 1, "remove rail mod", str(r3))
	var sil: Dictionary = gs.make_item("silencer", 100, true, false)
	gs.add_item(sil)
	var r4: Dictionary = gs.gun_install_mod(int(gun["uid"]), int(sil["uid"]))
	check(bool(r4.get("ok", false)) and int(gs.gun_item_stats(gun).get("suppressed", 0)) == 1, "suppressor flag", str(r4))
	var gl: Dictionary = gs.make_item("gl", 100, true, false)
	gs.add_item(gl)
	check(not bool(gs.gun_install_mod(int(gun["uid"]), int(gl["uid"])).get("ok", true)), "incompatible mod rejected")

	gs = fresh()
	for i in range(gs.inventory.size() - 1, -1, -1):
		gs.inventory.remove_at(i)
	gs.display = []
	for i in range(2):
		gs.add_item(gs.make_item("small_pistol_ammo", 100, true, false))
	gs.combat_active = true
	gs.combat_ended = false
	gs.combat_player_uid = 0
	gs.combat_current_uid = 0
	gs.combat_player_weapon = "weapon_attack"
	gs.combat_is_gun = true
	gs.combat_gun_stats = {"mag_size": 8, "caliber": 22, "accuracy": 30, "firepower": 20}
	gs.combat_mag_size = 8
	gs.combat_mag_rounds = 8
	gs.combat_ammo_id = "small_pistol_ammo"
	check(gs.combat_spend_round() and gs.combat_mag_rounds == 7, "shot consumes ammo", str(gs.combat_mag_rounds))
	gs.combat_mag_rounds = 0
	check(not gs.combat_spend_round(), "empty magazine blocks shot")
	gs.combat_current_uid = gs.combat_player_uid
	var ammo0: int = gs.inventory_count("small_pistol_ammo")
	var rl: Dictionary = gs.combat_reload()
	check(bool(rl.get("ok", false)) and gs.combat_mag_rounds == 8 and gs.inventory_count("small_pistol_ammo") == ammo0 - 1, "reload refills magazine", str(rl))

	var u1 := {"armor": {"value": 10, "max": 10, "efficiency": 100, "mitigation": 100, "protection": 0, "resilience": 0, "item_uid": -1}}
	gs._combat_armor_absorb(u1, 1)
	check(int(u1["armor"]["value"]) == 10, "mitigation prevents durability loss", str(u1["armor"]["value"]))
	var u2 := {"armor": {"value": 10, "max": 10, "efficiency": 100, "mitigation": 0, "protection": 0, "resilience": 0, "item_uid": -1}}
	gs._combat_armor_absorb(u2, 1)
	check(int(u2["armor"]["value"]) == 9, "armor loses durability without mitigation", str(u2["armor"]["value"]))

	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
