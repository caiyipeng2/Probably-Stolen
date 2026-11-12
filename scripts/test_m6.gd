extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	print("scenes=", gs.story_scenes.size(), " pending=", gs.pending_story)
	var c = gs.current_customer
	print("day1 customer scene=", c.get("story_scene", ""), " intent=", c.get("intent", ""), " name=", gs.item_display_name(c.get("item", {})))
	# finish the georgio1 dialogue chain
	var nid = gs.pending_story
	var guard = 0
	while nid != "" and guard < 20:
		var node = gs.story_node(nid)
		gs.mark_story_seen(nid)
		nid = String(node.get("next", ""))
		guard += 1
	print("georgio1 seen=", gs.scene_seen.has("georgio1"), " flag=", gs.story_flags.has("georgio_intro_done"), " scraps=", gs.inventory_count("scrap_metal"))
	gs.finish_day()
	gs.advance_day()
	print("day2 pending=", gs.pending_story, " queued=", gs.story_queue)
	var queued = gs.take_queued_story()
	print("day2 queued next=", queued, " mentor=", gs.story_node(queued).get("speaker", ""))
	for i in range(3):
		gs.finish_day()
		gs.advance_day()
	print("day5 pending=", gs.pending_story, " intent=", gs.current_customer.get("intent", ""), " budget=", gs.current_customer.get("budget", 0))
	gs.scene_seen.append("serpico7")
	gs.save_game()
	gs.load_game()
	print("loaded scene_seen=", gs.scene_seen.has("georgio1"), " day=", gs.day, " cash=", gs.cash)
	for i in range(6):
		gs.finish_day()
		gs.advance_day()
	var scene_customers = []
	for cust in gs.customers_today:
		if cust.get("story_scene", "") != "":
			scene_customers.append(cust["story_scene"])
	print("day11 pending=", gs.pending_story, " queue=", gs.story_queue.size(), " scene_customers=", scene_customers, " total customers=", gs.customers_today.size())
	var guard2 = 0
	while gs.pending_story != "" and guard2 < 80:
		var node2 = gs.story_node(gs.pending_story)
		gs.mark_story_seen(gs.pending_story)
		var nxt2 = String(node2.get("next", ""))
		if nxt2 != "":
			gs.pending_story = nxt2
		else:
			gs.pending_story = gs.take_queued_story()
		guard2 += 1
	print("postgame seen=", gs.scene_seen.size(), " flags=", gs.story_flags.size())
	quit()
