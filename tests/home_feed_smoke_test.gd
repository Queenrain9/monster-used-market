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
	await _test_commercial_shell()
	await _test_presentation_layer()
	await _test_world_session()
	await _test_dynamic_market_events()
	await _test_relationship_progression()
	await _test_collection_progression()
	cards = game.get_node_or_null("Margin/RootVBox/MarketPanel/Scroll/Box/FeedCards")
	_expect(cards != null and cards.get_child_count() == 3, "test harness must refresh listing-card references after save/load reconstruction")
	if cards == null:
		await _finish()
		return
	await _test_public_feed(cards)
	await _test_browsing(cards)
	await _test_trade_flow(cards)
	await _test_save_compatibility()
	await _test_save_recovery()
	await _finish()


func _test_commercial_shell() -> void:
	game._show_title_screen()
	_expect(game.commercial_shell.visible and game.title_view.visible, "commercial build must have a real title screen")
	_expect(game.continue_button.disabled, "fresh install must not offer a fake continue action")
	game._new_game_from_title()
	_expect(game.game_started and game.onboarding_view.visible and not game.onboarding_complete, "new game must enter first-session onboarding")
	_expect(game.onboarding_step_label.text == "1 / 3", "onboarding must start at step 1 of 3")
	game._advance_onboarding()
	_expect(game.onboarding_step_label.text == "2 / 3", "onboarding must advance to role explanation")
	game._advance_onboarding()
	_expect(game.onboarding_step_label.text == "3 / 3" and game.onboarding_next_button.text == "장터 열기", "onboarding final step must explain the first objective")
	game._advance_onboarding()
	_expect(game.onboarding_complete and not game.commercial_shell.visible and game.current_stage == "market", "finishing onboarding must enter the playable market")
	_expect(game.day_label.text.contains("DAY 1") and game.rank_label.text == "견습 물건상" and game.reputation_label.text.contains("평판 0"), "commercial HUD must expose day, rank and reputation")
	_expect(game.goal_label.text.contains("첫 거래 완료") and game.goal_label.text.contains("0/1"), "first session must expose a concrete daily objective")
	await _assert_layout("commercial first session")


func _test_presentation_layer() -> void:
	game._show_settings()
	await _settle()
	_expect(game.settings_overlay.visible, "commercial settings must be available as an overlay")
	_expect(game.settings_overlay.get_global_rect().size.x <= 390.5 and game.settings_overlay.get_global_rect().size.y <= 844.5, "settings overlay must fit the portrait viewport")

	game.settings_music_slider.value = 0.35
	game.settings_sfx_slider.value = 0.45
	game.settings_haptics_check.button_pressed = false
	game.settings_reduced_motion_check.button_pressed = true
	game.settings_large_text_check.button_pressed = true
	await _settle()
	_expect(abs(float(game.presentation_settings["music_volume"]) - 0.35) < 0.001, "music volume setting must update live")
	_expect(abs(float(game.presentation_settings["sfx_volume"]) - 0.45) < 0.001, "sfx volume setting must update live")
	_expect(not bool(game.presentation_settings["haptics"]) and bool(game.presentation_settings["reduced_motion"]) and bool(game.presentation_settings["large_text"]), "accessibility and feedback toggles must update live")
	_expect(FileAccess.file_exists(game.SETTINGS_PATH), "presentation settings must persist independently of game progress")

	game._presentation_event("purchase", "success")
	_expect(game.last_presentation_event == "purchase", "presentation event keys must work even before final audio files exist")
	game.market_panel.modulate = Color(1, 1, 1, 0)
	game._play_screen_enter(game.market_panel)
	_expect(game.market_panel.modulate.a >= 0.99, "reduced-motion mode must skip animated screen fades")

	game.tutorial_flags.erase("chat")
	game._maybe_show_context_tip("chat", true)
	_expect(game.context_tip.visible and game.context_tip_title.text.length() > 0, "contextual tutorial must be renderable on first visit")
	game._dismiss_context_tip()
	_expect(bool(game.tutorial_flags.get("chat", false)) and not game.context_tip.visible, "dismissing a contextual tip must persist its seen state")

	# Return settings to normal test defaults while proving the file is writable.
	game.settings_haptics_check.button_pressed = true
	game.settings_reduced_motion_check.button_pressed = false
	game.settings_large_text_check.button_pressed = false
	game._hide_settings()
	await _assert_layout("presentation settings")


