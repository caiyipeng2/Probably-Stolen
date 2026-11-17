# [L2 执行层] misc_machines.gd — 加热板/蒸发器/弹药箱分配器
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	check_eq(String(state.machine_def("heating_plate").get("name", "")), "加热板", "heating plate def")
	check_eq(String(state.machine_def("evaporator").get("name", "")), "蒸发器", "evaporator def")
	check_eq(String(state.machine_def("box_dispenser").get("name", "")), "box_dispenser", "box dispenser def")
	check(bool(state.machine_def("heating_plate").get("passive", false)), "heating plate passive")
	check(bool(state.machine_def("evaporator").get("passive", false)), "evaporator passive")
	var before := int(state.inventory_count("ammo_box"))
	var bstart = state.start_machine("box_dispenser")
	check(bool(bstart.get("ok", false)), "box dispenser start", String(bstart.get("text", "")))
	state.advance_machines_one_cycle()
	check_eq(state.inventory_count("ammo_box"), before + 1, "box dispenser output")
	check_eq(state.machine_jobs.size(), 0, "box dispenser job cleared")
	var ht = state.machine_toggle_active("heating_plate")
	check(bool(ht.get("ok", false)), "heating plate toggle", String(ht.get("text", "")))
	check(bool(state.machine_active.get("heating_plate", false)), "heating plate active")
	var hspec = state.machine_special_action("heating_plate")
	check(not bool(hspec.get("ok", true)) and String(hspec.get("select", "")) == "heat", "heating plate asks for item", String(hspec.get("text", "")))
	state.machine_toggle_active("heating_plate")
	var et = state.machine_toggle_active("evaporator")
	check(bool(et.get("ok", false)), "evaporator toggle", String(et.get("text", "")))
	check(bool(state.machine_active.get("evaporator", false)), "evaporator active")
	var espec = state.machine_special_action("evaporator")
	check(not bool(espec.get("ok", true)) and String(espec.get("select", "")) == "distill", "evaporator asks for item", String(espec.get("text", "")))
	state.machine_toggle_active("evaporator")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
