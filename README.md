# 深空当铺手机版（M1）

Steam《深空当铺：可能是偷的》手机移植项目。当前为 M1 首个可玩版本：核心经营循环、触屏 UI、Android APK。

## 当前交付

- APK（M2 私有构建）：`build/probably_stolen_m2.apk`
- M1 APK：`build/probably_stolen_m1.apk`
- 真机截图：`build/screenshots/`
  - `01_main.png` 主界面
  - `02_inspect.png` 鉴定
  - `03_bargain.png` 议价
  - `04_sale.png` 成交
  - `05_dayend.png` 日结
  - `06_m2_full_catalog.png` M2 全量物品目录
- 平台：Godot 4.7.2 stable，Android 横屏
- 测试机：Samsung SM-S9280，Android 16，2340×1080

## 安装

```bash
adb install -r build/probably_stolen_m1.apk
adb shell monkey -p com.caiyipeng.probablystolen.mobile -c android.intent.category.LAUNCHER 1
```

## 已实现（M1）

- 主界面：店铺场景、顾客立绘、对话、日程/房租、资金、派系声望、右侧交涉栏。
- 异形格背包：16×3 格、矩形异形占位、点选详情、长按拖动、旋转、整理、分类页签。
- 展示柜：6 个展示位、上架/下架、把商品放到交易台。
- 顾客：6 类顾客（下层区、拾荒客、治安部、黑市、上层区、革命军），买/卖两种意图。
- 验货：水质、香烟、义体/枪械、通用四类模板；每次鉴定扣费，两次得出结论，假货/赃物会影响估值。
- 议价：±5%/±10% 调价、报价、顾客还价、威胁；成交/失败会影响派系声望。
- 经营：每日 3–5 位顾客、成交、日结、7 天房租、12 天贷款、房租上涨。
- 夜间事件：4 张事件卡，含现金与声望选择。
- 存档：3 个槽位中的槽位 1 已接入，顶栏存档/读档；日结自动存档。
- 新手引导：首次进入说明经营流程；第一天首位顾客固定为拾荒客卖家，便于上手。

## M2 首增量（进行中）

- 从反编译物品工厂方法抽取 **269 个物品定义、264 件可交易物品、235 个图标**。
- 私有数据层：`data_private/items_full.json` + `assets_private/items/`，已加入 `.gitignore`，不进入公开仓库。
- 顾客生成池已切换到全量目录；M2 APK 在真机验证，顾客会出售原版目录中的物品（截图中的“美工刀”）。
- 物品名称/数值覆盖仍有缺口：当前 269 个定义，目标约 330；部分定义使用回退名称/数值。
- M2 剩余：补齐名称与数值、完整物品特征/容器、完整价格公式、公开版素材替换。

## 真机验收

- 帧率：SurfaceFlinger 采样 127 帧，中位 8.30ms，约 120 FPS（设备刷新率上限），p95 8.92ms。
- 内存：TOTAL PSS 约 314 MB。
- 冷启动：`am start -W` TotalTime 305ms。
- APK：约 30 MB，arm64-v8a，minSdk 24。
- 已验证：鉴定 → 议价 → 成交、买家上架 → 放柜台 → 成交、日结 → 夜间事件 → 下一天、存档 → 读档。

## 构建

```bash
# 资源导入（首次）
"C:/Users/EDY/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" --path . --headless --import

# 导出 Android debug APK
"C:/Users/EDY/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" --path . --headless --export-debug "Android" build/probably_stolen_m1.apk
```

开发调试参数：

```bash
# 桌面截图
godot --path . --capture
# UI 自动化冒烟
godot --path . --autotest
# 检查鉴定按钮
godot --path . --dumpinspect
```

## 目录

- `scenes/Main.tscn`：唯一主场景，UI 由 `scripts/main.gd` 构建。
- `scripts/game_state.gd`：数据、经济、顾客、鉴定、议价、日结、存读档。
- `scripts/main.gd`：触屏 UI、背包、展示柜、弹窗、交互。
- `data/`：物品、顾客、事件 JSON。
- `assets/`：像素场景、顾客立绘、物品图标、像素字体。
- `docs/立项方案.md`：全量 1:1 目标与 M1–M6 路线。
- `_research/`：拆包、反编译、效果图与测试截图，已排除在 APK 与公开仓库之外。

## 素材与版权

- 当前私有自用版复用了本机已购游戏的拆包素材；`_research/` 与拆包素材不进入公开仓库，APK 不公开分发。
- 公开仓库/公开版必须替换为自制或生成素材，保留玩法与配色方向，不使用原游戏角色、Logo、贴图、音频。

## M1 限制

- 21 件物品、6 类顾客、4 个事件、1 个店铺场景。
- 未包含：完整 330 物品、机器/生产链、化学/DNA/水产/种植/器官、2544 条剧情、13 专精、49 升级、8 派系完整树、战斗、报纸/手机系统。
- 这些属于 M2–M6，最终目标是全量 1:1，不永久删减。

## M2 剩余

- 补齐到约 330 件物品，修正回退名称/数值。
- 完整物品特征、容器嵌套、展示/储藏规则、违禁/赃物。
- 完整价格公式与派系/事件修正。
- 公开版素材替换后，公开仓库才具备可运行素材。
