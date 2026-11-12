extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	print("endings=", gs.endings.size(), " defs=", gs.ending_def("sec").get("title", ""))
	# rent
	gs.cash = 0
	gs.rent_due = 1
	var s1 = gs.finish_day()
	print("rent=", s1.get("gameover", ""), " ending=", gs.ending_id)
	# loan
	gs.new_game()
	gs.cash = 0
	gs.loan_due = 1
	var s2 = gs.finish_day()
	print("loan=", s2.get("gameover", ""), " ending=", gs.ending_id)
	# rep endings
	gs.new_game()
	gs.rep["security"] = -40
	var s3 = gs.finish_day()
	print("security=", s3.get("gameover", ""), " ending=", gs.ending_id)
	gs.new_game()
	gs.rep["blackmarket"] = -40
	var s4 = gs.finish_day()
	print("blackmarket=", s4.get("gameover", ""), " ending=", gs.ending_id)
	# confiscation arrest
	gs.new_game()
	gs.rep["security"] = -25
	gs.add_item(gs.make_item("handmade_pistol", 100, true, true))
	gs.pending_event = {"id": "security_search", "choices": [{"cash": 0, "rep": {}, "confiscate": true, "result": "test"}]}
	gs.apply_event(0)
	print("confiscate phase=", gs.phase, " ending=", gs.ending_id)
	# event combat loss
	gs.new_game()
	gs.start_combat("raider", "security", "", "security_raid")
	gs.combat_player_hp = 1
	gs.combat_action("guard")
	print("raid phase=", gs.phase, " ending=", gs.ending_id)
	# boss loss
	gs.new_game()
	gs.start_combat("boss_lou", "lower", "w_lou", "")
	gs.combat_player_hp = 1
	gs.combat_action("guard")
	print("boss phase=", gs.phase, " ending=", gs.ending_id)
	quit()
