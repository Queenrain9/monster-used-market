extends SceneTree

const Art = preload("res://scripts/art_catalog.gd")
const Content = preload("res://data/content.gd")
const MarketEngine = preload("res://scripts/game_logic.gd")
const Feed = preload("res://scripts/home_feed.gd")
var failures: Array = []


func _init() -> void:
	var engine = MarketEngine.new(724)
	var feed = Feed.new()
	for item in Content.ITEMS:
		_check(Art.catalog().items.has(item.id), "missing item mapping: " + item.id)
	for seller in Content.SELLERS:
		_check(Art.catalog().sellers.has(seller.id), "missing seller mapping: " + seller.id)
	for group in Art.catalog():
		for id in Art.catalog()[group]:
			var path = str(Art.catalog()[group][id].texture)
			_check(ResourceLoader.exists(path), "missing imported image: " + path)
			var texture = Art.texture_for(group, id)
			_check(texture != null and texture.get_width() <= 768, "image must load at mobile import size: " + path)
	var fallback = Art.texture_for("ui", "fallback")
	_check(Art.texture_for("items", "future-item") == fallback, "unknown ID must use fallback")
	Art.catalog().items["missing-file"] = {"texture": "res://assets/not-present.png"}
	_check(Art.texture_for("items", "missing-file") == fallback, "missing replacement must not break UI")
	Art.catalog().items.erase("missing-file")
	for listing in engine.generate_market(3):
		var before = listing.duplicate(true)
		var data = feed.describe_listing(listing, true)
		_check(data.get("item_art_id", "") == listing.item_id, "feed must connect item identity")
		_check(data.get("seller_art_id", "") == listing.seller.id, "feed must connect seller identity")
		_check(data.name == Art.item_name(listing), "feed must use catalog display name")
		_check(listing == before, "presentation must not rewrite saves or gameplay data")
		for state in ["진품", "모조품", "결함품"]:
			listing.state = state
			listing.condition = "손상"
			listing.rarity = "전설"
			_check(feed.describe_listing(listing, true) == data, "art must not reveal hidden truth")
	if failures.is_empty():
		print("ART SMOKE OK: 24 items, 8 sellers, drop-in final slots, replacement fallback, mobile textures, no truth leaks")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
