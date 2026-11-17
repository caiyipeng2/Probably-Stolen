# [L2 执行层] m1.gd — 基础交易、日结与存读档
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	check_eq(state.day, 1, "start day")
	check_eq(state.cash, 600, "start cash")
	check_eq(state.inventory.size(), 46, "start inventory")
	check(state.customers_today.size() >= 3 and state.customers_today.size() <= 6, "customer count", str(state.customers_today.size()))
	var c = state.current_customer
	var res: Dictionary
	if c.get("intent") == "sell":
		res = state.make_offer(int(c["item"].get("asking_price", 0)))
	else:
		var uid := int(state.inventory[0]["uid"])
		state.add_to_display(uid)
		state.put_display_on_counter(uid)
		res = state.make_sell_offer(int(c.get("offer", 0)))
	check(res.has("text"), "trade result")
	check(bool(res.get("accepted", false)), "trade accepted", String(res.get("text", "")))
	var trade_cash := int(state.cash)
	var trade_inv := int(state.inventory.size())
	check(trade_cash != 600, "cash changed by trade", str(trade_cash))
	for i in range(7):
		if state.phase == "gameover":
			break
		var s = state.finish_day()
		if String(s.get("gameover", "")) == "":
			state.advance_day()
	var saved_day := int(state.day)
	var saved_cash := int(state.cash)
	var saved_inv := int(state.inventory.size())
	check(saved_day > 1, "days advanced", str(saved_day))
	check(state.save_game(9), "save slot9")
	state.new_game()
	check(state.load_game(9), "load slot9")
	check_eq(state.day, saved_day, "loaded day")
	check_eq(state.inventory.size(), saved_inv, "loaded inventory")
	check_eq(state.cash, saved_cash, "loaded cash")
	check(trade_inv > 0, "inventory intact", str(trade_inv))

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
