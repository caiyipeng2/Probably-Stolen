extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	gs.rng.seed = 20261117
	check(gs.phone_contacts.size() >= 6, "phone contacts loaded", str(gs.phone_contacts.size()))
	# red imp courier stock 0
	var c = gs._gen_courier_customer({"supplier": "red_imp", "stock_type": 0, "free": false})
	check(c.get("intent", "") == "wholesale", "courier intent")
	var stock: Array = c.get("wholesale_stock", [])
	check(stock.size() == 1 and String(stock[0].get("def_id", "")) == "beerCase", "beer case courier stock", str(stock.size()))
	check(stock[0].get("children", []).size() == 8, "beer case filled with 8 bottles", str(stock[0].get("children", []).size()))
	var base := 0
	for it in stock:
		base += gs.effective_value(it)
	var total = gs.wholesale_total(c)
	check(total == int(round(float(base) * 0.8)), "wholesale discount 20%", "%d / %d" % [total, base])
	# purchase
	gs.inventory.clear()
	gs.cash = 10000
	gs.current_customer = c
	var before_cash = gs.cash
	var res = gs.buy_wholesale()
	check(res.get("ok", false) and gs.cash == before_cash - total, "wholesale purchase deducted cash", res.get("text", ""))
	check(gs.inventory_count("beerCase") == 1, "beer case added", str(gs.inventory_count("beerCase")))
	check(int(gs.phone_client("red_imp").get("amount_spent", 0)) == total, "amount spent tracked", str(gs.phone_client("red_imp").get("amount_spent", 0)))
	# shareholder discount
	gs.owned_upgrades["BREWER_SHAREHOLDER"] = true
	var c2 = gs._gen_courier_customer({"supplier": "red_imp", "stock_type": 0, "free": false})
	check(int(c2.get("wholesale_discount", 0)) == -35, "shareholder wholesale -35", str(c2.get("wholesale_discount", 0)))
	# stock type 1 = two cases
	var c3 = gs._gen_courier_customer({"supplier": "red_imp", "stock_type": 1, "free": false})
	check(c3.get("wholesale_stock", []).size() == 2, "second order two cases")
	# free courier
	var f = gs._gen_courier_customer({"supplier": "mining", "stock_type": 0, "free": true})
	check(gs.wholesale_total(f) == 0, "free courier total zero")
	gs.current_customer = f
	var fres = gs.buy_wholesale()
	check(fres.get("ok", false) and gs.inventory_count("common_ore") == 8, "free courier grants ore", fres.get("text", ""))
	# mining paid stock
	var m = gs._gen_courier_customer({"supplier": "mining", "stock_type": 0, "free": false})
	check(m.get("wholesale_stock", []).size() == 6, "mining six ore", str(m.get("wholesale_stock", []).size()))
	# future queue due processing
	gs.future_customers.clear()
	gs.queue_future_customer("courrierPharma", "pharma", 0, 1, false)
	var due_day = int(gs.future_customers[0].get("day", 0))
	check(due_day == gs.day + 1, "future customer due tomorrow", str(due_day))
	# cooldown tick
	gs.phone_clients["chem"] = {"state": "Cooldown", "cooldown": 2, "amount_spent": 0, "dialed": true, "stock_type": 0}
	gs.day = due_day
	gs.start_day()
	check(int(gs.phone_client("chem").get("cooldown", 0)) == 1, "cooldown decremented", str(gs.phone_client("chem").get("cooldown", 0)))
	var has_courier := false
	for cc in gs.customers_today:
		if cc.get("intent", "") == "wholesale" and String(cc.get("wholesale_supplier", "")) == "pharma":
			has_courier = true
	check(has_courier, "due courier appears in customers")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
