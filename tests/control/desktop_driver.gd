# [L1 控件层] desktop_driver.gd — 语义控件解析 + 真实输入事件注入
extends RefCounted

var root: Node
var ui_map: Dictionary = {}
var last_error := ""
var direct_actions: Array = []

func _init(main_node: Node, map_path := "res://tests/control/ui_map.json") -> void:
	root = main_node
	var f := FileAccess.open(map_path, FileAccess.READ)
	if f:
		ui_map = JSON.parse_string(f.get_as_text())
	else:
		push_error("ui_map missing: " + map_path)

func _spec(screen: String, key: String) -> Dictionary:
	return ui_map.get("screens", {}).get(screen, {}).get(key, {})

func _scope(spec: Dictionary) -> Node:
	var scope_name := String(spec.get("scope", ""))
	if scope_name != "":
		var sc = root.get(scope_name)
		if sc != null:
			return sc
	return root

func _find_by_text(parent: Node, text: String, contains: bool) -> Control:
	for child in parent.get_children():
		if child is Button and child.is_visible_in_tree():
			var t := String(child.text)
			if (contains and t.contains(text)) or (not contains and t == text):
				return child
		var found := _find_by_text(child, text, contains)
		if found != null:
			return found
	return null

func resolve(screen: String, key: String) -> Control:
	var spec := _spec(screen, key)
	if spec.is_empty():
		return null
	if spec.has("property"):
		var c = root.get(String(spec["property"]))
		if c is Control:
			return c
	if spec.has("name"):
		var n := root.find_child(String(spec["name"]), true, false)
		if n is Control:
			return n
	var scope := _scope(spec)
	if spec.has("text"):
		return _find_by_text(scope, String(spec["text"]), false)
	if spec.has("text_contains"):
		return _find_by_text(scope, String(spec["text_contains"]), true)
	return null

func is_visible(screen: String, key: String) -> bool:
	var c := resolve(screen, key)
	return c != null and c.is_visible_in_tree()

func read_text(screen: String, key: String) -> String:
	var c := resolve(screen, key)
	if c is Button:
		return (c as Button).text
	if c is Label:
		return (c as Label).text
	if c is LineEdit:
		return (c as LineEdit).text
	return ""

func read_property(prop: String):
	return root.get(prop)

func tap_control(control: Control) -> bool:
	if control == null or not control.is_visible_in_tree():
		return false
	if control is Button and (control as Button).disabled:
		last_error = "control disabled: " + String(control.name)
		return false
	await _click_at(control.get_global_rect().get_center())
	return true

func tap_text_contains(screen: String, text: String) -> bool:
	var scope := _scope(_spec(screen, "list"))
	var c := _find_by_text(scope, text, true)
	return await tap_control(c)

func find_text_contains(screen: String, text: String) -> Control:
	var scope := _scope(_spec(screen, "list"))
	return _find_by_text(scope, text, true)

func tap_first_in(property: String) -> bool:
	var parent = root.get(property)
	if parent == null:
		return false
	for child in parent.get_children():
		if child is Button and child.is_visible_in_tree():
			return await tap_control(child)
	return false

func type_text(screen: String, key: String, value: String) -> bool:
	var c := resolve(screen, key)
	if c is LineEdit:
		var edit := c as LineEdit
		edit.grab_focus()
		edit.text = value
		edit.text_submitted.emit(value)
		direct_actions.append("type_text:%s.%s" % [screen, key])
		return true
	return false

func _click_at(pos: Vector2) -> void:
	var vp := root.get_viewport()
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = pos
	down.global_position = pos
	vp.push_input(down, true)
	await root.get_tree().process_frame
	await root.get_tree().create_timer(0.02).timeout
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = pos
	up.global_position = pos
	vp.push_input(up, true)
	await root.get_tree().process_frame
	await root.get_tree().create_timer(0.02).timeout

func tap(screen: String, key: String) -> bool:
	var c := resolve(screen, key)
	if c == null or not c.is_visible_in_tree():
		last_error = "control not found: %s.%s" % [screen, key]
		return false
	if c is Button and (c as Button).disabled:
		last_error = "control disabled: %s.%s" % [screen, key]
		return false
	await _click_at(c.get_global_rect().get_center())
	return true

func wait_visible(screen: String, key: String, timeout_ms := 5000) -> bool:
	var deadline := Time.get_ticks_msec() + timeout_ms
	while Time.get_ticks_msec() < deadline:
		if is_visible(screen, key):
			return true
		await root.get_tree().create_timer(0.05).timeout
	last_error = "timeout: %s.%s" % [screen, key]
	return false

func drag_between(from_control: Control, to_pos: Vector2, steps := 12) -> bool:
	if from_control == null:
		return false
	var vp := root.get_viewport()
	var start := from_control.get_global_rect().get_center()
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = start
	down.global_position = start
	vp.push_input(down, true)
	await root.get_tree().process_frame
	for i in range(1, steps + 1):
		var p := start.lerp(to_pos, float(i) / float(steps))
		var motion := InputEventMouseMotion.new()
		motion.position = p
		motion.global_position = p
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		vp.push_input(motion, true)
		await root.get_tree().process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = to_pos
	up.global_position = to_pos
	vp.push_input(up, true)
	await root.get_tree().process_frame
	return true

func tap_item_uid(uid: int) -> bool:
	var node := root.find_child("item_%d" % uid, true, false)
	if node is Control and node.is_visible_in_tree():
		return await tap_control(node)
	return false

func tap_item_def(def_id: String) -> bool:
	var gs = root.get_node("/root/GameState")
	for it in gs.inventory:
		if String(it.get("def_id", "")) == def_id:
			return await tap_item_uid(int(it["uid"]))
	return false

func drag_item_to_container(uid: int, gx: int, gy: int) -> bool:
	var item := root.find_child("item_%d" % uid, true, false) as Control
	var grid := root.get("container_grid") as Control
	if item == null or grid == null:
		return false
	var pos := grid.global_position + Vector2(gx * 50 + 16, gy * 50 + 16)
	return await drag_between(item, pos)

func drag_container_item_to_main(uid: int, gx: int, gy: int) -> bool:
	var item := root.find_child("container_item_%d" % uid, true, false) as Control
	var grid := root.get("grid_root") as Control
	if item == null or grid == null:
		return false
	var pos := grid.global_position + Vector2(gx * 58 + 27, gy * 58 + 27)
	return await drag_between(item, pos)

func set_slider_at(property: String, index: int, value: float) -> bool:
	var arr = root.get(property)
	if arr is Array and index >= 0 and index < arr.size() and arr[index] is HSlider:
		var slider := arr[index] as HSlider
		slider.set_value_no_signal(value)
		slider.value_changed.emit(value)
		direct_actions.append("set_slider_at:%s[%d]" % [property, index])
		return true
	return false

func dump_screen(screen: String) -> Dictionary:
	var out := {}
	var view := root.get_viewport().get_visible_rect().size
	for key in ui_map.get("screens", {}).get(screen, {}).keys():
		var c := resolve(screen, key)
		if c == null or not c.is_visible_in_tree():
			continue
		var r := c.get_global_rect()
		out[key] = {"x": r.position.x / view.x, "y": r.position.y / view.y,
					"w": r.size.x / view.x, "h": r.size.y / view.y}
	return out
