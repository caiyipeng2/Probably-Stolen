# [L2 执行层] endings.gd — 21 条结局与失败路径
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	check_eq(state.endings.size(), 21, "endings")
	check_eq(state.events.size(), 13, "events")
	check_eq(String(state.ending_def("sec").get("title", "")), "治安部清剿", "sec title")
	check_eq(state.resolve_ending("buyout_dynamic"), "buyout", "dynamic buyout")
	check_eq(state.resolve_ending("cartel_dynamic"), "cartel", "dynamic cartel")
	state.story_flags["buyout_mortgage_plan"] = true
	state.rep["cartel"] = 20
	check_eq(state.resolve_ending("buyout_dynamic"), "buyout_mortgage", "dynamic mortgage")
	check_eq(state.resolve_ending("cartel_dynamic"), "cartel_retired", "dynamic retired")
	state.cash = 0
	state.rent_due = 1
	var s1 = state.finish_day()
	check_eq(String(s1.get("gameover", "")), "rent", "rent gameover")
	check_eq(state.ending_id, "rent", "rent ending")
	state.new_game()
	state.cash = 0
	state.loan_due = 1
	var s2 = state.finish_day()
	check_eq(String(s2.get("gameover", "")), "repo", "loan gameover")
	check_eq(state.ending_id, "repo", "loan ending")
	state.new_game()
	state.rep["security"] = -40
	var s3 = state.finish_day()
	check_eq(String(s3.get("gameover", "")), "sec", "security gameover")
	check_eq(state.ending_id, "sec", "security ending")
	state.new_game()
	state.rep["blackmarket"] = -40
	var s4 = state.finish_day()
	check_eq(String(s4.get("gameover", "")), "hitman", "blackmarket gameover")
	check_eq(state.ending_id, "hitman", "blackmarket ending")
	state.new_game()
	state.rep["security"] = -25
	state.add_item(state.make_item("handmade_pistol", 100, true, true))
	state.pending_event = {"id": "security_search", "choices": [{"cash": 0, "rep": {}, "confiscate": true, "result": "test"}]}
	state.apply_event(0)
	check_eq(state.phase, "gameover", "confiscate phase")
	check_eq(state.ending_id, "arrest", "confiscate ending")
	state.new_game()
	state.start_combat("raider", "security", "", "security_raid")
	state.combat_player_hp = 1
	state.combat_action("guard")
	check_eq(state.phase, "gameover", "raid phase")
	check_eq(state.ending_id, "sec", "raid ending")
	state.new_game()
	state.start_combat("boss_lou", "lower", "w_lou", "")
	state.combat_player_hp = 1
	state.combat_action("guard")
	check_eq(state.phase, "gameover", "boss phase")
	check_eq(state.ending_id, "lou_bombed", "boss ending")
	state.new_game()
	state.pending_event = {"id": "reactor_scare", "choices": [{"cash": 0, "rep": {}, "ending": "reactor", "ending_chance": 1.0, "result": "test"}]}
	state.apply_event(0)
	check_eq(state.phase, "gameover", "event phase")
	check_eq(state.ending_id, "reactor", "event ending")
	state.new_game()
	state.cash = 0
	state.loan = 200
	state.start_combat("boss_lou", "lower", "w_lou", "")
	state.combat_player_hp = 1
	state.combat_action("guard")
	check_eq(state.phase, "gameover", "boss debt phase")
	check_eq(state.ending_id, "lou_bombed_debt", "boss debt ending")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
