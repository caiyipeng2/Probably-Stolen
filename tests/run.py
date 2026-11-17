#!/usr/bin/env python3
# [L4 回归结论层] run.py — 测试编排入口（参数解析与套件调度）
import argparse
import hashlib
import json
import pathlib
import subprocess
import sys
import time

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

ROOT = pathlib.Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tests.screenshot.compare import load_config, process_results
from tests.verdict.report import summarize, write_reports, exit_code, find_reference

DEFAULT_GODOT = "C:/Users/EDY/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
DESKTOP_PROFILE = "desktop-1280x720-win"


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
    p.add_argument("--check-coverage", action="store_true")
    p.add_argument("--godot", default="")
    p.add_argument("--apk", default="")
    return p


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


def run_ui_cases(cases: list[dict], run_id: str, godot: str, seed_default: int) -> list[dict]:
    run_dir = ROOT / "build/qa" / run_id
    results = []
    for case in cases:
        result_path = run_dir / "results" / (case["id"].replace("/", "__") + ".json")
        log_path = run_dir / "logs" / (case["id"].replace("/", "__") + ".log")
        result_path.parent.mkdir(parents=True, exist_ok=True)
        log_path.parent.mkdir(parents=True, exist_ok=True)
        cmd = [godot, "--path", str(ROOT), "tests/execution/ui_entry.tscn", "--",
               "--qa-case=" + case["file"],
               "--qa-id=" + case["id"],
               "--qa-report=" + str(result_path),
               "--qa-artifacts=" + str(run_dir / "desktop"),
               "--qa-seed=" + str(case.get("seed", seed_default))]
        proc = subprocess.run(cmd, cwd=ROOT, timeout=120, capture_output=True, text=True,
                              encoding="utf-8", errors="replace")
        log_path.write_text((proc.stdout or "") + "\n" + (proc.stderr or ""), encoding="utf-8")
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
    return results


def write_case_results(results, run_id):
    run_dir = ROOT / "build/qa" / run_id / "results"
    run_dir.mkdir(parents=True, exist_ok=True)
    for r in results:
        if "id" not in r:
            continue
        path = run_dir / (r["id"].replace("/", "__") + ".json")
        path.write_text(json.dumps(r, ensure_ascii=False, indent=2), encoding="utf-8")


def run_logic_cases(cases: list[dict], run_id: str, godot: str) -> list[dict]:
    run_dir = ROOT / "build/qa" / run_id
    report_dir = run_dir / "results"
    report_dir.mkdir(parents=True, exist_ok=True)
    ids = ",".join(c["id"] for c in cases)
    cmd = [godot, "--headless", "--path", str(ROOT),
           "--script", "res://tests/execution/logic_runner.gd", "--",
           "--qa-report-dir=" + str(report_dir),
           "--qa-cases=" + ids]
    proc = subprocess.run(cmd, cwd=ROOT, timeout=600, capture_output=True, text=True,
                          encoding="utf-8", errors="replace")
    (run_dir / "logs").mkdir(parents=True, exist_ok=True)
    (run_dir / "logs" / "logic.log").write_text((proc.stdout or "") + "\n" + (proc.stderr or ""), encoding="utf-8")
    results = []
    for case in cases:
        path = report_dir / (case["id"].replace("/", "__") + ".json")
        if path.exists():
            results.append(json.loads(path.read_text(encoding="utf-8")))
        else:
            results.append({"id": case["id"], "status": "ERROR", "error": "no result json",
                            "assertions": [], "shots": [], "steps": []})
    print(proc.stdout or "")
    return results


def retry_failed_ui_cases(results, run_id, godot, config):
    out = []
    for case in results:
        if case.get("status") not in ("FAIL", "ERROR") or "file" not in case:
            out.append(case)
            continue
        retry_case = {"id": case["id"], "file": case["file"], "seed": case.get("seed", 20261117)}
        retry_id = run_id + "-retry-" + case["id"].replace("/", "__")
        retry = run_ui_cases([retry_case], retry_id, godot, 20261117)
        retry_dir = ROOT / "build/qa" / retry_id
        retry = process_results(retry, DESKTOP_PROFILE, ROOT / "tests/baselines", retry_dir,
                                update=False, config=config)
        write_case_results(retry, retry_id)
        if retry and retry[0].get("status") == "PASS":
            case["status"] = "FLAKY"
            case["retry_passed"] = True
            case["retry_run"] = retry_id
        out.append(case)
    return out


