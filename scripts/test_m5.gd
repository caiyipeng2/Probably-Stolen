extends SceneTree
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	var before = gs.inventory_count("handmade_pistol")
	gs.pending_event = {"choices":[{"cash":0,"rep":{"security":2},"confiscate":true,"result":"test"}]}
	gs.apply_event(0)
	print("contraband before=", before, " after=", gs.inventory_count("handmade_pistol"))
	gs.apply_story_effects({"cash":50,"rep":{"lower":5},"flag":"test_flag"})
	print("story cash=", gs.cash, " flag=", gs.story_flags.has("test_flag"), " rep=", gs.rep["lower"])
	gs.mark_story_seen("mentor_day2")
	gs.save_game()
	gs.load_game()
	print("loaded seen=", gs.story_seen.has("mentor_day2"), " flag=", gs.story_flags.has("test_flag"))
	quit()
