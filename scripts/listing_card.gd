extends PanelContainer

const Art = preload("res://scripts/art_catalog.gd")

signal opened

@export var regular_style: StyleBox
@export var featured_style: StyleBox


func _ready() -> void:
	$OpenButton.pressed.connect(func(): opened.emit())


func render(data: Dictionary) -> void:
	var box = $Margin/Box
	box.get_node("Top/Thumbnail").texture = Art.texture_for("items", str(data.get("item_art_id", "")))
	box.get_node("SellerRow/Portrait").texture = Art.texture_for("sellers", str(data.get("seller_art_id", "")))
	box.get_node("Top/Info/Name").text = data["name"]
	box.get_node("Top/Info/Price").text = data["price_text"]
	box.get_node("SellerRow/Action").text = data["action_text"]
	box.get_node("SellerRow/Seller").text = data["seller_text"]
	box.get_node("Top/Info/Tags").text = data["tags_text"]
	box.get_node("Clue").text = data["clue_text"]
	box.get_node("Feature").text = data["feature_text"]
	var featured = not str(data["feature_text"]).is_empty()
	box.get_node("Feature").visible = featured
	add_theme_stylebox_override("panel", featured_style if featured else regular_style)
	$OpenButton.disabled = not bool(data["available"])
	$OpenButton.tooltip_text = "%s · %s" % [data["name"], data["action_text"]]
	modulate.a = 1.0 if bool(data["available"]) else 0.6
