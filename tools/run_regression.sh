#!/usr/bin/env bash
# Runs the full headless regression suite in the background-safe way (no phone, no UI).
set -u
cd "$(dirname "$0")/.."
GODOT="${GODOT_BIN:-C:/Users/EDY/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe}"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="build/test_logs/$STAMP"
mkdir -p "$OUT"
TESTS=(
  test_containers test_inspection test_inv test_aux_machines test_balance
  test_growth test_machines_durability test_machine_faults test_recipes_modules
  test_meta test_endings test_archive test_story_graphs
  test_barter test_wholesale test_phone test_phone_services test_combat test_combat_parties test_security test_customer_pools test_procurement test_special_customers test_market test_p1_container test_p1_wanted test_p1_night test_perks test_localization test_assets test_p0 test_p1 test_p2 test_l2_property test_l2_requests test_l2_perks test_l2_afterhours test_core_flow test_space
)
OVERALL=0
echo "Regression $STAMP" > "$OUT/summary.txt"
for t in "${TESTS[@]}"; do
  LOG="$OUT/$t.log"
  env timeout 240 "$GODOT" --path . --headless --script "scripts/$t.gd" > "$LOG" 2>&1
  RC=$?
  FAILS_LINE="$(grep -E '^FAILS=' "$LOG" | tail -1 || true)"
  ERR="$(grep -E 'SCRIPT ERROR|Parse Error' "$LOG" | head -1 || true)"
  if [ -n "$ERR" ]; then
    STATUS="FAIL"
    OVERALL=1
  elif [ -n "$FAILS_LINE" ]; then
    if [ "$FAILS_LINE" = "FAILS=0" ]; then STATUS="PASS"; else STATUS="FAIL"; OVERALL=1; fi
  elif [ "$RC" -ne 0 ] && [ "$RC" -ne 124 ]; then
    STATUS="FAIL"
    OVERALL=1
  else
    STATUS="OK"
  fi
  printf '%-28s %s  %s\n' "$t" "$STATUS" "${FAILS_LINE:-$ERR}" | tee -a "$OUT/summary.txt"
done
# Godot UI automation hooks: headless, no window, no phone.
UI_HOOKS=(testmachineui testcontainerui testbarterui testphoneui testcombatui testsecurityui testpresentationui testp0ui testp1ui testspaceui testp2ui)
UI_MARKERS=(MUI CUI BUI PUI CUI SUI PRUI P0UI P1UI SPUI P2UI)
for i in "${!UI_HOOKS[@]}"; do
  h="${UI_HOOKS[$i]}"
  marker="${UI_MARKERS[$i]}"
  LOG="$OUT/$h.log"
  env timeout 180 "$GODOT" --path . --headless --"$h" --quit-after 900 > "$LOG" 2>&1
  RC=$?
  ERR="$(grep -E 'SCRIPT ERROR|Parse Error' "$LOG" | head -1 || true)"
  if [ -n "$ERR" ]; then
    STATUS="FAIL"; OVERALL=1
  elif ! grep -q "$marker" "$LOG"; then
    STATUS="FAIL"; OVERALL=1
  else
    STATUS="PASS"
  fi
  printf '%-28s %s  %s
' "$h" "$STATUS" "${ERR:-headless UI}" | tee -a "$OUT/summary.txt"
done
echo "OVERALL=$([ "$OVERALL" -eq 0 ] && echo PASS || echo FAIL)" | tee -a "$OUT/summary.txt"
exit "$OVERALL"
