# 自动化回归与截图测试框架设计

- 日期：2026-11-17
- 状态：待审阅
- 适用项目：Probably Stolen / 深空当铺手机版（Godot 4.7.2）
- 目标版本：M27 起

## 1. 背景与目标

当前仓库的"自动化回归验证"与"截图"由四套互不衔接的机制组成：散装的 headless 打印脚本、藏在 `main.gd` 启动参数里的 UI 冒烟分支、写死路径的截图分支，以及每次手工执行的 ADB 真机流程。大多数脚本没有断言和退出码，回归结论靠人读日志和看图。

目标是把这些逻辑全部抽出，建成一个**分层、可断言、可汇总、可维护**的测试框架：

1. 每次回归有唯一入口、统一结果、明确退出码和可追溯报告；
2. 每层职责单一并用目录、README、文件头标注清楚：控件层、执行层、截图验证测试层、回归结论层；
3. 桌面逻辑、桌面 UI、真机黑盒、截图基线全部纳入同一套结果模型；
4. 旧的 `main.gd` 测试/截图分支全部移除，不再污染生产代码；
5. 用例、控件、基线、设备流程都有明确的维护路径。

## 2. 非目标

- 不建 CI/CD 流水线，仅提供可在本地/未来 CI 复用的命令行入口；
- 不改游戏玩法、经济数值、存档格式（确定性种子钩子除外，见 §10）；
- 不做 OCR、视觉大模型识别、真机 UI 控件树读取；
- 不做性能压测（帧率/内存已有独立手工流程）；
- 不把测试打进 APK，不引入 QA 专用导出包；
- 不重构 `game_state.gd` / `main.gd` 的业务结构，只做必要的测试缝与 debug 分支删除。

## 3. 现状与证据

| 现状 | 证据 |
|---|---|
| 22 个 headless 测试脚本，全部 `extends SceneTree` | `scripts/test_*.gd` |
| 仅 3 个有断言与失败退出码 | `test_aux_machines.gd:243`、`test_containers.gd:228`、`test_inspection.gd:134` |
| 其余 19 个只 `print`，恒返回 0 | 如 `test_m1.gd:32` 直接 `quit()` |
| 无 runner、无清单、无汇总，测试与生产代码同目录 | 仓库内无测试运行脚本 |
| UI 冒烟以启动参数分支形式塞在 `main.gd` | `main.gd:209-216` 分发，`main.gd:261-467` 各分支 |
| 分支直接调私有方法、固定延迟、只 print、无断言 | `main.gd:261`、`main.gd:340`、`main.gd:390`、`main.gd:433` |
| 截图写死到 `_research/mockups/phone/`，无基线、无对比 | `main.gd:469-530` |
| 真机靠手工 adb，产物堆在 `build/screenshots/`（252 张） | `README.md:144`、`build/screenshots/` |
| 测试目录当前会打进 APK | `export_presets.cfg:9-11` 仅排除 `_research/` 与 `build/` |

## 4. 已确认的决策

| 决策点 | 结论 |
|---|---|
| 覆盖范围 | 桌面 + 真机全链路；设备不在线时真机层 SKIP |
| 截图校验深度 | **全量基线比对**，动态区域用遮罩 |
| 技术栈 | GDScript 内测（控件/执行/捕获）+ Python 编排（设备/比对/报告） |
| 迁移方式 | 彻底迁移，旧 `--autotest` / `--test*` / `--capture*` / `--dump*` 全部移除 |
| 架构 | 双后端分层：桌面代码化流程 + 真机声明式冒烟，共享控件表、截图与结论层 |

## 5. 总体架构

```text
python tests/run.py --suite full
  │
  ├─ 0. 环境预检
  │     Godot 可执行文件、目标 APK、adb 与设备、基线 profile
  │
  ├─ 1. 桌面逻辑套件（一次 headless 进程）
  │     tests/execution/logic_runner.gd → cases/logic/*.gd
  │
  ├─ 2. 桌面 UI 套件（每个用例一个窗口进程）
  │     godot tests/ui_entry.tscn → Main.tscn
  │        ├─ tests/control/desktop_driver.gd   （控件层）
  │        └─ tests/execution/cases/ui/*.gd     （执行层）
  │
  ├─ 3. 真机套件（可选）
  │     tests/execution/device_runner.py → tests/control/device_driver.py
  │        声明式步骤：tap / drag / wait_screen / shot
  │
  ├─ 4. 截图验证
  │     tests/screenshot/compare.py：本次截图 vs tests/baselines/<profile>
  │
  └─ 5. 回归结论
        tests/verdict/report.py：合并结果 → report.md/json → 退出码
```

