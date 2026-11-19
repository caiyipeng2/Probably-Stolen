extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("normal")
	gs.rng.seed = 20261119
	gs.run_stats["customers_served"] = 7
	gs.run_stats["inspections"] = 2
	gs.run_stats["inspections_passed"] = 1
	gs.run_stats["goods_seized"] = 3
	gs.run_stats["burglaries"] = 1
	gs.run_stats["burglary_losses"] = 120
	gs.run_stats["scavenge_attempts"] = 4
	gs.run_stats["scavenged_value"] = 88
	gs.sec_crimes["FENCING"] = 200
	gs.sec_evidence = 40
	gs.night_log = ["测试日志：夜间失窃。"]
	gs.rep["lower"] = 15
	var summary: Dictionary = gs.finish_day()
	var secs: Dictionary = gs.day_summary_sections(summary)
	check(secs.size() == 6, "six summary sections", str(secs.size()))
	for key in ["overview", "credits", "expenses", "station", "nights", "security"]:
		check(String(secs.get(key, "")) != "", "section non-empty " + key)
	check(String(secs["overview"]).contains("第 %d 天" % int(summary["day"])), "overview day")
	check(String(secs["overview"]).contains("净资产"), "overview net worth")
	check(String(secs["expenses"]).contains("失窃损失"), "expenses losses")
	check(String(secs["station"]).contains("下层 +15"), "station reputation", String(secs["station"]))
	check(String(secs["nights"]).contains("测试日志"), "nights log", String(secs["nights"]))
	check(String(secs["security"]).contains("200"), "security crime total", String(secs["security"]))
	check(String(secs["security"]).contains("40/100"), "security evidence", String(secs["security"]))
	var src := FileAccess.get_file_as_string("res://scripts/main.gd")
	check(src.contains("summary_tabs") and src.contains('"security"'), "summary UI tabs wired")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
