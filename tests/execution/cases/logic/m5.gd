# [L2 执行层] m5.gd — 查抄、剧情效果与存读档
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	var before = state.inventory_count("handmade_pistol")
	state.pending_event = {"choices": [{"cash": 0, "rep": {"security": 2}, "confiscate": true, "result": "test"}]}
	state.apply_event(0)
	check_eq(before, 1, "contraband before")
	check_eq(state.inventory_count("handmade_pistol"), 0, "contraband confiscated")
	state.apply_story_effects({"cash": 50, "rep": {"lower": 5}, "flag": "test_flag"})
	check_eq(state.cash, 650, "story cash")
	check(state.story_flags.has("test_flag"), "story flag")
	check_eq(int(state.rep["lower"]), 5, "story rep")
	state.mark_story_seen("mentor_day2")
	check(state.save_game(9), "save slot9")
	state.new_game()
	check(state.load_game(9), "load slot9")
	check(state.story_seen.has("mentor_day2"), "loaded story seen")
	check(state.story_flags.has("test_flag"), "loaded story flag")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
