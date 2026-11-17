# [L2 执行层] recipes_modules.gd — 配方、模块与读档
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	var recipes := 0
	for m in state.machines:
		recipes += m.get("recipes", []).size()
	check_eq(state.machines.size(), 34, "machines")
	check_eq(recipes, 52, "recipes")
	check_eq(state.modules_def.size(), 31, "modules")
	state.set_machine_recipe("printer", "printer_chip_pistol_double")
	state.add_item(state.make_item("printer_chip_pistol_double", 100, true, false))
	check_eq(String(state.machine_recipe("printer").get("id", "")), "printer_chip_pistol_double", "printer recipe")
	check_eq(float(state.machine_recipe("printer").get("cycles", 0)), 6.0, "printer cycles")
	var pr = state.start_machine("printer")
	check(String(pr.get("text", "")).contains("已启动"), "printer started", String(pr.get("text", "")))
	check_eq(float(state.machine_jobs[0].get("remaining", 0)), 6.0, "printer remaining")
	state.install_module("furnace", "system_module_performance")
	var fr = state.start_machine("furnace")
	check(String(fr.get("text", "")).contains("已启动"), "furnace module started", String(fr.get("text", "")))
	check_eq(float(state.machine_jobs[-1].get("remaining", 0)), 1.0, "furnace module remaining")
	check(state.save_game(9), "save slot9")
	state.new_game()
	check(state.load_game(9), "load slot9")
	check_eq(String(state.machine_recipes.get("printer", "")), "printer_chip_pistol_double", "loaded recipe")
	check_eq(state.machine_modules.get("furnace", []), ["system_module_performance"], "loaded module")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
