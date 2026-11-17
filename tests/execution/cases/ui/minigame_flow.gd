# [L2 执行层] minigame_flow.gd — 打印失败/成功、配比、DNA
extends "res://tests/execution/case.gd"

var fixtures

func setup() -> void:
	fixtures = load("res://tests/execution/fixtures.gd").new(driver, state)
	await fixtures.boot_to_main("normal", "mobile", seed_value)

func run() -> void:
	var main = driver.root
	step("printer failure")
	check(await fixtures.open_minigame("printer"), "open printer minigame")
	check(await driver.tap("minigame", "btn_start_print"), "start empty printer")
	await driver.root.get_tree().create_timer(0.2).timeout
	check(driver.read_text("minigame", "status").contains("校准失败"), "printer fails empty")
	step("printer success")
	var target: Array = main.minigame_target
	for i in range(16):
		if int(target[i]) == 1:
			var cell := main.find_child("minigame_cell_%d" % i, true, false) as Control
			check(await driver.tap_control(cell), "cell " + str(i))
	check(await driver.tap("minigame", "btn_start_print"), "start calibrated printer")
	await driver.root.get_tree().create_timer(0.3).timeout
	check(state.machine_jobs.size() >= 1, "printer job queued")
	await shot("printer_job")
	step("mix")
	check(await fixtures.open_minigame("chem_finisher"), "open mix minigame")
	for i in range(3):
		check(driver.set_slider_at("mix_sliders", i, float(main.mix_target[i])), "mix slider " + str(i))
	check(await driver.tap("minigame", "btn_start_mix"), "start mix")
	await driver.root.get_tree().create_timer(0.3).timeout
	check(state.machine_jobs.size() >= 2, "mix job queued")
	await shot("mix_done")
	step("dna")
	check(await fixtures.open_minigame("plant_dna_manipulator"), "open dna minigame")
	for base in main.dna_target:
		check(await driver.tap("minigame", "base_" + String(base).to_lower()), "dna base " + String(base))
	check(await driver.tap("minigame", "btn_submit_dna"), "submit dna")
	await driver.root.get_tree().create_timer(0.3).timeout
	# HEAD 的 DNA 编辑器没有 recipes 数据，start_machine 会返回“辅助设备”；
	# 这里只验证序列匹配后小游戏关闭，开机队列覆盖等产品补齐配方后再加。
	check(not main.dna_layer.visible, "dna sequence accepted",
		String(main.machine_status_label.text) + " | " + String(main.dna_status.text))
	await shot("dna_done")
