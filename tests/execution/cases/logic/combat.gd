# [L2 执行层] combat.gd — 回合制战斗与结局
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	state.start_combat("thug")
	var guard := 0
	while state.combat_active and guard < 20:
		state.combat_action("attack")
		guard += 1
	check(not state.combat_active, "thug combat resolved")
	check(state.combat_player_hp > 0, "player survived", str(state.combat_player_hp))
	check(state.cash >= 600, "thug cash", str(state.cash))
	var w: Dictionary = state.wanted[0]
	state.start_combat(String(w["enemy"]), "security", String(w["id"]))
	guard = 0
	while state.combat_active and guard < 30:
		state.combat_action("skill" if state.combat_skill_cd == 0 else "attack")
		guard += 1
	check(state.wanted_defeated.has(String(w["id"])), "wanted defeated", str(state.wanted_defeated))
	state.set_ending("owner")
	check_eq(String(state.ending_def("owner").get("title", "")), "买下这家店", "owner ending")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
