# [L2 执行层] machines.gd — 净水器/熔炉/打印机基础循环
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	check_eq(state.power, 10, "start power")
	check_eq(state.inventory_count("water_bottle_full"), 1, "water")
	check_eq(state.inventory_count("water_tablet"), 2, "tablet")
	check_eq(state.inventory_count("scrap_metal"), 3, "scrap")
	check_eq(state.inventory_count("printer_plastic"), 3, "plastic")
	var purifier = state.start_machine("water_purifier")
	check(not bool(purifier.get("ok", true)), "purifier is aux", String(purifier.get("text", "")))
	check(String(purifier.get("text", "")).contains("辅助设备"), "purifier aux text")
	for i in range(8):
		state.advance_machines_one_cycle()
	check_eq(state.inventory_count("bottled_water_premium"), 0, "no premium water")
	check_eq(state.power, 10, "power unchanged")
	var furnace = state.start_machine("furnace")
	check(bool(furnace.get("ok", false)), "furnace start", String(furnace.get("text", "")))
	for i in range(8):
		state.advance_machines_one_cycle()
	check_eq(state.machine_io_container("furnace", "output").get("children", []).size(), 1, "ingot grid")
	check_eq(state.power, 8, "power after furnace")
	var printer = state.start_machine("printer")
	check(bool(printer.get("ok", false)), "printer start", String(printer.get("text", "")))
	for i in range(8):
		state.advance_machines_one_cycle()
	check_eq(state.machine_io_container("printer", "output").get("children", []).size(), 1, "printed gun grid")
	check_eq(state.power, 5, "power after printer")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