func _test_world_session() -> void:
	game.merchant_reputation = 0
	game.merchant_day = 1
	game.market_visits_remaining = Content.DAY_MARKET_VISITS
	game.current_district_id = ""
	game.market_items = []
	game.daily_goal_progress = 0
	game.daily_goal_claimed = false
	game.day_start_gold = game.gold
	game.last_day_summary = {}
	game.day_event_id = ""
	game._go_town()
	await _settle()
	_expect(game.current_stage == "town" and game.town_panel.visible, "P2 must expose a dedicated dark-town world screen")
	_expect(game.district_enter_buttons[0].disabled == false, "starting district must be available at reputation 0")
	for i in [1, 2, 3]:
		_expect(game.district_enter_buttons[i].disabled, "higher districts must be visibly reputation-locked")

	game._enter_district(0)
	await _settle()
	_expect(game.current_stage == "market" and game.market_visits_remaining == Content.DAY_MARKET_VISITS - 1, "entering a district must consume one daily market visit")
	var first_district: Dictionary = Content.DISTRICTS[0]
	for listing in game.market_items:
		_expect(first_district["seller_ids"].has(str(listing["seller"]["id"])), "district market must only use sellers from that district")

	game._go_town()
	game.merchant_reputation = 100
	game._render_town()
	_expect(not game.district_enter_buttons[1].disabled and not game.district_enter_buttons[2].disabled, "reputation 100 must unlock tower and dock")
	_expect(game.district_enter_buttons[3].disabled, "grave district must remain locked below reputation 180")

	var visits_before = game.market_visits_remaining
	game._enter_district(1)
	await _settle()
	_expect(game.current_district_id == "tower" and game.market_visits_remaining == visits_before - 1, "switching to another district must consume another market visit")
	for listing in game.market_items:
		_expect(Content.DISTRICTS[1]["seller_ids"].has(str(listing["seller"]["id"])), "tower market must use tower sellers")

	game._go_town()
	var previous_day = game.merchant_day
	game.today_deals = 1
	game.daily_goal_progress = 1
	game.daily_goal_claimed = true
	game._end_day()
	await _settle()
	_expect(game.merchant_day == previous_day + 1 and game.current_stage == "town", "ending the day must advance the virtual day and return to town")
	_expect(game.market_visits_remaining == Content.DAY_MARKET_VISITS and game.market_items.is_empty(), "new day must restore the visit budget and clear yesterday's live market")
	_expect(game.daily_goal_progress == 0 and not game.daily_goal_claimed, "new day must reset the daily objective")
	_expect(not game.last_day_summary.is_empty() and int(game.last_day_summary["deals"]) == 1, "day close must preserve a summary of the finished day")
	_expect(game.town_event_text.text.contains("오늘의 소문") and game.town_event_text.text.contains("시장 영향"), "each day must expose both the rumor and its functional market effect")
	_expect(str(game.last_day_summary.get("event_title", "")).length() > 0, "day close must preserve the rumor that shaped that day")
	await _assert_layout("world and day session")


func _test_dynamic_market_events() -> void:
	game._reset_core_progress()
	game.game_started = true
	game.onboarding_complete = true
	game.merchant_reputation = 300
	game.merchant_day = 4
	game.day_event_id = "grave_festival"
	game.current_district_id = "grave"
	game.market_visits_remaining = Content.DAY_MARKET_VISITS
	game._create_new_market(true, false, false)
	await _settle()

	var event: Dictionary = game._day_event()
	_expect(game.market_info_label.text.contains(str(event["effect_text"])), "live market banner must explain today's functional rumor")
	var special_count = 0
	for listing in game.market_items:
		_expect(str(listing.get("market_event_id", "")) == "grave_festival", "every live listing must retain today's rumor identity")
		if bool(listing.get("event_special", false)):
			special_count += 1
			var public_data = game.feed.describe_listing(listing, true)
			_expect(str(public_data["tags_text"]).contains("소문 매물"), "rumor-special listing must be visibly labeled on the public feed")
			_expect(not str(public_data).contains(str(listing.get("archetype", ""))), "public rumor label must never reveal hidden jackpot/trap archetype")
	_expect(special_count <= 1, "one market batch may expose at most one rumor-special listing")

	# Force one known affected listing through the detail and resale presentation.
	var affected_index = -1
	for i in range(game.market_items.size()):
		if bool(game.market_items[i].get("event_affected", false)):
			affected_index = i
			break
	if affected_index >= 0:
		game._open_listing(affected_index)
		await _settle()
		_expect(game.detail_info.text.contains("오늘 소문") and game.detail_info.text.contains(str(event["effect_text"])), "affected listing detail must explain the current rumor effect")
		var probe_listing: Dictionary = game.market_items[affected_index].duplicate(true)
		var offers = game.engine.make_buyer_offers(probe_listing)
		var found_reason = false
		for offer in offers:
			if str(offer.get("reason", "")).contains("오늘 수요"):
				found_reason = true
		_expect(found_reason, "resale offers for rumor-affected goods must explain today's demand modifier")
		game._go_market()

	await _assert_layout("dynamic market event")


