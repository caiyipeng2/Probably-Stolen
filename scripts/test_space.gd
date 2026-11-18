extends SceneTree
var fails := 0
func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok: fails += 1
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	check(gs.space_ships.size() == 4, "space ships loaded", str(gs.space_ships.size()))
	check(gs.space_pois.size() >= 23, "space POIs loaded", str(gs.space_pois.size()))
	var st: Dictionary = gs.space_start("cargo_ship")
	check(bool(st.get("ok", false)) and gs.space_fuel == 50 and gs.space_hull == 100, "space start", str(gs.space_fuel))
	var scan: Array = gs.space_scan()
	check(scan.size() == 4, "space scan returns 4", str(scan.size()))
	gs.space_poi = {"id": "mining_asteroid", "name": "采矿小行星", "kind": "mining", "distance": 20}
	var travel: Dictionary = gs.space_travel(gs.space_poi)
	check(bool(travel.get("ok", false)) and gs.space_fuel == 48, "space travel fuel", str(gs.space_fuel))
	var resolved: Dictionary = gs.space_resolve("mine")
	check(bool(resolved.get("ok", false)), "space mining resolve", str(resolved.get("text", "")))
	gs.space_poi = {"id": "trade_station", "name": "贸易站", "kind": "station", "distance": 30}
	gs.space_at_station = true
	var dock: Dictionary = gs.space_dock()
	check(bool(dock.get("ok", false)) and gs.combat_active and gs.combat_context == "space_station", "space station dock combat")
	check(gs.advance_space_raid(), "space raid next room")
	check(not gs.advance_space_raid(), "space raid finished")
	gs.space_at_station = true
	var saved: bool = gs.save_game(2)
	gs.space_mode = false
	gs.load_game(2)
	check(saved and gs.space_mode and gs.space_ship.get("id", "") == "cargo_ship", "space state persisted")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
