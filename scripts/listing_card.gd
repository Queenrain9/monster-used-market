extends PanelContainer

const Art = preload("res://scripts/art_catalog.gd")

signal opened

@export var regular_style: StyleBox
@export var featured_style: StyleBox


func _ready() -> void:
	$OpenButton.pressed.connect(func(): opened.emit())


func render(data: Dictionary) -> void:
	var main_info = $Margin/Body/MainInfo
	var side = $Margin/Body/Side
	$Margin/Body/Thumbnail.texture = Art.texture_for("items", str(data.get("item_art_id", "")))
	side.get_node("SellerRow/Portrait").texture = Art.texture_for("sellers", str(data.get("seller_art_id", "")))
	main_info.get_node("Name").text = data["name"]
	main_info.get_node("Price").text = data["price_text"]
	main_info.get_node("Meta").text = str(data.get("meta_text", "어둠마을 야시장"))
	main_info.get_node("Clue").text = data["clue_text"]
	main_info.get_node("Feature").text = data["feature_text"]
	side.get_node("Tags").text = data["tags_text"]
	side.get_node("Seller").text = str(data.get("seller_short_text", data["seller_text"])).trim_prefix("판매자: ")
	side.get_node("Action").text = data["action_text"]
	var featured = not str(data["feature_text"]).is_empty()
	main_info.get_node("Feature").visible = featured
	add_theme_stylebox_override("panel", featured_style if featured else regular_style)
	$OpenButton.disabled = not bool(data["available"])
	$OpenButton.tooltip_text = "%s · %s" % [data["name"], data["action_text"]]
	modulate.a = 1.0 if bool(data["available"]) else 0.55
