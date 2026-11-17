# 新功能接入测试模板

每个移植功能按这个顺序接入，避免“内容涨、测试不涨”。

## 1. 先盘点数据与覆盖

```bash
python tests/run.py --check-coverage
```

- 新机器/系统 ID 必须出现在某个用例里，或登记到 `tests/tools/coverage_exempt.json` 并写原因。
- 带 UI 的功能必须先有控件语义（`ui_map.json`），不要在用例里硬编码节点路径或坐标。

## 2. 逻辑层

复制 `logic_case.gd.tmpl` 到 `tests/execution/cases/logic/<feature>.gd`：

- `setup()` 使用固定种子；
- 每条断言用 `check`/`check_eq`，标签稳定、可读；
- 存档只用槽 9，`teardown()` 清理。

在 `tests/execution/suites.json` 注册：

```json
{"id": "logic/<feature>", "file": "cases/logic/<feature>.gd",
 "platform": "desktop", "runner": "logic", "seed": 20261117,
 "tags": ["<domain>"]}
```

## 3. 桌面 UI 层（有界面时）

复制 `ui_flow.gd.tmpl` 到 `tests/execution/cases/ui/<feature>_flow.gd`：

- 只用 `driver`/`fixtures` 的语义控件 API；
- 优先真实点击；确需白盒设置时写入夹具，并在 `direct_actions` 中留痕；
- 每个关键界面加 `shot()` 检查点。

注册到 `suites.json`（`runner: "ui"`），然后：

```bash
python tests/run.py --suite ui --filter ui/<feature>_flow --update-baselines
python tests/run.py --suite ui --filter ui/<feature>_flow
```

审阅 `build/qa/<run_id>/baseline_changes.md` 和 diff 图后再提交基线。

## 4. 真机层（核心链路时）

复制 `device_flow.json.tmpl` 到 `tests/execution/cases/device/<feature>_smoke.json`：

- 只允许 `tap` / `drag` / `wait_screen` / `shot`；
- 从「原版 1:1」+ 教程开始，先 `wait_screen welcome/tutorial`；
- 真机不能读文本，必须靠截图基线判定；
- 注册到 `suites.json`（`runner: "device"`）。

```bash
python tests/run.py --suite device --serial <serial> --fresh-device --update-baselines
python tests/run.py --suite device --serial <serial> --fresh-device
```

`--fresh-device` 前先备份应用数据；测完恢复。

## 5. 收尾检查

- `python tests/run.py --suite logic`
- `python tests/run.py --suite ui`（默认后台静默，调试才加 `--show-window`）
- `python tests/run.py --check-coverage`
- 更新 `README.md`/`tests/README.md` 的维护行；
- 不把 `build/`、`__pycache__`、`.import` 运行时变更提交进去。
