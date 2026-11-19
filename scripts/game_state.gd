extends Node

signal state_changed
signal customer_changed
signal day_finished(summary)
signal event_started(event)
signal machine_finished(message)
signal story_available(node_id)
signal combat_hit(target_uid, amount)
signal inspection_arrived
signal security_officer_arrived
signal permit_revoke_arrived
signal achievement_unlocked(aid)
signal news_ready(title, text)
signal combat_started
signal combat_updated
signal combat_finished(victory, message)

const GRID_W := 18
const GRID_H := 4
const GRID_PAGES := 3
const DISPLAY_SLOTS := 6
const HIDDEN_W := 2
const HIDDEN_H := 2
const SHOWCASE_W := 7
const SHOWCASE_H := 5
var poster_pulled := false
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
	"cozy": {"name": "舒适", "cash": 600, "rent": 200, "budget": 1.1, "damage": 0.85},
	"normal": {"name": "普通", "cash": 600, "rent": 200, "budget": 1.0, "damage": 1.0},
	"hard": {"name": "困难", "cash": 600, "rent": 200, "budget": 0.9, "damage": 1.25},
	"challenge": {"name": "赤字", "cash": 600, "rent": 200, "budget": 0.85, "damage": 1.5},
}

var items_def: Dictionary = {}
var tradable_pool: Array = []
var pages_unlocked := 2
var max_pages_unlocked := 2
var customer_defs: Array = []
var client_pools: Dictionary = {}
var client_cooldowns: Dictionary = {}
var client_sprite_pools: Dictionary = {}
var store_request_defs: Dictionary = {}
var store_requests: Array = []
var store_request_seen: Array = []
var marketplace_unlocked_day := -1
var auto_customer_flow := true
var faction_ops: Array = []
var afterhour_defs: Array = []
var faction_power: Dictionary = {"rev": 0, "bm": 0, "sec": 0, "civil_unrest": 0}
var operation_cooldowns: Dictionary = {}
var active_operations: Array = []
var afterhour_mods: Dictionary = {}
var afterhour_today := ""
var space_mode := false
var space_ships: Array = []
var space_pois: Array = []
var space_ship: Dictionary = {}
var space_fuel := 0
var space_hull := 0
var space_max_hull := 100
var space_day := 1
var space_poi: Dictionary = {}
var space_scanned: Array = []
var space_log: Array = []
var space_at_station := false
var space_raid_rooms: Array = []
var space_raid_index := 0
var space_pending_reward: Dictionary = {}
var store_water_ml := 20000
var next_combat_accuracy_bonus := 0
var combat_buff_accuracy := 0
var events: Array = []
var machines: Array = []
var factions: Array = []
var upgrades: Array = []
var owned_upgrades: Dictionary = {}
var professions: Array = []
var profession_id := ""
var profession_chosen := false
var start_type_id := ""
var starting_perk_ids: Array = []
var starting_perk_meta: Dictionary = {}
var run_count := 0
var player_max_hp := 100
var player_accuracy := 70
var player_reaction := 10
var thirst := 1000
var thirst_max := 1000
var wounds := 0
var wound_stable := true
var addiction_days := {"nicotine": 0, "alcohol": 0, "narcotic": 0}
var narcotic_relief := 999
var sentinel_days := 0
var sentinel_pool := 0
var luck := 0
var perk_flags: Dictionary = {}
var achievements_unlocked: Dictionary = {}
var achievement_defs: Array = []
var ach_stats: Dictionary = {}
var run_stats: Dictionary = {}
var aug_presence := 0
var aug_introduced := false
var aug_next_spawn_day := 0
var hireling: Dictionary = {}
var hireling_expedition: Dictionary = {}
var gun_order: Dictionary = {}
var gun_mod_defs: Dictionary = {}
var combat_mag_rounds := 0
var combat_mag_size := 0
var combat_ammo_id := ""
var combat_gun_stats: Dictionary = {}
var combat_is_gun := false
var gun_defs: Dictionary = {}
var gun_order_defs: Dictionary = {}
var commissions: Array = []
var procurement_defs: Dictionary = {}
var special_customers: Dictionary = {}
var difficulty_rules: Dictionary = {}
var starting_perks: Array = []
var rep_perk_defs: Array = []
var starting_perk_id := ""
var starting_perk_chosen := false
var procurement_orders: Array = []
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
var combat_player_hp := 100
var combat_player_max := 100
var combat_log: Array = []
var combat_skill_cd := 0
var combat_guarding := false
var combat_wanted_id := ""
var combat_context := ""
var combat_abilities: Dictionary = {}
var combat_weapon_map: Dictionary = {}
var combat_units: Array = []
var combat_turn_order: Array = []
var combat_turn_pos := 0
var combat_round := 1
var combat_current_uid := -1
var combat_player_uid := 0
var combat_uid_seq := 1
var combat_player_weapon := ""
var combat_player_weapon_uid := -1
var combat_player_items: Array = []
var combat_target_uid := -1
var combat_ended := false
var combat_pending_victory := false
var combat_armor_defs: Dictionary = {}
var combat_parties: Dictionary = {}
var expedition_rooms: Array = []
var expedition_room_index := 0
var raid_action_points := 100
var raid_turn := 1
var expedition_loot_log: Array = []
var combat_allies: Array = []
var market_modifiers: Dictionary = {"FOOD": 0, "MEDICAL": 0, "SUBSTANCE": 0, "MATERIAL": 0, "WEAPON": 0, "ARMOR": 0, "WATER": 0}
var market_customers: Dictionary = {}
var equipped_armor_uid := -1
var security_defs: Dictionary = {}
var locale_text: Dictionary = {}
var sec_crimes: Dictionary = {}
var sec_evidence := 0
var sec_state := 0
var sec_officer_pending := false
var sec_inspection_pending := false
var sec_inspection_personality := 0
var sec_inspection_fake := false
var sec_last_inspection_day := -99
var sec_bribe_tracker := 0
var sec_inspection_countdown := 6
var sec_permit_revoke_pending := false
var sec_permit_revoke_levels: Array = []
var active_permits: Array = []
var trash_items: Array = []
var upgrade_cooldowns: Dictionary = {}
var evidence_removal_purchases := 0
var _suppress_sec_tick := false
var ending_id := ""
var property_owned := false
var is_paying_mortgage := false
var mortgage_week_left := 0
var mortgage_total_weeks := 0
var mortgage_weekly_payment := 0
var mortgage_down_paid := 0
var mortgage_interest_taken := 0
var mortgage_offer_declined := false
var property_bought_at := 0
var property_bought_day := 0
var mortgage_due := 0
var machine_jobs: Array = []
var power := 10
var max_power := 10
var machine_modules: Dictionary = {}
var machine_temps: Dictionary = {}
var machine_durability: Dictionary = {}
var machine_faults: Dictionary = {}
var machine_recipes: Dictionary = {}
var modules_def: Array = []
var containers_def: Dictionary = {}
var machine_container_items: Dictionary = {}
var machine_io: Dictionary = {}
var loot_tables: Dictionary = {}
var barter_offer_defs: Dictionary = {}
var dialogue_lines: Dictionary = {}
var phone_contacts: Dictionary = {}
var phone_clients: Dictionary = {}
var future_customers: Array = []
var commissary_defs: Array = []
var commissary_stock: Dictionary = {}
var commissary_credit := 0
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
var inspection_families: Dictionary = {}
var appraisal_ranks: Array = []
var appraisal_item_defs: Array = []
var feature_rules: Dictionary = {}
var inspection_text: Dictionary = {}
var appraiser_level := 0
var appraisal_progress := 0.0
var appraisal_promotion_day := -1
var appraisal_promotion_declined := false
var appraisal_days_missed := 0
var appraisal_blacklist: Array = []
var appraisal_introduced := false
var pending_promotion := false
var secret_admirer_days := 0
var charity_cooldown := 0
var discerning_cooldown := 0
var cartel_exit_available := false
var cartel_exit_uses := 0
var cartel_exited := false
var blackmail_next_day := 1
var afterhours_visits_left := 0
var afterhours_went_out := false
var went_out_last_night := false
var last_afterhour_outing_day := -1
var scav_attempts_used := 0
var afterhours_location := ""
var jackson_stock: Array = []
var satchel_found := false
var kids_backpack_found := false
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

func _is_headless() -> bool:
	return DisplayServer.get_name() == "headless"

func _ready() -> void:
	rng.randomize()
	auto_customer_flow = _is_headless()
	_load_defs()
	_load_run_meta()
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
	var perk_file := FileAccess.open("res://data_private/starting_perks.json", FileAccess.READ)
	if perk_file:
		var pkdata = JSON.parse_string(perk_file.get_as_text())
		if pkdata is Array:
			starting_perks = pkdata
	var gun_file := FileAccess.open("res://data/gun_stats.json", FileAccess.READ)
	if gun_file:
		var gdata = JSON.parse_string(gun_file.get_as_text())
		if gdata is Dictionary:
			gun_defs = gdata
	var gm_file := FileAccess.open("res://data/gun_mods.json", FileAccess.READ)
	if gm_file:
		var gmdata = JSON.parse_string(gm_file.get_as_text())
		if gmdata is Dictionary:
			gun_mod_defs = gmdata
	var go_file := FileAccess.open("res://data/gun_orders.json", FileAccess.READ)
	if go_file:
		var godata = JSON.parse_string(go_file.get_as_text())
		if godata is Dictionary:
			gun_order_defs = godata
	_load_client_sprite_pools()
	var fo_file := FileAccess.open("res://data/faction_ops.json", FileAccess.READ)
	if fo_file:
		var fodata = JSON.parse_string(fo_file.get_as_text())
		if fodata is Array:
			faction_ops = fodata
	var ah_file := FileAccess.open("res://data/afterhour_events.json", FileAccess.READ)
	if ah_file:
		var ahdata = JSON.parse_string(ah_file.get_as_text())
		if ahdata is Array:
			afterhour_defs = ahdata
	var sh_file := FileAccess.open("res://data/space_ships.json", FileAccess.READ)
	if sh_file:
		var shdata = JSON.parse_string(sh_file.get_as_text())
		if shdata is Array:
			space_ships = shdata
	var sp_file := FileAccess.open("res://data/space_pois.json", FileAccess.READ)
	if sp_file:
		var spdata = JSON.parse_string(sp_file.get_as_text())
		if spdata is Array:
			space_pois = spdata
	var sr_file := FileAccess.open("res://data/store_requests.json", FileAccess.READ)
	if sr_file:
		var srdata = JSON.parse_string(sr_file.get_as_text())
		if srdata is Dictionary:
			store_request_defs = srdata
	var ach_file := FileAccess.open("res://data/achievements.json", FileAccess.READ)
	if ach_file:
		var adata = JSON.parse_string(ach_file.get_as_text())
		if adata is Array:
			achievement_defs = adata
	var meta_file := FileAccess.open("res://data/starting_perks_meta.json", FileAccess.READ)
	if meta_file:
		var mdata = JSON.parse_string(meta_file.get_as_text())
		if mdata is Array:
			for m in mdata:
				starting_perk_meta[String(m.get("id", ""))] = m
	var rep_file := FileAccess.open("res://data_private/reputation_perks.json", FileAccess.READ)
	if rep_file:
		var rpdata = JSON.parse_string(rep_file.get_as_text())
		if rpdata is Array:
			rep_perk_defs = rpdata
	f = FileAccess.open("res://data/market_customers.json", FileAccess.READ)
	if f:
		var mcdata = JSON.parse_string(f.get_as_text())
		if mcdata is Dictionary:
			market_customers = mcdata
	f = FileAccess.open("res://data/difficulty_rules.json", FileAccess.READ)
	if f:
		var drdata = JSON.parse_string(f.get_as_text())
		if drdata is Dictionary:
			difficulty_rules = drdata
	f = FileAccess.open("res://data/special_customers.json", FileAccess.READ)
	if f:
		var spdata = JSON.parse_string(f.get_as_text())
		if spdata is Dictionary:
			special_customers = spdata
	f = FileAccess.open("res://data/procurements.json", FileAccess.READ)
	if f:
		var prdata = JSON.parse_string(f.get_as_text())
		if prdata is Dictionary:
			procurement_defs = prdata
	f = FileAccess.open("res://data/client_pools.json", FileAccess.READ)
	if f:
		var pdata = JSON.parse_string(f.get_as_text())
		if pdata is Dictionary:
			client_pools = pdata
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
	f = FileAccess.open("res://data/containers.json", FileAccess.READ)
	if f:
		var cdefs = JSON.parse_string(f.get_as_text())
		if cdefs is Dictionary:
			containers_def = cdefs
	f = FileAccess.open("res://data/loot_crates.json", FileAccess.READ)
	if f:
		var ldefs = JSON.parse_string(f.get_as_text())
		if ldefs is Dictionary:
			loot_tables = ldefs
	f = FileAccess.open("res://data/inspection_families.json", FileAccess.READ)
	if f:
		var fams = JSON.parse_string(f.get_as_text())
		if fams is Dictionary:
			inspection_families = fams.get("families", {})
	f = FileAccess.open("res://data/appraisal_ranks.json", FileAccess.READ)
	if f:
		var ranks = JSON.parse_string(f.get_as_text())
		if ranks is Array:
			appraisal_ranks = ranks
	f = FileAccess.open("res://data/appraisal_items.json", FileAccess.READ)
	if f:
		var aitems = JSON.parse_string(f.get_as_text())
		if aitems is Array:
			appraisal_item_defs = aitems
	f = FileAccess.open("res://data/feature_rules.json", FileAccess.READ)
	if f:
		var frules = JSON.parse_string(f.get_as_text())
		if frules is Dictionary:
			feature_rules = frules
	var itext := FileAccess.open("res://data_private/inspection_text_zh.json", FileAccess.READ)
	if itext:
		var td = JSON.parse_string(itext.get_as_text())
		if td is Dictionary:
			inspection_text = td
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
			dialogue_lines = {}
			for g in dialogue_archive:
				for e in g.get("entries", []):
					dialogue_lines[String(e.get("key", ""))] = String(e.get("text", ""))
	f = FileAccess.open("res://data/barter_offers.json", FileAccess.READ)
	if f:
		var bdata = JSON.parse_string(f.get_as_text())
		if bdata is Dictionary:
			barter_offer_defs = bdata.get("clients", {})
	f = FileAccess.open("res://data/phone_contacts.json", FileAccess.READ)
	if f:
		var pdata = JSON.parse_string(f.get_as_text())
		if pdata is Dictionary:
			phone_contacts = pdata.get("contacts", {})
	f = FileAccess.open("res://data_private/phone_dialogue_zh.json", FileAccess.READ)
	if f:
		var pd = JSON.parse_string(f.get_as_text())
		if pd is Dictionary:
			for k in pd.keys():
				dialogue_lines[String(k)] = String(pd[k])
	f = FileAccess.open("res://data/commissary.json", FileAccess.READ)
	if f:
		var cdata = JSON.parse_string(f.get_as_text())
		if cdata is Dictionary:
			commissary_defs = cdata.get("items", [])
	f = FileAccess.open("res://data/combat_parties.json", FileAccess.READ)
	if f:
		var pdata = JSON.parse_string(f.get_as_text())
		if pdata is Dictionary:
			combat_parties = pdata.get("parties", {})
	f = FileAccess.open("res://data/combat.json", FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if data is Array:
			combat_data = data
	f = FileAccess.open("res://data/combat_abilities.json", FileAccess.READ)
	if f:
		var abdata = JSON.parse_string(f.get_as_text())
		if abdata is Dictionary:
			combat_abilities = abdata.get("abilities", {})
			combat_weapon_map = abdata.get("weapon_map", {})
			combat_armor_defs = abdata.get("armor", {})
	f = FileAccess.open("res://data/security.json", FileAccess.READ)
	if f:
		var sdata = JSON.parse_string(f.get_as_text())
		if sdata is Dictionary:
			security_defs = sdata
	f = FileAccess.open("res://data_private/locale_zh.json", FileAccess.READ)
	if f:
		var ldata = JSON.parse_string(f.get_as_text())
		if ldata is Dictionary:
			locale_text = ldata
	f = FileAccess.open("res://data_private/security_text_zh.json", FileAccess.READ)
	if f:
		var stext = JSON.parse_string(f.get_as_text())
		if stext is Dictionary:
			for k in stext.keys():
				dialogue_lines[String(k)] = String(stext[k])
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
	var it := {
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
		"children": [],
		"unit_count": 1,
	}
	_init_inspection_item(it)
	_init_container_state(it)
	if bool(it.get("stolen", false)):
		var heat := _stolen_heat_for_value(int(def.get("base_value", 0)))
		if heat <= 0:
			it["stolen"] = false
		else:
			it["stolen_heat"] = heat
	return it

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

func inspection_label(key: String, fallback: String) -> String:
	return String(inspection_text.get(key, fallback))

func _family_for(def_id: String, def: Dictionary) -> String:
	var tags: Array = def.get("tags", [])
	if def_id in ["hand_steel", "hand_carbon", "hand_gold"]:
		return "hand"
	if def_id == "ribwich":
		return "ribwich"
	if def_id == "plasma_fuel":
		return "plasma"
	if def_id in ["cig_red", "cig_black"] or "cigarette" in def_id:
		return "cigarette"
	if def_id == "food_stamp" or "stamp" in def_id:
		return "stamp"
	if "injector" in def_id:
		return "injector"
	if def_id == "wine_berry":
		return "berry"
	if is_water_container_item(def_id):
		return "water"
	if tags.has("CHEM_ITEM_TAG") or tags.has("CHEMICAL_PRODUCT_TAG") or String(def.get("category", "")) == "chem":
		return "chem"
	if def_id == "metal_ingot":
		return "ingot"
	if String(def.get("category", "")) in ["weapon", "weapon_mod", "cyber"]:
		return "equipment"
	if tags.has("MODULE_TAG") or String(def.get("category", "")) == "module":
		return "module"
	if String(def.get("category", "")) == "plant" or tags.has("SEED"):
		return "plant"
	if String(def.get("category", "")) in ["food", "animal", "organ", "medical"]:
		return "food"
	return "generic"

func _add_feature(it: Dictionary, rule_id: String, discovered: bool = false) -> Dictionary:
	var rule: Dictionary = feature_rules.get(rule_id, {})
	if rule.is_empty():
		return {}
	var f := {
		"id": rule_id, "category": String(rule.get("category", "")),
		"label": String(rule.get("label", rule_id)),
		"tool": String(rule.get("tool", "magnifier")),
		"public_label": String(rule.get("public_label", "")),
		"real_label": String(rule.get("real_label", "")),
		"public_mod": int(rule.get("public_mod", 0)),
		"real_mod": int(rule.get("real_mod", 0)),
		"stage": "innate", "discovered": discovered, "exposed": false,
	}
	it["feature_list"].append(f)
	return f

func _add_custom_feature(it: Dictionary, id: String, category: String, label: String, public_label: String, real_label: String, public_mod: int, real_mod: int, stage: String = "innate") -> Dictionary:
	var f := {
		"id": id, "category": category, "label": label, "tool": "",
		"public_label": public_label, "real_label": real_label,
		"public_mod": public_mod, "real_mod": real_mod,
		"stage": stage, "discovered": false, "exposed": false,
	}
	it["feature_list"].append(f)
	return f

func _init_inspection_item(it: Dictionary) -> void:
	var def := get_item_def(String(it.get("def_id", "")))
	var family := _family_for(String(it.get("def_id", "")), def)
	it["family"] = family
	it["attrs"] = {}
	it["issues"] = []
	it["feature_list"] = []
	it["inspect_notes"] = []
	it["family_seen"] = false
	it["confronted"] = false
	if family == "cigarette":
		_init_cigarette(it)
	elif family == "stamp":
		_init_stamp(it)
	elif family == "injector":
		_init_injector(it)
	elif family == "hand":
		_init_hand(it)
	elif family == "ribwich":
		_init_ribwich(it)
	elif family == "plasma":
		_init_plasma(it)
	elif family == "berry":
		_init_berry(it)
	elif family == "water":
		var pur := int(it.get("condition", 100))
		if pur < 25:
			_add_feature(it, "water_gutter")
		elif pur < 50:
			_add_feature(it, "water_rust")
		elif pur < 65:
			_add_feature(it, "water_ghost")
	elif family == "chem":
		var cnd := int(it.get("condition", 100))
		if cnd < 25:
			_add_feature(it, "chem_starch")
		elif cnd < 45:
			_add_feature(it, "chem_junk")
		elif cnd < 65:
			_add_feature(it, "chem_cut")
	elif family == "equipment":
		if not bool(it.get("authentic", true)):
			_add_feature(it, "replica")
		if int(it.get("condition", 100)) < 50:
			_add_feature(it, "equipment_poor")
		elif int(it.get("condition", 100)) < 75:
			_add_feature(it, "equipment_fair")
	elif family == "food":
		var fc := int(it.get("condition", 100))
		if fc < 35:
			_add_feature(it, "expired")
			_add_feature(it, "freshness_spoiled")
		elif fc < 60:
			_add_feature(it, "freshness_stale")
		if rng.randf() < 0.15:
			_add_feature(it, "dented")
		if rng.randf() < 0.1:
			_add_feature(it, "open_box")
	elif family == "module":
		if not bool(it.get("authentic", true)):
			_add_feature(it, "module_stuck")
	elif family == "ingot":
		if int(it.get("condition", 100)) < 25:
			_add_feature(it, "ingot_very_low")
		elif int(it.get("condition", 100)) < 50:
			_add_feature(it, "ingot_low")
	else:
		var roll := rng.randf()
		if roll < 0.1:
			_add_feature(it, "rusted")
		elif roll < 0.2:
			_add_feature(it, "dented")
		elif roll < 0.27:
			_add_feature(it, "open_box")
		elif roll < 0.32:
			_add_feature(it, "replica")

func _attr_label(family: String, key: String, value) -> String:
	var fam: Dictionary = inspection_families.get(family, {})
	var key_text := str(value)
	if value is float and float(value) == float(int(value)):
		key_text = str(int(value))
	for a in fam.get("attributes", []):
		if String(a.get("key", "")) == key:
			var opts: Dictionary = a.get("options", {})
			if opts.has(key_text):
				return String(opts[key_text])
			if key == "production":
				return key_text
			return key_text
	return key_text

func _init_cigarette(it: Dictionary) -> void:
	var attrs := {"lettering": 0, "logo": 0, "seal": 0, "box": 0, "color": 0}
	if not bool(it.get("authentic", true)):
		var pick := rng.randi_range(0, 4)
		match pick:
			0:
				attrs["seal"] = -1 if rng.randf() < 0.5 else 1
				it["issues"].append("CIGARETTE_SEAL_ISSUE")
			1:
				attrs["logo"] = -1 if rng.randf() < 0.2 else rng.randi_range(1, 4)
				it["issues"].append("CIGARETTE_LOGO_ISSUE")
			2:
				attrs["lettering"] = -1 if rng.randf() < 0.2 else rng.randi_range(1, 7)
				it["issues"].append("CIGARETTE_LETTERING_ISSUE")
			3:
				attrs["color"] = rng.randi_range(1, 4)
				it["issues"].append("CIGARETTE_COLOR_ISSUE")
			4:
				attrs["box"] = rng.randi_range(1, 4)
				it["issues"].append("CIGARETTE_BOX_ISSUE")
	it["attrs"] = attrs

func _init_stamp(it: Dictionary) -> void:
	var amounts := [40, 80, 120, 160, 200, 240]
	var amount := int(amounts[rng.randi_range(0, amounts.size() - 1)])
	var attrs := {"logo": 0, "chip": 0, "lettering": 0, "amount": amount, "seal": 0 if amount >= 160 else -1}
	if not bool(it.get("authentic", true)):
		var pick := rng.randi_range(0, 4)
		match pick:
			0:
				attrs["logo"] = -1 if rng.randf() < 0.2 else rng.randi_range(1, 5)
				it["issues"].append("STAMP_LOGO_ISSUE")
			1:
				attrs["chip"] = -1 if rng.randf() < 0.25 else rng.randi_range(1, 3)
				it["issues"].append("STAMP_CHIP_ISSUE")
			2:
				attrs["lettering"] = -1 if rng.randf() < 0.15 else rng.randi_range(1, 8)
				it["issues"].append("STAMP_LETTERING_ISSUE")
			3:
				attrs["amount"] = amount + 10
				it["issues"].append("STAMP_AMOUNT_ISSUE")
			4:
				attrs["seal"] = -1 if attrs["seal"] == 0 else 0
				it["issues"].append("STAMP_SEAL_ISSUE")
	it["attrs"] = attrs
	it["custom_base_value"] = int(round(float(attrs["amount"]) * 0.75))
	it["custom_name"] = "食品券（%d 代用点）" % int(attrs["amount"])

func _init_injector(it: Dictionary) -> void:
	var attrs := {
		"indicator": 0, "label": 0, "color": 0, "body": 0,
		"serial": _injector_correct_serial(), "company": "Carmicheal Pharmaceutical", "model": "Immunivax",
	}
	if not bool(it.get("authentic", true)):
		var pick := rng.randi_range(0, 4)
		match pick:
			0:
				attrs["serial"] = _injector_bad_serial()
				it["issues"].append("ISSUE_SERIAL")
			1:
				attrs["color"] = 1
				attrs["body"] = -1
				it["issues"].append("ISSUE_COLOR")
			2:
				attrs["model"] = _injector_bad_model()
				it["issues"].append("ISSUE_LABEL")
			3:
				attrs["company"] = _injector_bad_company()
				it["issues"].append("ISSUE_LABEL")
			4:
				attrs["indicator"] = 1
				it["issues"].append("ISSUE_INDICATOR")
	it["attrs"] = attrs
	it["custom_name"] = "注射剂（%s）" % String(attrs["model"])

func _init_hand(it: Dictionary) -> void:
	var material := "ALUMINUM_ALLOY"
	var mr := rng.randi_range(1, 100)
	if mr <= 3:
		material = "GOLD_PLATED"
	elif mr <= 55:
		material = "CARBON_COMPOSITE"
	var interface := "EMG"
	var ir := rng.randi_range(1, 100)
	if ir <= 20:
		interface = "NEURAL"
	elif ir <= 45:
		interface = "EMG_PLUS"
	elif ir > 85:
		interface = "UNSPECIFIED"
	var condition := "NONE"
	var cr := rng.randi_range(1, 100)
	if cr > 75:
		condition = "DAMAGE"
	elif cr > 50:
		condition = "WEAR"
	var attrs := {
		"material": material, "interface": interface,
		"marking": "FULL" if rng.randf() < 0.5 else "SYMBOL",
		"condition": condition,
		"armored": "ARMORED" if condition == "NONE" and rng.randf() < 0.33 else "NONE",
		"bladed": "BLADED" if condition == "NONE" and rng.randf() < 0.33 else "NONE",
	}
	it["attrs"] = attrs
	it["appraisal_value"] = _hand_value(attrs)

func _init_ribwich(it: Dictionary) -> void:
	var year := 425 + rng.randi_range(0, 4) if rng.randf() < 0.5 else 432 + rng.randi_range(0, 6)
	var month := rng.randi_range(1, 12)
	var period := 1 if year <= 429 else 2
	var attrs := {
		"wrap": 0, "pickles": 0, "meat": 0, "bun": 0,
		"davre_logo": 0,
		"ribwich_logo": 0 if period == 2 else -1,
		"production": "%04d-%02d" % [year, month],
		"year": year, "month": month,
		"facility": rng.randi_range(1, 35),
	}
	var counterfeit := (not bool(it.get("authentic", true))) or rng.randf() < 0.2
	if counterfeit:
		var pick := rng.randi_range(0, 5)
		match pick:
			0:
				attrs["wrap"] = 1 if rng.randf() < 0.5 else 2
			1:
				attrs["pickles"] = -1
			2:
				attrs["davre_logo"] = rng.randi_range(1, 7)
			3:
				attrs["production"] = "%04d-%02d" % [420 + rng.randi_range(0, 4), month]
				attrs["year"] = int(String(attrs["production"]).substr(0, 4))
			4:
				attrs["facility"] = rng.randi_range(36, 45)
			5:
				attrs["ribwich_logo"] = rng.randi_range(1, 3)
	it["attrs"] = attrs
	it["appraisal_value"] = _ribwich_value(attrs)

func _init_plasma(it: Dictionary) -> void:
	var attrs := {
		"wear": "WEAR" if rng.randf() < 0.33 else ("WEAR_HEAVY" if rng.randf() < 0.2 else "NONE"),
		"crack": "CRACK" if rng.randf() < 0.25 else "NONE",
		"uncovered": "UNCOVERED" if rng.randf() < 0.25 else "NONE",
		"reinforced": "REINFORCED" if rng.randf() < 0.25 else "NONE",
		"color": "",
		"seal": "",
	}
	var colors := ["STANDARD", "HIGH_QUALITY", "POOR1", "POOR2"]
	attrs["color"] = colors[rng.randi_range(0, colors.size() - 1)]
	var seals := ["NONE", "ZHONGHUA", "REPUBLIC", "IGNITION_LAB"]
	attrs["seal"] = seals[rng.randi_range(0, seals.size() - 1)]
	it["attrs"] = attrs
	it["appraisal_value"] = _plasma_value(attrs)

func _init_berry(it: Dictionary) -> void:
	var cond := 0
	var br := rng.randi_range(1, 100)
	if br <= 15:
		cond = -2
	elif br <= 35:
		cond = -1
	elif br <= 55:
		cond = 2
	it["attrs"] = {"condition": cond, "visual": rng.randi_range(1, 2)}

func _hand_value(attrs: Dictionary) -> int:
	var v := 100
	var material := String(attrs.get("material", "ALUMINUM_ALLOY"))
	var interface := String(attrs.get("interface", "EMG"))
	var condition := String(attrs.get("condition", "NONE"))
	if material == "GOLD_PLATED":
		v += 200
	elif material == "CARBON_COMPOSITE":
		v += 50
	if interface == "NEURAL":
		v += 120
	elif interface == "EMG_PLUS":
		v += 45
	elif interface == "UNSPECIFIED":
		v -= 60
	if condition == "WEAR":
		v -= 35
	elif condition == "DAMAGE":
		v -= 85
	if String(attrs.get("armored", "NONE")) == "ARMORED":
		v += 50
	if String(attrs.get("bladed", "NONE")) == "BLADED":
		v += 80
	if material == "CARBON_COMPOSITE" and interface in ["EMG_PLUS", "NEURAL"] and condition == "NONE" and String(attrs.get("armored", "")) == "ARMORED" and String(attrs.get("bladed", "")) == "BLADED":
		v += 100
	if material == "GOLD_PLATED" and interface == "NEURAL" and condition == "NONE":
		v += 200
	return maxi(v, 50)

func _ribwich_value(attrs: Dictionary) -> int:
	var wrap := int(attrs.get("wrap", 0))
	if wrap in [1, 2]:
		return 40
	var year := int(attrs.get("year", attrs.get("production", "0000-01").substr(0, 4) if attrs.get("production", "") != "" else 0))
	var month := int(attrs.get("month", 1))
	var valid_date := month >= 1 and month <= 12 and ((year >= 425 and year <= 429) or (year >= 432 and year <= 438))
	var facility := int(attrs.get("facility", 0))
	var period := 1 if year >= 425 and year <= 429 else (2 if year >= 432 and year <= 438 else 0)
	var counterfeit := (not valid_date) or facility < 1 or facility > 35 or int(attrs.get("davre_logo", 0)) != 0
	if period == 2 and int(attrs.get("ribwich_logo", 0)) != 0:
		counterfeit = true
	if period == 1 and int(attrs.get("ribwich_logo", 0)) != -1:
		counterfeit = true
	if counterfeit:
		return 40
	var v := 150
	if int(attrs.get("meat", 0)) == 1:
		v += 800
	if int(attrs.get("bun", 0)) == 1 and int(attrs.get("pickles", 0)) == 1:
		v += 300
	if (period == 1 and month == 1 and year == 425) or (period == 2 and month == 12 and year == 438):
		v += 50
	if year >= 425 and year <= 429:
		v += 80
	if facility in [1, 2, 5, 8, 21, 34]:
		v += 50
	elif facility in [7, 15, 18, 26, 31]:
		v -= 50
	return maxi(v, 40)

func _plasma_value(attrs: Dictionary) -> int:
	var v := 300
	var wear := String(attrs.get("wear", "NONE"))
	var crack := String(attrs.get("crack", "NONE"))
	var uncovered := String(attrs.get("uncovered", "NONE"))
	var reinforced := String(attrs.get("reinforced", "NONE"))
	var color := String(attrs.get("color", "STANDARD"))
	var seal := String(attrs.get("seal", "LL"))
	if wear == "WEAR":
		v -= 45
	elif wear == "WEAR_HEAVY":
		v -= 90
	if crack == "CRACK":
		v -= 150
	if uncovered == "UNCOVERED":
		v -= 60
	if reinforced == "REINFORCED":
		v += 60
	if color in ["POOR1", "POOR2"]:
		v -= 150
	elif color == "HIGH_QUALITY":
		v += 150
	if seal == "LL" and color in ["STANDARD", "POOR1", "POOR2"]:
		v += 60
	elif seal == "ZHONGHUA" and wear == "NONE" and crack == "NONE" and uncovered == "NONE" and color == "STANDARD":
		v += 120
	elif seal == "REPUBLIC" and crack != "CRACK" and color == "STANDARD":
		v += 120
	elif seal == "IGNITION_LAB" and reinforced == "NONE" and wear == "NONE" and crack == "NONE" and uncovered == "NONE" and color == "HIGH_QUALITY":
		v += 750
	return maxi(v, 90)

func _injector_correct_serial() -> String:
	var recalled := [250, 251, 301, 355, 385, 386, 421]
	var prefix := 0
	for i in range(10):
		prefix = rng.randi_range(125, 455)
		if not recalled.has(prefix):
			break
	if recalled.has(prefix):
		prefix = 133
	return "%d%04d" % [prefix, rng.randi_range(1000, 9999)]

func _injector_bad_serial() -> String:
	var recalled := [250, 251, 301, 355, 385, 386, 421]
	var mode := rng.randi_range(0, 3)
	if mode == 0:
		return str(rng.randi_range(100000, 999999))
	if mode == 1:
		return str(rng.randi_range(100, 124)) + str(rng.randi_range(1000, 9999))
	if mode == 2:
		return str(rng.randi_range(456, 999)) + str(rng.randi_range(1000, 9999))
	return "%d%04d" % [int(recalled[rng.randi_range(0, recalled.size() - 1)]), rng.randi_range(1000, 9999)]

func _injector_bad_company() -> String:
	var arr := ["Micheal Pharmaceutical", "Carmicheal Inc.", "Carmiicheal Phamaceutical", "Carmicheal Pharmaceutical Ltd.", "Crmichal Pharmaceutical", "Carmicheal's Meds", "Carmicheal", ""]
	return String(arr[rng.randi_range(0, arr.size() - 1)])

func _injector_bad_model() -> String:
	var arr := ["Immunivaxine", "Immunovax", "Imunivax", "ImmuniPro", "ImmuniVax 3000", "Im univax", "Immunivx", "Immunevax", "Imm nivax", ""]
	return String(arr[rng.randi_range(0, arr.size() - 1)])

func _family_attr_text(it: Dictionary) -> String:
	var family := String(it.get("family", "generic"))
	var fam: Dictionary = inspection_families.get(family, {})
	if fam.is_empty():
		return ""
	var attrs: Dictionary = it.get("attrs", {})
	var lines: Array = []
	for a in fam.get("attributes", []):
		var key := String(a.get("key", ""))
		var label := String(a.get("label", key))
		var value = attrs.get(key, "")
		if key == "production":
			value = String(attrs.get("production", "%04d-%02d" % [int(attrs.get("year", 0)), int(attrs.get("month", 0))]))
			lines.append("%s：%s" % [label, str(value)])
		elif key == "facility":
			lines.append("%s：%d" % [label, int(value)])
		elif key == "amount":
			lines.append("%s：%d 代用点" % [label, int(value)])
		elif key == "serial":
			lines.append("%s：%s" % [label, str(value)])
		elif key == "company":
			lines.append("%s：%s" % [label, str(value)])
		elif key == "model":
			lines.append("%s：%s" % [label, str(value)])
		else:
			lines.append("%s：%s" % [label, _attr_label(family, key, value)])
	return "\n".join(lines)

func _family_issue_options(it: Dictionary) -> Array:
	var family := String(it.get("family", "generic"))
	var fam: Dictionary = inspection_families.get(family, {})
	var out: Array = []
	var seen := {}
	for a in fam.get("attributes", []):
		var issue := String(a.get("issue", ""))
		if issue == "" or issue in seen:
			continue
		seen[issue] = true
		out.append({"id": issue, "label": String(a.get("label", issue))})
	if out.is_empty():
		out.append({"id": "__genuine__", "label": "正品"})
	return out

func _feature_by_id(it: Dictionary, id: String) -> Dictionary:
	for f in it.get("feature_list", []):
		if String(f.get("id", "")) == id:
			return f
	return {}

func _discover_features_with_tool(it: Dictionary, tool_id: String) -> Array:
	var got: Array = []
	for f in it.get("feature_list", []):
		if String(f.get("tool", "")) == tool_id and not bool(f.get("discovered", false)):
			f["discovered"] = true
			got.append(String(f.get("label", f.get("id", ""))))
	return got

func _expose_feature_internal(it: Dictionary, fid: String) -> bool:
	var f := _feature_by_id(it, fid)
	if f.is_empty() or not bool(f.get("discovered", false)) or bool(f.get("exposed", false)):
		return false
	f["exposed"] = true
	return true

func inspection_tools_for_counter() -> Array:
	var out: Array = []
	if inventory_count("magnifier") > 0:
		out.append({"id": "magnifier", "label": "放大镜", "count": inventory_count("magnifier")})
	if inventory_count("flashlight") > 0:
		out.append({"id": "flashlight", "label": "手电筒", "count": inventory_count("flashlight")})
	if inventory_count("water_test_strip") > 0:
		out.append({"id": "water_test_strip", "label": "水质试纸", "count": inventory_count("water_test_strip")})
	if inventory_count("chem_scanner") > 0:
		out.append({"id": "chem_scanner", "label": "化学扫描仪", "count": inventory_count("chem_scanner")})
	if inventory_count("plant_analyser") > 0:
		out.append({"id": "plant_analyser", "label": "植物分析仪", "count": inventory_count("plant_analyser")})
	out.append({"id": "scale", "label": "电子秤", "count": 1})
	return out

func inspect_counter_with_tool(tool_id: String) -> Dictionary:
	var it := counter_item
	if it.is_empty():
		return {"ok": false, "text": "柜台上没有物品。"}
	if tool_id == "magnifier":
		if inventory_count("magnifier") <= 0:
			return {"ok": false, "text": "没有放大镜。"}
		it["family_seen"] = true
		var got := _discover_features_with_tool(it, "magnifier")
		var text := "放大镜检查结果：\n" + _family_attr_text(it)
		if not got.is_empty():
			text += "\n发现：%s" % "、".join(got)
		_append_inspection_note(it, text)
		emit_signal("state_changed")
		return {"ok": true, "text": text}
	if tool_id == "flashlight":
		if inventory_count("flashlight") <= 0:
			return {"ok": false, "text": "没有手电筒。"}
		var got2 := _discover_features_with_tool(it, "flashlight")
		var text2 := "手电筒检查结果："
		if got2.is_empty():
			text2 += "没有发现明显的包装或锈蚀问题。"
		else:
			text2 += "发现 %s。" % "、".join(got2)
		_append_inspection_note(it, text2)
		emit_signal("state_changed")
		return {"ok": true, "text": text2}
	if tool_id == "water_test_strip":
		if inventory_count("water_test_strip") <= 0:
			return {"ok": false, "text": "没有水质试纸。"}
		remove_inventory("water_test_strip", 1)
		var wf := _feature_by_id(it, "water_rust")
		if wf.is_empty():
			wf = _feature_by_id(it, "water_gutter")
		if wf.is_empty():
			wf = _feature_by_id(it, "water_ghost")
		if not wf.is_empty():
			wf["discovered"] = true
			wf["exposed"] = true
			_refresh_customer_price(it)
		var text3 := "水质试纸：%s。" % (String(wf.get("real_label", "水质正常")) if not wf.is_empty() else "水质正常")
		_append_inspection_note(it, text3)
		emit_signal("state_changed")
		return {"ok": true, "text": text3}
	if tool_id == "chem_scanner":
		if inventory_count("chem_scanner") <= 0:
			return {"ok": false, "text": "没有化学扫描仪。"}
		var cf := _feature_by_id(it, "chem_starch")
		if cf.is_empty():
			cf = _feature_by_id(it, "chem_junk")
		if cf.is_empty():
			cf = _feature_by_id(it, "chem_cut")
		if not cf.is_empty():
			cf["discovered"] = true
			cf["exposed"] = true
			_refresh_customer_price(it)
		var text4 := "化学扫描：%s。" % (String(cf.get("real_label", "街头标准")) if not cf.is_empty() else "街头标准")
		_append_inspection_note(it, text4)
		emit_signal("state_changed")
		return {"ok": true, "text": text4}
	if tool_id == "plant_analyser":
		if inventory_count("plant_analyser") <= 0:
			return {"ok": false, "text": "没有植物分析仪。"}
		var text5 := "植物分析：营养区间 %d-%d，每周期耗水约 %dml。" % [int(it.get("condition", 100)) * 10, int(it.get("condition", 100)) * 14, 100]
		_append_inspection_note(it, text5)
		return {"ok": true, "text": text5}
	if tool_id == "scale":
		var wt := 0.0
		for c in item_cells(it):
			wt += 0.1
		var text6 := "电子秤：约 %.2f kg。" % wt
		var wfeat := _feature_by_id(it, "weight")
		if wfeat.is_empty():
			wfeat = _add_custom_feature(it, "weight", "weight", "重量", "未称重", text6, 0, 0)
		wfeat["discovered"] = true
		wfeat["real_label"] = text6
		_append_inspection_note(it, text6)
		emit_signal("state_changed")
		return {"ok": true, "text": text6}
	return {"ok": false, "text": "没有这个工具。"}

func _append_inspection_note(it: Dictionary, text: String) -> void:
	var notes: Array = it.get("inspect_notes", [])
	if not notes.has(text):
		notes.append(text)
	it["inspect_notes"] = notes

func expose_counter_feature(index: int) -> Dictionary:
	var it := counter_item
	var list: Array = it.get("feature_list", [])
	if index < 0 or index >= list.size():
		return {"ok": false, "text": "没有这个特征。"}
	var f: Dictionary = list[index]
	if not bool(f.get("discovered", false)):
		return {"ok": false, "text": "尚未发现这个特征。"}
	if bool(f.get("exposed", false)):
		return {"ok": false, "text": "这个特征已经揭露。"}
	f["exposed"] = true
	_refresh_customer_price(it)
	emit_signal("state_changed")
	return {"ok": true, "text": "已揭露：%s。" % String(f.get("real_label", ""))}

func _refresh_customer_price(it: Dictionary) -> void:
	if current_customer.is_empty():
		return
	var cuid := int(current_customer.get("item", {}).get("uid", -1))
	if cuid != int(it.get("uid", -2)):
		return
	var val := market_value(it, false, String(current_customer.get("arche", {}).get("faction", "lower")))
	current_customer["item"]["min_price"] = maxi(1, int(round(float(val) * 0.7)))
	current_customer["item"]["asking_price"] = maxi(1, int(round(float(val) * 0.9)))

func confront_counter_item(issue_id: String) -> Dictionary:
	var it := counter_item
	if it.is_empty():
		return {"ok": false, "text": "柜台上没有物品。"}
	var family := String(it.get("family", "generic"))
	if family not in ["cigarette", "stamp", "injector"]:
		return {"ok": false, "text": "这件物品不支持对质。"}
	if bool(it.get("confronted", false)):
		return {"ok": false, "text": "已经对质过了。"}
	var issues: Array = it.get("issues", [])
	var correct := (issue_id == "__genuine__" and issues.is_empty()) or issues.has(issue_id)
	if not correct:
		add_rep(String(current_customer.get("arche", {}).get("faction", "lower")), -2)
		return {"ok": false, "text": "顾客否认了你的判断，你的声望下降了。"}
	it["confronted"] = true
	var public_auth := "正品" if issues.is_empty() else "假货"
	var f := _add_custom_feature(it, "authenticity", "CATEGORY_AUTHENTICITY", "真伪", public_auth, public_auth, 0, 0)
	f["discovered"] = true
	f["exposed"] = true
	if _feature_by_id(it, "confront_discount").is_empty():
		var d := _add_custom_feature(it, "confront_discount", "confront", "验货折扣", "", "", 0, -15, "final")
		d["discovered"] = true
		d["exposed"] = true
	if issues.is_empty():
		add_rep(String(current_customer.get("arche", {}).get("faction", "lower")), 2)
	_refresh_customer_price(it)
	emit_signal("state_changed")
	return {"ok": true, "text": "对质成功：顾客承认了问题，价格已下调。"}


func next_uid() -> int:
	uid_counter += 1
	return uid_counter - 1

func appraisal_rank_data(level: int = -1) -> Dictionary:
	var lv := appraiser_level if level < 0 else level
	lv = clampi(lv, 0, maxi(0, appraisal_ranks.size() - 1))
	if appraisal_ranks.is_empty():
		return {}
	return appraisal_ranks[lv]

func appraisal_rank_name() -> String:
	var r := appraisal_rank_data()
	return String(r.get("name", "初级鉴定师"))

func appraisal_attraction_chance() -> int:
	var r := appraisal_rank_data()
	var base := int(r.get("attraction_chance", 33))
	return mini(100, int(round(float(base) * (2 + appraisal_days_missed) / 2.0)))

func appraisal_types_unlocked() -> Array:
	var out: Array = []
	for t in appraisal_item_defs:
		if int(t.get("unlock_rank", 0)) <= appraiser_level and not appraisal_blacklist.has(String(t.get("id", ""))):
			out.append(t)
	return out

func _appraisal_type_def(type_id: String) -> Dictionary:
	for t in appraisal_item_defs:
		if String(t.get("id", "")) == type_id:
			return t
	return {}

func _create_appraisal_item(type_id: String) -> Dictionary:
	var t := _appraisal_type_def(type_id)
	if t.is_empty():
		return {}
	var ids: Array = t.get("item_ids", [])
	if ids.is_empty():
		return {}
	var did := String(ids[rng.randi_range(0, ids.size() - 1)])
	var it := make_item(did, rng.randi_range(65, 100), true, false)
	it["family"] = String(t.get("family", it.get("family", "generic")))
	it["appraisal_value"] = int(it.get("appraisal_value", effective_value(it)))
	return it

func _gen_appraisal_customer() -> Dictionary:
	var pool := appraisal_types_unlocked()
	if pool.is_empty():
		pool = appraisal_item_defs
	var t: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var it := _create_appraisal_item(String(t.get("id", "")))
	var arche: Dictionary = customer_defs[rng.randi_range(0, customer_defs.size() - 1)].duplicate(true)
	if not FileAccess.file_exists("res://assets/customers/" + String(arche.get("sprite", ""))):
		arche["sprite"] = _random_client_sprite(String(arche.get("faction", "lower")))
	return {
		"arche": arche, "intent": "appraise", "patience": 3, "done": false,
		"item": it, "impatience": 0,
		"line": "我有件东西想请你估价。",
	}

func appraisal_precision(correct: int, value: int) -> int:
	if correct <= 0:
		return 5
	var low := int(round(float(correct) * 0.95))
	var high := int(round(float(correct) * 1.05))
	if value >= low and value <= high:
		return 1
	if value < low:
		if value <= int(round(float(correct) * 0.75)):
			return 5
		if value <= int(round(float(correct) * 0.85)):
			return 4
		if value <= int(round(float(correct) * 0.90)):
			return 3
		return 2
	if value >= int(round(float(correct) * 1.25)):
		return 5
	if value >= int(round(float(correct) * 1.15)):
		return 4
	if value >= int(round(float(correct) * 1.10)):
		return 3
	return 2

func _appraisal_acceptable(correct: int, value: int) -> int:
	if value < int(round(float(correct) * 0.5)):
		return -1
	if value > int(round(float(correct) * 1.5)):
		return 1
	return 0

func _appraisal_fee_percent(grade: int) -> int:
	var r := appraisal_rank_data()
	var arr: Array = r.get("fee_percent", [15, 12, 10, 8, 5])
	return int(arr[clampi(grade, 1, 5) - 1])

func _appraisal_grade_name(grade: int) -> String:
	match grade:
		1: return "完美"
		2: return "优秀"
		3: return "良好"
		4: return "一般"
	return "糟糕"

func _appraisal_progress(grade: int) -> float:
	var r := appraisal_rank_data()
	var arr: Array = r.get("progress", [10, 7, 5, 4, 3])
	return float(arr[clampi(grade, 1, 5) - 1])

func _add_appraisal_progress(delta: float) -> void:
	if appraiser_level >= 3 or appraisal_promotion_declined:
		return
	var threshold := float(appraisal_rank_data().get("progress_to_promote", 100))
	appraisal_progress = clampf(appraisal_progress + delta, 0.0, threshold)
	if appraisal_progress >= threshold:
		appraisal_promotion_day = day + 1
		pending_promotion = true

func appraise_counter_item(value: int) -> Dictionary:
	var it := counter_item
	if it.is_empty() or current_customer.is_empty() or String(current_customer.get("intent", "")) != "appraise":
		return {"ok": false, "text": "当前没有估价委托。"}
	var correct := int(it.get("appraisal_value", effective_value(it)))
	if int(current_customer.get("impatience", 0)) >= 100:
		return _appraisal_walkout()
	var acceptable := _appraisal_acceptable(correct, value)
	var grade := appraisal_precision(correct, value)
	if grade == 1:
		ach_stats["perfect_appraisals"] = int(ach_stats.get("perfect_appraisals", 0)) + 1
		_check_achievements()
	if acceptable == 0 and _appraisal_fee_percent(grade) <= 0:
		acceptable = 1 if value >= correct else -1
	if acceptable != 0:
		_add_appraisal_progress(minf(0.0, _appraisal_progress(grade)))
		current_customer["impatience"] = int(current_customer.get("impatience", 0)) + 49
		if int(current_customer["impatience"]) >= 100:
			return _appraisal_walkout()
		return {"ok": false, "text": "顾客认为你的报价%s。" % ("太高" if acceptable > 0 else "太低"), "too_high": acceptable > 0}
	var pct := _appraisal_fee_percent(grade)
	var fee := int(round(float(value) * float(pct) / 100.0)) + int(appraisal_rank_data().get("base_fee", 20))
	cash += fee
	daily["fees"] += fee
	daily["inspected"] = int(daily.get("inspected", 0)) + 1
	_add_appraisal_progress(_appraisal_progress(grade))
	var slip_text := _appraisal_slip_text(grade, value, correct, fee, pct)
	var slip := make_item("appraisal_slip", 100, true, false)
	slip["custom_name"] = "估价单（%s）" % _appraisal_grade_name(grade)
	slip["custom_desc"] = slip_text
	slip["known"] = true
	add_item(slip)
	counter_item = {}
	complete_customer(true)
	return {
		"ok": true, "text": "估价成功：%s。报酬 %d₵。" % [_appraisal_grade_name(grade), fee],
		"fee": fee, "grade": grade, "slip": slip_text,
	}

func _appraisal_walkout() -> Dictionary:
	_add_appraisal_progress(float(appraisal_rank_data().get("walkout_progress", 0)))
	var lost := counter_item
	counter_item = {}
	complete_customer(false)
	return {"ok": false, "text": "顾客失去耐心离开了。", "walkout": true, "lost_item": lost}

func _appraisal_slip_text(grade: int, estimate: int, correct: int, fee: int, pct: int) -> String:
	var accuracy := 100 - int(round(float(absi(estimate - correct)) * 100.0 / float(maxi(1, correct))))
	return "估价单\n评级：%s（%d%%）\n估价：%d₵\n真实价值：%d₵\n\n服务费：%d₵（%d%% + 底费 %d₵）" % [_appraisal_grade_name(grade), accuracy, estimate, correct, fee, pct, int(appraisal_rank_data().get("base_fee", 20))]

func promotion_cost() -> int:
	if appraiser_level >= 3:
		return 0
	var r := appraisal_rank_data(appraiser_level + 1)
	return int(round(85.0 * float(r.get("cost_share", 1.0))))

func promote_appraiser() -> Dictionary:
	if appraiser_level >= 3:
		return {"ok": false, "text": "已经是最高等级。"}
	var threshold := float(appraisal_rank_data().get("progress_to_promote", 100))
	if appraisal_progress < threshold:
		return {"ok": false, "text": "鉴定进度不足。"}
	var cost := promotion_cost()
	if cash < cost:
		return {"ok": false, "text": "晋升需要 %d₵，现金不足。" % cost}
	cash -= cost
	appraiser_level += 1
	appraisal_progress = 0.0
	appraisal_promotion_day = -1
	pending_promotion = false
	appraisal_promotion_declined = false
	var cert_id := String(appraisal_rank_data().get("certificate", "cert1"))
	if items_def.has(cert_id):
		add_item(make_item(cert_id, 100, true, false))
	emit_signal("state_changed")
	return {"ok": true, "text": "晋升为%s，花费 %d₵。" % [appraisal_rank_name(), cost]}

func decline_promotion(for_good: bool = false) -> void:
	if for_good:
		appraisal_promotion_declined = true
		appraisal_promotion_day = -1
	else:
		appraisal_promotion_day = day + 7
	pending_promotion = false
	emit_signal("state_changed")

func loc(group: String, key: String, fallback: String = "", args: Array = []) -> String:
	var text := String(locale_text.get("%s:%s" % [group, key], fallback))
	for i in range(args.size()):
		text = text.replace("{%d}" % i, str(args[i]))
	return text

func container_def(def_id: String) -> Dictionary:
	return containers_def.get(def_id, {})

func container_spec(item: Dictionary) -> Dictionary:
	if item.has("container_spec") and item["container_spec"] is Dictionary:
		return item["container_spec"]
	return container_def(String(item.get("def_id", "")))

func container_zones(spec: Dictionary) -> Array:
	var z = spec.get("zones", [])
	return z if z is Array else []

func container_zone_at(spec: Dictionary, x: int) -> Dictionary:
	for z in container_zones(spec):
		if x >= int(z.get("x", 0)) and x < int(z.get("x", 0)) + int(z.get("width", 0)):
			return z
	return {}

func container_effective_width(spec: Dictionary) -> int:
	var zones := container_zones(spec)
	if zones.is_empty():
		return int(spec.get("width", 1))
	var total := 0
	for z in zones:
		total += int(z.get("width", 0))
	return total

const CHILLABLE_IDS := ["bottled_water", "bottled_water_premium", "small_bottled_water", "large_bottled_water", "water_ration", "water_ration_small", "energy_drink", "soda_red", "red_beer", "processed_juice", "processed_milk"]

func is_chillable_item(it: Dictionary) -> bool:
	var did := String(it.get("def_id", ""))
	if is_liquid_container(it):
		return true
	return did in CHILLABLE_IDS

func is_freezable_item(it: Dictionary) -> bool:
	var did := String(it.get("def_id", ""))
	return did == "beis_icecream"

func is_spirit_item(it: Dictionary) -> bool:
	return String(it.get("def_id", "")) == "nudka"

func zone_accepts_item(zone: Dictionary, child: Dictionary) -> bool:
	var zid := String(zone.get("id", ""))
	var did := String(child.get("def_id", ""))
	var def := get_item_def(did)
	if String(def.get("category", "")) in ["machine", "furniture"]:
		return false
	if is_liquid_container(child):
		return true
	if zid == "chill":
		return is_chillable_item(child) or is_spirit_item(child)
	if zid == "freeze":
		return is_freezable_item(child) or is_spirit_item(child)
	return true

func is_container_item(item: Dictionary) -> bool:
	var spec := container_spec(item)
	if spec.is_empty():
		return false
	var kind := String(spec.get("kind", ""))
	if kind in ["grid", "slots"]:
		return true
	return kind == "liquid" and int(spec.get("filter_slots", 0)) > 0

func is_liquid_container(item: Dictionary) -> bool:
	var spec := container_spec(item)
	return not spec.is_empty() and String(spec.get("kind", "")) == "liquid"

func inventory_columns() -> int:
	if starting_perk_active("perk_ascetic"):
		return 12
	if starting_perk_active("perk_minimalist"):
		return 14
	return GRID_W

func page_size(page: int) -> Array:
	if page == 2:
		return [HIDDEN_W, HIDDEN_H]
	return [inventory_columns(), GRID_H]

func _init_container_state(it: Dictionary) -> void:
	var spec := container_def(String(it.get("def_id", "")))
	if spec.is_empty():
		return
	it["container_spec"] = spec.duplicate(true)
	it["children"] = []
	it["container_locked"] = spec.has("locked") and String(spec.get("locked", "")) != ""
	if String(spec.get("kind", "")) == "liquid":
		var cap := int(spec.get("capacity_ml", 500))
		it["liquid_ml"] = cap
		it["liquid_purity"] = clampi(int(it.get("condition", 100)) * 100, 0, 10000)
		it["liquid_contents"] = {"water": cap}

var shape_mask_cache: Dictionary = {}

func item_shape(item: Dictionary) -> Array:
	var def := get_item_def(item["def_id"])
	var s = def.get("shape", [1, 1])
	if item.get("rotated", false):
		return [s[1], s[0]]
	return [s[0], s[1]]

func item_mask_cells(item: Dictionary, rotated_override: int = -1) -> Array:
	var def := get_item_def(String(item.get("def_id", "")))
	var s: Array = def.get("shape", [1, 1])
	var w := int(s[0])
	var h := int(s[1])
	var rotated := bool(item.get("rotated", false)) if rotated_override < 0 else bool(rotated_override)
	var key := "%s|%d" % [String(item.get("def_id", "")), 1 if rotated else 0]
	if shape_mask_cache.has(key):
		return shape_mask_cache[key]
	var mask: Array = []
	mask.resize(w * h)
	mask.fill(true)
	var path := item_icon_path(def)
	if path != "" and ResourceLoader.exists(path):
		var tex = load(path)
		if tex is Texture2D:
			var img: Image = tex.get_image()
			if img != null:
				if img.is_compressed():
					img.decompress()
				var iw := img.get_width()
				var ih := img.get_height()
				var want_ratio := float(w) / float(maxi(1, h))
				var have_ratio := float(iw) / float(maxi(1, ih))
				var ratio_ok := have_ratio <= want_ratio * 1.6 and have_ratio >= want_ratio / 1.6
				var filled := 0
				if ratio_ok:
					for yy in range(h):
						for xx in range(w):
							var px := int((float(xx) + 0.5) / float(w) * float(iw))
							var py := int((float(yy) + 0.5) / float(h) * float(ih))
							px = clampi(px, 0, iw - 1)
							py = clampi(py, 0, ih - 1)
							var a := img.get_pixel(px, py).a
							if a > 0.12:
								mask[yy * w + xx] = true
								filled += 1
							else:
								mask[yy * w + xx] = false
				if filled <= 0:
					mask.fill(true)
	if rotated:
		var rmask: Array = []
		rmask.resize(w * h)
		for yy in range(h):
			for xx in range(w):
				rmask[xx * h + (h - 1 - yy)] = mask[yy * w + xx]
		mask = rmask
	shape_mask_cache[key] = mask
	return mask

func item_cells(item: Dictionary, ox: int = -1, oy: int = -1) -> Array:
	var s := item_shape(item)
	var x: int = int(item["x"]) if ox < 0 else ox
	var y: int = int(item["y"]) if oy < 0 else oy
	var mask := item_mask_cells(item)
	var out: Array = []
	for dy in range(s[1]):
		for dx in range(s[0]):
			if bool(mask[dy * int(s[0]) + dx]):
				out.append(Vector2i(x + dx, y + dy))
	return out

func can_place(item: Dictionary, x: int, y: int, rotated: bool, ignore_uid: int = -1, page: int = 0) -> bool:
	var s = get_item_def(item["def_id"]).get("shape", [1, 1])
	var w: int = s[1] if rotated else s[0]
	var h: int = s[0] if rotated else s[1]
	var dims := page_size(page)
	if x < 0 or y < 0 or x + w > int(dims[0]) or y + h > int(dims[1]):
		return false
	var mask := item_mask_cells(item, 1 if rotated else 0)
	var test := {}
	for dy in range(h):
		for dx in range(w):
			if bool(mask[dy * w + dx]):
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
	var pages: Array = [page] if page >= 0 else [0, 1]
	for pg in pages:
		var dims := page_size(int(pg))
		for y in range(int(dims[1])):
			for x in range(int(dims[0])):
				for rot in [false, true]:
					if can_place(item, x, y, rot, -1, pg):
						item["x"] = x
						item["y"] = y
						item["page"] = pg
						item["rotated"] = rot
						item["location"] = "backpack"
						return true
	return false

func is_stackable_item(it: Dictionary) -> bool:
	var did := String(it.get("def_id", ""))
	return did.contains("_ammo") and not is_container_item(it)

func add_item(item: Dictionary) -> bool:
	if String(item.get("def_id", "")) == "business_permit":
		unlock_achievement("ACH_AUTHORIZED")
	if is_stackable_item(item):
		for existing in inventory:
			if String(existing.get("def_id", "")) == String(item.get("def_id", "")) and int(existing.get("unit_count", 1)) < 99 and int(existing.get("condition", 100)) == int(item.get("condition", 100)) and bool(existing.get("authentic", true)) == bool(item.get("authentic", true)) and bool(existing.get("stolen", false)) == bool(item.get("stolen", false)) and existing.get("children", []).is_empty():
				existing["unit_count"] = int(existing.get("unit_count", 1)) + int(item.get("unit_count", 1))
				return true
	var ok := auto_place(item)
	if not ok:
		item["location"] = "overflow"
	inventory.append(item)
	_refresh_pages()
	return ok

func _refresh_pages() -> void:
	max_pages_unlocked = GRID_PAGES
	pages_unlocked = GRID_PAGES

func _find_child_item(parent: Dictionary, uid: int) -> Dictionary:
	for ch in parent.get("children", []):
		if int(ch.get("uid", -1)) == uid:
			return ch
		var nested := _find_child_item(ch, uid)
		if not nested.is_empty():
			return nested
	return {}

func find_item(uid: int) -> Dictionary:
	for it in inventory:
		if int(it.get("uid", -1)) == uid:
			return it
		var nested := _find_child_item(it, uid)
		if not nested.is_empty():
			return nested
	for it in display:
		if int(it.get("uid", -1)) == uid:
			return it
		var nested2 := _find_child_item(it, uid)
		if not nested2.is_empty():
			return nested2
	for it in trash_items:
		if int(it.get("uid", -1)) == uid:
			return it
		var nested_trash := _find_child_item(it, uid)
		if not nested_trash.is_empty():
			return nested_trash
	if not counter_item.is_empty():
		if int(counter_item.get("uid", -1)) == uid:
			return counter_item
		var nested3 := _find_child_item(counter_item, uid)
		if not nested3.is_empty():
			return nested3
	for mc in machine_container_items.values():
		if int(mc.get("uid", -2)) == uid:
			return mc
		var nested4 := _find_child_item(mc, uid)
		if not nested4.is_empty():
			return nested4
	return {}

func item_drag_sfx_key(it: Dictionary, action: String) -> String:
	var def := get_item_def(String(it.get("def_id", "")))
	var cat := String(def.get("category", ""))
	var did := String(it.get("def_id", ""))
	var tags := _item_tags(it)
	var prefix := "sfx_"
	var suffix := "_drag" if action == "drag" else "_drop"
	if cat == "weapon":
		if did in ["shotgun", "smg"]:
			return prefix + "heavy_gun" + suffix
		if did.contains("rifle") or did.contains("ump"):
			return prefix + "gun" + suffix
		return prefix + "small_gun" + suffix
	if cat == "weapon_mod":
		return prefix + "module" + suffix
	if cat in ["food", "animal"]:
		if tags.has("PRODUCE") or tags.has("SEED"):
			return prefix + "produce" + suffix
		return prefix + "meaty" + suffix
	if cat == "medical":
		return prefix + "plastic_vial" + ("_open" if action == "drag" else "_close")
	if cat == "document":
		return prefix + "paper_sheet" + suffix
	if cat == "material":
		if tags.has("METAL"):
			return prefix + "solid_metal" + suffix
		return prefix + "tiny_item" + suffix
	if tags.has("TEXTILE"):
		return prefix + "textile" + suffix
	if tags.has("GLASS") or did.contains("bottle"):
		return prefix + "full_plastic_bottle" + suffix
	return prefix + "tiny_item" + suffix

func _item_tags(it: Dictionary) -> Array:
	var def := get_item_def(String(it.get("def_id", "")))
	var tags: Array = def.get("tags", []).duplicate()
	var did := String(it.get("def_id", ""))
	var cat := String(def.get("category", ""))
	if cat == "weapon_mod":
		if did in ["stock", "short_stock"]:
			tags.append("MOD_STOCK_TAG")
		elif did in ["rds", "rds_makeshift", "laser", "laser2", "laser_toy", "ammo_display"]:
			tags.append("MOD_RAIL_TAG")
		elif did in ["barrel", "match_barrel", "compensator", "silencer", "silencer2", "silencer_makeshift"]:
			tags.append("MOD_BARREL_TAG")
		elif did.begins_with("mag_"):
			tags.append("MOD_MAGAZINE_TAG")
		elif did in ["grip", "grip_gel", "bipod", "gl"]:
			tags.append("MOD_UNDER_RAIL_TAG")
		else:
			tags.append("MOD_SPECIAL_TAG")
	if cat == "weapon" and did.contains("ammo"):
		tags.append("AMMUNITION")
	if did.contains("armor") or cat == "armor":
		tags.append("ARMOR")
	if int(def.get("contraband", 0)) > 0:
		tags.append("CONTRABAND")
	if did.ends_with("_seed") or cat == "plant":
		tags.append("SEED")
	if did in ["dream_dust", "nightmare_dust", "fanta_pill", "pink_alt_injector", "black_injector"]:
		tags.append("NARCOTIC")
	if did == "moonshine":
		tags.append("ALCOHOL")
	var upper := cat.to_upper()
	if upper != "" and not tags.has(upper):
		tags.append(upper)
	return tags

func _tag_match(tags: Array, wanted: Array) -> bool:
	for w in wanted:
		if tags.has(String(w)):
			return true
	return false

func is_water_filter_item(it: Dictionary) -> bool:
	var def := get_item_def(String(it.get("def_id", "")))
	return def.get("tags", []).has("WATER_FILTER")

func container_filter_slots(spec: Dictionary) -> int:
	return int(spec.get("filter_slots", 0))

func container_filter_at(parent: Dictionary, slot_index: int = 0) -> Dictionary:
	var sid := "filter%d" % (slot_index + 1)
	for ch in parent.get("children", []):
		if String(ch.get("slot_id", "")) == sid:
			return ch
	return {}

func container_can_accept(parent: Dictionary, child: Dictionary) -> bool:
	var spec := container_spec(parent)
	if spec.is_empty() or not is_container_item(parent):
		return false
	if int(child.get("uid", -1)) == int(parent.get("uid", -2)):
		return false
	var fslots := container_filter_slots(spec)
	var is_filter := is_water_filter_item(child)
	if String(spec.get("kind", "")) == "liquid":
		if fslots <= 0 or not is_filter:
			return false
		return _filter_slots_used(parent) < fslots
	if fslots > 0 and is_filter:
		if spec.has("locked") and bool(parent.get("container_locked", true)):
			return false
		return _filter_slots_used(parent) < fslots
	var ctags := _item_tags(child)
	var cspec := container_spec(child)
	var is_container_child := (String(cspec.get("kind", "")) == "grid" and bool(cspec.get("storage", true))) or String(get_item_def(String(child.get("def_id", ""))).get("category", "")) == "container"
	if is_container_child:
		if bool(spec.get("accept_containers", false)):
			pass
		elif bool(cspec.get("nestable_device", false)):
			pass
		elif bool(cspec.get("storable", false)) and bool(spec.get("storage", false)):
			pass
		else:
			return false
	if String(get_item_def(String(child.get("def_id", ""))).get("category", "")) == "furniture" and not bool(cspec.get("nestable_device", false)):
		return false
	var allowed: Array = spec.get("allowed_tags", [])
	if not allowed.is_empty() and not _tag_match(ctags, allowed):
		return false
	if String(spec.get("kind", "")) == "slots":
		var ok := false
		for slot in spec.get("slots", []):
			var accept: Array = slot.get("accept", [])
			if accept.is_empty() or _tag_match(ctags, accept):
				ok = true
				break
		return ok
	if spec.has("locked") and bool(parent.get("container_locked", true)):
		return false
	return true

func _filter_slots_used(parent: Dictionary) -> int:
	var used := 0
	for ch in parent.get("children", []):
		if String(ch.get("slot_id", "")).begins_with("filter"):
			used += 1
	return used

func _container_cells_used(parent: Dictionary, ignore_uid: int = -1) -> Dictionary:
	var used := {}
	for ch in parent.get("children", []):
		if int(ch.get("uid", -1)) == ignore_uid:
			continue
		if String(ch.get("slot_id", "")) != "":
			continue
		for c in item_cells(ch, int(ch.get("x", 0)), int(ch.get("y", 0))):
			used[c] = true
	return used

func container_can_place(parent: Dictionary, child: Dictionary, x: int, y: int, rotated: bool = false, ignore_uid: int = -1) -> bool:
	var spec := container_spec(parent)
	if spec.is_empty():
		return false
	if String(spec.get("kind", "")) == "liquid":
		return container_can_accept(parent, child)
	if String(spec.get("kind", "")) == "slots":
		return container_can_accept(parent, child)
	var s: Array = get_item_def(String(child.get("def_id", ""))).get("shape", [1, 1])
	var w: int = int(s[1]) if rotated else int(s[0])
	var h: int = int(s[0]) if rotated else int(s[1])
	if x < 0 or y < 0 or x + w > int(spec.get("width", 1)) or y + h > int(spec.get("height", 1)):
		return false
	var zones := container_zones(spec)
	if not zones.is_empty():
		var zone := container_zone_at(spec, x)
		if zone.is_empty() or x + w > int(zone.get("x", 0)) + int(zone.get("width", 0)):
			return false
		if not zone_accepts_item(zone, child):
			return false
	var used := _container_cells_used(parent, ignore_uid)
	var mask := item_mask_cells(child, 1 if rotated else 0)
	for dy in range(h):
		for dx in range(w):
			if bool(mask[dy * w + dx]) and used.has(Vector2i(x + dx, y + dy)):
				return false
	return container_can_accept(parent, child)

func container_auto_add(parent: Dictionary, child: Dictionary) -> bool:
	if not container_can_accept(parent, child):
		return false
	var spec := container_spec(parent)
	if is_water_filter_item(child) and container_filter_slots(spec) > 0:
		for i in range(container_filter_slots(spec)):
			if container_filter_at(parent, i).is_empty():
				child["slot_id"] = "filter%d" % (i + 1)
				child["x"] = 0
				child["y"] = 0
				parent["children"].append(child)
				return true
		return false
	if is_stackable_item(child):
		for existing in parent.get("children", []):
			if String(existing.get("def_id", "")) == String(child.get("def_id", "")) and int(existing.get("unit_count", 1)) < 99:
				existing["unit_count"] = int(existing.get("unit_count", 1)) + int(child.get("unit_count", 1))
				return true
	if String(spec.get("kind", "")) == "slots":
		for slot in spec.get("slots", []):
			var accept: Array = slot.get("accept", [])
			if not accept.is_empty() and not _tag_match(_item_tags(child), accept):
				continue
			var sid := String(slot.get("id", ""))
			var occupied := false
			for ch in parent.get("children", []):
				if String(ch.get("slot_id", "")) == sid:
					occupied = true
					break
			if not occupied:
				child["slot_id"] = sid
				child["x"] = 0
				child["y"] = 0
				parent["children"].append(child)
				return true
		return false
	for y in range(int(spec.get("height", 1))):
		for x in range(int(spec.get("width", 1))):
			for rot in [false, true]:
				if container_can_place(parent, child, x, y, rot):
					child["x"] = x
					child["y"] = y
					child["rotated"] = rot
					child["slot_id"] = ""
					parent["children"].append(child)
					return true
	return false

func lock_key_matches(container: Dictionary, key: Dictionary) -> bool:
	var spec := container_spec(container)
	var lock_id := String(spec.get("locked", ""))
	var did := String(key.get("def_id", ""))
	if did == "cmd_keycard":
		return true
	match lock_id:
		"LOCK_ID_SEC": return did == "sec_keycard"
		"LOCK_ID_ENG": return did == "eng_keycard"
		"LOCK_ID_MED": return did == "med_keycard"
		"LOCK_ID_SER": return did == "ser_keycard"
		"LOCK_ID_SUP": return did == "sup_keycard"
	return false

func split_liquid(item: Dictionary) -> Dictionary:
	if not is_liquid_container(item):
		return {"ok": false, "text": "不是液体容器。"}
	var ml := int(item.get("liquid_ml", 0))
	if ml < 2:
		return {"ok": false, "text": "液体太少，无法分瓶。"}
	var half: int = ml / 2
	var copy := make_item(String(item.get("def_id", "")), int(item.get("condition", 100)), bool(item.get("authentic", true)), bool(item.get("stolen", false)))
	copy["liquid_ml"] = ml - half
	copy["liquid_purity"] = int(item.get("liquid_purity", 0))
	copy["location"] = "backpack"
	item["liquid_ml"] = half
	add_item(copy)
	emit_signal("state_changed")
	return {"ok": true, "text": "已分瓶：%d ml。" % (ml - half)}

func transfer_liquid(from_item: Dictionary, to_item: Dictionary) -> Dictionary:
	if not is_liquid_container(from_item) or not is_liquid_container(to_item):
		return {"ok": false, "text": "两边都必须是液体容器。"}
	var from_ml := int(from_item.get("liquid_ml", 0))
	var to_ml := int(to_item.get("liquid_ml", 0))
	var cap := int(container_spec(to_item).get("capacity_ml", 0))
	var space := maxi(0, cap - to_ml)
	var move := mini(from_ml, space)
	if move <= 0:
		return {"ok": false, "text": "目标容器已满或源容器为空。"}
	var p1 := int(from_item.get("liquid_purity", 0))
	var p2 := int(to_item.get("liquid_purity", 0))
	var new_p := int(round((float(p1) * move + float(p2) * to_ml) / float(move + to_ml)))
	var filter_note := ""
	var filter := container_filter_at(to_item)
	if not filter.is_empty() and int(filter.get("condition", 0)) > 0:
		var fid := String(filter.get("def_id", ""))
		var floor_p := 8500
		if fid == "uv_filter":
			floor_p = 9800
		elif fid == "water_filter_adv":
			floor_p = 9500
		new_p = maxi(new_p, floor_p)
		filter["condition"] = maxi(0, int(filter.get("condition", 100)) - maxi(1, int(ceil(float(move) / 500.0))))
		filter_note = "（滤芯过滤，剩余耐久 %d%%）" % int(filter.get("condition", 0))
		if int(filter.get("condition", 0)) <= 0:
			var children: Array = to_item.get("children", [])
			children.erase(filter)
			to_item["children"] = children
			filter_note = "（滤芯已耗尽）"
	from_item["liquid_ml"] = from_ml - move
	to_item["liquid_ml"] = to_ml + move
	to_item["liquid_purity"] = new_p
	emit_signal("state_changed")
	return {"ok": true, "text": "倒入 %d ml，纯度约 %d%%%s。" % [move, new_p / 100, filter_note]}

func split_stack(uid: int) -> Dictionary:
	var it := find_item(uid)
	if it.is_empty():
		return {"ok": false, "text": "找不到这叠物品。"}
	var total := int(it.get("unit_count", 1))
	if total < 2 or not is_stackable_item(it):
		return {"ok": false, "text": "这件物品不能分堆。"}
	var move: int = total / 2
	var copy := make_item(String(it.get("def_id", "")), int(it.get("condition", 100)), bool(it.get("authentic", true)), bool(it.get("stolen", false)))
	copy["unit_count"] = move
	copy["features"] = it.get("features", []).duplicate(true)
	it["unit_count"] = total - move
	if not auto_place(copy):
		copy["location"] = "overflow"
	inventory.append(copy)
	emit_signal("state_changed")
	return {"ok": true, "text": "已分出 %d 发。" % move}

func _finish_unlock(container: Dictionary) -> void:
	container["container_locked"] = false
	container["custom_base_value"] = 15
	container["stolen"] = false
	container["contraband_cleared"] = true
	if container.get("children", []).is_empty():
		_generate_loot(container)

func container_lock_type(container: Dictionary) -> String:
	return String(container_spec(container).get("lock_type", "mechanical"))

func breach_container(container_uid: int) -> Dictionary:
	var c := find_item(container_uid)
	if c.is_empty() or not bool(c.get("container_locked", false)):
		return {"ok": false, "text": "容器没有上锁。"}
	var lock_type := container_lock_type(c)
	var tool := ""
	for candidate in (["wire_cutter", "crowbar", "toolbox"] if lock_type == "electronic" else ["crowbar", "toolbox"]):
		if inventory_count(candidate) > 0:
			tool = candidate
			break
	if tool == "":
		return {"ok": false, "text": "没有合适的撬锁工具（撬棍/工具箱/剪线钳）。"}
	var difficulty := int(container_spec(c).get("lock_difficulty", 20))
	var chance := 70 - difficulty
	if rng.randi_range(1, 100) <= chance:
		_finish_unlock(c)
		remove_inventory(tool, 1)
		emit_signal("state_changed")
		return {"ok": true, "text": "锁被撬开，工具损坏了。"}
	c["lock_attempts"] = int(c.get("lock_attempts", 0)) + 1
	var tool_item := {}
	for it in _iter_inventory_items():
		if String(it.get("def_id", "")) == tool:
			tool_item = it
			break
	if not tool_item.is_empty():
		tool_item["condition"] = maxi(0, int(tool_item.get("condition", 100)) - 15)
		if int(tool_item["condition"]) <= 0:
			remove_inventory(tool, 1)
	emit_signal("state_changed")
	return {"ok": false, "text": "撬锁失败（%d 次），工具磨损。" % int(c["lock_attempts"])}

func unlock_container(container: Dictionary, key: Dictionary) -> Dictionary:
	if not bool(container.get("container_locked", false)):
		return {"ok": false, "text": "容器没有上锁。"}
	if not lock_key_matches(container, key):
		return {"ok": false, "text": "这张卡打不开这个容器。"}
	_finish_unlock(container)
	remove_inventory(String(key.get("def_id", "")), 1)
	emit_signal("state_changed")
	return {"ok": true, "text": "容器已解锁。"}

func _generate_loot(crate: Dictionary) -> void:
	var did := String(crate.get("def_id", ""))
	if not loot_tables.has(did):
		return
	var rolls: Array = loot_tables[did].get("rolls", [])
	for roll in rolls:
		var chance := float(roll.get("chance", 100))
		if rng.randf() * 100.0 >= chance:
			continue
		var it: Dictionary
		if roll.has("container"):
			it = make_item(String(roll.get("container", "")), 100, true, false)
			for fill in roll.get("fill", []):
				var fid := String(fill[0])
				for n in range(int(fill[1])):
					container_auto_add(it, make_item(fid, 100, true, false))
		else:
			var rid := String(roll.get("id", ""))
			if rid == "" or not items_def.has(rid):
				continue
			it = make_item(rid, int(roll.get("cond", 100)), true, false)
		if roll.has("credits"):
			var cr: Array = roll.get("credits", [0, 0])
			var amount := rng.randi_range(int(cr[0]), int(cr[1]))
			it["custom_base_value"] = amount
			it["credit_value"] = amount
		if not container_auto_add(crate, it):
			continue

func container_remove_child(parent: Dictionary, child_uid: int) -> Dictionary:
	var children: Array = parent.get("children", [])
	for i in range(children.size()):
		if int(children[i].get("uid", -1)) == child_uid:
			var ch: Dictionary = children[i]
			children.remove_at(i)
			parent["children"] = children
			return ch
	return {}

func container_move_child(parent: Dictionary, child_uid: int, x: int, y: int, rotated: bool = false) -> bool:
	var children: Array = parent.get("children", [])
	for ch in children:
		if int(ch.get("uid", -1)) == child_uid:
			if container_can_place(parent, ch, x, y, rotated, child_uid):
				ch["x"] = x
				ch["y"] = y
				ch["rotated"] = rotated
				return true
			return false
	return false

func _detach_from_tree(parent: Dictionary, uid: int) -> Dictionary:
	var children: Array = parent.get("children", [])
	for i in range(children.size()):
		if int(children[i].get("uid", -1)) == uid:
			var found: Dictionary = children[i]
			children.remove_at(i)
			parent["children"] = children
			return found
		var nested := _detach_from_tree(children[i], uid)
		if not nested.is_empty():
			return nested
	return {}

func detach_item(uid: int) -> Dictionary:
	for i in range(inventory.size()):
		if int(inventory[i].get("uid", -1)) == uid:
			var top: Dictionary = inventory[i]
			inventory.remove_at(i)
			return top
		var nested := _detach_from_tree(inventory[i], uid)
		if not nested.is_empty():
			return nested
	for i in range(display.size()):
		if int(display[i].get("uid", -1)) == uid:
			var topd: Dictionary = display[i]
			display.remove_at(i)
			return topd
		var nestedd := _detach_from_tree(display[i], uid)
		if not nestedd.is_empty():
			return nestedd
	for i in range(trash_items.size()):
		if int(trash_items[i].get("uid", -1)) == uid:
			var topt: Dictionary = trash_items[i]
			trash_items.remove_at(i)
			return topt
		var nestedt := _detach_from_tree(trash_items[i], uid)
		if not nestedt.is_empty():
			return nestedt
	if int(counter_item.get("uid", -1)) == uid:
		var topc := counter_item
		counter_item = {}
		return topc
	var nestedc := _detach_from_tree(counter_item, uid)
	if not nestedc.is_empty():
		return nestedc
	return {}

func place_item_in_player(uid: int, page: int, x: int, y: int) -> bool:
	var child := detach_item(uid)
	if child.is_empty():
		return false
	if can_place(child, x, y, bool(child.get("rotated", false)), uid, page):
		child["location"] = "backpack"
		child["page"] = page
		child["x"] = x
		child["y"] = y
		inventory.append(child)
		return true
	add_item(child)
	return false

func place_item_in_showcase(uid: int, x: int, y: int) -> bool:
	var child := detach_item(uid)
	if child.is_empty():
		return false
	if display_can_place(child, x, y, bool(child.get("rotated", false)), uid):
		child["location"] = "display"
		child["x"] = x
		child["y"] = y
		display.append(child)
		return true
	add_item(child)
	return false

func move_display_item(uid: int, x: int, y: int) -> bool:
	for it in display:
		if int(it.get("uid", -1)) == uid:
			if display_can_place(it, x, y, bool(it.get("rotated", false)), uid):
				it["x"] = x
				it["y"] = y
				return true
			return false
	return false

func move_item_to_container(uid: int, parent_uid: int, x: int = -1, y: int = -1) -> bool:
	var child := find_item(uid)
	var parent := find_item(parent_uid)
	if child.is_empty() or parent.is_empty() or not is_container_item(parent) or not container_can_accept(parent, child):
		return false
	child = detach_item(uid)
	if child.is_empty():
		return false
	var ok := false
	if x >= 0 and y >= 0:
		if container_can_place(parent, child, x, y, bool(child.get("rotated", false))):
			child["x"] = x
			child["y"] = y
			parent["children"].append(child)
			ok = true
	else:
		ok = container_auto_add(parent, child)
	if not ok:
		add_item(child)
	emit_signal("state_changed")
	return ok

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

func new_game(diff_id: String = "normal", mode: String = "mobile", start_type: String = "", perk_ids: Array = []) -> void:
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
	equipped_armor_uid = -1
	sec_crimes = {}
	sec_evidence = 0
	sec_state = 0
	sec_officer_pending = false
	sec_inspection_pending = false
	sec_inspection_personality = 0
	sec_inspection_fake = false
	sec_last_inspection_day = -99
	sec_bribe_tracker = 0
	client_cooldowns = {}
	sec_permit_revoke_pending = false
	sec_permit_revoke_levels = []
	active_permits = []
	poster_pulled = false
	starting_perk_id = ""
	starting_perk_chosen = false
	start_type_id = ""
	starting_perk_ids = []
	perk_flags = {}
	secret_admirer_days = 0
	charity_cooldown = 0
	discerning_cooldown = 0
	cartel_exit_available = false
	cartel_exit_uses = 0
	cartel_exited = false
	blackmail_next_day = 1
	afterhours_visits_left = 0
	afterhours_went_out = false
	went_out_last_night = false
	last_afterhour_outing_day = -1
	scav_attempts_used = 0
	afterhours_location = ""
	jackson_stock = []
	satchel_found = false
	kids_backpack_found = false
	player_max_hp = 100
	player_accuracy = 70
	player_reaction = 10
	thirst = 1000
	thirst_max = 1000
	wounds = 0
	wound_stable = true
	addiction_days = {"nicotine": 0, "alcohol": 0, "narcotic": 0}
	narcotic_relief = 999
	sentinel_days = 0
	sentinel_pool = 0
	luck = 0
	achievements_unlocked = {}
	ach_stats = {}
	faction_power = {"rev": 0, "bm": 0, "sec": 0, "civil_unrest": 0}
	operation_cooldowns = {}
	active_operations = []
	afterhour_mods = {}
	afterhour_today = ""
	space_mode = false
	space_ship = {}
	space_fuel = 0
	space_hull = 0
	space_max_hull = 100
	space_day = 1
	space_poi = {}
	space_scanned = []
	space_log = []
	space_at_station = false
	space_raid_rooms = []
	space_raid_index = 0
	store_water_ml = 20000
	next_combat_accuracy_bonus = 0
	run_stats = _new_run_stats()
	aug_presence = 0
	aug_introduced = false
	aug_next_spawn_day = 0
	hireling = {}
	hireling_expedition = {}
	gun_order = {}
	trash_items = []
	upgrade_cooldowns = {}
	evidence_removal_purchases = 0
	phase = "open"
	daily = {"sales": 0, "purchases": 0, "rent": 0, "fees": 0, "sold": 0, "bought": 0, "inspected": 0}
	uid_counter = 1
	pages_unlocked = 2
	max_pages_unlocked = 2
	pending_event = {}
	tutorial_done = false
	tutorial_step = 0
	if start_type == "" and _is_headless():
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
		for stock in [["scrap_metal", 3], ["printer_plastic", 3], ["common_chemical", 2], ["restricted_chemical", 1], ["nutrifruit_seed", 2], ["industrial_fish_feed", 2], ["water_jug", 1], ["meat_scrap", 2], ["nutrient_tablet", 1], ["red_beer", 2], ["plastic_bag", 2], ["debris_pile1", 2], ["printer_module_metal", 1], ["printer_chip_pistol", 1], ["flashlight", 1], ["water_test_strip", 3], ["plant_analyser", 1], ["backpack_small", 1], ["organ_heart", 1], ["water_tablet", 1], ["small_raw_meat", 2], ["nutrifruit", 1]]:
			if items_def.has(stock[0]):
				for i in range(int(stock[1])):
					var it2 := make_item(stock[0], 100, true, false)
					it2["known"] = true
					add_item(it2)
	owned_upgrades = {}
	profession_id = ""
	profession_chosen = false
	commissions = []
	procurement_orders = []
	story_seen = []
	story_flags = {}
	pending_story = ""
	story_queue = []
	scene_seen = []
	wanted_defeated = []
	combat_active = false
	combat_allies = []
	expedition_rooms = []
	expedition_room_index = 0
	market_modifiers = {"FOOD": 0, "MEDICAL": 0, "SUBSTANCE": 0, "MATERIAL": 0, "WEAPON": 0, "ARMOR": 0, "WATER": 0}
	ending_id = ""
	property_owned = false
	is_paying_mortgage = false
	mortgage_week_left = 0
	mortgage_total_weeks = 0
	mortgage_weekly_payment = 0
	mortgage_down_paid = 0
	mortgage_interest_taken = 0
	mortgage_offer_declined = false
	property_bought_at = 0
	property_bought_day = 0
	mortgage_due = 0
	_refresh_upgrades()
	machine_jobs = []
	machine_modules = {}
	machine_temps = {}
	machine_durability = {}
	machine_faults = {}
	machine_recipes = {}
	machine_active = {}
	machine_stock = {}
	machine_container_items = {}
	machine_io = {}
	future_customers = []
	_init_phone_clients()
	_init_commissary()
	machine_cash = {}
	machine_upgrades = {}
	machine_state = {}
	night_log = []
	next_day_power_bonus = 0
	attraction_bonus = 100
	bargain_bonus = 0
	security_alarm_active = false
	security_stop_rate = 0
	appraiser_level = 0
	appraisal_progress = 0.0
	appraisal_promotion_day = -1
	appraisal_promotion_declined = false
	appraisal_days_missed = 0
	appraisal_blacklist = []
	appraisal_introduced = true
	pending_promotion = false
	if start_type != "":
		apply_start_type(start_type)
		if not perk_ids.is_empty():
			apply_starting_perks(perk_ids)
	start_day()

func _stolen_heat_for_value(value: int) -> int:
	var heat := 0
	for row in security_defs.get("stolen_heat", []):
		if value >= int(row.get("min_value", 0)):
			heat = int(row.get("heat", 0))
	return heat

func _decay_stolen_item(it: Dictionary) -> void:
	if not bool(it.get("stolen", false)):
		return
	var heat := int(it.get("stolen_heat", 50))
	var level := int(get_item_def(String(it.get("def_id", ""))).get("contraband", 0))
	var dec := 18 - (level * 2)
	heat = maxi(0, heat - dec)
	if heat <= 0:
		it["stolen"] = false
		it["stolen_heat"] = 0
	else:
		it["stolen_heat"] = heat

func toggle_poster() -> bool:
	poster_pulled = not poster_pulled
	emit_signal("state_changed")
	return poster_pulled

func sec_crime_name(cid: String) -> String:
	return String(security_defs.get("crimes", {}).get(cid, cid))

func _sec_perk_def(perk_id: String) -> Dictionary:
	return security_defs.get("reputation_perks", {}).get(perk_id, {})

func sec_perk_unlocked(perk_id: String) -> bool:
	var def := _sec_perk_def(perk_id)
	if def.is_empty():
		return false
	var faction := String(def.get("faction", "security"))
	var value := int(rep.get(faction, 0))
	var threshold := int(def.get("threshold", 0))
	if int(def.get("type", 1)) < 0:
		return value <= threshold
	return value >= threshold

func sec_investigation_multiplier() -> float:
	var mult := 1.0
	if sec_perk_unlocked("SEC_TRUSTED"):
		mult *= 0.5
	if sec_perk_unlocked("SEC_PRIORITY"):
		mult *= float(_sec_perk_def("SEC_PRIORITY").get("investigation_mult", 1.5))
	elif sec_perk_unlocked("SEC_WATCHLIST"):
		mult *= float(_sec_perk_def("SEC_WATCHLIST").get("investigation_mult", 1.2))
	if sec_perk_unlocked("UL_PETITION"):
		mult *= float(_sec_perk_def("UL_PETITION").get("investigation_mult", 1.5))
	return mult

func sec_inspection_chance_multiplier() -> float:
	var mult := 1.0
	if sec_perk_unlocked("SEC_TRUSTED"):
		mult *= float(_sec_perk_def("SEC_TRUSTED").get("inspection_chance_mult", 0.5))
	if sec_perk_unlocked("SEC_THOROUGH_INSPECTION"):
		mult *= float(_sec_perk_def("SEC_THOROUGH_INSPECTION").get("inspection_chance_mult", 1.25))
	return mult

func sec_inspection_disabled() -> bool:
	return sec_perk_unlocked("SEC_VIP")

func sec_is_firearm(it: Dictionary) -> bool:
	for t in _item_tags(it):
		if String(t).to_lower() == "firearm":
			return true
	return false

func sec_has_permit(level: int) -> bool:
	for p in active_permits:
		if String(p.get("type", "")) == "FIREARM" and int(p.get("level", 0)) == level:
			return true
	return false

func sec_item_contraband_level(it: Dictionary) -> int:
	var level := int(get_item_def(String(it.get("def_id", ""))).get("contraband", 0))
	if level > 0 and sec_is_firearm(it) and sec_has_permit(level):
		return 0
	return level

func _sec_grant_permits() -> void:
	for p in security_defs.get("permits", []):
		var uid := String(p.get("id", ""))
		var level := int(p.get("level", 0))
		if not bool(owned_upgrades.get(uid, false)) or sec_has_permit(level):
			continue
		if int(rep.get("security", 0)) < int(p.get("threshold", 0)):
			continue
		active_permits.append({"type": "FIREARM", "level": level})
		var item_id := String(p.get("item", ""))
		if items_def.has(item_id) and inventory_count(item_id) == 0:
			var it := make_item(item_id, 100, true, false)
			it["known"] = true
			add_item(it)
		_add_night_log("治安部签发了 %s。" % String(get_item_def(item_id).get("name", item_id)))

func _sec_check_permit_revocation() -> void:
	if sec_permit_revoke_pending or sec_officer_pending or sec_inspection_pending:
		return
	var levels: Array = []
	for p in security_defs.get("permits", []):
		var level := int(p.get("level", 0))
		if sec_has_permit(level) and int(rep.get("security", 0)) < int(p.get("threshold", 0)):
			levels.append(level)
	if levels.is_empty():
		return
	sec_permit_revoke_pending = true
	sec_permit_revoke_levels = levels
	_add_night_log("治安部将吊销你的武器许可证。")

func _sec_collect_item_uids(it: Dictionary, item_id: String, uids: Array) -> void:
	if String(it.get("def_id", "")) == item_id:
		uids.append(int(it.get("uid", -1)))
	for ch in it.get("children", []):
		_sec_collect_item_uids(ch, item_id, uids)

func _sec_remove_permit_items(level: int) -> void:
	var item_id := "permit_gun_%d" % level
	var uids: Array = []
	for it in inventory:
		_sec_collect_item_uids(it, item_id, uids)
	for it in display:
		_sec_collect_item_uids(it, item_id, uids)
	for it in trash_items:
		_sec_collect_item_uids(it, item_id, uids)
	if not counter_item.is_empty():
		_sec_collect_item_uids(counter_item, item_id, uids)
	for uid in uids:
		detach_item(int(uid))

func revoke_permits() -> Dictionary:
	if not sec_permit_revoke_pending:
		return {"ok": false, "text": "没有需要吊销的许可证。"}
	var removed: Array = []
	for level in sec_permit_revoke_levels:
		var kept: Array = []
		for p in active_permits:
			if String(p.get("type", "")) == "FIREARM" and int(p.get("level", 0)) == int(level):
				continue
			kept.append(p)
		active_permits = kept
		_sec_remove_permit_items(int(level))
		removed.append(int(level))
	sec_permit_revoke_pending = false
	sec_permit_revoke_levels = []
	var parts: Array = []
	for level in removed:
		parts.append(str(level))
	emit_signal("state_changed")
	return {"ok": true, "text": "吊销的许可证等级：%s。" % "、".join(parts)}

func sec_trash_capacity() -> int:
	return int(security_defs.get("inspection", {}).get("trash_capacity", 12))

func sec_trash_free_slot() -> Vector2i:
	var cap := sec_trash_capacity()
	var used := {}
	for it in trash_items:
		used["%d,%d" % [int(it.get("x", -1)), int(it.get("y", -1))]] = true
	for i in range(cap):
		var col := i % 4
		var row := int(floor(float(i) / 4.0))
		var key := "%d,%d" % [col, row]
		if not used.has(key):
			return Vector2i(col, row)
	return Vector2i(-1, -1)

func move_to_trash(uid: int) -> bool:
	if trash_items.size() >= sec_trash_capacity():
		return false
	var it := detach_item(uid)
	if it.is_empty():
		return false
	var slot := sec_trash_free_slot()
	it["location"] = "trash"
	it["x"] = slot.x
	it["y"] = slot.y
	it["page"] = 0
	trash_items.append(it)
	_refresh_pages()
	emit_signal("state_changed")
	return true

func take_from_trash(uid: int) -> bool:
	for i in range(trash_items.size()):
		if int(trash_items[i].get("uid", -1)) == uid:
			var it: Dictionary = trash_items[i]
			trash_items.remove_at(i)
			it["location"] = "backpack"
			it["x"] = -1
			it["y"] = -1
			add_item(it)
			_refresh_pages()
			emit_signal("state_changed")
			return true
	return false

func commit_crime(cid: String, amount: int) -> void:
	if amount <= 0:
		return
	if starting_perk_active("perk_intimidating"):
		amount = int(round(float(amount) * 0.67))
	if starting_perk_active("perk_blabbermouth"):
		amount = int(round(float(amount) * 1.33))
	sec_crimes[cid] = int(sec_crimes.get(cid, 0)) + maxi(1, amount)

func sec_total_crime() -> int:
	var total := 0
	for k in sec_crimes.keys():
		total += int(sec_crimes[k])
	return total

func sec_biggest_crime() -> String:
	var best_id := ""
	var best_amount := 0
	for k in sec_crimes.keys():
		if int(sec_crimes[k]) > best_amount:
			best_amount = int(sec_crimes[k])
			best_id = String(k)
	if best_id == "":
		return "无"
	return "%s（%d₵）" % [sec_crime_name(best_id), best_amount]

func sec_projected_sentence() -> String:
	var total := sec_total_crime()
	if total < 100:
		return "不适用"
	if total < int(security_defs.get("thresholds", {}).get("fine_max", 300)):
		return "罚款"
	if total < int(security_defs.get("thresholds", {}).get("arrest_max", 1500)):
		return "监禁"
	return "处决"

func sec_case_officer() -> String:
	var total := sec_total_crime()
	if total <= 100:
		return "无"
	if total < 300:
		return "杰夫"
	if total < 850:
		return "瓦伦丁"
	if total < 1500:
		return "黄"
	if total < 2500:
		return "佩奇"
	return "卡尔森"

func sec_fixer_tier() -> int:
	if bool(owned_upgrades.get("WILD_FIXER3", false)):
		return 3
	if bool(owned_upgrades.get("WILD_FIXER2", false)):
		return 2
	if bool(owned_upgrades.get("WILD_FIXER", false)):
		return 1
	return 0

func _sec_apply_fixer() -> void:
	var tier := sec_fixer_tier()
	if tier <= 0:
		return
	var rows: Array = security_defs.get("fixer", [])
	var row: Dictionary = rows[clampi(tier - 1, 0, rows.size() - 1)]
	var pct := float(row.get("percent", 0))
	var flat := int(row.get("flat", 0))
	for k in sec_crimes.keys():
		var v := int(sec_crimes[k])
		v -= int(round(float(v) * pct / 100.0))
		v = maxi(0, v - flat)
		sec_crimes[k] = v
	if tier > 0:
		_add_night_log("怀尔德修复师处理了犯罪记录。")

func _sec_decay_all_stolen() -> void:
	for it in _iter_inventory_items():
		_decay_stolen_item(it)
	for it in display:
		_decay_stolen_item(it)
		for ch in it.get("children", []):
			for sub in _iter_inventory_items([ch]):
				_decay_stolen_item(sub)
	if not counter_item.is_empty():
		_decay_stolen_item(counter_item)
	for it in trash_items:
		_decay_stolen_item(it)
		for ch in it.get("children", []):
			for sub in _iter_inventory_items([ch]):
				_decay_stolen_item(sub)

func _sec_on_new_day() -> void:
	if _suppress_sec_tick:
		return
	var evidence_mult := 1.0
	var th: Dictionary = security_defs.get("thresholds", {})
	var decay := int(th.get("decay_per_day", 20))
	if sec_evidence < int(th.get("decay_evidence_cutoff", 80)):
		for k in sec_crimes.keys():
			sec_crimes[k] = maxi(0, int(sec_crimes[k]) - decay)
	_sec_apply_fixer()
	_sec_decay_all_stolen()
	var total := sec_total_crime()
	var gain := 0
	if total >= int(th.get("evidence_start", 100)):
		for row in security_defs.get("evidence_gain", []):
			if total >= int(row.get("min", 0)):
				gain = int(row.get("gain", 0))
	if gain > 0:
		gain = maxi(1, int(round(float(gain) * sec_investigation_multiplier())))
	sec_evidence = mini(100, sec_evidence + int(round(float(gain) * evidence_mult)))
	if sec_evidence >= 100 and total > 0 and not sec_officer_pending:
		sec_officer_pending = true
		sec_state = 1
		_add_night_log("治安部已掌握足够证据，探员将上门。")
	elif gain > 0:
		_add_night_log("治安调查推进：证据 %d/100。" % sec_evidence)
	_sec_grant_permits()
	_sec_check_permit_revocation()

func sec_commit_sale(item: Dictionary, price: int, faction: String) -> void:
	var mod := 1.0
	if faction == "blackmarket":
		mod = 0.5
	elif faction == "rev":
		mod = 1.0 / 3.0
	elif faction == "lower" and rep_perk_unlocked("LLTIGHTLIPS"):
		mod = 0.5
	var value := int(round(float(price) * mod))
	if bool(item.get("stolen", false)):
		var heat := int(item.get("stolen_heat", 50))
		commit_crime("FENCING", int(round(float(value) * float(heat) / 100.0)))
	var level := sec_item_contraband_level(item)
	if bool(item.get("stolen", false)) or level > 0:
		perk_flags["sold_dirty"] = true
	if level > 0:
		var def := get_item_def(String(item.get("def_id", "")))
		var cat := String(def.get("category", ""))
		var did := String(item.get("def_id", ""))
		var cid := "CONTRABAND_TRAFFICKING"
		if cat == "weapon":
			cid = "WEAPON_TRAFFICKING"
		elif cat in ["medical", "chem"]:
			cid = "DRUG_TRAFFICKING"
		elif cat == "document" and (did.contains("keycard") or did.contains("card")):
			cid = "CARD_TRAFFICKING"
		commit_crime(cid, value)
	if is_liquid_container(item):
		var ml := int(item.get("liquid_ml", 0))
		var purity := int(item.get("liquid_purity", 10000))
		if ml > 0 and purity < 5000:
			commit_crime("FRAUD", maxi(1, ml / 100))
			commit_crime("ENDANGERMENT", maxi(1, ml / 200))
	for f in item.get("features", []):
		if String(f.get("id", "")) == "impurity" and int(f.get("mod", 0)) < 0:
			commit_crime("FRAUD", 50)
			commit_crime("ENDANGERMENT", 30)
			break

func sec_resolve_officer(pay: bool) -> Dictionary:
	if not sec_officer_pending:
		return {"ok": false, "text": "没有治安官上门。"}
	var total := sec_total_crime()
	var fine := total
	if sec_evidence < 95 or total <= 0:
		add_rep("security", -20)
		sec_state = 0
		sec_officer_pending = false
		return {"ok": true, "text": "探员没有找到证据，骂骂咧咧地离开了（治安声望 -20）。"}
	if total < int(security_defs.get("thresholds", {}).get("fine_max", 300)):
		if pay:
			if cash < fine:
				phase = "gameover"
				ending_id = "arrest"
				sec_officer_pending = false
				emit_signal("state_changed")
				return {"ok": true, "text": "你付不起罚款，被逮捕了。"}
			cash -= fine
			add_rep("security", -10)
			sec_crimes.clear()
			sec_evidence = 0
			sec_state = 0
			sec_officer_pending = false
			emit_signal("state_changed")
			return {"ok": true, "text": "你支付了 %d₵ 罚款，案件了结。" % fine}
		phase = "gameover"
		ending_id = "arrest"
		sec_officer_pending = false
		emit_signal("state_changed")
		return {"ok": true, "text": "你拒绝付款，被逮捕了。"}
	if total < int(security_defs.get("thresholds", {}).get("arrest_max", 1500)):
		if bool(owned_upgrades.get("SEC_GRACE", false)):
			add_rep("security", -10)
			sec_evidence = 0
			sec_state = 0
			sec_officer_pending = false
			emit_signal("state_changed")
			return {"ok": true, "text": "人情生效：你被从轻发落，案件压下。"}
		phase = "gameover"
		ending_id = "arrest"
		sec_officer_pending = false
		emit_signal("state_changed")
		return {"ok": true, "text": "你被治安部逮捕入狱。"}
	phase = "gameover"
	ending_id = "execution"
	sec_officer_pending = false
	emit_signal("state_changed")
	return {"ok": true, "text": "你的罪行足够处决。"}

func _sec_scan_item(it: Dictionary, flagged: Array, from_hidden: bool = false) -> void:
	var level := sec_item_contraband_level(it)
	var stolen := bool(it.get("stolen", false))
	if stolen and level <= 0:
		if rng.randi_range(1, 100) > int(it.get("stolen_heat", 50)):
			stolen = false
	if level > 0 or stolen:
		if from_hidden:
			return
		flagged.append(it)
	if bool(it.get("container_locked", false)):
		return
	for ch in it.get("children", []):
		_sec_scan_item(ch, flagged, from_hidden)

func sec_inspection_candidates() -> Array:
	var flagged: Array = []
	for it in inventory:
		if it.get("location", "backpack") != "backpack":
			continue
		_sec_scan_item(it, flagged, int(it.get("page", 0)) == 2 and not poster_pulled)
	for it in display:
		_sec_scan_item(it, flagged, false)
	if not counter_item.is_empty():
		_sec_scan_item(counter_item, flagged, false)
	if sec_inspection_personality != 2:
		for it in trash_items:
			_sec_scan_item(it, flagged, false)
	return flagged

func sec_bribe_amount() -> int:
	var b: Dictionary = security_defs.get("bribe", {})
	var amt := int(b.get("base", 100)) + day * int(b.get("per_day", 2)) + int(rep.get("security", 0)) * int(b.get("per_sec_rep", -2))
	return clampi(amt, int(b.get("min", 40)), int(b.get("max", 400)))

func _sec_inspection_level(flagged: Array) -> int:
	var highest := 0
	var has_stolen := false
	for it in flagged:
		var level := sec_item_contraband_level(it)
		if level > highest:
			highest = level
		if bool(it.get("stolen", false)):
			has_stolen = true
	if highest == 0 and has_stolen:
		return -1
	if sec_perk_unlocked("SEC_CONTRABAND_TOLERANCE") and highest >= 1:
		return mini(4, highest + 1)
	return highest

func _sec_seize_flagged(flagged: Array) -> Array:
	var seize_low := sec_perk_unlocked("SEC_CONTRABAND_TOLERANCE")
	var seized: Array = []
	for it in flagged:
		var level := sec_item_contraband_level(it)
		if level == 1 and not seize_low:
			continue
		var uid := int(it.get("uid", -1))
		if uid >= 0 and not detach_item(uid).is_empty():
			seized.append({"name": item_display_name(it), "value": effective_value(it)})
	return seized

func _sec_contains_flags(it: Dictionary) -> bool:
	var level := sec_item_contraband_level(it)
	if level > 0 or bool(it.get("stolen", false)):
		return true
	for ch in it.get("children", []):
		if _sec_contains_flags(ch):
			return true
	return false

func _sec_has_concealed() -> bool:
	for it in inventory:
		if int(it.get("page", 0)) == 2 and _sec_contains_flags(it):
			return true
	for it in inventory:
		if bool(it.get("container_locked", false)) and _sec_contains_flags(it):
			return true
	for it in display:
		if bool(it.get("container_locked", false)) and _sec_contains_flags(it):
			return true
	return false

func sec_resolve_inspection(accept: bool, bribe: bool) -> Dictionary:
	if not sec_inspection_pending:
		return {"ok": false, "text": "没有检查正在进行。", "result": "none"}
	var fake := sec_inspection_fake
	var personality := sec_inspection_personality
	sec_inspection_pending = false
	sec_inspection_fake = false
	sec_last_inspection_day = day
	if bribe:
		if fake:
			return {"ok": false, "text": "他根本不是治安部的人。", "result": "none"}
		var amt := sec_bribe_amount()
		if cash < amt:
			return {"ok": false, "text": "现金不足，无法贿赂（需要 %d₵）。" % amt, "result": "none"}
		cash -= amt
		sec_bribe_tracker += amt
		emit_signal("state_changed")
		return {"ok": true, "text": "你塞了 %d₵，检查官收下后离开了。" % amt, "result": "bribed", "fine": amt, "fake": false, "personality": personality}
	if not accept:
		return {"ok": false, "text": "你必须接受检查。", "result": "none"}
	var flagged := sec_inspection_candidates()
	var luck := int(security_defs.get("inspection", {}).get("luck_save", 5))
	if not flagged.is_empty() and rng.randi_range(1, 100) <= luck:
		emit_signal("state_changed")
		return {"ok": true, "text": String(dialogue_lines.get("mech_inspection_luck_saved", "检查官今天心情不错，什么也没发现。")), "result": "lucky", "seized": [], "fake": fake, "personality": personality}
	var suspicion := 0
	for it in flagged:
		var level := sec_item_contraband_level(it)
		suspicion += 1 + level
		var basev := int(get_item_def(String(it.get("def_id", ""))).get("base_value", 0))
		if bool(it.get("stolen", false)) and basev > 17:
			if basev >= 140:
				suspicion += 4
			elif basev >= 85:
				suspicion += 3
			elif basev >= 50:
				suspicion += 2
			else:
				suspicion += 1
	suspicion = mini(suspicion, int(security_defs.get("thresholds", {}).get("suspicion_cap", 25)))
	var level := _sec_inspection_level(flagged)
	var fine := 0
	for it in flagged:
		fine += effective_value(it)
	if fake:
		suspicion = 0
		if level >= 3:
			level = 2
	var sec_grace := bool(owned_upgrades.get("SEC_GRACE", false))
	var outcome := "cleared"
	var text := String(dialogue_lines.get("dialog_sec_inspect_cleared_1", "你没有问题。"))
	var seized: Array = []
	var fine_paid := 0
	if level == 4:
		if sec_grace:
			outcome = "grace"
			text = String(dialogue_lines.get("dialog_sec_inspect_grace_1", "这次从轻发落。"))
			if not fake:
				add_rep("security", -suspicion)
		else:
			outcome = "arrest"
			phase = "gameover"
			ending_id = "arrest"
			text = String(dialogue_lines.get("dialog_sec_inspect_arrest_1", "你被逮捕了。"))
	elif level == 3:
		if not fake:
			add_rep("security", -suspicion)
		if cash >= fine:
			cash -= fine
			fine_paid = fine
			outcome = "fine"
			text = String(dialogue_lines.get("dialog_sec_inspect_fine_pay_player", "你支付了罚款。"))
		elif sec_grace:
			outcome = "grace"
			text = String(dialogue_lines.get("dialog_sec_inspect_grace_1", "这次从轻发落。"))
		else:
			outcome = "arrest"
			phase = "gameover"
			ending_id = "arrest"
			text = String(dialogue_lines.get("dialog_sec_inspect_fine_arrest", "你付不起罚款，被捕了。"))
	elif level == 2:
		if not fake:
			add_rep("security", -suspicion)
		outcome = "seizure"
		text = String(dialogue_lines.get("dialog_sec_inspect_seizure_1", "违禁品被没收了。"))
	elif level == -1:
		if not fake:
			add_rep("security", -suspicion)
		outcome = "seizure"
		text = String(dialogue_lines.get("dialog_sec_inspect_seizure_stolen_1", "赃物被没收了。"))
	elif level == 1:
		if not fake:
			add_rep("security", -suspicion)
		outcome = "warning"
		text = String(dialogue_lines.get("dialog_sec_inspect_warning_1", "这次只是警告。"))
	else:
		if not fake and personality != 2 and not _sec_has_concealed():
			add_rep("security", 3)
		text = String(dialogue_lines.get("dialog_sec_inspect_cleared_1", "你没有问题。"))
	if fake and sec_perk_unlocked("SEC_VIP"):
		text += " " + String(dialogue_lines.get("dialog_wanted9_vip_last_open", "那个，呃。打开货舱门，然后退一边去。快点，在我当班……我是说，在我下班之前。"))
	if outcome in ["seizure", "fine", "grace"] or level in [2, -1]:
		seized = _sec_seize_flagged(flagged)
	if outcome == "arrest":
		sec_officer_pending = false
	if not fake and (not seized.is_empty() or fine_paid > 0):
		var slip := make_item("sec_slip", 100, true, false)
		slip["custom_name"] = String(dialogue_lines.get("mech_inspection_slip_title", "检查报告"))
		var slip_lines: Array = []
		for s2 in seized:
			slip_lines.append("%s（%d₵）" % [String(s2.get("name", "")), int(s2.get("value", 0))])
		var slip_body := String(dialogue_lines.get("mech_inspection_slip_confiscated_many", "没收物品")) + "：" + "、".join(slip_lines)
		if fine_paid > 0:
			slip_body += "
罚款：%d₵" % fine_paid
		slip["custom_desc"] = slip_body
		add_item(slip)
	sec_state = 0
	emit_signal("state_changed")
	return {"ok": true, "text": text, "result": outcome, "fine": fine_paid, "seized": seized, "suspicion": suspicion, "level": level, "fake": fake, "personality": personality}

func _sec_contraband_on_hand() -> bool:
	var saved := sec_inspection_personality
	sec_inspection_personality = 0
	var items := sec_inspection_candidates()
	sec_inspection_personality = saved
	return not items.is_empty()

func _sec_reset_inspection_countdown() -> void:
	var total := sec_total_crime()
	var min_d := 6
	var max_d := 9
	if total >= 150:
		min_d = 3
		max_d = 5
	if total >= 300:
		min_d = 3
		max_d = 3
	if total >= 450:
		min_d = 2
		max_d = 3
	if total >= 600:
		min_d = 2
		max_d = 2
	if total >= 750:
		min_d = 1
		max_d = 2
	if sec_perk_unlocked("SEC_TRUSTED"):
		min_d += 2
		max_d += 4
	if sec_perk_unlocked("SEC_THOROUGH_INSPECTION"):
		min_d = maxi(1, min_d - 1)
		max_d = maxi(2, max_d - 1)
	sec_inspection_countdown = rng.randi_range(maxi(1, min_d), maxi(2, max_d))

func _sec_tick_inspection_countdown() -> bool:
	if _suppress_sec_tick:
		return false
	if sec_inspection_pending or sec_officer_pending or sec_permit_revoke_pending:
		return false
	sec_inspection_countdown -= 1
	if sec_inspection_countdown == 1 and sec_perk_unlocked("SEC_TRUSTED"):
		_add_night_log("治安部线人预警：盘查即将到来。")
	if sec_inspection_countdown > 0:
		return false
	var total := sec_total_crime()
	if total <= 0 and not _sec_contraband_on_hand():
		return false
	sec_inspection_pending = true
	sec_inspection_personality = 0
	sec_inspection_fake = false
	_sec_reset_inspection_countdown()
	emit_signal("inspection_arrived")
	return true

func _sec_maybe_start_inspection() -> void:
	if sec_inspection_pending or sec_officer_pending or sec_permit_revoke_pending:
		return
	if sec_inspection_disabled():
		return
	if day - sec_last_inspection_day < 3:
		return
	var total := sec_total_crime()
	if total <= 0 and not _sec_contraband_on_hand():
		return
	var cfg: Dictionary = security_defs.get("inspection", {})
	var chance := int(cfg.get("chance_base", 8)) + total / 50
	chance += int(faction_power.get("civil_unrest", 0)) / 10 - int(faction_power.get("sec", 0)) / 20
	chance = int(round(float(chance) * sec_inspection_chance_multiplier()))
	chance = clampi(chance, 0, int(cfg.get("chance_cap", 45)))
	if rng.randi_range(1, 100) > chance:
		return
	sec_inspection_pending = true
	_sec_reset_inspection_countdown()
	sec_inspection_fake = rng.randi_range(1, 100) <= int(cfg.get("fake_chance", 8))
	if sec_inspection_fake:
		sec_inspection_personality = 0
	else:
		var personality := 0
		if sec_bribe_tracker < 500:
			var roll := rng.randi_range(1, 100)
			var shady := int(cfg.get("shady_chance", 20))
			var lazy := int(cfg.get("lazy_chance", 20))
			if roll <= shady:
				personality = 1
			elif roll <= shady + lazy:
				personality = 2
		sec_inspection_personality = personality
	emit_signal("inspection_arrived")

func _marketplace_unlock() -> void:
	if marketplace_unlocked_day < 0:
		marketplace_unlocked_day = day
	_add_store_request_by_id("unique_georgio_tp")
	var ll := _pick_request_by_faction("lower", false)
	if not ll.is_empty():
		_add_store_request_def(ll)

func _store_request_defs() -> Array:
	return store_request_defs.get("requests", [])

func _store_request_def_by_id(rid: String) -> Dictionary:
	for r in _store_request_defs():
		if String(r.get("id", "")) == rid:
			return r
	return {}

func _pick_request_by_faction(faction: String, allow_unique: bool) -> Dictionary:
	var candidates: Array = []
	for r in _store_request_defs():
		if String(r.get("faction", "")) != faction:
			continue
		if bool(r.get("unique", false)) and not allow_unique:
			continue
		candidates.append(r)
	if candidates.is_empty():
		return {}
	return candidates[rng.randi_range(0, candidates.size() - 1)]

func _request_reward(def: Dictionary, item_id: String) -> int:
	if String(def.get("reward_mode", "")) == "unit":
		var unit := int(get_item_def(item_id).get("base_value", 10))
		var mn := float(def.get("mult_min", 1.0))
		var mx := float(def.get("mult_max", mn))
		var mult := rng.randf_range(mn, mx)
		return int(round(float(unit) * mult * int(def.get("count", 1))))
	return int(def.get("credits", 0))

func _add_store_request_by_id(rid: String) -> bool:
	return _add_store_request_def(_store_request_def_by_id(rid))

func _add_store_request_def(def: Dictionary) -> bool:
	if def.is_empty():
		return false
	var rid := String(def.get("id", ""))
	if rid == "":
		return false
	if bool(def.get("unique", false)) and store_request_seen.has(rid):
		return false
	for req in store_requests:
		if String(req.get("id", "")) == rid:
			return false
	var item_id := String(def.get("item", ""))
	if String(def.get("pool", "")) != "":
		var pool: Array = store_request_defs.get("pools", {}).get(String(def.get("pool", "")), [])
		if pool.is_empty():
			return false
		item_id = String(pool[rng.randi_range(0, pool.size() - 1)])
	if item_id == "":
		return false
	var req := {
		"id": rid, "faction": String(def.get("faction", "lower")),
		"item_id": item_id, "count": int(def.get("count", 1)),
		"days": int(def.get("days", 3)), "rep": int(def.get("rep", 0)),
		"credits": _request_reward(def, item_id),
		"custom_name": String(def.get("custom_name", "")),
		"unique": bool(def.get("unique", false)),
	}
	store_requests.append(req)
	if bool(req.get("unique", false)):
		store_request_seen.append(rid)
	emit_signal("state_changed")
	return true

func _decay_store_requests() -> void:
	for i in range(store_requests.size() - 1, -1, -1):
		store_requests[i]["days"] = int(store_requests[i].get("days", 0)) - 1
		if int(store_requests[i].get("days", 0)) <= 0:
			store_requests.remove_at(i)

func _gen_store_requests() -> void:
	if marketplace_unlocked_day < 0 or day <= 8:
		return
	if not bool(owned_upgrades.get("MARKETPLACE_REQUESTS", false)):
		return
	for sc in store_request_defs.get("scheduled", []):
		if day == marketplace_unlocked_day + int(sc.get("offset", 0)):
			_add_store_request_by_id(String(sc.get("id", "")))
	if rep_perk_unlocked("REV_REQUEST"):
		var weekday := day % 7
		if weekday == 5 and rng.randi_range(1, 100) <= 80:
			_add_store_request_def(_pick_request_by_faction("rev", false))
		elif weekday == 1 and starting_perk_active("perk_revolution_sympathizer"):
			_add_store_request_def(_pick_request_by_faction("rev", false))
	if rng.randi_range(1, 100) <= 8:
		var ul := _store_request_def_by_id("ul_rare_item") if rng.randf() < 0.75 else _store_request_def_by_id("ul_charity")
		_add_store_request_def(ul)
	if rng.randi_range(1, 100) <= 4:
		_add_store_request_def(_store_request_def_by_id("lower_worker_stayawake"))

func fill_store_request(rid: String) -> Dictionary:
	var req: Dictionary = {}
	var idx := -1
	for i in range(store_requests.size()):
		if String(store_requests[i].get("id", "")) == rid:
			req = store_requests[i]
			idx = i
			break
	if req.is_empty():
		return {"ok": false, "text": "没有这条请求。"}
	var item_id := String(req.get("item_id", ""))
	var count := int(req.get("count", 1))
	if inventory_count(item_id) < count:
		return {"ok": false, "text": "物品不足：需要 %s ×%d。" % [item_display_name({"def_id": item_id}), count]}
	remove_inventory(item_id, count)
	cash += int(req.get("credits", 0))
	add_rep(String(req.get("faction", "lower")), int(req.get("rep", 0)))
	run_stats["customers_served"] = int(run_stats.get("customers_served", 0)) + 1
	store_requests.remove_at(idx)
	emit_signal("state_changed")
	return {"ok": true, "text": "完成请求：%s ×%d，获得 %d₵。" % [item_display_name({"def_id": item_id}), count, int(req.get("credits", 0))]}

func start_day() -> void:
	_sec_on_new_day()
	_decay_store_requests()
	_gen_store_requests()
	_maybe_introduce_aug()
	if day >= 2 and not _suppress_sec_tick:
		_apply_afterhour_event()
		_roll_faction_operation()
	for opi in range(active_operations.size() - 1, -1, -1):
		if int(active_operations[opi].get("until", 0)) < day:
			active_operations.remove_at(opi)
	_refresh_upgrades()
	power = max_power + next_day_power_bonus
	if starting_perk_active("perk_makeshift_reactor") and (inventory_count("makeshift_reactor") > 0 or bool(perk_flags.get("makeshift_reactor", false))):
		power += 10
	next_day_power_bonus = 0
	bargain_bonus = 0
	phase = "open"
	store_water_ml = 20000
	afterhours_visits_left = 2 if starting_perk_active("perk_speedy") else 1
	afterhours_went_out = false
	afterhours_location = ""
	scav_attempts_used = 0
	current_index = -1
	current_customer = {}
	counter_item = {}
	daily = {"sales": 0, "purchases": 0, "rent": 0, "fees": 0, "sold": 0, "bought": 0, "inspected": 0}
	customers_today = []
	if not _suppress_sec_tick:
		for cid in client_cooldowns.keys():
			client_cooldowns[cid] = maxi(0, int(client_cooldowns[cid]) - 1)
		for type_id in market_modifiers.keys():
			var mv := int(market_modifiers[type_id])
			if mv > 0:
				market_modifiers[type_id] = maxi(0, mv - 10)
			elif mv < 0:
				market_modifiers[type_id] = mini(0, mv + 10)
	if rent_due == 1:
		customers_today.append(_gen_due_customer("rent"))
	if loan_due == 1:
		customers_today.append(_gen_due_customer("loan"))
	_gen_commissions()
	var due: Array = []
	var remain_future: Array = []
	for f in future_customers:
		if int(f.get("day", 0)) <= day:
			due.append(f)
		else:
			remain_future.append(f)
	future_customers = remain_future
	for f in due:
		customers_today.append(_gen_courier_customer(f))
	if day > 1:
		commissary_restock()
	_grant_dividends()
	_handle_cartel_weekly()
	_handle_welfare_program()
	_handle_secret_admirer()
	_handle_gambling_addiction()
	_handle_blackmail()
	_handle_sentinel_scalper()
	charity_cooldown = maxi(0, charity_cooldown - 1)
	discerning_cooldown = maxi(0, discerning_cooldown - 1)
	for t in special_customers.get("tier", []):
		if day == int(t.get("day", -1)):
			customers_today.append(_gen_special_customer(t))
	for r in special_customers.get("retired", []):
		if day <= 0 or day % 7 != int(r.get("weekday", -1)):
			continue
		if bool(owned_upgrades.get(String(r.get("upgrade", "")), false)):
			customers_today.append(_gen_special_customer(r))
	for u in special_customers.get("unique", []):
		if day < int(u.get("min_day", 0)):
			continue
		if String(u.get("id", "")) == "cartel_dealer" and cartel_exited:
			continue
		if int(u.get("chance", 100)) < 100 and rng.randi_range(1, 100) > int(u.get("chance", 100)):
			continue
		var day_mod: Array = u.get("day_mod", [])
		if not day_mod.is_empty() and not day_mod.has(day % 7):
			continue
		var req := String(u.get("requires", ""))
		if req != "" and not bool(owned_upgrades.get(req, false)):
			continue
		var req_perk := String(u.get("requires_perk", ""))
		if req_perk != "" and not rep_perk_unlocked(req_perk):
			continue
		customers_today.append(_gen_special_customer(u))
	for type_id in market_modifiers.keys():
		var mod := int(market_modifiers[type_id])
		if absi(mod) >= 30:
			var market_c := _market_customer(String(type_id), mod > 0)
			if not market_c.is_empty():
				customers_today.append(market_c)
	for order in procurement_orders:
		if int(order.get("due_day", 0)) <= day:
			customers_today.append(_gen_procurement_collect_customer(order))
	if day >= 2 and rng.randi_range(1, 100) <= int(procurement_defs.get("offer_chance", 10)):
		var procurement_offer := _gen_procurement_offer_customer()
		if not procurement_offer.is_empty():
			customers_today.append(procurement_offer)
	for sid in phone_clients.keys():
		var pc: Dictionary = phone_clients[sid]
		if String(pc.get("state", "")) == "Cooldown":
			pc["cooldown"] = maxi(0, int(pc.get("cooldown", 0)) - 1)
			if int(pc["cooldown"]) <= 0:
				pc["state"] = "Regular"
				_add_night_log("联系人可再次联系：%s。" % String(phone_contacts.get(sid, {}).get("name", sid)))
	var regular_start := customers_today.size()
	var count := rng.randi_range(3, 5)
	if attraction_bonus >= 110:
		count += 1
	count += customer_count_modifier()
	count = maxi(0, count)
	for i in range(count):
		customers_today.append(_gen_customer())
	var regular_count := customers_today.size() - regular_start
	if not hireling.is_empty() and String(hireling.get("status", "")) in ["complete", "injured"] and not bool(hireling.get("reported", false)):
		customers_today.append(_gen_hireling_return_customer())
		hireling["reported"] = true
	if regular_count > 0 and day >= 2 and rng.randf() < 0.18:
		var gun_c := _gen_gun_order_customer()
		if not gun_c.is_empty():
			customers_today[regular_start + rng.randi_range(0, regular_count - 1)] = gun_c
	if aug_introduced and day >= aug_next_spawn_day and regular_count > 0:
		customers_today[regular_start + rng.randi_range(0, regular_count - 1)] = _gen_aug_customer()
		aug_next_spawn_day = day + rng.randi_range(6, 7)
	if rng.randi_range(1, 100) <= 8 and not starting_perk_active("perk_known_snitch"):
		var candidates: Array = []
		for w in wanted:
			if not wanted_defeated.has(String(w.get("id", ""))):
				candidates.append(w)
		if not candidates.is_empty():
			var wv: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)]
			customers_today.append({
				"arche": {"faction": "lower", "name": String(wv.get("name", "可疑顾客"))},
				"intent": "wanted_visit", "wanted_id": String(wv.get("id", "")),
				"done": false, "line": "……你好像认错人了。",
			})
	if appraisal_introduced and regular_count > 0:
		if rng.randi_range(1, 100) <= appraisal_attraction_chance():
			var replace_index := regular_start + rng.randi_range(0, regular_count - 1)
			customers_today[replace_index] = _gen_appraisal_customer()
			appraisal_days_missed = 0
		else:
			appraisal_days_missed += 1
	_append_rep_perk_customers(customers_today)
	went_out_last_night = false
	if appraisal_promotion_day >= 0 and day >= appraisal_promotion_day:
		pending_promotion = true
	_queue_story_for_day()
	if not _sec_tick_inspection_countdown():
		_sec_maybe_start_inspection()
	emit_signal("state_changed")
	if sec_officer_pending:
		emit_signal("security_officer_arrived")
	if sec_inspection_pending:
		emit_signal("inspection_arrived")
	if sec_permit_revoke_pending:
		emit_signal("permit_revoke_arrived")
	if pending_story != "":
		emit_signal("story_available", pending_story)
	if auto_customer_flow:
		next_customer()
	else:
		current_index = -1
		current_customer = {}
		counter_item = {}
		phase = "open"
		emit_signal("customer_changed")

func store_attractiveness() -> int:
	var score := 250
	for uid in ["RENOVATION1", "RENOVATION2", "RENOVATION3"]:
		if bool(owned_upgrades.get(uid, false)):
			score += 150
	score += maxi(0, attraction_bonus - 100)
	return score

func client_attractiveness_tier() -> int:
	var thresholds: Array = client_pools.get("tier_thresholds", [400, 650])
	var score := store_attractiveness()
	if score >= int(thresholds[1]):
		return 2
	if score >= int(thresholds[0]):
		return 1
	return 0

func _client_pool_perk_active(perk_id: String) -> bool:
	return rep_perk_unlocked(perk_id)

func _pool_chance(pool: Dictionary) -> int:
	var chance := int(pool.get("chance_base", 0))
	var pf := String(pool.get("faction", ""))
	if pf in ["blackmarket", "rev", "security"]:
		chance += int(faction_power.get({"blackmarket": "bm", "rev": "rev", "security": "sec"}[pf], 0)) / 10
	if pf == "blackmarket" and rep_perk_unlocked("BM_SMALL_TIME_BROKER"):
		chance += 5
	for rule in pool.get("chance_rules", []):
		var applies := true
		if rule.has("perk") and not _client_pool_perk_active(String(rule.get("perk", ""))):
			applies = false
		if applies and rule.has("rep"):
			var value := int(rep.get(String(rule.get("rep", "")), 0))
			if rule.has("lt") and value >= int(rule.get("lt", 0)):
				applies = false
			if rule.has("gte") and value < int(rule.get("gte", 0)):
				applies = false
		if not applies:
			continue
		if rule.has("set"):
			chance = int(rule.get("set", 0))
			break
		if rule.has("add"):
			chance += int(rule.get("add", 0))
	return clampi(chance, 0, 100)

func _weighted_client_entry(entries: Array, tier: int) -> Dictionary:
	var candidates: Array = []
	var total := 0
	for entry in entries:
		var eid := String(entry.get("id", ""))
		if int(client_cooldowns.get(eid, 0)) > 0:
			continue
		var weights: Array = entry.get("weights", [1, 1, 1])
		var weight := int(weights[clampi(tier, 0, weights.size() - 1)])
		if weight <= 0:
			continue
		candidates.append({"entry": entry, "weight": weight})
		total += weight
	if candidates.is_empty() or total <= 0:
		return {}
	var pick := rng.randi_range(1, total)
	for c in candidates:
		pick -= int(c.get("weight", 0))
		if pick <= 0:
			return c.get("entry", {})
	return candidates[0].get("entry", {})

func _pick_client_pool_entry() -> Dictionary:
	var tier := client_attractiveness_tier()
	for pool in client_pools.get("faction_pools", []):
		if rng.randi_range(1, 100) > _pool_chance(pool):
			continue
		var entry := _weighted_client_entry(pool.get("entries", []), tier)
		if not entry.is_empty():
			return {"entry": entry, "faction": String(pool.get("faction", "lower"))}
	var general := _weighted_client_entry(client_pools.get("general", []), tier)
	if general.is_empty():
		return {}
	return {"entry": general, "faction": String(general.get("faction", "lower"))}

func _pool_dialogue_line(entry: Dictionary) -> String:
	var dialogue := String(entry.get("dialogue", entry.get("id", "")))
	var alias := {
		"scav_general": "scav", "scav_crate": "scav", "scav_inspectable": "scav",
		"stamp_seller": "scav", "broke_upper": "broke_upper",
	}
	var prefixes: Array = [dialogue]
	var alt := String(alias.get(dialogue, ""))
	if alt != "" and not prefixes.has(alt):
		prefixes.append(alt)
	var lines: Array = []
	for prefix in prefixes:
		for pattern in ["dialog_%s_greet_1", "dialog_%s_1", "dialog_%s_intro_1", "dialog_%s_offer_1", "dialog_%s_deal_1", "dialog_%s_2"]:
			var key := String(pattern) % String(prefix)
			var text := String(dialogue_lines.get(key, ""))
			if text != "" and not lines.has(text):
				lines.append(text)
		if lines.size() >= 2:
			break
	if lines.is_empty():
		return "……"
	return "\n".join(lines)

func diff_rule(key: String, fallback: Variant) -> Variant:
	var key_id := difficulty
	if key_id == "easy":
		key_id = "cozy"
	var rules: Dictionary = difficulty_rules.get(key_id, {})
	return rules.get(key, fallback)

func _pool_budget(entry: Dictionary, faction: String = "") -> int:
	var base := int(entry.get("budget_base", 0))
	var spread := int(entry.get("budget_rand", 0))
	var amount := base
	if spread > 0:
		amount += rng.randi_range(0, spread)
	amount += day * int(entry.get("budget_day", 0))
	if amount <= 0:
		return 0
	if faction == "":
		faction = String(entry.get("faction", ""))
	var mult := (1.0 + float(upgrade_total("budget")) / 100.0) * float(DIFFICULTY[difficulty]["budget"])
	mult *= float(attraction_bonus) / 100.0
	mult *= rep_budget_mult(faction)
	return maxi(1, int(round(float(amount) * mult)))

func _pool_stock_items(entry: Dictionary) -> Array:
	var rows: Array = entry.get("stock", [])
	var has_groups := false
	for row in rows:
		if row.has("group"):
			has_groups = true
			break
	var chosen_group := -1
	if has_groups:
		var groups: Array = []
		for row in rows:
			if row.has("group") and not groups.has(int(row.get("group", 0))):
				groups.append(int(row.get("group", 0)))
		for g in groups:
			var group_chance := 0.0
			for row in rows:
				if int(row.get("group", -1)) == int(g):
					group_chance = float(row.get("chance", 100))
					break
			if rng.randf() * 100.0 < group_chance:
				chosen_group = int(g)
				break
		if chosen_group < 0:
			for row in rows:
				if bool(row.get("fallback", false)):
					chosen_group = int(row.get("group", -1))
					break
	var out: Array = []
	for row in rows:
		if has_groups and row.has("group") and int(row.get("group", -1)) != chosen_group:
			continue
		if row.has("min_day") and day < int(row.get("min_day", 0)):
			continue
		if row.has("chance") and not row.has("group"):
			if rng.randf() * 100.0 >= float(row.get("chance", 100)):
				continue
		var count := int(row.get("count", 0))
		if count <= 0:
			var cmin := int(row.get("count_min", 1))
			var cmax := int(row.get("count_max", cmin))
			count = rng.randi_range(cmin, maxi(cmin, cmax))
		for bonus in row.get("day_bonus", []):
			if day >= int(bonus.get("day", 0)) and rng.randf() * 100.0 < float(bonus.get("chance", 100)):
				count += int(bonus.get("add", 0))
		var item_id := String(row.get("id", ""))
		for n in range(count):
			var it := make_item(item_id, rng.randi_range(70, 100), true, bool(row.get("stolen", false)))
			it["known"] = false
			out.append(it)
	return out

func _load_client_sprite_pools() -> void:
	client_sprite_pools = {}
	var dir := DirAccess.open("res://assets/customers")
	if dir == null:
		return
	for f in dir.get_files():
		if not f.ends_with(".png"):
			continue
		var base := f.get_basename()
		var cut := base.rfind("_")
		if cut <= 0:
			continue
		var prefix := base.substr(0, cut)
		if not client_sprite_pools.has(prefix):
			client_sprite_pools[prefix] = []
		client_sprite_pools[prefix].append(f)

func _random_client_sprite(faction: String) -> String:
	var pools: Array = []
	match faction:
		"lower": pools = ["maleLower", "femaleLower", "maleScav", "maleChef", "femaleChef", "maleFarmer", "femaleFarmer"]
		"upper": pools = ["maleUpper", "femaleUpper"]
		"security": pools = ["maleSec", "femaleSec", "maleSecOff", "femaleSecOff", "maleSecCorpo", "femaleSecCorpo"]
		"blackmarket": pools = ["maleBM", "femaleBM"]
		"rev": pools = ["maleRev", "femaleRev"]
		"cartel": pools = ["maleMerc", "femaleMerc", "maleUpper", "femaleUpper"]
		"church": pools = ["femaleMed", "maleMed", "femaleSci", "maleSci"]
		"tourist": pools = ["maleUpper", "femaleUpper"]
	var names: Array = []
	for p in pools:
		names.append_array(client_sprite_pools.get(String(p), []))
	if names.is_empty():
		for k in client_sprite_pools.keys():
			names.append_array(client_sprite_pools[k])
	if names.is_empty():
		return "maleUpper_0.png"
	return String(names[rng.randi_range(0, names.size() - 1)])

func _gen_pool_customer(entry: Dictionary, pool_faction: String) -> Dictionary:
	var intent := String(entry.get("intent", "buy"))
	if intent == "barter":
		return _gen_barter_customer(String(entry.get("barter_id", "")))
	var faction := String(entry.get("faction", pool_faction))
	if faction == "":
		faction = "lower"
	var name := loc("ClientName", String(entry.get("name_key", "")), String(entry.get("id", "")))
	var line := _pool_dialogue_line(entry)
	var base := {
		"pool_id": String(entry.get("id", "")),
		"arche": {"faction": faction, "name": name, "sprite": _random_client_sprite(faction)},
		"patience": 3,
		"done": false,
		"line": line,
		"cooldown": int(entry.get("cooldown", 0)),
	}
	if intent == "information":
		base["intent"] = "information"
		base["service_cost"] = int(entry.get("service_cost", 50))
		return base
	if intent == "buy":
		base["intent"] = "buy"
		base["want_tags"] = entry.get("buy_tags", []).duplicate()
		base["exclude_contraband"] = base["want_tags"].has("ALL_TYPE_EXCEPT_CONTRABAND")
		if base["exclude_contraband"]:
			base["want_tags"] = []
		base["discount_buy"] = int(entry.get("discount_buy", 0))
		base["variety"] = bool(entry.get("variety", false))
		base["budget"] = _pool_budget(entry, faction)
		base["offer"] = 0
		base["max_price"] = 0
		base["cooldown"] = int(entry.get("cooldown", 0))
		return base
	var stock := _pool_stock_items(entry)
	if String(entry.get("sell_mode", "counter")) == "wholesale":
		var discount_range: Array = entry.get("wholesale_discount", [-20, -20])
		var discounted := int(discount_range[0])
		if int(discount_range[1]) != int(discount_range[0]):
			discounted = rng.randi_range(int(discount_range[0]), int(discount_range[1]))
		base["intent"] = "wholesale"
		base["wholesale_name"] = name
		base["wholesale_supplier"] = ""
		base["wholesale_discount"] = discounted
		base["wholesale_stock"] = stock
		base["wholesale_free"] = false
		base["wholesale_done_key"] = ""
		base["sellbuy"] = intent == "sellbuy"
		if base["sellbuy"]:
			base["want_tags"] = entry.get("buy_tags", []).duplicate()
			base["budget"] = _pool_budget(entry)
			base["discount_buy"] = 0
		return base
	base["intent"] = "sell"
	base["items"] = stock
	base["item_index"] = 0
	var item: Dictionary = stock[0] if not stock.is_empty() else make_item(String(entry.get("id", "")), 100, true, false)
	item["known"] = false
	var val := market_value(item, false, faction)
	item["asking_price"] = int(round(val * rng.randf_range(1.15, 1.45)))
	item["min_price"] = int(round(val * rng.randf_range(0.7, 0.9)))
	base["item"] = item
	base["cooldown"] = int(entry.get("cooldown", 0))
	return base

func _buy_tag_match(it: Dictionary, wanted: Array) -> bool:
	if current_customer.get("want_ids", []).has(String(it.get("def_id", ""))):
		return true
	if wanted.is_empty():
		return true
	var tags := _item_tags(it)
	for w in wanted:
		var wl := String(w).to_lower()
		for t in tags:
			if String(t).to_lower() == wl:
				return true
	return false

func _gen_customer() -> Dictionary:
	var forced_tutorial := day == 1 and not tutorial_done and customers_today.is_empty()
	if not forced_tutorial and not client_pools.is_empty():
		var picked := _pick_client_pool_entry()
		if not picked.is_empty():
			var pooled := _gen_pool_customer(picked.get("entry", {}), String(picked.get("faction", "lower")))
			if not pooled.is_empty():
				var cd := int(pooled.get("cooldown", 0))
				var pid := String(pooled.get("pool_id", ""))
				if cd > 0 and pid != "":
					client_cooldowns[pid] = cd
				return pooled
	var arche: Dictionary = customer_defs[rng.randi_range(0, customer_defs.size() - 1)].duplicate(true)
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
		bmult *= rep_budget_mult(String(arche.get("faction", "lower")))
		c["budget"] = int(round(float(rng.randi_range(int(arche["budget"][0]), int(arche["budget"][1]))) * bmult))
		c["offer"] = 0
		c["max_price"] = 0
		c["line"] = arche.get("greet", "")
	return c

func _barter_intro_key(client_id: String) -> String:
	match client_id:
		"addict": return "dialog_barter_addict_1"
		"blood": return "dialog_barter_addict_blood_1"
		"scav": return "dialog_barter_scav_1"
		"chemist": return "dialog_barter_chemist_1"
		"food": return "dialog_barter_food_normal_1"
	return "dialog_barter_addict_gen_1"

func _gen_barter_customer(preferred_id: String = "") -> Dictionary:
	var ids: Array = []
	var total := 0
	for cid in barter_offer_defs.keys():
		var w := int(barter_offer_defs[cid].get("weight", 10))
		ids.append(cid)
		total += w
	var client_id := String(ids[0])
	if preferred_id != "" and barter_offer_defs.has(preferred_id):
		client_id = preferred_id
	else:
		var pick := rng.randi_range(1, maxi(1, total))
		for cid in ids:
			pick -= int(barter_offer_defs[cid].get("weight", 10))
			if pick <= 0:
				client_id = String(cid)
				break
	var def: Dictionary = barter_offer_defs[client_id]
	var arche: Dictionary = customer_defs[rng.randi_range(0, customer_defs.size() - 1)].duplicate(true)
	arche["faction"] = String(def.get("faction", arche.get("faction", "lower")))
	var offers_def: Array = def.get("offers", [])
	var chosen: Array = []
	if String(def.get("offer_mode", "")) == "one_of" and not offers_def.is_empty():
		chosen.append(offers_def[rng.randi_range(0, offers_def.size() - 1)])
	else:
		for o in offers_def:
			var chance := float(o.get("chance", 100))
			if chance >= 100.0 or rng.randf() * 100.0 < chance:
				chosen.append(o)
	if chosen.is_empty() and not offers_def.is_empty():
		chosen.append(offers_def[0])
	var sets: Array = []
	for o in chosen:
		var items: Array = []
		for pair in o.get("items", []):
			items.append({"id": String(pair[0]), "count": int(pair[1])})
		sets.append({"items": items})
	var intro := String(dialogue_lines.get(_barter_intro_key(client_id), ""))
	if intro == "":
		intro = "我想用这些东西和你换点东西。"
	var c := {
		"arche": arche,
		"intent": "barter",
		"patience": 3,
		"done": false,
		"line": intro,
		"barter_client": client_id,
		"barter_name": String(def.get("name", "顾客")),
		"barter_want": String(def.get("want_text", "拿取：物品")),
		"barter_conditions": def.get("conditions", []).duplicate(true),
		"barter_offers": sets,
		"barter_index": 0,
	}
	var key_map := {"addict_general": "addict_gen", "food": "food_normal", "blood": "addict_blood"}
	var base := String(key_map.get(client_id, client_id))
	c["barter_accept_key"] = "dialog_barter_%s_accept" % base
	c["barter_done_key"] = "dialog_barter_%s_done" % base
	return c

func _barter_item_matches(it: Dictionary, cond: Dictionary) -> bool:
	var did := String(it.get("def_id", ""))
	if cond.has("item") and String(cond.get("item", "")) != "" and did != String(cond.get("item", "")):
		return false
	if cond.has("tag") and String(cond.get("tag", "")) != "" and not _item_tags(it).has(String(cond.get("tag", ""))):
		return false
	for fid in cond.get("blacklist", []):
		for f in it.get("features", []):
			if String(f.get("id", "")) == String(fid):
				return false
	return true

func _iter_inventory_items(list: Array = []) -> Array:
	if list.is_empty():
		list = inventory
	var out: Array = []
	for it in list:
		out.append(it)
		if not it.get("children", []).is_empty():
			out.append_array(_iter_inventory_items(it.get("children", [])))
	return out

func barter_condition_label(cond: Dictionary) -> String:
	if cond.has("item") and String(cond.get("item", "")) != "":
		return String(get_item_def(String(cond.get("item", ""))).get("name", cond.get("item", "")))
	if cond.has("tag"):
		match String(cond.get("tag", "")):
			"FOOD": return "食物"
			"NARCOTIC": return "毒品"
		return String(cond.get("tag", ""))
	return "物品"

func barter_condition_count(cond: Dictionary) -> int:
	var total := 0
	for it in _iter_inventory_items():
		if _barter_item_matches(it, cond):
			total += int(it.get("unit_count", 1))
	return total

func barter_condition_satisfied(c: Dictionary) -> bool:
	var conds: Array = c.get("barter_conditions", [])
	if conds.is_empty():
		return false
	for cond in conds:
		if barter_condition_count(cond) < int(cond.get("count", 1)):
			return false
	return true

func barter_offer_items(c: Dictionary) -> Array:
	var offers: Array = c.get("barter_offers", [])
	if offers.is_empty():
		return []
	var idx := clampi(int(c.get("barter_index", 0)), 0, offers.size() - 1)
	return offers[idx].get("items", [])

func barter_offer_count(c: Dictionary) -> int:
	return int(c.get("barter_offers", []).size())

func cycle_barter_offer(offset: int) -> void:
	if current_customer.is_empty() or current_customer.get("intent") != "barter":
		return
	var count := barter_offer_count(current_customer)
	if count <= 1:
		return
	current_customer["barter_index"] = posmod(int(current_customer.get("barter_index", 0)) + offset, count)
	emit_signal("state_changed")

func _consume_barter_unit(cond: Dictionary) -> bool:
	for it in _iter_inventory_items():
		if not _barter_item_matches(it, cond):
			continue
		if int(it.get("unit_count", 1)) > 1:
			it["unit_count"] = int(it.get("unit_count", 1)) - 1
			return true
		if not detach_item(int(it.get("uid", -1))).is_empty():
			return true
	return false

func accept_barter() -> Dictionary:
	if current_customer.is_empty() or current_customer.get("intent") != "barter":
		return {"ok": false, "text": "当前顾客不是来以物易物的。"}
	if bool(current_customer.get("done", false)):
		return {"ok": false, "text": "这笔交换已经完成。"}
	if not barter_condition_satisfied(current_customer):
		return {"ok": false, "text": "背包里没有满足条件的物品。"}
	for cond in current_customer.get("barter_conditions", []):
		for n in range(int(cond.get("count", 1))):
			if not _consume_barter_unit(cond):
				return {"ok": false, "text": "所需物品不足。"}
	var got: Array = []
	for entry in barter_offer_items(current_customer):
		var did := String(entry.get("id", ""))
		if did == "" or not items_def.has(did):
			continue
		for n in range(int(entry.get("count", 1))):
			var it := make_item(did, 100, true, false)
			add_item(it)
			got.append(String(get_item_def(did).get("name", did)))
	current_customer["done"] = true
	current_customer["done_got"] = got
	current_customer["line"] = String(dialogue_lines.get("dialog_barter_accept", "成交。"))
	add_rep(String(current_customer.get("arche", {}).get("faction", "lower")), 1)
	emit_signal("state_changed")
	return {"ok": true, "text": "交换完成：+%s" % "、".join(got), "got": got}

func phone_card_contact(def_id: String) -> String:
	match def_id:
		"card_brewer": return "red_imp"
		"card_chem": return "chem"
		"card_pharma": return "pharma"
		"card_mining": return "mining"
		"card_rev": return "rev"
	return ""

func _grant_dividends() -> void:
	var wd := day % 7
	if bool(owned_upgrades.get("BREWER_SHAREHOLDER", false)) and wd == 4:
		add_item(_bundle_stock({"container": "beerCase", "fill": [["red_beer", 8]]}))
		_add_night_log("股东分红：1 箱整啤。")
	if bool(owned_upgrades.get("MINER_SHAREHOLDER", false)) and wd == 5:
		for i in range(6):
			add_item(make_item("common_ore", 100, true, false))
		_add_night_log("股东分红：6 份矿石。")
	if bool(owned_upgrades.get("CHEMIST_SHAREHOLDER", false)) and wd == 6:
		for i in range(8):
			add_item(make_item("dream_dust", 100, true, false))
		_add_night_log("股东分红：8 份街头级梦尘。")
	if bool(owned_upgrades.get("PHARMA_SHAREHOLDER", false)) and wd == 0:
		for i in range(5):
			add_item(make_item("pink_alt_injector", 100, true, false))
		_add_night_log("股东分红：5 支奥克西莫注射器。")

func _init_commissary() -> void:
	commissary_credit = 0
	commissary_stock = {}
	for it in commissary_defs:
		var did := String(it.get("id", ""))
		commissary_stock[did] = mini(int(it.get("max", 10)), int(it.get("restock", 1)) * 2)

func commissary_restock() -> void:
	var pct := int(afterhour_mods.get("commissary_restock_percent", 0))
	for it in commissary_defs:
		var did := String(it.get("id", ""))
		var add := int(it.get("restock", 1))
		add = int(round(float(add) * (100.0 + pct) / 100.0))
		commissary_stock[did] = mini(int(it.get("max", 10)), int(commissary_stock.get(did, 0)) + add)

func commissary_banned() -> bool:
	return starting_perk_active("perk_banned_commissary")

func commissary_redeem_stamps() -> Dictionary:
	if commissary_banned():
		return {"ok": false, "text": "你被配给站拒之门外，食品券无法使用。"}
	var credit := 0
	var count := 0
	for it in _iter_inventory_items().duplicate():
		if String(it.get("def_id", "")) != "food_stamp":
			continue
		credit += int(it.get("custom_base_value", get_item_def("food_stamp").get("base_value", 30)))
		detach_item(int(it.get("uid", -1)))
		count += 1
	commissary_credit += credit
	emit_signal("state_changed")
	return {"ok": count > 0, "text": "兑换 %d 张食品券，获得 %d 兑换券。" % [count, credit]}

func commissary_buy(id: String) -> Dictionary:
	if commissary_banned():
		return {"ok": false, "text": "你被配给站拒之门外。"}
	var def := {}
	for it in commissary_defs:
		if String(it.get("id", "")) == id:
			def = it
			break
	if def.is_empty():
		return {"ok": false, "text": "补给站没有这件商品。"}
	var price := int(def.get("price", 0))
	if int(commissary_stock.get(id, 0)) <= 0:
		return {"ok": false, "text": "这件商品缺货。"}
	if commissary_credit < price:
		return {"ok": false, "text": "兑换券不足：需要 %d。" % price}
	commissary_credit -= price
	commissary_stock[id] = int(commissary_stock.get(id, 0)) - 1
	add_item(make_item(id, 100, true, false))
	emit_signal("state_changed")
	return {"ok": true, "text": "兑换：%s。" % String(get_item_def(id).get("name", id))}

func _init_phone_clients() -> void:
	phone_clients = {}
	var name_keys := {"red_imp": "name_red_imp_rep", "chem": "name_ashish", "mining": "name_caulson", "pharma": "name_dale", "rev": "name_odin", "wild": "name_joe_assistant"}
	for sid in name_keys.keys():
		if phone_contacts.has(sid):
			var localized_name := loc("ClientName", String(name_keys[sid]), "")
			if localized_name != "":
				phone_contacts[sid]["name"] = localized_name
	for sid in phone_contacts.keys():
		var cfg: Dictionary = phone_contacts[sid]
		var kind := String(cfg.get("kind", ""))
		var state := "NotResponding"
		if kind in ["wild", "sec", "commissary"]:
			state = "Regular"
		phone_clients[sid] = {"state": state, "cooldown": 0, "amount_spent": 0, "dialed": false, "stock_type": 0}

func phone_client(sid: String) -> Dictionary:
	if not phone_clients.has(sid):
		return {}
	return phone_clients[sid]

func queue_future_customer(cid: String, supplier: String = "", stock_type: int = 0, days: int = 1, free: bool = false) -> void:
	future_customers.append({"customer": cid, "supplier": supplier, "stock_type": stock_type, "day": day + maxi(1, days), "free": free})

func _bundle_stock(entry: Dictionary) -> Dictionary:
	if entry.has("container"):
		var box := make_item(String(entry.get("container", "")), 100, true, false)
		for fill in entry.get("fill", []):
			var fid := String(fill[0])
			for n in range(int(fill[1])):
				container_auto_add(box, make_item(fid, 100, true, false))
		return box
	return make_item(String(entry.get("id", "")), 100, true, false)

func _gen_courier_customer(f: Dictionary) -> Dictionary:
	if String(f.get("customer", "")) == "wanted":
		return {
			"arche": {"faction": "security", "name": "奥丁的手下"},
			"intent": "wanted", "wanted_id": "w_odin", "done": false,
			"line": "奥丁的人找上门了。",
		}
	var sid := String(f.get("supplier", ""))
	var cfg: Dictionary = phone_contacts.get(sid, {})
	var free := bool(f.get("free", false))
	var st := int(f.get("stock_type", 0))
	var key := "free" if free else ("stock%d" % st)
	var stock_def: Array = cfg.get(key, [])
	var stock: Array = []
	for entry in stock_def:
		for n in range(int(entry.get("count", 1))):
			stock.append(_bundle_stock(entry))
	var discount := int(cfg.get("discount", -20))
	var sh_id := String(cfg.get("shareholder", ""))
	if sh_id != "" and bool(owned_upgrades.get(sh_id, false)):
		discount -= 15
	var prefix := String(cfg.get("dialogue", "red_imp"))
	var line1 := String(dialogue_lines.get("dialog_courrier_%s_1" % prefix, ""))
	if line1 == "":
		line1 = String(dialogue_lines.get("dialog_courrier_beer_1", ""))
	var line2 := String(dialogue_lines.get("dialog_courrier_%s_2" % prefix, ""))
	var name := String(cfg.get("name", "快递员"))
	if sid == "red_imp":
		name = "红魔酿酒厂快递员"
	elif sid == "mining":
		name = "GP采矿合作社快递员"
	var c := {
		"arche": {"faction": "lower", "name": name},
		"intent": "wholesale",
		"patience": 3,
		"done": false,
		"line": line1 + ("\n" + line2 if line2 != "" else ""),
		"wholesale_name": name,
		"wholesale_supplier": sid,
		"wholesale_discount": discount,
		"wholesale_stock": stock,
		"wholesale_free": free,
		"wholesale_done_key": "dialog_courrier_%s_done" % prefix,
	}
	return c

func wholesale_total(c: Dictionary) -> int:
	if bool(c.get("wholesale_free", false)):
		return 0
	var base := 0
	for it in c.get("wholesale_stock", []):
		base += effective_value(it)
	return maxi(0, int(round(float(base) * (1.0 + float(c.get("wholesale_discount", -20)) / 100.0))))

func buy_wholesale() -> Dictionary:
	if current_customer.is_empty() or current_customer.get("intent") != "wholesale":
		return {"ok": false, "text": "当前不是批发顾客。"}
	if bool(current_customer.get("done", false)):
		return {"ok": false, "text": "这批货已经处理过了。"}
	var total := wholesale_total(current_customer)
	if not bool(current_customer.get("wholesale_free", false)) and cash < total:
		return {"ok": false, "text": "现金不足：需要 %d₵。" % total}
	var got: Array = []
	for it in current_customer.get("wholesale_stock", []):
		it["location"] = "backpack"
		add_item(it)
		got.append(item_display_name(it))
	if not bool(current_customer.get("wholesale_free", false)):
		cash -= total
	var sid := String(current_customer.get("wholesale_supplier", ""))
	if sid != "" and phone_clients.has(sid):
		phone_clients[sid]["amount_spent"] = int(phone_clients[sid].get("amount_spent", 0)) + total
	var sellbuy := bool(current_customer.get("sellbuy", false)) and int(current_customer.get("budget", 0)) > 0
	if sellbuy:
		current_customer["intent"] = "buy"
		current_customer["done"] = false
		current_customer["line"] = "货我收下了。你这里还有什么适合我的？"
	else:
		current_customer["done"] = true
		current_customer["done_total"] = total
		current_customer["line"] = String(dialogue_lines.get(String(current_customer.get("wholesale_done_key", "")), "验货完毕，合作愉快。"))
	emit_signal("state_changed")
	return {"ok": true, "text": "买下 %d 件，支付 %d₵。" % [got.size(), total], "got": got, "next_intent": "buy" if sellbuy else ""}

func phone_contact_by_number(num: String) -> String:
	for sid in phone_contacts.keys():
		if String(phone_contacts[sid].get("number", "")) == num:
			return String(sid)
	return ""

func phone_number_of(sid: String) -> String:
	return String(phone_contacts.get(sid, {}).get("number", ""))

func phone_status_text(sid: String) -> String:
	var pc := phone_client(sid)
	match String(pc.get("state", "")):
		"Regular": return "可联系"
		"Cooldown": return "冷却 %d 天" % int(pc.get("cooldown", 0))
		"Introduction": return "新联系人"
		"NotResponding": return "无人接听"
	return "未知"

func phone_book_contacts() -> Array:
	var out: Array = []
	for sid in phone_contacts.keys():
		var pc := phone_client(sid)
		if not bool(pc.get("dialed", false)):
			continue
		if String(pc.get("state", "")) not in ["Regular", "Cooldown", "Introduction"]:
			continue
		out.append({"id": sid, "name": String(phone_contacts[sid].get("name", sid)), "status": phone_status_text(sid)})
	return out

func _phone_lines(keys: Array, args: Array = []) -> Array:
	var out: Array = []
	for k in keys:
		var t := String(dialogue_lines.get(String(k), ""))
		if t == "":
			continue
		for i in range(args.size()):
			t = t.replace("{%d}" % i, str(args[i]))
		out.append(t)
	return out

func phone_use_service(sid: String) -> void:
	var cfg: Dictionary = phone_contacts.get(sid, {})
	var pc := phone_client(sid)
	pc["state"] = "Cooldown"
	pc["cooldown"] = int(cfg.get("cooldown", 0))
	pc["dialed"] = true

func phone_order(sid: String, stock_type: int) -> Dictionary:
	var cfg: Dictionary = phone_contacts.get(sid, {})
	var pc := phone_client(sid)
	if String(pc.get("state", "")) != "Regular":
		return {"ok": false, "text": "这个联系人现在无法接单。"}
	if stock_type == 1 and int(pc.get("amount_spent", 0)) < int(cfg.get("unlock_spent", 400)):
		return {"ok": false, "text": "消费额不足：%d/%d。" % [int(pc.get("amount_spent", 0)), int(cfg.get("unlock_spent", 400))]}
	pc["stock_type"] = stock_type
	var days: Array = cfg.get("delivery_days", [1, 2])
	var d := int(days[clampi(stock_type, 0, days.size() - 1)])
	queue_future_customer("courrier", sid, stock_type, d, false)
	phone_use_service(sid)
	emit_signal("state_changed")
	return {"ok": true, "text": "订单已下：%d 天后送达。" % d}

func phone_finish_intro(sid: String) -> void:
	phone_use_service(sid)
	queue_future_customer("courrierFree", sid, 0, 1, true)
	emit_signal("state_changed")

func phone_dial(sid: String) -> Dictionary:
	var cfg: Dictionary = phone_contacts.get(sid, {})
	if cfg.is_empty():
		return {"ok": false, "text": "号码不存在。"}
	var pc := phone_client(sid)
	pc["dialed"] = true
	var kind := String(cfg.get("kind", ""))
	var name := String(cfg.get("name", sid))
	if kind == "supplier" and rep_perk_unlocked("LLAVOIDED"):
		emit_signal("state_changed")
		return {"ok": false, "text": "所有供货商都拒接你的电话。"}
	match kind:
		"supplier":
			var state := String(pc.get("state", ""))
			if state == "Introduction":
				var intro_keys: Array = []
				for i in range(1, 10):
					var k := "%s_intro%d" % [String(cfg.get("dialogue", "")), i]
					match String(cfg.get("dialogue", "")):
						"red_imp": k = "red_imp_rep_intro%d" % i
						"chem": k = "ashish_intro%d" % i
						"mining": k = "caulson_intro%d" % i
						"pharma": k = "dale_intro%d" % i
					intro_keys.append(k)
				var pages := _phone_lines(intro_keys)
				return {"ok": true, "speaker": name, "pages": pages, "choices": [{"id": "intro_end", "label": "结束通话"}]}
			elif state == "Regular":
				var prefix := String(cfg.get("dialogue", ""))
				var regular_keys: Array = []
				match prefix:
					"red_imp": regular_keys = ["red_imp_rep2"]
					"chem": regular_keys = ["ashish_regular1", "ashish_regular2"]
					"mining": regular_keys = ["caulson_regular1", "caulson_regular2"]
					"pharma": regular_keys = ["dale_regular1", "dale_regular2", "dale_regular3"]
				var pages2 := _phone_lines(regular_keys)
				var choices: Array = []
				var qty := [8, 16]
				if prefix == "mining":
					qty = [6, 12]
				elif prefix == "pharma":
					qty = [5, 10]
				var order_keys := ["%s_order1" % prefix, "%s_order2" % prefix]
				var days: Array = cfg.get("delivery_days", [1, 2])
				choices.append({"id": "order0", "label": _phone_lines([order_keys[0]], [qty[0], days[0]])[0] if not _phone_lines([order_keys[0]]).is_empty() else "下首单"})
				if int(pc.get("amount_spent", 0)) >= int(cfg.get("unlock_spent", 400)):
					if not _phone_lines([order_keys[1]]).is_empty():
						choices.append({"id": "order1", "label": _phone_lines([order_keys[1]], [qty[1], days[1]])[0]})
				choices.append({"id": "end_call", "label": String(dialogue_lines.get("end_call", "结束通话"))})
				return {"ok": true, "speaker": name, "pages": pages2, "choices": choices}
			else:
				var cd_keys: Array = []
				match String(cfg.get("dialogue", "")):
					"red_imp": cd_keys = ["red_imp_out1", "red_imp_out2", "red_imp_out3"]
					"chem": cd_keys = ["ashish_cooldown1", "ashish_cooldown2", "ashish_cooldown3"]
					"mining": cd_keys = ["caulson_cooldown2", "caulson_cooldown5"]
					"pharma": cd_keys = ["dale_cooldown1", "dale_cooldown3"]
				var pages3 := _phone_lines(cd_keys, [int(pc.get("cooldown", 0))])
				if pages3.is_empty():
					pages3 = [String(dialogue_lines.get("generic_cooldown", "现在不太方便，过几天再打吧。"))]
				return {"ok": true, "speaker": name, "pages": pages3, "choices": [{"id": "end_call", "label": String(dialogue_lines.get("end_call", "结束通话"))}]}
		"wild":
			return {"ok": true, "speaker": name, "pages": _phone_lines(["wild1", "wild2"]), "choices": [
				{"id": "wild_network", "label": String(dialogue_lines.get("browse_wild_service", "浏览怀尔德网络"))},
				{"id": "end_call", "label": String(dialogue_lines.get("end_call", "结束通话"))}]}
		"sec":
			return {"ok": true, "speaker": name, "pages": ["这里是治安部。有什么可以帮您？"], "choices": [
				{"id": "report", "label": "举报通缉犯"},
				{"id": "end_call", "label": String(dialogue_lines.get("end_call", "结束通话"))}]}
		"commissary":
			return {"ok": true, "speaker": name, "pages": ["这里是补给站自动电话系统。"], "choices": [
				{"id": "open_commissary", "label": "前往补给站"},
				{"id": "end_call", "label": String(dialogue_lines.get("end_call", "结束通话"))}]}
		"rev":
			if String(pc.get("state", "")) == "Cooldown":
				return {"ok": true, "speaker": name, "pages": [String(dialogue_lines.get("generic_cooldown", "现在不太方便，过几天再打吧。"))], "choices": [{"id": "end_call", "label": String(dialogue_lines.get("end_call", "结束通话"))}]}
			return {"ok": true, "speaker": name, "pages": _phone_lines(["odin_regular1"]), "choices": [
				{"id": "rev_book", "label": String(dialogue_lines.get("odin_yes", "是我"))},
				{"id": "end_call", "label": String(dialogue_lines.get("end_call", "结束通话"))}]}
	return {"ok": false, "text": "无人接听。"}

func phone_choose(sid: String, choice: String) -> Dictionary:
	var cfg: Dictionary = phone_contacts.get(sid, {})
	var name := String(cfg.get("name", sid))
	match choice:
		"intro_end":
			phone_finish_intro(sid)
			return {"close": true, "toast": "联系人已加入电话簿，明早会有免费快递。"}
		"order0", "order1":
			var st := 0 if choice == "order0" else 1
			var res := phone_order(sid, st)
			if not bool(res.get("ok", false)):
				return {"close": true, "toast": String(res.get("text", ""))}
			var ready_keys: Array = []
			match String(cfg.get("dialogue", "")):
				"red_imp": ready_keys = ["red_imp_rep4"]
				"chem": ready_keys = ["ashish_ready"]
				"mining": ready_keys = ["caulson_ready"]
				"pharma": ready_keys = ["dale_ready"]
			return {"close": true, "toast": String(res.get("text", "")), "after_text": "、".join(_phone_lines(ready_keys))}
		"rev_book":
			phone_use_service("rev")
			queue_future_customer("wanted", "rev", 0, 2, false)
			return {"close": true, "toast": "奥丁会在 2 天后派人上门。"}
		"report":
			var report_res := report_wanted("")
			return {"close": true, "toast": String(report_res.get("text", ""))}
		"wild_network":
			return {"close": true, "open": "network"}
		"open_commissary":
			return {"close": true, "open": "commissary"}
	return {"close": true}

func phone_unlock_supplier(upgrade_id: String) -> void:
	var sid := ""
	match upgrade_id:
		"BREWER": sid = "red_imp"
		"CHEMIST": sid = "chem"
		"PHARMA": sid = "pharma"
		"MINER": sid = "mining"
	if sid == "" or not phone_clients.has(sid):
		return
	var pc: Dictionary = phone_clients[sid]
	if String(pc.get("state", "")) == "NotResponding":
		pc["state"] = "Introduction"
		_add_night_log("新联系人：%s（%s）。" % [String(phone_contacts[sid].get("name", sid)), phone_number_of(sid)])

func summon_customer() -> Dictionary:
	if phase != "open" and not current_customer.is_empty():
		return {"ok": false, "text": "当前还有顾客。"}
	if current_index + 1 >= customers_today.size():
		return {"ok": false, "text": "今天没有更多顾客了。"}
	next_customer()
	return {"ok": true, "text": "顾客上门。"}

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
	counter_item = current_customer.get("item", {}) if current_customer.get("intent") in ["sell", "appraise"] else {}
	if String(current_customer.get("intent", "")) == "wanted":
		var wid := String(current_customer.get("wanted_id", ""))
		var w := wanted_def(wid)
		current_customer = {}
		counter_item = {}
		if not w.is_empty():
			start_combat(String(w.get("enemy", "enforcer")), "security", wid)
		return
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

func item_weight(it: Dictionary) -> int:
	var def := get_item_def(String(it.get("def_id", "")))
	var unit := int(it.get("weight_g", def.get("weight_g", 0)))
	var total := unit * int(it.get("unit_count", 1))
	for ch in it.get("children", []):
		total += item_weight(ch)
	return total

func effective_value(item: Dictionary) -> int:
	if item.is_empty():
		return 0
	var def := get_item_def(item.get("def_id", ""))
	var base := float(def.get("base_value", 10))
	if item.has("custom_base_value"):
		base = float(item.get("custom_base_value", base))
	var cond := clampf(float(item.get("condition", 100)) / 100.0, 0.2, 1.0)
	var auth := 1.0 if item.get("authentic", true) else 0.35
	var stolen := 0.9 if item.get("stolen", false) else 1.0
	var contra := 1.0
	if not bool(item.get("contraband_cleared", false)):
		contra = 1.0 + float(def.get("contraband", 0)) * 0.12
	var feat_mod := 0
	var final_mult := 1.0
	for f in item.get("features", []):
		feat_mod += int(f.get("mod", 0))
	for f in item.get("feature_list", []):
		var mod := int(f.get("real_mod", 0)) if bool(f.get("exposed", false)) else int(f.get("public_mod", 0))
		if String(f.get("stage", "innate")) == "final":
			final_mult *= maxf(0.0, 1.0 + float(mod) / 100.0)
		else:
			feat_mod += mod
	var feat_mult := clampf(1.0 + float(feat_mod) / 100.0, 0.2, 3.0) * final_mult
	var total := float(round(base * cond * auth * stolen * contra * feat_mult))
	for ch in item.get("children", []):
		total += float(effective_value(ch))
	return int(round(total))

func market_modifier_for_item(item: Dictionary) -> int:
	var total := 0
	var seen := {}
	for t in _item_tags(item):
		var key := String(t).to_upper()
		if market_modifiers.has(key) and not seen.has(key):
			seen[key] = true
			total += int(market_modifiers[key])
	return total

func market_value(item: Dictionary, for_sale: bool = false, faction: String = "") -> int:
	var v := float(effective_value(item))
	var def2 := get_item_def(item.get("def_id", ""))
	v *= 1.0 + float(market_modifier_for_item(item)) / 100.0
	if for_sale:
		v *= 1.0 + (float(diff_rule("retail_markup", RETAIL_MARKUP)) + float(upgrade_total("retail"))) / 100.0
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
	var match_tag := _buy_tag_match(it, current_customer.get("want_tags", []))
	var factor := 1.0 if match_tag else 0.55
	if bool(current_customer.get("exclude_contraband", false)) and sec_item_contraband_level(it) > 0:
		return false
	var arche: Dictionary = current_customer["arche"]
	var faction := String(arche.get("faction", "lower"))
	if faction == "lower" and rep_perk_unlocked("LLDISTRUSTED") and sec_item_contraband_level(it) > 0:
		return false
	if faction == "blackmarket" and rep_perk_unlocked("BM_DISTRUSTED") and sec_item_contraband_level(it) > 0:
		return false
	factor *= 1.0 - float(current_customer.get("discount_buy", 0)) / 100.0
	if starting_perk_active("perk_awful_negotiator"):
		factor *= 0.95
	if faction == "upper" and rep_perk_unlocked("UL_TIPS"):
		factor *= 1.15
	var val := market_value(it, true, faction)
	var pm := float(arche.get("price_mod", 1.0)) * (float(attraction_bonus) / 100.0)
	var bargain := 1.0 + float(bargain_bonus) / 100.0
	var ah_price := 1.0 + float(afterhour_mods.get("price_mod", 0)) / 100.0
	var withdraw := 1.0 + addiction_price_mod()
	current_customer["offer"] = int(round(val * factor * pm * bargain * withdraw * ah_price * rng.randf_range(0.75, 0.95)))
	current_customer["max_price"] = int(min(float(current_customer["budget"]), val * factor * pm * bargain * 1.05))
	emit_signal("state_changed")
	return true

func showcase_size() -> Array:
	var w := SHOWCASE_W
	var h := SHOWCASE_H
	if bool(owned_upgrades.get("SHOWCASE_I", false)):
		w += 1
		h += 1
	if bool(owned_upgrades.get("SHOWCASE_II", false)):
		w += 1
		h += 1
	return [w, h]

func display_can_place(it: Dictionary, x: int, y: int, rotated: bool, ignore_uid: int = -1) -> bool:
	var shape: Array = get_item_def(String(it.get("def_id", ""))).get("shape", [1, 1])
	var w: int = int(shape[1]) if rotated else int(shape[0])
	var h: int = int(shape[0]) if rotated else int(shape[1])
	var size := showcase_size()
	if x < 0 or y < 0 or x + w > int(size[0]) or y + h > int(size[1]):
		return false
	var mask := item_mask_cells(it, 1 if rotated else 0)
	var test := {}
	for dy in range(h):
		for dx in range(w):
			if bool(mask[dy * w + dx]):
				test[Vector2i(x + dx, y + dy)] = true
	for other in display:
		if int(other.get("uid", -1)) == ignore_uid:
			continue
		for c in item_cells(other):
			if test.has(c):
				return false
	return true

func display_auto_place(it: Dictionary) -> bool:
	var size := showcase_size()
	for y in range(int(size[1])):
		for x in range(int(size[0])):
			for rot in [false, true]:
				if display_can_place(it, x, y, rot, int(it.get("uid", -1))):
					it["x"] = x
					it["y"] = y
					it["rotated"] = rot
					return true
	return false

func add_to_display(uid: int) -> bool:
	var idx := -1
	for i in range(inventory.size()):
		if int(inventory[i]["uid"]) == uid:
			idx = i
			break
	if idx < 0:
		return false
	var it: Dictionary = inventory[idx]
	it["location"] = "display"
	if not display_auto_place(it):
		it["location"] = "backpack"
		return false
	inventory.remove_at(idx)
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

func _advance_sell_item() -> bool:
	var items: Array = current_customer.get("items", [])
	var next_index := int(current_customer.get("item_index", 0)) + 1
	if next_index < items.size():
		current_customer["item_index"] = next_index
		current_customer["item"] = items[next_index]
		counter_item = items[next_index]
		current_customer["patience"] = 3
		return true
	complete_customer(true)
	return false

func skip_current_sell_item() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "sell":
		return {"ok": false, "text": "当前没有可跳过的物品。"}
	var advanced := _advance_sell_item()
	return {"ok": true, "advanced": advanced, "text": "跳过这件，看下一件。" if advanced else "没有更多物品了。"}

func bargain_success_chance(percent: int) -> int:
	var chance := 55 + int(rep.get("blackmarket", 0)) / 5 + int(rep.get("lower", 0)) / 10
	chance -= maxi(0, percent - 5) * 3
	chance -= (3 - int(current_customer.get("patience", 3))) * 8
	return clampi(chance, 5, 95)

func bargain_leave_chance(percent: int) -> int:
	var chance := 15 + maxi(0, percent - 5) * 3 - int(rep.get("lower", 0)) / 10
	return clampi(chance, 5, 80)

func bargain_choose_direction(direction: int) -> Dictionary:
	if not can_bargain():
		return {"ok": false, "text": "你不善议价，无法与顾客讨价还价。"}
	if current_customer.is_empty():
		return {"ok": false, "text": "当前没有顾客。"}
	if bool(current_customer.get("bargain_locked", false)):
		return {"ok": false, "text": "议价方式已经锁定。"}
	if direction not in [-1, 1]:
		return {"ok": false, "text": "只能选择压价或抬价。"}
	current_customer["bargain_direction"] = direction
	return {"ok": true, "text": "已选择%s，之后不能更改。" % ("压价" if direction < 0 else "抬价")}

func bargain_choose_percent(percent: int) -> Dictionary:
	if current_customer.is_empty():
		return {"ok": false, "text": "当前没有顾客。"}
	var direction := int(current_customer.get("bargain_direction", 0))
	if direction == 0:
		return {"ok": false, "text": "先选择压价或抬价。"}
	if bool(current_customer.get("bargain_locked", false)):
		return {"ok": false, "text": "报价方式已经锁定。"}
	percent = clampi(percent, 1, 50)
	var base := int(current_customer.get("offer", 0))
	if String(current_customer.get("intent", "")) == "sell":
		base = int(current_customer.get("item", {}).get("asking_price", 0))
	if base <= 0:
		return {"ok": false, "text": "没有可议价的报价。"}
	var price := base
	if direction < 0:
		price = int(round(float(base) * (1.0 - float(percent) / 100.0)))
	else:
		price = int(round(float(base) * (1.0 + float(percent) / 100.0)))
	current_customer["bargain_percent"] = percent
	current_customer["bargain_price"] = maxi(1, price)
	current_customer["bargain_locked"] = true
	return {"ok": true, "text": "已锁定：%s %d%%。" % ["压价" if direction < 0 else "抬价", percent], "price": maxi(1, price)}

func bargain_locked_price() -> int:
	return int(current_customer.get("bargain_price", 0)) if not current_customer.is_empty() else 0

func bargain_preview(percent: int) -> Dictionary:
	return {
		"success": bargain_success_chance(percent),
		"leave": bargain_leave_chance(percent),
		"rep": 0 if percent <= 5 else -1,
	}

func blackmail_bargain() -> Dictionary:
	if current_customer.is_empty():
		return {"ok": false, "text": "当前没有顾客。"}
	var it: Dictionary = current_customer.get("item", {})
	var level := sec_item_contraband_level(it) if not it.is_empty() else 0
	var can := bool(perk_flags.get("blackmail", false)) or bool(it.get("stolen", false)) or level > 0
	if not can:
		return {"ok": false, "text": "你没有可以勒索对方的把柄。"}
	var chance := 50 + int(rep.get("blackmarket", 0)) / 5 - int(rep.get("security", 0)) / 10
	if bool(perk_flags.get("blackmail", false)):
		chance += 25
	if rng.randi_range(1, 100) <= clampi(chance, 10, 95):
		if String(current_customer.get("intent", "")) == "sell":
			var mp := int(it.get("min_price", 0))
			it["min_price"] = int(round(float(mp) * 0.75))
			current_customer["offer"] = int(round(float(current_customer.get("offer", mp)) * 0.75))
			return {"ok": true, "text": "你压低声音提起那批货的来路，对方让步 25%。"}
		current_customer["max_price"] = int(round(float(current_customer.get("max_price", 0)) * 1.2))
		current_customer["offer"] = int(round(float(current_customer.get("offer", 0)) * 1.2))
		return {"ok": true, "text": "你暗示知道货的去向，对方愿意多付 20%。"}
	add_rep("blackmarket", -10)
	add_rep("security", -5)
	complete_customer(false)
	return {"ok": true, "text": "对方没有被吓住，反而记下了你的脸。"}

func make_offer(price: int) -> Dictionary:
	if current_customer.is_empty() or current_customer.get("intent") != "sell":
		return {"accepted": false, "text": "当前没有可收购的物品。"}
	if price > cash:
		return {"accepted": false, "text": "现金不足，你只有 %d₵。" % cash}
	var item: Dictionary = current_customer["item"]
	var aug_discount := 0.8 if int(current_customer.get("aug_threat", 0)) > 0 else 1.0
	var min_price := int(round(float(item.get("min_price", 0)) * (1.0 - float(bargain_bonus) / 100.0) * (1.0 + addiction_price_mod()) * aug_discount))
	if starting_perk_active("perk_awful_negotiator"):
		min_price = int(round(float(min_price) * 1.05))
	if price >= min_price:
		cash -= price
		item["known"] = true
		item["location"] = "backpack"
		add_item(item)
		daily["purchases"] += price
		daily["bought"] = int(daily.get("bought", 0)) + 1
		run_stats["stock_spent"] = int(run_stats.get("stock_spent", 0)) + price
		run_stats["items_bought"] = int(run_stats.get("items_bought", 0)) + 1
		add_rep(current_customer["arche"].get("faction", "lower"), 2)
		var advanced := _advance_sell_item()
		var suffix := "" if advanced else ""
		return {"accepted": true, "advanced": advanced, "text": "成交。你花 %d₵ 收下了 %s。%s" % [price, item_display_name(item), suffix]}
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
	var aug_markup := 1.2 if int(current_customer.get("aug_threat", 0)) > 0 else 1.0
	var sell_cap := int(round(float(current_customer.get("max_price", 0)) * (1.0 - addiction_price_mod()) * aug_markup))
	var base_offer := maxi(1, int(current_customer.get("offer", 1)))
	var raise_pct := int(round((float(price) / float(base_offer) - 1.0) * 100.0))
	if raise_pct > 5 and price <= sell_cap and rng.randi_range(1, 100) > bargain_success_chance(raise_pct):
		current_customer["patience"] = int(current_customer.get("patience", 0)) - 1
		add_rep("lower", -1)
		if int(current_customer["patience"]) < 0:
			complete_customer(false)
			return {"accepted": false, "text": "对方嫌你太贪心，转身离开了。"}
		emit_signal("state_changed")
		return {"accepted": false, "text": "对方拒绝了这次抬价。"}
	if raise_pct > 5 and price > sell_cap:
		return {"accepted": false, "text": "对方最多只肯出 %d₵。" % sell_cap}
	if price <= sell_cap:
		sec_commit_sale(counter_item, price, String(current_customer.get("arche", {}).get("faction", "lower")))
		cash += price
		daily["sales"] += price
		daily["sold"] = int(daily.get("sold", 0)) + 1
		run_stats["total_sales"] = int(run_stats.get("total_sales", 0)) + price
		run_stats["items_sold"] = int(run_stats.get("items_sold", 0)) + 1
		if int(daily["sales"]) > int(run_stats.get("best_day_sales", 0)):
			run_stats["best_day_sales"] = int(daily["sales"])
			run_stats["best_day"] = day
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
			var advanced2 := _advance_sell_item()
			return {"accepted": true, "advanced": advanced2, "text": "你压低声音威胁了几句，花 %d₵ 拿下了货。" % price}
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
		run_stats["customers_served"] = int(run_stats.get("customers_served", 0)) + 1
		if not success:
			add_rep("lower", -1)
	emit_signal("state_changed")
	if auto_customer_flow:
		next_customer()
	else:
		current_customer = {}
		counter_item = {}
		phase = "open"
		emit_signal("customer_changed")
		emit_signal("state_changed")

func add_rep(faction: String, amount: int) -> void:
	if not rep.has(faction):
		rep[faction] = 0
	var final_amount := amount
	if amount > 0:
		var gain := float(amount) * (1.0 + float(upgrade_total("rep")) / 100.0) * float(diff_rule("reputation_gain_mult", 1.0))
		if starting_perk_active("perk_diplomatic"):
			gain *= 1.33
		if starting_perk_active("perk_blabbermouth") and faction in ["blackmarket", "rev"]:
			gain *= 0.5
		if starting_perk_active("perk_sycophant") and faction == "upper":
			gain *= 1.25
		final_amount = int(round(gain))
	elif amount < 0:
		final_amount = int(round(float(amount) * float(diff_rule("reputation_loss_mult", 1.0))))
		if faction == "blackmarket":
			final_amount = int(round(float(final_amount) * 2.0))
		if faction == "security" and sec_perk_unlocked("UL_PETITION"):
			final_amount = int(round(float(final_amount) * float(_sec_perk_def("UL_PETITION").get("rep_loss_mult", 2.0))))
	rep[faction] = clampi(int(rep[faction]) + final_amount, -100, 100)

func store_buy_price() -> int:
	var base := int(diff_rule("property_base_price", 12000))
	var inc := int(diff_rule("property_price_per_day", 50))
	var cap := int(diff_rule("property_price_cap", 5000))
	return base + mini(maxi(0, day - 50) * inc, cap)

func mortgage_down_payment() -> int:
	var share := float(diff_rule("mortgage_down_share", 0.15))
	return maxi(500, int(round(float(store_buy_price()) * share / 500.0)) * 500)

func mortgage_weekly_for(price: int, down: int) -> int:
	var weeks := maxi(1, int(diff_rule("mortgage_weeks", 12)))
	var loan := maxi(0, price - down)
	var rate := int(diff_rule("mortgage_interest", 50))
	var interest := int(float(loan * rate) / 100.0)
	interest = int(float(interest) / 52.0) * weeks
	return int(ceil(float(loan + interest) / float(weeks)))

func can_buy_out_store() -> bool:
	return not property_owned and cash >= store_buy_price()

func can_be_offered_mortgage() -> bool:
	if property_owned or is_paying_mortgage or mortgage_offer_declined:
		return false
	return cash >= mortgage_down_payment() * 2

func _on_property_owned(by_mortgage: bool) -> void:
	unlock_achievement("ACH_BUYOUT")
	if not bool(perk_flags.get("sold_dirty", false)):
		unlock_achievement("ACH_HONEST_MERCHANT")
	if start_type_id == "rock_bottom":
		unlock_achievement("ACH_RAG_TO_RICHES")
		if difficulty in ["hard", "challenge"]:
			unlock_achievement("ACH_NOTHING_TO_RICHES")
	if day < 50:
		unlock_achievement("ACH_PRODIGIOUS")
	var deed := make_item("deed", 100, true, false)
	deed["known"] = true
	add_item(deed)
	_add_night_log("产权到手：%s。" % ("按揭付清" if by_mortgage else "现金买断"))
	emit_signal("state_changed")

func buy_out_store() -> Dictionary:
	if property_owned:
		return {"ok": false, "text": "店铺已经是你的了。"}
	var price := store_buy_price()
	if cash < price:
		return {"ok": false, "text": "现金不足，买断需要 %d₵。" % price}
	cash -= price
	property_owned = true
	property_bought_at = price
	property_bought_day = day
	_on_property_owned(false)
	return {"ok": true, "text": "买断店铺：支付 %d₵，房租时代结束。" % price}

func take_mortgage() -> Dictionary:
	if not can_be_offered_mortgage():
		return {"ok": false, "text": "当前无法申请按揭。"}
	var price := store_buy_price()
	var down := mortgage_down_payment()
	if cash < down:
		return {"ok": false, "text": "首付不足，需要 %d₵。" % down}
	var weeks := maxi(1, int(diff_rule("mortgage_weeks", 12)))
	var weekly := mortgage_weekly_for(price, down)
	var loan := price - down
	var rate := int(diff_rule("mortgage_interest", 50))
	var interest := int(float(loan * rate) / 100.0)
	interest = int(float(interest) / 52.0) * weeks
	cash -= down
	is_paying_mortgage = true
	mortgage_week_left = weeks
	mortgage_total_weeks = weeks
	mortgage_weekly_payment = weekly
	mortgage_down_paid = down
	mortgage_interest_taken = interest
	property_bought_at = loan
	mortgage_due = 7
	_add_night_log("按揭获批：首付 %d₵，每周 %d₵，共 %d 周。" % [down, weekly, weeks])
	emit_signal("state_changed")
	return {"ok": true, "text": "按揭获批：首付 %d₵，每周 %d₵。" % [down, weekly]}

func _try_repo_assets(need: int) -> bool:
	var candidates: Array = []
	for it in display:
		candidates.append(it)
	for it in inventory:
		candidates.append(it)
	candidates.sort_custom(func(a, b): return effective_value(a) > effective_value(b))
	var recovered := 0
	for it in candidates:
		if recovered >= need:
			break
		var val := effective_value(it)
		if String(it.get("location", "")) == "display":
			for i in range(display.size() - 1, -1, -1):
				if int(display[i].get("uid", -1)) == int(it.get("uid", -2)):
					display.remove_at(i)
					break
		else:
			var idx := _find_root_index(inventory, int(it.get("uid", -1)))
			if idx >= 0:
				inventory.remove_at(idx)
		recovered += val
	return recovered >= need

func pay_mortgage_week() -> Dictionary:
	if not is_paying_mortgage:
		return {"ok": false, "text": "没有进行中的按揭。"}
	var pay := mortgage_weekly_payment
	if cash >= pay:
		cash -= pay
		mortgage_week_left -= 1
		mortgage_due = 7
		run_stats["rent_paid"] = int(run_stats.get("rent_paid", 0)) + pay
		if mortgage_week_left <= 0:
			is_paying_mortgage = false
			property_owned = true
			_on_property_owned(true)
			return {"ok": true, "text": "按揭付清，产权到手。"}
		_add_night_log("支付按揭 %d₵，剩余 %d 周。" % [pay, mortgage_week_left])
		emit_signal("state_changed")
		return {"ok": true, "text": "支付按揭 %d₵，剩余 %d 周。" % [pay, mortgage_week_left]}
	if _try_repo_assets(pay):
		mortgage_due = 7
		_add_night_log("无法支付按揭，放贷人收走了货物。")
		emit_signal("state_changed")
		return {"ok": true, "text": "现金不足，货物被收走抵债。"}
	phase = "gameover"
	ending_id = "repo"
	return {"ok": false, "text": "现金不足且无货可收，店铺被收回。"}

func finish_day() -> Dictionary:
	rent_due -= 1
	loan_due -= 1
	if is_paying_mortgage:
		mortgage_due -= 1
	var summary := {
		"day": day, "sales": daily["sales"], "purchases": daily["purchases"],
		"fees": daily["fees"], "rent_paid": 0, "loan_paid": 0,
		"rent": rent, "rent_due": rent_due, "loan_due": loan_due, "cash": cash, "gameover": ""
	}
	if not property_owned and not is_paying_mortgage and rent_due <= 0:
		var rent_cost := int(round(float(rent) * (1.0 - minf(50.0, float(upgrade_total("rent"))) / 100.0)))
		if cash >= rent_cost:
			cash -= rent_cost
			summary["rent_paid"] = rent_cost
			rent = int(round(float(rent) * float(diff_rule("rent_increase", 1.1))))
			rent_due = 7
		else:
			summary["gameover"] = "rent"
	if is_paying_mortgage and mortgage_due <= 0 and summary["gameover"] == "":
		if cash >= mortgage_weekly_payment:
			cash -= mortgage_weekly_payment
			mortgage_week_left -= 1
			mortgage_due = 7
			run_stats["rent_paid"] = int(run_stats.get("rent_paid", 0)) + mortgage_weekly_payment
			if mortgage_week_left <= 0:
				is_paying_mortgage = false
				property_owned = true
				_on_property_owned(true)
		elif _try_repo_assets(mortgage_weekly_payment):
			mortgage_due = 7
			_add_night_log("无法支付按揭，货物被收走抵债。")
		else:
			summary["gameover"] = "repo"
	if loan_due <= 0 and summary["gameover"] == "":
		if cash >= loan:
			cash -= loan
			summary["loan_paid"] = loan
			loan_due = 12
		else:
			summary["gameover"] = "repo"
	if bool(owned_upgrades.get("INSURANCE", false)) and not insurance_blocked() and summary["gameover"] == "":
		var ins_cost := insurance_daily_cost()
		cash -= ins_cost
		summary["fees"] = int(summary.get("fees", 0)) + ins_cost
		daily["fees"] = int(daily.get("fees", 0)) + ins_cost
		run_stats["insurance_spent"] = int(run_stats.get("insurance_spent", 0)) + ins_cost
		if cash < 0:
			summary["gameover"] = "rent"
	if summary["gameover"] == "":
		var doom := ""
		if rep_perk_unlocked("LLLYNCH"):
			doom = "mob"
		elif sec_perk_unlocked("SEC_IMMEDIATE_ARREST"):
			doom = "sec"
		elif rep_perk_unlocked("UL_HITMAN"):
			doom = "hitman"
		elif rep_perk_unlocked("CARTEL_RETIRED"):
			doom = "cartel_retired"
		elif rep_perk_unlocked("REV_HIT"):
			doom = "bombed"
		summary["gameover"] = doom
	if String(summary["gameover"]) != "":
		ending_id = String(summary["gameover"])
	if ending_id in ["buyout", "buyout_mortgage"]:
		unlock_achievement("ACH_BUYOUT")
		if not bool(perk_flags.get("sold_dirty", false)):
			unlock_achievement("ACH_HONEST_MERCHANT")
		if start_type_id == "rock_bottom":
			unlock_achievement("ACH_RAG_TO_RICHES")
			if difficulty in ["hard", "challenge"]:
				unlock_achievement("ACH_NOTHING_TO_RICHES")
		if day < 50:
			unlock_achievement("ACH_PRODIGIOUS")
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

func _night_rats() -> void:
	var food: Array = []
	for it in inventory:
		var cat := String(get_item_def(String(it.get("def_id", ""))).get("category", ""))
		if cat in ["food", "animal"]:
			food.append(it)
	for it in display:
		var cat2 := String(get_item_def(String(it.get("def_id", ""))).get("category", ""))
		if cat2 in ["food", "animal"]:
			food.append(it)
	if food.is_empty() or rng.randi_range(1, 100) > 12:
		return
	if inventory_count("mouse_trap") > 0 and rng.randi_range(1, 100) <= 70:
		remove_inventory("mouse_trap", 1)
		_add_night_log("老鼠触发了捕鼠器，店里安静下来。")
		return
	var stolen: Dictionary = food[rng.randi_range(0, food.size() - 1)]
	var sname := item_display_name(stolen)
	if String(stolen.get("location", "")) == "display":
		for i in range(display.size()):
			if int(display[i].get("uid", -1)) == int(stolen.get("uid", -2)):
				display.remove_at(i)
				break
	else:
		remove_inventory(String(stolen.get("def_id", "")), 1)
	_add_night_log("老鼠啃坏了 %s，只能扔掉。" % sname)

func _night_burglary() -> void:
	if display.is_empty():
		return
	var chance := burglary_chance()
	if chance <= 0:
		return
	if security_alarm_active and rng.randi_range(1, 100) <= 50:
		_add_night_log("警报响起，盗贼放弃了行动。")
		return
	if rng.randi_range(1, 100) > chance:
		return
	var idx := rng.randi_range(0, display.size() - 1)
	var stolen: Dictionary = display[idx]
	var value := effective_value(stolen)
	display.remove_at(idx)
	run_stats["burglaries"] = int(run_stats.get("burglaries", 0)) + 1
	run_stats["burglary_losses"] = int(run_stats.get("burglary_losses", 0)) + value
	if bool(owned_upgrades.get("INSURANCE", false)) and not insurance_blocked():
		cash += value
		_add_night_log("夜间失窃：%s（估值 %d₵），保险已赔付。" % [item_display_name(stolen), value])
	else:
		_add_night_log("夜间失窃：%s（估值 %d₵），没有保险赔付。" % [item_display_name(stolen), value])
	emit_signal("state_changed")

func advance_day() -> void:
	if phase == "gameover":
		return
	went_out_last_night = afterhours_went_out
	_resolve_hireling_expedition()
	if not hireling.is_empty() and String(hireling.get("status", "")) == "injured":
		hireling["health"] = mini(int(hireling.get("max_health", 100)), int(hireling.get("health", 0)) + 10)
		if int(hireling.get("health", 0)) > 50:
			hireling["status"] = "available"
	advance_machines_one_cycle()
	_night_burglary()
	_night_rats()
	nightly_survival()
	run_stats["days_played"] = int(run_stats.get("days_played", day)) + 1
	run_stats["net_worth_by_day"][str(day + 1)] = net_worth()
	_check_achievements()
	if phase == "gameover":
		emit_signal("state_changed")
		return
	day += 1
	start_day()
	if events.size() > 0 and rng.randf() < 0.45:
		pending_event = events[rng.randi_range(0, events.size() - 1)].duplicate(true)
		emit_signal("event_started", pending_event)
	elif events.size() > 0 and rep_perk_unlocked("LLTIPS") and rng.randf() < 0.04:
		pending_event = events[rng.randi_range(0, events.size() - 1)].duplicate(true)
		_add_night_log("市井传言带来了即将发生事件的情报。")
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
	var market_changes: Dictionary = ch.get("market", {})
	for k in market_changes.keys():
		market_modifiers[String(k)] = int(market_modifiers.get(String(k), 0)) + int(market_changes[k])
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
	return apply_start_type(pid)

func apply_start_type(pid: String) -> Dictionary:
	if profession_chosen:
		return {"ok": false, "text": "本局已经选择过开局。"}
	var p := {}
	for x in professions:
		if String(x.get("id", "")) == pid:
			p = x
			break
	if p.is_empty():
		return {"ok": false, "text": "没有这个开局。"}
	if bool(p.get("coming_soon", false)):
		return {"ok": false, "text": "这个开局尚未开放。"}
	profession_id = pid
	start_type_id = pid
	profession_chosen = true
	if pid == "rock_bottom":
		cash = 0
	else:
		cash += int(p.get("cash_delta", p.get("cash", 0)))
	rent += int(p.get("rent_delta", 0))
	for entry in p.get("items", []):
		var iid := String(entry[0])
		var cnt := int(entry[1])
		if iid == "" or cnt <= 0:
			continue
		if not _is_headless():
			continue
		for n in range(cnt):
			var it := make_item(iid, 100, true, false)
			it["known"] = true
			add_item(it)
	var reps: Dictionary = p.get("rep", {})
	for k in reps.keys():
		add_rep(String(k), int(reps[k]))
	var ups: Dictionary = p.get("upgrades", {})
	for uid in ups.keys():
		owned_upgrades[String(uid)] = true
	_refresh_upgrades()
	if pid == "rock_bottom":
		unlock_achievement("ACH_RATS")
	emit_signal("state_changed")
	return {"ok": true, "text": "已选择开局：%s。" % p.get("name", pid)}

func starting_perk_meta_def(pid: String) -> Dictionary:
	return starting_perk_meta.get(pid, {})

func starting_perk_points(ids: Array) -> int:
	var total := 0
	for pid in ids:
		total += int(starting_perk_meta_def(String(pid)).get("cost", 0))
	return total

func starting_perk_slots(ids: Array) -> int:
	var slots := 4
	for pid in ids:
		var m := starting_perk_meta_def(String(pid))
		slots += maxi(0, int(m.get("max_slot", 1)) - 1)
	return slots

func starting_perks_valid(ids: Array) -> Dictionary:
	if ids.size() > starting_perk_slots(ids):
		return {"ok": false, "text": "天赋槽位不足。"}
	if starting_perk_points(ids) > 3:
		return {"ok": false, "text": "天赋点数超过 3 点。"}
	for pid in ids:
		if starting_perk_def(String(pid)).is_empty() and starting_perk_meta_def(String(pid)).is_empty():
			return {"ok": false, "text": "没有这个天赋。"}
		var m := starting_perk_meta_def(String(pid))
		var bad: Array = m.get("incompatible", [])
		for other in ids:
			if String(other) != String(pid) and bad.has(String(other)):
				return {"ok": false, "text": "天赋互斥：%s 与 %s。" % [pid, other]}
		if ids.count(pid) > maxi(1, int(m.get("max_slot", 1))):
			return {"ok": false, "text": "这个天赋最多选 %d 次。" % maxi(1, int(m.get("max_slot", 1)))}
	return {"ok": true, "text": "可以开始。"}

func add_rep_raw(faction: String, amount: int) -> void:
	if not rep.has(faction):
		rep[faction] = 0
	rep[faction] = clampi(int(rep[faction]) + amount, -100, 100)

func apply_starting_perks(ids: Array) -> Dictionary:
	if starting_perk_chosen:
		return {"ok": false, "text": "本局已经选择过天赋。"}
	var check := starting_perks_valid(ids)
	if not bool(check.get("ok", false)):
		return check
	starting_perk_ids = []
	for pid in ids:
		var p := starting_perk_def(String(pid))
		if p.is_empty():
			continue
		starting_perk_ids.append(String(pid))
		_apply_starting_perk_effect(String(pid))
		perk_flags[String(pid)] = true
	starting_perk_id = String(starting_perk_ids[0]) if not starting_perk_ids.is_empty() else ""
	starting_perk_chosen = true
	_rebuild_starting_perk_effects()
	_refresh_pages()
	emit_signal("state_changed")
	return {"ok": true, "text": "已选择 %d 个天赋。" % starting_perk_ids.size()}

func choose_starting_perk(pid: String) -> Dictionary:
	return apply_starting_perks([pid])

func _apply_starting_perk_effect(pid: String) -> void:
	match pid:
		"perk_sawyer_crew":
			combat_allies = [{"name": "索耶船员", "enemy_id": "marine"}]
		"perk_expedition_organizer":
			combat_allies = [{"name": "探险助手", "enemy_id": "scav"}]
			unlock_hireling()
		"perk_saving": cash += 150
		"perk_bad_lease": rent += 40
		"perk_well_connected":
			for f in ["lower", "upper", "security", "blackmarket", "rev", "tourist", "church", "cartel"]:
				add_rep_raw(f, 15)
		"perk_public_enemy":
			for f in ["lower", "upper", "security", "blackmarket", "rev", "tourist", "church", "cartel"]:
				add_rep_raw(f, -15)
		"perk_model_citizen": add_rep_raw("security", 30)
		"perk_convict":
			add_rep_raw("security", -30)
		"perk_sycophant":
			add_rep_raw("upper", 15)
			perk_flags["rep_gain"] = true
		"perk_known_snitch":
			add_rep_raw("blackmarket", -10)
			add_rep_raw("rev", -10)
		"perk_revolution_sympathizer": add_rep_raw("rev", 25)
		"perk_colorful_character":
			for f in ["lower", "upper", "security", "blackmarket", "rev", "tourist", "church", "cartel"]:
				add_rep_raw(f, 3)
		"perk_tapehead":
			add_item(make_item("radio_on", 100, true, false))
			add_item(make_item("cassette_player", 100, true, false))
		"perk_handy":
			add_item(make_item("toolbox", 100, true, false))
			add_item(make_item("flashlight", 100, true, false))
			add_item(make_item("screwdriver", 100, true, false))
			add_item(make_item("wire_cutter", 100, true, false))
			add_item(make_item("crowbar", 100, true, false))
			add_item(make_item("welder", 100, true, false))
		"perk_vending":
			owned_upgrades["VENDING_MACHINE"] = true
			add_item(make_item("vending_machine", 100, true, false))
		"perk_side_street": rent = maxi(50, rent - 20)
		"perk_prime_real_estate": rent += 75
		"perk_nicotine_addiction":
			perk_flags["addiction_nicotine"] = true
			addiction_days["nicotine"] = 3
			add_item(make_item("cig_red", 100, true, false))
		"perk_alcohol_addiction":
			perk_flags["addiction_alcohol"] = true
			addiction_days["alcohol"] = 3
			add_item(make_item("red_beer", 100, true, false))
		"perk_narcotic_addiction":
			perk_flags["addiction_narcotic"] = true
			addiction_days["narcotic"] = 3
			add_item(make_item("fanta_pill", 100, true, false))
		"perk_gambling_addiction":
			perk_flags["gambling"] = true
			add_item(make_item("coin", 100, true, false))
		"perk_sentinel":
			perk_flags["sentinel"] = true
			add_item(make_item("large_purple_injector", 100, true, false))
		"perk_aug_menace":
			perk_flags["aug_menace"] = true
			aug_introduced = true
			aug_presence = 15
			aug_next_spawn_day = 2
		"perk_lucky": luck += 15
		"perk_unlucky": luck -= 15
		"perk_working_pipes":
			owned_upgrades["GUTTERFLOW_TAP"] = true
			owned_upgrades["RUSTWATER_TAP"] = true
		"perk_welfare_program": perk_flags["welfare"] = true
		"perk_banned_commissary": perk_flags["banned_commissary"] = true
		"perk_hoarder":
			for i in range(3):
				add_item(make_item("debris_pile1", 100, true, false))
		"perk_secret_admirer": perk_flags["secret_admirer"] = true
		"perk_short_sleeper": perk_flags["short_sleeper"] = true
		"perk_minimalist": perk_flags["minimalist"] = true
		"perk_ascetic": perk_flags["ascetic"] = true
		"perk_blackmail": perk_flags["blackmail"] = true
		"perk_blabbermouth": perk_flags["blabbermouth"] = true
		"perk_intimidating": perk_flags["intimidating"] = true
		"perk_diplomatic": perk_flags["diplomatic"] = true
		"perk_alert": perk_flags["alert"] = true
		"perk_awful_negotiator": perk_flags["awful_negotiator"] = true
		"perk_tinkerer": perk_flags["tinkerer"] = true
		"perk_illiterate": perk_flags["illiterate"] = true
		"perk_maimed":
			perk_flags["perk_maimed"] = true
			wounds = mini(10, wounds + 2)
		"perk_degenerative_osteoarthritis":
			perk_flags["perk_degenerative_osteoarthritis"] = true
			wounds = mini(10, wounds + 2)
			for i in range(2):
				add_item(make_item("topical_bandage_item", 100, true, false))
		"perk_proficient_scavenger", "perk_careful_scavenger":
			perk_flags[pid] = true
		"perk_wild_favorite":
			perk_flags["wild_favorite"] = true
		"perk_wild_bad_side":
			perk_flags["wild_bad_side"] = true
		"perk_makeshift_reactor":
			perk_flags["makeshift_reactor"] = true
			add_item(make_item("makeshift_reactor", 100, true, false))
		"perk_unsubscribed":
			perk_flags["unsubscribed"] = true
		"perk_speedy":
			perk_flags["speedy"] = true
		"perk_agoraphobia":
			perk_flags["agoraphobia"] = true
func _market_customer(type_id: String, shortage: bool) -> Dictionary:
	var cfg: Dictionary = market_customers.get("types", {}).get(type_id, {})
	if cfg.is_empty():
		return {}
	if shortage:
		var budget_cfg: Array = cfg.get("shortage_budget", [100, 20, 50])
		var name := loc("ClientName", String(cfg.get("shortage_name", "")), "顾客")
		var line := _pool_dialogue_line({"dialogue": String(cfg.get("shortage_dialogue", ""))})
		var b := int(budget_cfg[0]) + rng.randi_range(0, int(budget_cfg[1])) + int(budget_cfg[2])
		return {
			"arche": {"faction": "lower", "name": name, "sprite": _random_client_sprite("lower")},
			"intent": "buy", "patience": 3, "done": false, "line": line,
			"want_tags": [type_id], "exclude_contraband": false,
			"budget": _pool_budget({"budget_base": b}), "offer": 0, "max_price": 0,
			"market_type": type_id, "market_kind": "shortage",
		}
	var name2 := loc("ClientName", String(cfg.get("surplus_name", "")), "商人")
	var line2 := _pool_dialogue_line({"dialogue": String(cfg.get("surplus_dialogue", ""))})
	var stock: Array = []
	for iid in tradable_pool:
		if _buy_tag_match(make_item(String(iid), 100, true, false), [type_id]):
			var it := make_item(String(iid), rng.randi_range(70, 100), true, false)
			stock.append(it)
		if stock.size() >= 4:
			break
	return {
		"arche": {"faction": "lower", "name": name2},
		"intent": "wholesale", "patience": 3, "done": false, "line": line2,
		"wholesale_name": name2, "wholesale_supplier": "", "wholesale_discount": -20,
		"wholesale_stock": stock, "wholesale_free": false, "wholesale_done_key": "",
		"market_type": type_id, "market_kind": "surplus",
	}

func _gen_due_customer(kind: String) -> Dictionary:
	if kind == "rent":
		return {"arche": {"faction": "lower", "name": "房东"}, "intent": "rent", "amount": rent, "done": false, "line": "房租该交了。"}
	return {"arche": {"faction": "blackmarket", "name": "放贷人"}, "intent": "loan", "amount": loan, "done": false, "line": "欠款到期了。"}

func pay_rent_early() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "rent":
		return {"ok": false, "text": "当前没有房东。"}
	var amount := int(current_customer.get("amount", rent))
	if cash < amount:
		return {"ok": false, "text": "现金不足，需要 %d₵。" % amount}
	cash -= amount
	rent = int(round(float(rent) * float(diff_rule("rent_increase", 1.1))))
	rent_due = 7
	complete_customer(true)
	emit_signal("state_changed")
	return {"ok": true, "text": "支付房租 %d₵。" % amount}

func pay_loan_early() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "loan":
		return {"ok": false, "text": "当前没有放贷人。"}
	var amount := int(current_customer.get("amount", loan))
	if cash < amount:
		return {"ok": false, "text": "现金不足，需要 %d₵。" % amount}
	cash -= amount
	loan_due = 12
	complete_customer(true)
	emit_signal("state_changed")
	return {"ok": true, "text": "偿还欠款 %d₵。" % amount}

func _gen_special_customer(t: Dictionary) -> Dictionary:
	var name := String(t.get("name", ""))
	if name == "":
		name = loc("ClientName", String(t.get("name_key", "")), String(t.get("id", "")))
	var line := _pool_dialogue_line(t)
	var base := {
		"special_id": String(t.get("id", "")),
		"arche": {"faction": String(t.get("faction", "lower")), "name": name, "sprite": _random_client_sprite(String(t.get("faction", "lower")))},
		"patience": 3,
		"done": false,
		"line": line,
	}
	if String(t.get("intent", "sell")) == "information":
		base["intent"] = "information"
		base["service_cost"] = int(t.get("service_cost", 50))
		return base
	if String(t.get("intent", "sell")) == "expedition":
		base["intent"] = "expedition"
		base["party"] = String(t.get("party", "pirateRookieTriple"))
		return base
	if String(t.get("intent", "sell")) == "buy":
		base["intent"] = "buy"
		base["want_tags"] = t.get("buy_tags", []).duplicate()
		base["exclude_contraband"] = false
		base["budget"] = _pool_budget(t, String(t.get("faction", "lower")))
		base["offer"] = 0
		base["max_price"] = 0
		base["discount_buy"] = 0
		return base
	var stock := _pool_stock_items(t)
	base["intent"] = "wholesale"
	base["wholesale_name"] = name
	base["wholesale_supplier"] = ""
	base["wholesale_discount"] = int(t.get("wholesale_discount", [0, 0])[0])
	base["wholesale_stock"] = stock
	base["wholesale_free"] = false
	base["wholesale_done_key"] = ""
	return base

func _real_stamp(value: int) -> Dictionary:
	var it := make_item("food_stamp", 100, true, false)
	it["custom_base_value"] = value
	it["custom_name"] = "食品券（%d₵）" % value
	it["known"] = true
	return it

func _handle_welfare_program() -> void:
	if not starting_perk_active("perk_welfare_program"):
		return
	if day != 1 and day % 7 != 1:
		return
	var adjusted := (net_worth() - cash) / 3 + cash
	var value := 40
	if adjusted <= 1200:
		value = 160
	elif adjusted <= 1800:
		value = 120
	elif adjusted <= 2400:
		value = 80
	add_item(_real_stamp(value))
	_add_night_log("福利计划发放了 %d₵ 食品券。" % value)

func _handle_secret_admirer() -> void:
	if not starting_perk_active("perk_secret_admirer"):
		return
	if day == 2:
		add_item(make_item("galaxy_blend", 100, true, false))
		secret_admirer_days = 0
		_add_night_log("神秘仰慕者送来一份银河混合饮。")
		return
	var chance := 3
	if secret_admirer_days + 1 >= 12:
		chance = 100
	elif secret_admirer_days + 1 > 3:
		chance = 3 + 6 * (secret_admirer_days + 1 - 3)
	if rng.randi_range(1, 100) > chance:
		secret_admirer_days += 1
		return
	secret_admirer_days = 0
	var gift_id := "nutrifruit"
	if starting_perk_active("perk_sentinel") and inventory_count("large_purple_injector") == 0:
		gift_id = "large_purple_injector"
	elif addiction_active_count() > 0 and inventory_count("black_injector") == 0:
		gift_id = "black_injector"
	elif wounds > 0:
		gift_id = "bandage_item"
	else:
		var roll := rng.randi_range(1, 100)
		if roll <= 30:
			gift_id = "galaxy_blend"
		elif roll <= 60:
			gift_id = "nutrifruit"
		elif roll <= 80:
			gift_id = "bandage_item"
		else:
			gift_id = "salve"
	var gift := make_item(gift_id, 100, true, false)
	gift["known"] = true
	add_item(gift)
	_add_night_log("神秘仰慕者送来 %s。" % item_display_name(gift))

func _handle_gambling_addiction() -> void:
	if not starting_perk_active("perk_gambling_addiction"):
		return
	if cash < 20:
		return
	cash -= 20
	var roll := rng.randi_range(1, 100)
	var payout := 0
	if roll > 97:
		payout = rng.randi_range(350, 600)
	elif roll > 85:
		payout = rng.randi_range(80, 260)
	elif roll > 55:
		payout = rng.randi_range(10, 60)
	cash += payout
	_add_night_log("赌瘾发作：花 20₵ 买了张彩票，%s" % ("中奖 %d₵。" % payout if payout > 0 else "谢谢惠顾。"))

func _handle_blackmail() -> void:
	if not starting_perk_active("perk_blackmail"):
		return
	if day <= 1 or day % 7 != 1:
		return
	customers_today.append({
		"arche": {"faction": "lower", "name": "敲诈者", "sprite": _random_client_sprite("lower")},
		"intent": "blackmail", "amount": 40 + day, "done": false, "patience": 3,
		"line": "你知道我手里有什么。交 %d₵，这事就当没发生过。" % (40 + day),
	})

func resolve_blackmail(pay: bool) -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "blackmail":
		return {"ok": false, "text": "当前没有敲诈者。"}
	var amount := int(current_customer.get("amount", 0))
	if pay:
		if cash < amount:
			return {"ok": false, "text": "现金不足，需要 %d₵。" % amount}
		cash -= amount
		complete_customer(true)
		emit_signal("state_changed")
		return {"ok": true, "text": "你支付了 %d₵ 封口费。" % amount}
	add_rep("lower", -30)
	add_rep("rev", -30)
	complete_customer(false)
	emit_signal("state_changed")
	return {"ok": true, "text": "你拒绝付款，秘密被曝光：下层区与革命军声望大跌。"}

func _handle_sentinel_scalper() -> void:
	if not starting_perk_active("perk_sentinel") or day % 7 != 6:
		return
	var item := make_item("large_purple_injector", 100, true, false)
	item["known"] = true
	var val := market_value(item, false, "blackmarket")
	item["asking_price"] = int(round(float(val) * 2.2))
	item["min_price"] = int(round(float(val) * 1.5))
	customers_today.append({
		"arche": {"faction": "blackmarket", "name": "药贩子", "sprite": _random_client_sprite("blackmarket")},
		"intent": "sell", "items": [item], "item_index": 0, "item": item,
		"done": false, "patience": 3,
		"line": "免疫宁，只此一支。你懂这价。",
	})

func _pool_entry_by_id(eid: String) -> Dictionary:
	for pool in client_pools.get("faction_pools", []):
		for e in pool.get("entries", []):
			if String(e.get("id", "")) == eid:
				return e
	for e in client_pools.get("general", []):
		if String(e.get("id", "")) == eid:
			return e
	return {}

func _special_by_id(sid: String) -> Dictionary:
	for group in ["tier", "retired", "unique"]:
		for e in special_customers.get(group, []):
			if String(e.get("id", "")) == sid:
				return e
	return {}

func _boost_thief_quality(c: Dictionary) -> void:
	var rep_bm := maxi(0, int(rep.get("blackmarket", 0)))
	var boost := rep_bm / 10
	for it in c.get("wholesale_stock", []):
		it["condition"] = mini(100, int(it.get("condition", 100)) + boost)
	if not c.get("item", {}).is_empty():
		c["item"]["condition"] = mini(100, int(c["item"].get("condition", 100)) + boost)

func _gen_perk_sell_customer(eid: String, name: String) -> Dictionary:
	var entry := _pool_entry_by_id(eid)
	if entry.is_empty():
		return {}
	var c := _gen_pool_customer(entry, "blackmarket")
	if c.is_empty():
		return {}
	c["arche"]["name"] = name
	c["line"] = "有些货，你可能会感兴趣。"
	if eid in ["thief", "pettyThief", "foodThief"]:
		_boost_thief_quality(c)
	return c

func _gen_rare_merchant() -> Dictionary:
	var stock: Array = []
	for id in ["energy_credit_breeder", "turbo_booster_adv", "advanced_flux_agent", "blank_module"]:
		var it := make_item(id, rng.randi_range(70, 100), true, false)
		it["known"] = false
		stock.append(it)
	if not tradable_pool.is_empty():
		for i in range(2):
			var it2 := make_item(String(tradable_pool[rng.randi_range(0, tradable_pool.size() - 1)]), rng.randi_range(60, 100), true, false)
			it2["known"] = false
			stock.append(it2)
	return {
		"arche": {"faction": "lower", "name": "稀有货商人", "sprite": _random_client_sprite("lower")},
		"intent": "wholesale", "patience": 3, "done": false,
		"wholesale_name": "稀有货商人", "wholesale_supplier": "",
		"wholesale_discount": -5, "wholesale_stock": stock,
		"wholesale_free": false, "wholesale_done_key": "",
		"line": "稀有货，违禁品，识货的才懂。",
	}

func _gen_rev_quartermaster() -> Dictionary:
	var stock: Array = []
	var rep_rev := int(rep.get("rev", 0))
	for i in range(rng.randi_range(5, 12)):
		var it := make_item("common_ore", rng.randi_range(70, 100), true, false)
		it["known"] = false
		stock.append(it)
	for i in range(rng.randi_range(2, 5)):
		var it2 := make_item("scrap_metal", rng.randi_range(70, 100), true, false)
		it2["known"] = false
		stock.append(it2)
	var disc := -(20 + int((rep_rev - 40) / 4))
	return {
		"arche": {"faction": "rev", "name": "革命军军需官", "sprite": _random_client_sprite("rev")},
		"intent": "wholesale", "patience": 3, "done": false,
		"wholesale_name": "革命军军需官", "wholesale_supplier": "",
		"wholesale_discount": disc, "wholesale_stock": stock,
		"wholesale_free": false, "wholesale_done_key": "",
		"line": "军需品，按你的声望给价。",
	}

func _gen_rev_raider() -> Dictionary:
	var stock: Array = []
	var rep_rev := int(rep.get("rev", 0))
	for id in ["energy_credit_breeder", "turbo_booster_adv", "advanced_flux_agent"]:
		if rng.randi_range(1, 100) <= 40:
			var it := make_item(id, rng.randi_range(60, 100), true, true)
			it["known"] = false
			stock.append(it)
	if stock.is_empty():
		var fallback := make_item("blank_module", rng.randi_range(70, 100), true, true)
		fallback["known"] = false
		stock.append(fallback)
	var disc := -(10 + maxi(0, rep_rev) / 10)
	return {
		"arche": {"faction": "rev", "name": "革命军突击队员", "sprite": _random_client_sprite("rev")},
		"intent": "wholesale", "patience": 3, "done": false,
		"wholesale_name": "革命军突击队员", "wholesale_supplier": "",
		"wholesale_discount": disc, "wholesale_stock": stock,
		"wholesale_free": false, "wholesale_done_key": "",
		"line": "突袭所得，低价出。",
	}

func _gen_sec_requisition() -> Dictionary:
	return {
		"arche": {"faction": "security", "name": "治安部征用官", "sprite": _random_client_sprite("security")},
		"intent": "buy", "want_tags": ["FOOD", "MEDICAL"], "exclude_contraband": false,
		"budget": 300, "offer": 0, "max_price": 0, "discount_buy": 0,
		"done": false, "patience": 3,
		"line": "治安部征用食品与医疗物资，价格从优。",
	}

func _gen_extra_upper() -> Dictionary:
	var entry := _pool_entry_by_id("upperLowerVisitor")
	if entry.is_empty():
		return {}
	var c := _gen_pool_customer(entry, "upper")
	if not c.is_empty():
		c["arche"]["name"] = "上层区顾客"
		c["line"] = "听说你这里能弄到好东西。"
	return c

func _has_luxury_display() -> bool:
	for it in display:
		for t in _item_tags(it):
			if String(t).to_upper() == "LUXURY_ITEM":
				return true
	return false

func _gen_discerning_customer() -> Dictionary:
	return {
		"arche": {"faction": "upper", "name": "品味不凡的收藏家", "sprite": _random_client_sprite("upper")},
		"intent": "buy", "want_tags": ["LUXURY_ITEM"], "exclude_contraband": false,
		"budget": _pool_budget({"budget_base": 500, "budget_day": 3}, "upper"),
		"offer": 0, "max_price": 0, "discount_buy": 0,
		"done": false, "patience": 3,
		"line": "展示柜里那只，我看上了。",
	}

func _gen_charity_customer() -> Dictionary:
	return {
		"arche": {"faction": "upper", "name": "上层区施恩人", "sprite": _random_client_sprite("upper")},
		"intent": "gift", "done": false, "patience": 3,
		"line": "一点心意，请收下。",
	}

func accept_charity_gift() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "gift":
		return {"ok": false, "text": "当前没有捐赠。"}
	var gifts: Array = ["galaxy_blend", "galaxy_blend", "energy_credit", "food_stamp"]
	var got: Array = []
	for id in gifts:
		var it := make_item(String(id), 100, true, false)
		it["known"] = true
		add_item(it)
		got.append(item_display_name(it))
	complete_customer(true)
	emit_signal("state_changed")
	return {"ok": true, "text": "收下捐赠：%s。" % "、".join(got)}

func _handle_cartel_weekly() -> void:
	if cartel_exited or day % 7 != 0:
		return
	if rep_perk_unlocked("CARTEL_INCREASED_STIPEND") and int(rep.get("cartel", 0)) >= 25:
		var pay := 150 + int(rep.get("cartel", 0)) * 4
		cash += pay
		_add_night_log("卡特尔津贴随声望发放：%d₵。" % pay)
	if rep_perk_unlocked("CARTEL_AUTHORIZED_EXIT"):
		cartel_exit_available = true

func cartel_material_cost() -> int:
	return 6 if rep_perk_unlocked("CARTEL_RELIABLE_CHEMIST") else 12

func request_cartel_materials() -> Dictionary:
	if cartel_exited:
		return {"ok": false, "text": "你已经与卡特尔断绝关系。"}
	var cost := cartel_material_cost()
	if int(rep.get("cartel", 0)) < cost:
		return {"ok": false, "text": "卡特尔声望不足：需要 %d。" % cost}
	add_rep("cartel", -cost)
	for i in range(2):
		var it := make_item("chem_module", 100, true, false)
		it["known"] = true
		add_item(it)
	emit_signal("state_changed")
	return {"ok": true, "text": "获得 2 个化学模块，消耗 %d 卡特尔声望。" % cost}

func exit_cartel() -> Dictionary:
	if cartel_exited:
		return {"ok": false, "text": "你已经脱离卡特尔。"}
	if not cartel_exit_available:
		return {"ok": false, "text": "接头人还没有为你安排好退路。"}
	cartel_exited = true
	cartel_exit_available = false
	cartel_exit_uses += 1
	add_rep("cartel", -25)
	_add_night_log("你与卡特尔和平分手，金盆洗手。")
	emit_signal("state_changed")
	return {"ok": true, "text": "你与卡特尔断绝了关系（卡特尔声望 -25）。"}

func afterhours_block_reason() -> String:
	if phase != "endday":
		return "只能在结束营业后外出。"
	if afterhours_visits_left <= 0:
		return "今晚已经没有外出的机会。"
	if wounds >= 7:
		return "伤势严重，无法外出。"
	if starting_perk_active("perk_agoraphobia") and last_afterhour_outing_day >= 0:
		var ready := last_afterhour_outing_day + 3
		if day < ready:
			return "广场恐惧症：还需要休息 %d 晚。" % (ready - day)
	return ""

func afterhours_locations() -> Array:
	var out: Array = []
	if not starting_perk_active("perk_maimed"):
		out.append({"id": "dumping_ground", "name": "垃圾倾倒场"})
	if not commissary_banned():
		out.append({"id": "commissary", "name": "补给站"})
	if not rep_perk_unlocked("LLAVOIDED"):
		out.append({"id": "dr_jackson", "name": "杰克逊医生"})
	return out

func afterhours_travel(loc_id: String) -> Dictionary:
	var reason := afterhours_block_reason()
	if reason != "":
		return {"ok": false, "text": reason}
	var known := false
	for loc in afterhours_locations():
		if String(loc.get("id", "")) == loc_id:
			known = true
			break
	if not known:
		return {"ok": false, "text": "今晚去不了那里。"}
	afterhours_visits_left -= 1
	afterhours_went_out = true
	last_afterhour_outing_day = day
	afterhours_location = loc_id
	scav_attempts_used = 0
	if loc_id == "dr_jackson":
		_refresh_jackson_stock()
	var names := {"dumping_ground": "垃圾倾倒场", "commissary": "补给站", "dr_jackson": "杰克逊医生"}
	_add_night_log("夜间外出：%s。" % String(names.get(loc_id, loc_id)))
	emit_signal("state_changed")
	return {"ok": true, "location": loc_id, "text": "你摸黑来到%s。" % String(names.get(loc_id, loc_id))}

func afterhours_return() -> Dictionary:
	afterhours_location = ""
	emit_signal("state_changed")
	return {"ok": true, "text": "你回到店铺。"}

func scav_attempts_max() -> int:
	if starting_perk_active("perk_maimed"):
		return 0
	var n := 5
	if starting_perk_active("perk_proficient_scavenger"):
		n += 2
	if starting_perk_active("perk_careful_scavenger"):
		n -= 2
	if starting_perk_active("perk_degenerative_osteoarthritis"):
		n -= int((day - 1) / 7)
		if n < 3:
			return 0
	n += int(afterhour_mods.get("scav_attempts", 0))
	return maxi(0, n)

func scav_attempts_left() -> int:
	return maxi(0, scav_attempts_max() - scav_attempts_used)

func scav_minor_chance() -> float:
	if starting_perk_active("perk_careful_scavenger"):
		return 0.0
	if int(afterhour_mods.get("injury_immunity", 0)) > 0:
		return 0.0
	var chance := 5.0 + float(scav_attempts_used)
	if inventory_count("flashlight") > 0:
		chance /= 2.0
	return chance * (1.0 + float(afterhour_mods.get("injury_chance", 0)) / 100.0)

func scav_major_chance() -> float:
	if starting_perk_active("perk_careful_scavenger"):
		return 0.0
	if int(afterhour_mods.get("injury_immunity", 0)) > 0:
		return 0.0
	var chance := 1.0 + float(scav_attempts_used) * 0.25
	if inventory_count("flashlight") > 0:
		chance /= 2.0
	return chance * (1.0 + float(afterhour_mods.get("injury_chance", 0)) / 100.0)

func _roll_scav_item() -> String:
	var table: Array = [
		["scrap_metal", 55.0], ["printer_plastic", 20.0], ["common_ore", 15.0],
		["common_electronic", 8.0], ["nuts_metal", 5.0], ["wire", 5.0],
		["metal_ingot", 3.0], ["energy_credit", 3.0], ["turbo_booster_adv", 1.0],
		["blank_module", 1.0], ["chem_module", 0.5], ["system_capped_neural_core", 0.2],
	]
	var roll := rng.randf() * 100.0
	for row in table:
		roll -= float(row[1])
		if roll <= 0.0:
			return String(row[0])
	return "scrap_metal"

func _roll_scav_loot() -> Array:
	var loot: Array = []
	var it := make_item(_roll_scav_item(), rng.randi_range(45, 100), true, false)
	loot.append(it)
	if rng.randi_range(1, 100) <= 3 and not satchel_found and inventory_count("satchel") == 0:
		var bag := make_item("satchel", 100, true, false)
		loot.append(bag)
		satchel_found = true
	elif rng.randi_range(1, 100) <= 3 and not kids_backpack_found and inventory_count("kids_backpack") == 0:
		var bag2 := make_item("kids_backpack", 100, true, false)
		loot.append(bag2)
		kids_backpack_found = true
	if rng.randi_range(1, 100) <= 1:
		loot.append(make_item("mouse_trap", 100, true, false))
	if inventory_count("screwdriver") > 0 and rng.randi_range(1, 100) <= 10:
		loot.append(make_item("nuts_metal", 100, true, false))
	if inventory_count("wire_cutter") > 0 and rng.randi_range(1, 100) <= 10:
		loot.append(make_item("wire", 100, true, false))
	if inventory_count("welder") > 0 and rng.randi_range(1, 100) <= 10:
		loot.append(make_item("scrap_metal", 100, true, false))
	var double_chance := float(afterhour_mods.get("loot_double_chance", 0))
	if inventory_count("metal_scanner") > 0:
		double_chance += 15.0
	if double_chance > 0.0 and rng.randf() * 100.0 < double_chance:
		loot.append(make_item(_roll_scav_item(), rng.randi_range(45, 100), true, false))
	return loot

func scavenge_dumping_ground() -> Dictionary:
	if afterhours_location != "dumping_ground":
		return {"ok": false, "text": "你不在垃圾倾倒场。"}
	if scav_attempts_left() <= 0:
		return {"ok": false, "text": "今晚已经搜不动了。"}
	if not wound_stable:
		return {"ok": false, "text": "伤口还在流血，先处理伤口。"}
	var minor := scav_minor_chance()
	var major := scav_major_chance()
	scav_attempts_used += 1
	run_stats["scavenge_attempts"] = int(run_stats.get("scavenge_attempts", 0)) + 1
	var roll := rng.randf() * 100.0
	if roll < minor:
		gain_wound(false)
		_add_night_log("拾荒时被碎屑划伤。")
		emit_signal("state_changed")
		return {"ok": true, "wounded": "minor", "text": "碎屑划伤了你，今晚还剩 %d 次搜索。" % scav_attempts_left()}
	if roll < minor + major:
		gain_wound(true)
		_add_night_log("拾荒时被重物砸伤。")
		emit_signal("state_changed")
		return {"ok": true, "wounded": "major", "text": "重物砸中了你，伤势严重！今晚还剩 %d 次搜索。" % scav_attempts_left()}
	var loot := _roll_scav_loot()
	var names: Array = []
	var value := 0
	for it in loot:
		it["known"] = false
		add_item(it)
		names.append(item_display_name(it))
		value += effective_value(it)
	run_stats["scavenged_value"] = int(run_stats.get("scavenged_value", 0)) + value
	run_stats["best_find_value"] = maxi(int(run_stats.get("best_find_value", 0)), value)
	_add_night_log("拾荒所得：%s（约 %d₵）。" % ["、".join(names), value])
	emit_signal("state_changed")
	return {"ok": true, "loot": names, "value": value, "text": "翻找垃圾，找到：%s。今晚还剩 %d 次搜索。" % ["、".join(names), scav_attempts_left()]}

func _refresh_jackson_stock() -> void:
	jackson_stock = []
	var pool := ["blank_module", "common_electronic", "chem_module", "bandage_item", "salve", "water_test_strip", "flashlight", "magnifier", "common_ore", "metal_ingot"]
	for i in range(4):
		var id := String(pool[rng.randi_range(0, pool.size() - 1)])
		var it := make_item(id, rng.randi_range(70, 100), true, false)
		it["known"] = true
		var price := maxi(5, int(round(float(market_value(it, false, "upper")) * 1.35)))
		jackson_stock.append({"item": it, "price": price})

func jackson_buy(index: int) -> Dictionary:
	if afterhours_location != "dr_jackson":
		return {"ok": false, "text": "你不在杰克逊医生那里。"}
	if index < 0 or index >= jackson_stock.size():
		return {"ok": false, "text": "没有这件货。"}
	var entry: Dictionary = jackson_stock[index]
	var price := int(entry.get("price", 0))
	if cash < price:
		return {"ok": false, "text": "现金不足，需要 %d₵。" % price}
	cash -= price
	var it: Dictionary = entry.get("item", {})
	it["location"] = "backpack"
	add_item(it)
	jackson_stock.remove_at(index)
	_add_night_log("从杰克逊医生处购入 %s（%d₵）。" % [item_display_name(it), price])
	emit_signal("state_changed")
	return {"ok": true, "text": "买下 %s，花费 %d₵。" % [item_display_name(it), price]}


func _append_rep_perk_customers(list: Array) -> void:
	var wd := day % 7
	if rep_perk_unlocked("BM_RELIABLE"):
		if wd == 1:
			var c1 := _gen_perk_sell_customer("thief", "小偷")
			if not c1.is_empty():
				list.append(c1)
		if rng.randi_range(1, 100) <= 20:
			var c2 := _gen_perk_sell_customer("pettyThief", "小毛贼")
			if not c2.is_empty():
				list.append(c2)
	if rep_perk_unlocked("BM_SMALL_TIME_BROKER") and rng.randi_range(1, 100) <= 25:
		var c3 := _gen_perk_sell_customer("thief", "掮客带来的小偷")
		if not c3.is_empty():
			list.append(c3)
	if rep_perk_unlocked("LLRAREGOOD") and wd in [1, 5]:
		if rng.randi_range(1, 100) <= 50:
			list.append(_gen_rare_merchant())
		elif rng.randi_range(1, 100) <= 25:
			var seller := make_item("handmade_pistol", rng.randi_range(70, 100), true, false)
			seller["known"] = false
			list.append({
				"arche": {"faction": "lower", "name": "枪贩", "sprite": _random_client_sprite("lower")},
				"intent": "wholesale", "patience": 3, "done": false,
				"wholesale_name": "枪贩", "wholesale_supplier": "",
				"wholesale_discount": -10, "wholesale_stock": [seller],
				"wholesale_free": false, "wholesale_done_key": "",
				"line": "家伙不错，价钱好说。",
			})
	if rep_perk_unlocked("REV_QUARTERMASTER") and wd == 0:
		list.append(_gen_rev_quartermaster())
	if rep_perk_unlocked("REV_RAID_LOOT") and wd == 5:
		list.append(_gen_rev_raider())
	if rep_perk_unlocked("SEC_REQUISITION") and wd == 4 and day > 7:
		list.append(_gen_sec_requisition())
	if rep_perk_unlocked("UL_HOUSEHOLD_NAME") and rng.randi_range(1, 100) <= 20:
		var cu := _gen_extra_upper()
		if not cu.is_empty():
			list.append(cu)
	if rep_perk_unlocked("UL_CHARITY") and charity_cooldown <= 0:
		list.append(_gen_charity_customer())
		charity_cooldown = 5
	if rep_perk_unlocked("UL_DISCERNING_TASTE") and day > 13 and discerning_cooldown <= 0 and _has_luxury_display():
		var chance := 1 + maxi(0, int(rep.get("upper", 0))) / 5
		if rng.randi_range(1, 100) <= chance:
			list.append(_gen_discerning_customer())
			discerning_cooldown = 5

func start_expedition() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "expedition":
		return {"ok": false, "text": "当前没有探险委托。"}
	var party_id := String(current_customer.get("party", "pirateRookieTriple"))
	var party: Dictionary = combat_parties.get(party_id, {})
	if party.is_empty():
		return {"ok": false, "text": "探险目标不存在。"}
	current_customer["done"] = true
	expedition_rooms = [
		{"name": "货舱", "party": party_id, "loot": true},
		{"name": "舰桥", "party": "pirateVeteranLeaderTriple", "loot": true},
	]
	expedition_room_index = 0
	expedition_loot_log = []
	raid_action_points = 100
	raid_turn = 1
	var first := String(party.get("enemies", ["pirate_rookie"])[0])
	start_combat(first, "lower", "", "expedition", party_id)
	emit_signal("state_changed")
	return {"ok": true, "text": "探险开始（第 1/%d 层）。" % expedition_rooms.size()}

func _expedition_grant_room_loot() -> void:
	if expedition_room_index < 0 or expedition_room_index >= expedition_rooms.size():
		return
	var room: Dictionary = expedition_rooms[expedition_room_index]
	if not bool(room.get("loot", false)):
		return
	room["loot"] = false
	var pool: Array = tradable_pool if not tradable_pool.is_empty() else ["scrap_metal", "printer_plastic", "water_bottle_full", "nutrifruit"]
	var got: Array = []
	for i in range(rng.randi_range(1, 2)):
		var did := String(pool[rng.randi_range(0, pool.size() - 1)])
		var it := make_item(did, rng.randi_range(60, 100), true, false)
		it["known"] = true
		add_item(it)
		got.append(item_display_name(it))
	var credits := rng.randi_range(20, 80)
	cash += credits
	expedition_loot_log.append("%s：%s，%d₵" % [String(room.get("name", "房间")), "、".join(got), credits])
	raid_action_points = 100
	raid_turn += 1

func advance_expedition() -> bool:
	_expedition_grant_room_loot()
	expedition_room_index += 1
	if expedition_room_index >= expedition_rooms.size():
		expedition_rooms = []
		expedition_room_index = 0
		return false
	var room: Dictionary = expedition_rooms[expedition_room_index]
	var party_id := String(room.get("party", "pirateRookieTriple"))
	var party: Dictionary = combat_parties.get(party_id, {})
	if party.is_empty():
		expedition_rooms = []
		return false
	var first := String(party.get("enemies", ["pirate_rookie"])[0])
	start_combat(first, "lower", "", "expedition", party_id)
	return true

func buy_information() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "information":
		return {"ok": false, "text": "当前没有情报商人。"}
	var cost := int(current_customer.get("service_cost", 50))
	if cash < cost:
		return {"ok": false, "text": "现金不足，需要 %d₵。" % cost}
	cash -= cost
	var tips: Array = []
	for w in wanted:
		if not wanted_defeated.has(String(w.get("id", ""))):
			tips.append("通缉目标：%s。悬赏 %d₵。" % [String(w.get("name", "")), int(w.get("reward", 0))])
	for type_id in market_modifiers.keys():
		var mv := int(market_modifiers[type_id])
		if absi(mv) >= 30:
			tips.append("%s 市场%s %d%%。" % [String(type_id), "短缺" if mv > 0 else "过剩", absi(mv)])
	if tips.is_empty():
		tips.append("治安部近期没有大动作。")
	var note := make_item("handnote", 100, true, false)
	note["custom_name"] = "情报便条"
	note["custom_desc"] = String(tips[rng.randi_range(0, tips.size() - 1)])
	note["known"] = true
	add_item(note)
	complete_customer(true)
	emit_signal("state_changed")
	return {"ok": true, "text": "你花了 %d₵，得到一张情报便条。" % cost}

func starting_perk_def(pid: String) -> Dictionary:
	for p in starting_perks:
		if String(p.get("id", "")) == pid:
			return p
	return {}

func _rebuild_starting_perk_effects() -> void:
	pass

func _load_run_meta() -> void:
	var f := FileAccess.open("user://run_meta.json", FileAccess.READ)
	if f == null:
		run_count = 0
		return
	var data = JSON.parse_string(f.get_as_text())
	if data is Dictionary:
		run_count = int(data.get("run_count", 0))

func record_new_game_start() -> void:
	run_count += 1
	var f := FileAccess.open("user://run_meta.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"run_count": run_count}))
		f.close()

func _new_run_stats() -> Dictionary:
	return {
		"total_sales": 0, "items_sold": 0, "stock_spent": 0, "customers_served": 0,
		"sales_by_day": {}, "best_day_sales": 0, "best_day": 0,
		"rent_paid": 0, "power_spent": 0, "insurance_spent": 0, "bribes": 0,
		"inspections": 0, "inspections_passed": 0, "goods_seized": 0,
		"burglaries": 0, "burglary_losses": 0, "scavenge_attempts": 0,
		"scavenged_value": 0, "injuries_minor": 0, "injuries_major": 0,
		"criminals_reported": 0, "perfect_appraisals": 0, "augs_shot": 0,
		"wrongful_reports": 0, "items_bought": 0, "best_flip_value": 0,
		"best_find_value": 0, "days_played": 1, "net_worth_by_day": {},
	}

func net_worth() -> int:
	var total := cash
	for it in inventory:
		total += effective_value(it)
	for it in display:
		total += effective_value(it)
	return total

func _check_achievements() -> void:
	if net_worth() > 10000:
		unlock_achievement("ACH_SETTLED")
	if net_worth() > 100000:
		unlock_achievement("ACH_RICH")
	if store_attractiveness() >= 1000:
		unlock_achievement("ACH_SHINY")
	if int(ach_stats.get("criminals_reported", 0)) >= 10:
		unlock_achievement("ACH_MODEL_CITIZEN")
	if int(ach_stats.get("augs_shot", 0)) >= 10:
		unlock_achievement("ACH_AUG_HUNTER")
	if int(ach_stats.get("perfect_appraisals", 0)) >= 10:
		unlock_achievement("ACH_MASTER_APPRAISER")
	for mid in machine_modules.keys():
		if int(machine_module_sums(String(mid)).get("quality", 0)) >= 250:
			unlock_achievement("ACH_OVERLOAD")
			break
	var machine_ids := {}
	for m in machines:
		machine_ids[String(m.get("id", ""))] = true
	var machines_owned := 0
	for it in inventory:
		if machine_ids.has(String(it.get("def_id", ""))):
			machines_owned += 1
	if machines_owned >= 10:
		unlock_achievement("ACH_INDUSTRIOUS")
	for f in rep.keys():
		if int(rep[f]) >= 200:
			unlock_achievement("ACH_PERFECT_MEDIATOR")
			break

func unlock_achievement(aid: String) -> bool:
	if aid == "" or achievements_unlocked.has(aid):
		return false
	achievements_unlocked[aid] = day
	emit_signal("achievement_unlocked", aid)
	emit_signal("state_changed")
	return true

func survival_accuracy_mod() -> int:
	if thirst <= 0:
		return -6
	if thirst <= 150:
		return -4
	if thirst <= 500:
		return -2
	if thirst >= 800:
		return 5
	return 0

func addiction_active_count() -> int:
	var n := 0
	for k in addiction_days.keys():
		if int(addiction_days[k]) >= 3 and bool(perk_flags.get("addiction_" + String(k), false)):
			n += 1
	return mini(3, n)

func addiction_price_mod() -> float:
	return float(addiction_active_count()) * 0.08

func gain_wound(major: bool = false) -> void:
	wounds = mini(10, wounds + (5 if major else 2))
	wound_stable = false
	ach_stats["injuries_major" if major else "injuries_minor"] = int(ach_stats.get("injuries_major" if major else "injuries_minor", 0)) + 1

func nightly_survival() -> void:
	thirst = maxi(0, thirst - 70)
	for k in addiction_days.keys():
		addiction_days[k] = mini(999, int(addiction_days[k]) + 1)
		if int(addiction_days[k]) >= 20 and bool(perk_flags.get("addiction_" + String(k), false)):
			perk_flags.erase("addiction_" + String(k))
	if int(narcotic_relief) < 999:
		narcotic_relief = mini(999, int(narcotic_relief) + 1)
	if wound_stable:
		wounds = maxi(0, wounds - 4)
	else:
		if rng.randi_range(1, 100) <= 10:
			wounds = mini(10, wounds + 1)
		elif rng.randi_range(1, 100) <= 50:
			wound_stable = true
	if bool(perk_flags.get("sentinel", false)):
		sentinel_days += 1
		var gain := 0
		if sentinel_days >= 14:
			gain = 3
		elif sentinel_days >= 10:
			gain = 2
		elif sentinel_days >= 7:
			gain = 1
		sentinel_pool += gain
		if sentinel_days >= 6 and gain == 0:
			_add_night_log("哨兵注射剂在体内滴答作响。")
		if sentinel_pool >= 20:
			phase = "gameover"
			ending_id = "sentinel"
			_add_night_log("哨兵注射剂到期了。")
	if aug_introduced and aug_presence >= 100:
		phase = "gameover"
		ending_id = "aug"
		_add_night_log("义体人控制了空间站。")

func _water_ml_for(def_id: String) -> int:
	match def_id:
		"bottled_water": return 750
		"small_bottled_water": return 450
		"mini_bottle": return 250
		"large_bottled_water": return 2000
		"water_jug": return 6000
		"water_ration": return 750
		"water_ration_small": return 375
		"water_bottle_full": return 1000
		"water_bottle_empty": return 0
		"energy_drink", "galaxy_blend": return 350
		"cup_noodle": return 375
	return 0

func _addiction_kind_for(def_id: String) -> String:
	if def_id in ["packet_red_cigarette", "cig_red", "cig_black", "cigarette"]:
		return "nicotine"
	if def_id in ["red_beer", "nudka", "wine_bottle", "wine", "moonshine"]:
		return "alcohol"
	if def_id in ["fanta_pill", "dream_dust", "pink_injector", "pink_alt_injector"]:
		return "narcotic"
	return ""

func _addiction_value_for(def_id: String) -> int:
	match def_id:
		"packet_red_cigarette", "cig_red", "cig_black", "cigarette": return 3
		"red_beer": return 1
		"nudka": return 4
		"wine_bottle", "wine": return 4
		"fanta_pill": return 3
		"dream_dust": return 1
		"pink_injector", "pink_alt_injector": return 1
	return 0

func fill_liquid_from_faucet(uid: int) -> Dictionary:
	var it := find_item(uid)
	if it.is_empty() or not is_liquid_container(it):
		return {"ok": false, "text": "这不是液体容器。"}
	var cap := int(container_spec(it).get("capacity_ml", 0))
	if cap <= 0:
		cap = int(it.get("liquid_ml", 1000))
	var need := maxi(0, cap - int(it.get("liquid_ml", 0)))
	if need <= 0:
		return {"ok": false, "text": "容器已经满了。"}
	if store_water_ml < need:
		return {"ok": false, "text": "今天的水龙头只剩 %d ml。" % store_water_ml}
	store_water_ml -= need
	it["liquid_ml"] = cap
	it["liquid_purity"] = 10000
	it["liquid_contents"] = {"water": cap}
	emit_signal("state_changed")
	return {"ok": true, "text": "灌满 %s（%d ml）。" % [item_display_name(it), need]}

func drain_liquid_container(uid: int) -> Dictionary:
	var it := find_item(uid)
	if it.is_empty() or not is_liquid_container(it):
		return {"ok": false, "text": "这不是液体容器。"}
	var ml := int(it.get("liquid_ml", 0))
	if ml <= 0:
		return {"ok": false, "text": "容器已经空了。"}
	it["liquid_ml"] = 0
	it["liquid_purity"] = 10000
	it["liquid_contents"] = {}
	emit_signal("state_changed")
	return {"ok": true, "text": "倒空 %s（%d ml）。" % [item_display_name(it), ml]}

func can_use_consumable(it: Dictionary) -> bool:
	var did := String(it.get("def_id", ""))
	if did in ["black_injector", "large_purple_injector", "packet_red_cigarette", "cig_red", "cig_black", "cigarette", "fanta_pill", "dream_dust", "pink_injector", "pink_alt_injector", "labeler", "labeler_blue"]:
		return true
	var cat := String(get_item_def(did).get("category", ""))
	if _water_ml_for(did) > 0:
		return true
	return cat in ["food", "medical"] and not did.contains("container")

func relabel_item(uid: int, label: String) -> Dictionary:
	var it := find_item(uid)
	if it.is_empty():
		return {"ok": false, "text": "物品不存在。"}
	if label.strip_edges() == "":
		return {"ok": false, "text": "标签不能为空。"}
	if label.length() > 24:
		label = label.substr(0, 24)
	it["custom_name"] = label.strip_edges()
	unlock_achievement("ACH_LOWER_LEVELS_SPECIAL")
	emit_signal("state_changed")
	return {"ok": true, "text": "已贴标：%s。" % it["custom_name"]}

func use_consumable(uid: int) -> Dictionary:
	var it := find_item(uid)
	if it.is_empty():
		return {"ok": false, "text": "物品不存在。"}
	var did := String(it.get("def_id", ""))
	if did in ["green_injector", "blue_injector", "red_injector", "turquoise_injector"]:
		if did == "turquoise_injector":
			next_combat_accuracy_bonus += 5
			remove_inventory(did, 1)
			emit_signal("state_changed")
			return {"ok": true, "text": "注射了绿松石注射剂：下一场战斗命中 +5。"}
		wounds = maxi(0, wounds - 1)
		wound_stable = true
		remove_inventory(did, 1)
		emit_signal("state_changed")
		return {"ok": true, "text": "注射了%s，伤口开始愈合。" % item_display_name(it)}
	if did.contains("berry") or did == "ribwich":
		remove_inventory(did, 1)
		thirst = mini(thirst_max, thirst + 120)
		emit_signal("state_changed")
		return {"ok": true, "text": "吃下%s，饥饿与口渴稍有缓解。" % item_display_name(it)}
	if did in ["scratcher", "scratcher_stack", "lottery_ticket"]:
		var payout := 0
		var roll := rng.randi_range(1, 100)
		if roll > 97:
			payout = rng.randi_range(350, 600)
		elif roll > 85:
			payout = rng.randi_range(80, 260)
		elif roll > 55:
			payout = rng.randi_range(10, 60)
		cash += payout
		remove_inventory(did, 1)
		if payout >= 350:
			unlock_achievement("ACH_LUCKY")
		emit_signal("state_changed")
		return {"ok": true, "text": "刮开%s：%s" % [item_display_name(it), ("中奖 %d₵！" % payout) if payout > 0 else "谢谢惠顾。"]}
	if did == "black_injector":
		var kinds: Array = []
		for k in addiction_days.keys():
			if bool(perk_flags.get("addiction_" + String(k), false)):
				kinds.append(k)
		if kinds.is_empty():
			return {"ok": false, "text": "你没有需要戒断的成瘾。"}
		var pick := String(kinds[rng.randi_range(0, kinds.size() - 1)])
		perk_flags.erase("addiction_" + pick)
		addiction_days[pick] = 0
		remove_inventory(did, 1)
		emit_signal("state_changed")
		return {"ok": true, "text": "Synaprest 清除了%s成瘾。" % pick}
	if did == "large_purple_injector":
		sentinel_days = 0
		sentinel_pool = 0
		remove_inventory(did, 1)
		emit_signal("state_changed")
		return {"ok": true, "text": "Immunivax 重置了哨兵注射剂计时。"}
	var ml := _water_ml_for(did)
	if ml > 0:
		if thirst >= thirst_max and ml < 1000:
			return {"ok": false, "text": "你并不口渴。"}
		var gain := mini(ml, thirst_max - thirst)
		thirst = mini(thirst_max, thirst + gain)
		remove_inventory(did, 1)
		emit_signal("state_changed")
		return {"ok": true, "text": "喝下%s，解渴 %d ml。" % [item_display_name(it), gain]}
	var kind := _addiction_kind_for(did)
	if kind != "":
		var val := _addiction_value_for(did)
		addiction_days[kind] = -val
		perk_flags["addiction_" + kind] = true
		if kind == "narcotic":
			narcotic_relief = 0
		remove_inventory(did, 1)
		emit_signal("state_changed")
		return {"ok": true, "text": "使用了%s，%s成瘾暂时缓解。" % [item_display_name(it), kind]}
	var cat := String(get_item_def(did).get("category", ""))
	if cat in ["food", "medical"]:
		remove_inventory(did, 1)
		if did.contains("bandage") and wounds > 0:
			wound_stable = true
			wounds = maxi(0, wounds - 1)
		emit_signal("state_changed")
		return {"ok": true, "text": "使用了%s。" % item_display_name(it)}
	return {"ok": false, "text": "这个物品不能直接使用。"}

func unlock_hireling() -> void:
	if not hireling.is_empty():
		return
	hireling = {"id": "hireling_juan", "name": "Juan", "health": 100, "max_health": 100, "status": "available", "days_away": 0, "log": ""}
	if not bool(perk_flags.get("expedition_unlocked", false)):
		perk_flags["expedition_unlocked"] = true

func rep_perk_def(pid: String) -> Dictionary:
	for p in rep_perk_defs:
		if String(p.get("id", "")) == pid:
			return p
	return {}

func rep_perk_unlocked(pid: String) -> bool:
	var d := rep_perk_def(pid)
	if d.is_empty():
		return false
	if pid == "BM_HONOR":
		return true
	var faction := "lower"
	if pid.begins_with("SEC_"):
		faction = "security"
	elif pid.begins_with("BM_"):
		faction = "blackmarket"
	elif pid.begins_with("UL_"):
		faction = "upper"
	elif pid.begins_with("REV_"):
		faction = "rev"
	elif pid.begins_with("CARTEL_"):
		faction = "cartel"
	var value := int(rep.get(faction, 0))
	var threshold := int(d.get("threshold", 0))
	var ptype := int(d.get("type", -1 if threshold < 0 else 1))
	if ptype < 0:
		return value <= threshold
	return value >= threshold

func starting_perk_active(pid: String) -> bool:
	return bool(perk_flags.get(pid, false)) or starting_perk_ids.has(pid)

func can_bargain() -> bool:
	return not bool(perk_flags.get("awful_negotiator", false))

func customer_count_modifier() -> int:
	var mod := 0
	if rep_perk_unlocked("LLPOORREVIEWS"):
		mod -= 1
	if rep_perk_unlocked("LLREFERAL"):
		mod += 1
	if starting_perk_active("perk_side_street"):
		mod -= 1
	if starting_perk_active("perk_prime_real_estate"):
		mod += 1
	if went_out_last_night and not starting_perk_active("perk_short_sleeper"):
		mod -= 1
	return mod

func tinkerer_material_saved() -> bool:
	return starting_perk_active("perk_tinkerer") and rng.randi_range(1, 100) <= 20

func can_read_guides() -> bool:
	return not bool(perk_flags.get("illiterate", false))

func insurance_blocked() -> bool:
	return rep_perk_unlocked("BM_UNINSURABLE")

func rep_budget_mult(faction: String) -> float:
	var mult := 1.0
	if faction == "upper":
		if rep_perk_unlocked("UL_TOP_REVIEW"):
			mult *= 1.25
		if starting_perk_active("perk_sycophant"):
			mult *= 1.10
	if rep_perk_unlocked("SEC_RELIABLE_VENDOR"):
		mult *= 1.5
	return mult

func upgrade_cost_mult() -> float:
	var mult := 1.0
	if rep_perk_unlocked("LLPILLAR"):
		mult *= 0.85
	if starting_perk_active("perk_wild_favorite"):
		mult *= 0.9
	if starting_perk_active("perk_wild_bad_side"):
		mult *= 1.1
	return mult

func insurance_daily_cost() -> int:
	var cost := 15.0
	if rep_perk_unlocked("LLTARGET"):
		cost *= 2.0
	if starting_perk_active("perk_wild_favorite"):
		cost *= 0.5
	if starting_perk_active("perk_wild_bad_side"):
		cost *= 1.5
	return maxi(1, int(round(cost)))

func burglary_chance() -> int:
	if starting_perk_active("perk_alert") or sec_perk_unlocked("SEC_VIP"):
		return 0
	var chance := 15
	if sec_perk_unlocked("SEC_PROTECTION"):
		chance -= 16
	if rep_perk_unlocked("LLTARGET"):
		chance += 15
	return clampi(chance, 0, 90)

func can_know_faction_operation(faction: String) -> bool:
	match faction:
		"lower":
			return rep_perk_unlocked("LLTIPS")
		"security":
			return sec_perk_unlocked("SEC_TRUSTED")
		"upper":
			return rep_perk_unlocked("UL_GOSSIP")
		"rev":
			return rep_perk_unlocked("REV_FRIEND")
		"blackmarket":
			return rep_perk_unlocked("BM_NETWORK")
	return true

func operation_label(op: Dictionary) -> String:
	if can_know_faction_operation(String(op.get("faction", ""))):
		return String(op.get("name", ""))
	return "不明派系行动"


func procurement_template(tid: String) -> Dictionary:
	for t in procurement_defs.get("templates", []):
		if String(t.get("id", "")) == tid:
			return t
	return {}

func hireling_status_text() -> String:
	if hireling.is_empty():
		return "没有雇员。"
	var st := String(hireling.get("status", "available"))
	match st:
		"away": return "Juan 外出探险中（%d 天）。" % int(hireling.get("days_away", 0))
		"injured": return "Juan 受伤休养中（生命 %d/%d）。" % [int(hireling.get("health", 0)), int(hireling.get("max_health", 100))]
		"complete": return "Juan 已返回，等待汇报。"
	return "Juan 待命中（生命 %d/%d）。" % [int(hireling.get("health", 0)), int(hireling.get("max_health", 100))]

func dispatch_hireling() -> Dictionary:
	if hireling.is_empty():
		return {"ok": false, "text": "还没有雇员。先选择“探险组织者”天赋。"}
	if String(hireling.get("status", "available")) != "available":
		return {"ok": false, "text": hireling_status_text()}
	hireling["status"] = "away"
	hireling["days_away"] = 1
	hireling["reported"] = false
	hireling_expedition = {"loot": [], "log": "", "injury": 0}
	_add_night_log("Juan 出发前往垃圾场探险。")
	emit_signal("state_changed")
	return {"ok": true, "text": "Juan 已出发，预计明天返回。"}

func _resolve_hireling_expedition() -> void:
	if hireling.is_empty() or String(hireling.get("status", "")) != "away":
		return
	var lines: Array = []
	var loot: Array = []
	var pools := [
		["scrap_metal", "debris_pile1", "printer_plastic"],
		["scrap_metal", "printer_plastic", "common_electronic"],
		["common_electronic", "metal_ingot", "printer_chip_pistol"],
	]
	var attempts := 3 + int(afterhour_mods.get("scav_attempts", 0))
	for i in range(attempts):
		if rng.randi_range(1, 100) <= 85:
			var pool: Array = pools[i % pools.size()]
			var did := String(pool[rng.randi_range(0, pool.size() - 1)])
			var it := make_item(did, 100, true, false)
			it["known"] = true
			add_item(it)
			loot.append(item_display_name(it))
			lines.append("找到 %s。" % item_display_name(it))
		else:
			if int(afterhour_mods.get("injury_immunity", 0)) > 0:
				lines.append("遇到事故，但安然无恙。")
			else:
				var dmg := rng.randi_range(5, 8)
				hireling["health"] = maxi(0, int(hireling.get("health", 100)) - dmg)
				lines.append("遭遇事故，受伤 %d。" % dmg)
	var log_text := "
".join(lines)
	hireling_expedition = {"loot": loot, "log": log_text, "injury": 1 if int(hireling.get("health", 100)) <= 50 else 0}
	hireling["status"] = "complete"
	if int(hireling.get("health", 100)) <= 50:
		hireling["status"] = "injured"
	_add_night_log("Juan 的探险报告：" + log_text)

func _gen_hireling_return_customer() -> Dictionary:
	var log_text := String(hireling_expedition.get("log", "这次什么也没找到。"))
	var note := make_item("handnote", 100, true, false)
	note["custom_name"] = "探险日志"
	note["custom_desc"] = log_text
	note["known"] = true
	add_item(note)
	hireling["status"] = "available" if String(hireling.get("status", "")) == "complete" else String(hireling.get("status", "available"))
	hireling_expedition = {}
	return {
		"arche": {"faction": "lower", "name": "Juan"},
		"intent": "hireling_return", "done": false, "patience": 3,
		"line": log_text,
	}

func _maybe_introduce_aug() -> void:
	if not aug_introduced and day >= 12:
		aug_introduced = true
		aug_presence = 15
		aug_next_spawn_day = day + rng.randi_range(2, 4)
		_add_night_log("治安部发布义体人通报：义体人开始出现在站内。")
	if aug_introduced and aug_next_spawn_day <= 0:
		aug_next_spawn_day = day + 6

func _gen_aug_customer() -> Dictionary:
	var tier := 1
	var t := clampf(float(day - 12) / 100.0, 0.0, 1.0)
	var roll := rng.randi_range(1, 100)
	if roll <= int(lerpf(5.0, 75.0, t)):
		tier = 1
	elif roll <= int(lerpf(20.0, 100.0, t)):
		tier = 2
	else:
		tier = 3 if roll > 90 else 4
	var name := "普通顾客"
	if tier >= 3:
		name = "体面的顾客"
	var is_aug := rng.randi_range(1, 100) <= 80
	var tell := 0
	if is_aug:
		var tr := rng.randi_range(1, 100)
		if tr < 35:
			tell = 1
		elif tr < 75:
			tell = 2
		else:
			tell = 0
	var budget := rng.randi_range(150, 250)
	return {
		"arche": {"faction": "lower" if tier <= 2 else "upper", "name": name},
		"intent": "buy", "want_tags": ["MEDICAL"], "exclude_contraband": false,
		"budget": budget, "offer": budget, "max_price": budget,
		"done": false, "patience": 3, "is_aug": is_aug, "aug_tier": tier,
		"aug_scanned": false, "aug_tell": tell,
		"line": "我需要一些医疗用品。" if tier <= 2 else "你这里有什么好药？",
	}

func scan_aug_customer() -> Dictionary:
	if current_customer.is_empty():
		return {"ok": false, "text": "当前没有顾客。"}
	if inventory_count("aug_scanner") <= 0:
		return {"ok": false, "text": "没有义体扫描仪。"}
	if bool(current_customer.get("aug_scanned", false)):
		return {"ok": false, "text": "已经扫描过了。"}
	if power < 25:
		return {"ok": false, "text": "电力不足：需要 25。"}
	power -= 25
	current_customer["aug_scanned"] = true
	var is_aug := bool(current_customer.get("is_aug", false))
	emit_signal("state_changed")
	return {"ok": true, "text": "扫描结果：%s" % ("检测到义体信号。" if is_aug else "没有检测到义体信号。")}

func threaten_aug() -> Dictionary:
	if current_customer.is_empty():
		return {"ok": false, "text": "当前没有顾客。"}
	if not aug_introduced:
		return {"ok": false, "text": "你还不知道怎么威胁义体人。"}
	if bool(current_customer.get("aug_threatened", false)):
		return {"ok": false, "text": "已经威胁过了。"}
	current_customer["aug_threatened"] = true
	if bool(current_customer.get("is_aug", false)):
		current_customer["aug_threat"] = 20
		add_rep("security", -2)
		return {"ok": true, "text": "义体人沉默片刻，接受了你的条件（+20%）。"}
	if rng.randi_range(1, 100) <= 50:
		add_rep("blackmarket", -10)
		add_rep("security", -10)
		var name := String(current_customer.get("arche", {}).get("name", "顾客"))
		complete_customer(false)
		return {"ok": true, "text": "%s 不是义体人，被激怒了，转身离开。" % name}
	add_rep("blackmarket", -7)
	return {"ok": true, "text": "对方被吓住了，但你的名声受损。"}

func report_aug() -> Dictionary:
	if current_customer.is_empty() or not bool(current_customer.get("is_aug", false)):
		ach_stats["wrongful_reports"] = int(ach_stats.get("wrongful_reports", 0)) + 1
		add_rep("security", -10)
		add_rep("blackmarket", -5)
		complete_customer(false)
		return {"ok": false, "text": "治安部赶来后一无所获，你被记了一次误报。"}
	var reward := clampi(100 + int(day) - 12, 100, 250)
	if bool(perk_flags.get("aug_menace", false)):
		reward = int(round(float(reward) * 1.25))
	cash += reward
	add_rep("security", 8)
	add_rep("rev", 2)
	add_rep("blackmarket", 2)
	aug_presence = maxi(0, aug_presence - 25)
	ach_stats["augs_shot"] = int(ach_stats.get("augs_shot", 0)) + 1
	ach_stats["criminals_reported"] = int(ach_stats.get("criminals_reported", 0)) + 1
	_check_achievements()
	_add_night_log("举报义体人：奖励 %d₵。" % reward)
	complete_customer(false)
	emit_signal("state_changed")
	return {"ok": true, "text": "治安部确认了义体信号，支付了 %d₵ 赏金。" % reward}

func _gun_condition_key(value) -> String:
	var conds: Dictionary = gun_defs.get("conditions", {})
	if value is String and conds.has(value):
		return value
	var n := int(value)
	if n >= 90:
		return "new"
	if n >= 75:
		return "excellent"
	if n >= 55:
		return "good"
	if n >= 35:
		return "fair"
	return "poor"

func gun_def_stats(def_id: String, condition = "") -> Dictionary:
	var g: Dictionary = gun_defs.get("guns", {}).get(def_id, {}).duplicate()
	if g.is_empty():
		return {}
	var cond_value = condition
	if cond_value == null:
		cond_value = g.get("condition", "good")
	elif cond_value is String and cond_value == "":
		cond_value = g.get("condition", "good")
	var cond := _gun_condition_key(cond_value)
	var cond_pct := int(gun_defs.get("conditions", {}).get(cond, 0))
	var shape: Array = get_item_def(def_id).get("shape", [1, 1])
	g["size"] = int(shape[0]) * int(shape[1])
	g["suppressed"] = 0
	g["caliber"] = int(g.get("caliber", 0))
	for k in ["firepower", "style", "reliability", "recoil", "ergonomics", "accuracy"]:
		g[k] = int(round(float(g.get(k, 0)) * (100.0 + cond_pct) / 100.0))
	g["condition"] = cond
	return g

func gun_mod_def(mod_id: String) -> Dictionary:
	return gun_mod_defs.get("mods", {}).get(mod_id, {})

func gun_mod_slot(mod_id: String) -> String:
	return String(gun_mod_def(mod_id).get("slot", ""))

func gun_item_stats(it: Dictionary) -> Dictionary:
	var g := gun_def_stats(String(it.get("def_id", "")), _gun_condition_key(it.get("condition", 100)))
	if g.is_empty():
		return {}
	var mods: Dictionary = it.get("gun_mods", {})
	for slot in mods.keys():
		var mid := String(mods[slot].get("def_id", ""))
		var md := gun_mod_def(mid)
		if md.is_empty():
			continue
		var stats: Dictionary = md.get("stats", {})
		for k in stats.keys():
			g[k] = int(g.get(k, 0)) + int(stats[k])
		if bool(md.get("suppressor", false)):
			g["suppressed"] = 1
	g["mod_count"] = mods.size()
	g["mag_size"] = gun_mag_size(it)
	return g

func gun_mag_size(it: Dictionary) -> int:
	var def_id := String(it.get("def_id", ""))
	var base := int(gun_defs.get("guns", {}).get(def_id, {}).get("mag_size", 8))
	var mods: Dictionary = it.get("gun_mods", {})
	if mods.has("magazine"):
		var md := gun_mod_def(String(mods["magazine"].get("def_id", "")))
		base += int(md.get("mag_bonus", 0))
	return maxi(1, base)

func gun_ammo_for_caliber(caliber: int) -> String:
	return String(gun_mod_defs.get("ammo_by_caliber", {}).get(str(caliber), ""))

func gun_mod_allowed(md: Dictionary, gun_def_id: String) -> bool:
	var allow: Array = md.get("allow", [])
	return allow.is_empty() or allow.has(gun_def_id)

func gun_install_mod(gun_uid: int, mod_uid: int) -> Dictionary:
	var gun := find_item(gun_uid)
	var mod := find_item(mod_uid)
	if gun.is_empty() or mod.is_empty():
		return {"ok": false, "text": "找不到枪械或配件。"}
	var mid := String(mod.get("def_id", ""))
	var md := gun_mod_def(mid)
	if md.is_empty():
		return {"ok": false, "text": "这不是枪械配件。"}
	if not gun_mod_allowed(md, String(gun.get("def_id", ""))):
		return {"ok": false, "text": "这个配件不能装在这把枪上。"}
	var slot := String(md.get("slot", ""))
	if slot == "":
		return {"ok": false, "text": "没有可用槽位。"}
	var mods: Dictionary = gun.get("gun_mods", {})
	if mods.has(slot):
		return {"ok": false, "text": "该槽位已有配件，请先卸下。"}
	var ex := String(md.get("exclusive", ""))
	if ex != "":
		for s in mods.keys():
			if String(gun_mod_def(String(mods[s].get("def_id", ""))).get("exclusive", "")) == ex:
				return {"ok": false, "text": "与其他配件互斥。"}
	var detached := detach_item(mod_uid)
	if detached.is_empty():
		return {"ok": false, "text": "无法取下这个配件。"}
	mods[slot] = {"def_id": mid}
	gun["gun_mods"] = mods
	emit_signal("state_changed")
	return {"ok": true, "text": "已安装 %s 到%s槽。" % [item_display_name(detached), slot]}

func gun_remove_mod(gun_uid: int, slot: String) -> Dictionary:
	var gun := find_item(gun_uid)
	if gun.is_empty():
		return {"ok": false, "text": "找不到枪械。"}
	var mods: Dictionary = gun.get("gun_mods", {})
	if not mods.has(slot):
		return {"ok": false, "text": "这个槽位没有配件。"}
	var mid := String(mods[slot].get("def_id", ""))
	var it := make_item(mid, 100, true, false)
	it["known"] = true
	if not add_item(it):
		return {"ok": false, "text": "背包空间不足，无法卸下。"}
	mods.erase(slot)
	gun["gun_mods"] = mods
	emit_signal("state_changed")
	return {"ok": true, "text": "已卸下 %s。" % item_display_name(it)}

func gun_mod_gun_list() -> Array:
	var out: Array = []
	for it in _iter_inventory_items():
		if not gun_def_stats(String(it.get("def_id", ""))).is_empty():
			out.append({"id": str(int(it.get("uid", -1))), "label": item_display_name(it)})
	return out

func gun_owned_mods_for(gun_item: Dictionary, slot: String) -> Array:
	var out: Array = []
	for it in _iter_inventory_items():
		var mid := String(it.get("def_id", ""))
		var md := gun_mod_def(mid)
		if md.is_empty() or String(md.get("slot", "")) != slot:
			continue
		if not gun_mod_allowed(md, String(gun_item.get("def_id", ""))):
			continue
		out.append({"id": str(int(it.get("uid", -1))), "label": item_display_name(it)})
	return out

func _gun_tier_for_faction(faction: String) -> int:
	return int(gun_order_defs.get("faction_tier", {}).get(faction, 1))

func _player_has_tier_gun(tier: int) -> bool:
	var ids: Array = gun_order_defs.get("tier_guns", {}).get(str(tier), [])
	for it in inventory:
		if ids.has(String(it.get("def_id", ""))):
			return true
	return false

func _roll_faction_operation() -> void:
	if faction_ops.is_empty() or rng.randi_range(1, 100) > 12:
		return
	var pool: Array = []
	for op in faction_ops:
		if int(operation_cooldowns.get(String(op.get("id", "")), 0)) > day:
			continue
		pool.append(op)
	if pool.is_empty():
		return
	var op: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var oid := String(op.get("id", ""))
	operation_cooldowns[oid] = day + int(op.get("cooldown", 5))
	faction_power["bm"] = clampi(int(faction_power.get("bm", 0)) + int(op.get("bm", 0)), -100, 100)
	faction_power["rev"] = clampi(int(faction_power.get("rev", 0)) + int(op.get("rev", 0)), -100, 100)
	faction_power["sec"] = clampi(int(faction_power.get("sec", 0)) + int(op.get("sec", 0)), -100, 100)
	faction_power["civil_unrest"] = clampi(int(faction_power.get("civil_unrest", 0)) + int(op.get("unrest", 0)), -100, 100)
	active_operations.append({"id": oid, "faction": String(op.get("faction", "")), "name": String(op.get("name", oid)), "until": day + int(op.get("duration", 1))})
	if can_know_faction_operation(String(op.get("faction", ""))):
		_add_night_log("派系行动：%s" % String(op.get("name", oid)))
		emit_signal("news_ready", "站内新闻 · " + String(op.get("name", oid)), String(op.get("text", "")))
	else:
		_add_night_log("你察觉到不明派系正在行动，但不知道细节。")
	emit_signal("state_changed")

func _apply_afterhour_event() -> void:
	afterhour_mods = {}
	afterhour_today = ""
	var weekday := ((day - 1) % 7) + 1
	for ev in afterhour_defs:
		if int(ev.get("weekday", 0)) != weekday:
			continue
		afterhour_mods = ev.duplicate(true)
		afterhour_today = String(ev.get("id", ""))
		_add_night_log("夜间事件：%s" % String(ev.get("name", "")))
		emit_signal("news_ready", "夜间广播 · " + String(ev.get("name", "")), String(ev.get("text", "")))
		break

func _gen_gun_order_customer() -> Dictionary:
	var factions: Array = ["lower", "lower", "blackmarket", "upper", "rev"]
	var faction := String(factions[rng.randi_range(0, factions.size() - 1)])
	var tier := _gun_tier_for_faction(faction)
	var name := loc("ClientName", "name_gun_buyer", "枪械买家")
	if name == "" or name == "枪械买家":
		name = ["枪械买家", "佣兵", "上层收藏家"][tier - 1]
	var service_mode := rng.randf() < 0.5 and not _player_has_tier_gun(tier)
	if service_mode:
		var sv: Dictionary = gun_order_defs.get("service", {})
		var gids: Array = sv.get("guns", {}).get(str(tier), ["handmade_pistol"])
		var gun_id := String(gids[rng.randi_range(0, gids.size() - 1)])
		var conds: Array = sv.get("conditions", ["fair"])
		var cond := String(conds[rng.randi_range(0, conds.size() - 1)])
		var gun := make_item(gun_id, 100, true, false)
		gun["condition"] = cond
		gun["custom_name"] = "待修：" + item_display_name(gun)
		gun["service_order"] = true
		gun["service_parts_value"] = 0
		gun["known"] = true
		add_item(gun)
		var base_stats := gun_def_stats(gun_id, cond)
		var req: Dictionary = {}
		var stat_pool: Array = ["accuracy", "firepower", "reliability", "style"]
		var need := 1 if tier == 1 else 2
		for i in range(need):
			var st := String(stat_pool[rng.randi_range(0, stat_pool.size() - 1)])
			req[st] = int(base_stats.get(st, 0)) + 4
		var fee: int = int(sv.get("fees", [0, 30, 60, 100])[mini(tier, 3)])
		return {
			"arche": {"faction": faction, "name": name},
			"intent": "gun_order", "done": false, "patience": 3,
			"order_id": "svc_%d_%d" % [day, rng.randi_range(100, 999)],
			"tier": tier, "service": true, "gun_id": gun_id,
			"require": req, "bonuses": [], "base": fee + rng.randi_range(0, 9), "fee": fee,
			"line": "我这把枪要按规格整备好。",
		}
	var pool: Array = []
	for o in gun_order_defs.get("orders", []):
		if int(o.get("tier", 0)) == tier:
			pool.append(o)
	if pool.is_empty():
		return {}
	var order: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var o := order.duplicate(true)
	o["arche"] = {"faction": faction, "name": name}
	o["intent"] = "gun_order"
	o["done"] = false
	o["patience"] = 3
	o["service"] = false
	o["order_id"] = "gun_%d_%d" % [day, rng.randi_range(100, 999)]
	o["line"] = "我要一把符合这张订单的枪。"
	return o

func gun_order_candidates() -> Array:
	var out: Array = []
	for it in inventory:
		var did := String(it.get("def_id", ""))
		if gun_defs.get("guns", {}).has(did):
			out.append(it)
	for it in display:
		var did2 := String(it.get("def_id", ""))
		if gun_defs.get("guns", {}).has(did2):
			out.append(it)
	return out

func space_start(ship_id: String = "cargo_ship") -> Dictionary:
	var def := {}
	for sh in space_ships:
		if String(sh.get("id", "")) == ship_id:
			def = sh
			break
	if def.is_empty():
		return {"ok": false, "text": "没有这艘船。"}
	space_mode = true
	space_ship = def.duplicate(true)
	space_max_hull = int(def.get("hull", 100))
	space_hull = space_max_hull
	space_fuel = int(def.get("fuel", 50))
	space_day = 1
	space_poi = {}
	space_scanned = []
	space_log = ["登舰：%s（%s）" % [String(def.get("name", "")), String(def.get("class", ""))]]
	space_at_station = false
	space_raid_rooms = []
	space_raid_index = 0
	space_pending_reward = {}
	emit_signal("state_changed")
	return {"ok": true, "text": "已登舰：%s。" % String(def.get("name", ""))}

func space_leave() -> void:
	space_mode = false
	space_poi = {}
	space_scanned = []
	space_at_station = false
	emit_signal("state_changed")

func space_scan() -> Array:
	if space_pois.is_empty():
		return []
	var pool: Array = space_pois.duplicate(true)
	var out: Array = []
	while out.size() < 4 and not pool.is_empty():
		var idx2 := rng.randi_range(0, pool.size() - 1)
		out.append(pool[idx2])
		pool.remove_at(idx2)
	space_scanned = out
	return out

func space_travel(poi: Dictionary) -> Dictionary:
	if not space_mode:
		return {"ok": false, "text": "尚未登舰。"}
	var dist := int(poi.get("distance", 20))
	var speed := maxi(1, int(space_ship.get("speed", 10)))
	var fuel_cost := int(ceil(float(dist) / float(maxi(1, int(space_ship.get("speed", 10))))))
	if space_fuel < fuel_cost:
		return {"ok": false, "text": "燃料不足：需要 %d，当前 %d。" % [fuel_cost, space_fuel]}
	space_fuel -= fuel_cost
	space_day += maxi(1, int(ceil(float(dist) / float(speed))))
	space_poi = poi.duplicate(true)
	space_at_station = String(poi.get("kind", "")) == "station"
	space_log.append("抵达 %s（消耗燃料 %d）。" % [String(poi.get("name", "")), fuel_cost])
	emit_signal("state_changed")
	if space_at_station:
		return {"ok": true, "text": "抵达 %s，可以停靠。" % String(poi.get("name", "")), "station": true}
	if rng.randi_range(1, 100) <= 65:
		return {"ok": true, "encounter": _space_encounter(), "text": "途中遭遇事件。"}
	return {"ok": true, "text": "抵达 %s，航道上暂时没有异常。" % String(poi.get("name", ""))}

func _space_encounter() -> Dictionary:
	var kind := String(space_poi.get("kind", "empty"))
	var name := String(space_poi.get("name", "太空遭遇"))
	var options: Array = []
	match kind:
		"mining":
			options = [{"id": "mine", "label": "开采矿石"}, {"id": "leave", "label": "离开"}]
		"loot", "wreck":
			options = [{"id": "salvage", "label": "打捞"}, {"id": "leave", "label": "离开"}]
		"combat":
			options = [{"id": "fight", "label": "交战"}, {"id": "flee", "label": "逃离"}]
		"distress", "refugee":
			options = [{"id": "aid", "label": "援助"}, {"id": "rob", "label": "抢劫"}, {"id": "leave", "label": "离开"}]
		"fuel":
			options = [{"id": "fuel", "label": "抽取燃料"}, {"id": "leave", "label": "离开"}]
		"heal":
			options = [{"id": "heal", "label": "接受治疗"}, {"id": "leave", "label": "离开"}]
		"repair":
			options = [{"id": "repair", "label": "付费维修（30₵）"}, {"id": "leave", "label": "离开"}]
		"trade":
			options = [{"id": "trade", "label": "交易"}, {"id": "leave", "label": "离开"}]
		_:
			options = [{"id": "leave", "label": "继续航行"}]
	return {"title": name, "text": String(space_poi.get("desc", "")), "options": options}

func space_resolve(option_id: String) -> Dictionary:
	var kind := String(space_poi.get("kind", "empty"))
	var msg := "继续航行。"
	match option_id:
		"mine":
			var got: Array = []
			for i in range(2):
				var did: String = ["scrap_metal", "metal_ingot", "printer_plastic", "common_electronic"][rng.randi_range(0, 3)]
				var it := make_item(did, rng.randi_range(60, 100), true, false)
				it["known"] = true
				add_item(it)
				got.append(item_display_name(it))
			msg = "开采获得：%s。" % "、".join(got)
		"salvage":
			var did2: String = str(tradable_pool[rng.randi_range(0, maxi(0, tradable_pool.size() - 1))]) if not tradable_pool.is_empty() else "scrap_metal"
			var loot := make_item(did2, rng.randi_range(60, 100), true, false)
			loot["known"] = true
			add_item(loot)
			var credits := rng.randi_range(20, 90)
			cash += credits
			msg = "打捞获得：%s，%d₵。" % [item_display_name(loot), credits]
		"fight":
			var party := "pirateRookieTriple" if rng.randi_range(1, 100) <= 70 else "pirateVeteranLeaderTriple"
			space_pending_reward = {"cash": rng.randi_range(60, 180)}
			start_combat("pirate_rookie", "lower", "", "space_encounter", party)
			space_log.append("与海盗交战。")
			emit_signal("state_changed")
			return {"ok": true, "combat": true, "text": "战斗开始。"}
		"flee":
			var dmg := rng.randi_range(5, 15)
			space_hull = maxi(0, space_hull - dmg)
			msg = "逃离时船体受损 %d。" % dmg
		"aid":
			space_fuel = maxi(0, space_fuel - 5)
			add_rep("lower", 2)
			msg = "你伸出援手，消耗 5 燃料，下层声望 +2。"
		"rob":
			cash += 80
			add_rep("lower", -5)
			msg = "你抢走了他们的物资，获得 80₵，下层声望 -5。"
		"fuel":
			var gain := rng.randi_range(10, 25)
			space_fuel += gain
			var dmg2 := rng.randi_range(0, 8)
			space_hull = maxi(0, space_hull - dmg2)
			msg = "抽取燃料 +%d，船体受损 %d。" % [gain, dmg2]
		"heal":
			space_hull = mini(space_max_hull, space_hull + 25)
			wounds = maxi(0, wounds - 2)
			msg = "接受治疗：船体 +25，伤口 -2。"
		"repair":
			if cash >= 30:
				cash -= 30
				space_hull = mini(space_max_hull, space_hull + 40)
				msg = "支付 30₵，船体 +40。"
			else:
				msg = "现金不足，无法维修。"
		"trade":
			var profit := rng.randi_range(40, 140)
			cash += profit
			msg = "做成一笔买卖，获得 %d₵。" % profit
		"leave":
			msg = "你离开了。"
	if space_hull <= 0:
		msg += " 船体破裂，你漂回了当铺。"
		space_leave()
	emit_signal("state_changed")
	return {"ok": true, "text": msg}

func space_wait() -> Dictionary:
	if not space_mode:
		return {"ok": false, "text": "尚未登舰。"}
	space_day += 1
	space_hull = mini(space_max_hull, space_hull + 5)
	space_log.append("在轨道上等待一天，船体 +5。")
	emit_signal("state_changed")
	return {"ok": true, "text": "等待一天，船体 +5。"}

func space_dock() -> Dictionary:
	if not space_at_station:
		return {"ok": false, "text": "当前没有可停靠的站点。"}
	space_raid_rooms = [
		{"name": "码头", "party": "pirateRookieTriple", "loot": true},
		{"name": "货舱", "party": "pirateVeteranLeaderTriple", "loot": true},
	]
	space_raid_index = 0
	var first := "pirate_rookie"
	var party: Dictionary = combat_parties.get("pirateRookieTriple", {})
	if not party.is_empty() and not party.get("enemies", []).is_empty():
		first = String(party["enemies"][0])
	start_combat(first, "lower", "", "space_station", "pirateRookieTriple")
	return {"ok": true, "text": "停靠并进入站点。"}

func _space_raid_loot() -> void:
	var room: Dictionary = space_raid_rooms[space_raid_index] if space_raid_index < space_raid_rooms.size() else {}
	var credits := rng.randi_range(40, 120)
	cash += credits
	space_log.append("%s：%d₵" % [String(room.get("name", "房间")), credits])

func advance_space_raid() -> bool:
	_space_raid_loot()
	space_raid_index += 1
	if space_raid_index >= space_raid_rooms.size():
		space_at_station = true
		return false
	var room: Dictionary = space_raid_rooms[space_raid_index]
	var party_id := String(room.get("party", "pirateRookieTriple"))
	var party: Dictionary = combat_parties.get(party_id, {})
	if party.is_empty():
		return false
	var first := String(party.get("enemies", ["pirate_rookie"])[0])
	start_combat(first, "lower", "", "space_station", party_id)
	return true

func space_state_text() -> String:
	if not space_mode:
		return "未登舰。"
	var lines: Array = []
	lines.append("舰船：%s（%s）" % [String(space_ship.get("name", "")), String(space_ship.get("class", ""))])
	lines.append("船体 %d/%d · 燃料 %d · 航日 %d" % [space_hull, space_max_hull, space_fuel, space_day])
	if not space_poi.is_empty():
		lines.append("当前：%s" % String(space_poi.get("name", "")))
	lines.append("现金：%d₵" % cash)
	if not space_log.is_empty():
		lines.append("")
		for i in range(maxi(0, space_log.size() - 4), space_log.size()):
			lines.append(String(space_log[i]))
	return "\n".join(lines)

func _gen_gun_followup_customer(ammo_id: String, melee_id: String, tier: int, bonuses: int) -> Dictionary:
	var faction := String(current_customer.get("arche", {}).get("faction", "lower"))
	var name := String(current_customer.get("arche", {}).get("name", "顾客"))
	var want_ids: Array = []
	if ammo_id != "":
		want_ids.append(ammo_id)
	if melee_id != "":
		want_ids.append(melee_id)
	var budget := int(round(float(current_customer.get("gun_value", 100)) * 0.33)) + 60 * tier
	if melee_id != "":
		budget = maxi(budget, [0, 60, 120, 250][clampi(tier, 0, 3)])
	return {
		"arche": {"faction": faction, "name": name, "sprite": _random_client_sprite(faction)},
		"intent": "buy", "want_tags": [], "want_ids": want_ids,
		"exclude_contraband": false, "budget": budget, "offer": 0, "max_price": 0,
		"done": false, "patience": 3,
		"line": "顺便，你这里有没有%s？" % ("弹药" if ammo_id != "" and melee_id == "" else "近战武器" if melee_id != "" and ammo_id == "" else "弹药或近战武器"),
		"followup_bonuses": bonuses,
	}

func gun_order_eval(it: Dictionary) -> Dictionary:
	if gun_order.is_empty():
		return {"ok": false, "met": false, "reward": 0, "text": "没有订单。"}
	var did := str(it.get("def_id", ""))
	var stats := gun_item_stats(it)
	if stats.is_empty():
		return {"ok": false, "met": false, "reward": 0, "text": "这不是枪。"}
	var require: Dictionary = gun_order.get("require", {})
	var missing: Array = []
	for k in require.keys():
		if int(stats.get(k, 0)) <= int(require[k]):
			missing.append("%s>%d" % [k, int(require[k])])
	var met := missing.is_empty()
	var reward := int(gun_order.get("base", 0))
	var met_bonus := 0
	for b in gun_order.get("bonuses", []):
		if int(stats.get(String(b.get("stat", "")), 0)) > int(b.get("min", 0)):
			reward += int(b.get("add", 0))
			met_bonus += 1
	var weapon_mod := 1.0 + float(market_modifiers.get("WEAPON", 0)) / 100.0
	reward = int(round(float(reward) * weapon_mod))
	if bool(gun_order.get("service", false)):
		reward += int(it.get("service_parts_value", 0))
	return {"ok": true, "met": met, "reward": reward, "missing": missing, "bonuses": met_bonus, "text": "符合订单" if met else "缺少：" + "、".join(missing)}

func deliver_gun_order(uid: int) -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "gun_order":
		return {"ok": false, "text": "当前没有枪械订单。"}
	var it := find_item(uid)
	if it.is_empty():
		return {"ok": false, "text": "找不到这把枪。"}
	gun_order = current_customer
	var ev := gun_order_eval(it)
	if not bool(ev.get("met", false)):
		return {"ok": false, "text": "订单要求未满足。"}
	var reward := int(ev.get("reward", 0))
	var return_parts := int(it.get("service_parts_value", 0)) / 25 if bool(gun_order.get("service", false)) else 0
	var loc := String(it.get("location", ""))
	if loc == "display":
		for i in range(display.size()):
			if int(display[i].get("uid", -1)) == uid:
				display.remove_at(i)
				break
	else:
		inventory.remove_at(_find_root_index(inventory, uid))
	cash += reward
	for pi in range(return_parts):
		add_item(make_item("gun_part", 100, true, false))
	daily["sales"] = int(daily.get("sales", 0)) + reward
	run_stats["total_sales"] = int(run_stats.get("total_sales", 0)) + reward
	add_rep(String(current_customer.get("arche", {}).get("faction", "lower")), 3)
	var bonuses_met := int(ev.get("bonuses", 0))
	var tier := int(current_customer.get("tier", 1))
	current_customer["gun_value"] = effective_value(it)
	var ammo_id := ""
	var caliber := int(gun_item_stats(it).get("caliber", 0))
	if rng.randi_range(1, 100) <= 50 + 5 * bonuses_met:
		if caliber == 22:
			ammo_id = "small_pistol_ammo"
		elif caliber == 10:
			ammo_id = "heavy_pistol_ammo"
	var melee_id := ""
	if tier >= 2 and rng.randi_range(1, 100) <= 40 + 5 * bonuses_met:
		melee_id = "combat_knife" if rng.randi_range(1, 100) <= 50 else "stun_baton"
	if ammo_id != "" or melee_id != "":
		var follow := _gen_gun_followup_customer(ammo_id, melee_id, tier, bonuses_met)
		customers_today.insert(mini(customers_today.size(), current_index + 1), follow)
	_add_night_log("枪械订单交付：%s，报酬 %d₵。" % [item_display_name(it), reward])
	complete_customer(true)
	gun_order = {}
	emit_signal("state_changed")
	return {"ok": true, "text": "交付完成，收到 %d₵。" % reward}

func release_gun_order() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "gun_order":
		return {"ok": false, "text": "当前没有枪械订单。"}
	if bool(current_customer.get("service", false)):
		var gid := String(current_customer.get("gun_id", ""))
		for i in range(inventory.size() - 1, -1, -1):
			if String(inventory[i].get("def_id", "")) == gid and bool(inventory[i].get("service_order", false)):
				var parts := int(inventory[i].get("service_parts_value", 0)) / 25
				inventory.remove_at(i)
				for pi in range(parts):
					add_item(make_item("gun_part", 100, true, false))
				break
	gun_order = {}
	complete_customer(false)
	return {"ok": true, "text": "已结束订单。"}

func gun_order_repair() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "gun_order":
		return {"ok": false, "text": "当前没有枪械订单。"}
	if not bool(current_customer.get("service", false)):
		return {"ok": false, "text": "这不是维修订单。"}
	var part_value := 25
	if inventory_count("gun_part") <= 0:
		if cash < part_value:
			return {"ok": false, "text": "缺少枪械零件（gun_part），现金也不足 %d₵。" % part_value}
		cash -= part_value
		run_stats["stock_spent"] = int(run_stats.get("stock_spent", 0)) + part_value
	else:
		remove_inventory("gun_part", 1)
	var gid := String(current_customer.get("gun_id", ""))
	for it in inventory:
		if String(it.get("def_id", "")) == gid and bool(it.get("service_order", false)):
			var order := ["poor", "fair", "good", "excellent", "new"]
			var ci := order.find(String(it.get("condition", "fair")))
			it["condition"] = order[clampi(ci + 1, 0, 4)]
			it["service_parts_value"] = int(it.get("service_parts_value", 0)) + part_value
			break
	return {"ok": true, "text": "使用枪械零件整备完毕（零件价值 %d₵）。" % part_value}

func _find_root_index(arr: Array, uid: int) -> int:
	for i in range(arr.size()):
		if int(arr[i].get("uid", -1)) == uid:
			return i
	return -1

func _gen_procurement_offer_customer() -> Dictionary:
	var active: Array = []
	for o in procurement_orders:
		active.append(String(o.get("template_id", "")))
	var choices: Array = []
	for t in procurement_defs.get("templates", []):
		if not active.has(String(t.get("id", ""))):
			choices.append(t)
	if choices.is_empty():
		return {}
	var t: Dictionary = choices[rng.randi_range(0, choices.size() - 1)]
	var name := String(t.get("name", ""))
	var name_key := String(t.get("name_key", ""))
	if name_key != "":
		var localized_name := loc("ClientName", name_key, "")
		if localized_name != "":
			name = localized_name
	var reward := int(t.get("reward_base", 0)) + (rng.randi_range(0, int(t.get("reward_rand", 0))) if int(t.get("reward_rand", 0)) > 0 else 0)
	var body := String(t.get("slip_body", ""))
	return {
		"arche": {"faction": "lower", "name": name},
		"intent": "procurement_offer",
		"procurement_id": String(t.get("id", "")),
		"item_id": String(t.get("item_id", "")),
		"count": int(t.get("count", 0)),
		"days": int(t.get("days", 0)),
		"reward": reward,
		"done": false,
		"line": body,
	}

func _gen_procurement_collect_customer(order: Dictionary) -> Dictionary:
	var name := String(order.get("client_name", "采购人"))
	return {
		"arche": {"faction": "lower", "name": name},
		"intent": "procurement_collect",
		"order_id": String(order.get("id", "")),
		"item_id": String(order.get("item_id", "")),
		"count": int(order.get("count", 0)),
		"reward": int(order.get("reward", 0)),
		"done": false,
		"line": "我来取之前订的货。",
	}

func accept_procurement() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "procurement_offer":
		return {"ok": false, "text": "当前没有采购委托。"}
	var t := procurement_template(String(current_customer.get("procurement_id", "")))
	if t.is_empty():
		return {"ok": false, "text": "采购模板不存在。"}
	var order := {
		"id": "pr_%d_%d" % [day, int(current_customer.get("count", 0))],
		"template_id": String(t.get("id", "")),
		"item_id": String(t.get("item_id", "")),
		"count": int(t.get("count", 0)),
		"due_day": day + int(t.get("days", 0)),
		"reward": int(current_customer.get("reward", 0)),
		"client_name": String(current_customer.get("arche", {}).get("name", "采购人")),
	}
	procurement_orders.append(order)
	var slip := make_item("procurement_slip", 100, true, false)
	slip["custom_name"] = String(t.get("slip_name", "采购订单"))
	slip["custom_desc"] = "%s
报酬：%d₵
期限：第 %d 天" % [String(t.get("slip_body", "")), int(order.get("reward", 0)), int(order.get("due_day", 0))]
	add_item(slip)
	complete_customer(true)
	emit_signal("state_changed")
	return {"ok": true, "text": "已接下采购委托：%s，第 %d 天交货。" % [String(get_item_def(String(order.get("item_id", ""))).get("name", order.get("item_id", ""))), int(order.get("due_day", 0))]}

func collect_procurement() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "procurement_collect":
		return {"ok": false, "text": "当前没有待交付的采购。"}
	var oid := String(current_customer.get("order_id", ""))
	var order: Dictionary = {}
	var oi := -1
	for i in range(procurement_orders.size()):
		if String(procurement_orders[i].get("id", "")) == oid:
			order = procurement_orders[i]
			oi = i
			break
	if order.is_empty():
		return {"ok": false, "text": "找不到这张采购订单。"}
	var item_id := String(order.get("item_id", ""))
	var need := int(order.get("count", 0))
	if inventory_count(item_id) < need:
		return {"ok": false, "text": "货物不足：%s %d/%d。" % [String(get_item_def(item_id).get("name", item_id)), inventory_count(item_id), need]}
	remove_inventory(item_id, need)
	cash += int(order.get("reward", 0))
	procurement_orders.remove_at(oi)
	complete_customer(true)
	emit_signal("state_changed")
	return {"ok": true, "text": "交付成功，获得 %d₵。" % int(order.get("reward", 0))}

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

func report_wanted(wid: String) -> Dictionary:
	if sec_perk_unlocked("SEC_ALARM_IGNORED"):
		return {"ok": false, "text": "治安部不再回应你的报警。"}
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "wanted_visit":
		cash -= 100
		add_rep("security", -5)
		emit_signal("state_changed")
		return {"ok": true, "text": "谎报警情，被罚款 100₵，治安声望 -5。"}
	var current_wid := String(current_customer.get("wanted_id", ""))
	if current_wid != wid:
		cash -= 100
		add_rep("security", -5)
		emit_signal("state_changed")
		return {"ok": true, "text": "举报错了人，被罚款 100₵，治安声望 -5。"}
	var w := wanted_def(wid)
	if w.is_empty() or wanted_defeated.has(wid):
		return {"ok": false, "text": "没有这个通缉目标。"}
	wanted_defeated.append(wid)
	var bounty := float(w.get("reward", 0))
	if starting_perk_active("perk_convict"):
		bounty *= 0.75
	if starting_perk_active("perk_model_citizen"):
		bounty *= 1.5
	var bounty_paid := int(round(bounty))
	cash += bounty_paid
	add_rep("security", 5)
	var reps: Dictionary = w.get("rep", {})
	for k in reps.keys():
		add_rep(String(k), int(reps[k]))
	complete_customer(true)
	emit_signal("state_changed")
	return {"ok": true, "text": "举报成功，获得 %d₵ 悬赏。" % bounty_paid}

func engage_wanted_visit() -> Dictionary:
	if current_customer.is_empty() or String(current_customer.get("intent", "")) != "wanted_visit":
		return {"ok": false, "text": "当前没有通缉目标。"}
	var wid := String(current_customer.get("wanted_id", ""))
	var w := wanted_def(wid)
	if w.is_empty():
		return {"ok": false, "text": "目标不存在。"}
	current_customer["done"] = true
	start_combat(String(w.get("enemy", "thug")), "security", wid, "wanted_visit")
	emit_signal("state_changed")
	return {"ok": true, "text": "你向目标扑了过去。"}

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

func armor_def(def_id: String) -> Dictionary:
	var d = combat_armor_defs.get(def_id, {})
	return d if d is Dictionary else {}

func is_armor_item(it: Dictionary) -> bool:
	return not armor_def(String(it.get("def_id", ""))).is_empty()

func equipped_armor() -> Dictionary:
	if equipped_armor_uid < 0:
		return {}
	return find_item(equipped_armor_uid)

func equip_armor(uid: int) -> Dictionary:
	var it := find_item(uid)
	if it.is_empty() or not is_armor_item(it):
		return {"ok": false, "text": "这件物品不是护甲。"}
	var ad := armor_def(String(it.get("def_id", "")))
	if not it.has("armor_value"):
		it["armor_value"] = int(ad.get("max", 100))
	equipped_armor_uid = uid
	emit_signal("state_changed")
	return {"ok": true, "text": "已装备护甲：%s。" % item_display_name(it)}

func unequip_armor() -> Dictionary:
	if equipped_armor_uid < 0:
		return {"ok": false, "text": "没有装备护甲。"}
	var it := find_item(equipped_armor_uid)
	equipped_armor_uid = -1
	emit_signal("state_changed")
	return {"ok": true, "text": "已卸下护甲：%s。" % (item_display_name(it) if not it.is_empty() else "")}

func _combat_player_armor() -> Dictionary:
	var it := equipped_armor()
	if it.is_empty():
		return {}
	var ad := armor_def(String(it.get("def_id", "")))
	var val := int(it.get("armor_value", ad.get("max", 100)))
	return {
		"item_uid": int(it.get("uid", -1)),
		"value": maxi(0, val),
		"max": int(ad.get("max", 100)),
		"efficiency": int(ad.get("efficiency", 0)),
		"mitigation": int(ad.get("mitigation", 0)),
		"protection": int(ad.get("protection", 0)),
		"resilience": int(ad.get("resilience", 0)),
	}

func _combat_armor_absorb(u: Dictionary, damage: int) -> int:
	var a: Dictionary = u.get("armor", {})
	if a.is_empty() or damage <= 0:
		return 0
	var remaining := damage
	var absorbed := 0
	var value := int(a.get("value", 0))
	var protection := int(a.get("protection", 0))
	if protection > 0 and value > 0:
		var block := mini(remaining, mini(protection, value))
		remaining -= block
		value -= block
		absorbed += block
	if remaining > 0 and value > 0 and int(a.get("efficiency", 0)) > 0:
		for i in range(remaining):
			if value <= 0:
				break
			if rng.randi_range(1, 100) <= int(a.get("efficiency", 0)):
				absorbed += 1
				remaining -= 1
				if int(a.get("mitigation", 0)) <= 0 or rng.randi_range(1, 100) > int(a.get("mitigation", 0)):
					value -= 1
	if value <= 0 and int(a.get("resilience", 0)) > 0:
		var res_absorb := mini(remaining, int(a.get("resilience", 0)))
		absorbed += res_absorb
		remaining -= res_absorb
	a["value"] = maxi(0, value)
	u["armor"] = a
	var it := find_item(int(a.get("item_uid", -1)))
	if not it.is_empty():
		it["armor_value"] = int(a.get("value", 0))
	if absorbed > 0:
		combat_log.append("护甲吸收了 %d 点伤害（%d/%d）。" % [absorbed, int(a.get("value", 0)), int(a.get("max", 0))])
	return absorbed

func _combat_weapon_choice() -> Dictionary:
	var best_uid := -1
	var best_ability := "fists"
	var best_score := -1
	for it in _iter_inventory_items():
		var did := String(it.get("def_id", ""))
		if not combat_weapon_map.has(did):
			continue
		var score := int(get_item_def(did).get("base_value", 0)) + int(it.get("condition", 100))
		if score > best_score:
			best_score = score
			best_uid = int(it.get("uid", -1))
			best_ability = String(combat_weapon_map[did])
	return {"uid": best_uid, "ability": best_ability}

func _combat_item_abilities() -> Array:
	var out: Array = []
	var map := {"bandage_item": "bandage_ability", "hemostatic_bandage_item": "bandage_ability", "topical_bandage_item": "bandage_ability", "smelling_salt": "smelling_salt_ability", "smoke_grenade": "smoke_grenade", "flashbang_grenade": "flashbang", "bicarsole_pill": "bicarsole_ability", "large_purple_injector": "experimental_injector_purple", "black_injector": "experimental_injector_black", "pink_alt_injector": "experimental_injector_red"}
	for it in _iter_inventory_items():
		var did := String(it.get("def_id", ""))
		if map.has(did):
			out.append({"id": String(map[did]), "item_uid": int(it.get("uid", -1))})
	return out

func _combat_make_unit(base: Dictionary, team: int) -> Dictionary:
	var u := base.duplicate(true)
	u["uid"] = combat_uid_seq
	combat_uid_seq += 1
	u["team"] = team
	u["max_hp"] = int(base.get("hp", 100))
	u["hp"] = int(base.get("hp", 100))
	u["accuracy"] = int(base.get("accuracy", 70))
	u["reaction"] = int(base.get("reaction", 10))
	u["priority"] = int(base.get("priority", 5))
	u["dodge"] = int(base.get("dodge", 0))
	u["crit"] = int(base.get("crit", 10))
	u["crit_receive"] = int(base.get("crit_receive", 0))
	u["death_chance"] = int(base.get("death_chance", 100))
	u["effects"] = []
	u["dead"] = false
	u["is_player"] = false
	u["max_action"] = 1
	u["action"] = 1
	return u

func _combat_unit_by_uid(uid: int) -> Dictionary:
	for u in combat_units:
		if int(u.get("uid", -1)) == uid:
			return u
	return {}

func _combat_alive(team: int) -> Array:
	var out: Array = []
	for u in combat_units:
		if int(u.get("team", -1)) == team and not bool(u.get("dead", false)):
			out.append(u)
	return out

func _combat_enemies_of(u: Dictionary) -> Array:
	return _combat_alive(1 - int(u.get("team", 0)))

func _combat_allies_of(u: Dictionary, include_self: bool = true) -> Array:
	var out: Array = []
	for x in combat_units:
		if int(x.get("team", -1)) != int(u.get("team", 0)) or bool(x.get("dead", false)):
			continue
		if not include_self and int(x.get("uid", -1)) == int(u.get("uid", -2)):
			continue
		out.append(x)
	return out

func _combat_sync_legacy() -> void:
	var enemies := _combat_alive(1)
	if not enemies.is_empty():
		combat_enemy = enemies[0]
		combat_enemy_hp = int(enemies[0].get("hp", 0))
	var pl := _combat_unit_by_uid(combat_player_uid)
	if not pl.is_empty():
		combat_player_hp = int(pl.get("hp", 0))
		combat_player_max = int(pl.get("max_hp", 100))

func start_combat(enemy_id: String, faction: String = "lower", wanted_id: String = "", context: String = "", party_id: String = "") -> Dictionary:
	var e := enemy_def(enemy_id)
	var party: Dictionary = combat_parties.get(party_id, {}) if party_id != "" else {}
	var enemy_ids: Array = []
	if not party.is_empty():
		var filtered: Array = []
		for eid in party.get("enemies", []):
			if not enemy_def(String(eid)).is_empty():
				filtered.append(eid)
		enemy_ids = filtered
		if not enemy_ids.is_empty():
			e = enemy_def(String(enemy_ids[0]))
	if e.is_empty():
		return {"ok": false, "text": "敌人不存在。"}
	combat_uid_seq = 1
	combat_units = []
	combat_buff_accuracy = next_combat_accuracy_bonus
	next_combat_accuracy_bonus = 0
	combat_ended = false
	combat_active = true
	combat_wanted_id = wanted_id
	combat_context = context
	combat_skill_cd = 0
	combat_guarding = false
	combat_round = 1
	combat_log = []
	var pw := _combat_weapon_choice()
	combat_player_weapon = String(pw.get("ability", "fists"))
	combat_player_weapon_uid = int(pw.get("uid", -1))
	combat_player_items = _combat_item_abilities()
	var gun_item := find_item(combat_player_weapon_uid)
	combat_gun_stats = gun_item_stats(gun_item) if not gun_item.is_empty() else {}
	combat_is_gun = not combat_gun_stats.is_empty()
	combat_mag_size = int(combat_gun_stats.get("mag_size", 0))
	combat_mag_rounds = combat_mag_size
	combat_ammo_id = gun_ammo_for_caliber(int(combat_gun_stats.get("caliber", 0)))
	var php := maxi(20, player_max_hp - wounds * 2)
	var player := {
		"uid": 0, "team": 0, "name": "你", "hp": php, "max_hp": php,
		"accuracy": player_accuracy + survival_accuracy_mod() + combat_buff_accuracy + int(combat_gun_stats.get("accuracy", 0)) / 10, "reaction": player_reaction, "priority": 5, "dodge": 0, "crit": 10,
		"crit_receive": 0, "death_chance": 40, "weapon": combat_player_weapon,
		"abilities": [], "effects": [], "dead": false, "is_player": true,
		"max_action": 1, "action": 1, "loot": [],
		"armor": _combat_player_armor(),
	}
	combat_player_uid = 0
	combat_units.append(player)
	for ally in combat_allies:
		var adef := enemy_def(String(ally.get("enemy_id", "scav")))
		if adef.is_empty():
			continue
		var ally_unit := _combat_make_unit(adef, 0)
		ally_unit["name"] = String(ally.get("name", "队友"))
		ally_unit["is_player"] = false
		ally_unit["is_ally"] = true
		combat_units.append(ally_unit)
	if enemy_ids.is_empty():
		enemy_ids = [enemy_id]
	for idx in range(enemy_ids.size()):
		var unit := _combat_make_unit(enemy_def(String(enemy_ids[idx])), 1)
		if enemy_ids.size() > 1:
			unit["name"] = "%s %d" % [String(unit.get("name", "")), idx + 1]
		if idx == 0 and wanted_id != "":
			var w := wanted_def(wanted_id)
			if not w.is_empty():
				unit["reward"] = int(w.get("reward", 0))
				unit["rep"] = w.get("rep", {}).duplicate(true)
		combat_units.append(unit)
	combat_turn_order = []
	for u in combat_units:
		combat_turn_order.append(int(u.get("uid", -1)))
	combat_turn_order.sort_custom(func(a, b):
		var ua := _combat_unit_by_uid(a)
		var ub := _combat_unit_by_uid(b)
		if int(ua.get("reaction", 0)) == int(ub.get("reaction", 0)):
			return int(ua.get("priority", 0)) > int(ub.get("priority", 0))
		return int(ua.get("reaction", 0)) > int(ub.get("reaction", 0))
	)
	combat_turn_pos = 0
	combat_current_uid = -1
	var encounter_name := String(party.get("name", e.get("name", enemy_id)))
	if party.is_empty() and enemy_ids.size() > 1:
		encounter_name = "%s ×%d" % [String(e.get("name", enemy_id)), enemy_ids.size()]
	if not combat_allies.is_empty():
		var ally_names: Array = []
		for a in combat_allies:
			ally_names.append(String(a.get("name", "队友")))
		combat_log.append("队友：%s。" % "、".join(ally_names))
	combat_log.append("遭遇：%s（第 %d 回合）" % [encounter_name, combat_round])
	_combat_sync_legacy()
	emit_signal("combat_started")
	emit_signal("state_changed")
	_combat_advance()
	return {"ok": true, "text": "战斗开始。"}

func combat_roll(minv: int, maxv: int) -> int:
	return rng.randi_range(minv, maxv)

func _combat_current_unit() -> Dictionary:
	return _combat_unit_by_uid(combat_current_uid)

func combat_waiting_for_player() -> bool:
	return combat_active and not combat_ended and combat_current_uid == combat_player_uid

func _combat_is_stunned(u: Dictionary) -> bool:
	for e in u.get("effects", []):
		if String(e.get("type", "")) == "stun" and int(e.get("duration", 0)) > 0:
			return true
	return false

func _combat_has_effect(u: Dictionary, type_id: String) -> bool:
	for e in u.get("effects", []):
		if String(e.get("type", "")) == type_id and int(e.get("duration", 0)) > 0:
			return true
	return false

func _combat_stat_key(stat: String) -> String:
	match stat:
		"accuracy": return "accuracy"
		"dodge": return "dodge"
		"reaction": return "reaction"
		"crit", "criticalChanceDealing": return "crit"
		"criticalChanceReceving", "criticalChanceReceiving": return "crit_receive"
		"priority": return "priority"
	return stat

func _combat_add_effect(target: Dictionary, effect: Dictionary) -> void:
	var e := effect.duplicate(true)
	e["duration"] = int(effect.get("duration", 1))
	var etype := String(e.get("type", ""))
	if etype in ["buff", "debuff"]:
		var key := _combat_stat_key(String(e.get("stat", "")))
		var val := int(e.get("value", 0))
		target[key] = int(target.get(key, 0)) + val
		e["applied_stat"] = key
		e["applied_value"] = val
		combat_log.append("%s：%s（%d 回合）" % [target.get("name", ""), "增益" if etype == "buff" else "减益", e["duration"]])
	elif etype == "stun":
		combat_log.append("%s 被眩晕 %d 回合。" % [target.get("name", ""), e["duration"]])
	elif etype == "bleed":
		combat_log.append("%s 开始流血（%d 回合）。" % [target.get("name", ""), e["duration"]])
	elif etype == "overwatch":
		combat_log.append("%s 进入警戒。" % target.get("name", ""))
	elif etype == "retaliate":
		combat_log.append("%s 进入反击姿态。" % target.get("name", ""))
	var effects: Array = target.get("effects", [])
	var keep: Array = []
	for old in effects:
		if String(old.get("type", "")) == etype and String(old.get("stat", "")) == String(e.get("stat", "")):
			continue
		keep.append(old)
	keep.append(e)
	target["effects"] = keep

func _combat_expire_effects(u: Dictionary) -> void:
	var keep: Array = []
	for e in u.get("effects", []):
		var dur := int(e.get("duration", 0)) - 1
		e["duration"] = dur
		if dur > 0:
			keep.append(e)
			continue
		if String(e.get("type", "")) in ["buff", "debuff"] and e.has("applied_stat"):
			var key := String(e.get("applied_stat", ""))
			u[key] = int(u.get(key, 0)) - int(e.get("applied_value", 0))
	u["effects"] = keep

func _combat_heal(u: Dictionary, amount: int) -> void:
	if bool(u.get("dead", false)) or amount <= 0:
		return
	u["hp"] = mini(int(u.get("max_hp", 100)), int(u.get("hp", 0)) + amount)
	combat_log.append("%s 恢复 %d 生命。" % [u.get("name", ""), amount])

func _combat_death_roll(u: Dictionary) -> void:
	if bool(u.get("dead", false)):
		return
	var dc := int(u.get("death_chance", 100))
	var roll := rng.randi_range(1, 100)
	if roll <= dc:
		u["hp"] = 0
		u["dead"] = true
		combat_log.append("%s 倒下了。" % u.get("name", ""))
	else:
		u["hp"] = 1
		combat_log.append("%s 濒死挣扎，撑住了！" % u.get("name", ""))

func _combat_damage(u: Dictionary, amount: int, source_name: String) -> void:
	if bool(u.get("dead", false)) or amount <= 0:
		return
	var dealt := amount
	if u.has("armor") and not (u.get("armor", {}) as Dictionary).is_empty():
		var absorbed := _combat_armor_absorb(u, amount)
		dealt = maxi(0, amount - absorbed)
		if dealt <= 0:
			combat_log.append("%s 的护甲挡住了全部伤害。" % u.get("name", ""))
			return
	u["hp"] = int(u.get("hp", 0)) - dealt
	combat_log.append("%s 对 %s 造成 %d 伤害。" % [source_name, u.get("name", ""), dealt])
	emit_signal("combat_hit", int(u.get("uid", -1)), dealt)
	if int(u.get("hp", 0)) <= 0:
		_combat_death_roll(u)

func _combat_hit_chance(caster: Dictionary, target: Dictionary, ability: Dictionary) -> int:
	var bonus := int(ability.get("bonus_accuracy", 0))
	if bonus >= 1000:
		return 100
	var chance := int(caster.get("accuracy", 70)) + bonus - int(target.get("dodge", 0))
	if bool(caster.get("is_player", false)):
		if starting_perk_active("perk_lucky"):
			chance += 5
		elif starting_perk_active("perk_unlucky"):
			chance -= 5
	return clampi(chance, 0, 100)

func _combat_ability_has_offense(ability: Dictionary) -> bool:
	for eff in ability.get("effects", []):
		if String(eff.get("type", "")) in ["attack", "bleed", "stun"]:
			if String(eff.get("target", "singleEnemy")) in ["singleEnemy", "allEnemy", "all"]:
				return true
	return false

func _combat_resolve_effect(caster: Dictionary, target: Dictionary, eff: Dictionary, crit: bool) -> void:
	var etype := String(eff.get("type", ""))
	match etype:
		"attack":
			var dmg := rng.randi_range(int(eff.get("min", 1)), int(eff.get("max", 1)))
			if bool(caster.get("is_player", false)) and combat_is_gun:
				dmg += int(combat_gun_stats.get("firepower", 0)) / 20
			if crit:
				dmg *= 2
				combat_log.append("暴击！")
			_combat_damage(target, dmg, String(caster.get("name", "")))
		"heal":
			_combat_heal(target, int(eff.get("value", 0)))
		"overtime_heal":
			_combat_add_effect(target, {"type": "overtime_heal", "value": int(eff.get("value", 0)), "duration": int(eff.get("duration", 1))})
		"bleed":
			if rng.randi_range(1, 100) <= int(eff.get("chance", 100)):
				_combat_add_effect(target, {"type": "bleed", "value": int(eff.get("value", 2)), "duration": int(eff.get("duration", 1))})
		"stun":
			if rng.randi_range(1, 100) <= int(eff.get("chance", 100)):
				_combat_add_effect(target, {"type": "stun", "duration": int(eff.get("duration", 1))})
		"buff", "debuff":
			_combat_add_effect(target, {"type": etype, "stat": String(eff.get("stat", "accuracy")), "value": int(eff.get("value", 0)), "duration": int(eff.get("duration", 1))})
		"overwatch", "retaliate":
			_combat_add_effect(target, {"type": etype, "duration": int(eff.get("duration", 1))})
		"stop_bleed":
			var keep: Array = []
			for e in target.get("effects", []):
				if String(e.get("type", "")) != "bleed":
					keep.append(e)
			target["effects"] = keep
			combat_log.append("%s 的流血被止住了。" % target.get("name", ""))
		"remove_stun":
			var keep2: Array = []
			for e in target.get("effects", []):
				if String(e.get("type", "")) != "stun":
					keep2.append(e)
			target["effects"] = keep2
			combat_log.append("%s 清醒过来。" % target.get("name", ""))

func _combat_targets_for(caster: Dictionary, ability: Dictionary, target_uid: int) -> Array:
	var effects: Array = ability.get("effects", [])
	if effects.is_empty():
		return []
	var ttype := String(effects[0].get("target", "singleEnemy"))
	match ttype:
		"self":
			return [caster]
		"allEnemy":
			return _combat_enemies_of(caster)
		"allFriendly":
			return _combat_allies_of(caster, true)
		"singleFriendly", "singleFriendlyExceptSelf":
			var t := _combat_unit_by_uid(target_uid)
			if not t.is_empty() and int(t.get("team", -1)) == int(caster.get("team", 0)) and not bool(t.get("dead", false)):
				return [t]
			var allies := _combat_allies_of(caster, ttype != "singleFriendlyExceptSelf")
			if allies.is_empty():
				return []
			return [allies[0]]
		"all":
			return _combat_alive(0) + _combat_alive(1)
	var target := _combat_unit_by_uid(target_uid)
	if target.is_empty() or bool(target.get("dead", false)):
		var enemies := _combat_enemies_of(caster)
		if enemies.is_empty():
			return []
		return [enemies[0]]
	if int(target.get("team", -1)) == int(caster.get("team", 0)):
		var enemies2 := _combat_enemies_of(caster)
		if enemies2.is_empty():
			return []
		return [enemies2[0]]
	return [target]

func _combat_reactions(caster: Dictionary, ability: Dictionary) -> void:
	if not bool(ability.get("trigger_overwatch", true)):
		return
	var foes := _combat_enemies_of(caster)
	for f in foes:
		if bool(caster.get("dead", false)):
			return
		var weapon := String(f.get("weapon", "weapon_attack"))
		if _combat_has_effect(f, "overwatch"):
			var keep: Array = []
			for e in f.get("effects", []):
				if String(e.get("type", "")) != "overwatch":
					keep.append(e)
			f["effects"] = keep
			combat_log.append("%s 警戒射击！" % f.get("name", ""))
			_combat_use_ability(f, weapon, int(caster.get("uid", -1)), -1, true)
		elif _combat_has_effect(f, "retaliate"):
			combat_log.append("%s 发起反击！" % f.get("name", ""))
			_combat_use_ability(f, weapon, int(caster.get("uid", -1)), -1, true)

func _combat_use_ability(caster: Dictionary, ability_id: String, target_uid: int, item_uid: int = -1, is_reaction: bool = false) -> String:
	if bool(caster.get("dead", false)):
		return ""
	var ability: Dictionary = combat_abilities.get(ability_id, {})
	if ability.is_empty():
		ability = combat_abilities.get("fists", {})
		ability_id = "fists"
	var targets := _combat_targets_for(caster, ability, target_uid)
	if targets.is_empty():
		return "没有合法目标。"
	var primary: Dictionary = targets[0]
	var hit := true
	if _combat_ability_has_offense(ability):
		var chance := _combat_hit_chance(caster, primary, ability)
		hit = chance >= 100 or rng.randi_range(1, 100) <= chance
		if not hit:
			combat_log.append("%s 使用%s，但没有命中。" % [caster.get("name", ""), String(ability.get("name", ability_id))])
	if hit:
		var crit := rng.randi_range(1, 100) <= int(caster.get("crit", 10)) + int(primary.get("crit_receive", 0))
		for eff in ability.get("effects", []):
			if not hit and String(eff.get("target", "")) in ["singleEnemy", "allEnemy", "all"] and _combat_ability_has_offense(ability):
				continue
			var eff_targets: Array = targets
			if String(eff.get("target", "")) not in ["singleEnemy", "allEnemy", "all"]:
				eff_targets = _combat_targets_for(caster, {"effects": [eff]}, target_uid)
			for t in eff_targets:
				_combat_resolve_effect(caster, t, eff, crit)
	if item_uid >= 0:
		var consumed := detach_item(item_uid)
		if not consumed.is_empty():
			combat_log.append("消耗了 %s。" % item_display_name(consumed))
			var kept: Array = []
			for entry in combat_player_items:
				if int(entry.get("item_uid", -1)) != item_uid:
					kept.append(entry)
			combat_player_items = kept
	if not is_reaction and hit and _combat_ability_has_offense(ability):
		_combat_reactions(caster, ability)
	return String(ability.get("name", ability_id))

func _combat_ai_pick_target(u: Dictionary) -> Dictionary:
	var enemies := _combat_enemies_of(u)
	if enemies.is_empty():
		return {}
	match String(u.get("ai", "murderous")):
		"sadistic", "hunter":
			var best: Dictionary = enemies[0]
			for e in enemies:
				if int(e.get("hp", 0)) < int(best.get("hp", 0)):
					best = e
			return best
		"boss", "pirate_chief":
			var best2: Dictionary = enemies[0]
			for e in enemies:
				if int(e.get("priority", 0)) > int(best2.get("priority", 0)):
					best2 = e
			return best2
	var total := 0
	for e in enemies:
		total += maxi(1, int(e.get("priority", 1)))
	var roll := rng.randi_range(1, maxi(1, total))
	var acc := 0
	for e in enemies:
		acc += maxi(1, int(e.get("priority", 1)))
		if roll <= acc:
			return e
	return enemies[0]

func _combat_ai_turn(u: Dictionary) -> void:
	var target := _combat_ai_pick_target(u)
	if target.is_empty():
		return
	var abilities: Array = u.get("abilities", [])
	var allies := _combat_allies_of(u, true)
	match String(u.get("ai", "murderous")):
		"medic", "deserter_medic":
			for a in allies:
				if _combat_has_effect(a, "bleed") and abilities.has("bandage_ability"):
					_combat_use_ability(u, "bandage_ability", int(a.get("uid", -1)))
					return
		"brewer":
			for a in allies:
				if int(a.get("hp", 0)) < int(a.get("max_hp", 100)) and abilities.has("brewer_heal"):
					_combat_use_ability(u, "brewer_heal", int(a.get("uid", -1)))
					return
		"herald":
			if not _combat_has_effect(u, "buff") and abilities.has("herald_buff"):
				_combat_use_ability(u, "herald_buff", int(u.get("uid", -1)))
				return
		"overwatch", "pirate_veteran":
			if not _combat_has_effect(u, "overwatch"):
				_combat_use_ability(u, "overwatch", int(u.get("uid", -1)))
				return
		"deserter_marine":
			if not _combat_has_effect(u, "buff") and abilities.has("take_aim_ability"):
				_combat_use_ability(u, "take_aim_ability", int(u.get("uid", -1)))
				return
	var weapon := String(u.get("weapon", "weapon_attack"))
	_combat_use_ability(u, weapon, int(target.get("uid", -1)))

func _combat_start_turn(u: Dictionary) -> void:
	if bool(u.get("is_player", false)):
		thirst = maxi(0, thirst - 15)
		u["accuracy"] = player_accuracy + survival_accuracy_mod() + combat_buff_accuracy
		if thirst <= 0:
			_combat_damage(u, int(u.get("hp", 1)) + 999, "极度脱水")
			return
	for e in u.get("effects", []).duplicate():
		if String(e.get("type", "")) == "bleed" and int(e.get("duration", 0)) > 0:
			_combat_damage(u, absi(int(e.get("value", 2))), "流血")
		elif String(e.get("type", "")) == "overtime_heal" and int(e.get("duration", 0)) > 0:
			_combat_heal(u, int(e.get("value", 0)))
		if bool(u.get("dead", false)):
			return

func _combat_end_turn(u: Dictionary) -> void:
	_combat_expire_effects(u)

func _combat_check_end() -> bool:
	if combat_ended:
		return true
	if _combat_alive(1).is_empty():
		_combat_victory()
		return true
	var party_alive := _combat_alive(0)
	if party_alive.is_empty():
		_combat_defeat()
		return true
	return false

func _combat_victory() -> void:
	combat_ended = true
	combat_active = false
	var reward := 0
	var reps: Dictionary = {}
	var loot_lines: Array = []
	for u in combat_units:
		if int(u.get("team", 0)) != 1:
			continue
		reward += int(u.get("reward", 0))
		var r: Dictionary = u.get("rep", {})
		for k in r.keys():
			reps[k] = int(reps.get(k, 0)) + int(r[k])
		for entry in u.get("loot", []):
			var iid := String(entry[0])
			var chance := int(entry[1])
			if rng.randi_range(1, 100) <= chance and items_def.has(iid):
				add_item(make_item(iid, 100, true, false))
				loot_lines.append(String(get_item_def(iid).get("name", iid)))
	cash += reward
	for k in reps.keys():
		add_rep(String(k), int(reps[k]))
	if combat_wanted_id != "" and not wanted_defeated.has(combat_wanted_id):
		wanted_defeated.append(combat_wanted_id)
	var msg := "战斗胜利"
	if reward > 0:
		msg += "，获得 %d₵" % reward
	if not loot_lines.is_empty():
		msg += "，战利品：%s" % "、".join(loot_lines)
	combat_log.append(msg)
	combat_skill_cd = 0
	combat_guarding = false
	_combat_sync_legacy()
	emit_signal("combat_finished", true, msg)
	emit_signal("state_changed")

func _combat_defeat() -> void:
	combat_ended = true
	combat_active = false
	cash = maxi(0, cash - 100)
	add_rep("lower", -3)
	gain_wound(true)
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
	_combat_sync_legacy()
	emit_signal("combat_finished", false, "你被打倒了，损失 100₵。")
	emit_signal("state_changed")

func _combat_advance() -> void:
	if combat_ended:
		return
	var guard := 0
	while guard < 64:
		guard += 1
		if _combat_check_end():
			return
		if combat_turn_pos >= combat_turn_order.size():
			combat_round += 1
			combat_turn_pos = 0
			combat_log.append("第 %d 回合。" % combat_round)
			continue
		var uid := int(combat_turn_order[combat_turn_pos])
		var u := _combat_unit_by_uid(uid)
		if u.is_empty() or bool(u.get("dead", false)):
			combat_turn_pos += 1
			continue
		_combat_start_turn(u)
		if bool(u.get("dead", false)):
			combat_turn_pos += 1
			continue
		if _combat_is_stunned(u):
			combat_log.append("%s 被眩晕，跳过行动。" % u.get("name", ""))
			_combat_end_turn(u)
			combat_turn_pos += 1
			continue
		if bool(u.get("is_player", false)):
			combat_current_uid = uid
			var foes := _combat_enemies_of(u)
			if not foes.is_empty():
				combat_target_uid = int(foes[0].get("uid", -1))
			_combat_sync_legacy()
			emit_signal("combat_updated")
			emit_signal("state_changed")
			return
		_combat_ai_turn(u)
		_combat_end_turn(u)
		if combat_ended:
			return
		combat_turn_pos += 1
	_combat_sync_legacy()
	emit_signal("combat_updated")

func combat_player_skills() -> Array:
	var out: Array = []
	var weapon := combat_player_weapon if combat_player_weapon != "" else "fists"
	var ab: Dictionary = combat_abilities.get(weapon, {})
	out.append({"id": weapon, "name": String(ab.get("name", "攻击")), "item_uid": -1})
	for entry in combat_player_items:
		var aid := String(entry.get("id", ""))
		var item_uid := int(entry.get("item_uid", -1))
		if find_item(item_uid).is_empty():
			continue
		var a: Dictionary = combat_abilities.get(aid, {})
		if a.is_empty():
			continue
		out.append({"id": aid, "name": String(a.get("name", aid)), "item_uid": item_uid})
	out.append({"id": "brace_ability", "name": "防御", "item_uid": -1})
	out.append({"id": "overwatch", "name": "警戒", "item_uid": -1})
	if combat_is_gun and combat_mag_rounds < combat_mag_size:
		out.append({"id": "reload", "name": "换弹（%d/%d）" % [combat_mag_rounds, combat_mag_size], "item_uid": -1})
	return out

func combat_select_target(uid: int) -> void:
	combat_target_uid = uid
	emit_signal("combat_updated")

func combat_player_action(ability_id: String, target_uid: int = -1, item_uid: int = -1) -> Dictionary:
	if not combat_active or combat_ended or combat_current_uid != combat_player_uid:
		return {"ok": false, "text": "还没轮到你。"}
	var pl := _combat_unit_by_uid(combat_player_uid)
	if ability_id == "reload":
		return _combat_reload_action(pl)
	if combat_is_gun and ability_id == combat_player_weapon:
		if not combat_spend_round():
			return {"ok": false, "text": "弹匣空了，先换弹。"}
	var use_target := target_uid
	if use_target < 0:
		use_target = combat_target_uid
	if item_uid < 0:
		for s in combat_player_skills():
			if String(s.get("id", "")) == ability_id:
				item_uid = int(s.get("item_uid", -1))
				break
	var label := _combat_use_ability(pl, ability_id, use_target, item_uid)
	_combat_end_turn(pl)
	if _combat_check_end():
		return {"ok": true, "text": label}
	combat_turn_pos += 1
	_combat_advance()
	return {"ok": true, "text": label}

func combat_spend_round() -> bool:
	if not combat_is_gun:
		return true
	if combat_mag_rounds <= 0:
		return false
	combat_mag_rounds -= 1
	return true

func combat_reload() -> Dictionary:
	if not combat_is_gun:
		return {"ok": false, "text": "当前武器不需要换弹。"}
	if combat_mag_rounds >= combat_mag_size:
		return {"ok": false, "text": "弹匣是满的。"}
	if combat_ammo_id == "" or inventory_count(combat_ammo_id) <= 0:
		return {"ok": false, "text": "没有可用的弹药。"}
	remove_inventory(combat_ammo_id, 1)
	combat_mag_rounds = combat_mag_size
	combat_log.append("你换上新的弹匣（%d/%d）。" % [combat_mag_rounds, combat_mag_size])
	return {"ok": true, "text": "换弹完成。"}

func _combat_reload_action(pl: Dictionary) -> Dictionary:
	var res := combat_reload()
	if not bool(res.get("ok", false)):
		return res
	_combat_end_turn(pl)
	if not _combat_check_end():
		combat_turn_pos += 1
		_combat_advance()
	return res

func combat_action(action: String) -> Dictionary:
	match action:
		"attack":
			return combat_player_action(combat_player_weapon if combat_player_weapon != "" else "fists", combat_target_uid)
		"guard":
			return combat_player_action("brace_ability", combat_player_uid)
		"skill":
			return combat_player_action("overwatch", combat_player_uid)
		"flee":
			return {"ok": false, "text": "战斗中无法逃跑。"}
	return {"ok": false, "text": "未知动作。"}

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
	var def := get_item_def(String(item.get("def_id", "")))
	var text := String(def.get("description", ""))
	if text == "":
		text = String(def.get("flavor", ""))
	return text

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

const UPGRADE_PREREQS := {
	"GUN_PERMIT_II": "GUN_PERMIT_I",
	"GUN_PERMIT_III": "GUN_PERMIT_II",
	"WILD_FIXER2": "WILD_FIXER",
	"WILD_FIXER3": "WILD_FIXER2",
}

func upgrade_cost(id: String) -> int:
	var u := upgrade_def(id)
	var cost := int(u.get("cost", 0))
	if id == "EVIDENCE_REMOVAL":
		cost += evidence_removal_purchases * int(security_defs.get("evidence_removal", {}).get("cost_step", 100))
	cost = int(round(float(cost) * float(diff_rule("upgrade_price_mult", 1.0))))
	cost = int(round(float(cost) * upgrade_cost_mult()))
	return cost

func upgrade_owned(id: String) -> bool:
	if id == "EVIDENCE_REMOVAL":
		return false
	return owned_upgrades.has(id)

func upgrade_cooldown(id: String) -> int:
	if id != "EVIDENCE_REMOVAL":
		return 0
	return maxi(0, int(upgrade_cooldowns.get(id, 0)) - day)

func upgrade_available(id: String) -> Dictionary:
	var u := upgrade_def(id)
	if u.is_empty():
		return {"ok": false, "reason": "没有这项升级。", "cost": 0}
	if upgrade_owned(id):
		return {"ok": false, "reason": "已经购买过了。", "cost": upgrade_cost(id)}
	if id == "INSURANCE" and insurance_blocked():
		return {"ok": false, "reason": "黑市声望过低，没有保险公司愿意承保。", "cost": upgrade_cost(id)}
	var req := String(UPGRADE_PREREQS.get(id, ""))
	if req != "" and not bool(owned_upgrades.get(req, false)):
		return {"ok": false, "reason": "需要先购买 %s。" % String(upgrade_def(req).get("name", req)), "cost": upgrade_cost(id)}
	var cooldown := upgrade_cooldown(id)
	if cooldown > 0:
		return {"ok": false, "reason": "冷却中，还需 %d 天。" % cooldown, "cost": upgrade_cost(id)}
	var cost := upgrade_cost(id)
	if cash < cost:
		return {"ok": false, "reason": "现金不足，需要 %d₵。" % cost, "cost": cost}
	return {"ok": true, "reason": "可购买", "cost": cost}

func buy_upgrade(id: String) -> Dictionary:
	var check := upgrade_available(id)
	if not bool(check.get("ok", false)):
		return {"ok": false, "text": String(check.get("reason", "无法购买。"))}
	var cost := int(check.get("cost", 0))
	var u := upgrade_def(id)
	cash -= cost
	if id == "EVIDENCE_REMOVAL":
		evidence_removal_purchases += 1
		upgrade_cooldowns[id] = day + int(security_defs.get("evidence_removal", {}).get("cooldown_days", 14))
		sec_evidence = 0
		sec_state = 0
		sec_officer_pending = false
		_add_night_log("王尔德清除了治安部收集的所有证据。")
		_refresh_upgrades()
		emit_signal("state_changed")
		return {"ok": true, "text": "证据已清除。下次价格 %d₵。" % upgrade_cost(id)}
	owned_upgrades[id] = true
	if id == "MARKETPLACE_REQUESTS":
		_marketplace_unlock()
	if String(u.get("effect", "")) == "power":
		power += int(u.get("value", 0))
	var card_map := {"BREWER": "card_brewer", "CHEMIST": "card_chem", "PHARMA": "card_pharma", "MINER": "card_mining"}
	var sid_map := {"BREWER": "red_imp", "CHEMIST": "chem", "PHARMA": "pharma", "MINER": "mining"}
	if card_map.has(id):
		phone_unlock_supplier(id)
		var card := make_item(String(card_map[id]), 100, true, false)
		card["known"] = true
		add_item(card)
		_add_night_log("获得供应商名片：%s，电话 %s。" % [String(get_item_def(String(card_map[id])).get("name", "")), phone_number_of(String(sid_map.get(id, "")))])
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

func _count_item_tree(it: Dictionary, def_id: String) -> int:
	var n := int(it.get("unit_count", 1)) if String(it.get("def_id", "")) == def_id else 0
	for ch in it.get("children", []):
		n += _count_item_tree(ch, def_id)
	return n

func inventory_count(def_id: String) -> int:
	var n := 0
	for it in inventory:
		n += _count_item_tree(it, def_id)
	return n

func _remove_from_tree(items: Array, def_id: String, need: int) -> int:
	var i := 0
	while i < items.size() and need > 0:
		var it: Dictionary = items[i]
		if String(it.get("def_id", "")) == def_id:
			var have := int(it.get("unit_count", 1))
			if have > need:
				it["unit_count"] = have - need
				need = 0
			else:
				need -= have
				items.remove_at(i)
			continue
		var children: Array = it.get("children", [])
		need = _remove_from_tree(children, def_id, need)
		i += 1
	return need

func remove_inventory(def_id: String, count: int) -> bool:
	if inventory_count(def_id) < count:
		return false
	var need := _remove_from_tree(inventory, def_id, count)
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
	var io := machine_io_spec(machine_id)
	var use_io_input := io.get("input", {}) is Dictionary and not (io.get("input", {}) as Dictionary).is_empty()
	var avg_cond := machine_io_avg_condition(machine_id, "input", active_inputs) if use_io_input else _avg_input_condition(active_inputs)
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
	if use_io_input:
		for inp in active_inputs:
			var iid := String(inp.get("id", ""))
			var need0 := int(inp.get("count", 1))
			var have0 := machine_io_count(machine_id, "input", iid)
			if have0 < need0:
				_io_pull_from_inventory(machine_id, iid, need0 - have0)
		for inp in active_inputs:
			var need := int(inp.get("count", 1))
			var have := machine_io_count(machine_id, "input", String(inp.get("id", "")))
			if have < need:
				var d := get_item_def(String(inp.get("id", "")))
				return {"ok": false, "text": "输入端缺少原料：%s x%d。" % [d.get("name", inp.get("id", "")), need]}
	else:
		for inp in active_inputs:
			var need2 := int(inp.get("count", 1))
			if inventory_count(String(inp.get("id", ""))) < need2:
				var d2 := get_item_def(String(inp.get("id", "")))
				return {"ok": false, "text": "缺少原料：%s x%d。" % [d2.get("name", inp.get("id", "")), need2]}
	if dry_run:
		return {"ok": true, "text": "%s 可以启动（%d 夜 / %d 电力）。" % [m.get("name", machine_id), use_cycles, use_power]}
	for inp in active_inputs:
		if use_io_input:
			machine_io_remove(machine_id, "input", String(inp.get("id", "")), int(inp.get("count", 1)))
		else:
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
		"io_input": use_io_input,
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
	if starting_perk_active("perk_handy"):
		cost = maxi(1, cost / 2)
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
	var mid := String(job.get("machine_id", ""))
	var io := machine_io_spec(mid)
	var out_conf = io.get("output", {})
	var out_container: Dictionary = {}
	if out_conf is Dictionary and not out_conf.is_empty():
		out_container = machine_io_container(mid, "output")
	for out in job.get("outputs", []):
		var oid := String(out.get("id", ""))
		if not items_def.has(oid):
			continue
		for n in range(int(out.get("count", 1))):
			var it := _make_output_item(oid, cond, features)
			var placed := false
			if not out_container.is_empty():
				placed = container_auto_add(out_container, it)
				if placed:
					it["location"] = "machine"
			if not placed:
				add_item(it)
			if mid == "chem_finisher" and cond >= 90:
				unlock_achievement("ACH_LAB_PURE")
			if oid == "nutrifruit" and cond >= 95:
				unlock_achievement("ACH_HUGE_NUTRIFRUIT")
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

func machine_io_spec(mid: String) -> Dictionary:
	var io = machine_def(mid).get("io", {})
	return io if io is Dictionary else {}

func _io_side_items(mid: String, side: String) -> Array:
	if not machine_io.has(mid):
		machine_io[mid] = {"input": [], "output": []}
	var sides: Dictionary = machine_io[mid]
	if not sides.has(side) or not (sides[side] is Array):
		sides[side] = []
	return sides[side]

func machine_io_container(mid: String, side: String) -> Dictionary:
	var key := mid + "::" + side
	if machine_container_items.has(key):
		return machine_container_items[key]
	var io := machine_io_spec(mid)
	var conf = io.get(side, {})
	if not (conf is Dictionary):
		return {}
	var spec := {}
	if conf.has("slots"):
		var slot_list: Array = []
		for i in range(int(conf.get("slots", 1))):
			slot_list.append({"id": "slot%d" % (i + 1), "accept": []})
		spec = {"kind": "slots", "slots": slot_list}
	else:
		var grid: Array = conf.get("grid", [3, 3])
		spec = {"kind": "grid", "width": int(grid[0]), "height": int(grid[1]), "storage": true}
		if bool(conf.get("accept_containers", false)):
			spec["accept_containers"] = true
	var m := machine_def(mid)
	var side_name := "输入" if side == "input" else "输出"
	var item := {
		"uid": -2000 - machine_container_items.size(),
		"def_id": mid,
		"custom_name": "%s · %s" % [String(m.get("name", mid)), side_name],
		"custom_base_value": 0,
		"condition": 100,
		"authentic": true,
		"children": _io_side_items(mid, side),
		"container_spec": spec,
		"container_locked": false,
		"location": "machine",
		"_window_key": key,
	}
	machine_container_items[key] = item
	return item

func machine_io_count(mid: String, side: String, def_id: String) -> int:
	var total := 0
	for it in _io_side_items(mid, side):
		if String(it.get("def_id", "")) == def_id:
			total += int(it.get("unit_count", 1))
	return total

func machine_io_remove(mid: String, side: String, def_id: String, count: int) -> bool:
	var items := _io_side_items(mid, side)
	var need := count
	var i := 0
	while i < items.size() and need > 0:
		var it: Dictionary = items[i]
		if String(it.get("def_id", "")) == def_id:
			var have := int(it.get("unit_count", 1))
			if have > need:
				it["unit_count"] = have - need
				need = 0
			else:
				need -= have
				items.remove_at(i)
				continue
		i += 1
	return need == 0

func _io_pull_from_inventory(mid: String, def_id: String, count: int) -> void:
	var box := machine_io_container(mid, "input")
	if box.is_empty() or count <= 0:
		return
	var need := count
	var i := 0
	while i < inventory.size() and need > 0:
		var it: Dictionary = inventory[i]
		if String(it.get("def_id", "")) != def_id or not it.get("children", []).is_empty():
			i += 1
			continue
		var have := int(it.get("unit_count", 1))
		var take := mini(need, have)
		if take >= have:
			inventory.remove_at(i)
			it["location"] = "machine"
			if container_auto_add(box, it):
				need -= take
			else:
				it["location"] = "backpack"
				inventory.append(it)
				break
		else:
			var copy := make_item(def_id, int(it.get("condition", 100)), bool(it.get("authentic", true)), bool(it.get("stolen", false)))
			copy["unit_count"] = take
			copy["location"] = "machine"
			it["unit_count"] = have - take
			if container_auto_add(box, copy):
				need -= take
			else:
				it["unit_count"] = have
				break

func machine_io_avg_condition(mid: String, side: String, inputs: Array) -> int:
	var total := 0
	var count := 0
	for spec in inputs:
		var did := String(spec.get("id", ""))
		var want := int(spec.get("count", 1))
		for it in _io_side_items(mid, side):
			if want <= 0:
				break
			if String(it.get("def_id", "")) != did:
				continue
			var take := mini(want, int(it.get("unit_count", 1)))
			total += int(it.get("condition", 100)) * take
			count += take
			want -= take
	return 50 if count <= 0 else int(round(float(total) / float(count)))

func machine_container(mid: String) -> Dictionary:
	if machine_container_items.has(mid):
		return machine_container_items[mid]
	var spec := container_def(mid).duplicate(true)
	if spec.is_empty():
		return {}
	if mid == "fridge":
		spec["height"] = 2 + mini(7, int(machine_upgrades.get(mid, 0)))
	elif mid == "vending_machine":
		spec["height"] = 2 + mini(10, int(machine_upgrades.get(mid, 0)))
	elif mid == "animal_cage":
		spec["height"] = 3 + mini(8, int(machine_upgrades.get(mid, 0)))
	var m := machine_def(mid)
	var item := {
		"uid": -1000 - machine_container_items.size(),
		"def_id": mid,
		"custom_name": "%s · 库存" % String(m.get("name", mid)),
		"custom_base_value": 0,
		"condition": 100,
		"authentic": true,
		"children": _stock_items(mid),
		"container_spec": spec.duplicate(true),
		"container_locked": false,
		"location": "machine",
	}
	machine_container_items[mid] = item
	return item

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
			if String(it.get("def_id", "")) == "wine_bottle":
				return false
			return is_liquid_container(it) or is_chillable_item(it) or is_freezable_item(it) or is_spirit_item(it)
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
	var cspec := container_spec(machine_container(machine_id))
	if not cspec.is_empty() and String(cspec.get("kind", "")) == "grid":
		return container_effective_width(cspec) * int(cspec.get("height", 1))
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
	var parent := machine_container(machine_id)
	if parent.is_empty():
		if _stock_items(machine_id).size() >= machine_stock_limit(machine_id):
			return {"ok": false, "text": "机器库存已满。"}
		inventory.remove_at(idx)
		it["location"] = "machine"
		_stock_items(machine_id).append(it)
	else:
		if not container_can_accept(parent, it):
			return {"ok": false, "text": "这件物品不能放入该库存网格。"}
		if not container_auto_add(parent, it):
			return {"ok": false, "text": "机器库存已满。"}
		inventory.remove_at(idx)
		it["location"] = "machine"
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
	var spec := container_spec(machine_container(mid))
	for it in _stock_items(mid):
		var zone := container_zone_at(spec, int(it.get("x", 0)))
		var zid := String(zone.get("id", ""))
		if zid == "chill":
			if is_chillable_item(it):
				_apply_feature(it, "chilled", "冷藏", int(sp.get("chill_bonus", 20)))
			elif is_spirit_item(it):
				_apply_feature(it, "chilled", "冷藏", int(sp.get("chill_bonus", 20)))
		elif zid == "freeze":
			if is_freezable_item(it):
				_apply_feature(it, "frozen", "冷冻", int(sp.get("freeze_bonus", 25)))
			elif is_spirit_item(it):
				_remove_feature(it, "chilled")
				_apply_feature(it, "iceCold", "冰镇", int(sp.get("freeze_bonus", 25)))

func _apply_feature(it: Dictionary, fid: String, fname: String, mod: int) -> void:
	for f in it.get("features", []):
		if String(f.get("id", "")) == fid:
			f["mod"] = mod
			return
	it["features"].append({"id": fid, "name": fname, "mod": mod})

func _remove_feature(it: Dictionary, fid: String) -> void:
	var list: Array = it.get("features", [])
	for i in range(list.size() - 1, -1, -1):
		if String(list[i].get("id", "")) == fid:
			list.remove_at(i)
	it["features"] = list

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
		it["liquid_ml"] = 1000
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
	if not tinkerer_material_saved():
		remove_inventory(material, 1)
	machine_upgrades[mid] = level + 1
	machine_container_items.erase(mid)
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
			if is_liquid_container(it):
				it["liquid_purity"] = maxi(int(it.get("liquid_purity", 0)), 9900)
			it["features"].append({"id": "purified", "name": "已净化", "mod": 15})
		elif kind == "distill":
			it["features"].append({"id": "distilled", "name": "蒸馏", "mod": 20})
			if is_liquid_container(it):
				it["liquid_purity"] = 9990
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
		"machine_active": machine_active, "machine_stock": machine_stock, "machine_cash": machine_cash, "machine_upgrades": machine_upgrades, "machine_state": machine_state, "machine_io": machine_io,
		"phone_clients": phone_clients, "future_customers": future_customers, "commissary_stock": commissary_stock, "commissary_credit": commissary_credit,
		"night_log": night_log, "next_day_power_bonus": next_day_power_bonus, "attraction_bonus": attraction_bonus, "security_alarm_active": security_alarm_active, "security_stop_rate": security_stop_rate,
		"appraiser_level": appraiser_level, "appraisal_progress": appraisal_progress, "appraisal_promotion_day": appraisal_promotion_day,
		"appraisal_promotion_declined": appraisal_promotion_declined, "appraisal_days_missed": appraisal_days_missed,
		"appraisal_blacklist": appraisal_blacklist, "appraisal_introduced": appraisal_introduced, "pending_promotion": pending_promotion,
		"secret_admirer_days": secret_admirer_days, "charity_cooldown": charity_cooldown, "discerning_cooldown": discerning_cooldown,
		"cartel_exit_available": cartel_exit_available, "cartel_exit_uses": cartel_exit_uses, "cartel_exited": cartel_exited,
		"blackmail_next_day": blackmail_next_day,
		"afterhours_visits_left": afterhours_visits_left, "afterhours_went_out": afterhours_went_out,
		"went_out_last_night": went_out_last_night, "last_afterhour_outing_day": last_afterhour_outing_day,
		"scav_attempts_used": scav_attempts_used, "afterhours_location": afterhours_location,
		"jackson_stock": jackson_stock, "satchel_found": satchel_found, "kids_backpack_found": kids_backpack_found,
		"owned_upgrades": owned_upgrades, "profession_id": profession_id, "profession_chosen": profession_chosen, "equipped_armor_uid": equipped_armor_uid, "sec_crimes": sec_crimes, "sec_evidence": sec_evidence, "sec_state": sec_state, "sec_officer_pending": sec_officer_pending, "sec_last_inspection_day": sec_last_inspection_day, "sec_bribe_tracker": sec_bribe_tracker, "sec_inspection_countdown": sec_inspection_countdown, "sec_inspection_pending": sec_inspection_pending, "sec_inspection_personality": sec_inspection_personality, "sec_inspection_fake": sec_inspection_fake, "starting_perk_id": starting_perk_id, "starting_perk_chosen": starting_perk_chosen, "poster_pulled": poster_pulled, "combat_allies": combat_allies, "market_modifiers": market_modifiers, "client_cooldowns": client_cooldowns, "sec_permit_revoke_pending": sec_permit_revoke_pending, "sec_permit_revoke_levels": sec_permit_revoke_levels, "active_permits": active_permits, "trash_items": trash_items, "upgrade_cooldowns": upgrade_cooldowns, "evidence_removal_purchases": evidence_removal_purchases,
		"commissions": commissions, "procurement_orders": procurement_orders, "story_seen": story_seen, "story_flags": story_flags,
		"scene_seen": scene_seen, "wanted_defeated": wanted_defeated, "ending_id": ending_id,
		"tutorial_done": tutorial_done, "tutorial_step": tutorial_step, "difficulty": difficulty, "campaign_mode": campaign_mode,
		"start_type_id": start_type_id, "starting_perk_ids": starting_perk_ids,
		"player_max_hp": player_max_hp, "player_accuracy": player_accuracy, "player_reaction": player_reaction,
		"thirst": thirst, "wounds": wounds, "wound_stable": wound_stable, "addiction_days": addiction_days,
		"narcotic_relief": narcotic_relief, "sentinel_days": sentinel_days, "sentinel_pool": sentinel_pool,
		"luck": luck, "perk_flags": perk_flags, "achievements_unlocked": achievements_unlocked,
		"ach_stats": ach_stats, "run_stats": run_stats, "aug_presence": aug_presence,
		"aug_introduced": aug_introduced, "aug_next_spawn_day": aug_next_spawn_day,
		"hireling": hireling, "hireling_expedition": hireling_expedition, "gun_order": gun_order,
		"store_water_ml": store_water_ml, "next_combat_accuracy_bonus": next_combat_accuracy_bonus,
		"store_requests": store_requests, "store_request_seen": store_request_seen, "marketplace_unlocked_day": marketplace_unlocked_day,
		"property_owned": property_owned, "is_paying_mortgage": is_paying_mortgage,
		"mortgage_week_left": mortgage_week_left, "mortgage_total_weeks": mortgage_total_weeks,
		"mortgage_weekly_payment": mortgage_weekly_payment, "mortgage_down_paid": mortgage_down_paid,
		"mortgage_interest_taken": mortgage_interest_taken, "mortgage_offer_declined": mortgage_offer_declined,
		"property_bought_at": property_bought_at, "property_bought_day": property_bought_day, "mortgage_due": mortgage_due,
		"faction_power": faction_power, "operation_cooldowns": operation_cooldowns, "active_operations": active_operations,
		"space_mode": space_mode, "space_ship": space_ship, "space_fuel": space_fuel, "space_hull": space_hull,
		"space_max_hull": space_max_hull, "space_day": space_day, "space_poi": space_poi, "space_log": space_log,
		"space_at_station": space_at_station,
		"raid_action_points": raid_action_points, "raid_turn": raid_turn, "expedition_loot_log": expedition_loot_log,
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
		if int(it.get("x", -1)) < 0 or int(it.get("y", -1)) < 0:
			display_auto_place(it)
	pages_unlocked = clampi(max_pages_unlocked, 2, GRID_PAGES)
	max_pages_unlocked = pages_unlocked
	power = int(data.get("power", 10))
	owned_upgrades = data.get("owned_upgrades", {}).duplicate(true)
	equipped_armor_uid = int(data.get("equipped_armor_uid", -1))
	sec_crimes = data.get("sec_crimes", {}).duplicate(true)
	sec_evidence = int(data.get("sec_evidence", 0))
	sec_state = int(data.get("sec_state", 0))
	sec_officer_pending = bool(data.get("sec_officer_pending", false))
	sec_last_inspection_day = int(data.get("sec_last_inspection_day", -99))
	sec_bribe_tracker = int(data.get("sec_bribe_tracker", 0))
	sec_inspection_countdown = int(data.get("sec_inspection_countdown", 6))
	sec_inspection_pending = bool(data.get("sec_inspection_pending", false))
	sec_inspection_personality = int(data.get("sec_inspection_personality", 0))
	sec_inspection_fake = bool(data.get("sec_inspection_fake", false))
	sec_permit_revoke_pending = bool(data.get("sec_permit_revoke_pending", false))
	sec_permit_revoke_levels = []
	for lv in data.get("sec_permit_revoke_levels", []):
		sec_permit_revoke_levels.append(int(lv))
	combat_allies = data.get("combat_allies", []).duplicate(true)
	market_modifiers = data.get("market_modifiers", market_modifiers).duplicate(true)
	poster_pulled = bool(data.get("poster_pulled", false))
	starting_perk_id = String(data.get("starting_perk_id", ""))
	starting_perk_chosen = bool(data.get("starting_perk_chosen", false))
	active_permits = []
	for p in data.get("active_permits", []):
		active_permits.append({"type": String(p.get("type", "")), "level": int(p.get("level", 0))})
	trash_items = data.get("trash_items", []).duplicate(true)
	for it in trash_items:
		_normalize_item(it)
	upgrade_cooldowns = data.get("upgrade_cooldowns", {}).duplicate(true)
	evidence_removal_purchases = int(data.get("evidence_removal_purchases", 0))
	client_cooldowns = data.get("client_cooldowns", {}).duplicate(true)
	for cid in client_cooldowns.keys():
		client_cooldowns[cid] = int(client_cooldowns[cid])
	profession_id = String(data.get("profession_id", ""))
	profession_chosen = bool(data.get("profession_chosen", false))
	start_type_id = String(data.get("start_type_id", profession_id))
	starting_perk_ids = data.get("starting_perk_ids", []).duplicate()
	player_max_hp = int(data.get("player_max_hp", 100))
	player_accuracy = int(data.get("player_accuracy", 70))
	player_reaction = int(data.get("player_reaction", 10))
	thirst = int(data.get("thirst", 1000))
	wounds = int(data.get("wounds", 0))
	wound_stable = bool(data.get("wound_stable", true))
	addiction_days = data.get("addiction_days", {"nicotine": 0, "alcohol": 0, "narcotic": 0}).duplicate()
	narcotic_relief = int(data.get("narcotic_relief", 999))
	sentinel_days = int(data.get("sentinel_days", 0))
	sentinel_pool = int(data.get("sentinel_pool", 0))
	luck = int(data.get("luck", 0))
	perk_flags = data.get("perk_flags", {}).duplicate()
	achievements_unlocked = data.get("achievements_unlocked", {}).duplicate()
	ach_stats = data.get("ach_stats", {}).duplicate()
	run_stats = data.get("run_stats", _new_run_stats()).duplicate(true)
	aug_presence = int(data.get("aug_presence", 0))
	aug_introduced = bool(data.get("aug_introduced", false))
	aug_next_spawn_day = int(data.get("aug_next_spawn_day", 0))
	hireling = data.get("hireling", {}).duplicate(true)
	hireling_expedition = data.get("hireling_expedition", {}).duplicate(true)
	gun_order = data.get("gun_order", {}).duplicate(true)
	store_requests = data.get("store_requests", []).duplicate(true)
	store_request_seen = data.get("store_request_seen", []).duplicate()
	marketplace_unlocked_day = int(data.get("marketplace_unlocked_day", -1))
	property_owned = bool(data.get("property_owned", false))
	is_paying_mortgage = bool(data.get("is_paying_mortgage", false))
	mortgage_week_left = int(data.get("mortgage_week_left", 0))
	mortgage_total_weeks = int(data.get("mortgage_total_weeks", 0))
	mortgage_weekly_payment = int(data.get("mortgage_weekly_payment", 0))
	mortgage_down_paid = int(data.get("mortgage_down_paid", 0))
	mortgage_interest_taken = int(data.get("mortgage_interest_taken", 0))
	mortgage_offer_declined = bool(data.get("mortgage_offer_declined", false))
	property_bought_at = int(data.get("property_bought_at", 0))
	property_bought_day = int(data.get("property_bought_day", 0))
	mortgage_due = int(data.get("mortgage_due", 0))
	store_water_ml = int(data.get("store_water_ml", 20000))
	next_combat_accuracy_bonus = int(data.get("next_combat_accuracy_bonus", 0))
	space_mode = bool(data.get("space_mode", false))
	space_ship = data.get("space_ship", {}).duplicate(true)
	space_fuel = int(data.get("space_fuel", 0))
	space_hull = int(data.get("space_hull", 0))
	space_max_hull = int(data.get("space_max_hull", 100))
	space_day = int(data.get("space_day", 1))
	space_poi = data.get("space_poi", {}).duplicate(true)
	space_log = data.get("space_log", []).duplicate()
	space_at_station = bool(data.get("space_at_station", false))
	faction_power = data.get("faction_power", {"rev": 0, "bm": 0, "sec": 0, "civil_unrest": 0}).duplicate()
	operation_cooldowns = data.get("operation_cooldowns", {}).duplicate()
	active_operations = data.get("active_operations", []).duplicate(true)
	raid_action_points = int(data.get("raid_action_points", 100))
	raid_turn = int(data.get("raid_turn", 1))
	expedition_loot_log = data.get("expedition_loot_log", []).duplicate()
	commissions = data.get("commissions", []).duplicate(true)
	procurement_orders = data.get("procurement_orders", []).duplicate(true)
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
	machine_io = data.get("machine_io", {}).duplicate(true)
	phone_clients = data.get("phone_clients", {}).duplicate(true)
	future_customers = data.get("future_customers", []).duplicate(true)
	commissary_stock = data.get("commissary_stock", {}).duplicate(true)
	commissary_credit = int(data.get("commissary_credit", 0))
	if phone_clients.is_empty():
		_init_phone_clients()
	if commissary_stock.is_empty():
		_init_commissary()
	machine_container_items = {}
	night_log = data.get("night_log", []).duplicate(true)
	next_day_power_bonus = int(data.get("next_day_power_bonus", 0))
	attraction_bonus = int(data.get("attraction_bonus", 100))
	security_alarm_active = bool(data.get("security_alarm_active", false))
	security_stop_rate = int(data.get("security_stop_rate", 0))
	appraiser_level = int(data.get("appraiser_level", 0))
	appraisal_progress = float(data.get("appraisal_progress", 0.0))
	appraisal_promotion_day = int(data.get("appraisal_promotion_day", -1))
	appraisal_promotion_declined = bool(data.get("appraisal_promotion_declined", false))
	appraisal_days_missed = int(data.get("appraisal_days_missed", 0))
	appraisal_blacklist = data.get("appraisal_blacklist", []).duplicate(true)
	appraisal_introduced = bool(data.get("appraisal_introduced", true))
	pending_promotion = bool(data.get("pending_promotion", false))
	secret_admirer_days = int(data.get("secret_admirer_days", 0))
	charity_cooldown = int(data.get("charity_cooldown", 0))
	discerning_cooldown = int(data.get("discerning_cooldown", 0))
	cartel_exit_available = bool(data.get("cartel_exit_available", false))
	cartel_exit_uses = int(data.get("cartel_exit_uses", 0))
	cartel_exited = bool(data.get("cartel_exited", false))
	blackmail_next_day = int(data.get("blackmail_next_day", 1))
	afterhours_visits_left = int(data.get("afterhours_visits_left", 0))
	afterhours_went_out = bool(data.get("afterhours_went_out", false))
	went_out_last_night = bool(data.get("went_out_last_night", false))
	last_afterhour_outing_day = int(data.get("last_afterhour_outing_day", -1))
	scav_attempts_used = int(data.get("scav_attempts_used", 0))
	afterhours_location = String(data.get("afterhours_location", ""))
	jackson_stock = data.get("jackson_stock", []).duplicate(true)
	satchel_found = bool(data.get("satchel_found", false))
	kids_backpack_found = bool(data.get("kids_backpack_found", false))
	machine_jobs = data.get("machine_jobs", []).duplicate(true)
	for j in machine_jobs:
		j["remaining"] = float(j.get("remaining", 0.0))
		j["total"] = float(j.get("total", 1.0))
	for mid in machine_stock.keys():
		for it in machine_stock[mid]:
			_normalize_item(it)
	pending_event = {}
	phase = "open"
	_suppress_sec_tick = true
	start_day()
	_suppress_sec_tick = false
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
	it["unit_count"] = int(it.get("unit_count", 1))
	if not it.has("clues") or not it["clues"] is Array:
		it["clues"] = []
	if not it.has("features") or not it["features"] is Array:
		it["features"] = []
	if not it.has("children") or not it["children"] is Array:
		it["children"] = []
	var spec := container_def(String(it.get("def_id", "")))
	if not spec.is_empty():
		if not it.has("container_spec") or not it["container_spec"] is Dictionary:
			it["container_spec"] = spec.duplicate(true)
		if not it.has("container_locked"):
			it["container_locked"] = spec.has("locked") and String(spec.get("locked", "")) != ""
		if String(spec.get("kind", "")) == "liquid" and not it.has("liquid_ml"):
			var cap := int(spec.get("capacity_ml", 500))
			it["liquid_ml"] = cap
			it["liquid_purity"] = clampi(int(it.get("condition", 100)) * 100, 0, 10000)
			it["liquid_contents"] = {"water": cap}
	for ch in it["children"]:
		_normalize_item(ch)