func _test_relationship_progression() -> void:
	game._reset_core_progress()
	game.game_started = true
	game.onboarding_complete = true
	game.gold = 500000
	game.current_district_id = "night_market"
	game.market_visits_remaining = Content.DAY_MARKET_VISITS
	game._create_new_market(true, false, false)
	await _settle()

	game._open_listing(0)
	var listing: Dictionary = game.market_items[0]
	var seller_id = str(listing["seller"]["id"])
	game._open_seller_chat()
	for i in range(4):
		game._investigate(i)
	await _settle()

	var relation: Dictionary = game._seller_relationship(seller_id)
	_expect(int(relation["points"]) == 4 and int(relation["chats"]) == 4, "four real seller questions must create four relationship points and chat memories")
	_expect(int(relation["story_step"]) >= 1 and int(relation["story_seen_step"]) >= 1, "relationship threshold 4 must unlock and deliver the first seller story beat")
	var saw_story = false
	for message in game.market_items[0].get("chat_history", []):
		if bool(message.get("story", false)):
			saw_story = true
			break
	_expect(saw_story, "unlocked seller story must appear inside the persistent seller chat")

	game._back_to_detail()
	var asking = int(game.market_items[0]["asking"])
	game._complete_purchase(asking)
	await _settle()
	relation = game._seller_relationship(seller_id)
	_expect(int(relation["points"]) == 8 and int(relation["purchases"]) == 1, "buying from a seller must add four relationship points and one purchase memory")
	_expect(str(relation["last_memory"]).contains("직거래"), "seller relationship must remember the most recent purchase")

	# Push the same real relationship to the final story threshold and verify
	# the promised relationship-only listing enters that seller's district.
	game._add_seller_relationship(seller_id, 16, 0, 0, "테스트용 관계 도달")
	relation = game._seller_relationship(seller_id)
	_expect(int(relation["story_step"]) == 3 and bool(relation["special_offer_ready"]), "relationship 24 must unlock the final story and a special listing")

	var district_index = game._district_index_for_seller(seller_id)
	_expect(district_index >= 0, "relationship seller must belong to a commercial district")
	game.current_district_id = str(Content.DISTRICTS[district_index]["id"])
	game._create_new_market(true, false, false)
	await _settle()
	var special_index = -1
	for i in range(game.market_items.size()):
		if bool(game.market_items[i].get("relationship_special", false)) and str(game.market_items[i].get("relationship_seller_id", "")) == seller_id:
			special_index = i
			break
	_expect(special_index >= 0, "final relationship story must inject the seller's relationship-only listing into their district market")

	if special_index >= 0:
		game._open_listing(special_index)
		game._complete_purchase(int(game.market_items[special_index]["asking"]))
		await _settle()
		relation = game._seller_relationship(seller_id)
		_expect(bool(relation["special_offer_claimed"]) and not bool(relation["special_offer_ready"]), "buying a relationship-only listing must consume that one-time offer")

	game._save_game()
	var expected_relation: Dictionary = game._seller_relationship(seller_id).duplicate(true)
	game.queue_free()
	await _settle()
	game = MainScene.instantiate()
	root.add_child(game)
	await _settle()
	var loaded_relation: Dictionary = game._seller_relationship(seller_id)
	for field in ["points", "chats", "purchases", "story_step", "story_seen_step", "special_offer_ready", "special_offer_claimed", "last_memory"]:
		_expect(str(loaded_relation.get(field, "")) == str(expected_relation.get(field, "")), "seller relationship field %s must survive save/load" % field)
	await _assert_layout("seller relationships")


