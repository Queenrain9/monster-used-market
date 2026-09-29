extends SceneTree

const MainScene = preload("res://scenes/main.tscn")

var failures: Array = []
var game


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var sizes = [
		Vector2i(375, 812),
		Vector2i(390, 844),
		Vector2i(430, 932)
	]
	for size in sizes:
		await _test_size(size)
		if not failures.is_empty():
			break

	if failures.is_empty():
		print("RELEASE LAYOUT OK: 375x812, 390x844, 430x932 commercial shells and meta screens")
		quit(0)
	else:
		for failure in failures:
			push_error("RELEASE LAYOUT FAILED: %s" % failure)
		quit(1)


func _test_size(size: Vector2i) -> void:
	root.size = size
	game = MainScene.instantiate()
	root.add_child(game)
	await _settle()

	game._reset_core_progress()
	game.game_started = true
	game.onboarding_complete = true
	game._create_new_market(true, false, false)
	game._update_header()
	await _settle()

	game._show_title_screen()
	await _settle()
	_assert_horizontal_fit(game.commercial_shell, size, "%s title" % str(size))
	_expect(game.get_node("CommercialShell/ArtBackground").texture != null, "%s title final-art slot must resolve to final or fallback texture" % str(size))

	for page in range(3):
		game._show_onboarding_page(page)
		await _settle()
		_assert_horizontal_fit(game.commercial_shell, size, "%s onboarding %d" % [str(size), page + 1])
		_expect(game.get_node("CommercialShell/Center/Card/OnboardingView/Art").texture != null, "%s onboarding page %d needs a resolved art slot" % [str(size), page + 1])

	game.commercial_shell.hide()

	var screens = [
		{"name":"town", "method":"_go_town", "node":game.town_panel},
		{"name":"workshop", "method":"_go_workshop", "node":game.workshop_panel},
		{"name":"relationships", "method":"_go_relationships", "node":game.relationships_panel},
		{"name":"collection", "method":"_go_collection", "node":game.collection_panel},
		{"name":"market", "method":"_go_market", "node":game.market_panel},
		{"name":"inventory", "method":"_go_inventory", "node":game.inventory_panel},
		{"name":"records", "method":"_go_records", "node":game.result_panel}
	]
	for spec in screens:
		game.call(str(spec["method"]))
		await _settle()
		var panel: Control = spec["node"]
		_expect(panel.visible, "%s %s must become visible" % [str(size), spec["name"]])
		_assert_horizontal_fit(panel, size, "%s %s" % [str(size), spec["name"]])
		for scroll in _nodes_of_type(panel, "ScrollContainer"):
			_expect(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "%s %s must never require horizontal scrolling" % [str(size), spec["name"]])

	game.queue_free()
	await _settle()


func _assert_horizontal_fit(node: Node, viewport_size: Vector2i, context: String) -> void:
	for control in _visible_controls(node):
		if control.size.x <= 0.0:
			continue
		var rect = control.get_global_rect()
		if rect.position.x < -1.0 or rect.end.x > float(viewport_size.x) + 1.0:
			_failures_once("%s overflow: %s [%.1f..%.1f] > %d" % [
				context,
				str(control.get_path()),
				rect.position.x,
				rect.end.x,
				viewport_size.x
			])
			return


func _visible_controls(node: Node) -> Array:
	var result: Array = []
	if node is Control and node.is_visible_in_tree():
		result.append(node)
	for child in node.get_children():
		result.append_array(_visible_controls(child))
	return result


func _nodes_of_type(node: Node, type_name: String) -> Array:
	var result: Array = []
	if node.is_class(type_name):
		result.append(node)
	for child in node.get_children():
		result.append_array(_nodes_of_type(child, type_name))
	return result


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures_once(message)


func _failures_once(message: String) -> void:
	if not failures.has(message):
		failures.append(message)


func _settle() -> void:
	for i in range(6):
		await process_frame