四层严格单向依赖：

```text
结论层 ← 截图验证层 ← 执行层 ← 控件层
```

- 控件层不知道用例存在；
- 执行层不知道 ADB/像素实现；
- 截图验证层不知道业务语义；
- 结论层不重新执行任何东西。

## 6. 目录结构

```text
tests/
  README.md                       # 四层总图、命令、能力矩阵、维护手册
  run.py                          # 唯一编排入口

  control/                        # ① 控件层
    README.md
    ui_map.json                   # 语义控件表（桌面选择器 + 真机百分比矩形）
    desktop_driver.gd             # 节点解析 + 真实输入注入 + 文本读取
    device_driver.py              # ADB 封装 + 坐标换算 + 设备生命周期

  execution/                      # ② 执行层
    README.md
    case.gd                       # 用例基类：软断言、步骤、结果
    fixtures.gd                   # 种子、欢迎页、剧情、开窗、日结
    logic_runner.gd               # headless 逻辑入口
    ui_entry.tscn / ui_entry.gd   # 桌面 UI 入口（实例化 Main.tscn）
    device_runner.py              # 真机声明式流程执行
    suites.json                   # 用例清单、套件、tag、平台、种子
    cases/
      logic/                      # 22 个迁移用例
      ui/                         # 桌面 UI 流程
      device/                     # 真机冒烟流程（JSON）
      diagnostics/                # 音频路径等诊断

  screenshot/                     # ③ 截图验证测试层
    README.md
    capture.gd                    # 桌面稳定帧捕获
    capture.py                    # 真机稳定帧捕获
    compare.py                    # 基线比对、遮罩、差异图
    config.json                   # 阈值与 profile 配置
    masks/<case>/<shot>.json      # 动态区域遮罩

  verdict/                        # ④ 回归结论层
    README.md
    report.py                     # 汇总、参考运行对比、报告、退出码
    known_failures.json           # 已知问题白名单

  baselines/<profile>/...         # 提交进 git 的基线（目录含 .gdignore）

build/qa/<run_id>/                 # 本次运行产物（build/ 已 gitignored）
```

## 7. 层契约

### 7.1 控件层（① control/）

**职责**：定位语义控件、注入真实输入、读取控件状态/文本。**不做业务断言，不 import GameState。**

#### 7.1.1 语义控件表 `ui_map.json`

```json
{
  "screens": {
    "welcome": {
      "btn_normal":   {"type": "button", "text": "普通"},
      "btn_original": {"type": "button", "text": "原版 1:1"}
    },
    "main": {
      "cash":         {"type": "label",  "property": "cash_label"},
      "btn_end_day":  {"type": "button", "text": "结束营业"}
    },
    "inspect": {
      "btn_close":    {"type": "button", "text": "关闭"},
      "info":         {"type": "label",  "property": "inspection_info"}
    }
  },
  "device": {
    "welcome.btn_normal": {"x": 0.50, "y": 0.62, "w": 0.16, "h": 0.07},
    "main.btn_end_day":   {"x": 0.08, "y": 0.88, "w": 0.14, "h": 0.06}
  },
  "device_profiles": {
    "SM-S9280": {"offset_x": 0.0, "offset_y": 0.0}
  }
}
```

- 选择器优先级：`property`（Main 上已有变量）→ `name`（节点名）→ `text`（精确）→ `text_contains`。
- `scope` 可选：`modal` / `machine_panel` / `container_panel`，用于限定搜索根节点。
- 真机坐标使用**百分比矩形**，由桌面导出工具生成，不手工标注。
- `device_profiles` 允许按机型加偏移，吸收安全区/刘海差异；默认 0。

#### 7.1.2 桌面驱动 `desktop_driver.gd`