func _test_collection_progression() -> void:
	game._reset_core_progress()
	game.game_started = true
	game.onboarding_complete = true
	game.gold = 100000
	game.merchant_reputation = 0

	var first_set: Dictionary = Content.COLLECTION_SETS[0]
	var first_ids: Array = first_set["item_ids"]
	var states = ["진품", "모조품", "결함품"]
	var rarities = ["고급", "희귀", "영웅"]
	var start_gold = game.gold
	for i in range(first_ids.size()):
		var item_id = str(first_ids[i])
		var listing = {
			"item_id":item_id,
			"state":states[i % states.size()],
			"rarity":rarities[i % rarities.size()]
		}
		game._record_collection_discovery(listing, "sale", (i + 1) * 1000, true)

	_expect(game._collection_discovered_count() == 3, "P5 must track distinct discovered item types")
	_expect(game._collection_discovered_states().size() == 3, "P5 must remember genuine imitation and defect discoveries")
	_expect(game._completed_collection_sets() == 1, "discovering all items in a theme must complete that collection set")
	_expect(bool(game.collection_goal_claimed.get("catalog_3", false)), "three discovered items must complete the first long-term catalog goal")
	_expect(bool(game.collection_goal_claimed.get("set_1", false)), "completing a theme set must complete the collection-set goal")
	_expect(game.gold == start_gold + 3500, "catalog_3 and set_1 rewards must grant exactly 3,500G once")
	_expect(game.merchant_reputation == 20, "catalog_3 and set_1 rewards must grant exactly 20 reputation once")
	for achievement_id in ["first_truth", "three_states", "one_set"]:
		_expect(game.achievement_unlocks.has(achievement_id), "collection achievement %s must unlock from real collection state" % achievement_id)

	var before_repeat_gold = game.gold
	game._record_collection_discovery({
		"item_id":str(first_ids[0]),
		"state":"진품",
		"rarity":"전설"
	}, "sale", 5000, true)
	_expect(game.gold == before_repeat_gold, "completed long-term collection rewards must never be paid twice")
	var repeated_record = game._collection_record(str(first_ids[0]))
	_expect(int(repeated_record["sales"]) == 2 and str(repeated_record["highest_rarity"]) == "전설", "repeat trades must update stats and highest rarity without duplicating discovery")

	game._go_collection()
	await _settle()
	_expect(game.current_stage == "collection" and game.collection_panel.visible, "town collection entry must open a dedicated collection screen")
	_expect(game.collection_item_list.item_count == Content.ITEMS.size(), "collection screen must list every content item slot")
	_expect(game.collection_completion_label.text.contains("3 / %d" % Content.ITEMS.size()), "collection screen must show actual catalog completion")
	_expect(game.collection_sets_text.text.contains(str(first_set["name"])) and game.collection_sets_text.text.contains("✓"), "completed theme set must be visible in the collection screen")
	_expect(game.collection_goals_text.text.contains("첫 수집 장부") and game.collection_achievements_text.text.contains("첫 정체 확인"), "long-term goals and achievements must be visible in collection UI")
	await _assert_layout("collection progression")

	game._save_game()
	var saved_records = JSON.parse_string(JSON.stringify(game.collection_records))
	var saved_goals = JSON.parse_string(JSON.stringify(game.collection_goal_claimed))
	var saved_achievements = JSON.parse_string(JSON.stringify(game.achievement_unlocks))
	game.queue_free()
	await _settle()
	game = MainScene.instantiate()
	root.add_child(game)
	await _settle()
	_expect(game.collection_records == saved_records, "collection records must survive save/load")
	_expect(game.collection_goal_claimed == saved_goals, "claimed collection goals must survive save/load")
	_expect(game.achievement_unlocks == saved_achievements, "achievement unlocks must survive save/load")


