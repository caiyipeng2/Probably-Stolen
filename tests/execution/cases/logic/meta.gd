# [L2 执行层] meta.gd — 难度、原版模式与存读档
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value

func run() -> void:
	state.new_game("easy")
	check_eq(state.cash, 800, "easy cash")
	check_eq(state.rent, 150, "easy rent")
	check_eq(state.difficulty, "easy", "easy difficulty")
	state.new_game("hard")
	check_eq(state.cash, 450, "hard cash")
	check_eq(state.rent, 260, "hard rent")
	check_eq(state.difficulty, "hard", "hard difficulty")
	state.new_game("normal", "original")
	state.day = 6
	state.start_day()
	check_eq(state.pending_story, "sc_georgio1_0", "original day6 story")
	check_eq(state.campaign_mode, "original", "original mode")
	state.cash = 1234
	state.day = 5
	check(state.save_game(9), "save slot9")
	check(state.has_save(9), "has slot9")
	state.new_game("normal")
	check(state.load_game(9), "load slot9")
	check_eq(state.cash, 1234, "loaded cash")
	check_eq(state.day, 5, "loaded day")
	check_eq(state.difficulty, "normal", "loaded difficulty")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
