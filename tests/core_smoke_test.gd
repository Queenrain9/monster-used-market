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
	var seen_states = {}
	var seen_archetypes = {}
	var seen_seller_types = {}
	var negotiated_with_evidence = 0
	var quote_checks = 0

	for market_index in range(20):
		var market = engine.generate_market(3)
		if market.size() != 3:
			_fail("market %d did not contain 3 listings" % market_index)
			return

		var ids = {}
		var shared_budget = Content.MARKET_INVESTIGATION_BUDGET

		for listing_index in range(market.size()):
			var listing: Dictionary = market[listing_index]
			var item_id = str(listing["item_id"])
			if ids.has(item_id):
				_fail("market %d contained duplicate item ids" % market_index)
				return
			ids[item_id] = true

			if listing["discovered_clues"].size() != 2:
				_fail("listing should begin with exactly visible clue + seller claim")
				return
			if str(listing["listing_status"]) != "미확인":
				_fail("new listing status should be 미확인")
				return

			if shared_budget > 0:
				var options = engine.investigation_options(listing)
				if options.size() < 5:
					_fail("expected at least 5 investigation choices")
					return
				var investigation = engine.investigate(listing, str(options[0]["id"]))
				if not bool(investigation["consumed"]):
					_fail("first investigation should consume a shared opportunity")
					return
				listing = investigation["listing"]
				shared_budget -= 1
				if listing["discovered_clues"].size() < 3:
					_fail("investigation did not reveal new information")
					return

			listing = engine.save_hypothesis(listing, "애매함", "결함 의심", "5,000~15,000G")
			if not engine.hypothesis_complete(listing):
				_fail("hypothesis was not stored")
				return

			var negotiation = engine.start_negotiation(listing)
			var evidence = engine.negotiation_evidence_options(listing)
			var clue_index = -1
			if evidence.size() > 0:
				clue_index = int(evidence[0]["clue_index"])
				negotiated_with_evidence += 1

			for _round in range(3):
				if bool(negotiation.get("closed", false)):
					break
				var current_price = int(negotiation["current_price"])
				var offer = int(round(float(current_price) * 0.90))
				var bargain = engine.negotiate_offer(listing, negotiation, offer, clue_index)
				negotiation = bargain["state"]

			if int(negotiation["rounds"]) > 3:
				_fail("negotiation exceeded 3 rounds")
				return

			var post_options = engine.post_inspection_options(listing)
			if post_options.size() != 3:
				_fail("post purchase inspection options should be 3")
				return
			var post_result = engine.run_post_inspection(listing, str(post_options[0]["id"]))
			if not bool(post_result["consumed"]):
				_fail("post inspection should consume once")
				return
			listing = post_result["listing"]

			var before_value = int(listing["actual_value"])
			var appraisal = engine.appraise(listing)
			if int(appraisal["value"]) != before_value:
				_fail("appraisal rerolled hidden value")
				return

			var offers = engine.make_buyer_offers(listing)
			if offers.size() != 3:
				_fail("buyer offers did not contain 3 choices")
				return
			var scrap_count = 0
			var hidden_specialists = 0
			for offer in offers:
				if offer["buyer_id"] == "scrap":
					scrap_count += 1
					if not bool(offer["revealed"]):
						_fail("scrap offer must be immediately visible")
						return
				elif not bool(offer["revealed"]):
					hidden_specialists += 1
			if scrap_count != 1 or hidden_specialists != 2:
				_fail("sale discovery should start with 2 hidden specialists + 1 visible scrap dealer")
				return

			var old_price = int(offers[0]["price"])
			var revealed = engine.reveal_quote(offers, 0)
			if int(revealed[0]["price"]) != old_price or not bool(revealed[0]["revealed"]):
				_fail("quote reveal changed the pre-generated offer")
				return
			quote_checks += 1

			seen_states[str(listing["state"])] = true
			seen_archetypes[str(listing["archetype"])] = true
			seen_seller_types[str(listing["seller"]["type"])] = true
			var signature = "%s|%s|%s|%s|%s|%s" % [
				listing["item_id"],
				listing["state"],
				listing["rarity"],
				listing["condition"],
				listing["seller"]["type"],
				listing["asking"]
			]
			signatures[signature] = true

	if signatures.size() < 24:
		_fail("20 markets produced too little listing variety: %d signatures" % signatures.size())
		return
	if seen_states.size() < 2:
		_fail("listing generation did not vary hidden states")
		return
	if seen_archetypes.size() < 3:
		_fail("listing generation did not vary risk archetypes")
		return
	if seen_seller_types.size() < 3:
		_fail("listing generation did not vary seller personalities")
		return
	if negotiated_with_evidence <= 0:
		_fail("no evidence-backed negotiation was exercised")
		return
	if quote_checks <= 0:
		_fail("quote reveal was not exercised")
		return

	print("SMOKE OK v0.2.1: 20 markets / 60 listings, shared investigation, hypotheses, price negotiation, post inspections and limited quote flow")
	quit(0)


func _fail(message: String) -> void:
	push_error("SMOKE FAILED: %s" % message)
	quit(1)
