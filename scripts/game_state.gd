extends Node

signal state_changed
signal customer_changed
signal day_finished(summary)
signal event_started(event)
signal machine_finished(message)
signal story_available(node_id)
signal combat_started
signal combat_updated
signal combat_finished(victory, message)

const GRID_W := 16
const GRID_H := 3
const GRID_PAGES := 3
const DISPLAY_SLOTS := 6
const RETAIL_MARKUP := 15.0
const MACHINE_FAULTS := {
	"jam": {"name": "卡料", "fee": 30},
	"surge": {"name": "电压浪涌", "fee": 60},
	"contamination": {"name": "污染", "fee": 80},
}
const GROWTH_MACHINES := ["hydroponic", "ras"]
const GROWTH_HARVESTS := 3
const DIFFICULTY := {
	"easy": {"name": "简单", "cash": 800, "rent": 150, "budget": 1.15, "damage": 0.8},
	"normal": {"name": "普通", "cash": 600, "rent": 200, "budget": 1.0, "damage": 1.0},
	"hard": {"name": "困难", "cash": 450, "rent": 260, "budget": 0.9, "damage": 1.25},
}

var items_def: Dictionary = {}
var tradable_pool: Array = []
var pages_unlocked := 2
var max_pages_unlocked := 2
var customer_defs: Array = []
var events: Array = []
var machines: Array = []
var factions: Array = []
var upgrades: Array = []
var owned_upgrades: Dictionary = {}
var professions: Array = []
var profession_id := ""
var profession_chosen := false
var commissions: Array = []
var story_nodes: Dictionary = {}
var story_seen: Array = []
var story_flags: Dictionary = {}
var pending_story := ""
var story_queue: Array = []
var story_scenes: Array = []
var scene_seen: Array = []
var dialogue_archive: Array = []
var story_graphs: Dictionary = {}
var original_days: Dictionary = {}
var campaign_mode := "mobile"
var combat_data: Array = []
var wanted: Array = []
var endings: Array = []
var wanted_defeated: Array = []
var combat_active := false
var combat_enemy: Dictionary = {}
var combat_enemy_hp := 0
var combat_player_hp := 60
var combat_player_max := 60
var combat_log: Array = []
var combat_skill_cd := 0
var combat_guarding := false
var combat_wanted_id := ""
var combat_context := ""
var ending_id := ""
var machine_jobs: Array = []
var power := 10
var max_power := 10
var machine_modules: Dictionary = {}
var machine_temps: Dictionary = {}
var machine_durability: Dictionary = {}
var machine_faults: Dictionary = {}
var machine_recipes: Dictionary = {}
var modules_def: Array = []
var machine_active: Dictionary = {}
var machine_stock: Dictionary = {}
var machine_cash: Dictionary = {}
var machine_upgrades: Dictionary = {}
var machine_state: Dictionary = {}
var night_log: Array = []
var next_day_power_bonus := 0
var attraction_bonus := 100
var bargain_bonus := 0
var security_alarm_active := false
var security_stop_rate := 0
signal music_toggled(on: bool)

var difficulty := "normal"
var day := 1
var cash := 600
var rent := 200
var rent_due := 6
var loan := 200
var loan_due := 12
var rep := {"lower": 0, "security": 0, "blackmarket": 0, "upper": 0, "rev": 0, "tourist": 0, "church": 0, "cartel": 0}
var inventory: Array = []
var display: Array = []
var customers_today: Array = []
var current_index := -1
var current_customer: Dictionary = {}
var counter_item: Dictionary = {}
var phase := "open"
var daily := {"sales": 0, "purchases": 0, "rent": 0, "fees": 0}
var uid_counter := 1
var rng := RandomNumberGenerator.new()
var pending_event: Dictionary = {}
var tutorial_done := false
var tutorial_step := 0

func _ready() -> void:
	rng.randomize()
	_load_defs()
	new_game()

func _fmt_placeholder_name(text: String, count: int = 1) -> String:
	return text.replace("{0}", str(count)).replace("{1}", str(count))

