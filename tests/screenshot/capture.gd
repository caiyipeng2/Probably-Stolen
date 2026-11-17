# [L3 截图验证测试层] capture.gd — 桌面稳定帧捕获，状态由 compare.py 回填
extends RefCounted

var root: Node
var out_dir: String
var case_id: String
var counter := 0

func _init(main_node: Node, artifacts_dir: String, cid: String) -> void:
	root = main_node
	out_dir = artifacts_dir
	case_id = cid

func capture(shot_name: String) -> Dictionary:
	var img := await _stable_image()
	if img == null:
		return {"name": shot_name, "status": "ERROR", "reason": "no viewport image"}
	counter += 1
	var name := "%02d_%s" % [counter, shot_name]
	var dir := out_dir.path_join(case_id)
	DirAccess.make_dir_recursive_absolute(dir)
	var path := dir.path_join(name + ".png")
	var err := img.save_png(path)
	return {"name": name, "file": path, "status": "PENDING" if err == OK else "ERROR"}

func _stable_image() -> Image:
	var park := InputEventMouseMotion.new()
	park.position = Vector2(2, 2)
	park.global_position = park.position
	root.get_viewport().push_input(park, true)
	await root.get_tree().create_timer(0.1).timeout
	var last: Image = null
	var deadline := Time.get_ticks_msec() + 3000
	while Time.get_ticks_msec() < deadline:
		var img := root.get_viewport().get_texture().get_image()
		if last != null and img.get_data() == last.get_data():
			return img
		last = img
		await root.get_tree().create_timer(0.1).timeout
	return last
