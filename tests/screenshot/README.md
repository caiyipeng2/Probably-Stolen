# ③ 截图验证测试层

- 职责：捕获稳定帧、管理基线、执行像素比对与遮罩。
- 输入：桌面视口 / ADB `screencap`、`baselines/`、`masks/`、`config.json`。
- 输出：每张截图的 `PASS/FAIL/NEW_BASELINE/ERROR` 与差异指标、差异图。
- 依赖：Pillow、numpy。
- 禁止：决定用例整体结论、重新执行业务步骤。
- 被谁调用：`tests/run.py`、真机执行器。

基线只能通过 `--update-baselines` 显式更新；更新后人工审阅差异图再提交。
