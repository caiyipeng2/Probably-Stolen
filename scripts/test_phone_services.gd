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
	# commissary initial stock and redeem
	check(gs.commissary_defs.size() == 7, "commissary items")
	check(int(gs.commissary_stock.get("nutrifruit", 0)) == 8, "commissary initial stock", str(gs.commissary_stock.get("nutrifruit", 0)))
	gs.add_item(gs.make_item("food_stamp", 100, true, false))
	gs.add_item(gs.make_item("food_stamp", 100, true, false))
	var rd = gs.commissary_redeem_stamps()
	check(rd.get("ok", false) and gs.commissary_credit == 300, "redeem stamps", rd.get("text", ""))
	check(gs.inventory_count("food_stamp") == 0, "stamps consumed")
	var before = gs.inventory_count("nutrifruit")
	var buy = gs.commissary_buy("nutrifruit")
	check(buy.get("ok", false) and gs.commissary_credit == 288 and gs.inventory_count("nutrifruit") == before + 1, "commissary buy", buy.get("text", ""))
	check(int(gs.commissary_stock.get("nutrifruit", 0)) == 7, "stock decremented", str(gs.commissary_stock.get("nutrifruit", 0)))
	# restock
	gs._init_commissary()
	gs.commissary_stock["nutrifruit"] = 1
	gs.commissary_restock()
	check(int(gs.commissary_stock.get("nutrifruit", 0)) == 5, "commissary restock", str(gs.commissary_stock.get("nutrifruit", 0)))
	# dividends
	gs.owned_upgrades["BREWER_SHAREHOLDER"] = true
	gs.owned_upgrades["MINER_SHAREHOLDER"] = true
	gs.owned_upgrades["PHARMA_SHAREHOLDER"] = true
	var beer_before = gs.inventory_count("beerCase")
	var ore_before = gs.inventory_count("common_ore")
	var inj_before = gs.inventory_count("pink_alt_injector")
	gs.day = 4
	gs.start_day()
	check(gs.inventory_count("beerCase") == beer_before + 1, "brewer dividend thursday", str(gs.inventory_count("beerCase")))
	gs.day = 5
	gs.start_day()
	check(gs.inventory_count("common_ore") == ore_before + 6, "miner dividend friday", str(gs.inventory_count("common_ore")))
	gs.day = 7
	gs.start_day()
	check(gs.inventory_count("pink_alt_injector") == inj_before + 5, "pharma dividend sunday", str(gs.inventory_count("pink_alt_injector")))
	# wild and sec dialogs
	var wild = gs.phone_dial("wild")
	check(wild.get("ok", false) and wild.get("choices", []).size() == 2, "wild service dialog")
	var sec = gs.phone_dial("sec")
	check(sec.get("ok", false) and sec.get("choices", []).size() == 2, "security dialog")
	var comm = gs.phone_dial("commissary")
	check(comm.get("ok", false), "commissary dialog")
	# save/load commissary
	gs.commissary_credit = 55
	var save_ok = gs.save_game(3)
	var credit = gs.commissary_credit
	gs.new_game()
	var load_ok = gs.load_game(3)
	check(save_ok and load_ok and gs.commissary_credit == credit, "commissary credit saved", "%s/%s/%d" % [save_ok, load_ok, gs.commissary_credit])
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
