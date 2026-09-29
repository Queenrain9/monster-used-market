extends RefCounted

# Presentation only: never inspect state, rarity, condition, price or archetype.
const Manifest = preload("res://data/art_catalog.gd")
static var _catalog: Dictionary = {}
static var _textures: Dictionary = {}


static func catalog() -> Dictionary:
	if _catalog.is_empty():
		_catalog = Manifest.ENTRIES.duplicate(true)
	return _catalog


static func texture_for(group: String, id: String) -> Texture2D:
	var entry: Dictionary = catalog().get(group, {}).get(id, {})
	var path = str(entry.get("texture", ""))
	var result = _texture(path)
	if result == null:
		result = _texture(str(catalog().get("ui", {}).get("fallback", {}).get("texture", "")))
	return result


static func _texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	if not _textures.has(path):
		_textures[path] = load(path) as Texture2D
	return _textures[path]


static func item_name(listing: Dictionary) -> String:
	return _display_name("items", str(listing.get("item_id", "")), str(listing.get("name", "")))


static func seller_name(seller: Dictionary) -> String:
	return _display_name("sellers", str(seller.get("id", "")), str(seller.get("name", "")))


static func _display_name(group: String, id: String, fallback: String) -> String:
	var entry: Dictionary = catalog().get(group, {}).get(id, {})
	# Preserve custom names in saves / mods, including names not known to this skin.
	if fallback not in [str(entry.get("legacy_name", "")), str(entry.get("name", ""))]:
		return fallback
	return str(entry.get("name", fallback))
