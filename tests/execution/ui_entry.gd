# [L2 执行层] ui_entry.gd — 桌面 UI 用例进程入口：实例化 Main、运行单个用例、写结果
extends Node

const DesktopDriver = preload("res://tests/control/desktop_driver.gd")
const DesktopCapturer = preload("res://tests/screenshot/capture.gd")

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var case_file := _arg(args, "--qa-case", "")
	var case_id := _arg(args, "--qa-id", case_file.get_basename())
	var report_path := _arg(args, "--qa-report", "user://qa_result.json")
	var artifacts := _arg(args, "--qa-artifacts", "user://qa_artifacts")
	var seed_value := int(_arg(args, "--qa-seed", "20261117"))
	var main = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	get_tree().create_timer(60.0).timeout.connect(func(): get_tree().quit(2))
	await get_tree().create_timer(0.5).timeout
	var case_script = load("res://tests/execution/" + case_file)
	if case_script == null or not case_script.can_instantiate():
		_write_json(report_path, {"id": case_id, "status": "ERROR",
			"error": "failed to load case script: " + case_file,
			"assertions": [], "shots": [], "steps": []})
		get_tree().quit(2)
		return
	var case = case_script.new()
	case.id = case_id
	case.seed_value = seed_value
	case.state = GameState
	case.driver = DesktopDriver.new(main)
	case.capturer = DesktopCapturer.new(main, artifacts, case.id.replace("/", "_"))
	var t0 := Time.get_ticks_msec()
	await case.setup()
	await case.run()
	await case.teardown()
	var result: Dictionary = case.to_result()
	result["duration_ms"] = Time.get_ticks_msec() - t0
	_write_json(report_path, result)
	get_tree().quit(0 if String(result.get("status", "FAIL")) == "PASS" else 1)

func _arg(args: PackedStringArray, name: String, fallback: String) -> String:
	for a in args:
		if a.begins_with(name + "="):
			return a.substr(name.length() + 1)
	return fallback

func _write_json(path: String, data: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