| API | 行为 |
|---|---|
| `tap(key)` | 计算控件全局矩形中心，注入 `InputEventMouseButton` 按下/抬起（项目已开启触屏模拟） |
| `drag(from_key, to_key, steps)` | 按下 → 逐帧移动 → 松开，默认 12 帧 |
| `type_text(key, value)` | 点击聚焦后逐字符注入按键事件；仅保证 ASCII/数字 |
| `read_text(key)` | 返回 Label/Button 当前文本 |
| `is_visible(key)` | 返回可见性（含父级 `visible` 链） |
| `wait_visible(key, timeout_ms)` | 轮询到可见；超时抛 `ControlNotFound` 并附当前屏控件快照 |
| `wait_hidden(key, timeout_ms)` | 轮询到隐藏 |
| `dump_controls(screen)` | 导出当前屏控件 `key → 百分比矩形 + 文本`，用于生成真机坐标表与排障 |

实现约束：

- 输入必须走真实事件分发（`Input.parse_input_event` / `viewport.push_input`），不得调用 `button.pressed.emit()` 或业务私有方法；
- 例外：`type_text` 在按键注入不可行时可回退为 `LineEdit.text` + `text_submitted.emit()`，但必须在步骤日志标记 `injected_direct`；
- 只读 `Control`/`Node` 的通用属性，不调用 `main.gd` 的业务方法。

#### 7.1.3 真机驱动 `device_driver.py`

| API | 实现 |
|---|---|
| `install(apk)` | `adb install -r -t` |
| `launch()` / `stop()` | `am start -W -a MAIN -c LAUNCHER` / `am force-stop` |
| `tap(key)` / `drag(...)` | 百分比矩形 × `wm size`，`input tap` / `input swipe` |
| `key(code)` | `input keyevent` |
| `screencap()` | `adb exec-out screencap -p`，二进制直取 |
| `write_user_file(name, text)` | `adb push` 到 `/data/local/tmp` 后 `run-as <pkg> cp` |
| `delete_user_file(name)` | `run-as rm` |
| `clear_data()` | `pm clear <pkg>`（**仅在显式 `--fresh-device` 时调用**） |
| `device_info()` | 型号、分辨率、density、Android 版本、序列号 |
| `read_text` | 不支持，调用抛 `UnsupportedCapability` |

所有命令带超时；区分 `DeviceOffline`、`Unauthorized`、`CommandTimeout` 三类基础设施错误。

#### 7.1.4 能力矩阵（写入 `tests/README.md`）

| 能力 | 桌面 | 真机 |
|---|---|---|
| tap / drag / 输入 | 真实输入事件 | ADB 真触摸 |
| 读控件文本 / 状态断言 | 支持 | 不支持 |
| 截图检查点 | 支持 | 支持 |
| 直接断言 GameState | 仅逻辑用例 | 不支持 |

#### 7.1.5 控件表生成

```bash
python tests/run.py --build-control-map
```

- 桌面端依次执行脚本化导航（欢迎页、主界面、鉴定、机器、容器等），每到一屏调用 `dump_controls`；
- Python 把 `key → 百分比矩形` 合并进 `ui_map.json` 的 `device` 段；
- 输出 `build/qa/control_map_diff.md`，人工复核后提交；
- UI 改版后重跑此命令即可，不在用例里硬编码坐标。

### 7.2 执行层（② execution/）

**职责**：组织步骤、调用控件层、记录断言、管理夹具与套件。不直接调用 adb、不直接读 PNG。

#### 7.2.1 用例基类 `case.gd`

```gdscript
class_name QaCase
var id: String
var tags: Array
var platform: String        # "desktop" / "device"
var seed: int = 20261117

func setup() -> void
func run() -> void
func teardown() -> void

func step(title: String) -> void
func check(ok: bool, label: String, detail: String = "") -> void
func check_eq(actual, expected, label: String) -> void
func check_text(key: String, expected: String, mode: String = "eq") -> void
func shot(name: String) -> void
```

- 软断言：单条失败不中断，用例结束统一判定。
- 每个用例输出：`id/status/duration_ms/steps[]/assertions[]/shots[]/error`。
- 状态：`PASS / FAIL / SKIP / ERROR`；截图状态由截图层回填。
- 断言标签必须可读且稳定（报告与 known_failures 以此匹配）。

#### 7.2.2 夹具 `fixtures.gd`（桌面）

真机夹具（安装、启动、推种子、停止）由 `device_runner.py` 实现，不在 `fixtures.gd` 中。

