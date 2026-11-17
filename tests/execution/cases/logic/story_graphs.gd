# [L2 执行层] story_graphs.gd — 剧情图规模与场景覆盖
extends "res://tests/execution/case.gd"

func run() -> void:
	var total_nodes := 0
	var total_choices := 0
	for cid in state.story_graphs.keys():
		var g: Dictionary = state.story_graphs[cid]
		total_nodes += g.get("nodes", []).size()
		for n in g.get("nodes", []):
			total_choices += n.get("choices", []).size()
	check_eq(state.story_graphs.size(), 341, "graphs")
	check_eq(total_nodes, 2165, "nodes")
	check_eq(total_choices, 80, "choices")
	var covered := 0
	for scene in state.story_scenes:
		if state.story_graphs.has(String(scene.get("id", ""))):
			covered += 1
	check_eq(state.story_scenes.size(), 55, "scenes")
	check_eq(covered, 53, "graph covered scenes")
	var g2: Dictionary = state.story_graphs.get("eleanor4", {})
	var root := int(g2.get("root", 0))
	var node = state.story_node("sc_eleanor4_%d" % root)
	check_eq(root, 2, "eleanor4 root")
	check_eq(String(node.get("speaker", "")), "埃莉诺", "eleanor4 speaker")
	check(String(node.get("text", "")).begins_with("我的资金耗尽了"), "eleanor4 text")
	check_eq(node.get("choices", []).size(), 0, "eleanor4 choices")
