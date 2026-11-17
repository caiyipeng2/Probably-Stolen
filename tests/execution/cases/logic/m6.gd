# [L2 执行层] m6.gd — 原版剧情排期与长链
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	check_eq(state.story_scenes.size(), 55, "scenes")
	check_eq(state.pending_story, "sc_georgio1_0", "day1 pending")
	var c = state.current_customer
	check_eq(String(c.get("story_scene", "")), "georgio1", "day1 customer scene")
	var nid := String(state.pending_story)
	var guard := 0
	while nid != "" and guard < 20:
		var node = state.story_node(nid)
		state.mark_story_seen(nid)
		nid = String(node.get("next", ""))
		guard += 1
	check(state.scene_seen.has("georgio1"), "georgio1 seen")
	check(state.story_flags.has("georgio_intro_done"), "georgio intro flag")
	check(state.inventory_count("scrap_metal") > 0, "georgio scraps")
	state.finish_day()
	state.advance_day()
	check_eq(state.pending_story, "sc_georgio1_1_0", "day2 pending")
	check(state.story_queue.has("mentor_day2"), "day2 queue mentor")
	var queued := String(state.take_queued_story())
	check_eq(queued, "mentor_day2", "queued story")
	check_eq(String(state.story_node(queued).get("speaker", "")), "导师", "mentor speaker")
	for i in range(3):
		state.finish_day()
		state.advance_day()
	check_eq(state.pending_story, "sc_serpico1_0", "day5 pending")
	state.scene_seen.append("serpico7")
	check(state.save_game(9), "save slot9")
	state.new_game()
	check(state.load_game(9), "load slot9")
	check(state.scene_seen.has("georgio1"), "loaded scene seen")
	check_eq(state.day, 5, "loaded day")
	for i in range(6):
		state.finish_day()
		state.advance_day()
	check_eq(state.pending_story, "sc_georgio_assistance_3", "day11 pending")
	var scene_customers := []
	for cust in state.customers_today:
		if String(cust.get("story_scene", "")) != "":
			scene_customers.append(String(cust["story_scene"]))
	check(scene_customers.has("georgio3"), "day11 georgio3", str(scene_customers))
	check(state.customers_today.size() >= 3 and state.customers_today.size() <= 6, "day11 customer count", str(state.customers_today.size()))
	var guard2 := 0
	while state.pending_story != "" and guard2 < 80:
		var node2 = state.story_node(state.pending_story)
		state.mark_story_seen(state.pending_story)
		var nxt := String(node2.get("next", ""))
		if nxt != "":
			state.pending_story = nxt
		else:
			state.pending_story = state.take_queued_story()
		guard2 += 1
	check(state.scene_seen.size() > 0, "postgame scenes", str(state.scene_seen.size()))
	check(state.story_flags.size() > 0, "postgame flags", str(state.story_flags.size()))

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
