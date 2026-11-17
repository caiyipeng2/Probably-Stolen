# 分层自动化回归测试框架 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把现有散装的 headless 测试、`main.gd` 调试分支、截图逻辑和手工 ADB 流程，重建为控件层 / 执行层 / 截图验证层 / 回归结论层四层可维护框架。

**Architecture:** GDScript 内跑控件层与执行层（真实输入事件、控件文本断言）；Python 编排 Godot、ADB、截图基线比对和回归结论。桌面用代码化流程，真机用声明式 JSON 冒烟；两端共享语义控件表、截图基线与结论模型。

**Tech Stack:** Godot 4.7.2 / GDScript；Python 3.14 + Pillow 12.2 + numpy 2.4；ADB；Git Bash。

**Spec:** `docs/superpowers/specs/2026-11-17-regression-framework-design.md`

## Global Constraints

- Godot 可执行文件：`C:/Users/EDY/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`（下称 `$GODOT`）。
- 项目根目录：`E:/Probably Stolen`；桌面逻辑分辨率 2340×1080，`canvas_items` 拉伸。
- 真机：SM-S9280，序列号 `R5CX211TXNT`，Android 16，物理 1080×2340，横屏截图 2340×1080，density 450；包名 `com.caiyipeng.probablystolen.mobile`。
- 测试与基线 **不得进入 APK**：`export_presets.cfg` 的 `exclude_filter` 必须包含 `tests/*, tests/**`。
- 除以下四项外不改游戏行为：① `GameState._ready()` 一次性种子文件钩子；② `_finish_drag` 改用释放事件坐标；③ 给控件补充 `name`；④ 修复 buy 顾客的「议价/成交」按钮启用条件（经用户授权，见 Task 3）。前三项不改变正常玩法，第四项恢复 M24 起被禁用的买家交易路径。
- 每个新建脚本第一行必须是层标注注释（`# [L1 控件层]` / `# [L2 执行层]` / `# [L3 截图验证层]` / `# [L4 回归结论层]`）。
- **工作区前提**：实施在独立 worktree `E:/Probably Stolen-qa`（分支 `qa-framework`）进行，主目录 `E:/Probably Stolen` 留在 `main` 且只保留用户的在途改动（barter、wholesale 等），不得切分支或覆盖。`qa-framework` 基于已提交 HEAD（30885bb），**不包含**尚未提交的 barter 代码，因此 Task 8B 暂缓，等 barter 合入 main 并同步到 qa-framework 后再执行；当前不删除主目录的 `scripts/test_barter.gd`。
- 所有测试用例固定随机种子；逻辑用例统一使用存档槽 9，`teardown()` 删除 `user://save_9.json`。
- 真机清数据只允许在显式 `--fresh-device` 时执行；未带该开关时真机套件 SKIP，绝不隐式 `pm clear`。
- 每个任务完成后先跑本任务的验证命令；提交前确认工作区只包含本任务改动。是否 `git commit` 以用户当次授权为准。

---

### Task 1: 框架骨架、入口帮助与导出隔离

**Files:**
- Create: `tests/README.md`
- Create: `tests/control/README.md`
- Create: `tests/execution/README.md`
- Create: `tests/screenshot/README.md`
- Create: `tests/verdict/README.md`
- Create: `tests/run.py`
- Create: `tests/execution/suites.json`
- Create: `tests/baselines/.gdignore`（空文件）
- Create: `tests/__init__.py`、`tests/control/__init__.py`、`tests/execution/__init__.py`、`tests/screenshot/__init__.py`、`tests/verdict/__init__.py`（空文件，供 Python unittest 导入）
- Modify: `export_presets.cfg:11`
- Modify: `.gitignore`

**Interfaces:**
- Consumes: 无
- Produces: `tests/run.py --help`；`tests/execution/suites.json` 的 `cases[]` / `suites{}` 结构；退出码约定 `0/1/2`。

- [ ] **Step 1: 写四层 README 与总览**

`tests/README.md`：

```markdown
# 自动化回归测试框架

## 四层

| 层 | 目录 | 职责 | 禁止 |
|---|---|---|---|
| ① 控件层 | `control/` | 定位语义控件、注入真实输入、读取文本 | 业务断言、调用 GameState |
| ② 执行层 | `execution/` | 组织步骤、夹具、软断言 | 直接调 adb、直接比像素 |
| ③ 截图验证层 | `screenshot/` | 稳定帧捕获、基线比对、遮罩 | 决定用例整体结论 |
| ④ 回归结论层 | `verdict/` | 汇总、参考运行对比、报告、退出码 | 重新执行用例 |

## 命令

```bash
python tests/run.py --suite logic
python tests/run.py --suite ui
python tests/run.py --suite device --serial R5CX211TXNT --fresh-device
python tests/run.py --suite full
python tests/run.py --suite ui --update-baselines
python tests/run.py --build-control-map
```

## 能力矩阵

| 能力 | 桌面 | 真机 |
|---|---|---|
| tap / drag / 输入 | 真实输入事件 | ADB 真触摸 |
| 读控件文本 | 支持 | 不支持 |
| 截图检查点 | 支持 | 支持 |
| 断言 GameState | 仅逻辑用例 | 不支持 |
```

四个层 README 固定写：职责 / 输入 / 输出 / 依赖 / 禁止事项 / 被谁调用，内容按上表展开。

- [ ] **Step 2: 写 `tests/run.py` 参数骨架**

