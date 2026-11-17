# [L2 执行层] m4.gd — 派系、专精、升级与委托
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	check_eq(state.factions.size(), 8, "factions")
	check_eq(state.upgrades.size(), 60, "upgrades")
	check_eq(state.professions.size(), 13, "professions")
	check_eq(state.commissions.size(), 3, "commissions")
	var pid := String(state.professions[0]["id"])
	var pr = state.apply_profession(pid)
	check(bool(pr.get("ok", false)), "profession applied", String(pr.get("text", "")))
	check(state.profession_chosen, "profession chosen")
	var uid := String(state.upgrades[0]["id"])
	var ur = state.buy_upgrade(uid)
	check(bool(ur.get("ok", false)), "upgrade bought", String(ur.get("text", "")))
	check(state.owned_upgrades.size() >= 1, "owned upgrades")
	if not state.commissions.is_empty():
		var c = state.commissions[0]
		for i in range(int(c["count"])):
			state.add_item(state.make_item(String(c["item_id"]), 100, true, false))
		var before: int = state.commissions.size()
		var dr = state.deliver_commission(String(c["id"]))
		check(bool(dr.get("ok", false)), "commission delivered", String(dr.get("text", "")))
		check_eq(state.commissions.size(), before - 1, "commission removed")
	check(state.save_game(9), "save slot9")
	state.new_game()
	check(state.load_game(9), "load slot9")
	check(state.profession_id != "", "loaded profession")
	check(state.profession_chosen, "loaded chosen")
	check(state.owned_upgrades.size() >= 1, "loaded upgrades")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