| 夹具 | 行为 |
|---|---|
| `boot_to_main(difficulty := "normal", mode := "mobile", seed := 20261117)` | 设种子 → 点击欢迎难度 → 循环关闭教程/剧情（guard 40）→ 等主界面 |
| `skip_story()` | 循环点击可见的继续/选项按钮直到剧情层隐藏 |
| `close_modal()` | 点击弹窗关闭/确定 |
| `open_machine(id)` | 打开机器湾并选中指定机器，等待详情刷新 |
| `open_container(uid)` | 打开指定容器并等待网格稳定 |
| `end_day()` | 点击结束营业并处理结算弹窗 |
| `assert_day(n)` / `assert_cash(v)` | 仅逻辑用例使用的 GameState 断言 |

#### 7.2.3 确定性策略

- **桌面**：`boot_to_main` 在点击欢迎按钮前设置 `GameState.rng.seed = case.seed`，零生产改动。
- **真机**：`device_runner.py` 在每次启动前推入一次性种子文件 `user://qa_seed.txt`；`GameState._ready()` 在 `rng.randomize()` 之前读取该文件，用其内容设置 `rng.seed` 并立即删除（一次性，正常玩家不受影响）。启动时 `_ready()` 里的首次 `new_game()` 与随后点击欢迎难度触发的 `new_game()` 都沿用同一种子序列，因此每次运行可复现。该文件是唯一生产代码测试缝，见 §10。
- 每个用例/流程固定种子；随机内容（顾客、物品特征）因此可复现。

#### 7.2.4 套件清单 `suites.json`

```json
{
  "cases": [
    {"id": "logic/containers", "file": "cases/logic/containers.gd",
     "platform": "desktop", "runner": "logic", "seed": 20261117,
     "tags": ["smoke", "container"]},
    {"id": "ui/trade_flow", "file": "cases/ui/trade_flow.gd",
     "platform": "desktop", "runner": "ui", "seed": 20261117,
     "tags": ["smoke", "trade"]},
    {"id": "device/trade_smoke", "file": "cases/device/trade_smoke.json",
     "platform": "device", "runner": "device",
     "tags": ["smoke", "trade"]}
  ],
  "suites": {
    "logic":  {"platform": "desktop", "runner": "logic"},
    "ui":     {"platform": "desktop", "runner": "ui"},
    "device": {"platform": "device", "runner": "device"},
    "smoke":  {"tags": ["smoke"]},
    "full":   {}
  }
}
```

#### 7.2.5 用例迁移映射

| 新位置 | 来源 | 内容 |
|---|---|---|
| `cases/logic/`（22 个） | `scripts/test_*.gd` | 全部迁移；19 个纯 print 用例补断言 |
| `cases/ui/trade_flow.gd` | `--autotest` | 买家成交、卖家成交、鉴定、议价、日结、下一天 |
| `cases/ui/inspect_flow.gd` | `--testinspect` / `--dumpinspect` | 放大镜、对质、估价提交 |
| `cases/ui/machine_flow.gd` | `--testmachineui` | 充能器、售货机、反应堆、动物笼、水培、冰箱、熔炉 IO |
| `cases/ui/minigame_flow.gd` | `--testminigame` | 打印失败/成功、配比、DNA |
| `cases/ui/container_flow.gd` | `--testcontainerui` | 嵌套容器、分堆、拖拽 |
| `cases/ui/archive_story_flow.gd` | `--capturearchive` / `--capturestory` | 档案页、剧情弹窗 |
| `cases/diagnostics/audio_paths.gd` | `--audioinfo` | 音频路径诊断 |
| `cases/device/*.json` | 旧手工 adb | 启动、交易、机器、容器拖拽、日结 5 条冒烟 |

补充规则：

- 数据量类断言用精确值（如 34 组 / 2544 条 / 341 客户 / 2165 节点）；
- 平衡类用区间阈值（存活率、破产天数），不冻结单局随机结果；
- print 迁移前先用固定种子跑一遍当前实现，人工审阅输出再落断言，避免把错误现状固化。

#### 7.2.6 真机声明式流程

真机流程统一从欢迎页选择「原版 1:1」：该模式第 1 天无剧情，只有教程，黑盒无需处理不可读的剧情分支。每个流程先 `wait_screen welcome`、再点难度、`wait_screen tutorial`、点跳过，确保启动时序稳定。

只允许四种步骤：

