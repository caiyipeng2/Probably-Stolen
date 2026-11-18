extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()

	gs.new_game("normal", "original", "water_merchant", ["perk_saving"])
	check(gs.cash == 550, "start type cash delta + perk saving", str(gs.cash))
	check(gs.profession_id == "water_merchant", "start type applied", gs.profession_id)
	check(bool(gs.owned_upgrades.get("WATER_TRADER", false)), "start type upgrade applied")
	check(gs.inventory_count("water_tablet") >= 3, "start type items applied")

	gs.new_game("normal", "original", "rock_bottom", [])
	check(gs.cash == 0, "rock bottom cash", str(gs.cash))
	check(gs.achievements_unlocked.has("ACH_RATS"), "rock bottom achievement")

	gs.new_game("normal", "original", "apprentice", ["perk_saving", "perk_well_connected", "perk_alert"])
	check(not gs.starting_perk_chosen, "over-budget perks rejected", str(gs.starting_perk_points(gs.starting_perk_ids)))

	gs.new_game("normal", "original", "apprentice", ["perk_convict", "perk_model_citizen"])
	check(not gs.starting_perk_chosen, "incompatible perks rejected")

	gs.new_game("normal", "original", "apprentice", ["perk_colorful_character", "perk_colorful_character", "perk_colorful_character"])
	check(gs.starting_perk_chosen and gs.starting_perk_ids.size() == 3, "colorful character slots", str(gs.starting_perk_ids.size()))

	gs.new_game("normal", "original", "apprentice", ["perk_alcohol_addiction"])
	check(bool(gs.perk_flags.get("addiction_alcohol", false)), "addiction perk flag")
	gs.addiction_days["alcohol"] = 3
	check(int(round(gs.addiction_price_mod() * 100.0)) == 8, "withdrawal price penalty", str(gs.addiction_price_mod()))

	gs.thirst = 100
	var bottle: Dictionary = gs.make_item("water_bottle_full", 100, true, false)
	gs.add_item(bottle)
	var drank: Dictionary = gs.use_consumable(int(bottle.get("uid", -1)))
	check(bool(drank.get("ok", false)) and gs.thirst > 100, "drink raises thirst", str(gs.thirst))
	check(gs.inventory_count("water_bottle_full") == 0, "water consumed")

	gs.new_game("normal", "original", "apprentice", ["perk_sentinel"])
	gs.sentinel_days = 13
	gs.sentinel_pool = 14
	gs.nightly_survival()
	check(gs.sentinel_pool >= 17, "sentinel pool accumulates", str(gs.sentinel_pool))

	gs.new_game("normal", "original", "apprentice", [])
	gs.current_customer = {"intent": "gun_order", "arche": {"faction": "lower", "name": "买家"}, "done": false}
	gs.gun_order = {"require": {"accuracy": 10}, "bonuses": [], "base": 100, "service": false}
	gs.current_customer["require"] = {"accuracy": 10}
	gs.current_customer["bonuses"] = []
	gs.current_customer["base"] = 100
	var gun: Dictionary = gs.make_item("handmade_pistol", 100, true, false)
	gs.add_item(gun)
	var before: int = gs.cash
	var delivered: Dictionary = gs.deliver_gun_order(int(gun.get("uid", -1)))
	check(bool(delivered.get("ok", false)) and gs.cash > before, "gun order delivered", str(delivered.get("text", "")))

	gs.new_game("normal", "original", "apprentice", [])
	gs.aug_introduced = true
	gs.power = 10
	var scanned: Dictionary = gs.scan_aug_customer()
	check(not bool(scanned.get("ok", false)), "aug scan needs customer")
	gs.current_customer = {"intent": "buy", "arche": {"faction": "lower", "name": "顾客"}, "is_aug": true, "aug_scanned": false, "done": false}
	gs.add_item(gs.make_item("aug_scanner", 100, true, false))
	gs.power = 10
	check(not bool(gs.scan_aug_customer().get("ok", false)), "aug scan needs power")
	gs.power = 30
	var scan2: Dictionary = gs.scan_aug_customer()
	check(bool(scan2.get("ok", false)) and bool(gs.current_customer.get("aug_scanned", false)), "aug scan succeeds", str(scan2.get("text", "")))
	var before_report: int = gs.cash
	var report: Dictionary = gs.report_aug()
	check(bool(report.get("ok", false)) and gs.cash > before_report, "aug report reward", str(report.get("text", "")))

	gs.new_game("normal", "original", "apprentice", [])
	gs.unlock_hireling()
	var dispatched: Dictionary = gs.dispatch_hireling()
	check(bool(dispatched.get("ok", false)), "hireling dispatched")
	gs._resolve_hireling_expedition()
	check(String(gs.hireling.get("status", "")) in ["complete", "injured"], "hireling resolved", String(gs.hireling.get("status", "")))
	check(not String(gs.hireling_expedition.get("log", "")).is_empty(), "hireling log present")

	gs.new_game("normal", "original", "apprentice", [])
	gs.cash = 20000
	gs._check_achievements()
	check(gs.achievements_unlocked.has("ACH_SETTLED"), "achievement settled")

	gs.new_game("normal", "original", "apprentice", ["perk_saving"])
	var saved: bool = gs.save_game(2)
	var cash_before: int = gs.cash
	gs.cash = 1
	var loaded: bool = gs.load_game(2)
	check(saved and loaded and gs.cash == cash_before, "p0 state save/load", str(gs.cash))
	check(gs.start_type_id == "apprentice" and not gs.starting_perk_ids.is_empty(), "start state persisted")

	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
