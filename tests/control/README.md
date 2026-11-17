# ① 控件层

- 职责：把界面抽象成语义控件，定位控件、注入真实输入、读取控件状态。
- 输入：`ui_map.json`、桌面 `Main` 节点树、ADB 设备。
- 输出：`DesktopDriver` / `DeviceDriver` 的控件操作结果。
- 依赖：无业务层依赖。
- 禁止：写业务断言、直接调用 `GameState` 业务方法、判断流程对错。
- 被谁调用：执行层（`execution/`）。

新增控件时先改 `ui_map.json`；真机坐标由 `--build-control-map` 导出，不手工标注。
