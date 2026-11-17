# ④ 回归结论层

- 职责：合并所有用例结果，与参考运行对比，生成报告与退出码。
- 输入：逻辑/UI/真机结果、截图判定、`known_failures.json`、`history.jsonl`。
- 输出：`report.md`、`report.json`、`summary.txt`、退出码。
- 依赖：无执行依赖。
- 禁止：重新执行用例、解析原始 print 日志。
- 被谁调用：`tests/run.py`。

退出码：`0` 回归通过；`1` 新增回归/失败/缺失基线；`2` 环境或框架错误。
