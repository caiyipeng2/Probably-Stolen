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

func _load_defs() -> void:
	var f := FileAccess.open("res://data/items.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			for d in data:
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
				norm["name"] = String(p.get("name", id))
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

func new_game() -> void:
	day = 1
	cash = 600
	rent = 200
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
	for stock in [["scrap_metal", 3], ["printer_plastic", 3], ["common_chemical", 2], ["restricted_chemical", 1], ["nutrifruit_seed", 2], ["industrial_fish_feed", 2], ["water_jug", 1], ["meat_scrap", 2], ["nutrient_tablet", 1], ["red_beer", 2], ["plastic_bag", 2], ["debris_pile1", 2], ["printer_module_metal", 1], ["organ_heart", 1], ["water_tablet", 1], ["small_raw_meat", 2], ["nutrifruit", 1]]:
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
	start_day()

func start_day() -> void:
	power = max_power
	phase = "open"
	current_index = -1
	current_customer = {}
	counter_item = {}
	daily = {"sales": 0, "purchases": 0, "rent": 0, "fees": 0, "sold": 0, "bought": 0, "inspected": 0}
	customers_today = []
	_gen_commissions()
	var count := rng.randi_range(3, 5)
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
		var bmult := 1.0 + float(upgrade_total("budget")) / 100.0
		c["budget"] = int(round(float(rng.randi_range(int(arche["budget"][0]), int(arche["budget"][1]))) * bmult))
		c["offer"] = 0
		c["max_price"] = 0
		c["line"] = arche.get("greet", "")
	return c

func next_customer() -> void:
	if phase == "gameover":
		return
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
	var pm := float(arche.get("price_mod", 1.0))
	current_customer["offer"] = int(round(val * factor * pm * rng.randf_range(0.75, 0.95)))
	current_customer["max_price"] = int(min(float(current_customer["budget"]), val * factor * pm * 1.05))
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
	if price >= int(item.get("min_price", 0)):
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
		item["asking_price"] = int(item["min_price"])
		emit_signal("state_changed")
		return {"accepted": false, "counter": int(item["min_price"]), "text": "顾客摇头：最低 %d₵，不能再少了。" % int(item["min_price"])}
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

func _queue_story_for_day() -> void:
	pending_story = ""
	story_queue.clear()
	for nid in _queue_story_scenes():
		story_queue.append(nid)
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
		var sday := int(scene.get("day", 0))
		if sday == 0:
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
		var nid := "sc_%s_0" % sid
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
	max_power = 10 + upgrade_total("power")
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

func start_machine(machine_id: String, quality: float = 0.0, dry_run: bool = false) -> Dictionary:
	var m := machine_def(machine_id)
	if m.is_empty():
		return {"ok": false, "text": "没有这台机器。"}
	for j in machine_jobs:
		if String(j.get("machine_id", "")) == machine_id:
			return {"ok": false, "text": "%s 正在运行。" % m.get("name", machine_id)}
	if int(machine_durability.get(machine_id, 100)) <= 0:
		return {"ok": false, "text": "%s 已损坏，请先维修。" % m.get("name", machine_id)}
	var lvl := int(machine_temps.get(machine_id, 2))
	var temp_time: float = [1.2, 1.0, 0.8][clampi(lvl, 1, 3) - 1]
	var temp_power: float = [1.0, 1.0, 1.5][clampi(lvl, 1, 3) - 1]
	var use_time: float = float(m.get("time", 1.0)) * temp_time
	var use_power := maxi(1, int(round(float(m.get("power", 0)) * temp_power)))
	if machine_modules.has(machine_id):
		use_time *= 0.8
		use_power = maxi(1, use_power - 1)
	use_time *= 1.0 - minf(50.0, float(upgrade_total("machine"))) / 100.0
	use_time *= 1.0 - clampf(quality, 0.0, 1.0) * 0.2
	if power < use_power:
		return {"ok": false, "text": "电力不足：需要 %d，当前 %d。" % [use_power, power]}
	for inp in m.get("inputs", []):
		if inventory_count(String(inp.get("id", ""))) < int(inp.get("count", 1)):
			var d := get_item_def(String(inp.get("id", "")))
			return {"ok": false, "text": "缺少原料：%s x%d。" % [d.get("name", inp.get("id", "")), int(inp.get("count", 1))]}
	if dry_run:
		return {"ok": true, "text": "%s 可以启动。" % String(m.get("name", machine_id))}
	for inp in m.get("inputs", []):
		remove_inventory(String(inp.get("id", "")), int(inp.get("count", 1)))
	power -= use_power
	var job := {"machine_id": machine_id, "name": String(m.get("name", machine_id)), "remaining": use_time, "total": use_time, "outputs": m.get("outputs", []).duplicate(true)}
	machine_jobs.append(job)
	emit_signal("state_changed")
	return {"ok": true, "text": "%s 已启动，预计 %.1f 秒。" % [job["name"], job["remaining"]]}

func install_module(machine_id: String) -> Dictionary:
	if machine_modules.has(machine_id):
		return {"ok": false, "text": "这台机器已经安装了模块。"}
	var idx := -1
	for i in range(inventory.size()):
		var d := get_item_def(inventory[i].get("def_id", ""))
		if String(d.get("category", "")) == "module":
			idx = i
			break
	if idx < 0:
		return {"ok": false, "text": "背包里没有可安装的模块。"}
	var mod: Dictionary = inventory[idx]
	inventory.remove_at(idx)
	machine_modules[machine_id] = String(mod.get("def_id", ""))
	_refresh_pages()
	emit_signal("state_changed")
	return {"ok": true, "text": "已安装模块：%s（耗时 -20%%，电力 -1）。" % get_item_def(mod.get("def_id", "")).get("name", "")}

func set_machine_temp(machine_id: String, level: int) -> void:
	machine_temps[machine_id] = clampi(level, 1, 3)
	emit_signal("state_changed")

func machine_repair_cost(machine_id: String) -> int:
	var m := machine_def(machine_id)
	return 60 + int(m.get("power", 2)) * 20

func repair_machine(machine_id: String) -> Dictionary:
	var m := machine_def(machine_id)
	if m.is_empty():
		return {"ok": false, "text": "没有这台机器。"}
	if int(machine_durability.get(machine_id, 100)) >= 100:
		return {"ok": false, "text": "%s 状态良好，不需要维修。" % m.get("name", machine_id)}
	var cost := machine_repair_cost(machine_id)
	if cash < cost:
		return {"ok": false, "text": "维修需要 %d₵，现金不足。" % cost}
	cash -= cost
	machine_durability[machine_id] = 100
	emit_signal("state_changed")
	return {"ok": true, "text": "%s 已维修，花费 %d₵。" % [m.get("name", machine_id), cost]}

func _process(delta: float) -> void:
	if machine_jobs.is_empty():
		return
	var finished: Array = []
	var k := 0
	while k < machine_jobs.size():
		var j: Dictionary = machine_jobs[k]
		j["remaining"] = float(j.get("remaining", 0.0)) - delta
		if float(j["remaining"]) <= 0.0:
			finished.append(j)
			machine_jobs.remove_at(k)
		else:
			k += 1
	for j in finished:
		var got: Array = []
		for out in j.get("outputs", []):
			var oid := String(out.get("id", ""))
			if not items_def.has(oid):
				continue
			for n in range(int(out.get("count", 1))):
				add_item(make_item(oid, 100, true, false))
				got.append(String(get_item_def(oid).get("name", oid)))
		var mid := String(j.get("machine_id", ""))
		var wear: int = [1, 2, 3][clampi(int(machine_temps.get(mid, 2)), 1, 3) - 1] + rng.randi_range(0, 1)
		var dur := maxi(0, int(machine_durability.get(mid, 100)) - wear)
		machine_durability[mid] = dur
		var msg := "%s 完成：+%s" % [j.get("name", ""), "、".join(got)]
		if dur <= 0:
			msg += "（机器损坏，需要维修）"
		emit_signal("machine_finished", msg)
	emit_signal("state_changed")

func save_game() -> bool:
	var data := {
		"version": 1, "day": day, "cash": cash, "rent": rent, "rent_due": rent_due,
		"loan": loan, "loan_due": loan_due, "rep": rep, "inventory": inventory,
		"display": display, "uid_counter": uid_counter, "pages_unlocked": max_pages_unlocked,
		"power": power, "machine_jobs": machine_jobs, "machine_modules": machine_modules, "machine_temps": machine_temps, "machine_durability": machine_durability,
		"owned_upgrades": owned_upgrades, "profession_id": profession_id, "profession_chosen": profession_chosen,
		"commissions": commissions, "story_seen": story_seen, "story_flags": story_flags,
		"scene_seen": scene_seen, "wanted_defeated": wanted_defeated, "ending_id": ending_id,
		"tutorial_done": tutorial_done, "tutorial_step": tutorial_step,
	}
	var f := FileAccess.open("user://save_1.json", FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	return true

func has_save() -> bool:
	return FileAccess.file_exists("user://save_1.json")

func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open("user://save_1.json", FileAccess.READ)
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
	ending_id = String(data.get("ending_id", ""))
	_refresh_upgrades()
	machine_modules = data.get("machine_modules", {}).duplicate(true)
	machine_temps = data.get("machine_temps", {}).duplicate(true)
	machine_durability = data.get("machine_durability", {}).duplicate(true)
	machine_jobs = data.get("machine_jobs", []).duplicate(true)
	for j in machine_jobs:
		j["remaining"] = float(j.get("remaining", 0.0))
		j["total"] = float(j.get("total", 1.0))
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