```json
{
  "id": "device/trade_smoke",
  "seed": 20261117,
  "steps": [
    {"action": "wait_screen", "shot": "welcome", "timeout_ms": 20000},
    {"action": "tap", "target": "welcome.btn_original"},
    {"action": "wait_screen", "shot": "tutorial", "timeout_ms": 10000},
    {"action": "tap", "target": "tutorial.btn_skip"},
    {"action": "wait_screen", "shot": "main_day1", "timeout_ms": 20000},
    {"action": "tap", "target": "main.customer_card"},
    {"action": "tap", "target": "inspect.btn_inspect"},
    {"action": "shot", "shot": "inspect_open"},
    {"action": "tap", "target": "modal.btn_close"},
    {"action": "shot", "shot": "main_after_close"}
  ]
}
```

- `tap` / `drag`：目标为 `ui_map` 语义 key；
- `wait_screen`：轮询截图与同名基线的差异率，直到低于阈值或超时（真机没有控件文本，用它做同步）；
- `shot`：截取并做全量基线比对；
- 真机流程不写条件分支；需要分支的验证留给桌面 UI 用例。

#### 7.2.7 运行隔离

- 逻辑套件：单个 Godot headless 进程跑完所有逻辑用例；
- 桌面 UI：**每个用例独立 Godot 进程**，避免存档/窗口/信号残留；
- 真机：每个流程 `force-stop → 推种子 → 启动`。**全量基线要求每次从全新数据开始**（否则教程/存档状态会让画面不一致）：`--suite device` 必须显式带 `--fresh-device`，流程变为 `force-stop → pm clear → 推 qa_seed.txt → 启动`；未带该开关时真机套件直接 `SKIP` 并提示原因，绝不默默清空设备数据。
- 用例失败不阻断后续用例（除非是环境错误，由 run.py 决定中止）。

### 7.3 截图验证测试层（③ screenshot/）

**职责**：捕获稳定画面、管理基线、输出每张图的判定与指标。不决定用例整体结论。

#### 7.3.1 捕获

- 桌面 `capture.gd`：等待连续两帧画面 hash 一致后落盘；超时 3s 记 `UNSTABLE`。同时记录用例、种子、视口尺寸、Godot 版本、commit。
- 真机 `capture.py`：每 200ms `screencap`，连续两张差异低于稳定阈值才采用；超时取最后一帧并标 `UNSTABLE`。
- 命名：`build/qa/<run_id>/<platform>/<case>/<NN>_<shot>.png`。
- 基线：`tests/baselines/<profile>/<case>/<NN>_<shot>.png`。

#### 7.3.2 Profile

- 桌面：`desktop-1280x720-win`（Godot 窗口实际截图尺寸）；
- 真机：`device-<model>-<wxh>-<android_version>`（当前为 `device-SM-S9280-2340x1080-16`）。
- 设备型号/分辨率与基线 profile 不一致 → 真机套件 `SKIP`，原因写入报告；不跨 profile 比对。

#### 7.3.3 比对算法

1. 基线缺失：非更新模式 → `NEW_BASELINE`（失败）；更新模式 → 写入；
2. 尺寸不一致 → `FAIL`；
3. 应用 `masks/<case>/<shot>.json` 的百分比矩形，忽略动态区域；
4. 逐像素容差（单通道默认 ±3）后统计差异占比；
5. 差异率 ≤ 阈值 → `PASS`，否则 `FAIL`。
6. 失败输出 `diff.png`（红色标记差异区）与 `metrics.json`（差异像素数、占比、包围盒、阈值）。

阈值默认：桌面 0.1%，真机 0.3%；可在 `config.json` 按检查点覆盖。

遮罩文件格式（百分比矩形，坐标系与截图一致）：

```json
{
  "regions": [
    {"x": 0.62, "y": 0.18, "w": 0.30, "h": 0.42, "reason": "随机顾客头像与对话"},
    {"x": 0.03, "y": 0.92, "w": 0.10, "h": 0.05, "reason": "toast 淡出动画"}
  ]
}
```

#### 7.3.4 基线维护

- 只允许显式更新：`python tests/run.py --suite <套件> --update-baselines`（桌面/真机基线都走同一流程）；
- 更新时输出 `baseline_changes.md`（新增/变更/删除清单）与差异图；
- 基线目录加 `.gdignore`，防止 Godot 导入；`tests/**` 不进入 APK；
- 审阅流程：看 diff 图 → 确认是有意改动 → 提交基线变更。

