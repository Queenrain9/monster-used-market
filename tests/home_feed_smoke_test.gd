extends SceneTree

const MainScene = preload("res://scenes/main.tscn")
const MarketEngine = preload("res://scripts/game_logic.gd")
const Content = preload("res://data/content.gd")

var errors: Array = []
var checks = 0
var game


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var data_root = OS.get_environment("MONSTER_SMOKE_DATA_ROOT").replace("\\", "/")
	if data_root.is_empty() or not OS.get_user_data_dir().replace("\\", "/").begins_with(data_root):
		push_error("Set an isolated APPDATA/XDG_DATA_HOME and MONSTER_SMOKE_DATA_ROOT before this save-writing test.")
		quit(1)
		return
	root.size = Vector2i(390, 844)
	game = MainScene.instantiate()
	root.add_child(game)
	await _settle()
	var cards = game.get_node_or_null("Margin/RootVBox/MarketPanel/Scroll/Box/FeedCards")
	_expect(cards != null and cards.get_child_count() == 3, "home must contain three separate listing cards")
	if cards == null:
		await _finish()
		return
	await _test_public_feed(cards)
	await _test_browsing(cards)
	await _test_trade_flow(cards)
	await _test_save_compatibility()
	await _finish()


func _test_public_feed(cards) -> void:
	var presenter = load("res://scripts/home_feed.gd").new()
	var engine = MarketEngine.new(20260929)
	var market = engine.generate_market(3)
	game.market_items = market
	game.investigation_remaining = 4
	game.owned_items = []
	game.gold = 50000
	game.last_result_text = ""
	game._update_header()
	game._go_market()
	await _settle()
	await _capture("home-feed")
	var first_card_rect = cards.get_child(0).get_global_rect()
	var click_position = first_card_rect.position + Vector2(20, 20)
	for pressed in [true, false]:
		var click = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = pressed
		click.position = click_position
		click.global_position = click_position
		root.push_input(click)
		await _settle()
	_expect(game.current_stage == "detail" and game.selected_market_index == 0, "real card hit area must open the existing detail")
	await _capture("listing-detail")
	_expect(game.get_node("Margin/RootVBox/DetailPanel/Scroll/Box/HeroRow/ImageColumn/ItemArt").texture == cards.get_child(0).get_node("Margin/Body/Thumbnail").texture, "home and detail must show the same public artwork")
	game._go_market()
	await _settle()
	var original_id = market[0]["listing_id"]
	for i in range(100):
		market[0]["listing_id"] = "feature-preview-%d" % i
		if presenter.choose_featured_index(market) == 0:
			break
	game._render_market()
	await _settle()
	await _capture("home-special")
	market[0]["listing_id"] = original_id
	game._render_market()
	var card = market[0]
	card["seller"]["type"] = "urgent"
	card["seller"]["personality"] = Content.SELLER_TYPES["urgent"].duplicate(true)
	card["initial_clue"]["text"] = "공개된 흔적 하나."
	card["seller_claim"]["text"] = "판매자 주장 비공개표식"
	card["discovered_clues"].append({"kind": "시세", "text": "조사 결과 비공개표식"})
	var public_data = presenter.describe_listing(card, true)
	_expect(str(public_data["tags_text"]).contains("가격 협의"), "public feed should communicate negotiability without revealing seller archetype")
	_expect(not str(public_data).contains("급한 판매자"), "public feed must not reveal the hidden urgent seller archetype")
	_expect(public_data["clue_text"] == "공개된 흔적 하나.", "home must expose only the initial clue")
	var hidden_changed = card.duplicate(true)
	hidden_changed["state"] = "모조품"
	hidden_changed["condition"] = "손상"
	hidden_changed["rarity"] = "전설"
	hidden_changed["actual_value"] = 999999999
	hidden_changed["trade_plan"] = {"value_band": "30,000G 이상", "max_buy_price": 12345}
	_expect(presenter.describe_listing(hidden_changed, true) == public_data, "hidden truths and trade plans must not alter the home projection")
	for archetype in ["stable", "ambiguous", "risky", "jackpot", "trap"]:
		hidden_changed["archetype"] = archetype
		_expect(presenter.describe_listing(hidden_changed, true) == public_data, "special appearance must not encode archetype %s" % archetype)
	var featured_count = 0
	var ordinary_count = 0
	for i in range(60):
		market[0]["listing_id"] = "feed-fixture-%d" % i
		var chosen = presenter.choose_featured_index(market)
		_expect(chosen >= -1 and chosen < 3, "feature selection must choose at most one real listing")
		_expect(chosen == presenter.choose_featured_index(market), "feature selection must stay stable while browsing")
		if chosen >= 0:
			featured_count += 1
		else:
			ordinary_count += 1
		for archetype in ["stable", "ambiguous", "risky", "jackpot", "trap"]:
			for listing in market:
				listing["archetype"] = archetype
			_expect(presenter.choose_featured_index(market) == chosen, "all archetypes must share feature eligibility, including traps")
	_expect(featured_count > 0 and ordinary_count > 0, "special listing must be occasional")
	game._render_market()
	await _settle()
	var home_text = _visible_text(cards)
	_expect(not home_text.contains("판매자 주장 비공개표식") and not home_text.contains("조사 결과 비공개표식"), "home must not reveal claims or discovered details")
	_expect(game.next_market_button.disabled, "uninvestigated market must not allow a free rotation")
	var old_ids = _listing_ids()
	game._request_next_market()
	_expect(_listing_ids() == old_ids and game.investigation_remaining == 4, "blocked rotation must keep all listings and resources")
	await _assert_layout("initial home")
	for listing in game.market_items:
		listing["name"] = "아주 긴 매물 이름과 보관 설명 ".repeat(12) + "unbroken".repeat(40)
		listing["seller"]["name"] = "긴 판매자 이름 ".repeat(10)
		listing["initial_clue"]["text"] = "긴 공개 단서도 화면 안에서 줄바꿈됩니다. ".repeat(5)
	game._render_market()
	await _assert_layout("long home")
	var home_scroll = game.get_node("Margin/RootVBox/MarketPanel/Scroll")
	home_scroll.scroll_vertical = 100
	await _settle()
	var home_offset = home_scroll.scroll_vertical
	game.market_nav_button.pressed.emit()
	await _settle()
	_expect(home_scroll.scroll_vertical == home_offset, "tapping Home while already browsing must retain the feed position when scrolling exists")


