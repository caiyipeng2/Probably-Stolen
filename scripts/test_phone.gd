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
	check(gs.phone_contacts.size() >= 6, "phone contacts")
	check(gs.phone_clients.get("red_imp", {}).get("state", "") == "NotResponding", "supplier starts unavailable")
	# upgrade unlock + card
	gs.cash = 10000
	var up = gs.buy_upgrade("BREWER")
	check(up.get("ok", false), "buy brewer upgrade", up.get("text", ""))
	check(gs.phone_client("red_imp").get("state", "") == "Introduction", "supplier introduction state")
	check(gs.inventory_count("card_brewer") == 1, "supplier card granted")
	check(gs.phone_number_of("red_imp") == "8815", "supplier number")
	# intro dialog
	var d = gs.phone_dial("red_imp")
	check(d.get("ok", false) and d.get("pages", []).size() >= 3, "intro pages", str(d.get("pages", []).size()))
	check(not d.get("choices", []).is_empty(), "intro choices")
	var r = gs.phone_choose("red_imp", "intro_end")
	check(bool(r.get("close", false)) and gs.phone_client("red_imp").get("state", "") == "Cooldown", "intro completes to cooldown")
	check(gs.future_customers.size() == 1 and bool(gs.future_customers[0].get("free", false)), "free courier queued")
	# next day free courier
	gs.day += 1
	gs.start_day()
	var free_c: Dictionary = {}
	for c in gs.customers_today:
		if String(c.get("intent", "")) == "wholesale" and bool(c.get("wholesale_free", false)):
			free_c = c
	check(not free_c.is_empty(), "free courier appears")
	gs.current_customer = free_c
	var before = gs.inventory_count("beerCase")
	var bought = gs.buy_wholesale()
	check(bought.get("ok", false) and gs.inventory_count("beerCase") == before + 1, "free courier delivered beer", bought.get("text", ""))
	# cooldown tick to regular
	gs.phone_client("red_imp")["cooldown"] = 1
	gs.day += 1
	gs.start_day()
	check(gs.phone_client("red_imp").get("state", "") == "Regular", "cooldown expires to regular", str(gs.phone_client("red_imp")))
	# paid order 0
	var order = gs.phone_order("red_imp", 0)
	check(order.get("ok", false), "order placed", order.get("text", ""))
	check(gs.phone_client("red_imp").get("state", "") == "Cooldown", "order sets cooldown")
	gs.day += 1
	gs.start_day()
	var paid_c: Dictionary = {}
	for c in gs.customers_today:
		if String(c.get("intent", "")) == "wholesale" and not bool(c.get("wholesale_free", true)):
			paid_c = c
	check(not paid_c.is_empty(), "paid courier appears")
	gs.cash = 10000
	gs.current_customer = paid_c
	var total = gs.wholesale_total(paid_c)
	var before2 = gs.phone_client("red_imp").get("amount_spent", 0)
	var bought2 = gs.buy_wholesale()
	check(bought2.get("ok", false) and int(gs.phone_client("red_imp").get("amount_spent", 0)) == int(before2) + total, "paid delivery tracked spend", bought2.get("text", ""))
	# phone book
	gs.phone_client("red_imp")["state"] = "Regular"
	var book = gs.phone_book_contacts()
	var found := false
	for c in book:
		if String(c.get("id", "")) == "red_imp":
			found = true
	check(found, "phone book lists dialed supplier")
	# second order locked by spend
	var locked = gs.phone_order("red_imp", 1)
	check(not locked.get("ok", false), "second order requires spend", locked.get("text", ""))
	gs.phone_client("red_imp")["amount_spent"] = 400
	gs.phone_client("red_imp")["state"] = "Regular"
	var unlocked = gs.phone_order("red_imp", 1)
	check(unlocked.get("ok", false), "second order unlocked", unlocked.get("text", ""))
	# rev merchant queue
	gs.phone_client("rev")["state"] = "Regular"
	var rev = gs.phone_dial("rev")
	check(rev.get("ok", false) and not rev.get("choices", []).is_empty(), "rev dialog")
	gs.phone_choose("rev", "rev_book")
	check(gs.future_customers.size() >= 1, "rev queues wanted")
	# save/load phone state
	gs.save_game(3)
	var amt = int(gs.phone_client("red_imp").get("amount_spent", 0))
	gs.new_game()
	gs.load_game(3)
	check(int(gs.phone_client("red_imp").get("amount_spent", 0)) == amt, "phone state saved", str(amt))
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
