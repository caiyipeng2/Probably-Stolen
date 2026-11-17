# [L2 执行层] catalog.gd — 物品目录与分页背包
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	step("catalog counts")
	check(state.items_def.size() >= 474, "items_def >= 474", str(state.items_def.size()))
	check_eq(state.tradable_pool.size(), 422, "tradable_pool")
	check_eq(String(state.items_def["beis_icecream"]["name"]), "贝氏优质香草冰淇淋", "icecream name")
	check_eq(int(state.items_def["hand_gold"]["base_value"]), 200, "hand_gold value")
	check_eq(String(state.items_def["water_bottle_full"]["category"]), "food", "water category")
	step("inventory paging")
	for i in range(40):
		state.add_item(state.make_item("cig_red"))
	var pages := {}
	for it in state.inventory:
		var pg := int(it.get("page", 0))
		pages[pg] = int(pages.get(pg, 0)) + 1
	check_eq(state.inventory.size(), 86, "inventory after 40 cigs")
	check_eq(int(pages.get(0, 0)), 67, "page0 count")
	check_eq(int(pages.get(1, 0)), 19, "page1 count")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