func _test_browsing(cards) -> void:
	var ids = _listing_ids()
	var scroll = game.get_node("Margin/RootVBox/MarketPanel/Scroll").scroll_vertical
	cards.get_child(0).get_node("OpenButton").pressed.emit()
	await _settle()
	_expect(game.current_stage == "detail" and game.selected_market_index == 0, "tapping the first card must open the existing detail")
	var pre_purchase_text = _visible_text(game.get_node("Margin/RootVBox/DetailPanel"))
	var seller_type = str(game.market_items[0]["seller"]["type"])
	var seller_type_name = str(Content.SELLER_TYPES[seller_type]["name"])
	_expect(not pre_purchase_text.contains("[긍정적]") and not pre_purchase_text.contains("[부정적]") and not pre_purchase_text.contains("[애매한]"), "detail must show clue facts without polarity labels")
	_expect(not pre_purchase_text.contains(seller_type_name), "detail must show seller behavior cues without naming the archetype")
	game.inspect_buttons[0].pressed.emit()
	_expect(game.investigation_remaining == 3, "A investigation must consume one shared opportunity")
	var a_clues = game.market_items[0]["discovered_clues"].duplicate(true)
	game.get_node("Margin/RootVBox/DetailPanel/Scroll/Box/BackMarketButton").pressed.emit()
	await _settle()
	_expect(_listing_ids() == ids, "back must keep all three listings")
	_expect(game.get_node("Margin/RootVBox/MarketPanel/Scroll").scroll_vertical == scroll, "back must restore the home feed position")
	cards.get_child(1).get_node("OpenButton").pressed.emit()
	await _settle()
	game.inspect_buttons[1].pressed.emit()
	_expect(game.investigation_remaining == 2, "B must use the same market investigation pool")
	game._go_market()
	await _settle()
	cards.get_child(0).get_node("OpenButton").pressed.emit()
	await _settle()
	_expect(game.market_items[0]["discovered_clues"] == a_clues, "A must keep previously discovered information")
	game.inspect_buttons[0].pressed.emit()
	_expect(game.investigation_remaining == 2, "repeated A investigation must not spend another opportunity")
	for clue in game.market_items[0]["discovered_clues"]:
		clue["text"] += " 非常に長い説明 with long evidence ".repeat(12)
	game._render_detail()
	game.suspect_option.select(1)
	await _assert_layout("long detail and selected suspicion")
	await _assert_popup(game.suspect_option, "suspicion popup")
	game.resale_option.select(2)
	game.max_buy_slider.value = game.max_buy_slider.min_value
	game.get_node("Margin/RootVBox/DetailPanel/Scroll/Box/StartDealButton").pressed.emit()
	await _settle()
	_expect(game.current_stage == "deal", "trade plan must still lead to negotiation")
	_expect(not game.get_node("Margin/RootVBox/Header").visible and not game.get_node("Margin/RootVBox/NavRow").visible, "negotiation must use its dedicated focus screen")
	_expect(game.deal_seller_price.text.contains("판매자 요구가") and game.deal_max_buy.text.contains("내 최대 매입가") and game.deal_expected_resale.text.contains("예상 재판매가"), "negotiation entry must show seller price, purchase ceiling and resale estimate together")
	game.offer_slider.value = game.offer_slider.max_value
	await _settle()
	_expect(not game.offer_warning_label.text.is_empty(), "offer above the saved purchase ceiling must show a warning without blocking input")
	game.evidence_option.select(game.evidence_option.item_count - 1)
	await _assert_layout("long negotiation and evidence")
	await _assert_popup(game.evidence_option, "evidence popup")
	game.evidence_option.select(0)
	game.offer_slider.value = game.offer_slider.min_value
	game.get_node("Margin/RootVBox/DealPanel/Scroll/Box/SubmitOfferButton").pressed.emit()
	await _settle()
	_expect(game.current_stage == "deal" and int(game.market_items[0]["negotiation_state"]["rounds"]) == 1, "a low price must still receive a counter or refusal and spend a negotiation round")
	_expect(game.deal_last_action.text.contains("직전 제안"), "seller response state must expose the player's previous offer")
	_expect(not game.deal_price_change.text.is_empty(), "seller response state must expose whether the seller price changed or stayed")
	_expect(game.deal_round_label.text.contains("1 / 3"), "negotiation status must visibly update the spent round")
	_expect(game.deal_patience_label.get_line_count() == 1 and game.deal_patience_label.autowrap_mode == TextServer.AUTOWRAP_OFF and game.deal_patience_label.text.contains("인내"), "patience status must remain a readable single-line indicator")
	var deal_text = _visible_text(game.get_node("Margin/RootVBox/DealPanel"))
	_expect(not deal_text.contains("[긍정적]") and not deal_text.contains("[부정적]") and not deal_text.contains("[애매한]"), "negotiation evidence must not expose clue polarity")
	game._go_market()
	await _settle()
	game._open_listing(0)
	_expect(game.resale_option.selected == 2, "saved resale estimate must survive home browsing")
	_expect(int(game.max_buy_slider.value) == int(game.market_items[0]["trade_plan"]["max_buy_price"]), "saved purchase ceiling must survive home browsing")
	_expect(int(game.market_items[0]["negotiation_state"]["rounds"]) == 1, "home browsing must not restore negotiation rounds")
	game._investigate(2)
	game._investigate(3)
	game._go_market()
	await _settle()
	_expect(game.investigation_remaining == 0 and not game.next_market_button.disabled, "exhausting investigation must unlock the next market")
	game._request_next_market()
	await _settle()
	_expect(_listing_ids() != ids and game.investigation_remaining == 4, "next market must generate three new listings and restore the pool once")