#### 7.3.5 稳定性

- 固定种子 + 统一夹具 + 稳定帧捕获；
- 遮罩只覆盖不可避免的动态区域，并在文件内注明原因；
- 截图失败自动重拍一次，通过则记 `FLAKY`；两次失败才判 `FAIL`；
- `UNSTABLE` 单独标注，不直接等同业务失败。

### 7.4 回归结论层（④ verdict/）

**职责**：合并标准化结果、与参考运行对比、生成报告与退出码。不重新执行。

#### 7.4.1 状态与归因

| 状态 | 含义 | 是否新增回归 |
|---|---|---|
| `PASS` | 断言与截图全部通过 | 否 |
| `FAIL` | 业务断言失败或截图差异超阈值 | 是 |
| `ERROR` | 异常、超时、崩溃、设备断开 | 归入环境/框架错误 |
| `SKIP` | 设备离线、profile 不匹配、未选套件 | 否 |
| `NEW_BASELINE` | 基线缺失且非更新模式 | 是（无法判定） |
| `FLAKY` | 首次失败、重试通过 | 否，计入稳定性风险 |

#### 7.4.2 回归结论

参考运行的确定规则：默认取 `build/qa/history.jsonl` 中最近一次 `suite=full` 且结论为"回归通过"的 run；不存在时报告"无参考运行，仅本次结果"；可用 `--reference-run <run_id>` 显式指定。逐用例对比：

- **回归通过**：无新增失败、无 ERROR、无缺失基线；
- **新增回归 N**：参考运行通过、本次失败的用例（附首个失败断言与截图 diff）；
- **已知问题 M**：仅当该用例的**全部失败断言**都被 `known_failures.json` 覆盖时才计入；只覆盖部分断言的用例仍按新增回归/失败处理；
- **环境阻断 K**：设备、框架、崩溃等原因单独列出。

桌面 UI 与真机用例首次失败会自动重跑一次；第二次通过记 `FLAKY`，不改变“回归通过”的结论，但保留首次证据。

`known_failures.json` 条目：

```json
{
  "case": "logic/balance",
  "assertion": "survival_rate",
  "issue": "ISSUE-123",
  "expires": "2027-01-31",
  "reason": "已知数值波动，待重新校准"
}
```

过期条目在报告中警告。

#### 7.4.3 报告与历史

```text
build/qa/<run_id>/
  report.json        # 机器可读完整结果
  report.md          # 人读摘要 + 失败明细 + diff 图 + 截图册
  summary.txt        # 一屏纯文本
  baseline_changes.md（仅更新模式）
build/qa/history.jsonl # 追加：run_id/commit/版本/profile/计数/耗时/结论
```

- `history.jsonl` 用于趋势与 flaky 追踪；连续两次 `FLAKY` 的用例标"稳定性风险"；
- 报告包含环境信息、各套件计数、失败归因、耗时、设备信息。

#### 7.4.4 退出码

| 码 | 含义 |
|---|---|
| 0 | 回归通过（允许已知问题；可选设备 SKIP） |
| 1 | 新增回归 / FAIL / NEW_BASELINE |
| 2 | 环境或框架错误；或 `--require-device` 时设备不在线 |

## 8. 数据契约

### 8.1 用例结果（raw result）

```json
{
  "id": "ui/trade_flow",
  "platform": "desktop",
  "status": "FAIL",
  "duration_ms": 4210,
  "seed": 20261117,
  "steps": [
    {"at": "2026-11-17T15:00:01", "title": "boot_to_main"},
    {"at": "2026-11-17T15:00:03", "title": "buyer_deal"}
  ],
  "assertions": [
    {"label": "cash_increases", "ok": false, "detail": "650 -> 650"}
  ],
  "shots": [
    {"name": "01_welcome", "status": "PASS", "diff_ratio": 0.0},
    {"name": "02_trade", "status": "FAIL", "diff_ratio": 0.021,
     "diff_image": "build/qa/.../diff_02_trade.png"}
  ],
  "error": null
}
```

### 8.2 报告（report.json）

