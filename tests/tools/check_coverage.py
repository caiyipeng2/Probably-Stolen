#!/usr/bin/env python3
# [L4 回归结论层] check_coverage.py — 防止新移植内容没有测试覆盖
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main() -> int:
    machines_path = ROOT / "data/machines.json"
    if not machines_path.exists():
        print("machines.json not found")
        return 2
    machines = json.loads(machines_path.read_text(encoding="utf-8"))
    ids = [str(m.get("id", "")) for m in machines]
    text = "\n".join(
        p.read_text(encoding="utf-8", errors="ignore")
        for p in (ROOT / "tests/execution/cases").rglob("*")
        if p.suffix in (".gd", ".json")
    )
    exempt_path = ROOT / "tests/tools/coverage_exempt.json"
    exempt = json.loads(exempt_path.read_text(encoding="utf-8")) if exempt_path.exists() else {}
    missing = [mid for mid in ids if mid and mid not in text and mid not in exempt]
    stale = [mid for mid in exempt if mid not in ids]
    for mid in missing:
        print("MISSING", mid)
    for mid in stale:
        print("STALE_EXEMPT", mid)
    print("machines=%d covered_or_exempt=%d missing=%d stale_exempt=%d"
          % (len(ids), len(ids) - len(missing), len(missing), len(stale)))
    return 1 if missing or stale else 0


if __name__ == "__main__":
    sys.exit(main())
