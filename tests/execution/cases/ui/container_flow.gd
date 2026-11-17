# [L2 执行层] container_flow.gd — 打开容器、拖入、拖回、关闭
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)

func run() -> void:
	var bag = state.make_item("backpack_large", 100, true, false)
	var fruit = state.make_item("nutrifruit", 100, true, false)
	state.add_item(bag)
	state.add_item(fruit)
	state.emit_signal("state_changed")
	await driver.root.get_tree().process_frame
	check(await driver.tap_item_uid(int(bag.uid)), "select backpack")
	check(await driver.tap("main", "detail_open_btn"), "open backpack")
	check(await driver.wait_visible("container", "title", 3000), "container open")
	check(driver.read_text("container", "title").contains("容器"), "container title")
	await shot("container_open")
	var before := int(bag.children.size())
	check(await driver.drag_item_to_container(int(fruit.uid), 2, 2), "drag fruit in")
	await driver.root.get_tree().process_frame
	var after := int(bag.children.size())
	check_eq(after, before + 1, "child count +1")
	await shot("container_dragged_in")
	check(await driver.drag_container_item_to_main(int(fruit.uid), 1, 1), "drag fruit back")
	await driver.root.get_tree().process_frame
	check_eq(String(state.find_item(int(fruit.uid)).get("location", "backpack")), "backpack", "fruit back")
	check(bag.children.is_empty(), "bag emptied", str(bag.children.size()))
	await shot("container_dragged_back")
	check(await driver.tap("container", "btn_close"), "close container")
	check(not driver.is_visible("container", "title"), "container closed")
