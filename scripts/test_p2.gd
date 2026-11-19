extends SceneTree
var fails := 0
func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok: fails += 1
func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game("normal", "original", "apprentice", [])
	check(FileAccess.file_exists("res://assets_private/posters/poster.png"), "poster art present")
	check(FileAccess.file_exists("res://assets_private/posters/poster_down.png"), "poster down art present")
	var p1: bool = gs.toggle_poster()
	var p2: bool = gs.toggle_poster()
	check(p1 and not p2, "poster toggle state")
	check(gs.commissary_defs.any(func(i): return String(i.get("id", "")) == "mouse_trap"), "mouse trap in commissary")
	check(FileAccess.file_exists("res://assets_private/audio_original/new_bell.ogg"), "bell sfx present")
	check(FileAccess.file_exists("res://assets_private/audio_original/pour_water.ogg"), "water sfx present")
	check(FileAccess.file_exists("res://assets_private/audio_original/ping_sonar.ogg"), "sonar sfx present")
	var food: Dictionary = gs.make_item("nutrifruit", 100, true, false)
	gs.add_item(food)
	gs.add_item(gs.make_item("mouse_trap", 100, true, false))
	gs.rng.seed = 21
	var log_before: int = gs.night_log.size()
	for i in range(120):
		gs._night_rats()
		if gs.night_log.size() > log_before:
			break
	check(gs.night_log.size() > log_before, "rat night event fires", str(gs.night_log[-1] if not gs.night_log.is_empty() else ""))
	var log_text := String(gs.night_log[-1]) if not gs.night_log.is_empty() else ""
	check("捕鼠器" in log_text or "老鼠" in log_text, "rat outcome logged", log_text)
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
