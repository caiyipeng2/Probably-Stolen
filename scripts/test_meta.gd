extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("easy")
	print("easy cash=", gs.cash, " rent=", gs.rent, " diff=", gs.difficulty)
	gs.new_game("hard")
	print("hard cash=", gs.cash, " rent=", gs.rent, " diff=", gs.difficulty)
	gs.cash = 1234
	gs.day = 5
	print("save slot3=", gs.save_game(3), " has3=", gs.has_save(3))
	gs.new_game("normal")
	print("load slot3=", gs.load_game(3), " cash=", gs.cash, " day=", gs.day, " diff=", gs.difficulty)
	quit()
