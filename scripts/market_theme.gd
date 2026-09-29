extends RefCounted

# v0.2.5 Wireframe Fidelity Pass.
# Deliberately neutral: layout and information hierarchy are validated before final art.
static func build() -> Theme:
	var result = Theme.new()
	result.default_font_size = 13
	result.set_color("font_color", "Label", Color("24282e"))

	for type in ["Button", "OptionButton"]:
		result.set_stylebox("normal", type, _panel(Color("ffffff"), Color("d8dde4"), 7, 7))
		result.set_stylebox("hover", type, _panel(Color("f3f7fc"), Color("8cb8ef"), 7, 7))
		result.set_stylebox("pressed", type, _panel(Color("e9f3ff"), Color("3187e5"), 7, 7))
		result.set_stylebox("disabled", type, _panel(Color("f2f3f5"), Color("e1e3e7"), 7, 7))
		result.set_stylebox("focus", type, _panel(Color(0, 0, 0, 0), Color("3187e5"), 7, 7))
		result.set_color("font_color", type, Color("262a30"))
		result.set_color("font_hover_color", type, Color("1f5f9f"))
		result.set_color("font_pressed_color", type, Color("126dcc"))
		result.set_color("font_disabled_color", type, Color("9da3aa"))

	result.set_stylebox("normal", "LineEdit", _panel(Color("ffffff"), Color("d6dbe2"), 9, 11))
	result.set_stylebox("focus", "LineEdit", _panel(Color("ffffff"), Color("3187e5"), 9, 11))
	result.set_color("font_color", "LineEdit", Color("24282e"))
	result.set_color("font_placeholder_color", "LineEdit", Color("8b929b"))

	result.set_stylebox("panel", "PopupMenu", _panel(Color("ffffff"), Color("cfd5dd"), 7, 8))
	result.set_stylebox("panel", "ItemList", _panel(Color("ffffff"), Color("d8dde4"), 7, 8))
	result.set_color("font_color", "PopupMenu", Color("24282e"))
	return result


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
