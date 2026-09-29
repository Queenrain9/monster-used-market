extends SceneTree

const MarketEngine = preload("res://scripts/game_logic.gd")
const Content = preload("res://data/content.gd")


func _init() -> void:
	var engine = MarketEngine.new(20260929)
	var errors = engine.validate_content()
	if not errors.is_empty():
		_fail("content validation failed: %s" % str(errors))
		return

	var signatures = {}
	var trade_plan_checks = 0
	var quote_checks = 0
	var investigation_profile_signatures = {}
	var profile_usage = {}

	# Information economy must scale from known purchase price, not hidden truth.
	var low_info_listing = engine.generate_listing(Content.ITEMS[0])
	low_info_listing["purchase_price"] = 1500
	var low_inspection = engine.post_inspection_options(low_info_listing)
	if [int(low_inspection[0]["cost"]), int(low_inspection[1]["cost"]), int(low_inspection[2]["cost"])] != [100, 150, 200]:
		_fail("low-price information floors changed unexpectedly")
		return
	if engine.professional_appraisal_cost(low_info_listing) != 300:
		_fail("low-price professional appraisal floor must be 300G")
		return

	var high_info_listing = low_info_listing.duplicate(true)
	high_info_listing["purchase_price"] = 20000
	var high_inspection = engine.post_inspection_options(high_info_listing)
	if [int(high_inspection[0]["cost"]), int(high_inspection[1]["cost"]), int(high_inspection[2]["cost"])] != [400, 600, 800]:
		_fail("20k purchase must scale inspection costs to 400/600/800G")
		return
	if engine.professional_appraisal_cost(high_info_listing) != 1500:
		_fail("20k purchase must scale professional appraisal to 1500G")
		return

	var hidden_changed = high_info_listing.duplicate(true)
	hidden_changed["actual_value"] = 999999
	hidden_changed["state"] = "모조품"
	hidden_changed["rarity"] = "전설"
	if engine.post_inspection_options(hidden_changed) != high_inspection or engine.professional_appraisal_cost(hidden_changed) != 1500:
		_fail("information price must not leak hidden actual value, authenticity or rarity")
		return

	for item in Content.ITEMS:
		var profile_id = str(item.get("investigation_profile", ""))
		profile_usage[profile_id] = int(profile_usage.get(profile_id, 0)) + 1
	var shared_profile_found = false
	for count in profile_usage.values():
		if int(count) >= 2:
			shared_profile_found = true
			break
	if not shared_profile_found:
		_fail("investigation profiles are still one-profile-per-item instead of reusable")
		return

	# A brand-new item that is not registered in Content.ITEMS must still work
	# by declaring only a reusable profile and normal item economy fields.
	var synthetic_item = {
		"id":"test_clockwork_box",
		"name":"테스트 태엽 상자",
		"category":"잡화",
		"tags":["기계","수집"],
		"base_value":10000,
		"rarity_weights":{"일반":1.0},
		"state_weights":{"진품":1.0},
		"investigation_profile":"mechanical"
	}
	var synthetic_listing = engine.generate_listing(synthetic_item)
	var synthetic_options = engine.investigation_options(synthetic_listing)
	if synthetic_options.size() != 5 or str(synthetic_options[2]["short_label"]) != "작동 상태":
		_fail("new item could not inherit the mechanical investigation profile")
		return
	var synthetic_check = engine.investigate(synthetic_listing, "function")
	if not bool(synthetic_check["consumed"]):
		_fail("new profile-only item could not run its inherited investigation")
		return

	# Optional one-action override must not require copying the whole profile.
	var overridden_item = synthetic_item.duplicate(true)
	overridden_item["id"] = "test_music_box"
	overridden_item["investigation_overrides"] = {
		"function":{"short_label":"멜로디 역재생","label":"태엽을 감아 멜로디가 거꾸로 흐르는지 듣는다"}
	}
	var overridden_listing = engine.generate_listing(overridden_item)
	var overridden_options = engine.investigation_options(overridden_listing)
	if str(overridden_options[2]["short_label"]) != "멜로디 역재생" or str(overridden_options[0]["short_label"]) != "외장 마모":
		_fail("single-action investigation override did not inherit the rest of the profile")
		return

	var saw_profile_clue = false
	for i in range(20):
		var sample_clue = engine._pick_clue_for_item(synthetic_item, "genuine", true)
		if str(sample_clue.get("id", "")).begins_with("mec_"):
			saw_profile_clue = true
			break
	if not saw_profile_clue:
		_fail("profile-specific clue layer was never selected for a profile-only item")
		return
	for item in Content.ITEMS:
		var probe = engine.generate_listing(item)
		var stories: Array = item.get("market_stories", [])
		if stories.is_empty() or not stories.has(str(probe.get("listing_story", ""))):
			_fail("%s generated listing did not persist one of its seller stories" % item["id"])
			return
		var seller_meta: Dictionary = probe.get("seller", {})
		for field in ["neighborhood", "meetup", "profile"]:
			if str(seller_meta.get(field, "")).strip_edges().is_empty():
				_fail("generated seller is missing local marketplace field %s" % field)
				return
		var options = engine.investigation_options(probe)
		if options.size() != 5:
			_fail("%s must expose exactly five investigation choices" % item["id"])
			return
		var stable_ids = []
		var labels = []
		for option in options:
			stable_ids.append(str(option["id"]))
			labels.append(str(option.get("short_label", "")))
		if stable_ids != ["exterior", "mark", "function", "origin", "market"]:
			_fail("%s investigation IDs changed and would break older saves" % item["id"])
			return
		investigation_profile_signatures["|".join(labels)] = true

		var semantic_probe = engine.generate_listing(item)
		for action_id in ["exterior", "mark", "function", "origin"]:
			var semantic_result = engine.investigate(semantic_probe, action_id)
			if not bool(semantic_result["consumed"]):
				_fail("%s semantic investigation %s did not consume" % [item["id"], action_id])
				return
			semantic_probe = semantic_result["listing"]
			var discovered: Array = semantic_probe.get("discovered_clues", [])
			var latest: Dictionary = discovered[discovered.size() - 1]
			if not str(latest.get("id", "")).begins_with("action_%s_" % action_id):
				_fail("%s investigation returned a clue from the wrong semantic channel: %s" % [action_id, latest.get("id", "")])
				return

	if investigation_profile_signatures.size() < 8:
		_fail("item investigation overrides do not create enough visible variety")
		return

	for market_index in range(20):
		var market = engine.generate_market(3)
		if market.size() != 3:
			_fail("market did not contain 3 listings")
			return

		var ids = {}
		for listing in market:
			if ids.has(listing["item_id"]):
				_fail("duplicate item in market")
				return
			ids[listing["item_id"]] = true

			var item_options = engine.investigation_options(listing)
			var first_action = str(item_options[0]["id"])
			var before_clues = listing.get("discovered_clues", []).size()
			var investigation = engine.investigate(listing, first_action)
			if not bool(investigation["consumed"]):
				_fail("item-specific investigation did not consume")
				return
			if str(investigation.get("action_label", "")).is_empty():
				_fail("item-specific investigation did not report its action label")
				return
			listing = investigation["listing"]
			if listing.get("discovered_clues", []).size() <= before_clues:
				_fail("item-specific investigation did not reveal a clue")
				return
			var repeated = engine.investigate(listing, first_action)
			if bool(repeated["consumed"]):
				_fail("repeating the same item-specific investigation spent another opportunity")
				return

			listing = engine.save_trade_plan(listing, "5,000~15,000G", max(1000, int(listing["asking"]) - 500), "")
			if not engine.trade_plan_complete(listing):
				_fail("trade plan incomplete")
				return
			var plan_feedback = engine.evaluate_trade_plan(listing, int(listing["asking"]), 9000)
			if plan_feedback.is_empty():
				_fail("trade plan feedback missing")
				return
			trade_plan_checks += 1

			var negotiation = engine.start_negotiation(listing)
			var bargain = engine.negotiate_offer(listing, negotiation, int(round(float(listing["asking"]) * 0.9)), -1)
			negotiation = bargain["state"]
			if int(negotiation["rounds"]) > 3:
				_fail("negotiation exceeded rounds")
				return

			var before_value = int(listing["actual_value"])
			var appraisal = engine.appraise(listing)
			if int(appraisal["value"]) != before_value:
				_fail("appraisal rerolled value")
				return
			if not appraisal.has("magic_grade") or not appraisal.has("curse_grade") or not appraisal.has("value_low") or not appraisal.has("value_high"):
				_fail("appraisal result UI fields are missing")
				return

			var offers = engine.make_buyer_offers(listing)
			if offers.size() != 4:
				_fail("expected 3 specialists + scrap buyer")
				return
			var scrap_count = 0
			var hidden_specialists = 0
			for offer in offers:
				if offer["buyer_id"] == "scrap":
					scrap_count += 1
					if not bool(offer["revealed"]):
						_fail("scrap price should be visible")
						return
				elif not bool(offer["revealed"]):
					hidden_specialists += 1
			if scrap_count != 1 or hidden_specialists != 3:
				_fail("buyer discovery structure incorrect")
				return

			var old_price = int(offers[0]["price"])
			var revealed = engine.reveal_quote(offers, 0)
			if int(revealed[0]["price"]) != old_price or not bool(revealed[0]["revealed"]):
				_fail("quote reveal rerolled price")
				return
			quote_checks += 1

			var signature = "%s|%s|%s|%s|%s" % [
				listing["item_id"], listing["state"], listing["rarity"], listing["seller"]["type"], listing["asking"]
			]
			signatures[signature] = true

	if signatures.size() < 24:
		_fail("not enough listing variety")
		return
	if trade_plan_checks != 60 or quote_checks != 60:
		_fail("core flow not fully exercised")
		return

	var evidence_listing = engine.generate_listing(Content.ITEMS[0])
	evidence_listing["asking"] = 10000
	evidence_listing["seller"]["type"] = "urgent"
	evidence_listing["seller"]["personality"] = Content.SELLER_TYPES["urgent"].duplicate(true)
	evidence_listing["discovered_clues"] = [{"kind": "부정적", "text": "균열 흔적", "aligned": true}]
	var without_evidence = engine.negotiate_offer(evidence_listing, engine.start_negotiation(evidence_listing), 5600, -1)
	var with_evidence = engine.negotiate_offer(evidence_listing, engine.start_negotiation(evidence_listing), 5600, 0)
	if bool(without_evidence["accepted"]) or not bool(with_evidence["accepted"]) or with_evidence["state"]["evidence_used"] != ["균열 흔적"]:
		_fail("aligned discovered evidence no longer changes the negotiation outcome")
		return

	print("SMOKE OK v0.2.19: dedicated seller chat, coherent inquiries, purchase handoff and full trade flow")
	quit(0)


func _fail(message: String) -> void:
	push_error("SMOKE FAILED: %s" % message)
	quit(1)
