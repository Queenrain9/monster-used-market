extends SceneTree

const MarketEngine = preload("res://scripts/game_logic.gd")
const Content = preload("res://data/content.gd")

var failures: Array = []


func _init() -> void:
	var engine = MarketEngine.new(1082401)
	var states = {"진품":0, "모조품":0, "결함품":0}
	var archetypes = {"stable":0, "ambiguous":0, "risky":0, "jackpot":0, "trap":0}
	var rarities = {}
	var total = 0
	var profitable_before_info = 0
	var asking_ratio_sum = 0.0
	var best_resale_ratio_sum = 0.0
	var archetype_ratio_sum = {"stable":0.0,"ambiguous":0.0,"risky":0.0,"jackpot":0.0,"trap":0.0}

	for item in Content.ITEMS:
		for sample_index in range(40):
			var listing = engine.generate_listing(item)
			total += 1
			var state = str(listing.get("state", ""))
			var archetype = str(listing.get("archetype", ""))
			var rarity = str(listing.get("rarity", ""))
			states[state] = int(states.get(state, 0)) + 1
			archetypes[archetype] = int(archetypes.get(archetype, 0)) + 1
			rarities[rarity] = int(rarities.get(rarity, 0)) + 1

			var actual = int(listing.get("actual_value", 0))
			var asking = int(listing.get("asking", 0))
			if actual <= 0 or asking <= 0:
				_fail("non-positive market value generated for %s" % item.get("id", ""))
				return
			var asking_ratio = float(asking) / float(actual)
			if asking_ratio < 0.15 or asking_ratio > 2.60:
				_fail("asking/value ratio escaped commercial guardrail: %.3f for %s" % [asking_ratio, item.get("id", "")])
				return
			asking_ratio_sum += asking_ratio
			archetype_ratio_sum[archetype] = float(archetype_ratio_sum.get(archetype, 0.0)) + asking_ratio

			var offers = engine.make_buyer_offers(listing)
			if offers.size() != 4:
				_fail("buyer market must always expose 3 specialists + scrap")
				return
			for offer in offers:
				if int(offer.get("price", 0)) <= 0:
					_fail("buyer offer became non-positive")
					return
			var best_resale = engine.best_offer_price(offers)
			best_resale_ratio_sum += float(best_resale) / float(actual)
			if best_resale > asking:
				profitable_before_info += 1

	if total != Content.ITEMS.size() * 40:
		_fail("long-run sample count mismatch")
		return

	for key in states:
		if int(states[key]) < 60:
			_fail("hidden state collapsed in long-run sample: %s=%d" % [key, states[key]])
			return
	for key in archetypes:
		if int(archetypes[key]) < 45:
			_fail("market archetype collapsed in long-run sample: %s=%d" % [key, archetypes[key]])
			return
	for rarity in ["일반","고급","희귀","영웅","전설"]:
		if int(rarities.get(rarity, 0)) <= 0:
			_fail("rarity never appeared in commercial long-run sample: %s" % rarity)
			return

	var opportunity_rate = float(profitable_before_info) / float(total)
	if opportunity_rate < 0.25 or opportunity_rate > 0.95:
		_fail("raw profitable-opportunity rate is commercially degenerate: %.3f" % opportunity_rate)
		return

	var stable_ratio = float(archetype_ratio_sum["stable"]) / float(archetypes["stable"])
	var jackpot_ratio = float(archetype_ratio_sum["jackpot"]) / float(archetypes["jackpot"])
	var trap_ratio = float(archetype_ratio_sum["trap"]) / float(archetypes["trap"])
	if jackpot_ratio >= stable_ratio * 0.88:
		_fail("jackpot listings are no longer meaningfully cheaper than stable listings: %.2f vs %.2f" % [jackpot_ratio, stable_ratio])
		return
	if trap_ratio <= stable_ratio * 1.18:
		_fail("trap listings are no longer meaningfully more expensive than stable listings: %.2f vs %.2f" % [trap_ratio, stable_ratio])
		return

	# Each district needs enough repeated content variety that a player does not
	# feel like the same three posts are cycling forever.
	for district in Content.DISTRICTS:
		var district_id = str(district.get("id", ""))
		var seen = {}
		for visit in range(20):
			for listing in engine.generate_market_for_district(district_id, 3):
				seen[str(listing.get("item_id", ""))] = true
				if not district.get("seller_ids", []).has(str(listing.get("seller", {}).get("id", ""))):
					_fail("%s leaked a seller outside its district during long-run simulation" % district_id)
					return
		if seen.size() < 8:
			_fail("%s has too little item variety across repeated visits: %d" % [district_id, seen.size()])
			return

	# Every rumor must have a real content supply to affect.
	for event in Content.DAY_EVENTS:
		var compatible = 0
		var affected_tags: Array = event.get("affected_tags", [])
		for item in Content.ITEMS:
			for tag in item.get("tags", []):
				if affected_tags.has(str(tag)):
					compatible += 1
					break
		if compatible < 3:
			_fail("day event has too little compatible supply: %s (%d items)" % [event.get("id", ""), compatible])
			return

	# Upgrade ladders must progress monotonically, otherwise a later tier can
	# become cheaper/easier than the previous tier.
	for upgrade in Content.UPGRADES:
		var previous_cost = 0
		var previous_reputation = 0
		for level in upgrade.get("levels", []):
			var cost = int(level.get("cost", 0))
			var reputation = int(level.get("reputation", 0))
			if cost <= previous_cost or reputation < previous_reputation:
				_fail("upgrade ladder is not monotonic: %s" % upgrade.get("id", ""))
				return
			previous_cost = cost
			previous_reputation = reputation

	var avg_asking_ratio = asking_ratio_sum / float(total)
	var avg_best_resale_ratio = best_resale_ratio_sum / float(total)
	print("RELEASE BALANCE OK: %d listings | opportunity %.1f%% | avg ask/value %.2f | avg best resale/value %.2f | states %s | archetypes %s" % [
		total,
		opportunity_rate * 100.0,
		avg_asking_ratio,
		avg_best_resale_ratio,
		str(states),
		str(archetypes)
	])
	print("ARCHETYPE ECONOMY OK: jackpot %.2f < stable %.2f < trap %.2f ask/value" % [jackpot_ratio, stable_ratio, trap_ratio])
	quit(0)


func _fail(message: String) -> void:
	push_error("RELEASE BALANCE FAILED: %s" % message)
	quit(1)
