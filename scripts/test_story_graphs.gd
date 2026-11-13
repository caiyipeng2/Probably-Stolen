extends SceneTree

func _init() -> void:
	var gs = load("res://scripts/game_state.gd").new()
	gs._load_defs()
	gs.new_game()
	var total_nodes := 0
	var total_choices := 0
	for cid in gs.story_graphs.keys():
		var g: Dictionary = gs.story_graphs[cid]
		total_nodes += g.get("nodes", []).size()
		for n in g.get("nodes", []):
			total_choices += n.get("choices", []).size()
	print("graphs=", gs.story_graphs.size(), " nodes=", total_nodes, " choices=", total_choices)
	var covered := 0
	for scene in gs.story_scenes:
		if gs.story_graphs.has(String(scene.get("id", ""))):
			covered += 1
	print("scenes=", gs.story_scenes.size(), " graph_covered=", covered)
	var g2: Dictionary = gs.story_graphs.get("eleanor4", {})
	var root := int(g2.get("root", 0))
	var node = gs.story_node("sc_eleanor4_%d" % root)
	print("eleanor4 root=", root, " speaker=", node.get("speaker", ""), " text=", node.get("text", ""), " choices=", node.get("choices", []).size())
	quit()
