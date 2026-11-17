#!/usr/bin/env python3
# [L2 执行层] device_runner.py — 真机声明式流程执行与稳定帧截图
import json
import time
import traceback
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
        if not _stable_shot(driver, dest, timeout=3):
            raise DeviceError("unstable screenshot: " + name)
        if update:
            return {"name": name, "file": str(dest), "status": "PENDING"}
        raise DeviceError("missing wait_screen baseline: " + name)
    cfg = dict(config.get("defaults", {}))
    cfg.update(config.get("profiles", {}).get(profile, {}))
    deadline = time.time() + timeout_ms / 1000.0
    while time.time() < deadline:
        if not _stable_shot(driver, dest, timeout=3):
            continue
        res = compare_image(dest, baseline, None, cfg)
        if res["status"] == "PASS":
            return {"name": name, "file": str(dest), "status": "PENDING"}
        time.sleep(0.3)
    raise DeviceError("wait_screen timeout: " + shot_name)


def run_cases(cases, run_dir, serial, fresh, update_baselines, apk=None):
    driver = DeviceDriver(serial=serial, ui_map_path=str(Path(__file__).resolve().parents[1] / "control/ui_map.json"))
    if not fresh:
        return [{"id": c["id"], "status": "SKIP", "error": "requires --fresh-device",
                 "assertions": [], "shots": [], "steps": []} for c in cases], None
    if apk:
        try:
            driver.install(apk)
        except Exception as e:
            msg = "install failed: %s: %s" % (type(e).__name__, e)
            return [{"id": c["id"], "status": "ERROR", "error": msg,
                     "assertions": [], "shots": [], "steps": []} for c in cases], None
    config = load_config(Path(__file__).resolve().parent.parent / "screenshot/config.json")
    baselines_root = Path(__file__).resolve().parents[2] / "tests/baselines"
    results = []
    profile = None
    for entry in cases:
        case_id = entry["id"]
        shots, steps, error = [], [], ""
        try:
            flow_path = Path(__file__).resolve().parents[2] / "tests/execution" / entry["file"]
            flow = json.loads(flow_path.read_text(encoding="utf-8"))
            case = {"id": case_id, "steps": flow.get("steps", []),
                    "seed": flow.get("seed", entry.get("seed", 20261117))}
            driver.wake()
            driver.force_stop()
            driver.clear_data()
            driver.wake()
            driver.launch()
            time.sleep(5)
            info = driver.device_info()
            profile = info["profile"]
            driver.force_stop()
            driver.write_user_file("qa_seed.txt", str(case.get("seed", 20261117)))
            driver.wake()
            driver.launch()
            time.sleep(5)
            for i, step in enumerate(case["steps"], 1):
                action = step["action"]
                if action == "tap":
                    driver.tap_key(step["target"])
                    time.sleep(0.5)
                elif action == "drag":
                    driver.drag_key(step["from"], step["to"], int(step.get("duration_ms", 400)))
                    time.sleep(0.8)
                elif action == "wait_screen":
                    shot = _wait_screen(driver, case, i, step["shot"], profile, baselines_root,
                                        run_dir, config, update_baselines,
                                        int(step.get("timeout_ms", 10000)))
                    shots.append(shot)
                    steps.append({"title": "wait_screen:" + step["shot"]})
                elif action == "shot":
                    name = "%02d_%s" % (i, step["shot"])
                    dest = run_dir / "device" / case["id"].replace("/", "_") / (name + ".png")
                    if not _stable_shot(driver, dest):
                        raise DeviceError("unstable screenshot: " + name)
                    shots.append({"name": name, "file": str(dest), "status": "PENDING"})
                    steps.append({"title": "shot:" + step["shot"]})
                else:
                    raise DeviceError("unknown action " + action)
        except Exception as e:
            error = "%s: %s" % (type(e).__name__, e)
            log_path = run_dir / "logs" / (case_id.replace("/", "__") + ".log")
            log_path.parent.mkdir(parents=True, exist_ok=True)
            log_path.write_text(traceback.format_exc(), encoding="utf-8")
        results.append({"id": case_id, "status": "ERROR" if error else "PASS",
                        "error": error, "assertions": [], "shots": shots, "steps": steps})
    return results, profile
