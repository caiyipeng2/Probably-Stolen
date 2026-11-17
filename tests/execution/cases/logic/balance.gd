# [L2 执行层] balance.gd — 30 局经济与战斗模拟阈值
extends "res://tests/execution/case.gd"

const RUNS := 30

func run() -> void:
	var reached := {5: 0, 10: 0, 12: 0, 15: 0}
	var cash_by_day := {5: [], 10: [], 12: [], 15: []}
	var final_days := []
	var reasons := {}
	for run in range(RUNS):
		state.rng.seed = 1000 + run * 7919
		state.new_game()
		var snap := _play_run(state)
		final_days.append(int(snap.get("day", 0)))
		for d in [5, 10, 12, 15]:
			if snap.get("cash", {}).has(d):
				reached[d] = int(reached[d]) + 1
				cash_by_day[d].append(int(snap["cash"][d]))
		var reason := String(snap.get("reason", ""))
		if reason != "":
			reasons[reason] = int(reasons.get(reason, 0)) + 1
	check_eq(int(reached[10]), 30, "active reached day10")
	var median10 := _median(cash_by_day[10])
	check(median10 >= 1500 and median10 <= 2100, "median cash day10", str(median10))
	var p75_10 := _percentile(cash_by_day[10], 75)
	check(p75_10 >= 1700 and p75_10 <= 2100, "p75 cash day10", str(p75_10))
	var passive_days := []
	var passive_reasons := {}
	for run in range(30):
		state.rng.seed = 3000 + run * 3571
		state.new_game()
		var reason := ""
		while state.day <= 20 and state.phase != "gameover":
			var s = state.finish_day()
			if String(s.get("gameover", "")) != "":
				reason = String(s["gameover"])
				break
			state.advance_day()
		passive_days.append(state.day)
		if reason != "":
			passive_reasons[reason] = int(passive_reasons.get(reason, 0)) + 1
	var passive_median := _median(passive_days)
	check(passive_median >= 12 and passive_median <= 15, "passive median day", str(passive_median))
	check_eq(int(passive_reasons.get("rent", 0)), 30, "passive all rent")
	var cg = load("res://scripts/game_state.gd").new()
	cg._load_defs()
	cg.new_game()
	var wins := {}
	var fights := 0
	var total_wins := 0
	for enemy in ["thug", "raider", "enforcer", "boss_lou"]:
		var ew := 0
		for i in range(30):
			cg.rng.seed = 5000 + i * 131 + fights
			cg.start_combat(enemy)
			var turns := 0
			while cg.combat_active and turns < 60:
				if cg.combat_skill_cd <= 0:
					cg.combat_action("skill")
				else:
					cg.combat_action("attack")
				turns += 1
			fights += 1
			if not cg.combat_active and cg.combat_enemy_hp <= 0:
				total_wins += 1
				ew += 1
		wins[enemy] = ew
	check_eq(int(wins["thug"]), 30, "thug win rate")
	check_eq(int(wins["raider"]), 30, "raider win rate")
	check(int(wins["enforcer"]) >= 20, "enforcer win rate", str(wins["enforcer"]))
	check(int(wins["boss_lou"]) >= 8, "boss win rate", str(wins["boss_lou"]))
	var rate := 100.0 * float(total_wins) / float(fights)
	check(rate >= 70.0 and rate <= 95.0, "combat total rate", "%.1f%%" % rate)

func _play_run(gs) -> Dictionary:
	var cash := {}
	var reason := ""
	for d in range(16):
		if gs.phase == "gameover":
			break
		cash[gs.day] = gs.cash
		var guard := 0
		while not gs.current_customer.is_empty() and guard < 12:
			guard += 1
			var c = gs.current_customer
			if c.get("intent") == "sell":
				var it = c["item"]
				var val = gs.market_value(it, false, c["arche"].get("faction", "lower"))
				var asking = int(it.get("asking_price", 0))
				if asking <= int(val * 1.15) and gs.cash >= asking + 40:
					gs.make_offer(asking)
				else:
					gs.complete_customer(false)
			else:
				var uid := _find_wanted(gs, c.get("want_tags", []))
				if uid >= 0 and gs.add_to_display(uid):
					gs.put_display_on_counter(uid)
					var offer = int(c.get("offer", 0))
					if offer > 0 and offer >= int(gs.market_value(gs.counter_item, true, c["arche"].get("faction", "lower")) * 0.7):
						gs.make_sell_offer(offer)
					else:
						gs.complete_customer(false)
				else:
					gs.complete_customer(false)
		var s = gs.finish_day()
		if String(s.get("gameover", "")) != "":
			reason = String(s["gameover"])
			break
		gs.advance_day()
	return {"day": gs.day, "cash": cash, "reason": reason}

func _find_wanted(gs, tags: Array) -> int:
	if tags.is_empty():
		return -1
	var best := -1
	var best_val := -1
	for it in gs.inventory:
		if it.get("location", "backpack") != "backpack":
			continue
		var d = gs.get_item_def(String(it.get("def_id", "")))
		var matched := false
		for t in tags:
			if t in d.get("tags", []):
				matched = true
				break
		if not matched:
			continue
		var val = gs.market_value(it, true)
		if val > best_val:
			best_val = val
			best = int(it["uid"])
	return best

func _median(arr: Array) -> int:
	if arr.is_empty():
		return 0
	var a := arr.duplicate()
	a.sort()
	return int(a[a.size() / 2])

func _percentile(arr: Array, pct: int) -> int:
	if arr.is_empty():
		return 0
	var a := arr.duplicate()
	a.sort()
	var idx := clampi(int(float(a.size() - 1) * float(pct) / 100.0), 0, a.size() - 1)
	return int(a[idx])

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
