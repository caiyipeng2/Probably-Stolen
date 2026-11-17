#!/usr/bin/env python3
# [L4 回归结论层] report.py — 汇总、参考运行对比、报告、退出码
import json
from datetime import date
from pathlib import Path


def _known_match(case, known):
    hits = []
    labels = [a.get("label", "") for a in case.get("assertions", []) if not a.get("ok")]
    for item in known:
        if item.get("case") != case.get("id"):
            continue
        assertion = item.get("assertion", "")
        if assertion == "" or assertion in labels:
            hits.append(item)
    return hits


def _known_covers_all(hits, labels):
    if not labels:
        return bool(hits)
    for label in labels:
        if not any(not h.get("assertion") or h.get("assertion") == label for h in hits):
            return False
    return True


def _entry(case):
    first = next((a.get("label", "") for a in case.get("assertions", []) if not a.get("ok")), "")
    return {"id": case.get("id"), "first_failure": first}


def summarize(results, reference, known, env):
    new_regressions, known_hits, skips, errors, failures = [], [], [], [], []
    ref_map = {c.get("id"): c for c in (reference or {}).get("cases", [])}
    counts = {"pass": 0, "fail": 0, "error": 0, "skip": 0, "flaky": 0}
    today = date.today().isoformat()
    for case in results:
        status = case.get("status", "ERROR")
        if status == "PASS":
            counts["pass"] += 1
        elif status == "FLAKY":
            counts["flaky"] += 1
        elif status == "SKIP":
            counts["skip"] += 1
            skips.append(case)
        elif status == "ERROR":
            counts["error"] += 1
            errors.append(case)
        else:
            counts["fail"] += 1
            hits = _known_match(case, known)
            failed_labels = [a.get("label", "") for a in case.get("assertions", []) if not a.get("ok")]
            if hits and _known_covers_all(hits, failed_labels):
                known_hits.append({
                    "id": case.get("id"),
                    "issues": [h.get("issue", "") for h in hits],
                    "expired": [h.get("issue", "") for h in hits if h.get("expires") and h["expires"] < today],
                })
            elif reference is None:
                failures.append(_entry(case))
            elif ref_map.get(case.get("id"), {}).get("status", "PASS") == "PASS":
                new_regressions.append(_entry(case))
            else:
                failures.append(_entry(case))
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
    regression_ok = not new_regressions and not failures and not errors
    return {"conclusion": conclusion, "regression_ok": regression_ok, "counts": counts,
            "new_regressions": new_regressions, "failures": failures,
            "known_failures": known_hits,
            "skips": [{"id": c.get("id")} for c in skips],
            "errors": [{"id": c.get("id")} for c in errors],
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
             "| 用例 | 状态 | 首个失败断言 |", "|---|---|---|"]
    for case in results:
        first = next((a.get("label", "") for a in case.get("assertions", []) if not a.get("ok")), "")
        lines.append("| %s | %s | %s |" % (case.get("id"), case.get("status"), first))
    lines += ["", "## 截图失败", ""]
    shot_failures = 0
    for case in results:
        if case.get("status") == "FLAKY":
            continue
        for shot in case.get("shots", []):
            if shot.get("status") == "FAIL":
                shot_failures += 1
                lines.append("- %s / %s：差异率 %.4f%%，diff=%s" % (
                    case.get("id"), shot.get("name"), float(shot.get("diff_ratio", 0)) * 100,
                    shot.get("diff_image", "")))
    if shot_failures == 0:
        lines.append("无")
    lines += ["", "## 环境", "", "```json",
              json.dumps(summary.get("environment", {}), ensure_ascii=False, indent=2), "```"]
    (run_dir / "report.md").write_text("\n".join(lines), encoding="utf-8")
    (run_dir / "summary.txt").write_text(summary["conclusion"] + "\n", encoding="utf-8")


def find_reference(history_path: Path, runs_root: Path, current_run: str):
    if not history_path.exists():
        return None
    for line in reversed(history_path.read_text(encoding="utf-8").splitlines()):
        if not line.strip():
            continue
        rec = json.loads(line)
        if rec.get("suite") != "full" or not rec.get("regression_ok"):
            continue
        if rec.get("run_id") == current_run:
            continue
        ref_path = runs_root / rec["run_id"] / "report.json"
        if ref_path.exists():
            return json.loads(ref_path.read_text(encoding="utf-8"))
    return None
