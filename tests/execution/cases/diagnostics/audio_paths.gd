# [L2 执行层] audio_paths.gd — 音频路径解析诊断
extends "res://tests/execution/case.gd"

func run() -> void:
	var main = driver.root
	for id in ["music_main", "ambience_station", "sfx_click"]:
		var path: String = main.call("_audio_path", id + ".ogg")
		check(path != "", "audio path " + id, path)
		check(FileAccess.file_exists(path), "audio exists " + id, path)
