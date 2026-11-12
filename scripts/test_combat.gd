extends SceneTree
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	gs.start_combat("thug")
	var guard=0
	while gs.combat_active and guard < 20:
		gs.combat_action("attack")
		guard += 1
	print("thug active=", gs.combat_active, " cash=", gs.cash, " hp=", gs.combat_player_hp)
	var w = gs.wanted[0]
	gs.start_combat(String(w["enemy"]), "security", String(w["id"]))
	guard=0
	while gs.combat_active and guard < 30:
		gs.combat_action("skill" if gs.combat_skill_cd == 0 else "attack")
		guard += 1
	print("wanted defeated=", gs.wanted_defeated, " cash=", gs.cash)
	gs.set_ending("owner")
	print("ending=", gs.ending_id, " def=", gs.ending_def("owner").get("title",""))
	quit()