func _test_public_feed(cards) -> void:
	var presenter = load("res://scripts/home_feed.gd").new()
	var engine = MarketEngine.new(20260929)
	var market = engine.generate_market(3)
	game.market_items = market
	game.investigation_remaining = 4
	game.owned_items = []
	game.gold = 50000
	game.merchant_day = 1
	game.merchant_reputation = 0
	game.current_district_id = "night_market"
	game.market_visits_remaining = Content.DAY_MARKET_VISITS
	game.day_start_gold = game.gold
	game.last_day_summary = {}
	game.day_event_id = ""
	game.daily_goal_progress = 0
	game.daily_goal_claimed = false
	game.last_result_text = ""
	game.last_result_record = {}
	game.collection_records = {}
	game.collection_goal_claimed = {}
	game.achievement_unlocks = {}
	game.selected_collection_index = 0
	game._update_header()
	game._go_market()
	await _settle()
	await _capture("home-feed")
	var rendered_first = cards.get_child(0)
	var rendered_listing: Dictionary = game.market_items[0]
	var rendered_home_text = _visible_text(rendered_first)
	var art = load("res://scripts/art_catalog.gd")
	_expect(rendered_home_text.contains(art.item_name(rendered_listing)), "rendered home card must visibly show the item name")
	_expect(rendered_home_text.contains(art.seller_name(rendered_listing["seller"])), "rendered home card must visibly show the monster seller name")
	_expect(rendered_home_text.contains(game.feed.public_location_text(rendered_listing)), "rendered home card must visibly show the seller neighborhood")
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
	card["listing_story"] = "서랍 정리하다 나온 물건이라 올려요."
	card["discovered_clues"].append({"kind": "시세", "text": "조사 결과 비공개표식"})
	var public_data = presenter.describe_listing(card, true)
	_expect(str(public_data["tags_text"]).contains("가격 제안"), "public feed should communicate local price-offer trading without revealing seller archetype")
	_expect(not str(public_data).contains("급한 판매자"), "public feed must not reveal the hidden urgent seller archetype")
	_expect(public_data["clue_text"] == "서랍 정리하다 나온 물건이라 올려요.", "home card must read like the seller's post rather than a system clue")
	_expect(str(public_data["meta_text"]).contains(art.seller_name(card["seller"])) and str(public_data["meta_text"]).contains(presenter.public_location_text(card)), "home card must visibly identify the displayed monster seller and neighborhood")
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
	var listing = game.market_items[0]
	_expect(not pre_purchase_text.contains("[긍정적]") and not pre_purchase_text.contains("[부정적]") and not pre_purchase_text.contains("[애매한]"), "detail must show clue facts without polarity labels")
	_expect(not pre_purchase_text.contains(seller_type_name), "detail must show seller behavior cues without naming the archetype")
	_expect(game.detail_description.text.contains(game.feed.listing_story_text(listing)), "detail must present the seller-written listing story")
	_expect(game.detail_info.text.contains(game.feed.public_meetup_text(listing)), "detail must expose a concrete local meetup spot")
	_expect(game.seller_card_text.text.contains(game.feed.seller_profile_text(listing)), "detail seller card must show the monster seller's marketplace profile")
	_expect(game.seller_portrait.texture == load("res://scripts/art_catalog.gd").texture_for("sellers", str(listing["seller"]["id"])), "detail must show the seller portrait")
	var item_options = game.engine.investigation_options(game.market_items[0])
	_expect(not game.get_node("Margin/RootVBox/DetailPanel/Scroll/Box/ChatPanel").visible, "detail must not embed the interactive seller chat")
	_expect(game.open_seller_chat_button.visible, "detail must expose one clear seller-chat CTA")
	var price_plan_cta = game.get_node("Margin/RootVBox/DetailPanel/Scroll/Box/NegotiationJumpButton")
	_expect(price_plan_cta != null, "price planning CTA must remain on listing detail")
	game.open_seller_chat_button.pressed.emit()
	await _settle()
	_expect(game.current_stage == "chat", "seller-chat CTA must open a dedicated chat navigation state")
	_expect(game.seller_chat_panel.visible and not game.detail_panel.visible, "dedicated seller chat must replace detail rather than sit inside it")
	var displayed_seller = load("res://scripts/art_catalog.gd").seller_name(game.market_items[0]["seller"])
	_expect(game.chat_seller_name.text == displayed_seller and game.chat_seller_name.size.x > 0 and game.chat_seller_name.size.y >= 20, "chat header must visibly show the seller name")
	_expect(game.chat_seller_status.text == game.feed.seller_activity_text(game.market_items[0]) and game.chat_seller_status.size.y >= 15, "chat header must visibly show seller activity/status")
	for i in range(game.inspect_buttons.size()):
		if i < 4:
			_expect(game.inspect_buttons[i].text.contains(game.feed.investigation_button_text(item_options[i])), "dedicated chat reply choices must match the current item's message")
			_expect(game.inspect_buttons[i].text.begins_with("“"), "seller reply choices must read like messages rather than feature buttons")
		else:
			_expect(game.inspect_buttons[i].text.begins_with("직접 조사"), "market search must read as the player's own research action")
	var investigation_grid = game.get_node("Margin/RootVBox/SellerChatPanel/Root/Composer/ReplyGrid")
	_expect(investigation_grid.get_child_count() == 4 and investigation_grid.columns == 1, "seller chat replies must be a one-column message-choice list rather than a 2-column command grid")
	_expect(game.inspect_buttons[4].get_parent() == game.get_node("Margin/RootVBox/SellerChatPanel/Root/Composer"), "market search must be separated from seller reply choices")
	game.inspect_buttons[0].pressed.emit()
	_expect(game.investigation_remaining == 3, "A investigation must consume one shared opportunity")
	var chat_text = _visible_text(game.chat_messages)
	_expect(chat_text.contains("나") and chat_text.contains(load("res://scripts/art_catalog.gd").seller_name(game.market_items[0]["seller"])), "an investigation must append buyer and seller turns to the visible dedicated chat thread")
	_expect(chat_text.contains("사진에서 확인"), "photo inquiry must label its observation as '사진에서 확인' instead of a generic trade memo")
	_expect(game.market_items[0].get("chat_history", []).size() >= 3, "conversation turns must persist on the listing")
	var a_clues = game.market_items[0]["discovered_clues"].duplicate(true)
	game.get_node("Margin/RootVBox/SellerChatPanel/Root/BackToDetailButton").pressed.emit()
	await _settle()
	_expect(game.current_stage == "detail" and game.detail_panel.visible, "back from seller chat must return to the same listing detail")
	game.get_node("Margin/RootVBox/DetailPanel/Scroll/Box/BackMarketButton").pressed.emit()
	await _settle()
	_expect(_listing_ids() == ids, "back must keep all three listings")
	_expect(game.get_node("Margin/RootVBox/MarketPanel/Scroll").scroll_vertical == scroll, "back must restore the home feed position")
	cards.get_child(1).get_node("OpenButton").pressed.emit()
	await _settle()
	game.open_seller_chat_button.pressed.emit()
	await _settle()
	game.inspect_buttons[1].pressed.emit()
	_expect(game.investigation_remaining == 2, "B must use the same market investigation pool")
	game._go_market()
	await _settle()
	cards.get_child(0).get_node("OpenButton").pressed.emit()
	await _settle()
	_expect(game.market_items[0]["discovered_clues"] == a_clues, "A must keep previously discovered information")
	game.open_seller_chat_button.pressed.emit()
	await _settle()
	game.inspect_buttons[0].pressed.emit()
	_expect(game.investigation_remaining == 2, "repeated A investigation must not spend another opportunity")
	for clue in game.market_items[0]["discovered_clues"]:
		clue["text"] += " 非常に長い 설명 with long evidence ".repeat(12)
	game._back_to_detail()
	await _settle()
	game._render_detail()
	game.suspect_option.select(1)
	await _assert_layout("long detail and selected suspicion")
	await _assert_popup(game.suspect_option, "suspicion popup")
	game.open_seller_chat_button.pressed.emit()
	await _settle()
	await _assert_layout("dedicated seller chat")
	game._back_to_detail()
	await _settle()
	game.resale_option.select(2)
	game.max_buy_slider.value = game.max_buy_slider.min_value
	game.get_node("Margin/RootVBox/DetailPanel/Scroll/Box/StartDealButton").pressed.emit()
	await _settle()
	_expect(game.current_stage == "deal", "trade plan must still lead to negotiation")
	_expect(not game.get_node("Margin/RootVBox/Header").visible and not game.get_node("Margin/RootVBox/NavRow").visible, "negotiation must use its dedicated focus screen")
	_expect(game.deal_seller_price.text.contains("판매자가 올린 가격") and game.deal_max_buy.text.contains("내 최대 매입가") and game.deal_expected_resale.text.contains("예상 재판매가"), "price-offer screen must show seller listing price, purchase ceiling and resale estimate together")
	_expect(game.deal_personality.text.contains(game.feed.public_meetup_text(game.market_items[0])), "price-offer screen must keep the local direct-trade context visible")
	_expect(game.deal_personality.text.contains(game.feed.seller_activity_text(game.market_items[0])) and game.deal_personality.text.contains(game.feed.seller_message_text(game.market_items[0])), "price-offer screen must show observable seller activity and an actual message instead of an analysis label")
	_expect(game.seller_speech.text.contains("아직 있어요"), "first price-offer state must feel like a seller reply instead of a system prompt")
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
	_expect(game.deal_seller_price.text.contains("현재 판매자 가격") and not game.deal_seller_price.text.contains("판매자가 올린 가격"), "after a counter the screen must distinguish current seller price from the original listing price")
	var deal_text = _visible_text(game.get_node("Margin/RootVBox/DealPanel"))
	_expect(not deal_text.contains("[긍정적]") and not deal_text.contains("[부정적]") and not deal_text.contains("[애매한]"), "negotiation evidence must not expose clue polarity")
	game._go_market()
	await _settle()
	game._open_listing(0)
	_expect(game.resale_option.selected == 2, "saved resale estimate must survive home browsing")
	_expect(int(game.max_buy_slider.value) == int(game.market_items[0]["trade_plan"]["max_buy_price"]), "saved purchase ceiling must survive home browsing")
	_expect(int(game.market_items[0]["negotiation_state"]["rounds"]) == 1, "home browsing must not restore negotiation rounds")
	game.open_seller_chat_button.pressed.emit()
	await _settle()
	_expect(_visible_text(game.chat_messages).contains(load("res://scripts/art_catalog.gd").seller_name(game.market_items[0]["seller"])), "seller chat thread must survive browsing and reopen in the dedicated screen")
	game._investigate(2)
	game._investigate(3)
	var origin_chat = _visible_text(game.chat_messages)
	_expect(origin_chat.contains("이거 어디서 얻으셨어요?") and origin_chat.contains("대화하며 확인"), "origin investigation must appear as a buyer-seller exchange with an action-specific observation label")
	var saved_chat_count = game.market_items[0].get("chat_history", []).size()
	_expect(saved_chat_count >= 6, "multiple inquiries must accumulate rather than replace the previous conversation")
	game._go_market()
	await _settle()
	_expect(game.investigation_remaining == 0 and not game.next_market_button.disabled, "exhausting investigation must unlock the next market")
	game._request_next_market()
	await _settle()
	_expect(_listing_ids() != ids and game.investigation_remaining == 4, "next market must generate three new listings and restore the pool once")