func _test_trade_flow(cards) -> void:
	game.gold = 500000
	game.total_deals = 0
	game.best_profit = 0
	game.worst_loss = 0
	cards.get_child(0).get_node("OpenButton").pressed.emit()
	game.resale_option.select(2)
	game._start_deal()
	var asking = int(game.market_items[0]["asking"])
	game._buy_current_price()
	await _settle()
	_expect(game.current_stage == "inventory" and game.owned_items.size() == 1, "purchase must enter inventory without forced appraisal")
	_expect(game.gold == 500000 - asking, "purchase must charge the actual agreed price")
	game._go_market()
	await _settle()
	_expect(not game.next_market_button.disabled, "actual purchase must unlock next market without consuming all investigations")
	_expect(cards.get_child(0).get_node("OpenButton").disabled, "completed listing must remain visible and cannot be bought again")
	game._go_inventory()
	_expect(game.get_node("Margin/RootVBox/InventoryPanel/Scroll/Box/ItemArt").texture == load("res://scripts/art_catalog.gd").texture_for("items", str(game.owned_items[0]["listing"]["item_id"])), "owned item must retain its public artwork")
	var real_name = game.owned_items[0]["listing"]["name"]
	game.owned_items[0]["listing"]["name"] = "매우 긴 보유품 이름 ".repeat(30)
	game._render_inventory()
	await _assert_layout("long inventory")
	game.owned_items[0]["listing"]["name"] = real_name
	game._render_inventory()
	await _assert_layout("inventory")
	game._keep_item()
	game.inventory_appraise_button.pressed.emit()
	var gold_before = game.gold
	game.post_buttons[0].pressed.emit()
	_expect(game.gold == gold_before - 120 and int(game.owned_items[0]["inspection_remaining"]) == 1, "extra inspection must charge its fee and use its own budget")
	game.post_buttons[0].pressed.emit()
	_expect(game.gold == gold_before - 120, "repeat paid inspection must not charge twice")
	game.professional_appraise_button.pressed.emit()
	_expect(game.gold == gold_before - 420, "optional professional appraisal must charge 300G")
	_expect(not game.owned_items[0]["appraisal_data"].is_empty(), "appraisal must keep the existing hidden-state result")
	_expect(game.appraisal_comment.text.contains("단서 복기"), "professional appraisal must reveal what discovered facts actually meant")
	await _assert_layout("appraisal")
	game._open_sale()
	await _assert_layout("resale initial")
	var sale_card_1 = game.get_node("Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard1")
	var sale_card_2 = game.get_node("Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard2")
	_expect(sale_card_1.size.y <= 120 and sale_card_2.size.y <= 120, "resale specialist cards must stay compact")
	_expect(sale_card_2.get_global_rect().end.y <= 844.5, "at least two specialist cards must be fully visible before scrolling")
	var initial_offers: Array = game.owned_items[0]["buyer_offers"]
	var resale_text_before = _visible_text(game.get_node("Margin/RootVBox/SalePanel"))
	_expect(not resale_text_before.contains("%sG" % _money(int(initial_offers[0]["price"]))), "unrequested specialist quote 1 must stay hidden in resale UI")
	_expect(not resale_text_before.contains("%sG" % _money(int(initial_offers[1]["price"]))), "unrequested specialist quote 2 must stay hidden in resale UI")
	_expect(resale_text_before.contains("%sG" % _money(int(initial_offers[3]["price"]))), "scrap instant price must be visible before any specialist quote")
	for i in [0, 1, 2]:
		game._select_buyer(i)
		game._request_quote()
	_expect(int(game.owned_items[0]["quote_requests_remaining"]) == 0, "specialist quote requests must remain limited to two")
	_expect(not game.owned_items[0]["buyer_offers"][2]["revealed"], "third specialist must remain unknown")
	_expect(game.owned_items[0]["buyer_offers"][3]["revealed"], "scrap instant price must remain available")
	# Godot's JSON parser converts integers to floats; compare the saved data's
	# semantic representation rather than requiring the in-memory Variant types.
	var ownership = JSON.parse_string(JSON.stringify(game.owned_items))
	game._save_game()
	game.queue_free()
	await _settle()
	game = MainScene.instantiate()
	root.add_child(game)
	await _settle()
	_expect(game.current_stage == "sale" and game.owned_items == ownership, "save/load must preserve ownership, paid information, offers and exhausted quote budget")
	game._select_buyer(0)
	await _assert_layout("resale")
	var sale_price = int(game.owned_items[0]["buyer_offers"][0]["price"])
	game.sell_button.pressed.emit()
	await _settle()
	_expect(game.owned_items.is_empty() and game.total_deals == 1, "sale must remove exactly one owned item and record the deal")
	_expect(game.gold == 500000 - asking - 420 + sale_price, "net assets must include inspection, appraisal and sale")
	var record = game.last_result_text
	_expect(record.contains("실제 물건") and record.contains("거래 계획 복기"), "completed record must preserve judgment and hidden-state review")
	_expect(record.contains("판매자 복기") and record.contains("실제 성향:"), "completed trade must reveal the seller archetype only in post-trade review")
	game.market_nav_button.pressed.emit()
	await _settle()
	game.records_nav_button.pressed.emit()
	await _settle()
	_expect(game.current_stage == "result" and game.result_summary.text == record, "records navigation must reopen the actual saved recent result")
	await _assert_layout("records")
	await _capture("trade-record")
	game._save_game()
	var saved_ids = _listing_ids()
	game.queue_free()
	await _settle()
	game = MainScene.instantiate()
	root.add_child(game)
	await _settle()
	_expect(game.last_result_text == record and game.total_deals == 1, "save/load must preserve records and aggregate statistics")
	_expect(_listing_ids() == saved_ids and game.investigation_remaining == 4, "save/load must not reroll the current market")
	game._go_market()
	game._open_listing(1)
	game.resale_option.select(2)
	game._start_deal()
	game._buy_current_price()
	game._open_sale()
	_expect(game.owned_items[0]["appraisal_data"].is_empty(), "selling without appraisal must remain possible")
	# A pre-art save already contains this discovery under its original name.
	game.owned_items[0]["listing"]["rarity"] = "희귀"
	var legacy_discovery = "%s · 희귀" % game.owned_items[0]["listing"]["name"]
	game.rare_items = [legacy_discovery]
	game._select_buyer(3)
	game._sell_selected_buyer()
	_expect(game.rare_items == [legacy_discovery], "a cosmetic name must not duplicate an existing rare discovery")
	_expect(game.total_deals == 2 and game.last_result_text.contains("검사/감정비 0G"), "unappraised scrap sale must keep a zero information cost and a real result")


