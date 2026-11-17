# [L2 执行层] archive.gd — 对话档案分组与条目
extends "res://tests/execution/case.gd"

func run() -> void:
	var total := 0
	for g in state.dialogue_archive:
		total += g.get("entries", []).size()
	check_eq(state.dialogue_archive.size(), 34, "archive groups")
	check_eq(total, 2544, "archive entries")
	check_eq(String(state.dialogue_archive[0].get("name", "")), "剧情顾客", "first group name")
	check_eq(state.dialogue_archive[0].get("entries", []).size(), 463, "first group entries")
