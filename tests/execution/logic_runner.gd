# [L2 执行层] logic_runner.gd — headless 逻辑用例入口
extends SceneTree

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var report_dir := _arg(args, "--qa-report-dir", "user://qa_logic")
	var filter := _arg(args, "--qa-filter", "")
	var only := _arg(args, "--qa-cases", "")
	var only_set := {}
	for x in only.split(",", false):
		if x != "":
			only_set[x] = true
	var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://tests/execution/suites.json"))
	var total_fail := 0
	var seen := 0
	for entry in manifest.get("cases", []):
		if String(entry.get("runner", "")) != "logic":
			continue
		if not only_set.is_empty() and not only_set.has(String(entry.get("id", ""))):
			continue
		if filter != "" and not String(entry.get("id", "")).contains(filter):
			continue
		var case_script = load("res://tests/execution/" + String(entry["file"]))
		if case_script == null or not case_script.can_instantiate():
			print("ERROR " + String(entry["id"]) + " | failed to load case script")
			total_fail += 1
			continue
		var case = case_script.new()
		case.id = String(entry["id"])
		case.seed_value = int(entry.get("seed", 20261117))
		case.state = load("res://scripts/game_state.gd").new()
		case.state._load_defs()
		var t0 := Time.get_ticks_msec()
		case.setup()
		case.run()
		case.teardown()
		var res: Dictionary = case.to_result()
		res["duration_ms"] = Time.get_ticks_msec() - t0
		total_fail += int(res.get("fails", 0))
		_write_result(report_dir, case.id, res)
		print(("PASS " if res["status"] == "PASS" else "FAIL ") + case.id)
		seen += 1
	print("LOGIC cases=%d fails=%d" % [seen, total_fail])
	quit(0 if total_fail == 0 else 1)

func _arg(args: PackedStringArray, name: String, fallback: String) -> String:
	for a in args:
		if a.begins_with(name + "="):
			return a.substr(name.length() + 1)
	return fallback

func _write_result(dir: String, cid: String, data: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	var path := dir.path_join(cid.replace("/", "__") + ".json")
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