func _test_save_compatibility() -> void:
	game._go_market()
	game._open_listing(2)
	game._investigate(0)
	var ids = _listing_ids()
	var clues = game.market_items[2]["discovered_clues"].duplicate(true)
	game._save_game()
	var file = FileAccess.open(game.SAVE_PATH, FileAccess.READ)
	var legacy = JSON.parse_string(file.get_as_text())
	file.close()
	legacy["version"] = 22
	legacy.erase("home_scroll_offset")
	for listing in legacy["market_items"]:
		listing.erase("viewed")
	var legacy_path = OS.get_user_data_dir().get_base_dir().path_join("괴물 중고마켓 MVP v0.2.2").path_join(game.SAVE_PATH.get_file())
	DirAccess.make_dir_recursive_absolute(legacy_path.get_base_dir())
	file = FileAccess.open(legacy_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.SAVE_PATH))
	game.queue_free()
	await _settle()
	game = MainScene.instantiate()
	root.add_child(game)
	await _settle()
	_expect(_listing_ids() == ids and game.investigation_remaining == 3, "v0.2.2 migration must preserve listings and spent investigations")
	_expect(game.market_items[2]["discovered_clues"] == clues, "v0.2.2 migration must preserve discoveries")
	_expect(game.total_deals == 2 and not game.last_result_text.is_empty(), "v0.2.2 migration must preserve completed records")
	game._go_market()
	game.records_nav_button.pressed.emit()
	await _assert_layout("migrated records")
	game.last_result_text = ""
	game.total_deals = 0
	game._go_records()
	_expect(game.result_summary.text.contains("아직"), "empty records must explain the real entry point")
	await _assert_layout("empty records")
	game.get_node("Margin/RootVBox/ResultPanel/Scroll/Box/ResetButton").pressed.emit()
	await _settle()
	var confirmation = game.get_node("ResetConfirmation")
	_expect(confirmation.size.x <= 390 and confirmation.position.x >= 0 and confirmation.position.x + confirmation.size.x <= 390, "reset confirmation must wrap and fit inside the 390px viewport")
	var dialog_label = confirmation.get_label()
	var dialog_text_width = dialog_label.get_theme_font("font").get_string_size(dialog_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, dialog_label.get_theme_font_size("font_size")).x
	_expect(dialog_label.autowrap_mode != TextServer.AUTOWRAP_OFF or dialog_text_width <= dialog_label.size.x, "reset confirmation must not clip its explanatory text")
	for button in [confirmation.get_ok_button(), confirmation.get_cancel_button()]:
		var text_width = button.get_theme_font("font").get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button.get_theme_font_size("font_size")).x
		_expect(button.size.x >= text_width, "reset confirmation buttons must retain enough width for readable labels")
	await _capture("reset-confirmation")
	confirmation.hide()


