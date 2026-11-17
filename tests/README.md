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
python tests/run.py --suite logic                 # 22 个逻辑用例（headless）
python tests/run.py --suite ui                    # 11 条桌面 UI/诊断流程
python tests/run.py --suite device --serial R5CX211TXNT --fresh-device
python tests/run.py --suite full --fresh-device   # 逻辑 + UI + 真机
python tests/run.py --suite ui --update-baselines # 更新截图基线
python tests/run.py --build-control-map           # 重新导出真机控件坐标
python tests/run.py --check-coverage              # 检查机器目录是否有用例/豁免
python -m unittest discover -s tests -p "test_*.py" -v
```

真机链路要求：

- debug APK（`run-as` 可写 `user://`）；
- `--fresh-device` 会 `pm clear` 应用数据，先自行备份；
- 真机流程使用「原版 1:1」模式：第 1 天无剧情、只有教程，便于黑盒冒烟；
- 设备 profile 由实际截图尺寸生成，当前 SM-S9280 为 `device-SM-S9280-2340x1080-16`。

## 能力矩阵

| 能力 | 桌面 | 真机 |
|---|---|---|
| tap / drag / 输入 | 真实输入事件 | ADB 真触摸 |
| 读控件文本 | 支持 | 不支持 |
| 截图检查点 | 支持 | 支持 |
| 断言 GameState | 仅逻辑用例 | 不支持 |

## 维护手册

| 场景 | 操作 |
|---|---|
| 新增逻辑用例 | 在 `cases/logic/` 新建 `QaCase` 文件 → 在 `suites.json` 注册 → 跑 `--suite logic` |
| 新增桌面 UI 用例 | 复用 `fixtures.gd` → 只用控件层 API → 注册到 `suites.json` |
| 控件改版 | 更新 `ui_map.json` → 跑 `--build-control-map` → 跑 `--suite ui` → 必要时 `--update-baselines` |
| 新增真机流程 | 在 `cases/device/` 写 JSON（tap/drag/wait_screen/shot）→ 先 `--update-baselines` 生成基线并审图 |
| 新增机器/系统 | 补逻辑用例 → 更新 `cases/device`/`cases/ui`（如有界面）→ 跑 `--check-coverage` |
| 处理已知失败 | 加入 `verdict/known_failures.json`（case/assertion/issue/expires）；必须覆盖该用例全部失败断言 |
| 定位失败 | 打开 `build/qa/<run_id>/report.md` → 看首个失败断言与 diff 图 → `--filter <case_id>` 复跑 |

## 截图与基线

- 桌面 profile：`desktop-1280x720-win`（Godot 窗口实际截图尺寸）。
- 基线：`tests/baselines/<profile>/<case>/<NN_shot>.png`，提交进 git。
- 基线更新只允许显式 `--update-baselines`；更新后查看 `build/qa/<run_id>/baseline_changes.md` 和 diff 图。
- 失败用例会自动重跑一次，第二次通过记 `FLAKY`；两次失败才记 `FAIL`/`ERROR`。
- 报告记录 `asset_hash`（`data/` + `data_private/` + `assets_private/`）；资产变化时先审图再更新基线。
- 遮罩：`tests/screenshot/masks/<case>/<shot>.json`，百分比矩形。

## 覆盖率守卫

`python tests/run.py --check-coverage` 会对比 `data/machines.json` 与 `tests/execution/cases/`：

- 新机器 ID 没有出现在任何用例文件中 → 失败；
- 确实暂不覆盖的机器写入 `tests/tools/coverage_exempt.json` 并写原因；
- 豁免对应的机器被删除 → 也失败，避免豁免腐烂。

新增移植内容时先跑这条命令，再决定补用例还是登记豁免。

## 已知限制

- **barter/wholesale/phone 等主分支在途功能**未合入 qa-framework，barter 逻辑用例（Task 8B）暂缓。
- **DNA 编辑器**当前没有 `recipes` 数据，`start_machine` 会返回“辅助设备”；`ui/minigame_flow` 只验证序列匹配与小游戏关闭，不验证开机队列。
- 真机黑盒不能读控件文本，断言完全依赖截图基线；设备型号/分辨率变化必须重建基线。
- 桌面 UI 截图受 toast/动画影响，流程在关键截图前会等待或清理弹层。

## 产物

- `build/qa/<run_id>/report.md`：人读结论与失败明细
- `build/qa/<run_id>/report.json`：机器可读完整结果
- `build/qa/<run_id>/desktop|device/`：截图与差异图
- `build/qa/history.jsonl`：运行历史（gitignored）