func _load_defs() -> void:
	var f := FileAccess.open("res://data/items.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			for d in data:
				d["name"] = _fmt_placeholder_name(String(d.get("name", d["id"])), int(d.get("name_count", 1)))
				items_def[d["id"]] = d
	var priv := FileAccess.open("res://data_private/items_full.json", FileAccess.READ)
	if priv:
		var pdata = JSON.parse_string(priv.get_as_text())
		if pdata is Array:
			for p in pdata:
				var id := String(p.get("id", ""))
				if id == "":
					continue
				var src := String(p.get("source", ""))
				if src.begins_with("NpcCharacter") or src.begins_with("PlayerCharacter") or src == "CharacterItemDirectory.cs":
					continue
				var norm: Dictionary = p.duplicate(true)
				norm["base_value"] = int(p.get("base_value", 0))
				if int(norm["base_value"]) <= 0:
					norm["base_value"] = 10
				norm["name"] = _fmt_placeholder_name(String(p.get("name", id)), int(p.get("name_count", 1)))
				norm["description"] = String(p.get("description", ""))
				norm["icon"] = String(p.get("icon", ""))
				norm["shape"] = p.get("shape", [1, 1])
				norm["inspect_type"] = String(p.get("inspect_type", "generic"))
				var cat := String(p.get("category", "misc"))
				var tags: Array = p.get("tags", []).duplicate()
				if not tags.has(cat):
					tags.append(cat)
				for t in p.get("types", []):
					var tl := String(t).to_lower()
					if not tags.has(tl):
						tags.append(tl)
				norm["tags"] = tags
				if not items_def.has(id):
					items_def[id] = norm
				else:
					var base: Dictionary = items_def[id].duplicate(true)
					if String(base.get("name", "")) == id or String(base.get("name", "")) == "":
						base["name"] = norm["name"]
					if String(base.get("description", "")) == "":
						base["description"] = norm["description"]
					if String(base.get("icon", "")) == "":
						base["icon"] = norm["icon"]
					if int(base.get("base_value", 0)) <= 0:
						base["base_value"] = norm["base_value"]
					if not base.has("shape"):
						base["shape"] = norm["shape"]
					if String(base.get("inspect_type", "generic")) == "generic":
						base["inspect_type"] = norm["inspect_type"]
					var btags: Array = base.get("tags", []).duplicate()
					for t in tags:
						if not btags.has(t):
							btags.append(t)
					base["tags"] = btags
					items_def[id] = base
	var supplement := FileAccess.open("res://data_private/items_supplement.json", FileAccess.READ)
	if supplement:
		var sdata = JSON.parse_string(supplement.get_as_text())
		if sdata is Array:
			for s in sdata:
				var sid := String(s.get("id", ""))
				if sid == "" or items_def.has(sid):
					continue
				var sn: Dictionary = s.duplicate(true)
				sn["base_value"] = int(s.get("base_value", 10))
				sn["name"] = _fmt_placeholder_name(String(s.get("name", sid)), int(s.get("name_count", 1)))
				sn["description"] = String(s.get("description", ""))
				sn["icon"] = String(s.get("icon", ""))
				sn["shape"] = s.get("shape", [1, 1])
				sn["inspect_type"] = String(s.get("inspect_type", "generic"))
				var stags: Array = s.get("tags", []).duplicate()
				if not stags.has(String(s.get("category", "misc"))):
					stags.append(String(s.get("category", "misc")))
				sn["tags"] = stags
				items_def[sid] = sn
	tradable_pool = []
	var blocked_ids := ["hand", "rev_codeword", "animal_cage", "auto_butcher", "printer", "box_dispenser", "deal_maker", "wine_rack", "plant_dna_manipulator"]
	for id in items_def.keys():
		var d: Dictionary = items_def[id]
		var sid := String(id)
		if int(d.get("base_value", 0)) <= 0:
			continue
		if String(d.get("icon", "")) == "":
			continue
		if String(d.get("category", "")) == "furniture":
			continue
		if sid.begins_with("pirate_") or sid.begins_with("deserter_") or sid.begins_with("xeno_") or sid.begins_with("test_") or sid.begins_with("debug_"):
			continue
		if sid.contains("save_bag") or sid in blocked_ids:
			continue
		tradable_pool.append(id)
	f = FileAccess.open("res://data/customers.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			customer_defs = data
	f = FileAccess.open("res://data/events.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			events = data
	f = FileAccess.open("res://data/machines.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			machines = data
	f = FileAccess.open("res://data/modules.json", FileAccess.READ)
	if f:
		var mods = JSON.parse_string(f.get_as_text())
		if mods is Array:
			modules_def = mods
	f = FileAccess.open("res://data/factions.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			factions = data
	f = FileAccess.open("res://data/upgrades.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			upgrades = data
	f = FileAccess.open("res://data/professions.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			professions = data
	f = FileAccess.open("res://data/story.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			for node in data:
				story_nodes[String(node.get("id", ""))] = node
	_load_story_scenes()
	var schedule := FileAccess.open("res://data_private/story_schedule_original.json", FileAccess.READ)
	if schedule:
		var sdata = JSON.parse_string(schedule.get_as_text())
		if sdata is Dictionary:
			original_days = sdata.get("days", {})
	var graph_file := FileAccess.open("res://data_private/story_graphs.json", FileAccess.READ)
	if graph_file:
		var gdata = JSON.parse_string(graph_file.get_as_text())
		if gdata is Dictionary:
			story_graphs = gdata.get("clients", {})
	var archive := FileAccess.open("res://data_private/dialogue_archive.json", FileAccess.READ)
	if archive:
		var adata = JSON.parse_string(archive.get_as_text())
		if adata is Dictionary:
			dialogue_archive = adata.get("groups", [])
	f = FileAccess.open("res://data/combat.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			combat_data = data
	f = FileAccess.open("res://data/wanted.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			wanted = data
	f = FileAccess.open("res://data/endings.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			endings = data

func get_item_def(id: String) -> Dictionary:
	return items_def.get(id, {})

func make_item(def_id: String, condition: int = 100, authentic: bool = true, stolen: bool = false) -> Dictionary:
	var def := get_item_def(def_id)
	return {
		"uid": next_uid(),
		"def_id": def_id,
		"condition": condition,
		"authentic": authentic,
		"stolen": stolen,
		"known": false,
		"inspect_count": 0,
		"clues": [],
		"features": _roll_features(def_id),
		"x": -1,
		"y": -1,
		"page": 0,
		"rotated": false,
		"location": "backpack",
	}

func _roll_features(def_id: String) -> Array:
	var def := get_item_def(def_id)
	var itype := String(def.get("inspect_type", "generic"))
	var pool: Array = []
	match itype:
		"water":
			pool = [{"id":"clean","name":"清澈","mod":6},{"id":"mineral","name":"矿物质偏高","mod":-4},{"id":"contaminated","name":"有沉淀","mod":-12}]
		"cig":
			pool = [{"id":"sealed","name":"封口完好","mod":5},{"id":"resealed","name":"二次封装","mod":-15},{"id":"stale","name":"受潮","mod":-8}]
		"cyber", "weapon":
			pool = [{"id":"serial_intact","name":"序列号完整","mod":8},{"id":"serial_ground","name":"序列号磨损","mod":-12},{"id":"polished","name":"翻新过","mod":3}]
		"organ":
			pool = [{"id":"cold_chain","name":"冷链完好","mod":10},{"id":"warm","name":"冷链中断","mod":-20}]
		"food":
			pool = [{"id":"fresh","name":"新鲜","mod":5},{"id":"expired","name":"临近过期","mod":-10}]
		_:
			pool = [{"id":"clean","name":"成色不错","mod":4},{"id":"worn","name":"使用痕迹","mod":-6},{"id":"engraved","name":"有刻字","mod":3},{"id":"bloody","name":"血渍","mod":-10}]
	var out: Array = []
	var n := rng.randi_range(0, 2)
	for i in range(n):
		out.append(pool[rng.randi_range(0, pool.size() - 1)].duplicate(true))
	return out

func next_uid() -> int:
	uid_counter += 1
	return uid_counter - 1

func item_shape(item: Dictionary) -> Array:
	var def := get_item_def(item["def_id"])
	var s = def.get("shape", [1, 1])
	if item.get("rotated", false):
		return [s[1], s[0]]
	return [s[0], s[1]]

func item_cells(item: Dictionary, ox: int = -1, oy: int = -1) -> Array:
	var s := item_shape(item)
	var x: int = int(item["x"]) if ox < 0 else ox
	var y: int = int(item["y"]) if oy < 0 else oy
	var out: Array = []
	for dy in range(s[1]):
		for dx in range(s[0]):
			out.append(Vector2i(x + dx, y + dy))
	return out

func can_place(item: Dictionary, x: int, y: int, rotated: bool, ignore_uid: int = -1, page: int = 0) -> bool:
	var s = get_item_def(item["def_id"]).get("shape", [1, 1])
	var w: int = s[1] if rotated else s[0]
	var h: int = s[0] if rotated else s[1]
	if x < 0 or y < 0 or x + w > GRID_W or y + h > GRID_H:
		return false
	var test := {}
	for dy in range(h):
		for dx in range(w):
			test[Vector2i(x + dx, y + dy)] = true
	for other in inventory:
		if other["uid"] == item["uid"] or other["uid"] == ignore_uid:
			continue
		if other.get("location", "backpack") != "backpack":
			continue
		if int(other.get("page", 0)) != page:
			continue
		for c in item_cells(other):
			if test.has(c):
				return false
	return true

func auto_place(item: Dictionary, page: int = -1) -> bool:
	var pages: Array = [page] if page >= 0 else range(pages_unlocked)
	for pg in pages:
		for y in range(GRID_H):
			for x in range(GRID_W):
				for rot in [false, true]:
					if can_place(item, x, y, rot, -1, pg):
						item["x"] = x
						item["y"] = y
						item["page"] = pg
						item["rotated"] = rot
						item["location"] = "backpack"
						return true
	return false

func add_item(item: Dictionary) -> bool:
	var ok := auto_place(item)
	if not ok:
		item["location"] = "overflow"
	inventory.append(item)
	_refresh_pages()
	return ok

func _refresh_pages() -> void:
	var owned := 0
	for it in inventory:
		var sid := String(it.get("def_id", "")).to_lower()
		if String(get_item_def(it.get("def_id", "")).get("category", "")) == "container" and (sid.contains("backpack") or (sid.contains("bag") and not sid.contains("save_bag"))):
			owned += 1
	for it in display:
		var sid2 := String(it.get("def_id", "")).to_lower()
		if String(get_item_def(it.get("def_id", "")).get("category", "")) == "container" and (sid2.contains("backpack") or (sid2.contains("bag") and not sid2.contains("save_bag"))):
			owned += 1
	var target := 2 + (1 if owned >= 1 else 0) + (1 if owned >= 2 else 0)
	max_pages_unlocked = clampi(max(max_pages_unlocked, target), 1, GRID_PAGES)
	pages_unlocked = max_pages_unlocked

func find_item(uid: int) -> Dictionary:
	for it in inventory:
		if it["uid"] == uid:
			return it
	for it in display:
		if it["uid"] == uid:
			return it
	if not counter_item.is_empty() and int(counter_item.get("uid", -1)) == uid:
		return counter_item
	return {}

func move_item(uid: int, x: int, y: int, page: int = 0) -> bool:
	var it := find_item(uid)
	if it.is_empty() or it.get("location") != "backpack":
		return false
	if can_place(it, x, y, it.get("rotated", false), uid, page):
		it["x"] = x
		it["y"] = y
		it["page"] = page
		emit_signal("state_changed")
		return true
	return false

func rotate_item(uid: int) -> bool:
	var it := find_item(uid)
	if it.is_empty():
		return false
	var old_rot: bool = it.get("rotated", false)
	it["rotated"] = not old_rot
	if it.get("location") == "backpack":
		var pg := int(it.get("page", 0))
		if not can_place(it, it["x"], it["y"], it["rotated"], uid, pg):
			if not auto_place(it, pg):
				it["rotated"] = old_rot
				return false
	emit_signal("state_changed")
	return true

func new_game(diff_id: String = "normal", mode: String = "mobile") -> void:
	difficulty = diff_id if DIFFICULTY.has(diff_id) else "normal"
	campaign_mode = mode if mode in ["mobile", "original"] else "mobile"
	var dcfg: Dictionary = DIFFICULTY[difficulty]
	day = 1
	cash = int(dcfg["cash"])
	rent = int(dcfg["rent"])
	rent_due = 6
	loan = 200
	loan_due = 12
	rep = {"lower": 0, "security": 0, "blackmarket": 0, "upper": 0, "rev": 0, "tourist": 0, "church": 0, "cartel": 0}
	inventory = []
	display = []
	customers_today = []
	current_index = -1
	current_customer = {}
	counter_item = {}
	phase = "open"
	daily = {"sales": 0, "purchases": 0, "rent": 0, "fees": 0, "sold": 0, "bought": 0, "inspected": 0}
	uid_counter = 1
	pages_unlocked = 2
	max_pages_unlocked = 2
	pending_event = {}
	tutorial_done = false
	tutorial_step = 0
	var start_items := [
		["water_bottle_full", 92, true, false],
		["cig_red", 88, true, false],
		["hand_gold", 76, true, false],
		["handmade_pistol", 64, true, false],
		["nutrifruit", 95, true, false],
		["organ_heart", 70, true, false],
		["chem_scanner", 90, true, false],
		["magnifier", 85, true, false],
		["water_tablet", 100, true, false],
		["radio_on", 80, true, false],
	]
	for entry in start_items:
		var it := make_item(entry[0], entry[1], entry[2], entry[3])
		it["known"] = true
		add_item(it)
	for stock in [["scrap_metal", 3], ["printer_plastic", 3], ["common_chemical", 2], ["restricted_chemical", 1], ["nutrifruit_seed", 2], ["industrial_fish_feed", 2], ["water_jug", 1], ["meat_scrap", 2], ["nutrient_tablet", 1], ["red_beer", 2], ["plastic_bag", 2], ["debris_pile1", 2], ["printer_module_metal", 1], ["printer_chip_pistol", 1], ["organ_heart", 1], ["water_tablet", 1], ["small_raw_meat", 2], ["nutrifruit", 1]]:
		if items_def.has(stock[0]):
			for i in range(int(stock[1])):
				var it2 := make_item(stock[0], 100, true, false)
				it2["known"] = true
				add_item(it2)
	owned_upgrades = {}
	profession_id = ""
	profession_chosen = false
	commissions = []
	story_seen = []
	story_flags = {}
	pending_story = ""
	story_queue = []
	scene_seen = []
	wanted_defeated = []
	combat_active = false
	ending_id = ""
	_refresh_upgrades()
	machine_jobs = []
	machine_modules = {}
	machine_temps = {}
	machine_durability = {}
	machine_faults = {}
	machine_recipes = {}
	machine_active = {}
	machine_stock = {}
	machine_cash = {}
	machine_upgrades = {}
	machine_state = {}
	night_log = []
	next_day_power_bonus = 0
	attraction_bonus = 100
	bargain_bonus = 0
	security_alarm_active = false
	security_stop_rate = 0
	start_day()

func start_day() -> void:
	_refresh_upgrades()
	power = max_power + next_day_power_bonus
	next_day_power_bonus = 0
	bargain_bonus = 0
	phase = "open"
	current_index = -1
	current_customer = {}
	counter_item = {}
	daily = {"sales": 0, "purchases": 0, "rent": 0, "fees": 0, "sold": 0, "bought": 0, "inspected": 0}
	customers_today = []
	_gen_commissions()
	var count := rng.randi_range(3, 5)
	if attraction_bonus >= 110:
		count += 1
	for i in range(count):
		customers_today.append(_gen_customer())
	_queue_story_for_day()
	emit_signal("state_changed")
	if pending_story != "":
		emit_signal("story_available", pending_story)
	next_customer()

func _gen_customer() -> Dictionary:
	var arche: Dictionary = customer_defs[rng.randi_range(0, customer_defs.size() - 1)].duplicate(true)
	var forced_tutorial := day == 1 and not tutorial_done and customers_today.is_empty()
	if forced_tutorial:
		arche = customer_defs[1].duplicate(true)
	var intent: String = arche.get("intent", "both")
	if forced_tutorial:
		intent = "sell"
	if intent == "both":
		intent = "sell" if rng.randf() < 0.55 else "buy"
	var c := {
		"arche": arche,
		"intent": intent,
		"patience": int(arche.get("patience", 3)),
		"done": false,
		"line": arche.get("greet", ""),
	}
	if intent == "sell":
		var pool: Array = tradable_pool if not tradable_pool.is_empty() else ["cig_red", "cig_black", "water_bottle_full", "water_jug", "nutrifruit", "hand_steel", "hand_carbon", "hand_gold", "aug_chip", "handmade_pistol", "revolver_short", "organ_heart", "organ_liver", "command_keycard", "chem_scanner"]
		var def_id: String = pool[rng.randi_range(0, pool.size() - 1)]
		var cond := rng.randi_range(40, 100)
		var def := get_item_def(def_id)
		var cat := String(def.get("category", "misc"))
		var contra := int(def.get("contraband", 0))
		var auth := true
		var stolen := false
		if "cig" in def_id:
			auth = rng.randf() < 0.55
		elif cat in ["cyber", "weapon", "organ", "document", "medical", "chem"]:
			auth = rng.randf() < 0.8
		if cat in ["cyber", "weapon", "organ"] or contra >= 2:
			stolen = rng.randf() < 0.18
		elif contra >= 1:
			stolen = rng.randf() < 0.08
		var item := make_item(def_id, cond, auth, stolen)
		var val := market_value(item, false, arche.get("faction", "lower"))
		item["asking_price"] = int(round(val * rng.randf_range(1.15, 1.45)))
		item["min_price"] = int(round(val * rng.randf_range(0.7, 0.9)))
		c["item"] = item
		c["line"] = arche.get("greet", "") + "\n" + arche.get("ask", "")
	else:
		c["want_tags"] = arche.get("prefer_tags", [])
		var bmult := (1.0 + float(upgrade_total("budget")) / 100.0) * float(DIFFICULTY[difficulty]["budget"])
		bmult *= float(attraction_bonus) / 100.0
		c["budget"] = int(round(float(rng.randi_range(int(arche["budget"][0]), int(arche["budget"][1]))) * bmult))
		c["offer"] = 0
		c["max_price"] = 0
		c["line"] = arche.get("greet", "")
	return c

func next_customer() -> void:
	if phase == "gameover":
		return
	bargain_bonus = 0
	current_index += 1
	if current_index >= customers_today.size():
		current_customer = {}
		counter_item = {}
		phase = "endday"
		emit_signal("customer_changed")
		emit_signal("state_changed")
		return
	current_customer = customers_today[current_index]
	phase = "customer"
	counter_item = current_customer.get("item", {}) if current_customer.get("intent") == "sell" else {}
	emit_signal("customer_changed")
	emit_signal("state_changed")

func _public_item_icon(def: Dictionary) -> String:
	var cat := String(def.get("category", "misc"))
	var p := "res://assets_public/icons/" + cat + ".png"
	if ResourceLoader.exists(p):
		return p
	p = "res://assets_public/icons/generic.png"
	if ResourceLoader.exists(p):
		return p
	return ""

func item_icon_path(def: Dictionary) -> String:
	var icon := String(def.get("icon", ""))
	var force_public := "--publicassets" in OS.get_cmdline_args()
	var p := ""
	if not force_public and icon != "":
		p = "res://assets_private/items/" + icon
		if ResourceLoader.exists(p):
			return p
		p = "res://assets/items/" + icon
		if ResourceLoader.exists(p):
			return p
	var iid := String(def.get("id", ""))
	if iid != "":
		p = "res://assets_public/items/" + iid + ".png"
		if ResourceLoader.exists(p):
			return p
	return _public_item_icon(def)

func effective_value(item: Dictionary) -> int:
	if item.is_empty():
		return 0
	var def := get_item_def(item.get("def_id", ""))
	var base := float(def.get("base_value", 10))
	var cond := clampf(float(item.get("condition", 100)) / 100.0, 0.2, 1.0)
	var auth := 1.0 if item.get("authentic", true) else 0.35
	var stolen := 0.9 if item.get("stolen", false) else 1.0
	var contra := 1.0 + float(def.get("contraband", 0)) * 0.12
	var feat_mod := 0
	for f in item.get("features", []):
		feat_mod += int(f.get("mod", 0))
	var feat_mult := clampf(1.0 + float(feat_mod) / 100.0, 0.5, 1.5)
	return int(round(base * cond * auth * stolen * contra * feat_mult))

func market_value(item: Dictionary, for_sale: bool = false, faction: String = "") -> int:
	var v := float(effective_value(item))
	var def2 := get_item_def(item.get("def_id", ""))
	if for_sale:
		v *= 1.0 + (RETAIL_MARKUP + float(upgrade_total("retail"))) / 100.0
	if int(def2.get("contraband", 0)) > 0:
		v *= 1.0 + float(upgrade_total("contraband")) / 100.0
	if String(def2.get("category", "")) == "water":
		v *= 1.0 + float(upgrade_total("water")) / 100.0
	var r := clampf(float(rep.get(faction, 0)), -50.0, 50.0)
	v *= 1.0 + r * 0.003 + float(faction_tier(faction)) * 0.01
	return int(round(v))

func put_display_on_counter(uid: int) -> bool:
	if current_customer.is_empty() or current_customer.get("intent") != "buy":
		return false
	var it := {}
	for d in display:
		if int(d["uid"]) == uid:
			it = d
			break
	if it.is_empty():
		return false
	counter_item = it
	var def := get_item_def(it["def_id"])
	var match_tag := false
	for tag in current_customer.get("want_tags", []):
		if tag in def.get("tags", []):
			match_tag = true
			break
	var factor := 1.0 if match_tag else 0.55
	var arche: Dictionary = current_customer["arche"]
	var val := market_value(it, true, arche.get("faction", "lower"))
	var pm := float(arche.get("price_mod", 1.0)) * (float(attraction_bonus) / 100.0)
	var bargain := 1.0 + float(bargain_bonus) / 100.0
	current_customer["offer"] = int(round(val * factor * pm * bargain * rng.randf_range(0.75, 0.95)))
	current_customer["max_price"] = int(min(float(current_customer["budget"]), val * factor * pm * bargain * 1.05))
	emit_signal("state_changed")
	return true

func add_to_display(uid: int) -> bool:
	if display.size() >= DISPLAY_SLOTS:
		return false
	var idx := -1
	for i in range(inventory.size()):
		if int(inventory[i]["uid"]) == uid:
			idx = i
			break
	if idx < 0:
		return false
	var it: Dictionary = inventory[idx]
	inventory.remove_at(idx)
	it["location"] = "display"
	display.append(it)
	_refresh_pages()
	emit_signal("state_changed")
	return true

func take_from_display(uid: int) -> void:
	for i in range(display.size()):
		if int(display[i]["uid"]) == uid:
			var it: Dictionary = display[i]
			display.remove_at(i)
			it["location"] = "backpack"
			add_item(it)
			_refresh_pages()
			emit_signal("state_changed")
			return

func inspect_item(uid: int, method: int) -> String:
	var it := find_item(uid)
	if it.is_empty():
		return "没有找到物品。"
	if it.get("known", false):
		return "已经鉴定过了：%s" % _true_desc(it)
	var itype: String = get_item_def(it["def_id"]).get("inspect_type", "generic")
	var cost := 10 if itype in ["cyber", "weapon"] else 5
	cost = maxi(1, int(round(float(cost) * (1.0 - minf(50.0, float(upgrade_total("inspect"))) / 100.0))))
	if cash < cost:
		return "现金不足，鉴定费 %d₵。" % cost
	cash -= cost
	daily["fees"] += cost
	var clue := ""
	if itype == "water":
		clue = ["试纸颜色偏绿，水质大约 %d%%。" % it["condition"], "UV 灯下没有明显菌斑。" if it["condition"] > 60 else "UV 灯下能看到絮状沉淀。", "扫描仪：矿物质超标，建议过滤。"][clamp(method, 0, 2)]
	elif itype == "cig":
		if it["authentic"]:
			clue = ["封口平整，压纹清晰。", "批次码能在治安部数据库里查到。", "烟丝颜色均匀，是真货。"][clamp(method, 0, 2)]
		else:
			clue = ["封口有二次压合的痕迹。", "批次码对不上，数据库里没有记录。", "烟丝里掺了纸屑，是假货。"][clamp(method, 0, 2)]
	elif itype in ["cyber", "weapon"]:
		var serial := "序列号被磨掉了。" if it["stolen"] else "序列号完整，可以追溯。"
		clue = ["材质做工%s。" % ("正常" if it["authentic"] else "粗糙"), "磨损程度约 %d%%。" % (100 - it["condition"]), serial][clamp(method, 0, 2)]
	else:
		clue = ["外观看起来%s。" % ("正常" if it["authentic"] else "有问题"), "标签印刷%s。" % ("清晰" if it["authentic"] else "模糊"), "来源%s。" % ("说不清" if it["stolen"] else "基本清楚")][clamp(method, 0, 2)]
	if method < it.get("features", []).size():
		clue += "；特征：" + String(it["features"][method].get("name", ""))
	it["clues"].append(clue)
	it["inspect_count"] = int(it.get("inspect_count", 0)) + 1
	if int(it["inspect_count"]) >= 2:
		it["known"] = true
		daily["inspected"] = int(daily.get("inspected", 0)) + 1
	emit_signal("state_changed")
	return clue

func _true_desc(it: Dictionary) -> String:
	var cond := int(it.get("condition", 100))
	var auth := "真品" if it.get("authentic", true) else "假货"
	var stolen := "，序列号被磨掉" if it.get("stolen", false) else ""
	var feat_text := ""
	for f in it.get("features", []):
		feat_text += ("、" if feat_text != "" else "") + String(f.get("name", ""))
	if feat_text != "":
		feat_text = "，特征：" + feat_text
	return "%s，品相 %d%%%s%s，估值 %d₵" % [auth, cond, stolen, feat_text, effective_value(it)]

func make_offer(price: int) -> Dictionary:
	if current_customer.is_empty() or current_customer.get("intent") != "sell":
		return {"accepted": false, "text": "当前没有可收购的物品。"}
	if price > cash:
		return {"accepted": false, "text": "现金不足，你只有 %d₵。" % cash}
	var item: Dictionary = current_customer["item"]
	var min_price := int(round(float(item.get("min_price", 0)) * (1.0 - float(bargain_bonus) / 100.0)))
	if price >= min_price:
		cash -= price
		item["known"] = true
		item["location"] = "backpack"
		add_item(item)
		daily["purchases"] += price
		daily["bought"] = int(daily.get("bought", 0)) + 1
		add_rep(current_customer["arche"].get("faction", "lower"), 2)
		complete_customer(true)
		return {"accepted": true, "text": "成交。你花 %d₵ 收下了 %s。" % [price, item_display_name(item)]}
	current_customer["patience"] = int(current_customer.get("patience", 0)) - 1
	if int(current_customer["patience"]) >= 0:
		item["asking_price"] = min_price
		emit_signal("state_changed")
		return {"accepted": false, "counter": min_price, "text": "顾客摇头：最低 %d₵，不能再少了。" % min_price}
	complete_customer(false)
	return {"accepted": false, "text": "顾客失去耐心，转身离开了。"}

func make_sell_offer(price: int) -> Dictionary:
	if current_customer.is_empty() or current_customer.get("intent") != "buy" or counter_item.is_empty():
		return {"accepted": false, "text": "请先从展示柜选一件商品放到柜台。"}
	if price <= int(current_customer.get("max_price", 0)):
		cash += price
		daily["sales"] += price
		daily["sold"] = int(daily.get("sold", 0)) + 1
		_remove_counter_from_display()
		add_rep(current_customer["arche"].get("faction", "lower"), 2)
		complete_customer(true)
		return {"accepted": true, "text": "顾客付了 %d₵，交易完成。" % price}
	current_customer["patience"] = int(current_customer.get("patience", 0)) - 1
	if int(current_customer["patience"]) >= 0:
		current_customer["offer"] = int(current_customer["max_price"])
		emit_signal("state_changed")
		return {"accepted": false, "counter": int(current_customer["max_price"]), "text": "顾客还价：最多 %d₵。" % int(current_customer["max_price"])}
	complete_customer(false)
	return {"accepted": false, "text": "顾客觉得太贵，走了。"}

func accept_current() -> Dictionary:
	if current_customer.is_empty():
		return {"accepted": false, "text": "当前没有顾客。"}
	if current_customer.get("intent") == "sell":
		return make_offer(int(current_customer["item"].get("asking_price", 0)))
	if counter_item.is_empty():
		return {"accepted": false, "text": "请先把展示柜商品放到柜台。"}
	return make_sell_offer(int(current_customer.get("offer", 0)))

func threaten() -> Dictionary:
	if current_customer.is_empty():
		return {"accepted": false, "text": "当前没有顾客。"}
	var chance := 0.45 + float(rep["blackmarket"]) * 0.01 - float(rep["security"]) * 0.005
	if rng.randf() < chance:
		add_rep("blackmarket", 3)
		add_rep("security", -5)
		add_rep("lower", -2)
		if current_customer.get("intent") == "sell":
			var item: Dictionary = current_customer["item"]
			var price := int(round(float(item.get("min_price", 0)) * 0.7))
			if price > cash:
				price = cash
			cash -= price
			item["known"] = true
			item["location"] = "backpack"
			add_item(item)
			daily["purchases"] += price
			complete_customer(true)
			return {"accepted": true, "text": "你压低声音威胁了几句，花 %d₵ 拿下了货。" % price}
		else:
			if counter_item.is_empty():
				return {"accepted": false, "text": "请先把商品放到柜台。"}
			var price2 := int(round(float(current_customer.get("max_price", 0)) * 1.2))
			cash += price2
			daily["sales"] += price2
			_remove_counter_from_display()
			complete_customer(true)
			return {"accepted": true, "text": "顾客被吓住了，付了 %d₵。" % price2}
	add_rep("lower", -5)
	add_rep("security", -2)
	complete_customer(false)
	return {"accepted": false, "text": "威胁失败，顾客骂骂咧咧地走了。"}

func _remove_counter_from_display() -> void:
	if counter_item.is_empty():
		return
	var uid := int(counter_item["uid"])
	for i in range(display.size()):
		if int(display[i]["uid"]) == uid:
			display.remove_at(i)
			break
	counter_item = {}

func complete_customer(success: bool) -> void:
	if not current_customer.is_empty():
		current_customer["done"] = true
		if not success:
			add_rep("lower", -1)
	emit_signal("state_changed")
	next_customer()

func add_rep(faction: String, amount: int) -> void:
	if not rep.has(faction):
		rep[faction] = 0
	var final_amount := amount
	if amount > 0:
		final_amount = int(round(float(amount) * (1.0 + float(upgrade_total("rep")) / 100.0)))
	rep[faction] = clampi(int(rep[faction]) + final_amount, -100, 100)

func finish_day() -> Dictionary:
	rent_due -= 1
	loan_due -= 1
	var summary := {
		"day": day, "sales": daily["sales"], "purchases": daily["purchases"],
		"fees": daily["fees"], "rent_paid": 0, "loan_paid": 0,
		"rent": rent, "rent_due": rent_due, "loan_due": loan_due, "cash": cash, "gameover": ""
	}
	if rent_due <= 0:
		var rent_cost := int(round(float(rent) * (1.0 - minf(50.0, float(upgrade_total("rent"))) / 100.0)))
		if cash >= rent_cost:
			cash -= rent_cost
			summary["rent_paid"] = rent_cost
			rent = int(round(float(rent) * 1.1))
			rent_due = 7
		else:
			summary["gameover"] = "rent"
	if loan_due <= 0 and summary["gameover"] == "":
		if cash >= loan:
			cash -= loan
			summary["loan_paid"] = loan
			loan_due = 12
		else:
			summary["gameover"] = "repo"
	if summary["gameover"] == "":
		if int(rep.get("security", 0)) <= -35:
			summary["gameover"] = "sec"
		elif int(rep.get("blackmarket", 0)) <= -35:
			summary["gameover"] = "hitman"
		elif int(rep.get("cartel", 0)) <= -35:
			summary["gameover"] = "mob"
		elif int(rep.get("upper", 0)) <= -35:
			summary["gameover"] = "execution"
		elif int(rep.get("rev", 0)) <= -35:
			summary["gameover"] = "sentinel"
	if String(summary["gameover"]) != "":
		ending_id = String(summary["gameover"])
	summary["cash"] = cash
	summary["rent"] = rent
	summary["rent_due"] = rent_due
	summary["loan_due"] = loan_due
	phase = "gameover" if summary["gameover"] != "" else "endday"
	if phase != "gameover":
		save_game()
	emit_signal("day_finished", summary)
	emit_signal("state_changed")
	return summary

func advance_day() -> void:
	if phase == "gameover":
		return
	advance_machines_one_cycle()
	if phase == "gameover":
		emit_signal("state_changed")
		return
	day += 1
	start_day()
	if events.size() > 0 and rng.randf() < 0.45:
		pending_event = events[rng.randi_range(0, events.size() - 1)].duplicate(true)
		emit_signal("event_started", pending_event)

func apply_event(choice_index: int) -> void:
	if pending_event.is_empty():
		return
	var choices: Array = pending_event.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return
	var ch: Dictionary = choices[choice_index]
	cash += int(ch.get("cash", 0))
	var changes: Dictionary = ch.get("rep", {})
	for k in changes.keys():
		add_rep(k, int(changes[k]))
	if bool(ch.get("repair_all", false)):
		machine_durability = {}
		machine_faults = {}
	var end_id := String(ch.get("ending", ""))
	if end_id != "" and rng.randf() < float(ch.get("ending_chance", 1.0)):
		phase = "gameover"
		ending_id = end_id
		pending_event = {}
		emit_signal("state_changed")
		return
	var confiscated := 0
	if bool(ch.get("confiscate", false)):
		for i in range(inventory.size() - 1, -1, -1):
			if int(get_item_def(inventory[i].get("def_id", "")).get("contraband", 0)) > 0:
				inventory.remove_at(i)
				confiscated += 1
		for i in range(display.size() - 1, -1, -1):
			if int(get_item_def(display[i].get("def_id", "")).get("contraband", 0)) > 0:
				display.remove_at(i)
				confiscated += 1
		_refresh_pages()
	pending_event = {}
	if confiscated > 0 and int(rep.get("security", 0)) <= -20:
		phase = "gameover"
		ending_id = "arrest"
	elif cash < 0:
		phase = "gameover"
		ending_id = "rent"
	emit_signal("state_changed")

func upgrade_total(effect: String) -> int:
	var total := 0
	for uid in owned_upgrades.keys():
		var u := upgrade_def(String(uid))
		if String(u.get("effect", "")) == effect:
			total += int(u.get("value", 0))
	return total

func apply_profession(pid: String) -> Dictionary:
	if profession_chosen:
		return {"ok": false, "text": "本局已经选择过专精。"}
	var p := {}
	for x in professions:
		if String(x.get("id", "")) == pid:
			p = x
			break
	if p.is_empty():
		return {"ok": false, "text": "没有这个专精。"}
	profession_id = pid
	profession_chosen = true
	cash += int(p.get("cash", 0))
	for entry in p.get("items", []):
		var iid := String(entry[0]); var cnt := int(entry[1])
		if not items_def.has(iid):
			continue
		for n in range(cnt):
			var it := make_item(iid, 100, true, false)
			it["known"] = true
			add_item(it)
	var reps: Dictionary = p.get("rep", {})
	for k in reps.keys():
		add_rep(String(k), int(reps[k]))
	emit_signal("state_changed")
	return {"ok": true, "text": "已选择专精：%s。" % p.get("name", pid)}

func _gen_commissions() -> void:
	commissions = []
	if tradable_pool.is_empty():
		return
	var fs := ["lower", "upper", "security", "blackmarket", "rev", "tourist", "church", "cartel"]
	for i in range(3):
		var iid: String = tradable_pool[rng.randi_range(0, tradable_pool.size() - 1)]
		var cnt := rng.randi_range(1, 2)
		var faction: String = fs[rng.randi_range(0, fs.size() - 1)]
		var sample := make_item(iid, 100, true, false)
		var reward := int(round(float(market_value(sample, false, faction)) * float(cnt) * 1.35))
		commissions.append({"id": "c%d" % i, "item_id": iid, "count": cnt, "faction": faction, "reward": reward, "rep": 5})

func deliver_commission(cid: String) -> Dictionary:
	for i in range(commissions.size()):
		var c: Dictionary = commissions[i]
		if String(c.get("id", "")) != cid:
			continue
		var iid := String(c.get("item_id", ""))
		var cnt := int(c.get("count", 1))
		if inventory_count(iid) < cnt:
			return {"ok": false, "text": "背包里的数量不足。"}
		remove_inventory(iid, cnt)
		cash += int(c.get("reward", 0))
		add_rep(String(c.get("faction", "lower")), int(c.get("rep", 0)))
		commissions.remove_at(i)
		emit_signal("state_changed")
		return {"ok": true, "text": "委托完成，获得 %d₵。" % int(c.get("reward", 0))}
	return {"ok": false, "text": "没有这个委托。"}

func enemy_def(id: String) -> Dictionary:
	for e in combat_data:
		if String(e.get("id", "")) == id:
			return e
	return {}

func wanted_def(id: String) -> Dictionary:
	for w in wanted:
		if String(w.get("id", "")) == id:
			return w
	return {}

func ending_def(id: String) -> Dictionary:
	for e in endings:
		if String(e.get("id", "")) == id:
			return e
	return {}

func resolve_ending(id: String) -> String:
	if id == "buyout_dynamic":
		return "buyout_mortgage" if story_flags.has("buyout_mortgage_plan") else "buyout"
	if id == "cartel_dynamic":
		return "cartel_retired" if int(rep.get("cartel", 0)) >= 20 else "cartel"
	return id

func start_combat(enemy_id: String, faction: String = "lower", wanted_id: String = "", context: String = "") -> Dictionary:
	var e := enemy_def(enemy_id)
	if e.is_empty():
		return {"ok": false, "text": "敌人不存在。"}
	combat_active = true
	combat_enemy = e.duplicate(true)
	if wanted_id != "":
		var w := wanted_def(wanted_id)
		if not w.is_empty():
			combat_enemy["reward"] = int(w.get("reward", e.get("reward", 50)))
			combat_enemy["rep"] = w.get("rep", e.get("rep", {})).duplicate(true)
	combat_enemy_hp = int(e.get("hp", 40))
	combat_player_max = 60
	combat_player_hp = 60
	combat_skill_cd = 0
	combat_guarding = false
	combat_wanted_id = wanted_id
	combat_context = context
	combat_log = ["遭遇：%s" % e.get("name", enemy_id)]
	emit_signal("combat_started")
	emit_signal("state_changed")
	return {"ok": true, "text": "战斗开始。"}

func combat_roll(minv: int, maxv: int) -> int:
	return rng.randi_range(minv, maxv)

func _combat_enemy_turn() -> void:
	if not combat_active:
		return
	var dmg := combat_roll(int(combat_enemy.get("atk_min", 5)), int(combat_enemy.get("atk_max", 9)))
	dmg = maxi(1, int(round(float(dmg) * float(DIFFICULTY[difficulty]["damage"]))))
	if combat_guarding:
		dmg = maxi(1, int(round(float(dmg) * 0.5)))
	combat_player_hp -= dmg
	combat_log.append("%s 反击，造成 %d 伤害。" % [combat_enemy.get("name", "敌人"), dmg])
	combat_guarding = false

func combat_action(action: String) -> Dictionary:
	if not combat_active:
		return {"ok": false, "text": "当前没有战斗。"}
	if action == "flee":
		if rng.randf() < 0.5:
			combat_active = false
			emit_signal("combat_finished", false, "你逃离了战斗。")
			emit_signal("state_changed")
			return {"ok": true, "text": "你逃离了战斗。"}
		combat_log.append("逃跑失败。")
	elif action == "guard":
		combat_guarding = true
		combat_log.append("你举起手臂防御。")
	elif action == "skill":
		if combat_skill_cd > 0:
			combat_log.append("技能冷却中（%d）。" % combat_skill_cd)
		else:
			var dmg := combat_roll(16, 24)
			combat_enemy_hp -= dmg
			combat_skill_cd = 3
			combat_log.append("瞄准射击，造成 %d 伤害。" % dmg)
	else:
		var dmg := combat_roll(8, 14)
		combat_enemy_hp -= dmg
		combat_log.append("你发起攻击，造成 %d 伤害。" % dmg)
	if combat_enemy_hp <= 0:
		var reward := int(combat_enemy.get("reward", 50))
		cash += reward
		var reps: Dictionary = combat_enemy.get("rep", {})
		for k in reps.keys():
			add_rep(String(k), int(reps[k]))
		if combat_wanted_id != "" and not wanted_defeated.has(combat_wanted_id):
			wanted_defeated.append(combat_wanted_id)
		var msg := "战斗胜利，获得 %d₵。" % reward
		combat_active = false
		emit_signal("combat_finished", true, msg)
		emit_signal("state_changed")
		return {"ok": true, "text": msg}
	_combat_enemy_turn()
	if combat_player_hp <= 0:
		cash = maxi(0, cash - 100)
		add_rep("lower", -3)
		combat_active = false
		var end_id := ""
		if combat_context == "security_raid":
			end_id = "sec"
		elif combat_context == "street_ambush":
			end_id = "mob"
		elif String(combat_enemy.get("id", "")) == "boss_lou":
			end_id = "lou_bombed_debt" if cash < loan else "lou_bombed"
		if end_id != "":
			phase = "gameover"
			ending_id = end_id
		emit_signal("combat_finished", false, "你被打倒了，损失 100₵。")
		emit_signal("state_changed")
		return {"ok": true, "text": "战斗失败。"}
	combat_skill_cd = maxi(0, combat_skill_cd - 1)
	emit_signal("combat_updated")
	emit_signal("state_changed")
	return {"ok": true, "text": ""}

func set_ending(id: String) -> void:
	ending_id = id
	emit_signal("state_changed")

func story_node(id: String) -> Dictionary:
	return story_nodes.get(id, {})

func _load_story_scenes() -> void:
	story_scenes = []
	var paths := ["res://data/story_scenes.json", "res://data_private/story_scenes_full.json"]
	for path in paths:
		var f := FileAccess.open(String(path), FileAccess.READ)
		if not f:
			continue
		var data = JSON.parse_string(f.get_as_text())
		if not data is Array:
			continue
		for scene in data:
			if not scene is Dictionary:
				continue
			var sid := String(scene.get("id", ""))
			if sid == "":
				continue
			var replaced := false
			for i in range(story_scenes.size()):
				if String(story_scenes[i].get("id", "")) == sid:
					story_scenes[i] = scene
					replaced = true
					break
			if not replaced:
				story_scenes.append(scene)
	for scene in story_scenes:
		_build_scene_nodes(scene)

func _build_scene_nodes(scene: Dictionary) -> void:
	var sid := String(scene.get("id", ""))
	if story_graphs.has(sid) and scene.get("choices", []).is_empty():
		_build_graph_scene_nodes(scene, story_graphs[sid])
		return
	var lines: Array = scene.get("lines", [])
	var ids: Array = []
	for i in range(lines.size()):
		var line: Dictionary = lines[i]
		var nid := "sc_%s_%d" % [sid, i]
		story_nodes[nid] = {
			"id": nid,
			"speaker": String(line.get("speaker", scene.get("name", ""))),
			"text": String(line.get("text", "")),
			"portrait": String(line.get("portrait", scene.get("portrait", ""))),
			"next": "",
			"scene_id": sid,
		}
		ids.append(nid)
	for i in range(ids.size() - 1):
		story_nodes[ids[i]]["next"] = ids[i + 1]
	if ids.is_empty():
		return
	var last := String(ids[ids.size() - 1])
	var choices: Array = scene.get("choices", [])
	if choices.is_empty():
		story_nodes[last]["scene_end"] = sid
		story_nodes[last]["on_done"] = scene.get("on_done", {})
		return
	var built: Array = []
	var any_branch := false
	for ci in range(choices.size()):
		var choice: Dictionary = choices[ci]
		var branch: Array = choice.get("next_lines", [])
		var branch_ids: Array = []
		for j in range(branch.size()):
			var bline: Dictionary = branch[j]
			var bid := "sc_%s_c%d_%d" % [sid, ci, j]
			story_nodes[bid] = {
				"id": bid,
				"speaker": String(bline.get("speaker", scene.get("name", ""))),
				"text": String(bline.get("text", "")),
				"portrait": String(bline.get("portrait", scene.get("portrait", ""))),
				"next": "",
				"scene_id": sid,
			}
			branch_ids.append(bid)
		for j in range(branch_ids.size() - 1):
			story_nodes[branch_ids[j]]["next"] = branch_ids[j + 1]
		if not branch_ids.is_empty():
			any_branch = true
			var bend := String(branch_ids[branch_ids.size() - 1])
			story_nodes[bend]["scene_end"] = sid
			story_nodes[bend]["on_done"] = scene.get("on_done", {})
		built.append({
			"text": String(choice.get("text", "选择")),
			"effects": choice.get("effects", {}),
			"requires_cash": int(choice.get("requires_cash", 0)),
			"requires_rep": choice.get("requires_rep", {}),
			"requires_flag": String(choice.get("requires_flag", "")),
			"next": String(branch_ids[0]) if not branch_ids.is_empty() else "",
			"ending": String(choice.get("ending", "")),
		})
	story_nodes[last]["choices"] = built
	if not any_branch:
		story_nodes[last]["scene_end"] = sid
		story_nodes[last]["on_done"] = scene.get("on_done", {})

func _build_graph_scene_nodes(scene: Dictionary, graph: Dictionary) -> void:
	var sid := String(scene.get("id", ""))
	var nodes: Array = graph.get("nodes", [])
	for i in range(nodes.size()):
		var raw: Dictionary = nodes[i]
		var nid := "sc_%s_%d" % [sid, i]
		var nxt := String(raw.get("next", ""))
		var node := {
			"id": nid,
			"speaker": String(raw.get("speaker", scene.get("name", ""))),
			"text": String(raw.get("text", "")),
			"portrait": String(scene.get("portrait", "")),
			"next": ("sc_%s_%s" % [sid, nxt]) if nxt != "" else "",
			"scene_id": sid,
		}
		var choices: Array = []
		var live_targets := 0
		for ch in raw.get("choices", []):
			var target := String(ch.get("next", ""))
			if target != "":
				live_targets += 1
			choices.append({
				"text": String(ch.get("text", "选择")),
				"next": ("sc_%s_%s" % [sid, target]) if target != "" else "",
				"effects": {},
			})
		if not choices.is_empty():
			node["choices"] = choices
		if String(node["next"]) == "" and (choices.is_empty() or live_targets == 0):
			node["scene_end"] = sid
			node["on_done"] = scene.get("on_done", {})
		story_nodes[nid] = node

func _scene_root_id(sid: String) -> String:
	var idx := 0
	if story_graphs.has(sid):
		idx = int(story_graphs[sid].get("root", 0))
	return "sc_%s_%d" % [sid, idx]

func _queue_story_for_day() -> void:
	pending_story = ""
	story_queue.clear()
	for nid in _queue_story_scenes():
		story_queue.append(nid)
	if campaign_mode == "original":
		if day == 45 and not story_seen.has("finale_day10"):
			story_queue.append("finale_day10")
	else:
		var map := {2: "mentor_day2", 3: "side_scavenger", 4: "security_day4", 6: "faction_day6", 7: "side_church", 8: "buyout_day8", 10: "finale_day10"}
		if map.has(day):
			var sid := String(map[day])
			if not story_seen.has(sid):
				story_queue.append(sid)
	if not story_queue.is_empty():
		pending_story = String(story_queue.pop_front())

func _queue_story_scenes() -> Array:
	var firsts: Array = []
	var postgame_count := 0
	for scene in story_scenes:
		var sid := String(scene.get("id", ""))
		if sid == "" or scene_seen.has(sid):
			continue
		var sday := int(original_days.get(sid, 0)) if campaign_mode == "original" else int(scene.get("day", 0))
		if campaign_mode == "original":
			if sday != day:
				continue
		elif sday == 0:
			if day < 11 or postgame_count >= 2:
				continue
		elif sday != day:
			continue
		if not _scene_available(scene):
			continue
		if sday == 0:
			postgame_count += 1
		var intent := String(scene.get("intent", "dialogue"))
		if intent in ["sell", "buy"]:
			customers_today.insert(0, _make_scene_customer(scene))
		var nid := _scene_root_id(sid)
		if story_nodes.has(nid):
			firsts.append(nid)
	while customers_today.size() > 5:
		customers_today.pop_back()
	return firsts

func _scene_available(scene: Dictionary) -> bool:
	var flag := String(scene.get("requires_flag", ""))
	if flag != "" and not story_flags.has(flag):
		return false
	if cash < int(scene.get("requires_cash", 0)):
		return false
	var req_rep: Dictionary = scene.get("requires_rep", {})
	for k in req_rep.keys():
		if int(rep.get(String(k), 0)) < int(req_rep[k]):
			return false
	return true

func _make_scene_customer(scene: Dictionary) -> Dictionary:
	var sid := String(scene.get("id", ""))
	var intent := String(scene.get("intent", "dialogue"))
	var arche := {
		"name": String(scene.get("name", "顾客")),
		"sprite": String(scene.get("portrait", "maleUpper_0.png")),
		"faction": String(scene.get("faction", "lower")),
		"greet": "",
		"ask": "",
		"price_mod": 1.0,
		"budget": [0, 0],
		"prefer_tags": scene.get("want_tags", []),
	}
	var c := {"arche": arche, "intent": intent, "patience": 99, "done": false, "line": "", "story_scene": sid}
	if intent == "sell":
		var item := make_item(String(scene.get("item_id", "scrap_metal")), int(scene.get("item_condition", 100)), true, bool(scene.get("stolen", false)))
		item["known"] = false
		item["custom_name"] = String(scene.get("item_name", ""))
		item["custom_desc"] = String(scene.get("item_desc", ""))
		var asking := int(scene.get("asking_price", 0))
		if asking <= 0:
			asking = int(round(market_value(item, false, String(arche["faction"])) * 1.3))
		item["asking_price"] = asking
		item["min_price"] = int(scene.get("min_price", int(round(asking * 0.75))))
		c["item"] = item
	elif intent == "buy":
		c["budget"] = int(scene.get("budget", 100))
		c["want_tags"] = scene.get("want_tags", [])
		c["offer"] = 0
		c["max_price"] = 0
	return c

func take_queued_story() -> String:
	if story_queue.is_empty():
		pending_story = ""
		return ""
	var sid := String(story_queue.pop_front())
	pending_story = sid
	return sid

func choice_available(choice: Dictionary) -> bool:
	if cash < int(choice.get("requires_cash", 0)):
		return false
	var req_rep: Dictionary = choice.get("requires_rep", {})
	for k in req_rep.keys():
		if int(rep.get(String(k), 0)) < int(req_rep[k]):
			return false
	var req_flag := String(choice.get("requires_flag", ""))
	if req_flag != "" and not story_flags.has(req_flag):
		return false
	return true

func item_display_name(item: Dictionary) -> String:
	var custom := String(item.get("custom_name", ""))
	if custom != "":
		return custom
	return String(get_item_def(String(item.get("def_id", ""))).get("name", ""))

func item_description(item: Dictionary) -> String:
	var custom := String(item.get("custom_desc", ""))
	if custom != "":
		return custom
	return String(get_item_def(String(item.get("def_id", ""))).get("description", ""))

func mark_story_seen(id: String) -> void:
	if not story_seen.has(id):
		story_seen.append(id)
	if pending_story == id:
		pending_story = ""
	var node: Dictionary = story_nodes.get(id, {})
	var sid := String(node.get("scene_end", ""))
	if sid != "" and not scene_seen.has(sid):
		scene_seen.append(sid)
		apply_story_effects(node.get("on_done", {}))
	emit_signal("state_changed")

func apply_story_effects(effects: Dictionary) -> void:
	cash += int(effects.get("cash", 0))
	var reps: Dictionary = effects.get("rep", {})
	for k in reps.keys():
		add_rep(String(k), int(reps[k]))
	for entry in effects.get("items", []):
		var iid := String(entry[0]); var cnt := int(entry[1])
		if items_def.has(iid):
			for n in range(cnt):
				add_item(make_item(iid, 100, true, false))
	var flag := String(effects.get("flag", ""))
	if flag != "":
		story_flags[flag] = true
	emit_signal("state_changed")

func faction_def(id: String) -> Dictionary:
	for f in factions:
		if String(f.get("id", "")) == id:
			return f
	return {}

func faction_tier(id: String) -> int:
	var f := faction_def(id)
	var val := int(rep.get(id, 0))
	var tier := 0
	for p in f.get("perks", []):
		if val >= int(p.get("threshold", 999)):
			tier += 1
	return tier

func faction_next_perk(id: String) -> Dictionary:
	var f := faction_def(id)
	var val := int(rep.get(id, 0))
	for p in f.get("perks", []):
		if val < int(p.get("threshold", 999)):
			return p
	return {}

func upgrade_def(id: String) -> Dictionary:
	for u in upgrades:
		if String(u.get("id", "")) == id:
			return u
	return {}

func buy_upgrade(id: String) -> Dictionary:
	var u := upgrade_def(id)
	if u.is_empty():
		return {"ok": false, "text": "没有这项升级。"}
	if owned_upgrades.has(id):
		return {"ok": false, "text": "已经购买过了。"}
	var cost := int(u.get("cost", 0))
	if cash < cost:
		return {"ok": false, "text": "现金不足，需要 %d₵。" % cost}
	cash -= cost
	owned_upgrades[id] = true
	if String(u.get("effect", "")) == "power":
		power += int(u.get("value", 0))
	_refresh_upgrades()
	emit_signal("state_changed")
	return {"ok": true, "text": "已购买：%s。" % u.get("name", id)}

func _refresh_upgrades() -> void:
	var bonus := 0
	var pb := machine_def("powerblock")
	if not pb.is_empty() and bool(machine_active.get("powerblock", false)):
		bonus += int(pb.get("special", {}).get("value", 2))
	max_power = 10 + upgrade_total("power") + bonus
	power = mini(power, max_power)

func machine_def(id: String) -> Dictionary:
	for m in machines:
		if String(m.get("id", "")) == id:
			return m
	return {}

func inventory_count(def_id: String) -> int:
	var n := 0
	for it in inventory:
		if String(it.get("def_id", "")) == def_id:
			n += 1
	return n

func remove_inventory(def_id: String, count: int) -> bool:
	if inventory_count(def_id) < count:
		return false
	var need := count
	var i := 0
	while i < inventory.size() and need > 0:
		if String(inventory[i].get("def_id", "")) == def_id:
			inventory.remove_at(i)
			need -= 1
		else:
			i += 1
	return need == 0

func module_def(module_id: String) -> Dictionary:
	for m in modules_def:
		if String(m.get("id", "")) == module_id:
			return m
	return {}

func machine_recipe(machine_id: String) -> Dictionary:
	var m := machine_def(machine_id)
	var recipes: Array = m.get("recipes", [])
	if recipes.is_empty():
		return {}
	var selected := String(machine_recipes.get(machine_id, ""))
	for r in recipes:
		if String(r.get("id", "")) == selected:
			return r
	return recipes[0]

func machine_recipe_name(recipe: Dictionary) -> String:
	var text := String(recipe.get("name", recipe.get("id", "")))
	var count := 1
	var outs: Array = recipe.get("outputs", [])
	if not outs.is_empty():
		count = int(outs[0].get("count", 1))
	return text.replace("{0}", str(count)).replace("{1}", str(count))

func set_machine_recipe(machine_id: String, recipe_id: String) -> void:
	machine_recipes[machine_id] = recipe_id
	emit_signal("state_changed")

func machine_module_ids(machine_id: String) -> Array:
	var raw = machine_modules.get(machine_id, [])
	if raw is Array:
		return raw.duplicate()
	if raw is String and String(raw) != "":
		return [String(raw)]
	return []

func machine_module_sums(machine_id: String) -> Dictionary:
	var sums := {"performance": 0, "efficiency": 0, "quality": 0, "count": 0}
	for mid in machine_module_ids(machine_id):
		var md := module_def(String(mid))
		if md.is_empty():
			continue
		sums["performance"] = int(sums["performance"]) + int(md.get("performance", 0))
		sums["efficiency"] = int(sums["efficiency"]) + int(md.get("efficiency", 0))
		sums["quality"] = int(sums["quality"]) + int(md.get("quality", 0))
		sums["count"] = int(sums["count"]) + 1
	return sums

func machine_module_type_ok(machine_id: String, module_id: String) -> bool:
	var m := machine_def(machine_id)
	var md := module_def(module_id)
	if m.is_empty() or md.is_empty():
		return false
	var allowed: Array = m.get("module_types", [])
	if allowed.is_empty():
		return false
	return allowed.has(String(md.get("type", "")))

func module_name(module_id: String) -> String:
	var md := module_def(module_id)
	return String(md.get("name", module_id))

func _merge_outputs(outputs: Array, adds: Array) -> void:
	for a in adds:
		var aid := String(a.get("id", ""))
		var acount := int(a.get("count", 1))
		var found := false
		for o in outputs:
			if String(o.get("id", "")) == aid:
				o["count"] = int(o.get("count", 1)) + acount
				found = true
				break
		if not found:
			outputs.append({"id": aid, "count": acount})

func _replace_outputs(outputs: Array, reps: Array) -> void:
	for r in reps:
		var from_id := String(r.get("from", ""))
		var to_id := String(r.get("to", ""))
		for o in outputs:
			if String(o.get("id", "")) == from_id:
				o["id"] = to_id

func _avg_input_condition(inputs: Array) -> int:
	var total := 0
	var count := 0
	for inp in inputs:
		var iid := String(inp.get("id", ""))
		var want := int(inp.get("count", 1))
		for it in inventory:
			if want <= 0:
				break
			if String(it.get("def_id", "")) == iid:
				total += int(it.get("condition", 100))
				count += 1
				want -= 1
	if count <= 0:
		return 50
	return int(round(float(total) / float(count)))

func machine_recipe_power(machine_id: String, recipe: Dictionary) -> int:
	var m := machine_def(machine_id)
	var base := int(recipe.get("power_cost", m.get("power", 0)))
	var sums := machine_module_sums(machine_id)
	var eff := float(sums["efficiency"])
	base = int(round(float(base) * (1.0 - minf(50.0, eff) / 100.0)))
	return maxi(0, base)

func machine_recipe_cycles(machine_id: String, recipe: Dictionary) -> int:
	var m := machine_def(machine_id)
	var lvl := int(machine_temps.get(machine_id, 2))
	var temp_time: float = [1.2, 1.0, 0.8][clampi(lvl, 1, 3) - 1]
	var base := int(recipe.get("cycles", m.get("cycles", 2)))
	var sums := machine_module_sums(machine_id)
	var perf := float(sums["performance"])
	var cycles := int(round(float(base) * temp_time * (1.0 - minf(50.0, perf) / 100.0)))
	cycles = int(round(float(cycles) * (1.0 - minf(50.0, float(upgrade_total("machine"))) / 100.0)))
	return maxi(1, cycles)

func install_module(machine_id: String, module_id: String) -> Dictionary:
	var md := module_def(module_id)
	if md.is_empty():
		return {"ok": false, "text": "没有这个模块。"}
	if machine_module_type_ok(machine_id, module_id) == false:
		return {"ok": false, "text": "%s 不能安装 %s。" % [machine_def(machine_id).get("name", machine_id), md.get("name", module_id)]}
	var list := machine_module_ids(machine_id)
	if list.has(module_id):
		list.erase(module_id)
		machine_modules[machine_id] = list
		emit_signal("state_changed")
		return {"ok": true, "text": "已卸下模块：%s。" % md.get("name", module_id)}
	var slots := int(machine_def(machine_id).get("module_slots", 1))
	if list.size() >= slots:
		return {"ok": false, "text": "模块槽已满（%d/%d）。" % [list.size(), slots]}
	list.append(module_id)
	machine_modules[machine_id] = list
	emit_signal("state_changed")
	return {"ok": true, "text": "已安装模块：%s（%d/%d）。" % [md.get("name", module_id), list.size(), slots]}

func clear_modules(machine_id: String) -> void:
	machine_modules[machine_id] = []
	emit_signal("state_changed")

func _make_output_item(oid: String, cond: int, features: Array) -> Dictionary:
	var it := make_item(oid, clampi(cond, 0, 100), true, false)
	for f in features:
		it["features"].append(f.duplicate(true))
	return it

func start_machine(machine_id: String, quality: float = 0.0, dry_run: bool = false) -> Dictionary:
	var m := machine_def(machine_id)
	if m.is_empty():
		return {"ok": false, "text": "没有这台机器。"}
	for j in machine_jobs:
		if String(j.get("machine_id", "")) == machine_id:
			return {"ok": false, "text": "%s 正在运行。" % m.get("name", machine_id)}
	if machine_faults.has(machine_id):
		var fault := String(machine_faults[machine_id])
		return {"ok": false, "text": "%s 故障：%s，请先维修。" % [m.get("name", machine_id), machine_fault_name(fault)]}
	if int(machine_durability.get(machine_id, 100)) <= 0:
		return {"ok": false, "text": "%s 已损坏，请先维修。" % m.get("name", machine_id)}
	var recipe := machine_recipe(machine_id)
	if recipe.is_empty():
		return {"ok": false, "text": "%s 是辅助设备，请使用专用操作。" % m.get("name", machine_id)}
	var installed := machine_module_ids(machine_id)
	for req in recipe.get("requires_modules", []):
		if not installed.has(String(req)):
			return {"ok": false, "text": "缺少模块：%s。" % module_name(String(req))}
	for req in recipe.get("requires_items", []):
		if inventory_count(String(req)) < 1:
			return {"ok": false, "text": "缺少所需芯片：%s。" % String(get_item_def(String(req)).get("name", req))}
	var unlock := int(recipe.get("unlock_upgrade", 0))
	if unlock > int(machine_upgrades.get(machine_id, 0)):
		return {"ok": false, "text": "需要升级到 %d 级才能使用该配方。" % unlock}
	var active_inputs: Array = recipe.get("inputs", []).duplicate(true)
	var active_outputs: Array = recipe.get("outputs", []).duplicate(true)
	var quality_delta := 0
	var neutralized := false
	var effects: Dictionary = recipe.get("module_effects", {})
	for mid in installed:
		var eff: Dictionary = effects.get(String(mid), {})
		if eff.is_empty():
			continue
		if eff.has("input_mult"):
			for inp in active_inputs:
				inp["count"] = int(ceil(float(inp.get("count", 1)) * float(eff["input_mult"])))
		if eff.has("outputs"):
			active_outputs = eff["outputs"].duplicate(true)
		if eff.has("add_outputs"):
			_merge_outputs(active_outputs, eff["add_outputs"])
		if eff.has("replace_outputs"):
			_replace_outputs(active_outputs, eff["replace_outputs"])
		quality_delta += int(eff.get("quality_delta", 0))
		if bool(eff.get("clear_contraband", false)):
			neutralized = true
	if bool(recipe.get("melee", false)) and installed.has("printer_module_melee_batch"):
		for o in active_outputs:
			o["count"] = int(o.get("count", 1)) + 1
	var avg_cond := _avg_input_condition(active_inputs)
	if bool(recipe.get("count_from_input_condition", false)) and not active_outputs.is_empty():
		var count := 2
		if avg_cond >= 95:
			count = 5
		elif avg_cond >= 80:
			count = 4
		elif avg_cond >= 40:
			count = 3
		active_outputs[0]["count"] = count
	var use_cycles := machine_recipe_cycles(machine_id, recipe)
	use_cycles = maxi(1, int(round(float(use_cycles) * (1.0 - clampf(quality, 0.0, 1.0) * 0.2))))
	var use_power := machine_recipe_power(machine_id, recipe)
	if power < use_power:
		return {"ok": false, "text": "电力不足：需要 %d，当前 %d。" % [use_power, power]}
	for inp in active_inputs:
		if inventory_count(String(inp.get("id", ""))) < int(inp.get("count", 1)):
			var d := get_item_def(String(inp.get("id", "")))
			return {"ok": false, "text": "缺少原料：%s x%d。" % [d.get("name", inp.get("id", "")), int(inp.get("count", 1))]}
	if dry_run:
		return {"ok": true, "text": "%s 可以启动（%d 夜 / %d 电力）。" % [m.get("name", machine_id), use_cycles, use_power]}
	for inp in active_inputs:
		remove_inventory(String(inp.get("id", "")), int(inp.get("count", 1)))
	power -= use_power
	var sums := machine_module_sums(machine_id)
	var quality_mod := int(sums["quality"]) + int(round(clampf(quality, 0.0, 1.0) * 20.0)) + quality_delta
	var features: Array = []
	if quality_mod != 0:
		features.append({"id": "machine_quality", "name": "精工" if quality_mod > 0 else "粗糙", "mod": quality_mod})
	if neutralized:
		features.append({"id": "neutralized", "name": "已中和", "mod": 10})
	var out_cond := 100
	if bool(recipe.get("melee", false)):
		out_cond = clampi(20 + rng.randi_range(20, 30) + quality_mod / 4 + avg_cond / 10, 0, 100)
	if bool(recipe.get("chem_loss", false)) or machine_id == "chem_finisher":
		var chem_mods := 0
		for mid in installed:
			if String(module_def(String(mid)).get("type", "")) == "MODULE_TYPE_CHEM":
				chem_mods += 1
		var losses: Array = [12, 6, 3, 1, 0]
		if machine_id == "blender":
			losses = [35, 20, 10, 5, 0]
		var loss := int(losses[mini(chem_mods, losses.size() - 1)])
		if loss > 0:
			features.append({"id": "impurity", "name": "杂质", "mod": -loss})
	var job := {
		"machine_id": machine_id, "name": String(m.get("name", machine_id)),
		"remaining": use_cycles, "total": use_cycles,
		"outputs": active_outputs.duplicate(true), "recipe": String(recipe.get("id", "")),
		"quality_mod": quality_mod, "features": features, "out_cond": out_cond,
	}
	if machine_id == "plant_dna_manipulator":
		var dna_sp: Dictionary = m.get("special", {})
		var chance := int(dna_sp.get("base_success", 70))
		if installed.has("dna_manipulator_module_stabilizer"):
			chance += int(dna_sp.get("stabilizer_bonus", 15))
		if installed.has("dna_manipulator_module_precision"):
			chance += int(dna_sp.get("precision_bonus", 10))
		chance += int(sums["quality"]) / 2
		job["dna_fail"] = rng.randi_range(1, 100) > chance
		job["dna_chance"] = chance
	var growth := machine_id in GROWTH_MACHINES
	if growth:
		job["growth"] = true
		job["ready"] = false
		job["harvests_left"] = GROWTH_HARVESTS
		job["regrow"] = maxi(1, int(round(float(use_cycles) * 0.6)))
	machine_jobs.append(job)
	emit_signal("state_changed")
	if growth:
		return {"ok": true, "text": "%s 已播种，预计 %d 夜成熟。" % [job["name"], job["remaining"]]}
	return {"ok": true, "text": "%s 已启动，预计 %d 夜。" % [job["name"], job["remaining"]]}

func set_machine_temp(machine_id: String, level: int) -> void:
	machine_temps[machine_id] = clampi(level, 1, 3)
	emit_signal("state_changed")

func machine_fault_name(fault: String) -> String:
	return String(MACHINE_FAULTS.get(fault, {}).get("name", fault))

func machine_fault_fee(fault: String) -> int:
	return int(MACHINE_FAULTS.get(fault, {}).get("fee", 0))

func _roll_machine_fault(machine_id: String) -> String:
	var temp := clampi(int(machine_temps.get(machine_id, 2)), 1, 3)
	var chance: float = [0.03, 0.06, 0.12][temp - 1]
	if int(machine_durability.get(machine_id, 100)) < 30:
		chance += 0.05
	if rng.randf() >= chance:
		return ""
	var keys := MACHINE_FAULTS.keys()
	return String(keys[rng.randi_range(0, keys.size() - 1)])

func machine_repair_cost(machine_id: String) -> int:
	var m := machine_def(machine_id)
	var cost := 60 + int(m.get("power", 2)) * 20
	if machine_faults.has(machine_id):
		cost += machine_fault_fee(String(machine_faults[machine_id]))
	return cost

func repair_machine(machine_id: String) -> Dictionary:
	var m := machine_def(machine_id)
	if m.is_empty():
		return {"ok": false, "text": "没有这台机器。"}
	var has_fault := machine_faults.has(machine_id)
	if int(machine_durability.get(machine_id, 100)) >= 100 and not has_fault:
		return {"ok": false, "text": "%s 状态良好，不需要维修。" % m.get("name", machine_id)}
	var cost := machine_repair_cost(machine_id)
	if cash < cost:
		return {"ok": false, "text": "维修需要 %d₵，现金不足。" % cost}
	cash -= cost
	machine_durability[machine_id] = 100
	machine_faults.erase(machine_id)
	emit_signal("state_changed")
	return {"ok": true, "text": "%s 已维修，花费 %d₵。" % [m.get("name", machine_id), cost]}

func _grant_job_outputs(job: Dictionary) -> Array:
	if bool(job.get("dna_fail", false)):
		return []
	var got: Array = []
	var cond := int(job.get("out_cond", 100))
	var features: Array = job.get("features", [])
	for out in job.get("outputs", []):
		var oid := String(out.get("id", ""))
		if not items_def.has(oid):
			continue
		for n in range(int(out.get("count", 1))):
			var it := _make_output_item(oid, cond, features)
			add_item(it)
			got.append(String(get_item_def(oid).get("name", oid)))
	return got

func harvest_machine(machine_id: String) -> Dictionary:
	var idx := -1
	for i in range(machine_jobs.size()):
		if String(machine_jobs[i].get("machine_id", "")) == machine_id:
			idx = i
			break
	if idx < 0:
		return {"ok": false, "text": "这台机器没有正在生长的作物。"}
	var j: Dictionary = machine_jobs[idx]
	if not bool(j.get("growth", false)):
		return {"ok": false, "text": "这台机器不能收获。"}
	if not bool(j.get("ready", false)):
		return {"ok": false, "text": "作物还在生长，暂时不能收获。"}
	var got: Array = _grant_job_outputs(j)
	var mid := machine_id
	var wear: int = [1, 2, 3][clampi(int(machine_temps.get(mid, 2)), 1, 3) - 1] + rng.randi_range(0, 1)
	var dur := maxi(0, int(machine_durability.get(mid, 100)) - wear)
	machine_durability[mid] = dur
	var left := int(j.get("harvests_left", 1)) - 1
	var msg := "收获：+%s" % "、".join(got)
	if left > 0:
		j["harvests_left"] = left
		j["ready"] = false
		j["remaining"] = float(j.get("regrow", 1.0))
		msg += "，还可收获 %d 次。" % left
	else:
		machine_jobs.remove_at(idx)
		msg += "，作物已耗尽。"
	if dur <= 0:
		msg += "（机器损坏，需要维修）"
	var fault := _roll_machine_fault(mid)
	if fault != "":
		machine_faults[mid] = fault
		msg += "（故障：%s）" % machine_fault_name(fault)
	emit_signal("state_changed")
	return {"ok": true, "text": msg}

func _process(_delta: float) -> void:
	pass

func _machine_state(machine_id: String) -> Dictionary:
	if not machine_state.has(machine_id) or not (machine_state[machine_id] is Dictionary):
		machine_state[machine_id] = {}
	return machine_state[machine_id]

func machine_is_active(machine_id: String) -> bool:
	return bool(machine_active.get(machine_id, false))

func machine_toggle_active(machine_id: String) -> Dictionary:
	var m := machine_def(machine_id)
	if m.is_empty():
		return {"ok": false, "text": "没有这台机器。"}
	if m.get("special", {}).is_empty():
		return {"ok": false, "text": "这台机器不需要启用。"}
	if int(machine_durability.get(machine_id, 100)) <= 0:
		return {"ok": false, "text": "%s 已损坏，请先维修。" % m.get("name", machine_id)}
	if machine_faults.has(machine_id):
		return {"ok": false, "text": "%s 有故障，请先维修。" % m.get("name", machine_id)}
	var now := not machine_is_active(machine_id)
	machine_active[machine_id] = now
	if machine_id == "powerblock":
		_refresh_upgrades()
	emit_signal("state_changed")
	return {"ok": true, "text": "%s 已%s。" % [m.get("name", machine_id), "启用" if now else "停用"]}

func _aux_can_draw(machine_id: String, amount: int) -> bool:
	if amount <= 0:
		return true
	if power < amount:
		_add_night_log(String(machine_def(machine_id).get("name", machine_id)) + " 电力不足，未运行。")
		return false
	power -= amount
	return true

func _add_night_log(text: String) -> void:
	night_log.append(text)

func machine_aux_power(machine_id: String) -> int:
	var sp: Dictionary = machine_def(machine_id).get("special", {})
	return int(sp.get("power", machine_def(machine_id).get("power", 0)))

func _run_auxiliary_machines() -> void:
	night_log = []
	security_alarm_active = false
	security_stop_rate = 0
	attraction_bonus = 100
	var moisture_count := 0
	for m in machines:
		if String(m.get("id", "")) == "moisture_farm" and machine_is_active("moisture_farm"):
			moisture_count += 1
	var feed_kcal := 0
	for m in machines:
		var mid := String(m.get("id", ""))
		if String(m.get("special", {}).get("kind", "")) == "feed" and machine_is_active(mid):
			feed_kcal += int(_machine_state(mid).get("kcal", 0))
	for m in machines:
		var mid := String(m.get("id", ""))
		var sp: Dictionary = m.get("special", {})
		if sp.is_empty() or not machine_is_active(mid):
			continue
		if int(machine_durability.get(mid, 100)) <= 0 or machine_faults.has(mid):
			continue
		var kind := String(sp.get("kind", ""))
		match kind:
			"recharge":
				next_day_power_bonus += int(sp.get("rate", 3))
				_add_night_log("充能器为电池组补充 %d 电力。" % int(sp.get("rate", 3)))
			"reactor":
				_run_reactor(mid, sp)
				if phase == "gameover":
					return
			"alarm":
				if _aux_can_draw(mid, int(sp.get("power", 4))):
					security_alarm_active = true
					security_stop_rate = clampi(int(sp.get("base_stop", 50)) + int(machine_module_sums(mid)["performance"]), 0, 100)
			"attract":
				if _aux_can_draw(mid, int(sp.get("power", 16))):
					var sums := machine_module_sums(mid)
					attraction_bonus = int(sp.get("base", 100)) + int(sums["quality"]) / maxi(1, int(sp.get("quality_div", 2))) + int(sums["performance"]) / maxi(1, int(sp.get("performance_div", 4)))
					_add_night_log("幻影投影仪运行，明日吸引力 %d%%。" % attraction_bonus)
			"vending":
				_run_vending(mid, sp)
			"fountain":
				_run_fountain(mid, sp)
			"wine":
				_run_wine_rack(mid, sp)
			"fridge":
				_run_fridge(mid, sp)
			"cage":
				_run_cage(mid, sp, feed_kcal)
			"feed":
				_run_feed(mid, sp)
			"vacuum":
				_run_vacuum(mid, sp)
			"moisture":
				_run_moisture(mid, sp, moisture_count)
			"ras":
				_run_ras(mid, sp)
	_run_theft_check()

func _run_reactor(mid: String, sp: Dictionary) -> void:
	var st := _machine_state(mid)
	if not st.has("integrity"):
		st["integrity"] = int(sp.get("max_integrity", 100))
		st["max_integrity"] = int(sp.get("max_integrity", 100))
		st["upgrades"] = 0
		st["waste"] = 0
	var max_int := int(st.get("max_integrity", 100))
	var integrity := int(st.get("integrity", max_int))
	var upgrades := int(st.get("upgrades", 0))
	var decay := maxi(0, int(sp.get("decay", 18)) - upgrades)
	integrity = maxi(0, integrity - decay)
	st["waste"] = int(st.get("waste", 0)) + decay
	while int(st["waste"]) >= int(sp.get("waste_per_damage", 160)):
		st["waste"] = int(st["waste"]) - int(sp.get("waste_per_damage", 160))
		if items_def.has("nuclear_waste"):
			add_item(make_item("nuclear_waste", 100, true, false))
			_add_night_log("反应堆排出 1 份核废料。")
	st["integrity"] = integrity
	if integrity <= 0:
		_add_night_log("简易反应堆爆炸了。")
		phase = "gameover"
		ending_id = "reactor"
		emit_signal("state_changed")
		return
	if integrity > int(sp.get("power_threshold", 25)):
		var charge := mini(int(sp.get("max_charge", 4)), int(sp.get("base_charge", 1)) + upgrades / maxi(1, int(sp.get("upgrades_per_charge", 5))))
		next_day_power_bonus += charge
	_add_night_log("反应堆完整度 %d/%d，充能 %d。" % [integrity, max_int, mini(int(sp.get("max_charge", 4)), int(sp.get("base_charge", 1)) + upgrades / maxi(1, int(sp.get("upgrades_per_charge", 5))))])

func _stock_items(mid: String) -> Array:
	if not machine_stock.has(mid) or not (machine_stock[mid] is Array):
		machine_stock[mid] = []
	return machine_stock[mid]

func _eligible_for_stock(mid: String, it: Dictionary) -> bool:
	var kind := String(machine_def(mid).get("special", {}).get("kind", ""))
	var def := get_item_def(String(it.get("def_id", "")))
	var tags: Array = def.get("tags", [])
	var cat := String(def.get("category", ""))
	match kind:
		"vending":
			var vid := String(it.get("def_id", ""))
			if vid in ["water_jug", "water_bottle_full", "large_water_bottle_full", "small_bottled_water", "bottled_water", "large_bottled_water", "mini_bottle"]:
				return false
			if int(def.get("contraband", 0)) > 0 or cat == "furniture" or cat == "machine":
				return false
			if tags.has("CONTAINER_TAG") or tags.has("container"):
				return false
			if cat == "water" and not vid.contains("wine"):
				return false
			return true
		"fountain":
			return cat == "water" or String(it.get("def_id", "")) in ["water_jug", "small_bottled_water", "bottled_water", "large_bottled_water", "mini_bottle", "water_bottle_full", "large_water_bottle_full"]
		"wine":
			var did := String(it.get("def_id", ""))
			return cat == "food" and (did.contains("wine") or did == "red_beer" or did == "wine_bottle")
		"fridge":
			return cat in ["food", "organ", "medical"]
		"cage":
			var did2 := String(it.get("def_id", ""))
			if did2.begins_with("feces"):
				return false
			return did2 == "rat" or (tags.has("animal") and int(def.get("base_value", 0)) <= 0)
		"feed":
			return cat == "food" or cat == "animal"
		"butcher":
			var did3 := String(it.get("def_id", ""))
			return did3 == "rat" or tags.has("animal_item_tag")
		"mark":
			var did4 := String(it.get("def_id", ""))
			return did4 == "rat" or tags.has("animal_item_tag") or tags.has("animal")
	return false

func machine_stock_limit(machine_id: String) -> int:
	var sp: Dictionary = machine_def(machine_id).get("special", {})
	var kind := String(sp.get("kind", ""))
	match kind:
		"vending": return 8 * (int(sp.get("capacity", 2)) + int(machine_upgrades.get(machine_id, 0)) / 2)
		"fountain": return 9
		"wine": return int(sp.get("bottle_capacity", 6))
		"fridge": return 10 + int(machine_upgrades.get(machine_id, 0)) * 2
		"cage": return (int(sp.get("size", 3)) + int(machine_upgrades.get(machine_id, 0))) * 10
		"feed": return 20
		"butcher": return int(sp.get("keep_max", 10))
	return 10

func machine_stock_add(machine_id: String, uid: int) -> Dictionary:
	var idx := -1
	for i in range(inventory.size()):
		if int(inventory[i].get("uid", -1)) == uid:
			idx = i
			break
	if idx < 0:
		return {"ok": false, "text": "背包里没有这件物品。"}
	var it: Dictionary = inventory[idx]
	if not _eligible_for_stock(machine_id, it):
		return {"ok": false, "text": "这件物品不能存入该机器。"}
	if _stock_items(machine_id).size() >= machine_stock_limit(machine_id):
		return {"ok": false, "text": "机器库存已满。"}
	inventory.remove_at(idx)
	it["location"] = "machine"
	_stock_items(machine_id).append(it)
	emit_signal("state_changed")
	return {"ok": true, "text": "已存入：%s。" % String(get_item_def(String(it.get("def_id", ""))).get("name", ""))}

func machine_stock_take_all(machine_id: String) -> Dictionary:
	var stock := _stock_items(machine_id)
	var got := 0
	var failed := 0
	while not stock.is_empty():
		var it: Dictionary = stock[0]
		it["location"] = "backpack"
		if add_item(it):
			stock.remove_at(0)
			got += 1
		else:
			failed += 1
			break
	emit_signal("state_changed")
	return {"ok": got > 0, "text": "取回 %d 件物品%s。" % [got, "，背包空间不足" if failed > 0 else ""]}

func _run_vending(mid: String, sp: Dictionary) -> void:
	if not _aux_can_draw(mid, int(sp.get("power", 2))):
		return
	var stock := _stock_items(mid)
	if stock.is_empty():
		return
	var capacity := int(sp.get("capacity", 2)) + int(machine_upgrades.get(mid, 0)) / 2
	var limit := 1 + capacity / 3
	var sold := 0
	while sold < limit and not stock.is_empty():
		var it: Dictionary = stock.pop_front()
		var val := market_value(it, true)
		machine_cash[mid] = int(machine_cash.get(mid, 0)) + val
		sold += 1
	if sold > 0:
		_add_night_log("自动售货机卖出 %d 件，收入 %d₵（待收取）。" % [sold, int(machine_cash.get(mid, 0))])

func _run_fountain(mid: String, sp: Dictionary) -> void:
	if not _aux_can_draw(mid, int(sp.get("power", 2))):
		return
	var stock := _stock_items(mid)
	if stock.is_empty():
		return
	var attract := int(sp.get("attractiveness", 15)) + int(machine_upgrades.get(mid, 0)) * int(sp.get("attract_per_upgrade", 5))
	var limit := 1 + attract / 40
	var sold := 0
	while sold < limit and not stock.is_empty():
		var it: Dictionary = stock.pop_front()
		var val := int(round(float(market_value(it, true)) * 1.3))
		machine_cash[mid] = int(machine_cash.get(mid, 0)) + val
		sold += 1
	if sold > 0:
		_add_night_log("自动售水机卖出 %d 份水，收入 %d₵（待收取）。" % [sold, int(machine_cash.get(mid, 0))])

func _run_wine_rack(mid: String, sp: Dictionary) -> void:
	if not _aux_can_draw(mid, int(sp.get("power", 24))):
		return
	var stock := _stock_items(mid)
	if stock.is_empty():
		return
	var sums := machine_module_sums(mid)
	var days := 1 + maxi(0, int(sums["quality"])) / maxi(1, int(sp.get("quality_div", 125)))
	for it in stock:
		it["aged_days"] = int(it.get("aged_days", 0)) + days
		var mod := mini(100, int(it["aged_days"]) * 10)
		var found := false
		for f in it.get("features", []):
			if String(f.get("id", "")) == "aged":
				f["mod"] = mod
				found = true
				break
		if not found:
			it["features"].append({"id": "aged", "name": "陈年", "mod": mod})
	_add_night_log("催陈器陈化 %d 瓶酒，每瓶 +%d 天。" % [stock.size(), days])

func _run_fridge(mid: String, sp: Dictionary) -> void:
	if not _aux_can_draw(mid, int(sp.get("power", 2))):
		return
	for it in _stock_items(mid):
		var found := false
		for f in it.get("features", []):
			if String(f.get("id", "")) == "chilled":
				f["mod"] = int(sp.get("chill_bonus", 20))
				found = true
				break
		if not found:
			it["features"].append({"id": "chilled", "name": "冷藏", "mod": int(sp.get("chill_bonus", 20))})

func _run_cage(mid: String, sp: Dictionary, feed_kcal: int) -> void:
	var stock := _stock_items(mid)
	var animals := 0
	for it in stock:
		if _eligible_for_stock(mid, it):
			animals += 1
	if animals <= 0:
		return
	var st := _machine_state(mid)
	if not st.has("health"):
		st["health"] = int(sp.get("health", 100))
	var health := int(st.get("health", 100))
	var max_health := int(sp.get("max_health", 100)) + int(machine_upgrades.get(mid, 0)) * 20
	var wear := animals / maxi(1, int(sp.get("wear_divisor", 4)))
	health = maxi(0, health - wear)
	if feed_kcal >= animals * 100:
		health = mini(max_health, health + animals * 5)
		for m in machines:
			if String(m.get("special", {}).get("kind", "")) == "feed" and machine_is_active(String(m.get("id", ""))):
				var fs := _machine_state(String(m.get("id", "")))
				fs["kcal"] = maxi(0, int(fs.get("kcal", 0)) - animals * 100)
				break
	st["health"] = health
	if health < int(sp.get("escape_threshold", 20)):
		var chance := 5
		if health <= 0:
			chance = int(sp.get("escape_chance_zero", 25))
		else:
			chance = int(round(lerpf(25.0, 5.0, float(health) / float(sp.get("escape_threshold", 20)))))
		if rng.randi_range(1, 100) <= chance and not stock.is_empty():
			var escaped: Dictionary = stock.pop_back()
			_add_night_log("笼中动物逃脱：%s。" % String(get_item_def(String(escaped.get("def_id", ""))).get("name", "")))
	for i in range(animals):
		if rng.randf() < 0.25 and items_def.has("feces_small"):
			add_item(make_item("feces_small", 100, true, false))

func _run_feed(mid: String, sp: Dictionary) -> void:
	var st := _machine_state(mid)
	if not st.has("kcal"):
		st["kcal"] = 0
	var stock := _stock_items(mid)
	var converted := 0
	while not stock.is_empty() and int(st["kcal"]) < int(sp.get("max_kcal", 40000)):
		var it: Dictionary = stock.pop_front()
		var did := String(it.get("def_id", ""))
		var kcal := 100
		if did == "raw_meat":
			kcal = 2000
		elif did == "small_raw_meat":
			kcal = 800
		elif did == "meat_scrap":
			kcal = 300
		elif did == "processed_meat":
			kcal = 1000
		elif did == "nutrifruit":
			kcal = 500
		st["kcal"] = mini(int(sp.get("max_kcal", 40000)), int(st["kcal"]) + kcal)
		converted += 1
	if converted > 0:
		_add_night_log("饲料分配器转化 %d 份食物，储存 %d kcal。" % [converted, int(st["kcal"])])

func _run_vacuum(mid: String, sp: Dictionary) -> void:
	var gained := 0
	for i in range(inventory.size() - 1, -1, -1):
		var did := String(inventory[i].get("def_id", ""))
		if did in ["feces_small", "feces_medium", "feces_large"]:
			inventory.remove_at(i)
			gained += 1
	if gained > 0:
		next_day_power_bonus += gained * int(sp.get("power_per_feces", 1))
		_add_night_log("清洁机器人焚化 %d 份粪便，回收 %d 电力。" % [gained, gained * int(sp.get("power_per_feces", 1))])

func _run_moisture(mid: String, sp: Dictionary, active_count: int) -> void:
	if not _aux_can_draw(mid, int(sp.get("power", 6))):
		return
	var st := _machine_state(mid)
	if not st.has("ml"):
		st["ml"] = 0
	var sums := machine_module_sums(mid)
	var base := int(round(float(sp.get("base_ml", 850)) * (1.0 + float(sums["performance"]) / 100.0)))
	var count := maxi(1, active_count)
	var volume := int(round(float(base) / (1.0 + float(sp.get("shared_air", 0.25)) * float(count - 1))))
	st["ml"] = int(st["ml"]) + volume
	while int(st["ml"]) >= 1000 and items_def.has("water_jug"):
		st["ml"] = int(st["ml"]) - 1000
		var it := make_item("water_jug", 100, true, false)
		var quality := int(sums["quality"])
		it["features"].append({"id": "water_quality", "name": "纯净水" if quality >= 50 else ("基础水" if quality >= 0 else "锈水"), "mod": quality})
		add_item(it)
	_add_night_log("湿气农场产出 %dml 水（共用空气 %d 台）。" % [volume, count])

func _run_ras(mid: String, sp: Dictionary) -> void:
	if not _aux_can_draw(mid, int(sp.get("power", 5))):
		return
	var st := _machine_state(mid)
	if not st.has("growth"):
		st["growth"] = 0
	var feed := "industrial_fish_feed"
	if inventory_count(feed) <= 0:
		_add_night_log("循环水养殖系统缺饲料，未生长。")
		return
	remove_inventory(feed, 1)
	st["growth"] = int(st["growth"]) + 25
	if int(st["growth"]) >= 100:
		st["growth"] = 0
		for i in range(2):
			add_item(make_item("fish_fillet", 100, true, false))
		_add_night_log("循环水养殖系统收获 2 份鱼片。")
	else:
		_add_night_log("循环水养殖系统生长 %d%%。" % int(st["growth"]))

func _run_theft_check() -> void:
	if display.is_empty():
		return
	if rng.randf() >= 0.12:
		return
	if security_alarm_active and rng.randi_range(1, 100) <= security_stop_rate:
		_add_night_log("警报系统阻止了一次店内盗窃（阻止率 %d%%）。" % security_stop_rate)
		return
	var idx := rng.randi_range(0, display.size() - 1)
	var stolen: Dictionary = display[idx]
	display.remove_at(idx)
	_add_night_log("店内失窃：%s。" % String(get_item_def(String(stolen.get("def_id", ""))).get("name", "")))
	add_rep("lower", -1)

func machine_special_action(machine_id: String) -> Dictionary:
	var m := machine_def(machine_id)
	if m.is_empty():
		return {"ok": false, "text": "没有这台机器。"}
	var sp: Dictionary = m.get("special", {})
	if sp.is_empty():
		return {"ok": false, "text": "这台机器没有专用操作。"}
	var kind := String(sp.get("kind", ""))
	match kind:
		"bargain":
			if current_customer.is_empty():
				return {"ok": false, "text": "现在没有顾客。"}
			if bargain_bonus > 0:
				return {"ok": false, "text": "这位顾客已经受过 Deal Maker 影响。"}
			var need := int(sp.get("power", 25))
			if power < need:
				return {"ok": false, "text": "电力不足：需要 %d，当前 %d。" % [need, power]}
			power -= need
			bargain_bonus = int(sp.get("base", 10)) + int(machine_module_sums(machine_id)["quality"]) / maxi(1, int(sp.get("quality_div", 1)))
			emit_signal("state_changed")
			return {"ok": true, "text": "Deal Maker 已启用：本次议价 +%d%%。" % bargain_bonus}
		"vending", "fountain":
			return _vending_action(machine_id, sp)
		"reactor":
			return _reactor_action(machine_id, sp)
		"cage":
			return _cage_action(machine_id, sp)
		"bottle_printer", "fridge", "ras":
			return _upgrade_action(machine_id, sp)
		"storage_preset":
			return _storage_preset_action(machine_id)
		"music":
			var st := _machine_state(machine_id)
			st["on"] = not bool(st.get("on", false))
			emit_signal("music_toggled", bool(st["on"]))
			emit_signal("state_changed")
			return {"ok": true, "text": "磁带播放器已%s。" % ("播放" if bool(st["on"]) else "停止")}
		"mark":
			var cage_stock := _stock_items("animal_cage")
			if cage_stock.is_empty():
				return {"ok": false, "text": "动物笼里没有可标记的动物。"}
			var animal: Dictionary = cage_stock[0]
			var colors: Array = sp.get("colors", ["red"])
			var color := String(colors[rng.randi_range(0, colors.size() - 1)])
			animal["features"] = animal.get("features", [])
			animal["features"].append({"id": "mark_" + color, "name": "标记：" + color, "mod": 0})
			emit_signal("state_changed")
			return {"ok": true, "text": "已标记：%s（%s）。" % [String(get_item_def(String(animal.get("def_id", ""))).get("name", "")), color]}
		"purify", "distill", "heat":
			return {"ok": false, "text": "请选择要处理的液体/食物。", "select": kind}
		"butcher":
			if not _stock_items(machine_id).is_empty():
				return {"ok": false, "text": "选择屠宰操作。", "select_options": [
					{"id": "butcher_stock", "label": "屠宰库存中的 1 只动物"},
					{"id": "cancel", "label": "取消"}], "select_cb": "butcher", "machine": machine_id}
			return {"ok": false, "text": "请选择要屠宰的动物。", "select": "butcher"}
		_:
			return {"ok": false, "text": "这台机器会自动运行，无需手动操作。"}

func _reactor_action(mid: String, sp: Dictionary) -> Dictionary:
	var st := _machine_state(mid)
	var integrity := int(st.get("integrity", sp.get("max_integrity", 100)))
	var max_int := int(st.get("max_integrity", 100))
	var upgrades := int(st.get("upgrades", 0))
	var options: Array = []
	if integrity < max_int:
		if inventory_count("scrap_metal") > 0:
			options.append({"id": "repair_scrap", "label": "废金属维修（+%d 完整度）" % int(sp.get("repair_scrap", 60))})
		if inventory_count("junk") > 0:
			options.append({"id": "repair_junk", "label": "垃圾维修（+%d，上限 -%d）" % [int(sp.get("repair_junk", 30)), int(sp.get("junk_max_loss", 5))]})
	if upgrades < int(sp.get("max_upgrades", 18)) and inventory_count("common_electronic") > 0:
		options.append({"id": "upgrade", "label": "电子件升级（%d/%d）" % [upgrades, int(sp.get("max_upgrades", 18))]})
	if options.is_empty():
		return {"ok": false, "text": "没有可用的维修/升级材料。"}
	options.append({"id": "cancel", "label": "取消"})
	return {"ok": false, "text": "选择反应堆操作。", "select_options": options, "select_cb": "reactor", "machine": mid}

func _cage_action(mid: String, sp: Dictionary) -> Dictionary:
	var st := _machine_state(mid)
	var options: Array = []
	if inventory_count("metal_ingot") > 0 and int(machine_upgrades.get(mid, 0)) < int(sp.get("max_size", 8)) - int(sp.get("size", 3)):
		options.append({"id": "upgrade", "label": "金属锭扩容（%d 级）" % int(machine_upgrades.get(mid, 0))})
	if int(st.get("health", 100)) < int(sp.get("max_health", 100)) and inventory_count("scrap_metal") > 0:
		options.append({"id": "repair", "label": "废金属修理"})
	if options.is_empty():
		return {"ok": false, "text": "没有可用的升级/修理材料。"}
	options.append({"id": "cancel", "label": "取消"})
	return {"ok": false, "text": "选择动物笼操作。", "select_options": options, "select_cb": "cage", "machine": mid}

func reactor_apply(mid: String, action: String) -> Dictionary:
	var sp: Dictionary = machine_def(mid).get("special", {})
	var st := _machine_state(mid)
	var integrity := int(st.get("integrity", sp.get("max_integrity", 100)))
	var max_int := int(st.get("max_integrity", 100))
	match action:
		"repair_scrap":
			if inventory_count("scrap_metal") <= 0:
				return {"ok": false, "text": "缺少废金属。"}
			remove_inventory("scrap_metal", 1)
			st["integrity"] = mini(max_int, integrity + int(sp.get("repair_scrap", 60)))
			emit_signal("state_changed")
			return {"ok": true, "text": "反应堆完整度恢复到 %d/%d。" % [int(st["integrity"]), max_int]}
		"repair_junk":
			if inventory_count("junk") <= 0:
				return {"ok": false, "text": "缺少垃圾。"}
			remove_inventory("junk", 1)
			max_int = maxi(0, max_int - int(sp.get("junk_max_loss", 5)))
			st["max_integrity"] = max_int
			st["integrity"] = mini(max_int, integrity + int(sp.get("repair_junk", 30)))
			emit_signal("state_changed")
			return {"ok": true, "text": "反应堆完整度恢复到 %d/%d（上限下降）。" % [int(st["integrity"]), max_int]}
		"upgrade":
			if inventory_count("common_electronic") <= 0:
				return {"ok": false, "text": "缺少电子件。"}
			remove_inventory("common_electronic", 1)
			st["upgrades"] = int(st.get("upgrades", 0)) + 1
			emit_signal("state_changed")
			return {"ok": true, "text": "反应堆升级到 %d 级。" % int(st["upgrades"])}
	return {"ok": false, "text": "取消。"}

func cage_apply(mid: String, action: String) -> Dictionary:
	var sp: Dictionary = machine_def(mid).get("special", {})
	var st := _machine_state(mid)
	match action:
		"upgrade":
			if inventory_count("metal_ingot") <= 0:
				return {"ok": false, "text": "缺少金属锭。"}
			remove_inventory("metal_ingot", 1)
			machine_upgrades[mid] = int(machine_upgrades.get(mid, 0)) + 1
			emit_signal("state_changed")
			return {"ok": true, "text": "动物笼扩容到 %d 级。" % int(machine_upgrades[mid])}
		"repair":
			if inventory_count("scrap_metal") <= 0:
				return {"ok": false, "text": "缺少废金属。"}
			remove_inventory("scrap_metal", 1)
			st["health"] = mini(int(sp.get("max_health", 100)) + int(machine_upgrades.get(mid, 0)) * 20, int(st.get("health", 0)) + 50)
			emit_signal("state_changed")
			return {"ok": true, "text": "动物笼已修理。"}
	return {"ok": false, "text": "取消。"}

func _upgrade_action(mid: String, sp: Dictionary) -> Dictionary:
	var max_level := 9
	var material := "common_electronic"
	if mid == "fridge":
		max_level = 14
	elif mid == "ras":
		max_level = 20
	elif mid == "vending_machine":
		max_level = 27
	elif mid == "vending_fountain":
		max_level = 17
	var level := int(machine_upgrades.get(mid, 0))
	if level >= max_level:
		return {"ok": false, "text": "已经升到最高级。"}
	if inventory_count(material) <= 0:
		return {"ok": false, "text": "缺少升级材料：%s。" % String(get_item_def(material).get("name", material))}
	remove_inventory(material, 1)
	machine_upgrades[mid] = level + 1
	emit_signal("state_changed")
	return {"ok": true, "text": "%s 升级到 %d 级。" % [machine_def(mid).get("name", mid), level + 1]}

func _vending_action(mid: String, sp: Dictionary) -> Dictionary:
	var options: Array = []
	var cash_in := int(machine_cash.get(mid, 0))
	if cash_in > 0:
		options.append({"id": "collect", "label": "收取现金 %d₵" % cash_in})
	var material := String(sp.get("upgrade_material", "common_electronic"))
	if inventory_count(material) > 0:
		options.append({"id": "upgrade", "label": "升级（消耗 1 %s）" % String(get_item_def(material).get("name", material))})
	if options.is_empty():
		return {"ok": false, "text": "没有待收现金，也缺少升级材料。"}
	if options.size() == 1:
		return machine_special_choice(mid, String(options[0]["id"]))
	options.append({"id": "cancel", "label": "取消"})
	return {"ok": false, "text": "选择操作。", "select_options": options, "select_cb": "vending", "machine": mid}

func machine_special_choice(machine_id: String, action: String) -> Dictionary:
	var sp: Dictionary = machine_def(machine_id).get("special", {})
	if action == "cancel":
		return {"ok": false, "text": "已取消。"}
	if action == "collect":
		var cash_in := int(machine_cash.get(machine_id, 0))
		if cash_in <= 0:
			return {"ok": false, "text": "机器里没有待收取的现金。"}
		cash += cash_in
		daily["sales"] += cash_in
		machine_cash[machine_id] = 0
		emit_signal("state_changed")
		return {"ok": true, "text": "收取 %d₵。" % cash_in}
	if action == "butcher_stock":
		return _butcher_stock(machine_id)
	if action == "upgrade":
		if String(sp.get("kind", "")) == "cage":
			return cage_apply(machine_id, action)
		return _upgrade_action(machine_id, sp)
	if action in ["repair_scrap", "repair_junk"]:
		return reactor_apply(machine_id, action)
	if action == "repair":
		return cage_apply(machine_id, action)
	return {"ok": false, "text": "未知操作。"}

func _storage_preset_action(mid: String) -> Dictionary:
	var st := _machine_state(mid)
	if not st.has("preset"):
		var preset: Array = []
		for it in display:
			preset.append(String(it.get("def_id", "")))
		st["preset"] = preset
		emit_signal("state_changed")
		return {"ok": true, "text": "已保存货架预设（%d 件）。" % preset.size()}
	var restored := 0
	for did in st["preset"]:
		if display.size() >= DISPLAY_SLOTS:
			break
		for i in range(inventory.size()):
			if String(inventory[i].get("def_id", "")) == String(did):
				var it: Dictionary = inventory[i]
				inventory.remove_at(i)
				it["location"] = "display"
				display.append(it)
				restored += 1
				break
	emit_signal("state_changed")
	return {"ok": true, "text": "按预设补货 %d 件。" % restored}

func is_water_container_item(def_id: String) -> bool:
	var def := get_item_def(def_id)
	var tags: Array = def.get("tags", [])
	for t in tags:
		if String(t) in ["WATER_PURIFICATION_TABLET", "WATER_TESTING_STRIP_TAG", "WATER_FILTER", "PRE_CONTAINER_TAG"]:
			return false
	if def_id.contains("tablet") or def_id.contains("filter") or def_id.contains("strip"):
		return false
	if tags.has("LIQUID_CONTAINER_TAG"):
		return true
	if String(def.get("inspect_type", "")) != "water" and not tags.has("water"):
		return false
	return def_id.contains("bottle") or def_id.contains("jug") or def_id.contains("pitcher") or def_id.contains("tank") or def_id.contains("ration")

func apply_item_service(machine_id: String, uid: int) -> Dictionary:
	var m := machine_def(machine_id)
	var sp: Dictionary = m.get("special", {})
	var kind := String(sp.get("kind", ""))
	var idx := -1
	for i in range(inventory.size()):
		if int(inventory[i].get("uid", -1)) == uid:
			idx = i
			break
	if idx < 0:
		return {"ok": false, "text": "背包里没有这件物品。"}
	var it: Dictionary = inventory[idx]
	var did := String(it.get("def_id", ""))
	var def := get_item_def(did)
	var tags: Array = def.get("tags", [])
	if kind in ["purify", "distill", "heat"]:
		if not is_water_container_item(did):
			return {"ok": false, "text": "只能处理液体容器。"}
		var need := int(sp.get("power", 0)) if kind != "heat" else 0
		if power < need:
			return {"ok": false, "text": "电力不足：需要 %d，当前 %d。" % [need, power]}
		power -= need
		if kind == "purify":
			for f in it.get("features", []):
				if int(f.get("mod", 0)) < 0:
					f["mod"] = 0
			it["features"].append({"id": "purified", "name": "已净化", "mod": 15})
		elif kind == "distill":
			it["features"].append({"id": "distilled", "name": "蒸馏", "mod": 20})
			if machine_module_ids(machine_id).has(String(sp.get("solvent_module", ""))):
				it["features"].append({"id": "solvent", "name": "溶剂回收", "mod": 10})
		else:
			it["features"].append({"id": "heated", "name": "已加热", "mod": 8})
		emit_signal("state_changed")
		return {"ok": true, "text": "%s 已处理：%s。" % [m.get("name", machine_id), String(def.get("name", did))]}
	if kind == "mark":
		var color := "red"
		var colors: Array = sp.get("colors", ["red"])
		color = String(colors[rng.randi_range(0, colors.size() - 1)])
		it["features"].append({"id": "mark_" + color, "name": "标记：" + color, "mod": 0})
		emit_signal("state_changed")
		return {"ok": true, "text": "已标记：%s（%s）。" % [String(def.get("name", did)), color]}
	if kind == "butcher":
		if not _eligible_for_stock(machine_id, it):
			return {"ok": false, "text": "这件物品不能屠宰。"}
		inventory.remove_at(idx)
		var cuts := 1
		if did == "rat":
			cuts = 1
			add_item(make_item("small_raw_meat", 100, true, false))
			add_item(make_item("meat_scrap", 100, true, false))
		else:
			add_item(make_item("small_raw_meat", 100, true, false))
		emit_signal("state_changed")
		return {"ok": true, "text": "已屠宰：%s，获得 %d 份肉。" % [String(def.get("name", did)), cuts + 1]}
	return {"ok": false, "text": "无法处理。"}

func _butcher_stock(machine_id: String) -> Dictionary:
	var stock := _stock_items(machine_id)
	if stock.is_empty():
		return {"ok": false, "text": "屠宰机库存里没有动物。"}
	var it: Dictionary = stock.pop_front()
	var did := String(it.get("def_id", ""))
	var def := get_item_def(did)
	var produced: Array = []
	if did == "rat":
		if add_item(make_item("small_raw_meat", 100, true, false)):
			produced.append(String(get_item_def("small_raw_meat").get("name", "small_raw_meat")))
		if add_item(make_item("meat_scrap", 100, true, false)):
			produced.append(String(get_item_def("meat_scrap").get("name", "meat_scrap")))
	else:
		if add_item(make_item("small_raw_meat", 100, true, false)):
			produced.append(String(get_item_def("small_raw_meat").get("name", "small_raw_meat")))
	emit_signal("state_changed")
	return {"ok": true, "text": "已屠宰 %s，获得：%s。" % [String(def.get("name", did)), "、".join(produced)]}

func machine_stock_summary(machine_id: String) -> String:
	var stock := _stock_items(machine_id)
	var counts := {}
	for it in stock:
		var did := String(it.get("def_id", ""))
		counts[did] = int(counts.get(did, 0)) + 1
	var parts: Array = []
	for did in counts.keys():
		parts.append("%s×%d" % [String(get_item_def(String(did)).get("name", did)), int(counts[did])])
	return "、".join(parts)

func advance_machines_one_cycle() -> void:
	_run_auxiliary_machines()
	if machine_jobs.is_empty():
		emit_signal("state_changed")
		return
	var finished: Array = []
	var k := 0
	while k < machine_jobs.size():
		var j: Dictionary = machine_jobs[k]
		if bool(j.get("growth", false)) and bool(j.get("ready", false)):
			k += 1
			continue
		j["remaining"] = maxi(0, int(j.get("remaining", 0)) - 1)
		if int(j["remaining"]) <= 0:
			if bool(j.get("growth", false)):
				j["ready"] = true
				emit_signal("machine_finished", "%s 已成熟，可收获（剩余 %d 次）。" % [j.get("name", ""), int(j.get("harvests_left", 0))])
				k += 1
			else:
				finished.append(j)
				machine_jobs.remove_at(k)
		else:
			k += 1
	for j in finished:
		var got: Array = _grant_job_outputs(j)
		var mid := String(j.get("machine_id", ""))
		var wear: int = [1, 2, 3][clampi(int(machine_temps.get(mid, 2)), 1, 3) - 1] + rng.randi_range(0, 1)
		var dur := maxi(0, int(machine_durability.get(mid, 100)) - wear)
		machine_durability[mid] = dur
		var msg := "%s 完成：+%s" % [j.get("name", ""), "、".join(got)]
		if bool(j.get("dna_fail", false)):
			msg = "%s 完成：性状操作失败（成功率 %d%%）。" % [j.get("name", ""), int(j.get("dna_chance", 0))]
		elif got.is_empty():
			msg = "%s 完成，没有产出。" % j.get("name", "")
		if dur <= 0:
			msg += "（机器损坏，需要维修）"
		var fault := _roll_machine_fault(mid)
		if fault != "":
			machine_faults[mid] = fault
			msg += "（故障：%s）" % machine_fault_name(fault)
		emit_signal("machine_finished", msg)
	emit_signal("state_changed")

func save_game(slot: int = 1) -> bool:
	var data := {
		"version": 1, "day": day, "cash": cash, "rent": rent, "rent_due": rent_due,
		"loan": loan, "loan_due": loan_due, "rep": rep, "inventory": inventory,
		"display": display, "uid_counter": uid_counter, "pages_unlocked": max_pages_unlocked,
		"power": power, "machine_jobs": machine_jobs, "machine_modules": machine_modules, "machine_temps": machine_temps, "machine_durability": machine_durability, "machine_faults": machine_faults, "machine_recipes": machine_recipes,
		"machine_active": machine_active, "machine_stock": machine_stock, "machine_cash": machine_cash, "machine_upgrades": machine_upgrades, "machine_state": machine_state,
		"night_log": night_log, "next_day_power_bonus": next_day_power_bonus, "attraction_bonus": attraction_bonus, "security_alarm_active": security_alarm_active, "security_stop_rate": security_stop_rate,
		"owned_upgrades": owned_upgrades, "profession_id": profession_id, "profession_chosen": profession_chosen,
		"commissions": commissions, "story_seen": story_seen, "story_flags": story_flags,
		"scene_seen": scene_seen, "wanted_defeated": wanted_defeated, "ending_id": ending_id,
		"tutorial_done": tutorial_done, "tutorial_step": tutorial_step, "difficulty": difficulty, "campaign_mode": campaign_mode,
	}
	var f := FileAccess.open("user://save_%d.json" % slot, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	return true

func has_save(slot: int = 1) -> bool:
	return FileAccess.file_exists("user://save_%d.json" % slot)

func load_game(slot: int = 1) -> bool:
	if not has_save(slot):
		return false
	var f := FileAccess.open("user://save_%d.json" % slot, FileAccess.READ)
	if f == null:
		return false
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if not data is Dictionary:
		return false
	day = int(data.get("day", 1))
	cash = int(data.get("cash", 600))
	rent = int(data.get("rent", 200))
	rent_due = int(data.get("rent_due", 6))
	loan = int(data.get("loan", 200))
	loan_due = int(data.get("loan_due", 12))
	rep = data.get("rep", rep).duplicate(true)
	inventory = data.get("inventory", []).duplicate(true)
	display = data.get("display", []).duplicate(true)
	uid_counter = int(data.get("uid_counter", 1))
	pages_unlocked = int(data.get("pages_unlocked", 2))
	max_pages_unlocked = pages_unlocked
	for it in inventory:
		_normalize_item(it)
		max_pages_unlocked = max(max_pages_unlocked, int(it.get("page", 0)) + 1)
	for it in display:
		_normalize_item(it)
	pages_unlocked = clampi(max_pages_unlocked, 2, GRID_PAGES)
	max_pages_unlocked = pages_unlocked
	power = int(data.get("power", 10))
	owned_upgrades = data.get("owned_upgrades", {}).duplicate(true)
	profession_id = String(data.get("profession_id", ""))
	profession_chosen = bool(data.get("profession_chosen", false))
	commissions = data.get("commissions", []).duplicate(true)
	story_seen = data.get("story_seen", []).duplicate(true)
	story_flags = data.get("story_flags", {}).duplicate(true)
	scene_seen = data.get("scene_seen", []).duplicate(true)
	wanted_defeated = data.get("wanted_defeated", []).duplicate(true)
	tutorial_done = bool(data.get("tutorial_done", false))
	tutorial_step = int(data.get("tutorial_step", 0))
	difficulty = String(data.get("difficulty", "normal"))
	if not DIFFICULTY.has(difficulty):
		difficulty = "normal"
	campaign_mode = String(data.get("campaign_mode", "mobile"))
	if campaign_mode not in ["mobile", "original"]:
		campaign_mode = "mobile"
	ending_id = String(data.get("ending_id", ""))
	_refresh_upgrades()
	machine_modules = data.get("machine_modules", {}).duplicate(true)
	machine_temps = data.get("machine_temps", {}).duplicate(true)
	machine_durability = data.get("machine_durability", {}).duplicate(true)
	machine_faults = data.get("machine_faults", {}).duplicate(true)
	machine_recipes = data.get("machine_recipes", {}).duplicate(true)
	machine_active = data.get("machine_active", {}).duplicate(true)
	machine_stock = data.get("machine_stock", {}).duplicate(true)
	machine_cash = data.get("machine_cash", {}).duplicate(true)
	machine_upgrades = data.get("machine_upgrades", {}).duplicate(true)
	machine_state = data.get("machine_state", {}).duplicate(true)
	night_log = data.get("night_log", []).duplicate(true)
	next_day_power_bonus = int(data.get("next_day_power_bonus", 0))
	attraction_bonus = int(data.get("attraction_bonus", 100))
	security_alarm_active = bool(data.get("security_alarm_active", false))
	security_stop_rate = int(data.get("security_stop_rate", 0))
	machine_jobs = data.get("machine_jobs", []).duplicate(true)
	for j in machine_jobs:
		j["remaining"] = float(j.get("remaining", 0.0))
		j["total"] = float(j.get("total", 1.0))
	for mid in machine_stock.keys():
		for it in machine_stock[mid]:
			_normalize_item(it)
	pending_event = {}
	phase = "open"
	start_day()
	return true

func _normalize_item(it: Dictionary) -> void:
	it["uid"] = int(it.get("uid", 0))
	it["condition"] = int(it.get("condition", 100))
	it["x"] = int(it.get("x", -1))
	it["y"] = int(it.get("y", -1))
	it["page"] = int(it.get("page", 0))
	it["inspect_count"] = int(it.get("inspect_count", 0))
	it["authentic"] = bool(it.get("authentic", true))
	it["stolen"] = bool(it.get("stolen", false))
	it["known"] = bool(it.get("known", false))
	it["rotated"] = bool(it.get("rotated", false))
	if not it.has("clues") or not it["clues"] is Array:
		it["clues"] = []
	if not it.has("features") or not it["features"] is Array:
		it["features"] = []