def latest_apk():
    apks = sorted((ROOT / "build").glob("probably_stolen_*.apk"),
                  key=lambda p: p.stat().st_mtime, reverse=True)
    return apks[0] if apks else None


def device_available(serial):
    cmd = ["adb"] + (["-s", serial] if serial else []) + ["get-state"]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return proc.returncode == 0 and "device" in proc.stdout


def hash_tree(paths):
    h = hashlib.sha256()
    for root in paths:
        if not root.exists():
            continue
        for p in sorted(root.rglob("*")):
            if not p.is_file():
                continue
            h.update(str(p.relative_to(ROOT)).replace("\\", "/").encode())
            h.update(str(p.stat().st_size).encode())
            with p.open("rb") as f:
                for chunk in iter(lambda: f.read(1024 * 1024), b""):
                    h.update(chunk)
    return h.hexdigest()[:16]


def run_map_builder(run_dir: pathlib.Path, godot: str) -> int:
    out_path = run_dir / "control_map.json"
    run_dir.mkdir(parents=True, exist_ok=True)
    cmd = [godot, "--path", str(ROOT), "tests/execution/map_builder.tscn", "--",
           "--qa-out=" + str(out_path)]
    proc = subprocess.run(cmd, cwd=ROOT, timeout=180, capture_output=True, text=True,
                          encoding="utf-8", errors="replace")
    (run_dir / "map_builder.log").write_text((proc.stdout or "") + "\n" + (proc.stderr or ""),
                                             encoding="utf-8")
    if not out_path.exists():
        print("control_map.json not found:", out_path)
        print((proc.stdout or "")[-2000:])
        return 2
    data = json.loads(out_path.read_text(encoding="utf-8"))
    ui_map_path = ROOT / "tests/control/ui_map.json"
    ui_map = json.loads(ui_map_path.read_text(encoding="utf-8"))
    merged = {f"{screen}.{key}": v for screen, keys in data.items() for key, v in keys.items()}
    ui_map["device"] = merged
    ui_map_path.write_text(json.dumps(ui_map, ensure_ascii=False, indent=2), encoding="utf-8")
    print("updated", ui_map_path, "device keys:", len(ui_map["device"]))
    return 0


