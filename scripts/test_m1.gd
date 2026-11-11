extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	print("start day=", gs.day, " cash=", gs.cash, " inv=", gs.inventory.size(), " customers=", gs.customers_today.size())
	var c = gs.current_customer
	print("customer intent=", c.get("intent", "?"), " name=", c.get("arche", {}).get("name", "?"))
	if c.get("intent") == "sell":
		var item = c["item"]
		var res = gs.make_offer(int(item.get("asking_price", 0)))
		print("buy result ", res)
	else:
		var uid = int(gs.inventory[0]["uid"])
		gs.add_to_display(uid)
		gs.put_display_on_counter(uid)
		var res2 = gs.make_sell_offer(int(gs.current_customer.get("offer", 0)))
		print("sell result ", res2)
	print("after trade cash=", gs.cash, " inv=", gs.inventory.size(), " display=", gs.display.size())
	for i in range(7):
		if gs.phase == "gameover":
			break
		var s = gs.finish_day()
		print("day end ", s)
		if s.get("gameover", "") == "":
			gs.advance_day()
	print("final day=", gs.day, " cash=", gs.cash, " rent=", gs.rent, " rent_due=", gs.rent_due, " save=", gs.has_save())
	gs.save_game()
	gs.load_game()
	print("loaded day=", gs.day, " cash=", gs.cash, " inv=", gs.inventory.size())
	quit()
