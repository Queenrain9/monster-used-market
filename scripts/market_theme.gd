extends RefCounted

# Native Control styles only; supplied artwork stays in TextureRects.
static func build() -> Theme:
	var result = Theme.new()
	result.default_font_size = 14
	result.set_color("font_color", "Label", Color("f1e6cf"))
	for type in ["Button", "OptionButton"]:
		result.set_stylebox("normal", type, _panel(Color("302535"), Color("71513c")))
		result.set_stylebox("hover", type, _panel(Color("493547"), Color("c6975a")))
		result.set_stylebox("pressed", type, _panel(Color("815927"), Color("e8b65c")))
		result.set_stylebox("disabled", type, _panel(Color("211d25"), Color("473c43")))
		result.set_stylebox("focus", type, _panel(Color(0, 0, 0, 0), Color("e8b65c")))
		result.set_color("font_color", type, Color("f4e5ca"))
		result.set_color("font_hover_color", type, Color("fff3db"))
		result.set_color("font_pressed_color", type, Color("fff4de"))
		result.set_color("font_disabled_color", type, Color("a99eac"))
	result.set_stylebox("panel", "PopupMenu", _panel(Color("211a28"), Color("a67b49")))
	result.set_stylebox("panel", "ItemList", _panel(Color("211a28"), Color("71513c")))
	return result


static func _panel(fill: Color, border: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(7)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	return style
