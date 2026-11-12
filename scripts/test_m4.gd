extends SceneTree
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	print("factions=", gs.factions.size(), " upgrades=", gs.upgrades.size(), " professions=", gs.professions.size(), " commissions=", gs.commissions.size())
	var pid = String(gs.professions[0]["id"])
	print("profession ", gs.apply_profession(pid), " cash=", gs.cash, " chosen=", gs.profession_chosen)
	var uid = String(gs.upgrades[0]["id"])
	print("upgrade ", gs.buy_upgrade(uid), " cash=", gs.cash)
	if not gs.commissions.is_empty():
		var c = gs.commissions[0]
		for i in range(int(c["count"])):
			gs.add_item(gs.make_item(String(c["item_id"]), 100, true, false))
		print("deliver ", gs.deliver_commission(String(c["id"])), " cash=", gs.cash, " remaining=", gs.commissions.size())
	gs.save_game()
	gs.load_game()
	print("loaded profession=", gs.profession_id, " chosen=", gs.profession_chosen, " upgrades=", gs.owned_upgrades.size())
	quit()
