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
	for item in Content.ITEMS:
		var probe = engine.generate_listing(item)
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
	if investigation_profile_signatures.size() < 10:
		_fail("item investigation profiles are not distinct enough")
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

	print("SMOKE OK v0.2.12: 12 item-specific investigation profiles, 20 markets / 60 listings, trade plans, clue-based negotiation and 3-of-4 resale discovery")
	quit(0)


func _fail(message: String) -> void:
	push_error("SMOKE FAILED: %s" % message)
	quit(1)