func _test_trade_flow(cards) -> void:
	game.gold = 500000
	game.total_deals = 0
	game.today_deals = 0
	game.best_profit = 0
	game.worst_loss = 0
	game.merchant_reputation = 0
	game.daily_goal_progress = 0
	game.daily_goal_claimed = false
	cards.get_child(0).get_node("OpenButton").pressed.emit()
	game.resale_option.select(2)
	game._start_deal()
	var purchase_listing: Dictionary = game.market_items[0]
	var purchase_meetup = game.feed.public_meetup_text(purchase_listing)
	var purchase_seller = load("res://scripts/art_catalog.gd").seller_name(purchase_listing["seller"])
	var asking = int(purchase_listing["asking"])
	game._buy_current_price()
	await _settle()
	_expect(game.current_stage == "inventory" and game.owned_items.size() == 1, "purchase must enter inventory without forced appraisal")
	_expect(game.gold == 500000 - asking, "purchase must charge the actual agreed price")
	_expect(game.purchase_handoff_panel.visible, "a completed direct trade must show a purchase handoff panel")
	_expect(game.purchase_handoff_text.text.contains(purchase_seller) and game.purchase_handoff_text.text.contains(purchase_meetup), "purchase handoff must preserve who sold the item and where it was received")
	_expect(not game.inventory_list.visible, "single-item ownership must not show a large empty-looking inventory list")
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
	var info_listing: Dictionary = game.owned_items[0]["listing"]
	var inspection_cost = int(game.engine.post_inspection_options(info_listing)[0]["cost"])
	var appraisal_cost = int(game.engine.professional_appraisal_cost(info_listing))
	_expect(game.post_buttons[0].text.contains("%sG" % _money(inspection_cost)), "appraisal UI must display the same dynamic inspection cost the engine charges")
	_expect(game.professional_appraise_button.text.contains("%sG" % _money(appraisal_cost)), "appraisal UI must display the same dynamic professional appraisal cost the engine charges")
	game.post_buttons[0].pressed.emit()
	_expect(game.gold == gold_before - inspection_cost and int(game.owned_items[0]["inspection_remaining"]) == 1, "extra inspection must charge its dynamic fee and use its own budget")
	game.post_buttons[0].pressed.emit()
	_expect(game.gold == gold_before - inspection_cost, "repeat paid inspection must not charge twice")
	game.professional_appraise_button.pressed.emit()
	_expect(game.gold == gold_before - inspection_cost - appraisal_cost, "optional professional appraisal must charge its dynamic fee")
	_expect(int(game.owned_items[0]["appraisal_cost"]) == appraisal_cost, "owned item must persist the actual dynamic appraisal fee paid")
	_expect(not game.owned_items[0]["appraisal_data"].is_empty(), "appraisal must keep the existing hidden-state result")
	var appraised_item_id = str(game.owned_items[0]["listing"]["item_id"])
	var appraised_record = game._collection_record(appraised_item_id)
	_expect(bool(appraised_record["discovered"]) and int(appraised_record["appraisals"]) == 1, "professional appraisal must add the item's true identity to the collection")
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
	_expect(game.gold == 500000 - asking - inspection_cost - appraisal_cost + sale_price + 500, "first completed trade must include the 500G first-session objective reward exactly once")
	_expect(game.daily_goal_claimed and game.daily_goal_progress == 1, "first completed trade must complete the first-session objective")
	_expect(game.merchant_reputation > 0 and game.rank_label.text == game._merchant_rank(), "completed trade must award persistent merchant reputation")
	_expect(int(game.last_result_record.get("goal_gold", 0)) == 500 and int(game.last_result_record.get("reputation_gain", 0)) > 0, "trade record must preserve progression rewards")
	var record = game.last_result_text
	_expect(record.contains("실제 물건") and record.contains("거래 계획 복기"), "legacy completed record text must preserve judgment and hidden-state review")
	_expect(record.contains("판매자 복기") and record.contains("실제 성향:"), "legacy record text must reveal the seller archetype only in post-trade review")
	_expect(not game.last_result_record.is_empty(), "new transactions must persist a structured record payload")
	var sold_collection_record = game._collection_record(appraised_item_id)
	_expect(int(sold_collection_record["sales"]) == 1 and int(sold_collection_record["appraisals"]) == 1, "completed sale must update collection trade stats without duplicating the appraisal discovery")
	_expect(int(game.last_result_record["profit"]) == sale_price - asking - inspection_cost - appraisal_cost, "structured record must preserve the exact trade profit")
	_expect(game.record_hero.visible and game.record_money_panel.visible and game.record_truth_panel.visible, "completed trade must render structured record cards")
	_expect(game.record_item_name.text == str(game.last_result_record["item_name"]), "record hero must show the actual traded item")
	_expect(game.record_profit_label.text.contains(game._signed_money(int(game.last_result_record["profit"]))), "record hero must foreground net profit")
	var money_grid = game.get_node("Margin/RootVBox/ResultPanel/Scroll/Box/MoneyPanel/Grid")
	for child in money_grid.get_children():
		_expect(child.size.x >= 95.0 and child.size.y >= 20.0, "trade money summary columns must remain readable and never collapse vertically")
		_expect(child.autowrap_mode == TextServer.AUTOWRAP_OFF, "trade money summary labels must stay on one line")
	_expect(not game.legacy_result_summary.visible, "new structured transactions must not fall back to the old text dump")
	game.market_nav_button.pressed.emit()
	await _settle()
	game.records_nav_button.pressed.emit()
	await _settle()
	_expect(game.current_stage == "result" and game.result_summary.text == record, "records navigation must preserve the legacy text payload for compatibility")
	_expect(game.record_hero.visible and game.record_decision_text.text.length() > 0 and game.record_truth_text.text.contains("실제 가치"), "records navigation must reopen the structured review UI")
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
	legacy.erase("last_result_record")
	for field in ["game_started", "onboarding_complete", "merchant_day", "merchant_reputation", "daily_goal_progress", "daily_goal_claimed", "current_district_id", "market_visits_remaining", "day_start_gold", "last_day_summary", "day_event_id", "seller_relationships", "selected_relationship_seller_index", "collection_records", "collection_goal_claimed", "achievement_unlocks", "selected_collection_index"]:
		legacy.erase(field)
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
	_expect(game.game_started and game.onboarding_complete, "old v0.2.x saves must migrate as already-started games instead of forcing onboarding")
	_expect(game.merchant_day == 1 and game.merchant_reputation >= game.total_deals * 15, "old saves must receive safe commercial progression defaults")
	_expect(game.current_district_id == "night_market" and game.market_visits_remaining == Content.DAY_MARKET_VISITS, "old saves must migrate into the starting district with a full day visit budget")
	_expect(not game.collection_records.is_empty(), "old saves with a recent completed trade must seed the new collection from legacy result data")
	game._go_market()
	game.records_nav_button.pressed.emit()
	_expect(not game.last_result_record.is_empty(), "legacy saves without structured record data must be migrated from the old text record")
	_expect(game.record_hero.visible and not game.legacy_result_summary.visible, "migrated legacy records must use the new structured review UI")
	_expect(int(game.last_result_record.get("purchase_price", 0)) > 0 and str(game.last_result_record.get("item_name", "")).length() > 0, "legacy record migration must recover core trade values and item identity")
	await _assert_layout("migrated records")
	game.last_result_text = ""
	game.last_result_record = {}
	game.total_deals = 0
	game._go_records()
	_expect(game.legacy_result_summary.visible and game.legacy_result_summary.text.contains("아직 완료한 거래가 없습니다"), "empty records must explain the real entry point in the current record UI")
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