func _assert_layout(context: String) -> void:
	await _settle()
	_check_bounds(game, context)
	for scroll in _nodes_of_type(game, "ScrollContainer"):
		_expect(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "%s: all scroll containers must disable horizontal scrolling" % context)
		_expect(not scroll.get_h_scroll_bar().is_visible_in_tree(), "%s: no horizontal scrollbar may be visible" % context)
	for bar in _nodes_of_type(game, "HScrollBar"):
		_expect(not bar.is_visible_in_tree(), "%s: internal horizontal scrollbars must also remain hidden" % context)
	var nav = game.get_node("Margin/RootVBox/NavRow")
	if nav.is_visible_in_tree():
		_expect(nav.get_global_rect().end.y <= 844 and nav.get_global_rect().position.y >= 780, "%s: bottom navigation must remain inside the portrait viewport" % context)


func _check_bounds(node: Node, context: String) -> void:
	if node is Control and node.is_visible_in_tree() and not node is ScrollBar:
		var rect = node.get_global_rect()
		_expect(rect.position.x >= -0.5 and rect.end.x <= 390.5, "%s: %s exceeds the horizontal viewport: %s" % [context, node.name, rect])
	for child in node.get_children():
		_check_bounds(child, context)


func _assert_popup(option: OptionButton, context: String) -> void:
	option.show_popup()
	await _settle()
	var popup = option.get_popup()
	_expect(popup.size.x <= 390, "%s: long options must not widen the popup beyond 390px" % context)
	popup.hide()


