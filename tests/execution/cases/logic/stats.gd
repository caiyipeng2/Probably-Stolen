# [L2 执行层] stats.gd — 目录完整性与回退值统计
extends "res://tests/execution/case.gd"

func run() -> void:
	var n := 0
	var names_fb := 0
	var values_fb := 0
	var no_icon := 0
	for id in state.tradable_pool:
		n += 1
		var d = state.items_def[id]
		if String(d.get("name", "")) == id:
			names_fb += 1
		if not bool(d.get("unit_value_found", true)):
			values_fb += 1
		if String(d.get("icon", "")) == "":
			no_icon += 1
	check(state.items_def.size() >= 474, "defs >= 474", str(state.items_def.size()))
	check_eq(n, 422, "tradable")
	check_eq(names_fb, 0, "name fallbacks")
	check_eq(values_fb, 68, "value fallbacks")
	check_eq(no_icon, 0, "missing icons")
	check_eq(state.pages_unlocked, 2, "initial pages")
