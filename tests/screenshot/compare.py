#!/usr/bin/env python3
# [L3 截图验证测试层] compare.py — 基线比对、遮罩、差异图
import json
import shutil
from pathlib import Path

import numpy as np
from PIL import Image


def load_mask(mask_path: Path | None) -> dict | None:
    if mask_path and mask_path.exists():
        return json.loads(mask_path.read_text(encoding="utf-8"))
    return None


def _mask_array(mask: dict | None, size) -> np.ndarray:
    w, h = size
    arr = np.ones((h, w), dtype=bool)
    for r in (mask or {}).get("regions", []):
        x0 = max(0, int(float(r["x"]) * w))
        y0 = max(0, int(float(r["y"]) * h))
        x1 = min(w, int((float(r["x"]) + float(r["w"])) * w))
        y1 = min(h, int((float(r["y"]) + float(r["h"])) * h))
        arr[y0:y1, x0:x1] = False
    return arr


def compare_image(current: Path, baseline: Path, mask: dict | None, cfg: dict,
                  diff_path: Path | None = None) -> dict:
    if not baseline.exists():
        return {"status": "NEW_BASELINE", "reason": "missing baseline",
                "diff_pixels": 0, "diff_ratio": 0.0}
    if not current.exists():
        return {"status": "ERROR", "reason": "missing current image",
                "diff_pixels": 0, "diff_ratio": 0.0}
    img_c = Image.open(current).convert("RGB")
    img_b = Image.open(baseline).convert("RGB")
    if img_c.size != img_b.size:
        return {"status": "FAIL", "reason": "size mismatch %s vs %s" % (img_c.size, img_b.size),
                "diff_pixels": 0, "diff_ratio": 1.0}
    a = np.asarray(img_c, dtype=np.int16)
    b = np.asarray(img_b, dtype=np.int16)
    diff = np.abs(a - b).max(axis=2)
    mask_arr = _mask_array(mask, img_c.size)
    total = int(mask_arr.sum())
    if total <= 0:
        return {"status": "ERROR", "reason": "mask covers entire image",
                "diff_pixels": 0, "diff_ratio": 0.0}
    tolerance = int(cfg.get("pixel_tolerance", 3))
    bad = (diff > tolerance) & mask_arr
    changed = int(bad.sum())
    ratio = changed / total
    status = "PASS" if ratio <= float(cfg.get("diff_ratio_max", 0.001)) else "FAIL"
    diff_image = None
    if diff_path and status == "FAIL":
        overlay = np.array(img_c)
        overlay[bad] = [255, 0, 0]
        diff_path.parent.mkdir(parents=True, exist_ok=True)
        Image.fromarray(overlay).save(diff_path)
        diff_image = str(diff_path)
    return {"status": status, "reason": "", "diff_pixels": changed,
            "diff_ratio": ratio, "diff_image": diff_image}


def load_config(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}


def process_results(results, profile, baselines_root, run_dir, update=False, config=None):
    config = config or {}
    base = baselines_root / profile
    masks_root = Path(__file__).resolve().parent / "masks"
    changes = []
    for case in results:
        for shot in case.get("shots", []):
            if shot.get("status") not in ("PENDING", None):
                continue
            baseline = base / case["id"] / (shot["name"] + ".png")
            mask = load_mask(masks_root / case["id"] / (shot["name"] + ".json"))
            cfg = dict(config.get("defaults", {}))
            cfg.update(config.get("profiles", {}).get(profile, {}))
            cfg.update(config.get("overrides", {}).get(case["id"] + "/" + shot["name"], {}))
            if update:
                baseline.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(shot["file"], baseline)
                shot.update({"status": "PASS", "baseline_updated": True, "diff_ratio": 0.0})
                changes.append("- 更新 `%s` ← `%s`" % (baseline, shot["file"]))
                continue
            diff_path = Path(shot["file"]).with_name("diff_" + Path(shot["file"]).name)
            res = compare_image(Path(shot["file"]), baseline, mask, cfg, diff_path)
            shot.update(res)
        if any(s.get("status") in ("FAIL", "ERROR", "NEW_BASELINE") for s in case.get("shots", [])):
            case["status"] = "FAIL"
    if update and changes:
        run_dir.mkdir(parents=True, exist_ok=True)
        (run_dir / "baseline_changes.md").write_text("\n".join(changes) + "\n", encoding="utf-8")
    return results
