extends RefCounted

const ArtManifest = preload("res://data/art_catalog.gd")

# Production theme contract:
# - without final UI skin files: neutral QA-safe fallback
# - with files at data/art_catalog.gd final_texture slots: 9-slice skin auto-applies
static func build() -> Theme:
	var result = Theme.new()
	result.default_font_size = 13
	result.set_color("font_color", "Label", Color("24282e"))

	var panel_style = _skin_box("skin_panel", 8)
	if panel_style == null:
		panel_style = _panel(Color("f9fafc"), Color("d6dbe2"), 8, 8)
	result.set_stylebox("panel", "PanelContainer", panel_style)

	for type in ["Button", "OptionButton"]:
		var normal = _skin_box("skin_button_normal", 7)
		var hover = _skin_box("skin_button_hover", 7)
		var pressed = _skin_box("skin_button_pressed", 7)
		var disabled = _skin_box("skin_button_disabled", 7)
		result.set_stylebox("normal", type, normal if normal != null else _panel(Color("ffffff"), Color("d8dde4"), 7, 7))
		result.set_stylebox("hover", type, hover if hover != null else _panel(Color("f3f7fc"), Color("8cb8ef"), 7, 7))
		result.set_stylebox("pressed", type, pressed if pressed != null else _panel(Color("e9f3ff"), Color("3187e5"), 7, 7))
		result.set_stylebox("disabled", type, disabled if disabled != null else _panel(Color("f2f3f5"), Color("e1e3e7"), 7, 7))
		result.set_stylebox("focus", type, _panel(Color(0, 0, 0, 0), Color("3187e5"), 7, 7))
		result.set_color("font_color", type, Color("262a30"))
		result.set_color("font_hover_color", type, Color("1f5f9f"))
		result.set_color("font_pressed_color", type, Color("126dcc"))
		result.set_color("font_disabled_color", type, Color("9da3aa"))

	var input_style = _skin_box("skin_input", 9, 11)
	result.set_stylebox("normal", "LineEdit", input_style if input_style != null else _panel(Color("ffffff"), Color("d6dbe2"), 9, 11))
	result.set_stylebox("focus", "LineEdit", input_style if input_style != null else _panel(Color("ffffff"), Color("3187e5"), 9, 11))
	result.set_color("font_color", "LineEdit", Color("24282e"))
	result.set_color("font_placeholder_color", "LineEdit", Color("8b929b"))

	result.set_stylebox("panel", "PopupMenu", panel_style)
	result.set_stylebox("panel", "ItemList", panel_style)
	result.set_color("font_color", "PopupMenu", Color("24282e"))
	return result


static func _skin_box(key: String, content_margin: int = 8, texture_margin: int = 24):
	var entry: Dictionary = ArtManifest.ENTRIES.get("ui", {}).get(key, {})
	var path = str(entry.get("final_texture", ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var texture = load(path) as Texture2D
	if texture == null:
		return null
	var style = StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = texture_margin
	style.texture_margin_top = texture_margin
	style.texture_margin_right = texture_margin
	style.texture_margin_bottom = texture_margin
	style.content_margin_left = content_margin
	style.content_margin_right = content_margin
	style.content_margin_top = content_margin
	style.content_margin_bottom = content_margin
	return style


static func _panel(fill: Color, border: Color, radius: int = 7, margin: int = 8) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = margin
	style.content_margin_right = margin
	style.content_margin_top = margin
	style.content_margin_bottom = margin
	return style