```json
{
  "run_id": "20261117-150000",
  "commit": "30885bb",
  "apk_version": "0.26.0",
  "godot": "4.7.2",
  "conclusion": "新增回归 1 / 已知问题 2 / 环境阻断 1",
  "exit_code": 1,
  "suites": {
    "logic": {"pass": 21, "fail": 0, "error": 0, "skip": 0},
    "ui": {"pass": 6, "fail": 1, "error": 0, "skip": 0, "flaky": 0},
    "device": {"pass": 5, "fail": 0, "error": 0, "skip": 0}
  },
  "new_regressions": [{"id": "ui/trade_flow", "first_failure": "cash_increases"}],
  "known_failures": [{"id": "logic/balance", "issue": "ISSUE-123"}],
  "environment": {"device": "SM-S9280", "profile": "device-SM-S9280-2340x1080-16"}
}
```

## 9. 错误处理与归因规则

| 场景 | 归类 | 行为 |
|---|---|---|
| 控件找不到/超时 | `ERROR` | 附当前屏控件快照，后续用例继续 |
| 业务断言失败 | `FAIL` | 记录首个失败，用例继续跑完 |
| 截图基线缺失 | `NEW_BASELINE` | 非更新模式失败；更新模式写入 |
| 截图 `UNSTABLE` | `ERROR`（截图） | 记录并重拍一次 |
| 设备离线/未授权 | `SKIP` 或 `ERROR` | 可选设备 → SKIP；`--require-device` → ERROR/退出 2 |
| Godot 进程崩溃/导出失败 | `ERROR` | 中止当前套件，报告保留已完成结果 |
| 帧差异超阈值 | `FAIL`（截图） | 重拍一次，通过记 `FLAKY` |

## 10. 生产代码改动

1. **删除 debug 分支**：`main.gd` 移除 `_capture_if_requested`、`_autotest_if_requested`、`_dumpui_if_requested`、`_dumpinspect_if_requested`、`_testminigame_if_requested`、`_testmachineui_if_requested`、`_testinspect_if_requested`、`_testcontainerui_if_requested` 及 `_ready` 中对应调用（`main.gd:209-216`）；`--audioinfo` 改为诊断用例；`--publicassets` 保留。
2. **确定性种子钩子（唯一测试缝）**：`game_state.gd` 初始化时：

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

   文件一次性消费；仅真机 QA 流程推入，正常玩家不存在该文件。
3. **控件命名**：仅对确有歧义的控件补充 `name`（预计个位数）；优先复用 `main.gd` 已有变量（`property` 选择器）。
4. **修复买家交易按钮**（2026-11-17 用户授权）：`main.gd` 中 `bargain` / `deal` 的启用条件由 `intent == "sell"` 改为 `intent in ["sell", "buy"]`，恢复 M24 `1e45b5a` 起被禁用的买家成交路径；底层 `_open_bargain` / `accept_current` 本就支持 buy。
5. **导出排除**：`export_presets.cfg` 的 exclude_filter 增加 `tests/*, tests/**`，确保测试、基线不进 APK。
6. **文档**：README 测试章节改为新命令；新增 `tests/README.md` 与四个层目录 README；基线目录加 `.gdignore`。
7. **忽略规则**：`build/qa/` 由现有 `build/` 规则覆盖，无需新增。

## 11. 迁移步骤

### 阶段 0：框架骨架
- 建目录、层 README、`run.py` 参数解析、结果 JSON 模型、空 runner 打通。

### 阶段 1：逻辑用例迁移
- 实现 `case.gd`、`logic_runner.gd`、`suites.json`；
- 迁移 22 个 `test_*.gd`，补断言与退出码；
- `--suite logic` 可独立跑通，失败返回 1。

### 阶段 2：控件层 + 桌面 UI
- `ui_map.json` 初版、`desktop_driver.gd`、`fixtures.gd`、`ui_entry.tscn`；
- 迁移 5 条 `--test*` UI 流程与 `--autotest`；
- 删除 `main.gd` 对应分支；
- `--suite ui` 可独立跑通。

### 阶段 3：截图验证层
- `capture.gd`、`compare.py`、`config.json`、遮罩目录；
- 在 UI 流程中布置检查点，生成桌面基线并人工审阅；
- 截图 FAIL 能输出 diff 与 metrics。

### 阶段 4：真机链路
- `device_driver.py`、`device_runner.py`、5 条声明式冒烟；
- 种子钩子、`--build-control-map` 坐标生成；
- SM-S9280 上安装、启动、点击、截图、基线比对全通。