```python
#!/usr/bin/env python3
# [L4 回归结论层] run.py — 测试编排入口（参数解析与套件调度）
import argparse
import sys

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="tests/run.py")
    p.add_argument("--suite", default="full",
                   choices=["logic", "ui", "device", "smoke", "full"])
    p.add_argument("--filter", default="")
    p.add_argument("--serial", default="")
    p.add_argument("--fresh-device", action="store_true")
    p.add_argument("--require-device", action="store_true")
    p.add_argument("--update-baselines", action="store_true")
    p.add_argument("--reference-run", default="")
    p.add_argument("--build-control-map", action="store_true")
    p.add_argument("--godot", default="")
    p.add_argument("--apk", default="")
    return p

def main(argv=None) -> int:
    args = build_parser().parse_args(argv)
    print("qa skeleton: suite=%s filter=%s" % (args.suite, args.filter))
    return 2

if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 3: 写空的套件清单**

`tests/execution/suites.json`：

```json
{
  "cases": [],
  "suites": {
    "logic":  {"platform": "desktop", "runner": "logic"},
    "ui":     {"platform": "desktop", "runner": "ui"},
    "device": {"platform": "device",  "runner": "device"},
    "smoke":  {"tags": ["smoke"]},
    "full":   {}
  }
}
```

- [ ] **Step 4: 导出隔离与忽略规则**

`export_presets.cfg` 第 11 行改为：

```ini
exclude_filter="_research/*, _research/**, build/*, build/**, tests/*, tests/**"
```

`.gitignore` 追加：

```gitignore
__pycache__/
*.pyc
```

- [ ] **Step 5: 验证**

Run:

```bash
python tests/run.py --help
python -m json.tool tests/execution/suites.json
grep -n "tests/\*" export_presets.cfg
```

Expected：帮助正常打印；JSON 解析成功；grep 命中 `tests/*, tests/**`。

- [ ] **Step 6: 提交（经用户授权后）**

```bash
git add tests export_presets.cfg .gitignore
git commit -m "test: scaffold layered regression framework"
```

---

### Task 2: 控件层桌面驱动 + UI 入口 + 启动冒烟

**Files:**
- Create: `tests/control/ui_map.json`
- Create: `tests/control/desktop_driver.gd`
- Create: `tests/execution/case.gd`
- Create: `tests/execution/fixtures.gd`
- Create: `tests/execution/ui_entry.gd`
- Create: `tests/execution/ui_entry.tscn`
- Create: `tests/execution/cases/ui/boot_smoke.gd`
- Create: `tests/screenshot/capture.gd`
- Modify: `tests/execution/suites.json`
- Modify: `tests/run.py`

**Interfaces:**
- Consumes: Task 1 的套件清单与退出码约定。
- Produces:
  - `DesktopDriver.new(main_node: Node, map_path := "res://tests/control/ui_map.json")`
  - `await driver.tap(screen: String, key: String) -> bool`
  - `driver.read_text(screen, key) -> String`、`driver.is_visible(screen, key) -> bool`
  - `await driver.wait_visible(screen, key, timeout_ms := 5000) -> bool`
  - `QaCase` 字段 `id/tags/seed_value/state/driver/capturer`，方法 `setup/run/teardown/step/check/check_eq/check_text/shot/to_result`
  - `QaFixtures.new(driver, state)`，`await boot_to_main(difficulty, mode, seed_value) -> bool`

- [ ] **Step 1: 写 `ui_map.json` 初始控件表**

```json
{
  "screens": {
    "welcome": {
      "btn_easy": {"type": "button", "text": "简单"},
      "btn_normal": {"type": "button", "text": "普通"},
      "btn_hard": {"type": "button", "text": "困难"},
      "btn_original": {"type": "button", "text": "原版 1:1"}
    },
    "tutorial": {
      "btn_skip": {"type": "button", "text": "跳过教程"},
      "btn_know": {"type": "button", "text": "知道了"}
    },
    "main": {
      "day_label": {"type": "label", "property": "day_label"},
      "cash_label": {"type": "label", "property": "cash_label"},
      "customer_info": {"type": "label", "property": "customer_info_label"},
      "btn_machines": {"type": "button", "text": "机器"},
      "btn_archive": {"type": "button", "text": "档案"},
      "btn_end_day": {"type": "button", "text": "结束营业"}
    },
    "modal": {
      "title": {"type": "label", "property": "modal_title"},
      "text": {"type": "label", "property": "modal_text"},
      "btn_close": {"type": "button", "text": "关闭"},
      "btn_continue": {"type": "button", "text": "继续"},
      "btn_next_day": {"type": "button", "text": "下一天"}
    },
    "story": {
      "layer": {"type": "node", "property": "story_layer"},
      "btn_continue": {"type": "button", "text": "继续"}
    }
  },
  "device": {},
  "device_profiles": {}
}
```

- [ ] **Step 2: 写用例基类 `case.gd`**

```gdscript
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
```

- [ ] **Step 3: 写桌面驱动 `desktop_driver.gd`**

```gdscript
# [L1 控件层] desktop_driver.gd — 语义控件解析 + 真实输入事件注入
extends RefCounted

var root: Node
var ui_map: Dictionary = {}
var last_error := ""

func _init(main_node: Node, map_path := "res://tests/control/ui_map.json") -> void:
	root = main_node
	var f := FileAccess.open(map_path, FileAccess.READ)
	if f:
		ui_map = JSON.parse_string(f.get_as_text())
	else:
		push_error("ui_map missing: " + map_path)

func _spec(screen: String, key: String) -> Dictionary:
	return ui_map.get("screens", {}).get(screen, {}).get(key, {})

func _scope(spec: Dictionary) -> Node:
	var scope_name := String(spec.get("scope", ""))
	if scope_name != "":
		var sc = root.get(scope_name)
		if sc != null:
			return sc
	return root

func _find_by_text(parent: Node, text: String, contains: bool) -> Control:
	for child in parent.get_children():
		if child is Button and child.is_visible_in_tree():
			var t := String(child.text)
			if (contains and t.contains(text)) or (not contains and t == text):
				return child
		var found := _find_by_text(child, text, contains)
		if found != null:
			return found
	return null

func resolve(screen: String, key: String) -> Control:
	var spec := _spec(screen, key)
	if spec.is_empty():
		return null
	if spec.has("property"):
		var c = root.get(String(spec["property"]))
		if c is Control:
			return c
	if spec.has("name"):
		var n := root.find_child(String(spec["name"]), true, false)
		if n is Control:
			return n
	var scope := _scope(spec)
	if spec.has("text"):
		return _find_by_text(scope, String(spec["text"]), false)
	if spec.has("text_contains"):
		return _find_by_text(scope, String(spec["text_contains"]), true)
	return null

func is_visible(screen: String, key: String) -> bool:
	var c := resolve(screen, key)
	return c != null and c.is_visible_in_tree()

func read_text(screen: String, key: String) -> String:
	var c := resolve(screen, key)
	if c is Button:
		return (c as Button).text
	if c is Label:
		return (c as Label).text
	if c is LineEdit:
		return (c as LineEdit).text
	return ""

func read_property(prop: String):
	return root.get(prop)

func tap_control(control: Control) -> bool:
	if control == null or not control.is_visible_in_tree():
		return false
	await _click_at(control.get_global_rect().get_center())
	return true

func tap_text_contains(screen: String, text: String) -> bool:
	var scope := _scope(_spec(screen, "list"))
	var c := _find_by_text(scope, text, true)
	return await tap_control(c)

func find_text_contains(screen: String, text: String) -> Control:
	var scope := _scope(_spec(screen, "list"))
	return _find_by_text(scope, text, true)

func tap_first_in(property: String) -> bool:
	var parent = root.get(property)
	if parent == null:
		return false
	for child in parent.get_children():
		if child is Button and child.is_visible_in_tree():
			return await tap_control(child)
	return false

func type_text(screen: String, key: String, value: String) -> bool:
	var c := resolve(screen, key)
	if c is LineEdit:
		c.grab_focus()
		c.text = value
		c.text_submitted.emit(value)
		return true
	return false

func _click_at(pos: Vector2) -> void:
	var vp := root.get_viewport()
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = pos
	down.global_position = pos
	vp.push_input(down)
	await root.get_tree().process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = pos
	up.global_position = pos
	vp.push_input(up)
	await root.get_tree().process_frame

func tap(screen: String, key: String) -> bool:
	var c := resolve(screen, key)
	if c == null or not c.is_visible_in_tree():
		last_error = "control not found: %s.%s" % [screen, key]
		return false
	await _click_at(c.get_global_rect().get_center())
	return true

func wait_visible(screen: String, key: String, timeout_ms := 5000) -> bool:
	var deadline := Time.get_ticks_msec() + timeout_ms
	while Time.get_ticks_msec() < deadline:
		if is_visible(screen, key):
			return true
		await root.get_tree().create_timer(0.05).timeout
	last_error = "timeout: %s.%s" % [screen, key]
	return false

func drag_between(from_control: Control, to_pos: Vector2, steps := 12) -> bool:
	if from_control == null:
		return false
	var vp := root.get_viewport()
	var start := from_control.get_global_rect().get_center()
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = start
	down.global_position = start
	vp.push_input(down)
	await root.get_tree().process_frame
	for i in range(1, steps + 1):
		var p := start.lerp(to_pos, float(i) / float(steps))
		var motion := InputEventMouseMotion.new()
		motion.position = p
		motion.global_position = p
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		vp.push_input(motion)
		await root.get_tree().process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = to_pos
	up.global_position = to_pos
	vp.push_input(up)
	await root.get_tree().process_frame
	return true
```

- [ ] **Step 4: 写截图捕获 `capture.gd`（本任务只捕获，不比对）**

```gdscript
# [L3 截图验证测试层] capture.gd — 桌面稳定帧捕获，状态由 compare.py 回填
extends RefCounted

var root: Node
var out_dir: String
var case_id: String
var counter := 0

func _init(main_node: Node, artifacts_dir: String, cid: String) -> void:
	root = main_node
	out_dir = artifacts_dir
	case_id = cid

func capture(shot_name: String) -> Dictionary:
	var img := await _stable_image()
	if img == null:
		return {"name": shot_name, "status": "ERROR", "reason": "no viewport image"}
	counter += 1
	var name := "%02d_%s" % [counter, shot_name]
	var dir := out_dir.path_join(case_id)
	DirAccess.make_dir_recursive_absolute(dir)
	var path := dir.path_join(name + ".png")
	var err := img.save_png(path)
	return {"name": name, "file": path, "status": "PENDING" if err == OK else "ERROR"}

func _stable_image() -> Image:
	var last: Image = null
	var deadline := Time.get_ticks_msec() + 3000
	while Time.get_ticks_msec() < deadline:
		var img := root.get_viewport().get_texture().get_image()
		if last != null and img.get_data() == last.get_data():
			return img
		last = img
		await root.get_tree().create_timer(0.1).timeout
	return last
```

- [ ] **Step 5: 写夹具 `fixtures.gd`**

```gdscript
# [L2 执行层] fixtures.gd — 通用前置/后置动作，禁止写业务断言
extends RefCounted

var driver
var state

func _init(desktop_driver, game_state) -> void:
	driver = desktop_driver
	state = game_state

func close_modal() -> bool:
	for key in ["btn_close", "btn_know", "btn_continue"]:
		if driver.is_visible("modal", key):
			return await driver.tap("modal", key)
	return false

func skip_story() -> bool:
	var guard := 0
	while guard < 40:
		if driver.is_visible("story", "btn_continue"):
			await driver.tap("story", "btn_continue")
		elif await driver.tap_first_in("story_choices"):
			pass
		else:
			break
		await driver.root.get_tree().create_timer(0.1).timeout
		guard += 1
	return not driver.root.story_layer.visible

func boot_to_main(difficulty := "normal", mode := "mobile", seed_value := 20261117) -> bool:
	seed(seed_value)
	state.rng.seed = seed_value
	var welcome_key := "btn_original" if mode == "original" else ("btn_easy" if difficulty == "easy" else ("btn_hard" if difficulty == "hard" else "btn_normal"))
	if not await driver.wait_visible("welcome", welcome_key, 8000):
		return false
	if not await driver.tap("welcome", welcome_key):
		return false
	await driver.root.get_tree().create_timer(0.3).timeout
	if driver.is_visible("tutorial", "btn_skip"):
		await driver.tap("tutorial", "btn_skip")
	await driver.root.get_tree().create_timer(0.2).timeout
	await skip_story()
	await close_modal()
	return await driver.wait_visible("main", "day_label", 5000)
```

- [ ] **Step 6: 写 UI 入口场景与脚本**

`tests/execution/ui_entry.tscn`：

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://tests/execution/ui_entry.gd" id="1"]

[node name="QaUiEntry" type="Node"]
script = ExtResource("1")
```

`tests/execution/ui_entry.gd`：

```gdscript
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
	var main := load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(0.5).timeout
	var case_script = load("res://tests/execution/" + case_file)
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
```

- [ ] **Step 7: 写启动冒烟用例**

`tests/execution/cases/ui/boot_smoke.gd`：

```gdscript
# [L2 执行层] boot_smoke.gd — 欢迎页到主界面的最小闭环
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)

func run() -> void:
	step("main screen after boot")
	check(driver.is_visible("main", "day_label"), "main visible")
	var day := driver.read_text("main", "day_label")
	var cash := driver.read_text("main", "cash_label")
	check(day.contains("第 1 天"), "day 1", day)
	check(cash.contains("600"), "cash 600", cash)
	check(driver.read_text("main", "customer_info").contains("意图："), "customer intent shown")
	await shot("main_day1")
```

- [ ] **Step 8: 注册用例并实现 `run.py` 的 UI 调度**

`tests/execution/suites.json` 的 `cases` 增加：

```json
{"id": "ui/boot_smoke", "file": "cases/ui/boot_smoke.gd",
 "platform": "desktop", "runner": "ui", "seed": 20261117,
 "tags": ["smoke"]}
```

`tests/run.py` 替换 `main` 并增加以下函数（保留 Task 1 的参数）：

```python
ROOT = pathlib.Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))
GODOT = "C:/Users/EDY/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"

def load_manifest() -> dict:
    return json.loads((ROOT / "tests/execution/suites.json").read_text(encoding="utf-8"))

def select_cases(manifest: dict, suite: str, flt: str) -> list[dict]:
    cfg = manifest["suites"].get(suite, {})
    out = []
    for case in manifest["cases"]:
        if cfg.get("runner") and case.get("runner") != cfg["runner"]:
            continue
        if cfg.get("tags") and not set(cfg["tags"]).issubset(set(case.get("tags", []))):
            continue
        if flt and flt not in case["id"]:
            continue
        out.append(case)
    return out

def run_ui_cases(cases: list[dict], run_id: str, seed_default: int) -> list[dict]:
    run_dir = ROOT / "build/qa" / run_id
    results = []
    for case in cases:
        result_path = run_dir / "results" / (case["id"].replace("/", "__") + ".json")
        log_path = run_dir / "logs" / (case["id"].replace("/", "__") + ".log")
        result_path.parent.mkdir(parents=True, exist_ok=True)
        log_path.parent.mkdir(parents=True, exist_ok=True)
        cmd = [GODOT, "--path", str(ROOT), "tests/execution/ui_entry.tscn", "--",
               "--qa-case=" + case["file"],
               "--qa-id=" + case["id"],
               "--qa-report=" + str(result_path),
               "--qa-artifacts=" + str(run_dir / "desktop"),
               "--qa-seed=" + str(case.get("seed", seed_default))]
        proc = subprocess.run(cmd, cwd=ROOT, timeout=120, capture_output=True, text=True)
        log_path.write_text(proc.stdout + "\n" + proc.stderr, encoding="utf-8")
        if result_path.exists():
            data = json.loads(result_path.read_text(encoding="utf-8"))
        else:
            data = {"id": case["id"], "status": "ERROR",
                    "error": "no result json, exit=%d" % proc.returncode,
                    "assertions": [], "shots": [], "steps": []}
        data["exit_code"] = proc.returncode
        data["file"] = case["file"]
        data["seed"] = case.get("seed", seed_default)
        results.append(data)
        print(("PASS " if data.get("status") == "PASS" else "FAIL ") + case["id"])
    return results

def main(argv=None) -> int:
    args = build_parser().parse_args(argv)
    manifest = load_manifest()
    cases = select_cases(manifest, args.suite, args.filter)
    if args.suite in ("ui", "full", "smoke"):
        run_id = time.strftime("%Y%m%d-%H%M%S")
        results = [c for c in cases if c.get("runner") == "ui"] if args.suite != "ui" else cases
        if args.suite == "ui":
            results = run_ui_cases(cases, run_id, 20261117)
        elif results:
            results = run_ui_cases(results, run_id, 20261117)
        return 0 if all(r.get("status") == "PASS" for r in results) else 1
    return 2

if __name__ == "__main__":
    sys.exit(main())
```

补齐 imports：`pathlib, json, subprocess, time, sys, argparse`。

- [ ] **Step 9: 验证**

Run:

```bash
python tests/run.py --suite ui
```

Expected：Godot 窗口启动后自动关闭；控制台 `PASS ui/boot_smoke`；`build/qa/<run_id>/results/ui__boot_smoke.json` 中 `status=PASS`，`assertions` 全为 `ok=true`；退出码 0。

把 `boot_smoke.gd` 的 `"cash 600"` 检查临时改成 `"cash 999"`，重跑应 `FAIL` 且退出码 1；验证后改回。

- [ ] **Step 10: 提交（经用户授权后）**

```bash
git add tests
git commit -m "test: add desktop control driver and UI runner"
```

---

### Task 3: 交易流程用例（买/卖）并移除 `--autotest`

**Files:**
- Modify: `tests/control/ui_map.json`
- Modify: `tests/execution/fixtures.gd`
- Modify: `tests/execution/suites.json`
- Modify: `scripts/main.gd`（展示柜槽位加 name）
- Modify: `scripts/main.gd`（删除 `_autotest_if_requested` 及 `_ready` 调用）
- Create: `tests/execution/cases/ui/trade_sell_flow.gd`
- Create: `tests/execution/cases/ui/trade_buy_flow.gd`

**Interfaces:**
- Consumes: Task 2 的 `driver` / `fixtures` / `case.gd`。
- Produces: 夹具 `await ensure_customer_intent(intent: String) -> bool`、`await place_inventory_on_counter(uid: int) -> bool`、`await end_day() -> bool`。

- [ ] **Step 1: 扩展 `ui_map.json`**

在 `screens.main` 增加：

```json
"btn_inspect": {"type": "button", "text": "鉴定"},
"btn_bargain": {"type": "button", "text": "议价"},
"btn_deal": {"type": "button", "text": "成交"},
"btn_dismiss": {"type": "button", "text": "送客"},
"detail_display_btn": {"type": "button", "property": "detail_display_btn"},
"detail_counter_btn": {"type": "button", "property": "detail_counter_btn"}
```

在 `screens.modal` 增加：

```json
"btn_quote": {"type": "button", "text": "报价"},
"btn_next_day": {"type": "button", "text": "下一天"}
```

- [ ] **Step 2: 给展示柜槽位和背包图标补 name，并加 `tap_item_uid`**

`scripts/main.gd` 展示柜槽位创建处（定位 `btn.pressed.connect(_on_display_slot.bind(uid))`）在连接之后加一行：

```gdscript
btn.name = "display_%d" % uid
```

背包图标创建处（定位 `icon.pressed.connect(_on_item_selected.bind(uid))` 上方 `var uid := int(it["uid"])`）加一行：

```gdscript
icon.name = "item_%d" % uid
```

`tests/control/desktop_driver.gd` 增加：

```gdscript
func tap_item_uid(uid: int) -> bool:
	var node := root.find_child("item_%d" % uid, true, false)
	if node is Control and node.is_visible_in_tree():
		return await tap_control(node)
	return false
```

- [ ] **Step 3: 扩展夹具**

在 `fixtures.gd` 追加：

```gdscript
func ensure_customer_intent(intent: String) -> bool:
	var label := "出售物品" if intent == "sell" else ("委托估价" if intent == "appraise" else "想买东西")
	var guard := 0
	while guard < 8:
		await close_modal()
		var info: String = driver.read_text("main", "customer_info")
		if info.contains(label):
			return true
		if not await driver.tap("main", "btn_dismiss"):
			return false
		await driver.root.get_tree().create_timer(0.2).timeout
		await skip_story()
		guard += 1
	return false

func place_inventory_on_counter(uid: int) -> bool:
	if not await driver.tap_item_uid(uid):
		return false
	if not await driver.tap("main", "detail_display_btn"):
		return false
	await driver.root.get_tree().process_frame
	var display := driver.root.find_child("display_%d" % uid, true, false) as Control
	if display == null:
		return false
	if not await driver.tap_control(display):
		return false
	await driver.root.get_tree().process_frame
	return await driver.tap("main", "detail_counter_btn")

func end_day() -> bool:
	if not await driver.tap("main", "btn_end_day"):
		return false
	if not await driver.wait_visible("modal", "btn_next_day", 5000):
		return false
	if not await driver.tap("modal", "btn_next_day"):
		return false
	return await driver.wait_visible("main", "day_label", 5000)
```

`place_inventory_on_counter` 的动作顺序固定为：选中背包物品 → 点"上架" → 点展示柜同名槽位 → 点"放柜台"。

- [ ] **Step 4: 写卖/买两条用例**

`tests/execution/cases/ui/trade_sell_flow.gd`（顾客出售，玩家买入，seed 20261117 第一位顾客为 sell）：

```gdscript
# [L2 执行层] trade_sell_flow.gd — 鉴定→议价→成交→日结
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)
	await fixtures.ensure_customer_intent("sell")

func run() -> void:
	var cash_before := int(state.cash)
	step("inspect counter item")
	check(await driver.tap("main", "btn_inspect"), "open inspection")
	check(await driver.wait_visible("inspection", "info", 3000), "inspection visible")
	check(driver.read_text("inspection", "info").contains("品相"), "inspection info")
	await shot("inspect_open")
	await driver.tap("inspection", "btn_close")
	step("bargain and deal")
	check(await driver.tap("main", "btn_bargain"), "open bargain")
	check(await driver.wait_visible("modal", "btn_quote", 3000), "bargain modal")
	await shot("bargain_modal")
	await driver.tap("modal", "btn_quote")
	await driver.root.get_tree().create_timer(0.2).timeout
	check(driver.read_text("modal", "title").contains("议价"), "bargain result", driver.read_text("modal", "title"))
	await driver.tap("modal", "btn_close")
	check(await driver.tap("main", "btn_deal"), "deal")
	await driver.root.get_tree().create_timer(0.2).timeout
	check(driver.read_text("modal", "title").contains("成交"), "deal result", driver.read_text("modal", "title"))
	await shot("deal_result")
	await driver.tap("modal", "btn_close")
	check(state.cash < cash_before, "cash spent", str(cash_before) + " -> " + str(state.cash))
	step("end day")
	check(await fixtures.end_day(), "next day")
	check(driver.read_text("main", "day_label").contains("第 2 天"), "day 2")
	await shot("day2_main")
```

`tests/execution/cases/ui/trade_buy_flow.gd`（顾客购买，玩家卖出，seed 20261117 送客 3 次后第 4 位为 buy）：

实施中发现：`scripts/main.gd` 的 `bargain/deal` 仅允许 `intent == "sell"`，导致买家无法通过 UI 成交（M24 `1e45b5a` 引入）。经用户授权，在 qa-framework 修复为：

```gdscript
action_buttons["bargain"].disabled = not (has_customer and has_counter and intent in ["sell", "buy"])
action_buttons["deal"].disabled = not (has_customer and has_counter and intent in ["sell", "buy"])
```

买家流程只需上架→放柜台→成交；成交后可能弹教程，用例先跳过教程再断言现金与柜台清空。

```gdscript
# [L2 执行层] trade_buy_flow.gd — 上架→放柜台→成交
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)
	await fixtures.ensure_customer_intent("buy")

func run() -> void:
	var cash_before := int(state.cash)
	var uid := int(state.inventory[0]["uid"])
	step("put item on counter")
	check(await fixtures.place_inventory_on_counter(uid), "item on counter")
	check(not state.counter_item.is_empty(), "counter item set")
	await shot("counter_item")
	step("deal")
	check(await driver.tap("main", "btn_deal"), "deal")
	await driver.root.get_tree().create_timer(0.3).timeout
	await fixtures.skip_tutorial()
	await fixtures.close_modal()
	await shot("after_deal")
	check(state.cash > cash_before, "cash earned", "%d -> %d" % [cash_before, int(state.cash)])
	check(state.counter_item.is_empty(), "counter cleared")
```

- [ ] **Step 5: 注册用例**

`suites.json` 增加：

```json
{"id": "ui/trade_sell_flow", "file": "cases/ui/trade_sell_flow.gd", "platform": "desktop", "runner": "ui", "seed": 20261117, "tags": ["smoke", "trade"]},
{"id": "ui/trade_buy_flow", "file": "cases/ui/trade_buy_flow.gd", "platform": "desktop", "runner": "ui", "seed": 20261117, "tags": ["smoke", "trade"]}
```

- [ ] **Step 6: 删除旧的 `--autotest` 分支**

删除 `scripts/main.gd` 中 `_autotest_if_requested()` 整个函数以及 `_ready()` 里对它的调用。保留 `--publicassets`。

- [ ] **Step 7: 验证**

```bash
python tests/run.py --suite ui --filter ui/trade_sell_flow
python tests/run.py --suite ui --filter ui/trade_buy_flow
grep -n "autotest" scripts/main.gd
```

Expected：两条用例 PASS；grep 无命中；结果 JSON 含交易前后断言与截图检查点。

- [ ] **Step 8: 提交（经用户授权后）**

```bash
git add tests scripts/main.gd
git commit -m "test: migrate trade flows to layered UI tests"
```

---

### Task 4: 逻辑用例 runner + catalog 样板

**Files:**
- Create: `tests/execution/logic_runner.gd`
- Create: `tests/execution/cases/logic/catalog.gd`
- Modify: `tests/execution/case.gd`（`to_result` 已含 `fails`）
- Modify: `tests/execution/suites.json`
- Modify: `tests/run.py`

**Interfaces:**
- Consumes: `QaCase`、`suites.json`。
- Produces: `python tests/run.py --suite logic`；逐用例结果 JSON：`build/qa/<run_id>/results/logic__<name>.json`。

- [ ] **Step 1: 写逻辑 runner**

```gdscript
# [L2 执行层] logic_runner.gd — headless 逻辑用例入口
extends SceneTree

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var report_dir := _arg(args, "--qa-report-dir", "user://qa_logic")
	var filter := _arg(args, "--qa-filter", "")
	var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://tests/execution/suites.json"))
	var total_fail := 0
	var seen := 0
	for entry in manifest.get("cases", []):
		if String(entry.get("runner", "")) != "logic":
			continue
		if filter != "" and not String(entry.get("id", "")).contains(filter):
			continue
		var case_script = load("res://tests/execution/" + String(entry["file"]))
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
```

- [ ] **Step 2: 写 catalog 用例（样板）**

```gdscript
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
	DirAccess.open("user://").remove("save_9.json")
```

- [ ] **Step 3: 注册 catalog 并实现 `run.py` 逻辑调度**

`suites.json`：

```json
{"id": "logic/catalog", "file": "cases/logic/catalog.gd", "platform": "desktop", "runner": "logic", "seed": 20261117, "tags": ["data"]}
```

`run.py` 增加：

```python
def run_logic_cases(cases: list[dict], run_id: str) -> list[dict]:
    run_dir = ROOT / "build/qa" / run_id
    report_dir = run_dir / "results"
    report_dir.mkdir(parents=True, exist_ok=True)
    cmd = [GODOT, "--headless", "--path", str(ROOT),
           "--script", "res://tests/execution/logic_runner.gd", "--",
           "--qa-report-dir=" + str(report_dir)]
    proc = subprocess.run(cmd, cwd=ROOT, timeout=600, capture_output=True, text=True)
    (run_dir / "logs").mkdir(parents=True, exist_ok=True)
    (run_dir / "logs" / "logic.log").write_text(proc.stdout + "\n" + proc.stderr, encoding="utf-8")
    results = []
    for case in cases:
        path = report_dir / (case["id"].replace("/", "__") + ".json")
        if path.exists():
            results.append(json.loads(path.read_text(encoding="utf-8")))
        else:
            results.append({"id": case["id"], "status": "ERROR", "error": "no result json",
                            "assertions": [], "shots": [], "steps": []})
    print(proc.stdout)
    return results
```

`main` 中当 `args.suite in ("logic", "full", "smoke")` 时调用 `run_logic_cases([...logic...], run_id)`，并把逻辑结果计入总退出码。

- [ ] **Step 4: 验证**

```bash
python tests/run.py --suite logic
```

Expected：`PASS logic/catalog`、`LOGIC cases=1 fails=0`、退出码 0；结果 JSON 断言全部 `ok=true`。

临时把 `items_def` 期望改成 1，重跑应 exit 1；改回。

- [ ] **Step 5: 提交（经用户授权后）**

```bash
git add tests
git commit -m "test: add headless logic runner and catalog case"
```

---

### Task 5: 迁移逻辑用例 A（数据/内容）

**Files:**
- Create: `tests/execution/cases/logic/inv.gd`
- Create: `tests/execution/cases/logic/archive.gd`
- Create: `tests/execution/cases/logic/story_graphs.gd`
- Create: `tests/execution/cases/logic/meta.gd`
- Create: `tests/execution/cases/logic/stats.gd`
- Create: `tests/execution/cases/logic/endings.gd`
- Modify: `tests/execution/suites.json`

**Interfaces:**
- Consumes: Task 4 的 runner 与 `QaCase`。
- Produces: 6 个 `logic/*` 用例，数据量出现回归时直接失败。

**统一转换模板**（每个用例照此写）：

```gdscript
# [L2 执行层] <name>.gd — <原 test_x.gd 职责>
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	# 原 test_x.gd 的 _init 主体，print 改为 check/check_eq
	pass

func teardown() -> void:
	DirAccess.open("user://").remove("save_9.json")
```

- [ ] **Step 1: 迁移 `inv.gd`**

断言：

| 断言 | 期望 |
|---|---|
| `state.pages_unlocked` 初始 | `3` |
| `state.inventory.size()` 初始 | `46` |
| 容器类 def 数量 | `23` |
| 加 `backpack_large` 后 inventory | `47` |
| 再加第二个容器后 inventory | `48` |
| 容器样本包含 | `water_jug`、`backpack_large`、`backpack_large_military` |

- [ ] **Step 2: 迁移 `archive.gd`**

断言：`dialogue_archive.size()==34`、总条目 `2544`、首组名称 `剧情顾客`、首组条目 `463`。

- [ ] **Step 3: 迁移 `story_graphs.gd`**

断言：`story_graphs.size()==341`、总节点 `2165`、总选项 `80`、场景 `55`、图覆盖 `53`；`eleanor4.root==2`、根节点 speaker `埃莉诺`、text 以 `我的资金耗尽了` 开头、choices `0`。

- [ ] **Step 4: 迁移 `meta.gd`**

断言：easy `cash=800/rent=150`；hard `cash=450/rent=260`；原版模式第 6 天 `pending_story=="sc_georgio1_0"`；存档槽改为 9：`save_game(9)==true`、`has_save(9)==true`；读档后 `cash=1234/day=5/difficulty=="normal"`。

- [ ] **Step 5: 迁移 `stats.gd`**

断言：`items_def==474`、`tradable==422`、`names_fb==0`、`values_fb==68`、`no_icon==0`、`pages==2`。

- [ ] **Step 6: 迁移 `endings.gd`**

断言：

| 场景 | 期望 |
|---|---|
| `endings.size()` / `events.size()` | `21` / `13` |
| `ending_def("sec").title` | `治安部清剿` |
| 动态结局 | `buyout` / `cartel`；设 flag+rep 后 `buyout_mortgage` / `cartel_retired` |
| 欠租 / 贷款 | ending `rent` / `repo`，phase `gameover` |
| 声望 | `sec` / `hitman` |
| 查抄 / 夜袭 / Boss / 事件 / 债务 Boss | `arrest` / `sec` / `lou_bombed` / `reactor` / `lou_bombed_debt` |

- [ ] **Step 7: 注册全部用例**

`suites.json` 为每个文件增加一条，`runner: "logic"`，`tags: ["data"]`，seed `20261117`。

- [ ] **Step 8: 验证**

```bash
python tests/run.py --suite logic --filter logic/inv
python tests/run.py --suite logic --filter logic/archive
python tests/run.py --suite logic --filter logic/story_graphs
python tests/run.py --suite logic --filter logic/meta
python tests/run.py --suite logic --filter logic/stats
python tests/run.py --suite logic --filter logic/endings
```

Expected：全部 PASS。任意一条失败时先核对数据文件是否被改动，不得直接把期望值改成实际值。

- [ ] **Step 9: 提交（经用户授权后）**

```bash
git add tests
git commit -m "test: migrate data and content logic cases"
```

---

### Task 6: 迁移逻辑用例 B（经济/战役）

**Files:**
- Create: `tests/execution/cases/logic/m1.gd`
- Create: `tests/execution/cases/logic/m4.gd`
- Create: `tests/execution/cases/logic/m5.gd`
- Create: `tests/execution/cases/logic/m6.gd`
- Create: `tests/execution/cases/logic/combat.gd`
- Create: `tests/execution/cases/logic/growth.gd`
- Create: `tests/execution/cases/logic/balance.gd`
- Modify: `tests/execution/suites.json`

**Interfaces:**
- Consumes: Task 4 的 runner 与 `QaCase`。
- Produces: 7 个经济/战役用例；`balance` 使用阈值而非单局随机值。

- [ ] **Step 1: `m1.gd`（基础交易与日结）**

断言：开局 `day=1/cash=600/inventory=46`，顾客数 `3..6`；完成一次交易后现金与背包至少一项变化；连续 7 次日结不崩溃；最终 `day=8`、`has_save(9)==true`；读档 9 后 `day` 与 `cash` 与存档前一致。所有 `save_game()`/`load_game()` 改为槽 9。

- [ ] **Step 2: `m4.gd`（派系/专精/升级/委托）**

断言：`factions=8`、`upgrades=60`、`professions=13`、`commissions=3`；`apply_profession(professions[0].id).ok==true` 且 `profession_chosen==true`；`buy_upgrade(upgrades[0].id).ok==true`；若有委托，交付后 `commissions.size()` 减少 1；存档/读档 9 后 `profession_id` 非空、`profession_chosen==true`、`owned_upgrades.size()>=1`。

- [ ] **Step 3: `m5.gd`（事件/剧情效果/存档）**

断言：查抄事件后 `handmade_pistol` 数量 `1→0`；`apply_story_effects({"cash":50,...})` 后 `cash=650`、`story_flags.has("test_flag")==true`、`rep["lower"]==5`；`mark_story_seen("mentor_day2")` 后存档/读档 9，`story_seen.has("mentor_day2")` 与 flag 均为 true。

- [ ] **Step 4: `m6.gd`（剧情排期与长链）**

断言：

| 检查点 | 期望 |
|---|---|
| 场景数 | `55` |
| 开局 pending | `sc_georgio1_0` |
| 第 1 位顾客 story_scene | `georgio1` |
| 走完 georgio1 链 | `scene_seen.has("georgio1")`、`story_flags.has("georgio_intro_done")`、`scrap_metal>0` |
| 第 2 天 | pending `sc_georgio1_1_0`，queue 含 `mentor_day2`，speaker `导师` |
| 第 5 天 | pending `sc_serpico1_0` |
| 存档/读档 9 | `scene_seen.has("georgio1")`、`day=5` |
| 第 11 天 | pending `sc_georgio_assistance_3`，`scene_customers` 含 `georgio3`，顾客数 `3..6` |
| 后日谈收尾 | `scene_seen.size()>0`、`story_flags.size()>0` |

- [ ] **Step 5: `combat.gd`（战斗与结局）**

断言：`start_combat("thug")` 后循环攻击至结束，`combat_active==false`、`combat_player_hp>0`、`cash>=600`；通缉战斗后 `wanted_defeated` 包含首位通缉 id；`set_ending("owner")` 后 `ending_def("owner").title=="买下这家店"`。战斗随机结果不要断言具体现金。

- [ ] **Step 6: `growth.gd`（种植周期）**

断言：播种文本含 `已播种`；未成熟收获文本含 `不能收获`；5 周期后 `ready==true`、`harvests_left==3`；三次收获文本分别含 `还可收获 2 次`、`还可收获 1 次`、`作物已耗尽`；`machine_jobs.size()==0`、`inventory_count("nutrifruit")==2`；补种文本含 `已播种`。

- [ ] **Step 7: `balance.gd`（30 局模拟，阈值断言）**

断言：`RUNS=30`；主动经营 `reached[10]==30`；中位现金 day10 在 `1500..2100`，p75 day10 在 `1700..2100`；被动经营中位破产日 `12..15` 且全部 `gameover` 原因为 `rent`；战斗胜率：thug `30/30`、raider `30/30`、enforcer `>=20/30`、boss_lou `>=8/30`、总体 `70%..95%`。保留原 `_play_run/_find_wanted/_median/_percentile` 辅助函数。

- [ ] **Step 8: 注册并验证**

`suites.json` 增加 7 条 `runner:"logic"`，`tags:["economy"]` 或 `["combat"]`。

```bash
python tests/run.py --suite logic --filter logic/m1
python tests/run.py --suite logic --filter logic/m4
python tests/run.py --suite logic --filter logic/m5
python tests/run.py --suite logic --filter logic/m6
python tests/run.py --suite logic --filter logic/combat
python tests/run.py --suite logic --filter logic/growth
python tests/run.py --suite logic --filter logic/balance
```

Expected：全部 PASS；`balance` 运行时间可接受（< 60s）。

- [ ] **Step 9: 提交（经用户授权后）**

```bash
git add tests
git commit -m "test: migrate economy and campaign logic cases"
```

---

### Task 7: 迁移逻辑用例 C（机器）

**Files:**
- Create: `tests/execution/cases/logic/machines.gd`
- Create: `tests/execution/cases/logic/machines2.gd`
- Create: `tests/execution/cases/logic/machines_durability.gd`
- Create: `tests/execution/cases/logic/machine_faults.gd`
- Create: `tests/execution/cases/logic/recipes_modules.gd`
- Create: `tests/execution/cases/logic/aux_machines.gd`
- Modify: `tests/execution/suites.json`

**Interfaces:**
- Consumes: Task 4 的 runner 与 `QaCase`。
- Produces: 6 个机器用例；`aux_machines` 保留原 243 行 `check()` 断言。

- [ ] **Step 1: `machines.gd`**

断言：开局 `power=10`、`water_bottle_full=1`、`water_tablet=2`、`scrap_metal=3`、`printer_plastic=3`；净水器 `start_machine` 返回 `ok==false` 且文本含 `辅助设备`；8 周期后 `bottled_water_premium==0`；熔炉启动 `ok==true`，8 周期后输出网格 `children.size()==1`、`power==8`；打印机启动 `ok==true`，8 周期后输出网格 `children.size()==1`、`power==5`。

- [ ] **Step 2: `machines2.gd`**

断言：`auto_butcher` 与 `livestock_feed_dispenser` 返回 `ok==false` 且文本含 `辅助设备`；`blender` 返回 `ok==true`；3 周期后 `meat_scrap==2`、`processed_juice==0`、`industrial_fish_feed==2`。

- [ ] **Step 3: `machines_durability.gd`**

断言：熔炉耐久设 1 后启动 `ok==true`；3 周期后 `machine_durability["furnace"]==0`、`metal_ingot==0`；再次启动文本含 `已损坏`；维修费 `100`、维修结果文本含 `已维修`、耐久 `100`；补 2 废金属后启动 `ok==true`；净水器耐久设 42 并存档/读档 9，读回 `42.0`。

- [ ] **Step 4: `machine_faults.gd`**

断言：熔炉 `jam` 故障启动文本含 `卡料`；维修费 `130`、`machine_fault_name("jam")=="卡料"`；维修文本含 `已维修` 且故障被清除；再次启动 `ok==true`；`repair_visit` 事件后 `machine_faults.size()==0`、`machine_durability.size()==0`；打印机 `contamination` 存档/读档 9 后仍在。

- [ ] **Step 5: `recipes_modules.gd`**

断言：`machines.size()==34`、配方总数 `52`、`modules_def.size()==31`；打印机选 `printer_chip_pistol_double` 后 recipe id 正确、`cycles==6.0`；启动文本含 `已启动`、`machine_jobs[0].remaining==6`；熔炉安装 `system_module_performance` 后启动 `remaining==1`；存档/读档 9 后配方与模块保留。

- [ ] **Step 6: `aux_machines.gd`**

把原 `scripts/test_aux_machines.gd` 的 `check()` 调用整体搬入 `run()`，保留全部标签；`setup()` 创建 state 并加载 defs；`teardown()` 清理槽 9。不要删减断言。

- [ ] **Step 7: 注册并验证**

```bash
python tests/run.py --suite logic --filter logic/machines
python tests/run.py --suite logic --filter logic/machines2
python tests/run.py --suite logic --filter logic/machines_durability
python tests/run.py --suite logic --filter logic/machine_faults
python tests/run.py --suite logic --filter logic/recipes_modules
python tests/run.py --suite logic --filter logic/aux_machines
```

Expected：全部 PASS；`aux_machines` 的断言数量与原脚本一致（243 行文件的全部 `check`）。

- [ ] **Step 8: 提交（经用户授权后）**

```bash
git add tests
git commit -m "test: migrate machine logic cases"
```

---

### Task 8: 迁移逻辑用例 D（容器/验货）

**Files:**
- Create: `tests/execution/cases/logic/containers.gd`
- Create: `tests/execution/cases/logic/inspection.gd`
- Modify: `tests/execution/suites.json`

**Interfaces:**
- Consumes: Task 4 的 runner 与 `QaCase`。
- Produces: 2 个用例，保留原 `test_containers.gd` / `test_inspection.gd` 的全部断言与退出码语义。

- [ ] **Step 1: `containers.gd`**

把原 `scripts/test_containers.gd` 的 `check(...)` 调用整体搬入 `run()`，保留全部标签（容器定义、背包 8×9、嵌套、价值、液体、冰箱双区、IO 网格、锁箱战利品、分堆、alpha 掩码等）。存档槽改为 9。

- [ ] **Step 2: `inspection.gd`**

把原 `scripts/test_inspection.gd` 的断言整体搬入 `run()`，保留全部标签（工具、线索、对质、估价、评级等）。存档槽改为 9（若原文件使用）。

- [ ] **Step 3: 注册并验证**

```bash
python tests/run.py --suite logic --filter logic/containers
python tests/run.py --suite logic --filter logic/inspection
```

Expected：全部 PASS，且断言数与原脚本一致。

- [ ] **Step 4: 提交（经用户授权后）**

```bash
git add tests
git commit -m "test: migrate container and inspection logic cases"
```

---

### Task 8B: 迁移在途的 barter 逻辑用例（暂缓，等 barter 合入）

**状态：BLOCKED** — `qa-framework` 基于 HEAD，尚未包含 barter 代码；等主目录 barter 合入 main 并同步到本分支后再执行，避免复制未提交实现。当前跳过本任务，继续 Task 9。

**Files:**
- Create: `tests/execution/cases/logic/barter.gd`
- Modify: `tests/execution/suites.json`
- 保留：`scripts/test_barter.gd`（迁移验证通过并经用户确认前不得删除）

**Interfaces:**
- Consumes: Task 4 的 runner 与 `QaCase`；`scripts/game_state.gd` 中已存在的 barter API。
- Produces: `logic/barter` 用例；barter 逻辑回归纳入统一套件。

- [ ] **Step 1: 按现有 `scripts/test_barter.gd` 写 case**

```gdscript
# [L2 执行层] barter.gd — 以物易物条件、报价轮换与交换
extends "res://tests/execution/case.gd"

func setup() -> void:
	state.rng.seed = seed_value
	state.new_game()

func run() -> void:
	check_eq(state.barter_offer_defs.size(), 6, "barter client definitions")
	check(state.dialogue_lines.has("dialog_barter_accept"), "barter dialogue loaded")
	var c = state._gen_barter_customer()
	check(String(c.get("intent", "")) == "barter" and not c.get("barter_offers", []).is_empty(), "barter customer generated")
	state.inventory.clear()
	state.display.clear()
	state.add_item(state.make_item("nutrifruit", 100, true, false))
	state.add_item(state.make_item("processed_meat", 100, true, false))
	var c2 := {
		"arche": {"faction": "lower"}, "intent": "barter", "done": false, "line": "",
		"barter_name": "测试", "barter_want": "",
		"barter_conditions": [{"tag": "FOOD", "count": 2}],
		"barter_offers": [{"items": [{"id": "wire", "count": 3}]}], "barter_index": 0,
	}
	state.current_customer = c2
	check(state.barter_condition_satisfied(c2), "food condition satisfied")
	var res: Dictionary = state.accept_barter()
	check(bool(res.get("ok", false)) and state.inventory_count("wire") == 3, "barter accepted and items swapped")
	check(state.inventory_count("nutrifruit") == 0 and state.inventory_count("processed_meat") == 0, "required food consumed")
	check(bool(state.current_customer.get("done", false)), "barter marked done")
	state.inventory.clear()
	var bad := state.make_item("pink_alt_injector", 100, true, false)
	bad["features"].append({"id": "starch_grade", "name": "淀粉级", "mod": -20})
	state.add_item(bad)
	var cond := {"item": "pink_alt_injector", "blacklist": ["starch_grade", "junk_grade", "impurity"]}
	check(not state.barter_condition_satisfied({"barter_conditions": [cond]}), "blacklisted injector rejected")
	state.add_item(state.make_item("pink_alt_injector", 100, true, false))
	check(state.barter_condition_satisfied({"barter_conditions": [cond]}), "genuine injector accepted")
	state.current_customer = {
		"intent": "barter", "barter_offers": [{"items": [["wire", 1]]}, {"items": [["blood_bag", 2]]}],
		"barter_index": 0,
	}
	state.cycle_barter_offer(1)
	check_eq(int(state.current_customer.get("barter_index", 0)), 1, "offer set cycles")
	check_eq(int(state.barter_offer_items(state.current_customer)[0].get("count", 0)), 2, "current offer items")
	state.inventory.clear()
	state.current_customer = {
		"arche": {"faction": "lower"}, "intent": "barter", "done": false, "line": "",
		"barter_conditions": [{"tag": "FOOD", "count": 1}],
		"barter_offers": [{"items": [{"id": "wire", "count": 1}]}], "barter_index": 0,
	}
	var fail_res: Dictionary = state.accept_barter()
	check(not bool(fail_res.get("ok", false)), "barter rejects missing items")

func teardown() -> void:
	var d := DirAccess.open("user://")
	if d:
		d.remove("save_9.json")
```

- [ ] **Step 2: 注册并验证**

`suites.json` 增加：

```json
{"id": "logic/barter", "file": "cases/logic/barter.gd", "platform": "desktop", "runner": "logic", "seed": 20261117, "tags": ["data", "barter"]}
```

```bash
python tests/run.py --suite logic --filter logic/barter
```

Expected：PASS，断言数与原 `scripts/test_barter.gd` 的 `check` 调用数量一致（12 条）。

- [ ] **Step 3: 提交（经用户授权后）**

```bash
git add tests
git commit -m "test: migrate barter logic case"
```

barter 的 UI 层（`barter_layer`、上一组/下一组/接受交换）暂不在本计划自动化范围内；等该功能合入并稳定后，再按 Task 12 的方式新增 `ui/barter_flow`，并在 `tests/README.md` 的维护手册中登记。

---

### Task 9: 截图验证层（全量基线、遮罩、差异图）

**Files:**
- Create: `tests/screenshot/compare.py`
- Create: `tests/screenshot/config.json`
- Create: `tests/screenshot/masks/.gitkeep`
- Create: `tests/screenshot/test_compare.py`
- Modify: `tests/run.py`（case 结果截图处理）
- Modify: `tests/execution/cases/ui/boot_smoke.gd`（已有 `shot`）

**Interfaces:**
- Consumes: 结果 JSON 中 `shots[]`（`name/file/status`）。
- Produces:
  - `compare_image(current: Path, baseline: Path, mask: dict | None, cfg: dict) -> dict`，返回 `{status,diff_ratio,diff_pixels,diff_image,reason}`。
  - `process_results(results: list[dict], profile: str, baselines_root: Path, run_dir: Path, update: bool) -> list[dict]`
  - 状态：`PASS/FAIL/NEW_BASELINE/ERROR`；更新模式写基线。

- [ ] **Step 1: 先写失败的单测**

`tests/screenshot/test_compare.py`：

```python
import json
import tempfile
import unittest
from pathlib import Path
from PIL import Image
from tests.screenshot.compare import compare_image

def make(path, color, size=(100, 50)):
    Image.new("RGB", size, color).save(path)

class CompareTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.cfg = {"pixel_tolerance": 3, "diff_ratio_max": 0.001}

    def tearDown(self):
        self.tmp.cleanup()

    def test_identical_passes(self):
        a = self.root / "a.png"; b = self.root / "b.png"
        make(a, (10, 20, 30)); make(b, (10, 20, 30))
        res = compare_image(a, b, None, self.cfg)
        self.assertEqual(res["status"], "PASS")

    def test_single_pixel_diff_fails(self):
        a = self.root / "a.png"; b = self.root / "b.png"
        make(a, (0, 0, 0)); img = Image.new("RGB", (100, 50), (0, 0, 0))
        img.putpixel((0, 0), (255, 255, 255)); img.save(b)
        res = compare_image(a, b, None, {**self.cfg, "diff_ratio_max": 0.0})
        self.assertEqual(res["status"], "FAIL")
        self.assertGreater(res["diff_pixels"], 0)

    def test_mask_ignores_region(self):
        a = self.root / "a.png"; b = self.root / "b.png"
        make(a, (0, 0, 0)); img = Image.new("RGB", (100, 50), (0, 0, 0))
        img.paste((255, 255, 255), (0, 0, 50, 50)); img.save(b)
        mask = {"regions": [{"x": 0.0, "y": 0.0, "w": 0.6, "h": 1.0}]}
        res = compare_image(a, b, mask, {**self.cfg, "diff_ratio_max": 0.0})
        self.assertEqual(res["status"], "PASS")

    def test_size_mismatch_fails(self):
        a = self.root / "a.png"; b = self.root / "b.png"
        make(a, (0, 0, 0)); make(b, (0, 0, 0), (120, 50))
        res = compare_image(a, b, None, self.cfg)
        self.assertEqual(res["status"], "FAIL")
        self.assertIn("size", res["reason"])

    def test_missing_baseline(self):
        a = self.root / "a.png"; make(a, (0, 0, 0))
        res = compare_image(a, self.root / "missing.png", None, self.cfg)
        self.assertEqual(res["status"], "NEW_BASELINE")
```

- [ ] **Step 2: 跑单测确认失败**

```bash
python -m unittest tests.screenshot.test_compare -v
```

Expected：ImportError / compare_image 未定义。

- [ ] **Step 3: 实现 `compare.py`**

```python
#!/usr/bin/env python3
# [L3 截图验证测试层] compare.py — 基线比对、遮罩、差异图
import json
import shutil
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

def load_mask(mask_path: Path | None) -> dict | None:
    if mask_path and mask_path.exists():
        return json.loads(mask_path.read_text(encoding="utf-8"))
    return None

def _mask_array(mask: dict | None, size) -> np.ndarray:
    w, h = size
    arr = np.ones((h, w), dtype=bool)
    for r in (mask or {}).get("regions", []):
        x0 = max(0, int(float(r["x"]) * w)); y0 = max(0, int(float(r["y"]) * h))
        x1 = min(w, int((float(r["x"]) + float(r["w"])) * w))
        y1 = min(h, int((float(r["y"]) + float(r["h"])) * h))
        arr[y0:y1, x0:x1] = False
    return arr

def compare_image(current: Path, baseline: Path, mask: dict | None, cfg: dict,
                  diff_path: Path | None = None) -> dict:
    if not baseline.exists():
        return {"status": "NEW_BASELINE", "reason": "missing baseline", "diff_pixels": 0, "diff_ratio": 0.0}
    if not current.exists():
        return {"status": "ERROR", "reason": "missing current image", "diff_pixels": 0, "diff_ratio": 0.0}
    img_c = Image.open(current).convert("RGB")
    img_b = Image.open(baseline).convert("RGB")
    if img_c.size != img_b.size:
        return {"status": "FAIL", "reason": "size mismatch %s vs %s" % (img_c.size, img_b.size),
                "diff_pixels": 0, "diff_ratio": 1.0}
    a = np.asarray(img_c, dtype=np.int16)
    b = np.asarray(img_b, dtype=np.int16)
    diff = np.abs(a - b).max(axis=2)
    mask_arr = _mask_array(mask, img_c.size)
    total = int(mask_arr.sum())
    if total <= 0:
        return {"status": "ERROR", "reason": "mask covers entire image", "diff_pixels": 0, "diff_ratio": 0.0}
    changed = int(np.count_nonzero((diff > int(cfg.get("pixel_tolerance", 3))) & mask_arr))
    ratio = changed / total
    status = "PASS" if ratio <= float(cfg.get("diff_ratio_max", 0.001)) else "FAIL"
    if diff_path and status == "FAIL":
        overlay = np.array(img_c)
        red = np.zeros_like(overlay); red[..., 0] = 255
        bad = (diff > int(cfg.get("pixel_tolerance", 3))) & mask_arr
        overlay[bad] = red[bad]
        diff_path.parent.mkdir(parents=True, exist_ok=True)
        Image.fromarray(overlay).save(diff_path)
    return {"status": status, "reason": "", "diff_pixels": changed,
            "diff_ratio": ratio, "diff_image": str(diff_path) if diff_path and status == "FAIL" else None}

def load_config(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}

def process_results(results, profile, baselines_root, run_dir, update=False, config=None):
    config = config or {}
    base = baselines_root / profile
    masks_root = Path(__file__).resolve().parent / "masks"
    changes = []
    for case in results:
        for shot in case.get("shots", []):
            if shot.get("status") not in ("PENDING", None):
                continue
            baseline = base / case["id"] / (shot["name"] + ".png")
            mask = load_mask(masks_root / case["id"] / (shot["name"] + ".json"))
            cfg = dict(config.get("defaults", {}))
            cfg.update(config.get("profiles", {}).get(profile, {}))
            cfg.update(config.get("overrides", {}).get(case["id"] + "/" + shot["name"], {}))
            if update:
                baseline.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(shot["file"], baseline)
                shot.update({"status": "PASS", "baseline_updated": True, "diff_ratio": 0.0})
                changes.append("- 更新 `%s` ← `%s`" % (baseline, shot["file"]))
                continue
            diff_path = Path(shot["file"]).with_name("diff_" + Path(shot["file"]).name)
            res = compare_image(Path(shot["file"]), baseline, mask, cfg, diff_path)
            shot.update(res)
        if any(s.get("status") in ("FAIL", "ERROR", "NEW_BASELINE") for s in case.get("shots", [])):
            case["status"] = "FAIL"
    if update and changes:
        (run_dir / "baseline_changes.md").write_text("\n".join(changes) + "\n", encoding="utf-8")
    return results
```

`config.json`：

```json
{
  "defaults": {"pixel_tolerance": 3, "diff_ratio_max": 0.001},
  "profiles": {
    "desktop-2340x1080-win": {"diff_ratio_max": 0.001},
    "device-SM-S9280-2340x1080-16": {"diff_ratio_max": 0.003}
  },
  "overrides": {}
}
```

- [ ] **Step 4: 跑单测确认通过**

```bash
python -m unittest tests.screenshot.test_compare -v
```

Expected：5 个测试全部 OK。

- [ ] **Step 5: 接入 `run.py` 并生成首套桌面基线**

`run.py` 的 UI 调度完成后调用：

```python
from tests.screenshot.compare import load_config, process_results
profile = "desktop-2340x1080-win"
config = load_config(ROOT / "tests/screenshot/config.json")
results = process_results(results, profile, ROOT / "tests/baselines", run_dir, update=args.update_baselines, config=config)
```

运行：

```bash
python tests/run.py --suite ui --filter ui/boot_smoke --update-baselines
python tests/run.py --suite ui --filter ui/boot_smoke
python -m unittest tests.screenshot.test_compare -v
```

Expected：第一次写出 `tests/baselines/desktop-2340x1080-win/ui/boot_smoke/01_main_day1.png`；第二次 PASS；单测 OK。若首图含随机内容，先加遮罩再更新基线，不得直接提交不稳定基线。

- [ ] **Step 6: 截图失败重试一次并标记 FLAKY**

在 `run.py` 的初始 `process_results` 之后（非更新模式）加入：

```python
def retry_screenshot_failures(results, run_id, profile, config):
    for case in results:
        if case.get("status") != "FAIL":
            continue
        if not any(s.get("status") == "FAIL" for s in case.get("shots", [])):
            continue
        retry_run_id = run_id + "-retry"
        retry = run_ui_cases([{"id": case["id"], "file": case.get("file", ""), "seed": case.get("seed", 20261117)}],
                             retry_run_id, 20261117)
        if not retry:
            continue
        retry_dir = ROOT / "build/qa" / retry_run_id
        retry = process_results(retry, profile, ROOT / "tests/baselines", retry_dir,
                                update=False, config=config)
        if retry[0].get("status") == "PASS":
            case["status"] = "FLAKY"
            case["retry_passed"] = True
            case["retry_run"] = retry_run_id
    return results
```

调用条件：`if not args.update_baselines: results = retry_screenshot_failures(results, run_id, profile, config)`。重试结果只用于判定 FLAKY，不覆盖首次的 diff 证据。真机流程在 Task 17 用同样的"失败再跑一次"策略。

- [ ] **Step 7: 提交（经用户授权后）**

```bash
git add tests
git commit -m "test: add screenshot baseline comparison layer"
```

---

### Task 10: 迁移 `--testinspect` 为验货/估价流程

**Files:**
- Modify: `tests/control/ui_map.json`
- Modify: `tests/execution/fixtures.gd`
- Modify: `tests/execution/suites.json`
- Modify: `scripts/main.gd`（删除 `_testinspect_if_requested` / `_dumpinspect_if_requested` 及调用）
- Create: `tests/execution/cases/ui/inspect_flow.gd`
- Create: `tests/execution/cases/ui/appraise_flow.gd`

**Interfaces:**
- Consumes: Task 2/3 的 driver、fixtures、case base。
- Produces: 验货与估价两条用例；`ensure_customer_intent("appraise")` 可用于后续流程。

- [ ] **Step 1: 扩展 `ui_map.json`**

```json
"inspection": {
  "title": {"type": "label", "property": "inspection_title"},
  "info": {"type": "label", "property": "inspection_info"},
  "status": {"type": "label", "property": "inspection_status"},
  "input": {"type": "line_edit", "property": "inspection_appraisal_input"},
  "btn_close": {"type": "button", "text": "关闭"},
  "btn_magnifier": {"type": "button", "text_contains": "放大镜"},
  "btn_submit": {"type": "button", "text": "提交估价"}
}
```

- [ ] **Step 2: `inspect_flow.gd`**

```gdscript
# [L2 执行层] inspect_flow.gd — 验货工具、对质与关闭
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)
	await fixtures.ensure_customer_intent("sell")

func run() -> void:
	check(await driver.tap("main", "btn_inspect"), "open inspection")
	check(await driver.wait_visible("inspection", "info", 3000), "inspection visible")
	check(driver.read_text("inspection", "info").contains("品相"), "info has condition")
	await shot("inspect_initial")
	if driver.is_visible("inspection", "btn_magnifier"):
		check(await driver.tap("inspection", "btn_magnifier"), "use magnifier")
		check(driver.read_text("inspection", "info").contains("工具记录"), "tool note added")
	await shot("inspect_tool")
	await driver.tap("inspection", "btn_close")
	check(not driver.is_visible("inspection", "info"), "inspection closed")
```

- [ ] **Step 3: `appraise_flow.gd`**

seed 20261122，第三位顾客为 appraise：

```gdscript
# [L2 执行层] appraise_flow.gd — 估价输入与提交
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)
	await fixtures.ensure_customer_intent("appraise")

func run() -> void:
	check(driver.read_text("main", "customer_info").contains("委托估价"), "appraise customer")
	var action_text := driver.read_text("main", "btn_inspect")
	check(action_text.contains("估价"), "action renamed to appraise", action_text)
	check(await driver.tap("main", "btn_inspect"), "open appraisal")
	check(await driver.wait_visible("inspection", "input", 3000), "input visible")
	check(driver.type_text("inspection", "input", "620"), "type appraisal")
	check(await driver.tap("inspection", "btn_submit"), "submit appraisal")
	await driver.root.get_tree().create_timer(0.2).timeout
	check(driver.read_text("modal", "text") != "", "appraisal result shown")
	await shot("appraisal_result")
	await driver.tap("modal", "btn_close")
```

- [ ] **Step 4: 注册并验证**

`suites.json` 增加两条：`ui/inspect_flow` seed 20261117，`ui/appraise_flow` seed 20261122，tags `["smoke"]`。

```bash
python tests/run.py --suite ui --filter ui/inspect_flow --update-baselines
python tests/run.py --suite ui --filter ui/inspect_flow
python tests/run.py --suite ui --filter ui/appraise_flow --update-baselines
python tests/run.py --suite ui --filter ui/appraise_flow
```

Expected：全部 PASS，截图基线生成且第二次比对通过。

- [ ] **Step 5: 删除 `--testinspect` / `--dumpinspect`**

删除 `_testinspect_if_requested()`、`_dumpinspect_if_requested()` 及 `_ready()` 调用。`dump` 能力由 Task 16 的 `--build-control-map` 取代。

- [ ] **Step 6: 提交（经用户授权后）**

```bash
git add tests scripts/main.gd
git commit -m "test: migrate inspection and appraisal flows"
```

---

### Task 11: 迁移 `--testminigame` 为三个小游戏流程

**Files:**
- Modify: `tests/control/ui_map.json`
- Modify: `tests/control/desktop_driver.gd`（`set_slider_at`）
- Modify: `tests/execution/fixtures.gd`（`open_minigame`）
- Modify: `tests/execution/suites.json`
- Modify: `scripts/main.gd`（删除 `_testminigame_if_requested` 及调用；给小游戏格子加 name）
- Create: `tests/execution/cases/ui/minigame_flow.gd`

**Interfaces:**
- Consumes: driver/fixtures/case base。
- Produces: `driver.set_slider_at(property: String, index: int, value: float)`；`fixtures.open_minigame(machine_id: String) -> bool`。

- [ ] **Step 1: 给打印小游戏格子加 name**

`scripts/main.gd` 打印格子创建循环（`grid.add_child(b)` 之前）加：

```gdscript
b.name = "minigame_cell_%d" % i
```

- [ ] **Step 2: 驱动增加 `set_slider_at`（标记为直接注入）**

```gdscript
func set_slider_at(property: String, index: int, value: float) -> bool:
	var arr = root.get(property)
	if arr is Array and index >= 0 and index < arr.size() and arr[index] is HSlider:
		arr[index].set_value_no_signal(value)
		arr[index].value_changed.emit(value)
		return true
	return false
```

- [ ] **Step 3: 夹具增加 `open_minigame`**

```gdscript
func open_minigame(machine_id: String) -> bool:
	var main = driver.root
	state.add_item(state.make_item("metal_ingot", 100, true, false))
	state.add_item(state.make_item("printer_plastic", 100, true, false))
	main.call("_refresh")
	await driver.root.get_tree().process_frame
	main.selected_machine_id = machine_id
	match machine_id:
		"printer":
			main.call("_open_printer_minigame")
		"chem_finisher":
			main.call("_open_mix_minigame")
		"plant_dna_manipulator":
			main.call("_open_dna_minigame")
		_:
			return false
	await driver.root.get_tree().process_frame
	return true
```

说明：进入小游戏用一次白盒调用作为夹具（旧 `--testminigame` 同样直调），小游戏内部操作与断言全部走控件层。步骤日志记录 `setup_direct`。

- [ ] **Step 4: 写 `minigame_flow.gd`**

```gdscript
# [L2 执行层] minigame_flow.gd — 打印失败/成功、配比、DNA
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)

func run() -> void:
	var main = driver.root
	step("printer failure")
	check(await fixtures.open_minigame("printer"), "open printer minigame")
	await driver.tap("minigame", "btn_start_print")
	await driver.root.get_tree().create_timer(0.2).timeout
	check(driver.read_text("minigame", "status").contains("校准失败"), "printer fails empty")
	step("printer success")
	var target: Array = main.minigame_target
	for i in range(16):
		if int(target[i]) == 1:
			var cell := main.find_child("minigame_cell_%d" % i, true, false) as Control
			await driver.tap_control(cell)
	await driver.tap("minigame", "btn_start_print")
	await driver.root.get_tree().create_timer(0.2).timeout
	check(state.machine_jobs.size() >= 1, "printer job queued")
	await shot("printer_job")
	step("mix")
	check(await fixtures.open_minigame("chem_finisher"), "open mix minigame")
	for i in range(3):
		check(driver.set_slider_at("mix_sliders", i, float(main.mix_target[i])), "mix slider " + str(i))
	await driver.tap("minigame", "btn_start_mix")
	await driver.root.get_tree().create_timer(0.2).timeout
	check(state.machine_jobs.size() >= 2, "mix job queued")
	step("dna")
	check(await fixtures.open_minigame("plant_dna_manipulator"), "open dna minigame")
	for base in main.dna_target:
		await driver.tap_text_contains("minigame", String(base))
	await driver.tap("minigame", "btn_submit_dna")
	await driver.root.get_tree().create_timer(0.2).timeout
	check(state.machine_jobs.size() >= 3, "dna job queued")
```

`ui_map.json` 增加：

```json
"minigame": {
  "status": {"type": "label", "property": "minigame_status"},
  "btn_start_print": {"type": "button", "text": "启动打印"},
  "btn_start_mix": {"type": "button", "text": "启动混合"},
  "btn_submit_dna": {"type": "button", "text": "提交序列"}
}
```

DNA 碱基按钮按文本 `A/C/G/T` 点击，使用 `tap_text_contains`（需在 driver 实现，直接扫按钮文本）。

- [ ] **Step 5: 注册并验证**

`suites.json` 增加 `ui/minigame_flow`，seed 20261117，tags `["machine"]`。

```bash
python tests/run.py --suite ui --filter ui/minigame_flow --update-baselines
python tests/run.py --suite ui --filter ui/minigame_flow
```

Expected：PASS；截图基线生成；若全局 `randi()` 目标图案导致漂移，确认夹具已 `seed(seed_value)`。

- [ ] **Step 6: 删除 `--testminigame`**

删除 `_testminigame_if_requested()` 及 `_ready()` 调用。

- [ ] **Step 7: 提交（经用户授权后）**

```bash
git add tests scripts/main.gd
git commit -m "test: migrate minigame flows"
```

---

### Task 12: 迁移 `--testmachineui` 为机器面板流程

**Files:**
- Modify: `tests/control/ui_map.json`
- Modify: `tests/execution/fixtures.gd`
- Modify: `tests/execution/suites.json`
- Modify: `scripts/main.gd`（删除 `_testmachineui_if_requested` 及调用）
- Create: `tests/execution/cases/ui/machine_flow.gd`

**Interfaces:**
- Consumes: driver/fixtures/case base。
- Produces: `fixtures.open_machines()`、`fixtures.select_machine(name_contains: String) -> bool`、`fixtures.close_panel(scope)`。

- [ ] **Step 1: 扩展 `ui_map.json`**

```json
"machines": {
  "title": {"type": "label", "property": "machine_name_label"},
  "io": {"type": "label", "property": "machine_io_label"},
  "status": {"type": "label", "property": "machine_status_label"},
  "btn_close": {"type": "button", "text": "关闭"},
  "btn_aux": {"type": "button", "property": "machine_aux_btn"},
  "btn_special": {"type": "button", "property": "machine_special_btn"},
  "btn_stock": {"type": "button", "property": "machine_stock_btn"},
  "btn_stock_grid": {"type": "button", "property": "machine_stock_grid_btn"},
  "btn_io_in": {"type": "button", "property": "machine_io_in_btn"},
  "btn_io_out": {"type": "button", "property": "machine_io_out_btn"},
  "btn_scroll_down": {"type": "button", "text": "▼ 下翻"},
  "list_recharger": {"type": "button", "text_contains": "充能器"},
  "list_vending": {"type": "button", "text_contains": "自动售货机"},
  "list_reactor": {"type": "button", "text_contains": "反应堆"},
  "list_cage": {"type": "button", "text_contains": "动物笼"},
  "list_hydro": {"type": "button", "text_contains": "水培"},
  "list_fridge": {"type": "button", "text_contains": "冰箱"},
  "list_furnace": {"type": "button", "text_contains": "熔炉"},
  "list_printer": {"type": "button", "text_contains": "打印机"}
}
```

- [ ] **Step 2: 夹具**

```gdscript
func open_machines() -> bool:
	if not await driver.tap("main", "btn_machines"):
		return false
	return await driver.wait_visible("machines", "btn_close", 5000)

func select_machine(key: String) -> bool:
	var spec: Dictionary = driver.ui_map.get("screens", {}).get("machines", {}).get(key, {})
	var text := String(spec.get("text_contains", ""))
	for i in range(8):
		if text == "" or driver.find_text_contains("machines", text) != null:
			break
		await driver.tap("machines", "btn_scroll_down")
	if not await driver.tap("machines", key):
		return false
	return await driver.wait_visible("machines", "title", 3000)
```

`ui_map` 中的 `list_*` key 用于 `select_machine("list_furnace")`。

- [ ] **Step 3: 写 `machine_flow.gd`**

```gdscript
# [L2 执行层] machine_flow.gd — 机器面板逐步检查
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)

func run() -> void:
	check(await fixtures.open_machines(), "machines open")
	check(await fixtures.select_machine("list_printer"), "printer selected")
	check(driver.read_text("machines", "io").contains("配方"), "printer io text")
	await shot("machine_printer")
	check(await fixtures.select_machine("list_recharger"), "recharger selected")
	check(driver.is_visible("machines", "btn_aux"), "recharger aux button")
	check(driver.is_visible("machines", "btn_special"), "recharger special button")
	await shot("machine_recharger")
	check(await fixtures.select_machine("list_vending"), "vending selected")
	check(driver.is_visible("machines", "btn_stock"), "vending stock button")
	check(await driver.tap("machines", "btn_aux"), "toggle vending active")
	await shot("machine_vending")
	check(await fixtures.select_machine("list_reactor"), "reactor selected")
	check(driver.read_text("machines", "btn_special").contains("维修"), "reactor special label")
	check(await fixtures.select_machine("list_cage"), "cage selected")
	check(driver.is_visible("machines", "btn_special"), "cage special button")
	check(await fixtures.select_machine("list_hydro"), "hydro selected")
	check(driver.read_text("machines", "io").contains("配方"), "hydro recipe text")
	check(await fixtures.select_machine("list_fridge"), "fridge selected")
	check(driver.is_visible("machines", "btn_stock_grid"), "fridge stock grid button")
	check(await driver.tap("machines", "btn_stock_grid"), "open fridge grid")
	check(await driver.wait_visible("container", "title", 3000), "fridge container open")
	await shot("fridge_grid")
	await driver.tap("container", "btn_close")
	check(await fixtures.select_machine("list_furnace"), "furnace selected")
	check(driver.is_visible("machines", "btn_io_in"), "furnace input button")
	check(driver.is_visible("machines", "btn_io_out"), "furnace output button")
	check(await driver.tap("machines", "btn_io_in"), "open furnace input")
	check(await driver.wait_visible("container", "title", 3000), "furnace input open")
	await shot("furnace_input")
	await driver.tap("container", "btn_close")
	check(await driver.tap("machines", "btn_close"), "close machines")
```

`ui_map` 需增加 `container.title` / `container.btn_close`（Task 13 也会用）：

```json
"container": {
  "title": {"type": "label", "property": "container_title"},
  "info": {"type": "label", "property": "container_info"},
  "btn_close": {"type": "button", "text": "关闭"}
}
```

- [ ] **Step 4: 注册并验证**

```bash
python tests/run.py --suite ui --filter ui/machine_flow --update-baselines
python tests/run.py --suite ui --filter ui/machine_flow
```

Expected：PASS；截图基线生成。

- [ ] **Step 5: 删除 `--testmachineui`**

删除 `_testmachineui_if_requested()` 及调用。

- [ ] **Step 6: 提交（经用户授权后）**

```bash
git add tests scripts/main.gd
git commit -m "test: migrate machine panel flow"
```

---

### Task 13: 迁移 `--testcontainerui` 并验证跨面板拖拽

**Files:**
- Modify: `scripts/main.gd`（背包/容器/展示柜图标 name；`_finish_drag` 接收释放坐标）
- Modify: `tests/control/ui_map.json`
- Modify: `tests/execution/fixtures.gd`
- Modify: `tests/execution/suites.json`
- Create: `tests/execution/cases/ui/container_flow.gd`

**Interfaces:**
- Consumes: driver/fixtures。
- Produces: `driver.tap_item_def(def_id) -> bool`、`driver.drag_item_to_container(uid, gx, gy) -> bool`、`driver.drag_container_item_to_main(uid, gx, gy) -> bool`（`tap_item_uid` 已在 Task 3 提供）。

- [ ] **Step 1: 生产改动（只改坐标来源，不改行为）**

`scripts/main.gd`：

1. 容器图标（约 1212 行 `var cuid := int(ch.get("uid", -1))` 后）加 `icon.name = "container_item_%d" % cuid`（背包图标 name 已在 Task 3 加过）；
2. 展示柜图标（约 1386 行附近）加 `icon.name = "showcase_item_%d" % uid`；
3. `_on_drag_gui_input` 的释放分支改为：

```gdscript
if did_drag:
	_finish_drag(uid, source, event.global_position)
```

4. `_finish_drag` 签名改为 `func _finish_drag(uid: int, source: String, mouse: Vector2) -> void:`，删除函数内 `var mouse := get_global_mouse_position()`。

- [ ] **Step 2: 驱动增加物品定位与拖拽**

先在 `ui_map.json` 的 `screens.main` 增加：

```json
"detail_open_btn": {"type": "button", "property": "detail_open_btn"}
```

```gdscript
func tap_item_def(def_id: String) -> bool:
	var gs = root.get_node("/root/GameState")
	for it in gs.inventory:
		if String(it.get("def_id", "")) == def_id:
			return await tap_item_uid(int(it["uid"]))
	return false

func drag_item_to_container(uid: int, gx: int, gy: int) -> bool:
	var item := root.find_child("item_%d" % uid, true, false) as Control
	var grid := root.get("container_grid") as Control
	if item == null or grid == null:
		return false
	var pos := grid.global_position + Vector2(gx * 50 + 16, gy * 50 + 16)
	return await drag_between(item, pos)

func drag_container_item_to_main(uid: int, gx: int, gy: int) -> bool:
	var item := root.find_child("container_item_%d" % uid, true, false) as Control
	var grid := root.get("grid_root") as Control
	if item == null or grid == null:
		return false
	var pos := grid.global_position + Vector2(gx * 58 + 27, gy * 58 + 27)
	return await drag_between(item, pos)
```

- [ ] **Step 3: 写 `container_flow.gd`**

```gdscript
# [L2 执行层] container_flow.gd — 打开容器、拖入、拖回、关闭
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)

func run() -> void:
	var bag := state.make_item("backpack_large", 100, true, false)
	var fruit := state.make_item("nutrifruit", 100, true, false)
	state.add_item(bag)
	state.add_item(fruit)
	state.emit_signal("state_changed")
	await driver.root.get_tree().process_frame
	check(await driver.tap_item_uid(int(bag.uid)), "select backpack")
	check(await driver.tap("main", "detail_open_btn"), "open backpack")
	check(await driver.wait_visible("container", "title", 3000), "container open")
	check(driver.read_text("container", "title").contains("容器"), "container title")
	await shot("container_open")
	var before := int(bag.children.size())
	check(await driver.drag_item_to_container(int(fruit.uid), 2, 2), "drag fruit in")
	await driver.root.get_tree().process_frame
	var after := int(bag.children.size())
	check_eq(after, before + 1, "child count +1")
	await shot("container_dragged_in")
	check(await driver.drag_container_item_to_main(int(fruit.uid), 1, 1), "drag fruit back")
	await driver.root.get_tree().process_frame
	check_eq(state.find_item(int(fruit.uid)).get("location", "backpack"), "backpack", "fruit back")
	await shot("container_dragged_back")
	await driver.tap("container", "btn_close")
	check(not driver.is_visible("container", "title"), "container closed")
```

- [ ] **Step 4: 注册并验证**

`suites.json` 增加 `ui/container_flow`，seed 20261117，tags `["smoke", "container"]`。

```bash
python tests/run.py --suite ui --filter ui/container_flow --update-baselines
python tests/run.py --suite ui --filter ui/container_flow
```

Expected：PASS；拖拽双向成功；若失败，先看 `_finish_drag` 是否拿到释放坐标，再核对 `container_grid`/`grid_root` 名称。

- [ ] **Step 5: 删除 `--testcontainerui`**

删除 `_testcontainerui_if_requested()` 及调用。

- [ ] **Step 6: 提交（经用户授权后）**

```bash
git add tests scripts/main.gd
git commit -m "test: migrate container drag flow"
```

---

### Task 14: 档案/剧情流程、诊断用例，并移除剩余调试分支

**Files:**
- Modify: `tests/control/ui_map.json`
- Modify: `tests/execution/suites.json`
- Modify: `scripts/main.gd`（删除 `_capture_if_requested`、`_dumpui_if_requested`、`_audioinfo_if_requested` 及调用）
- Create: `tests/execution/cases/ui/archive_flow.gd`
- Create: `tests/execution/cases/ui/story_flow.gd`
- Create: `tests/execution/cases/diagnostics/audio_paths.gd`

**Interfaces:**
- Consumes: driver/fixtures。
- Produces: 档案页、剧情弹窗、音频路径三类用例；`main.gd` 中不再存在 `--capture*` / `--dump*` / `--audioinfo`。

- [ ] **Step 1: 扩展 `ui_map.json`**

```json
"info": {
  "title": {"type": "label", "property": "info_title"},
  "list": {"type": "node", "property": "info_list_box"},
  "tab_archive": {"type": "button", "text": "档案", "scope": "info_layer"},
  "btn_close": {"type": "button", "text": "关闭", "scope": "info_layer"}
},
"story": {
  "btn_continue": {"type": "button", "text": "继续"}
}
```

档案列表项是 Button（文本含"剧情顾客 · 463"），直接使用 Task 2 已实现的 `driver.find_text_contains("info", "剧情顾客")`。

- [ ] **Step 2: `archive_flow.gd`**

```gdscript
# [L2 执行层] archive_flow.gd — 打开档案页并验证分组
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)

func run() -> void:
	check(await driver.tap("main", "btn_archive"), "open archive")
	check(await driver.wait_visible("info", "list", 3000), "info list visible")
	if driver.is_visible("info", "tab_archive"):
		await driver.tap("info", "tab_archive")
	await driver.root.get_tree().create_timer(0.2).timeout
	var entry := driver.find_text_contains("info", "剧情顾客") as Button
	check(entry != null, "archive group found")
	if entry != null:
		check(entry.text.contains("463") or entry.text.contains("2544"), "archive entry count", entry.text)
	await shot("archive_page")
```

- [ ] **Step 3: `story_flow.gd`**

```gdscript
# [L2 执行层] story_flow.gd — 开局剧情弹窗与推进
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value, false)

func run() -> void:
	check(driver.is_visible("story", "layer"), "story visible at boot")
	var before := int(state.scene_seen.size())
	await fixtures.skip_story()
	check(not driver.is_visible("story", "layer"), "story closed")
	check(driver.is_visible("main", "day_label"), "back to main")
	check(int(state.scene_seen.size()) > before, "scene marked seen")
```

`boot_to_main` 的签名必须同步改为：

```gdscript
func boot_to_main(difficulty := "normal", mode := "mobile", seed_value := 20261117, skip_story_after := true) -> bool:
	# ... 原有逻辑 ...
	if skip_story_after:
		await skip_story()
	await close_modal()
	return await driver.wait_visible("main", "day_label", 5000)
```

- [ ] **Step 4: 音频诊断用例**

```gdscript
# [L2 执行层] audio_paths.gd — 音频路径解析诊断
extends "res://tests/execution/case.gd"

func run() -> void:
	var main = driver.root
	for id in ["music_main", "ambience_station", "sfx_click"]:
		var path: String = main.call("_audio_path", id + ".ogg")
		check(path != "", "audio path " + id, path)
		check(FileAccess.file_exists(path), "audio exists " + id, path)
```

- [ ] **Step 5: 注册并验证**

`suites.json` 增加：

```json
{"id": "ui/archive_flow", "file": "cases/ui/archive_flow.gd", "platform": "desktop", "runner": "ui", "seed": 20261117, "tags": ["smoke"]},
{"id": "ui/story_flow", "file": "cases/ui/story_flow.gd", "platform": "desktop", "runner": "ui", "seed": 20261117, "tags": ["story"]},
{"id": "diagnostics/audio_paths", "file": "cases/diagnostics/audio_paths.gd", "platform": "desktop", "runner": "ui", "seed": 20261117, "tags": ["diagnostics"]}
```

运行三个用例（`archive_flow` 需先 `--update-baselines`）。

- [ ] **Step 6: 删除剩余调试分支**

删除 `main.gd` 中 `_capture_if_requested`、`_dumpui_if_requested`、`_audioinfo_if_requested` 及 `_ready()` 中对应调用。保留 `--publicassets` 和音频初始化。

```bash
grep -n "autotest\|--test\|--capture\|--dump\|--audioinfo" scripts/main.gd
```

Expected：无命中。

- [ ] **Step 7: 提交（经用户授权后）**

```bash
git add tests scripts/main.gd
git commit -m "test: migrate archive, story and diagnostics; drop debug branches"
```

---

### Task 15: 回归结论层（报告、参考运行、退出码）

**Files:**
- Create: `tests/verdict/report.py`
- Create: `tests/verdict/known_failures.json`（`[]`）
- Create: `tests/verdict/test_report.py`
- Modify: `tests/run.py`

**Interfaces:**
- Consumes: 所有 runner 的标准结果 dict。
- Produces:
  - `summarize(results: list[dict], reference: dict | None, known: list[dict], env: dict) -> dict`
  - `write_reports(run_dir: Path, results: list[dict], summary: dict) -> None`
  - `exit_code(summary: dict) -> int`

- [ ] **Step 1: 先写失败的结论层单测**

`tests/verdict/test_report.py`：

```python
import unittest
from tests.verdict.report import summarize, exit_code

def case(cid, status, assertions=None):
    return {"id": cid, "status": status, "assertions": assertions or [], "shots": []}

class VerdictTest(unittest.TestCase):
    def test_all_pass(self):
        s = summarize([case("logic/a", "PASS")], None, [], {})
        self.assertEqual(s["conclusion"], "回归通过")
        self.assertEqual(exit_code(s), 0)

    def test_new_regression(self):
        ref = {"cases": [{"id": "logic/a", "status": "PASS"}]}
        s = summarize([case("logic/a", "FAIL", [{"label": "x", "ok": False}])], ref, [], {})
        self.assertEqual(s["new_regressions"][0]["id"], "logic/a")
        self.assertEqual(exit_code(s), 1)

    def test_known_failure_not_counted(self):
        s = summarize([case("logic/a", "FAIL", [{"label": "x", "ok": False}])], None,
                      [{"case": "logic/a", "assertion": "x", "issue": "ISSUE-1"}], {})
        self.assertEqual(len(s["known_failures"]), 1)
        self.assertEqual(len(s["new_regressions"]), 0)
        self.assertEqual(exit_code(s), 0)

    def test_skip_is_not_failure(self):
        s = summarize([case("device/a", "SKIP")], None, [], {})
        self.assertEqual(exit_code(s), 0)

    def test_fail_without_reference_is_failure_not_new(self):
        s = summarize([case("logic/a", "FAIL", [{"label": "x", "ok": False}])], None, [], {})
        self.assertEqual(len(s["new_regressions"]), 0)
        self.assertEqual(s["failures"][0]["id"], "logic/a")
        self.assertEqual(exit_code(s), 1)

    def test_error_exit_2(self):
        s = summarize([case("logic/a", "ERROR")], None, [], {})
        self.assertEqual(exit_code(s), 2)

if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: 跑单测确认失败**

```bash
python -m unittest tests.verdict.test_report -v
```

Expected：ModuleNotFoundError / summarize 未定义。

- [ ] **Step 3: 实现 `report.py`**

```python
#!/usr/bin/env python3
# [L4 回归结论层] report.py — 汇总、参考运行对比、报告、退出码
import json
from pathlib import Path

def _known_match(case, known):
    hits = []
    for item in known:
        if item.get("case") != case.get("id"):
            continue
        assertion = item.get("assertion", "")
        labels = [a.get("label", "") for a in case.get("assertions", []) if not a.get("ok")]
        if assertion == "" or assertion in labels:
            hits.append(item)
    return hits

def summarize(results, reference, known, env):
    new_regressions, known_hits, skips, errors, failures = [], [], [], [], []
    ref_map = {c["id"]: c for c in (reference or {}).get("cases", [])}
    counts = {"pass": 0, "fail": 0, "error": 0, "skip": 0, "flaky": 0}
    for case in results:
        status = case.get("status", "ERROR")
        if status == "PASS":
            counts["pass"] += 1
        elif status == "FLAKY":
            counts["flaky"] += 1
        elif status == "SKIP":
            counts["skip"] += 1; skips.append(case)
        elif status == "ERROR":
            counts["error"] += 1; errors.append(case)
        else:
            counts["fail"] += 1
            hits = _known_match(case, known)
            first = next((a for a in case.get("assertions", []) if not a.get("ok")), None)
            info = {"id": case["id"], "first_failure": (first or {}).get("label", "")}
            if hits:
                known_hits.append({"id": case["id"], "issues": [h.get("issue", "") for h in hits]})
            elif reference is None:
                failures.append(info)
            elif ref_map.get(case["id"], {}).get("status", "PASS") == "PASS":
                new_regressions.append(info)
            else:
                info["first_failure"] = info["first_failure"] or "continued failure"
                failures.append(info)
    parts = []
    if new_regressions:
        parts.append("新增回归 %d" % len(new_regressions))
    if failures:
        parts.append("失败 %d" % len(failures))
    if known_hits:
        parts.append("已知问题 %d" % len(known_hits))
    if errors:
        parts.append("环境/框架错误 %d" % len(errors))
    if skips:
        parts.append("环境阻断 %d" % len(skips))
    conclusion = " / ".join(parts) if parts else "回归通过"
    return {"conclusion": conclusion, "counts": counts,
            "new_regressions": new_regressions, "failures": failures,
            "known_failures": known_hits,
            "skips": [{"id": c["id"]} for c in skips],
            "errors": [{"id": c["id"]} for c in errors],
            "environment": env}

def exit_code(summary):
    if summary["errors"]:
        return 2
    if summary["new_regressions"] or summary.get("failures"):
        return 1
    return 0

def write_reports(run_dir: Path, results, summary):
    run_dir.mkdir(parents=True, exist_ok=True)
    report = {"cases": results, **summary}
    (run_dir / "report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    lines = ["# 回归报告", "", "结论：**%s**" % summary["conclusion"], "",
             "| 用例 | 状态 | 失败断言 |", "|---|---|---|"]
    for case in results:
        first = next((a.get("label", "") for a in case.get("assertions", []) if not a.get("ok")), "")
        lines.append("| %s | %s | %s |" % (case.get("id"), case.get("status"), first))
    lines += ["", "## 截图", ""]
    for case in results:
        for s in case.get("shots", []):
            if s.get("status") == "FAIL":
                lines.append("- %s / %s：diff=%s（差异率 %.4f%%）" % (
                    case.get("id"), s.get("name"), s.get("diff_image", ""), float(s.get("diff_ratio", 0)) * 100))
    (run_dir / "report.md").write_text("\n".join(lines), encoding="utf-8")
    (run_dir / "summary.txt").write_text(summary["conclusion"] + "\n", encoding="utf-8")
```

- [ ] **Step 4: 跑单测确认通过**

```bash
python -m unittest tests.verdict.test_report -v
```

Expected：5 个测试 OK。

- [ ] **Step 5: 接入 `run.py`**

`main` 收尾：

```python
def find_reference(history_path, current_run):
    if not history_path.exists():
        return None
    for line in reversed(history_path.read_text(encoding="utf-8").splitlines()):
        if not line.strip():
            continue
        rec = json.loads(line)
        if rec.get("suite") != "full" or rec.get("conclusion") != "回归通过":
            continue
        if rec.get("run_id") == current_run:
            continue
        ref_path = ROOT / "build/qa" / rec["run_id"] / "report.json"
        if ref_path.exists():
            return json.loads(ref_path.read_text(encoding="utf-8"))
    return None

known = json.loads((ROOT / "tests/verdict/known_failures.json").read_text(encoding="utf-8"))
reference = None
if args.reference_run:
    ref_path = ROOT / "build/qa" / args.reference_run / "report.json"
    if ref_path.exists():
        reference = json.loads(ref_path.read_text(encoding="utf-8"))
else:
    reference = find_reference(ROOT / "build/qa" / "history.jsonl", run_id)
summary = summarize(results, reference, known, env)
write_reports(run_dir, results, summary)
with (ROOT / "build/qa" / "history.jsonl").open("a", encoding="utf-8") as f:
    f.write(json.dumps({"run_id": run_id, "suite": args.suite,
                        "conclusion": summary["conclusion"],
                        "counts": summary["counts"]}, ensure_ascii=False) + "\n")
print(summary["conclusion"])
return exit_code(summary)
```

`env` 至少包含 `godot`、`profile`、`device`（若有）、`commit`（`git rev-parse --short HEAD`）。

- [ ] **Step 6: 验证**

```bash
python tests/run.py --suite ui --filter ui/boot_smoke
python -m unittest tests.verdict.test_report -v
```

Expected：`build/qa/<run_id>/report.md` 与 `report.json` 生成；结论"回归通过"；退出码 0。

- [ ] **Step 7: 提交（经用户授权后）**

```bash
git add tests
git commit -m "test: add regression verdict and reporting layer"
```

---

### Task 16: 真机种子钩子、设备驱动与控件坐标生成

**Files:**
- Modify: `scripts/game_state.gd` 的 `_ready()`（当前含 `rng.randomize()`）
- Create: `tests/control/device_driver.py`
- Create: `tests/control/test_device_driver.py`
- Create: `tests/execution/map_builder.gd`
- Modify: `tests/control/desktop_driver.gd`（`dump_screen`）
- Modify: `tests/run.py`（`--build-control-map`）

**Interfaces:**
- Consumes: 桌面 UI 入口、ui_map。
- Produces:
  - `DeviceDriver(serial, adb="adb", ui_map_path=...)`，方法 `device_info/install/clear_data/force_stop/launch/tap_key/drag_key/key/screencap/write_user_file/remove_user_file`
  - `python tests/run.py --build-control-map` 更新 `ui_map.json` 的 `device` 段。

- [ ] **Step 1: 实现种子钩子（唯一生产测试缝）**

`scripts/game_state.gd` 的 `_ready()` 改为：

```gdscript
func _ready() -> void:
	var qa_seed := FileAccess.open("user://qa_seed.txt", FileAccess.READ)
	if qa_seed:
		rng.seed = int(qa_seed.get_as_text().strip_edges())
		qa_seed.close()
		var dir := DirAccess.open("user://")
		if dir:
			dir.remove("qa_seed.txt")
	else:
		rng.randomize()
	_load_defs()
	new_game()
```

- [ ] **Step 2: 桌面驱动增加 `dump_screen`**

```gdscript
func dump_screen(screen: String) -> Dictionary:
	var out := {}
	var view := root.get_viewport().get_visible_rect().size
	for key in ui_map.get("screens", {}).get(screen, {}).keys():
		var c := resolve(screen, key)
		if c == null or not c.is_visible_in_tree():
			continue
		var r := c.get_global_rect()
		out[key] = {"x": r.position.x / view.x, "y": r.position.y / view.y,
					"w": r.size.x / view.x, "h": r.size.y / view.y}
	return out
```

- [ ] **Step 3: 写 `map_builder.gd`**

```gdscript
# [L2 执行层] map_builder.gd — 导航到关键界面并导出语义控件百分比矩形
extends Node

const DesktopDriver = preload("res://tests/control/desktop_driver.gd")
const Fixtures = preload("res://tests/execution/fixtures.gd")

func _ready() -> void:
	var main := load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(0.5).timeout
	var driver := DesktopDriver.new(main)
	var fixtures = Fixtures.new(driver, GameState)
	var out := {}
	seed(20261117)
	GameState.rng.seed = 20261117
	out["welcome"] = driver.dump_screen("welcome")
	await driver.tap("welcome", "btn_normal")
	await driver.wait_visible("tutorial", "btn_skip", 5000)
	out["tutorial"] = driver.dump_screen("tutorial")
	await driver.tap("tutorial", "btn_skip")
	await fixtures.skip_story()
	await fixtures.close_modal()
	await driver.wait_visible("main", "day_label", 5000)
	out["main"] = driver.dump_screen("main")
	out["main"]["detail_open_btn"] = _rect_pct(main.get("detail_open_btn"))
	for def_id in ["backpack_small", "nutrifruit"]:
		var uid := _find_uid(def_id)
		if uid > 0:
			var node := main.find_child("item_%d" % uid, true, false) as Control
			if node != null:
				out["main"]["item." + def_id] = _rect_pct(node)
	await driver.tap("main", "btn_inspect")
	await driver.wait_visible("inspection", "info", 3000)
	out["inspection"] = driver.dump_screen("inspection")
	await driver.tap("inspection", "btn_close")
	await driver.tap("main", "btn_bargain")
	await driver.wait_visible("modal", "btn_quote", 3000)
	out["modal"] = driver.dump_screen("modal")
	await driver.tap("modal", "btn_close")
	await driver.tap("main", "btn_deal")
	await driver.wait_visible("modal", "btn_close", 3000)
	out["modal"].update(driver.dump_screen("modal"))
	await driver.tap("modal", "btn_close")
	if _find_uid("backpack_small") > 0:
		await driver.tap_item_def("backpack_small")
		await driver.tap("main", "detail_open_btn")
		await driver.wait_visible("container", "title", 3000)
		out["container"] = driver.dump_screen("container")
		var grid: Control = main.get("container_grid")
		out["container"]["cell_2_2"] = _rect_pct_rect(Rect2(grid.global_position + Vector2(2 * 50, 2 * 50), Vector2(42, 42)))
		await driver.tap("container", "btn_close")
	await fixtures.open_machines()
	out["machines"] = driver.dump_screen("machines")
	await fixtures.select_machine("list_furnace")
	out["machines_detail"] = driver.dump_screen("machines")
	out["machines"].update(out["machines_detail"])
	await driver.tap("machines", "btn_close")
	await driver.tap("main", "btn_archive")
	await get_tree().create_timer(0.2).timeout
	out["info"] = driver.dump_screen("info")
	await driver.tap("info", "btn_close")
	await driver.tap("main", "btn_end_day")
	await driver.wait_visible("modal", "btn_next_day", 3000)
	out["modal"].update(driver.dump_screen("modal"))
	var out_path := _arg(OS.get_cmdline_user_args(), "--qa-out", "user://control_map.json")
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(out, "\t"))
	get_tree().quit(0)

func _find_uid(def_id: String) -> int:
	for it in GameState.inventory:
		if String(it.get("def_id", "")) == def_id:
			return int(it["uid"])
	return -1

func _rect_pct(c: Control) -> Dictionary:
	if c == null:
		return {}
	return _rect_pct_rect(c.get_global_rect())

func _rect_pct_rect(r: Rect2) -> Dictionary:
	var view := get_viewport().get_visible_rect().size
	return {"x": r.position.x / view.x, "y": r.position.y / view.y,
			"w": r.size.x / view.x, "h": r.size.y / view.y}

func _arg(args: PackedStringArray, name: String, fallback: String) -> String:
	for a in args:
		if a.begins_with(name + "="):
			return a.substr(name.length() + 1)
	return fallback
```

- [ ] **Step 4: 写 `device_driver.py`**

```python
#!/usr/bin/env python3
# [L1 控件层] device_driver.py — ADB 控件操作、设备生命周期、坐标换算
import json
import subprocess
from pathlib import Path
from PIL import Image

class DeviceError(Exception): pass
class DeviceOffline(DeviceError): pass
class Unauthorized(DeviceError): pass
class CommandTimeout(DeviceError): pass
class UnsupportedCapability(DeviceError): pass

PACKAGE = "com.caiyipeng.probablystolen.mobile"

class DeviceDriver:
    def __init__(self, serial="", adb="adb", ui_map_path=None):
        self.serial = serial
        self.adb = adb
        self.ui_map_path = ui_map_path
        self._map = json.loads(Path(ui_map_path).read_text(encoding="utf-8")) if ui_map_path else {}
        self._info = None

    def _run(self, args, timeout=30, binary=False):
        cmd = [self.adb] + (["-s", self.serial] if self.serial else [])
        try:
            proc = subprocess.run(cmd + args, capture_output=True, timeout=timeout)
        except subprocess.TimeoutExpired as e:
            raise CommandTimeout(str(e))
        if proc.returncode != 0:
            err = proc.stderr.decode("utf-8", "replace")
            if "device offline" in err: raise DeviceOffline(err)
            if "unauthorized" in err: raise Unauthorized(err)
            raise DeviceError(err)
        return proc.stdout if binary else proc.stdout.decode("utf-8", "replace")

    def device_info(self):
        if self._info: return self._info
        model = self._run(["shell", "getprop", "ro.product.model"]).strip()
        android = self._run(["shell", "getprop", "ro.build.version.release"]).strip()
        png = self._run(["exec-out", "screencap", "-p"], binary=True)
        import io
        size = Image.open(io.BytesIO(png)).size
        self._info = {"model": model, "android": android, "width": size[0], "height": size[1],
                      "profile": "device-%s-%dx%d-%s" % (model, size[0], size[1], android)}
        return self._info

    def install(self, apk): self._run(["install", "-r", "-t", str(apk)], timeout=180)
    def clear_data(self): self._run(["shell", "pm", "clear", PACKAGE])
    def force_stop(self): self._run(["shell", "am", "force-stop", PACKAGE])
    def launch(self):
        self._run(["shell", "am", "start", "-W", "-a", "android.intent.action.MAIN",
                   "-c", "android.intent.category.LAUNCHER", "-p", PACKAGE])
    def key(self, code): self._run(["shell", "input", "keyevent", str(code)])

    def _coord(self, key):
        info = self.device_info()
        rect = self._map.get("device", {}).get(key)
        if not rect:
            raise DeviceError("no device map for " + key)
        x = int((rect["x"] + rect["w"] / 2) * info["width"])
        y = int((rect["y"] + rect["h"] / 2) * info["height"])
        return x, y

    def tap_key(self, key):
        x, y = self._coord(key)
        self._run(["shell", "input", "tap", str(x), str(y)])

    def drag_key(self, from_key, to_key, duration_ms=400):
        x1, y1 = self._coord(from_key); x2, y2 = self._coord(to_key)
        self._run(["shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(duration_ms)])

    def screencap(self, dest):
        png = self._run(["exec-out", "screencap", "-p"], binary=True)
        Path(dest).parent.mkdir(parents=True, exist_ok=True)
        Path(dest).write_bytes(png)

    def write_user_file(self, name, text):
        proc = subprocess.run([self.adb] + (["-s", self.serial] if self.serial else []) +
                              ["shell", "run-as", PACKAGE, "sh", "-c",
                               "mkdir -p files && cat > files/%s" % name],
                              input=text.encode(), capture_output=True)
        if proc.returncode != 0:
            raise DeviceError(proc.stderr.decode("utf-8", "replace"))

    def remove_user_file(self, name):
        self._run(["shell", "run-as", PACKAGE, "rm", "-f", "files/" + name])
```

`write_user_file` 直接用 stdin 写 `run-as`，避免 `/data/local/tmp` 权限问题；删除未使用的 `tmp` 变量。

- [ ] **Step 5: 写设备驱动单测（坐标换算）**

```python
import json, tempfile, unittest
from pathlib import Path
from unittest.mock import patch
from tests.control.device_driver import DeviceDriver

class CoordTest(unittest.TestCase):
    def test_percent_to_pixels(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "ui_map.json"
            p.write_text(json.dumps({"device": {"x": {"x": 0.5, "y": 0.5, "w": 0.1, "h": 0.1}}}), encoding="utf-8")
            drv = DeviceDriver(ui_map_path=str(p))
            drv._info = {"model": "SM-S9280", "android": "16", "width": 2340, "height": 1080,
                         "profile": "device-SM-S9280-2340x1080-16"}
            self.assertEqual(drv._coord("x"), (1287, 594))
```

- [ ] **Step 6: 实现 `--build-control-map` 与合并**

`run.py` 增加：

```python
def run_map_builder(run_dir: pathlib.Path) -> int:
    out_path = run_dir / "control_map.json"
    cmd = [GODOT, "--path", str(ROOT), "tests/execution/map_builder.tscn", "--",
           "--qa-out=" + str(out_path)]
    proc = subprocess.run(cmd, cwd=ROOT, timeout=120)
    if not out_path.exists():
        print("control_map.json not found:", out_path); return 2
    data = json.loads(out_path.read_text(encoding="utf-8"))
    ui_map_path = ROOT / "tests/control/ui_map.json"
    ui_map = json.loads(ui_map_path.read_text(encoding="utf-8"))
    ui_map["device"] = {**ui_map.get("device", {}), **{f"{screen}.{key}": v for screen, keys in data.items() for key, v in keys.items()}}
    ui_map_path.write_text(json.dumps(ui_map, ensure_ascii=False, indent=2), encoding="utf-8")
    print("updated", ui_map_path)
    return 0
```

`map_builder.tscn` 与 `ui_entry.tscn` 同构（Node + script）。`main` 中 `if args.build_control_map: return run_map_builder(run_dir)`（`run_dir` 用时间戳创建）。

- [ ] **Step 7: 验证**

```bash
python -m unittest tests.control.test_device_driver -v
python tests/run.py --build-control-map
python -c "import json; m=json.load(open('tests/control/ui_map.json')); print(len(m['device']))"
adb -s R5CX211TXNT shell run-as com.caiyipeng.probablystolen.mobile ls files
```

Expected：单测 OK；ui_map `device` 段非空；`run-as` 可执行（debug APK）。

- [ ] **Step 8: 提交（经用户授权后）**

```bash
git add tests scripts/game_state.gd
git commit -m "test: add device driver, seed hook and control map export"
```

---

### Task 17: 真机执行器与 5 条冒烟流程

**Files:**
- Create: `tests/execution/device_runner.py`
- Create: `tests/execution/cases/device/launch_smoke.json`
- Create: `tests/execution/cases/device/trade_smoke.json`
- Create: `tests/execution/cases/device/machine_smoke.json`
- Create: `tests/execution/cases/device/container_smoke.json`
- Create: `tests/execution/cases/device/day_end_smoke.json`
- Modify: `tests/execution/suites.json`
- Modify: `tests/run.py`

**Interfaces:**
- Consumes: `DeviceDriver`、`compare_image`、ui_map device 段。
- Produces: `run_cases(cases, run_dir, serial, fresh, update_baselines, config) -> list[dict]`。

- [ ] **Step 1: 写声明式流程**

`launch_smoke.json`：

```json
{
  "id": "device/launch_smoke",
  "seed": 20261117,
  "steps": [
    {"action": "wait_screen", "shot": "welcome", "timeout_ms": 15000},
    {"action": "shot", "shot": "welcome"},
    {"action": "tap", "target": "welcome.btn_normal"},
    {"action": "tap", "target": "tutorial.btn_skip"},
    {"action": "wait_screen", "shot": "main_day1", "timeout_ms": 15000},
    {"action": "shot", "shot": "main_day1"}
  ]
}
```

`trade_smoke.json`（seed 20261117 第一位顾客 sell）：

```json
{
  "id": "device/trade_smoke",
  "seed": 20261117,
  "steps": [
    {"action": "tap", "target": "welcome.btn_normal"},
    {"action": "tap", "target": "tutorial.btn_skip"},
    {"action": "wait_screen", "shot": "main_day1", "timeout_ms": 15000},
    {"action": "tap", "target": "main.btn_inspect"},
    {"action": "wait_screen", "shot": "inspect_open", "timeout_ms": 8000},
    {"action": "shot", "shot": "inspect_open"},
    {"action": "tap", "target": "inspection.btn_close"},
    {"action": "tap", "target": "main.btn_bargain"},
    {"action": "wait_screen", "shot": "bargain_modal", "timeout_ms": 8000},
    {"action": "shot", "shot": "bargain_modal"},
    {"action": "tap", "target": "modal.btn_quote"},
    {"action": "tap", "target": "modal.btn_close"},
    {"action": "tap", "target": "main.btn_deal"},
    {"action": "shot", "shot": "deal_result"},
    {"action": "tap", "target": "modal.btn_close"}
  ]
}
```

`machine_smoke.json`（只验证机器面板打开与布局，机器详情由桌面 `ui/machine_flow` 深测）：

```json
{
  "id": "device/machine_smoke",
  "seed": 20261117,
  "steps": [
    {"action": "tap", "target": "welcome.btn_normal"},
    {"action": "tap", "target": "tutorial.btn_skip"},
    {"action": "wait_screen", "shot": "main_day1", "timeout_ms": 15000},
    {"action": "tap", "target": "main.btn_machines"},
    {"action": "wait_screen", "shot": "machines", "timeout_ms": 8000},
    {"action": "shot", "shot": "machines"},
    {"action": "tap", "target": "machines.btn_close"}
  ]
}
```

`container_smoke.json`（使用 Task 16 生成的 `main.item.backpack_small` / `main.item.nutrifruit` / `container.cell_2_2` 坐标）：

```json
{
  "id": "device/container_smoke",
  "seed": 20261117,
  "steps": [
    {"action": "tap", "target": "welcome.btn_normal"},
    {"action": "tap", "target": "tutorial.btn_skip"},
    {"action": "wait_screen", "shot": "main_day1", "timeout_ms": 15000},
    {"action": "tap", "target": "main.item.backpack_small"},
    {"action": "tap", "target": "main.detail_open_btn"},
    {"action": "wait_screen", "shot": "container_open", "timeout_ms": 8000},
    {"action": "drag", "from": "main.item.nutrifruit", "to": "container.cell_2_2", "duration_ms": 600},
    {"action": "shot", "shot": "container_dragged"},
    {"action": "tap", "target": "container.btn_close"}
  ]
}
```

`day_end_smoke.json`：

```json
{
  "id": "device/day_end_smoke",
  "seed": 20261117,
  "steps": [
    {"action": "tap", "target": "welcome.btn_normal"},
    {"action": "tap", "target": "tutorial.btn_skip"},
    {"action": "wait_screen", "shot": "main_day1", "timeout_ms": 15000},
    {"action": "tap", "target": "main.btn_end_day"},
    {"action": "wait_screen", "shot": "day_summary", "timeout_ms": 8000},
    {"action": "shot", "shot": "day_summary"},
    {"action": "tap", "target": "modal.btn_next_day"},
    {"action": "wait_screen", "shot": "main_day2", "timeout_ms": 8000},
    {"action": "shot", "shot": "main_day2"}
  ]
}
```

ui_map `device` 段需要 `main.item.backpack_small`、`main.item.nutrifruit`、`container.cell_2_2`、`main.detail_open_btn` 等 key；Task 16 的 map builder 需为背包物品与展示柜/详情按钮生成坐标。若某个 key 缺失，`DeviceDriver._coord` 抛 `DeviceError`，报告为 ERROR 并提示重新生成控件表。

- [ ] **Step 2: 写 `device_runner.py`**

```python
#!/usr/bin/env python3
# [L2 执行层] device_runner.py — 真机声明式流程执行与稳定帧截图
import time
from pathlib import Path
from PIL import Image, ImageChops
from tests.control.device_driver import DeviceDriver, DeviceError
from tests.screenshot.compare import compare_image, load_config

def _stable_shot(driver, dest, timeout=10):
    last = None
    deadline = time.time() + timeout
    while time.time() < deadline:
        driver.screencap(dest)
        img = Image.open(dest).convert("RGB")
        if last is not None and ImageChops.difference(last, img).getbbox() is None:
            return True
        last = img
        time.sleep(0.2)
    return False

def _wait_screen(driver, case, index, shot_name, profile, baselines_root, run_dir,
                 config, update, timeout_ms):
    name = "%02d_%s" % (index, shot_name)
    dest = run_dir / "device" / case["id"].replace("/", "_") / (name + ".png")
    baseline = baselines_root / profile / case["id"] / (name + ".png")
    if update or not baseline.exists():
        _stable_shot(driver, dest, timeout=3)
        if update:
            return {"name": name, "file": str(dest), "status": "PENDING"}
        raise DeviceError("missing wait_screen baseline: " + name)
    cfg = dict(config.get("defaults", {}))
    cfg.update(config.get("profiles", {}).get(profile, {}))
    deadline = time.time() + timeout_ms / 1000.0
    while time.time() < deadline:
        _stable_shot(driver, dest, timeout=3)
        res = compare_image(dest, baseline, None, cfg)
        if res["status"] == "PASS":
            return {"name": name, "file": str(dest), "status": "PENDING"}
        time.sleep(0.3)
    raise DeviceError("wait_screen timeout: " + shot_name)

def run_cases(cases, run_dir, serial, fresh, update_baselines, apk=None):
    driver = DeviceDriver(serial=serial, ui_map_path="tests/control/ui_map.json")
    if apk:
        driver.install(apk)
    info = driver.device_info()
    profile = info["profile"]
    if not fresh:
        return [{"id": c["id"], "status": "SKIP", "error": "requires --fresh-device",
                 "assertions": [], "shots": [], "steps": []} for c in cases]
    config = load_config(Path(__file__).resolve().parent.parent / "screenshot/config.json")
    baselines_root = Path(__file__).resolve().parents[2] / "tests/baselines"
    results = []
    for case in cases:
        driver.force_stop()
        driver.clear_data()
        driver.launch()          # 首次启动创建 files/ 目录
        time.sleep(3)
        driver.force_stop()
        driver.write_user_file("qa_seed.txt", str(case.get("seed", 20261117)))
        driver.launch()
        time.sleep(3)
        shots, steps, error = [], [], ""
        try:
            for i, step in enumerate(case["steps"], 1):
                action = step["action"]
                if action == "tap":
                    driver.tap_key(step["target"]); time.sleep(0.5)
                elif action == "drag":
                    driver.drag_key(step["from"], step["to"], int(step.get("duration_ms", 400))); time.sleep(0.8)
                elif action == "wait_screen":
                    shot = _wait_screen(driver, case, i, step["shot"], profile, baselines_root,
                                        run_dir, config, update_baselines,
                                        int(step.get("timeout_ms", 10000)))
                    shots.append(shot)
                    steps.append({"title": "wait_screen:" + step["shot"]})
                elif action == "shot":
                    name = "%02d_%s" % (i, step["shot"])
                    dest = run_dir / "device" / case["id"].replace("/", "_") / (name + ".png")
                    _stable_shot(driver, dest)
                    shots.append({"name": name, "file": str(dest), "status": "PENDING"})
                    steps.append({"title": "shot:" + step["shot"]})
                else:
                    raise DeviceError("unknown action " + action)
        except DeviceError as e:
            error = str(e)
        results.append({"id": case["id"], "status": "ERROR" if error else "PASS",
                        "error": error, "assertions": [], "shots": shots, "steps": steps})
    return results, profile
```

`wait_screen` 在更新模式且基线不存在时只做固定稳定等待；验证模式必须循环比对到 PASS，超时 ERROR。`shot` 的 PENDING 由 `process_results` 回填。

- [ ] **Step 3: 注册设备流程并接入 `run.py`**

`suites.json` 增加 5 条 `runner: "device"`、`platform: "device"`、`tags: ["smoke"]`（container 加 `container`）。

`run.py` 的 `--suite device/full/smoke` 分支：

```python
def latest_apk():
    apks = sorted((ROOT / "build").glob("probably_stolen_*.apk"), key=lambda p: p.stat().st_mtime, reverse=True)
    return apks[0] if apks else None

def device_available(serial):
    cmd = ["adb"] + (["-s", serial] if serial else []) + ["get-state"]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return proc.returncode == 0 and "device" in proc.stdout

if args.suite in ("device", "full", "smoke") and any(c.get("runner") == "device" for c in cases):
    from tests.execution.device_runner import run_cases
    from tests.screenshot.compare import load_config, process_results
    device_cases = [c for c in cases if c.get("runner") == "device"]
    serial_ok = device_available(args.serial)
    if not serial_ok:
        if args.require_device:
            return 2
        results += [{"id": c["id"], "status": "SKIP", "error": "device offline",
                     "assertions": [], "shots": [], "steps": []} for c in device_cases]
    else:
        apk = pathlib.Path(args.apk) if args.apk else latest_apk()
        device_results, device_profile = run_cases(device_cases, run_dir, args.serial,
                                                   args.fresh_device, args.update_baselines, apk)
        device_results = process_results(device_results, device_profile, ROOT / "tests/baselines",
                                         run_dir, update=args.update_baselines,
                                         config=load_config(ROOT / "tests/screenshot/config.json"))
        results += device_results
```

设备检测：`adb devices` 中找不到目标序列号 → 设备用例 SKIP；`--require-device` → 返回 2。设备结果截图同样经过 `process_results`，profile 用 `device_info.profile`。

设备 FLAKY：若某条设备用例仅因截图 FAIL，使用同一 case 再调用一次 `run_cases([case], run_dir, ...)`（重新 fresh 启动并重比基线）；第二次 PASS 时把原结果 `status` 改为 `FLAKY`、`retry_passed=True`，保留首次 diff 证据。两次都 FAIL 才维持 FAIL。

- [ ] **Step 4: 设备验证**

```bash
adb devices
python tests/run.py --suite device --serial R5CX211TXNT --fresh-device --update-baselines
python tests/run.py --suite device --serial R5CX211TXNT --fresh-device
python tests/run.py --suite device --serial R5CX211TXNT
python tests/run.py --suite device --serial R5CX211TXNT --fresh-device --require-device
```

Expected：首轮生成 `tests/baselines/device-SM-S9280-2340x1080-16/...`；第二轮全部 PASS；未带 `--fresh-device` 全部 SKIP 且退出码 0；最后一条设备在线时 PASS，拔线时 2。设备基线只需在该机型/Android 版本上维护。

- [ ] **Step 5: 提交（经用户授权后）**

```bash
git add tests
git commit -m "test: add device runner and smoke flows"
```

---

### Task 18: 清理、文档与全量验收

**Files:**
- Delete: `scripts/test_*.gd`（22 个，迁移完成后）
- Modify: `README.md`（构建/测试章节）
- Modify: `tests/README.md`（最终维护手册）
- Verify: `export_presets.cfg`、`tests/**`、APK

**Interfaces:**
- Consumes: 全部前序任务。
- Produces: 可长期维护的框架、全绿基线、更新后的文档。

- [ ] **Step 1: 删除旧脚本**

确认所有用例都已迁入 `tests/execution/cases/logic/` 并在套件清单注册后，删除已提交的旧脚本（保留未跟踪的 `test_barter.gd` 直到 Task 8B 验证通过）：

```bash
git ls-files 'scripts/test_*.gd' | wc -l    # 22
git ls-files -z 'scripts/test_*.gd' 'scripts/test_*.gd.uid' | xargs -0 rm -f
# Task 8B 完成并经确认后，再删除 barter 旧文件：
rm -f scripts/test_barter.gd scripts/test_barter.gd.uid
```

- [ ] **Step 2: 更新 README**

`README.md` 的"构建"章节替换为：

```bash
# 逻辑回归（headless）
python tests/run.py --suite logic

# 桌面 UI + 截图基线
python tests/run.py --suite ui

# 真机冒烟（会清空应用数据，需显式开关）
python tests/run.py --suite device --serial R5CX211TXNT --fresh-device

# 全套
python tests/run.py --suite full --fresh-device
```

删除 `--autotest` / `--capture` / `--dumpinspect` 的说明；保留 `--publicassets`。

`tests/README.md` 最终版加入：四层职责表、命令、能力矩阵、维护手册（新增用例、控件改版、更新基线、已知失败、定位失败）。

- [ ] **Step 3: 全量验证**

```bash
python -m unittest discover -s tests -p "test_*.py" -v
python tests/run.py --suite logic
python tests/run.py --suite ui
python tests/run.py --suite device --serial R5CX211TXNT --fresh-device
python tests/run.py --suite full --fresh-device
```

Expected：单元测试全过；逻辑 22 条全过；桌面 UI 全过且截图基线全绿；真机 5 条全过；`full` 退出码 0，`report.md` 结论"回归通过"。

- [ ] **Step 4: APK 隔离验证**

```bash
"$GODOT" --headless --path . --export-debug "Android" build/probably_stolen_m27.apk
ls -lh build/probably_stolen_m27.apk
grep -n "tests/\*" export_presets.cfg
```

Expected：导出成功；APK 体积与 M26 相近（无测试资源膨胀）；导出过滤包含 `tests/*, tests/**`。

- [ ] **Step 5: 手工冒烟**

安装新 APK 到 SM-S9280，手动执行：欢迎页选难度 → 跳过教程 → 鉴定/议价/成交 → 机器面板 → 容器拖拽 → 结束营业。确认与框架跑测前行为一致。

- [ ] **Step 6: 提交（经用户授权后）**

```bash
git add -A
git commit -m "test: finish layered regression framework migration"
```

---

## Self-Review

**Spec coverage：**

| Spec 章节 | 对应任务 |
|---|---|
| 四层目录与唯一入口 | Task 1 |
| 控件层 ui_map / 双后端 / 能力矩阵 | Task 2、16 |
| 执行层 case/fixtures/suites/迁移映射 | Task 2、4-8 |
| 桌面 UI 流程（交易/验货/小游戏/机器/容器/档案/剧情） | Task 3、10-14 |
| 真机声明式冒烟 | Task 17 |
| 截图验证层（稳定帧、全量基线、遮罩、diff、更新） | Task 9 |
| 回归结论层（状态、参考运行、known failures、报告、退出码） | Task 15 |
| 种子钩子与 `--fresh-device` | Task 16、17 |
| 导出隔离与旧分支清理 | Task 1、3、10-14、18 |
| 工作区在途 barter 功能 | Task 8B（逻辑迁移；UI 流程待功能稳定后补） |
| 验收标准 | Task 18 |

**Placeholder scan：** 全部代码步骤均为可直接落地的实现；无 TBD/TODO，无"以后补"描述。工具函数在首次使用的任务中完整给出，后续任务不再重复定义。

**Type consistency：** `driver.tap/read_text/is_visible/wait_visible/drag_between`、`case.check/check_eq/check_text/shot/to_result`、`fixtures.boot_to_main/ensure_customer_intent/end_day/open_machines/select_machine`、`compare_image/process_results`、`summarize/write_reports/exit_code` 在各任务中签名一致。`selected_machine_id`、`machine_jobs`、`minigame_target`、`mix_target`、`dna_target` 均为 `main.gd` 现有字段，已核对。

---

## 实施记录（2026-11-17）

- 工作区：实施在 worktree `E:/Probably Stolen-qa`（分支 `qa-framework`）；主目录 `E:/Probably Stolen` 保持在 `main`，未受本次改动影响。
- 桌面截图实际尺寸为 1280×720（Godot 窗口覆盖尺寸），profile 最终命名为 `desktop-1280x720-win`。
- 真机流程改用欢迎页「原版 1:1」入口：README 记录原版模式第 1 天无剧情，黑盒无需跳过剧情；所有真机流程先 `wait_screen welcome/tutorial` 再点击，降低启动时序抖动。
- 真机数据清空前备份 `files/` 到 `build/qa/device_backup/files.tar`，测试后通过 `adb push + run-as tar xf` 恢复；QA APK 版本码临时提为 1000 以避免降级。
- 实施中发现并修复：买家「议价/成交」按钮被 `intent == "sell"` 误禁（M24 `1e45b5a`），已改为 `intent in ["sell","buy"]`。
- DNA 编辑器当前无 `recipes` 数据，`start_machine` 返回“辅助设备”；`ui/minigame_flow` 只验证序列匹配与小游戏关闭，开机队列待产品补配方。
- barter/wholesale/phone 等主分支在途功能未合入 qa-framework，Task 8B 暂缓。
- 最终验收：`python tests/run.py --suite full --fresh-device --serial R5CX211TXNT --apk build/probably_stolen_qa.apk` → 结论“回归通过”，退出码 0。
- 提交状态：未执行 `git commit`；所有改动留在 worktree，等待用户审阅后决定提交方式。
- 审阅修复（2026-11-17 第二稿）：
  - 设备安装/流程异常改为捕获并产出 `ERROR` 结果，写 `build/qa/<run>/logs/device_<case>.log`；
  - 设备执行前自动 wake + dismiss-keyguard，不再依赖手工亮屏；
  - `device_config` 在设备分支前初始化，避免重跑时未绑定；
  - 桌面 UI 也改为“首次失败重跑一次，通过记 FLAKY”；`archive`/`machine` 类点击抖动已加局部重试；
  - 已知失败必须覆盖该用例全部失败断言，避免吞掉新增回归；
  - `tap` 遇到 disabled 按钮返回 false，不再假成功；
  - 截图基线报告写入 `asset_hash`（data/data_private/assets_private）；
  - 新增 `python tests/run.py --check-coverage`：机器目录有用例或显式豁免才通过，初始豁免 3 台待补设备。