func _nodes_of_type(node: Node, type_name: String) -> Array:
	var result: Array = []
	if node.is_class(type_name):
		result.append(node)
	for child in node.get_children(true):
		result.append_array(_nodes_of_type(child, type_name))
	return result


func _visible_text(node: Node) -> String:
	var text = ""
	if node is Label and node.is_visible_in_tree():
		text += node.text + "\n"
	for child in node.get_children():
		text += _visible_text(child)
	return text


func _money(value: int) -> String:
	var source = str(abs(value))
	var out = ""
	while source.length() > 3:
		out = "," + source.substr(source.length() - 3, 3) + out
		source = source.substr(0, source.length() - 3)
	out = source + out
	return out


func _listing_ids() -> Array:
	var ids: Array = []
	for listing in game.market_items:
		ids.append(listing["listing_id"])
	return ids


func _settle() -> void:
	for i in range(5):
		await process_frame


func _capture(name: String) -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir=") and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(arg.trim_prefix("--capture-dir=").path_join(name + ".png"))


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		errors.append(message)


func _finish() -> void:
	game.queue_free()
	await _settle()
	if errors.is_empty():
		print("HOME FEED SMOKE OK v0.2.11: %d checks; privacy, A/home/B/home/A, resource gates, inventory/appraisal/quotes/resale, saves and 390x844 layout" % checks)
		quit(0)
	else:
		for message in errors:
			push_error("HOME FEED SMOKE FAILED: %s" % message)
		quit(1)
