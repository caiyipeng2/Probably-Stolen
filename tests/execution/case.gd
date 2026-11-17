# [L2 执行层] case.gd — 用例基类：步骤、软断言、截图检查点、结果模型
extends RefCounted

var id := ""
var tags: Array = []
var seed_value := 20261117
var state = null
var driver = null
var capturer = null
var assertions: Array = []
var steps: Array = []
var shots: Array = []
var fails := 0
var error_text := ""

func setup() -> void:
	pass

func run() -> void:
	pass

func teardown() -> void:
	pass

func step(title: String) -> void:
	steps.append({"at": Time.get_datetime_string_from_system(), "title": title})

func check(ok: bool, label: String, detail: String = "") -> void:
	if not ok:
		fails += 1
	assertions.append({"label": label, "ok": ok, "detail": detail})
	print(("PASS " if ok else "FAIL ") + id + " | " + label + ((" | " + detail) if detail != "" else ""))

func check_eq(actual, expected, label: String) -> void:
	check(actual == expected, label, "actual=%s expected=%s" % [str(actual), str(expected)])

func check_text(key: String, expected: String, mode := "eq") -> void:
	if driver == null:
		check(false, "text." + key, "driver missing")
		return
	var actual: String = driver.read_text("main", key)
	var ok := (actual == expected) if mode == "eq" else actual.contains(expected)
	check(ok, "text." + key, "actual=" + actual)

func shot(name: String) -> void:
	if capturer == null:
		check(false, "shot." + name, "capturer missing")
		return
	var res: Dictionary = await capturer.capture(name)
	shots.append(res)
	if String(res.get("status", "PENDING")) == "ERROR":
		fails += 1

func to_result() -> Dictionary:
	return {
		"id": id,
		"tags": tags,
		"status": "FAIL" if fails > 0 else "PASS",
		"fails": fails,
		"error": error_text,
		"seed": seed_value,
		"assertions": assertions,
		"steps": steps,
		"shots": shots,
	}