func _test_save_recovery() -> void:
	game.gold = 123456
	game.game_started = true
	game.onboarding_complete = true
	game._save_game()
	game._save_game()
	_expect(FileAccess.file_exists(game.SAVE_BACKUP_PATH), "atomic save flow must keep a previous known-good backup")

	var corrupt = FileAccess.open(game.SAVE_PATH, FileAccess.WRITE)
	_expect(corrupt != null, "test must be able to corrupt the primary save fixture")
	if corrupt != null:
		corrupt.store_string("{broken save")
		corrupt.close()

	game.queue_free()
	await _settle()
	game = MainScene.instantiate()
	root.add_child(game)
	await _settle()
	_expect(game.gold == 123456, "corrupted primary save must automatically recover the previous good backup")
	_expect(game.save_recovery_notice, "backup recovery must leave a player-facing recovery notice pending")
	var repaired = game._read_save_dictionary(game.SAVE_PATH)
	_expect(not repaired.is_empty() and int(repaired.get("gold", 0)) == 123456, "backup recovery must repair the primary save with valid data")


func _finish() -> void:
	game.queue_free()
	await _settle()
	if errors.is_empty():
		print("HOME FEED SMOKE OK v0.2.12: %d checks; privacy, A/home/B/home/A, resource gates, inventory/appraisal/quotes/resale, saves and 390x844 layout" % checks)
		quit(0)
	else:
		for message in errors:
			push_error("HOME FEED SMOKE FAILED: %s" % message)
		quit(1)