### 阶段 5：结论层与收尾
- `report.py`、`known_failures.json`、历史与退出码；
- 清理旧脚本、更新 README、导出排除；
- 跑一次 full 验收并人工审阅报告。

## 12. 验收标准

1. `python tests/run.py --suite logic`：22 个用例全部执行，当前代码下 exit 0；故意破坏一条断言返回 1 并指出用例与断言标签。
2. `python tests/run.py --suite ui`：全程通过控件层真实输入事件驱动，无 `main.gd` 私有方法直调；所有检查点有截图与基线判定。
3. `python tests/run.py --suite device --fresh-device`：SM-S9280 上完成装包、启动、5 条冒烟、截图全绿；未带 `--fresh-device` → SKIP；拔掉设备 → SKIP + exit 0；`--require-device` → exit 2。
4. `--update-baselines`：只更新指定套件检查点，输出变更清单与 diff 图，不误伤其他基线。
5. `report.md/json`：包含结论、失败归因、截图 diff 链接、环境信息与耗时。
6. APK 导出：`tests/**` 不进入包体，APK 大小无异常增长；旧回归（逻辑用例 + 手工冒烟）全过，游戏原有行为不变。

## 13. 风险与缓解

| 风险 | 缓解 |
|---|---|
| 19 个 print 用例补断言可能固化错误预期 | 固定种子先跑现状、人工审阅、数据量精确/平衡类阈值化 |
| 全量基线维护成本高 | 固定种子 + 稳定帧 + 最小遮罩 + profile；UI 改动按流程更新基线 |
| 真实输入暴露旧的命中区/布局问题 | 视为真实回归；预留一轮稳定期，逐条确认后修 UI 或冻结基线 |
| 真机渲染差异导致频繁 diff | 设备 profile 隔离 + 0.3% 阈值 + 重拍一次 + FLAKY 标注 |
| 每用例一个 Godot 进程导致变慢 | 仅 UI 用例隔离；逻辑用例单进程；预计 UI 全套 < 2 分钟 |
| 种子文件残留影响正常游玩 | 一次性消费并删除；仅真机 QA 推入；报告记录是否使用种子 |
| 真机测试清空应用数据 | 只有显式 `--fresh-device` 才 `pm clear`；默认 SKIP 并提示，绝不清数据；README 醒目标注 |

## 14. 附录

### 14.1 常用命令

```bash
python tests/run.py --suite logic
python tests/run.py --suite ui
python tests/run.py --suite device --serial <adb序列号> --fresh-device
python tests/run.py --suite smoke
python tests/run.py --suite full
python tests/run.py --suite ui --update-baselines
python tests/run.py --suite device --update-baselines
python tests/run.py --build-control-map
python tests/run.py --suite full --reference-run <run_id>
python tests/run.py --suite ui --filter ui/trade_flow
```

### 14.2 层标注规范

每个文件头必须标注层号与职责，例如：

```gdscript
# [L1 控件层] desktop_driver.gd — 语义控件解析与真实输入注入
# 职责: 定位控件、注入输入、读取文本；不做业务断言
# 被谁调用: L2 执行层
```

```python
# [L4 结论层] report.py — 汇总结果、对比参考运行、生成结论与退出码
# 职责: 只消费标准化结果；不重新执行用例
```

每个层目录的 README 固定包含：职责、输入、输出、依赖、禁止事项、被谁调用。

### 14.3 维护手册

| 场景 | 操作 |
|---|---|
| 新增逻辑用例 | 在 `cases/logic/` 新建 `QaCase` 文件 → 在 `suites.json` 注册 → 跑 `--suite logic` |
| 新增桌面 UI 用例 | 复用 `fixtures.gd` → 只用控件层 API → 注册到 `suites.json` |
| UI 控件改版 | 更新 `ui_map.json` → 跑 `--build-control-map` → 审阅 device 坐标 diff → 跑 `--suite ui` → 按需更新基线 |
| 新增真机流程 | 在 `cases/device/` 写 JSON（仅 tap/drag/wait_screen/shot）→ 先 `--update-baselines` 生成基线并审图 |
| 处理已知失败 | 加入 `known_failures.json` 并填 issue/过期日；修复后删除条目 |
| 回归失败定位 | 打开 `report.md` → 看首个失败断言 → 点 diff 图 → 复跑单个用例 `--filter <case_id>` |
