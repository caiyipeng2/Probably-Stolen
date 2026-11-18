extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func _init() -> void:
	var names := ["music_main.ogg", "ambience_station.ogg", "sfx_gun.ogg", "sfx_cash.ogg", "sfx_hit.ogg", "sfx_phone_pickup.ogg", "sfx_open_case.ogg", "sfx_shotgun.ogg", "sfx_airlock.ogg"]
	var found := 0
	for n in names:
		if FileAccess.file_exists("res://assets_private/audio_original/" + n):
			found += 1
	check(found == names.size(), "original audio assets present", "%d/%d" % [found, names.size()])
	var music = load("res://assets_private/audio_original/music_main.ogg")
	check(music != null and music.get_length() > 100.0, "original main theme loaded", str(music.get_length() if music else 0))
	var amb = load("res://assets_private/audio_original/ambience_station.ogg")
	check(amb != null and amb.get_length() > 300.0, "original ambience loaded", str(amb.get_length() if amb else 0))
	var portraits := ["maleUpper_0.png", "maleUpper_2.png", "femaleUpper_1.png", "maleSec_0.png", "femaleBM_2.png", "femaleRev_2.png"]
	var pfound := 0
	for p in portraits:
		if FileAccess.file_exists("res://assets/customers/" + p):
			pfound += 1
	check(pfound == portraits.size(), "original character portraits present", "%d/%d" % [pfound, portraits.size()])
	var custdir := DirAccess.open("res://assets/customers")
	var cust_count := 0
	if custdir:
		for f in custdir.get_files():
			if f.ends_with(".png"):
				cust_count += 1
	check(cust_count >= 130, "full original client sprite bank", str(cust_count))
	check(FileAccess.file_exists("res://assets_private/items/glock_receiver.png"), "original item sprite present")
	var audio_count := 0
	var dir := DirAccess.open("res://assets_private/audio_original")
	if dir:
		for f in dir.get_files():
			if f.ends_with(".ogg") and not f.ends_with(".ogg.import"):
				audio_count += 1
	check(audio_count >= 270, "full original audio bank converted", str(audio_count))
	check(FileAccess.file_exists("res://assets_private/audio_original/01_a_bao_a_qu_pristine.ogg"), "radio pristine song present")
	check(FileAccess.file_exists("res://assets_private/audio_original/sfx_meaty_drop.ogg"), "material drag sfx present")
	check(FileAccess.file_exists("res://assets/art/shop_scene_base.png"), "original scene base present")
	var ui_count := 0
	var uidir := DirAccess.open("res://assets_private/ui_icons")
	if uidir:
		for f in uidir.get_files():
			if f.ends_with(".png"):
				ui_count += 1
	check(ui_count >= 250, "original UI icon slices present", str(ui_count))
	check(FileAccess.file_exists("res://assets_private/ui_icons/BREWER.png"), "upgrade icon present")
	var panel_names := ["panel.png", "window_frame.png", "slot_frame.png", "inspection_receipt.png", "newspaper.png"]
	var panel_found := 0
	for pn in panel_names:
		if FileAccess.file_exists("res://assets_private/ui_panels/" + pn):
			panel_found += 1
	check(panel_found == panel_names.size(), "original 9-slice panels present", "%d/%d" % [panel_found, panel_names.size()])
	var walker_found := 0
	for i in range(8):
		if FileAccess.file_exists("res://assets_private/walkers/walker1_%d.png" % i):
			walker_found += 1
	check(walker_found == 8, "original walker frames present", "%d/8" % walker_found)
	var shot_found := 0
	for i in range(8):
		if FileAccess.file_exists("res://assets_private/shot_anim/shot_animation_body_%d.png" % i):
			shot_found += 1
	for i in range(6):
		if FileAccess.file_exists("res://assets_private/shot_anim/shot_animation_wound_%d.png" % i):
			shot_found += 1
	check(shot_found >= 12, "original shot animation frames present", str(shot_found))
	var public_audio := load("res://assets_public/audio/music_main.ogg")
	check(public_audio != null, "public audio fallback present")
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
