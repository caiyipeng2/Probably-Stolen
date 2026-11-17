# [L2 执行层] inv.gd — 分页与容器物品
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	check_eq(state.pages_unlocked, 3, "start pages")
	check_eq(state.inventory.size(), 46, "start inventory")
	var containers := []
	for id in state.items_def:
		if String(state.items_def[id].get("category", "")) == "container":
			containers.append(id)
	check_eq(containers.size(), 23, "container defs")
	check(containers.has("water_jug") and containers.has("backpack_large") and containers.has("backpack_large_military"), "container sample")
	state.add_item(state.make_item("backpack_large"))
	check_eq(state.inventory.size(), 47, "after one container")
	state.add_item(state.make_item(containers[1]))
	check_eq(state.inventory.size(), 48, "after two containers")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
