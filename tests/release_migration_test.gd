extends SceneTree

const MainScene = preload("res://scenes/main.tscn")

var failures: Array = []
var game


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var data_root = OS.get_environment("MONSTER_SMOKE_DATA_ROOT").replace("\\", "/")
	if data_root.is_empty() or not OS.get_user_data_dir().replace("\\", "/").begins_with(data_root):
		push_error("RELEASE MIGRATION FAILED: isolated user data root is required")
		quit(1)
		return

	root.size = Vector2i(390, 844)
	game = MainScene.instantiate()
	root.add_child(game)
	await _settle()

	var legacy_payload = {
		"version":37,
		"gold":73500,
		"total_deals":14,
		"today_deals":1,
		"game_started":true,
		"onboarding_complete":true,
		"merchant_day":7,
		"merchant_reputation":235,
		"daily_goal_progress":1,
		"daily_goal_claimed":true,
		"collection_goal_claimed":{"catalog_3":true,"catalog_6":true,"set_1":true,"catalog_all":true},
		"achievement_unlocks":{"first_truth":true,"six_items":true,"one_set":true,"all_items":true},
		"collection_records":{},
		"seller_relationships":{},
		"upgrade_levels":{},
		"market_items":[],
		"owned_items":[],
		"stage":"town"
	}
	var file = FileAccess.open(game.SAVE_PATH, FileAccess.WRITE)
	_expect(file != null, "must be able to write v37 migration fixture")
	if file != null:
		file.store_string(JSON.stringify(legacy_payload))
		file.close()

	game.queue_free()
	await _settle()
	game = MainScene.instantiate()
	root.add_child(game)
	await _settle()

	_expect(game.game_started and game.onboarding_complete, "commercial save identity must survive P8 migration")
	_expect(game.gold == 73500, "P8 catalog migration must not alter existing gold")
	_expect(game.merchant_day == 7 and game.merchant_reputation == 235, "P8 catalog migration must not alter day/reputation")
	_expect(bool(game.collection_goal_claimed.get("catalog_12", false)), "old 12/12 catalog reward must migrate to the new 12-item midpoint")
	_expect(not bool(game.collection_goal_claimed.get("catalog_all", false)), "old 12/12 goal must not auto-complete new 24/24 catalog")
	_expect(game.achievement_unlocks.has("twelve_items"), "old all-items achievement must migrate to 12-item achievement")
	_expect(not game.achievement_unlocks.has("all_items"), "old all-items flag must not unlock new 24-item achievement")

	game._save_game()
	var repaired = game._read_save_dictionary(game.SAVE_PATH)
	_expect(int(repaired.get("version", 0)) >= 38, "migrated save must be rewritten with P8 schema")
	_expect(bool(repaired.get("collection_goal_claimed", {}).get("catalog_12", false)), "rewritten save must persist migrated midpoint goal")

	game.queue_free()
	await _settle()

	if failures.is_empty():
		print("RELEASE MIGRATION OK: v37 12-item completion safely becomes P8 midpoint without losing economy/progress")
		quit(0)
	else:
		for failure in failures:
			push_error("RELEASE MIGRATION FAILED: %s" % failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)


func _settle() -> void:
	for i in range(6):
		await process_frame
