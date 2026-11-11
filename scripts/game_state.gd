extends Node

signal state_changed
signal customer_changed
signal day_finished(summary)
signal event_started(event)

const GRID_W := 16
const GRID_H := 3
const DISPLAY_SLOTS := 6

var items_def: Dictionary = {}
var tradable_pool: Array = []
var customer_defs: Array = []
var events: Array = []

var day := 1
var cash := 600
var rent := 200
var rent_due := 6
var loan := 200
var loan_due := 12
var rep := {"lower": 0, "security": 0, "blackmarket": 0, "upper": 0, "rev": 0}
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
	for id in items_def.keys():
		var d: Dictionary = items_def[id]
		if int(d.get("base_value", 0)) <= 0:
			continue
		if String(d.get("icon", "")) == "":
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
		"x": -1,
		"y": -1,
		"rotated": false,
		"location": "backpack",
	}

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

func can_place(item: Dictionary, x: int, y: int, rotated: bool, ignore_uid: int = -1) -> bool:
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
		for c in item_cells(other):
			if test.has(c):
				return false
	return true

func auto_place(item: Dictionary) -> bool:
	for y in range(GRID_H):
		for x in range(GRID_W):
			for rot in [false, true]:
				if can_place(item, x, y, rot):
					item["x"] = x
					item["y"] = y
					item["rotated"] = rot
					item["location"] = "backpack"
					return true
	return false

func add_item(item: Dictionary) -> bool:
	if auto_place(item):
		inventory.append(item)
		return true
	item["location"] = "overflow"
	inventory.append(item)
	return false

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

func move_item(uid: int, x: int, y: int) -> bool:
	var it := find_item(uid)
	if it.is_empty() or it.get("location") != "backpack":
		return false
	if can_place(it, x, y, it.get("rotated", false), uid):
		it["x"] = x
		it["y"] = y
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
		if not can_place(it, it["x"], it["y"], it["rotated"], uid):
			if not auto_place(it):
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
	rep = {"lower": 0, "security": 0, "blackmarket": 0, "upper": 0, "rev": 0}
	inventory = []
	display = []
	customers_today = []
	current_index = -1
	current_customer = {}
	counter_item = {}
	phase = "open"
	daily = {"sales": 0, "purchases": 0, "rent": 0, "fees": 0, "sold": 0, "bought": 0, "inspected": 0}
	uid_counter = 1
	pending_event = {}
	tutorial_done = false
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
	start_day()

func start_day() -> void:
	phase = "open"
	current_index = -1
	current_customer = {}
	counter_item = {}
	daily = {"sales": 0, "purchases": 0, "rent": 0, "fees": 0, "sold": 0, "bought": 0, "inspected": 0}
	customers_today = []
	var count := rng.randi_range(3, 5)
	for i in range(count):
		customers_today.append(_gen_customer())
	emit_signal("state_changed")
	next_customer()

func _gen_customer() -> Dictionary:
	var arche: Dictionary = customer_defs[rng.randi_range(0, customer_defs.size() - 1)].duplicate(true)
	var forced_tutorial := day == 1 and not tutorial_done and customers_today.is_empty()
	if forced_tutorial:
		arche = customer_defs[1].duplicate(true)
		tutorial_done = true
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
		var auth := true
		var stolen := false
		if def_id in ["cig_red", "cig_black"]:
			auth = rng.randf() < 0.55
		elif def_id in ["hand_gold", "aug_chip", "handmade_pistol", "revolver_short", "organ_heart", "organ_liver", "command_keycard"]:
			auth = rng.randf() < 0.65
			stolen = rng.randf() < 0.25
		var item := make_item(def_id, cond, auth, stolen)
		var val := effective_value(item)
		item["asking_price"] = int(round(val * rng.randf_range(1.15, 1.45)))
		item["min_price"] = int(round(val * rng.randf_range(0.7, 0.9)))
		c["item"] = item
		c["line"] = arche.get("greet", "") + "\n" + arche.get("ask", "")
	else:
		c["want_tags"] = arche.get("prefer_tags", [])
		c["budget"] = rng.randi_range(int(arche["budget"][0]), int(arche["budget"][1]))
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

func item_icon_path(def: Dictionary) -> String:
	var icon := String(def.get("icon", ""))
	if icon == "":
		return "res://assets/items/magnifier.png"
	var p := "res://assets_private/items/" + icon
	if ResourceLoader.exists(p):
		return p
	p = "res://assets/items/" + icon
	if ResourceLoader.exists(p):
		return p
	return "res://assets/items/magnifier.png"

func effective_value(item: Dictionary) -> int:
	if item.is_empty():
		return 0
	var def := get_item_def(item.get("def_id", ""))
	var base := float(def.get("base_value", 10))
	var cond := clampf(float(item.get("condition", 100)) / 100.0, 0.2, 1.0)
	var auth := 1.0 if item.get("authentic", true) else 0.35
	var stolen := 0.9 if item.get("stolen", false) else 1.0
	return int(round(base * cond * auth * stolen))

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
	var val := effective_value(it)
	var arche: Dictionary = current_customer["arche"]
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
	emit_signal("state_changed")
	return true

func take_from_display(uid: int) -> void:
	for i in range(display.size()):
		if int(display[i]["uid"]) == uid:
			var it: Dictionary = display[i]
			display.remove_at(i)
			it["location"] = "backpack"
			add_item(it)
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
	return "%s，品相 %d%%%s，估值 %d₵" % [auth, cond, stolen, effective_value(it)]

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
		return {"accepted": true, "text": "成交。你花 %d₵ 收下了 %s。" % [price, get_item_def(item["def_id"]).get("name", "")]}
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
	rep[faction] = clampi(int(rep[faction]) + amount, -100, 100)

func finish_day() -> Dictionary:
	rent_due -= 1
	loan_due -= 1
	var summary := {
		"day": day, "sales": daily["sales"], "purchases": daily["purchases"],
		"fees": daily["fees"], "rent_paid": 0, "loan_paid": 0,
		"rent": rent, "rent_due": rent_due, "loan_due": loan_due, "cash": cash, "gameover": ""
	}
	if rent_due <= 0:
		if cash >= rent:
			cash -= rent
			summary["rent_paid"] = rent
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
			summary["gameover"] = "loan"
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
	pending_event = {}
	if cash < 0:
		phase = "gameover"
	emit_signal("state_changed")

func save_game() -> bool:
	var data := {
		"version": 1, "day": day, "cash": cash, "rent": rent, "rent_due": rent_due,
		"loan": loan, "loan_due": loan_due, "rep": rep, "inventory": inventory,
		"display": display, "uid_counter": uid_counter,
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
	for it in inventory:
		_normalize_item(it)
	for it in display:
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
	it["inspect_count"] = int(it.get("inspect_count", 0))
	it["authentic"] = bool(it.get("authentic", true))
	it["stolen"] = bool(it.get("stolen", false))
	it["known"] = bool(it.get("known", false))
	it["rotated"] = bool(it.get("rotated", false))
	if not it.has("clues") or not it["clues"] is Array:
		it["clues"] = []