def main(argv=None) -> int:
    args = build_parser().parse_args(argv)
    manifest = load_manifest()
    cases = select_cases(manifest, args.suite, args.filter)
    godot = args.godot or DEFAULT_GODOT
    if not pathlib.Path(godot).exists():
        print("Godot not found:", godot)
        return 2
    run_id = time.strftime("%Y%m%d-%H%M%S")
    run_dir = ROOT / "build/qa" / run_id
    if args.build_control_map:
        return run_map_builder(run_dir, godot)
    if args.check_coverage:
        from tests.tools.check_coverage import main as coverage_main
        return coverage_main()
    device_profile = None
    results = []
    if args.suite in ("logic", "full", "smoke"):
        logic_cases = [c for c in cases if c.get("runner") == "logic"]
        if logic_cases:
            results += run_logic_cases(logic_cases, run_id, godot)
    if args.suite in ("ui", "full", "smoke"):
        ui_cases = [c for c in cases if c.get("runner") == "ui"]
        if ui_cases:
            ui_results = run_ui_cases(ui_cases, run_id, godot, 20261117)
            config = load_config(ROOT / "tests/screenshot/config.json")
            process_results(ui_results, DESKTOP_PROFILE, ROOT / "tests/baselines", run_dir,
                            update=args.update_baselines, config=config)
            if not args.update_baselines:
                ui_results = retry_failed_ui_cases(ui_results, run_id, godot, config)
            write_case_results(ui_results, run_id)
            results += ui_results
            for r in ui_results:
                print(("%s %s" % (r.get("status", "ERROR"), r.get("id"))))
    if args.suite in ("device", "full", "smoke"):
        device_cases = [c for c in cases if c.get("runner") == "device"]
        if device_cases:
            from tests.execution.device_runner import run_cases
            if not device_available(args.serial):
                if args.require_device:
                    print("device required but unavailable")
                    return 2
                results += [{"id": c["id"], "status": "SKIP", "error": "device offline",
                             "assertions": [], "shots": [], "steps": []} for c in device_cases]
            else:
                apk = pathlib.Path(args.apk) if args.apk else latest_apk()
                device_config = load_config(ROOT / "tests/screenshot/config.json")
                try:
                    device_results, device_profile = run_cases(
                        device_cases, run_dir, args.serial, args.fresh_device,
                        args.update_baselines, apk)
                except Exception as e:
                    device_results = [{"id": c["id"], "status": "ERROR",
                                       "error": "%s: %s" % (type(e).__name__, e),
                                       "assertions": [], "shots": [], "steps": []}
                                      for c in device_cases]
                    device_profile = None
                if device_profile:
                    process_results(device_results, device_profile, ROOT / "tests/baselines",
                                    run_dir, update=args.update_baselines, config=device_config)
                if not args.update_baselines:
                    failed = [r for r in device_results if r.get("status") not in ("PASS", "SKIP")]
                    if failed:
                        failed_ids = {r["id"] for r in failed}
                        retry_cases = [c for c in device_cases if c["id"] in failed_ids]
                        retry_id = run_id + "-retry-device"
                        retry_dir = ROOT / "build/qa" / retry_id
                        try:
                            retry_results, retry_profile = run_cases(
                                retry_cases, retry_dir, args.serial, args.fresh_device,
                                False, apk)
                        except Exception as e:
                            retry_results = [{"id": c["id"], "status": "ERROR",
                                              "error": "%s: %s" % (type(e).__name__, e),
                                              "assertions": [], "shots": [], "steps": []}
                                             for c in retry_cases]
                            retry_profile = None
                        if retry_profile:
                            process_results(retry_results, retry_profile, ROOT / "tests/baselines",
                                            retry_dir, update=False, config=device_config)
                        write_case_results(retry_results, retry_id)
                        retry_map = {r["id"]: r for r in retry_results}
                        for original in device_results:
                            match = retry_map.get(original["id"])
                            if original.get("status") not in ("PASS", "SKIP") and match and match.get("status") == "PASS":
                                original["status"] = "FLAKY"
                                original["retry_passed"] = True
                                original["retry_run"] = retry_id
                write_case_results(device_results, run_id)
                results += device_results
                for r in device_results:
                    print(("%s %s" % (r.get("status", "ERROR"), r.get("id"))))
    if not results:
        print("no cases selected")
        return 0
    known_path = ROOT / "tests/verdict/known_failures.json"
    known = json.loads(known_path.read_text(encoding="utf-8")) if known_path.exists() else []
    if args.reference_run:
        ref_path = ROOT / "build/qa" / args.reference_run / "report.json"
        reference = json.loads(ref_path.read_text(encoding="utf-8")) if ref_path.exists() else None
    else:
        reference = find_reference(ROOT / "build/qa/history.jsonl", ROOT / "build/qa", run_id)
    try:
        commit = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT,
                                         text=True).strip()
    except Exception:
        commit = "unknown"
    env = {"suite": args.suite, "profile": DESKTOP_PROFILE, "godot": godot, "commit": commit,
           "asset_hash": hash_tree([ROOT / "data", ROOT / "data_private", ROOT / "assets_private"])}
    if device_profile:
        env["device_profile"] = device_profile
    summary = summarize(results, reference, known, env)
    write_reports(run_dir, results, summary)
    with (ROOT / "build/qa" / "history.jsonl").open("a", encoding="utf-8") as f:
        f.write(json.dumps({"run_id": run_id, "suite": args.suite,
                            "conclusion": summary["conclusion"],
                            "regression_ok": summary["regression_ok"],
                            "counts": summary["counts"], "commit": commit},
                           ensure_ascii=False) + "\n")
    print("CONCLUSION:", summary["conclusion"])
    return exit_code(summary)


if __name__ == "__main__":
    sys.exit(main())
