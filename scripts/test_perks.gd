extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("normal")
	gs.rng.seed = 20261119
	gs.sec_inspection_pending = false
	check(gs.starting_perks.size() >= 50, "starting perks loaded", str(gs.starting_perks.size()))
	check(gs.rep_perk_defs.size() >= 45, "reputation perks loaded", str(gs.rep_perk_defs.size()))
	var cash0: int = gs.cash
	var chosen: Dictionary = gs.choose_starting_perk("perk_saving")
	check(bool(chosen.get("ok", false)) and gs.cash == cash0 + 150 and gs.starting_perk_chosen, "saving perk applies", str(chosen))
	check(not bool(gs.choose_starting_perk("perk_lucky").get("ok", true)), "starting perk once")
	gs.rep["security"] = 60
	check(gs.rep_perk_unlocked("SEC_TRUSTED") and not gs.rep_perk_unlocked("SEC_PRIORITY"), "generic rep perk unlock")
	check(gs.rep_perk_unlocked("UL_PETITION") == false, "upper petition locked by default")
	gs.rep["upper"] = -60
	check(gs.rep_perk_unlocked("UL_PETITION"), "upper petition unlock")
	check(gs.difficulty_rules.size() == 4, "difficulty presets", str(gs.difficulty_rules.size()))
	check(int(gs.diff_rule("retail_markup", -1)) == 15, "normal retail markup")
	gs.difficulty = "hard"
	check(int(gs.diff_rule("retail_markup", -1)) == 0 and is_equal_approx(float(gs.diff_rule("rent_increase", 0.0)), 1.1), "hard rules")
	check(gs.upgrade_cost("EVIDENCE_REMOVAL") == 750, "hard upgrade multiplier", str(gs.upgrade_cost("EVIDENCE_REMOVAL")))
	gs.starting_perk_id = "perk_saving"
	gs.starting_perk_chosen = true
	gs.save_game(2)
	gs.new_game()
	gs.load_game(2)
	check(gs.starting_perk_id == "perk_saving" and gs.starting_perk_chosen, "starting perk saved")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
