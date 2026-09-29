extends SceneTree

const MarketEngine = preload("res://scripts/game_logic.gd")


func _init() -> void:
	var engine = MarketEngine.new(20260929)
	var errors = engine.validate_content()
	if not errors.is_empty():
		_fail("content validation failed: %s" % str(errors))
		return

	var summary = engine.content_summary()
	if int(summary["items"]) != 12:
		_fail("expected 12 items, got %s" % str(summary["items"]))
		return
	if int(summary["seller_types"]) != 5:
		_fail("expected 5 seller types, got %s" % str(summary["seller_types"]))
		return
	if int(summary["sellers"]) != 8:
		_fail("expected 8 sellers, got %s" % str(summary["sellers"]))
		return
	if int(summary["buyers"]) != 5:
		_fail("expected 5 buyers, got %s" % str(summary["buyers"]))
		return
	if int(summary["clues"]) < 25:
		_fail("expected at least 25 clues, got %s" % str(summary["clues"]))
		return

	var signatures = {}
	var seen_states = {}
	var seen_archetypes = {}
	var seen_seller_types = {}

	for market_index in range(20):
		var market = engine.generate_market(3)
		if market.size() != 3:
			_fail("market %d did not contain 3 listings" % market_index)
			return

		var ids = {}
		for listing in market:
			var item_id = str(listing["item_id"])
			if ids.has(item_id):
				_fail("market %d contained duplicate item ids" % market_index)
				return
			ids[item_id] = true

			var before_value = int(listing["actual_value"])
			var appraisal = engine.appraise(listing)
			if int(appraisal["value"]) != before_value:
				_fail("appraisal rerolled hidden value")
				return

			var offers = engine.make_buyer_offers(listing)
			if offers.size() != 3:
				_fail("buyer offers did not contain 3 choices")
				return

			var negotiation = engine.start_negotiation(listing)
			for _round in range(3):
				if bool(negotiation.get("closed", false)):
					break
				var bargain = engine.negotiate(listing, negotiation, "soft")
				negotiation = bargain["state"]
			if int(negotiation["rounds"]) > 3:
				_fail("negotiation exceeded 3 rounds")
				return

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

	print("SMOKE OK: 20 markets / 60 listings, %d unique signatures, %d states, %d archetypes, %d seller types" % [
		signatures.size(),
		seen_states.size(),
		seen_archetypes.size(),
		seen_seller_types.size()
	])
	quit(0)


func _fail(message: String) -> void:
	push_error("SMOKE FAILED: %s" % message)
	quit(1)
