extends RefCounted

# The feed is a public projection, never an appraisal or a recommendation.
const Art = preload("res://scripts/art_catalog.gd")
const Content = preload("res://data/content.gd")


func describe_listing(listing: Dictionary, featured: bool = false) -> Dictionary:
	var seller: Dictionary = listing.get("seller", {})
	var personality: Dictionary = seller.get("personality", {})
	var status = str(listing.get("listing_status", "미확인"))
	var available = status not in ["구매 완료", "판매 완료"]
	var viewed = bool(listing.get("viewed", false)) or not listing.get("inspected_actions", []).is_empty()
	var tags: Array = []
	if str(seller.get("type", "")) == "urgent":
		tags.append("급처")
	elif float(personality.get("discount_receptiveness", 0.0)) >= 0.6:
		tags.append("흥정 여지 있음")
	elif str(seller.get("type", "")) == "expert":
		tags.append("시세에 밝음")
	elif str(seller.get("type", "")) == "greedy":
		tags.append("가격 고수")
	else:
		tags.append("설명 적극적")

	if not available:
		tags.append(status)
	elif status == "거래 중":
		tags.append("거래 중")
	elif viewed:
		tags.append("확인한 매물")
	else:
		tags.append("거래 가능")

	return {
		"name": Art.item_name(listing),
		"item_art_id": str(listing.get("item_id", "")),
		"seller_art_id": str(seller.get("id", "")),
		"price_text": "%sG" % _money(int(listing.get("asking", 0))),
		"seller_text": "판매자: %s" % Art.seller_name(seller),
		"tags_text": " · ".join(tags),
		"clue_text": str(listing.get("initial_clue", {}).get("text", "")),
		"feature_text": "특별 매물" if featured and available else "",
		"action_text": ("다시 보기 ›" if viewed else "보기 ›") if available else "거래 완료",
		"available": available
	}


func matches_filter(listing: Dictionary, query: String, tab_id: String, category_id: String) -> bool:
	var seller: Dictionary = listing.get("seller", {})
	var personality: Dictionary = seller.get("personality", {})
	var viewed = bool(listing.get("viewed", false)) or not listing.get("inspected_actions", []).is_empty()
	var q = query.strip_edges().to_lower()

	if not q.is_empty():
		var haystack = "%s %s %s" % [
			Art.item_name(listing),
			Art.seller_name(seller),
			str(listing.get("category", ""))
		]
		if not haystack.to_lower().contains(q):
			return false

	if tab_id == "negotiable":
		if str(seller.get("type", "")) != "urgent" and float(personality.get("discount_receptiveness", 0.0)) < 0.6:
			return false
	elif tab_id == "viewed":
		if not viewed:
			return false
	elif tab_id == "category":
		if category_id != "전체" and category_group(str(listing.get("category", ""))) != category_id:
			return false

	return true


func category_group(raw_category: String) -> String:
	if raw_category in ["장신구", "보석"]:
		return "장신구"
	if raw_category in ["재료", "연금재료"]:
		return "재료"
	if raw_category == "유물":
		return "유물"
	if raw_category == "마도구":
		return "마도구"
	if raw_category == "잡화":
		return "잡화"
	return "기타"


func public_age_text(listing: Dictionary) -> String:
	var fingerprint = abs(int(str(listing.get("listing_id", "")).hash()))
	var minutes = 2 + fingerprint % 58
	return "%d분 전" % minutes


func public_location_text(_listing: Dictionary) -> String:
	return "어둠마을 야시장"


func choose_featured_index(market: Array) -> int:
	if market.is_empty():
		return -1
	# Listing IDs already persist. A deterministic choice does not reroll on back,
	# consume the game's RNG, or alter hidden values / prices / future markets.
	var fingerprint = int(str(market[0].get("listing_id", "")).hash())
	if fingerprint % 3 != 0:
		return -1
	var candidates: Array = []
	for i in range(market.size()):
		# All existing archetypes have identical eligibility and public appearance.
		# In particular, jackpot and trap cannot be distinguished by this badge.
		if Content.ARCHETYPES.has(str(market[i].get("archetype", ""))):
			candidates.append(i)
	if candidates.is_empty():
		return -1
	return int(candidates[int(fingerprint / 3.0) % candidates.size()])


func _money(value: int) -> String:
	var source = str(abs(value))
	var result = ""
	while source.length() > 3:
		result = "," + source.right(3) + result
		source = source.left(source.length() - 3)
	return ("-" if value < 0 else "") + source + result
