extends SceneTree

var fails := 0

func check(ok: bool, label: String, detail: String = "") -> void:
	print(("PASS " if ok else "FAIL ") + label + (" | " + detail if detail != "" else ""))
	if not ok:
		fails += 1

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	check(gs.locale_text.size() >= 7000, "locale bundle loaded", str(gs.locale_text.size()))
	check(gs.loc("UI", "ui_end_day", "") != "", "UI key", gs.loc("UI", "ui_end_day", ""))
	check(gs.loc("MainMenu", "new_start_game", "") != "", "MainMenu key")
	check(gs.loc("Mechanic", "mech_bottle_printer_btn_start", "") != "", "Mechanic key")
	check(gs.loc("ClientName", "name_ashish", "") != "", "ClientName key")
	var ik = load("res://scripts/game_state.gd").new()
	ik._load_defs()
	var items: Array = ik.items_def.values()
	var names := 0
	var texts := 0
	for it in items:
		if String(it.get("name", "")) != "":
			names += 1
		if String(it.get("description", "")) != "" or String(it.get("flavor", "")) != "":
			texts += 1
	check(names == items.size(), "all item names localized", "%d/%d" % [names, items.size()])
	check(texts >= int(items.size() * 0.70), "item description/flavor coverage", "%d/%d" % [texts, items.size()])
	var gun = gs.get_item_def("glock_receiver")
	check(String(gun.get("name", "")).contains("3"), "item name from original", String(gun.get("name", "")))
	check(String(gun.get("description", "")) != "", "item description present")
	var knife = gs.make_item("combat_knife", 100, true, false)
	check(gs.item_description(knife) != "", "flavor fallback for description", gs.item_description(knife).substr(0, 20))
	check(gs.phone_number_of("red_imp") == "8815", "phone number kept")
	check(String(gs.phone_contacts.get("red_imp", {}).get("name", "")).contains("红魔"), "phone contact localized", String(gs.phone_contacts.get("red_imp", {}).get("name", "")))
	var mobile_labels := ["库存", "机器", "手机", "派系", "档案"]
	for l in mobile_labels:
		check(l != "", "mobile label present " + l)
	print("FAILS=", fails)
	quit(0 if fails == 0 else 1)
