extends RefCounted

# The feed is a public projection, never an appraisal or a recommendation.
const Art = preload("res://scripts/art_catalog.gd")
const Content = preload("res://data/content.gd")


func describe_listing(listing: Dictionary, featured: bool = false) -> Dictionary:
	var seller: Dictionary = listing.get("seller", {})
	var status = str(listing.get("listing_status", "미확인"))
	var available = status not in ["구매 완료", "판매 완료"]
	var viewed = bool(listing.get("viewed", false)) or not listing.get("inspected_actions", []).is_empty()
	var tags: Array = []
	tags.append("가격 제안")

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
		"seller_short_text": Art.seller_name(seller),
		"meta_text": "%s · %s · %s" % [Art.seller_name(seller), public_location_text(listing), public_age_text(listing)],
		"tags_text": " · ".join(tags),
		"clue_text": listing_story_text(listing),
		"feature_text": "동네 인기 매물" if featured and available else "",
		"action_text": ("다시 보기 ›" if viewed else "글 보기 ›") if available else "거래 완료",
		"available": available
	}


func seller_behavior_text(listing: Dictionary) -> String:
	var seller: Dictionary = listing.get("seller", {})
	var personality: Dictionary = seller.get("personality", {})
	var cues: Array = personality.get("public_cues", [])
	var seller_type = str(seller.get("type", ""))
	if cues.is_empty() and Content.SELLER_TYPES.has(seller_type):
		cues = Content.SELLER_TYPES[seller_type].get("public_cues", [])
	if cues.is_empty():
		return "대화만으로는 어떤 성향인지 단정하기 어렵다."
	var fingerprint = abs(int(("%s_%s" % [listing.get("listing_id", ""), seller.get("id", "")]).hash()))
	return str(cues[fingerprint % cues.size()])


func investigation_button_text(option: Dictionary) -> String:
	var action_id = str(option.get("id", ""))
	var subject = str(option.get("short_label", option.get("label", "확인")))
	match action_id:
		"exterior":
			return "사진 조금 더 볼게요"
		"mark":
			return "%s도 찍어줄 수 있어요?" % subject
		"function":
			return "%s 확인해봐도 돼요?" % subject
		"origin":
			return "이거 어디서 얻으셨어요?"
		"market":
			return "비슷한 매물 직접 찾아보기"
		_:
			return subject


func investigation_chat_messages(listing: Dictionary, option: Dictionary, result_message: String) -> Array:
	var action_id = str(option.get("id", ""))
	var seller: Dictionary = listing.get("seller", {})
	var seller_name = Art.seller_name(seller)
	var subject = str(option.get("short_label", option.get("label", "물건")))
	var result: Array = []

	match action_id:
		"origin":
			var claim = str(listing.get("seller_claim", {}).get("text", "")).strip_edges()
			if claim.is_empty():
				claim = "정확한 건 저도 잘 모르겠어요. 가지고 있던 경로는 말씀드릴게요."
			result.append({"speaker":"buyer","text":"이거 어디서 얻으셨어요?"})
			result.append({"speaker":"seller","text":claim.trim_prefix("“").trim_suffix("”")})
			result.append({"speaker":"note","label":"대화하며 확인","text":result_message})
		"market":
			result.append({"speaker":"note","label":"시세 검색 결과","text":result_message})
		"exterior":
			result.append({"speaker":"buyer","text":"사진 조금 더 볼게요. 다른 각도도 있나요?"})
			result.append({"speaker":"seller","text":"네, 잠깐만요. 지금 있는 사진 하나 더 보내드릴게요."})
			result.append({"speaker":"note","label":"사진에서 확인","text":result_message})
		"mark":
			result.append({"speaker":"buyer","text":"%s 쪽도 가까이 찍어줄 수 있어요?" % subject})
			result.append({"speaker":"seller","text":"네. 잘 보이게 가까이 찍어서 보낼게요."})
			result.append({"speaker":"note","label":"사진에서 확인","text":result_message})
		"function":
			result.append({"speaker":"buyer","text":"%s 직접 확인해봐도 돼요?" % subject})
			result.append({"speaker":"seller","text":"네, 만나서 직접 확인하셔도 됩니다."})
			result.append({"speaker":"note","label":"직접 확인","text":result_message})
		_:
			result.append({"speaker":"buyer","text":"이 부분 조금 더 확인해볼게요."})
			result.append({"speaker":"note","label":"확인한 내용","text":result_message})

	return result


func investigation_interaction(listing: Dictionary, option: Dictionary, result_message: String) -> Dictionary:
	var action_id = str(option.get("id", ""))
	var seller: Dictionary = listing.get("seller", {})
	var seller_name = Art.seller_name(seller)
	var subject = str(option.get("short_label", option.get("label", "물건")))
	match action_id:
		"origin":
			var claim = str(listing.get("seller_claim", {}).get("text", "")).strip_edges()
			if claim.is_empty():
				claim = "정확한 건 저도 잘 모르겠어요. 가지고 있던 경로는 말씀드릴게요."
			return {
				"kind":"chat",
				"title":"판매자에게 물어봄",
				"text":"나: “이거 어디서 얻으셨어요?”\n%s: %s\n대화하며 확인: %s" % [seller_name, claim, result_message]
			}
		"market":
			return {
				"kind":"search",
				"title":"비슷한 매물을 찾아봄",
				"text":"중고장터와 상점 기록을 비교해봤다.\n%s" % result_message
			}
		"exterior", "mark":
			return {
				"kind":"photo",
				"title":"사진을 더 확인함",
				"text":"나: “%s 쪽을 좀 더 볼 수 있을까요?”\n%s: “네, 잠깐만요.”\n사진에서 확인: %s" % [subject, seller_name, result_message]
			}
		"function":
			return {
				"kind":"onsite",
				"title":"직거래 전 확인",
				"text":"%s을(를) 직접 확인해봤다.\n%s" % [subject, result_message]
			}
		_:
			return {
				"kind":"check",
				"title":"추가로 확인함",
				"text":result_message
			}


func seller_activity_text(listing: Dictionary) -> String:
	var seller: Dictionary = listing.get("seller", {})
	var seller_type = str(seller.get("type", ""))
	match seller_type:
		"urgent":
			return "방금 답장함 · 오늘 거래 선호"
		"greedy":
			return "최근 접속 · 가격 제안은 신중히 봄"
		"bluffer":
			return "조금 전 접속 · 설명이 길어지는 편"
		"naive":
			return "최근 접속 · 물건 사연을 많이 말해줌"
		"expert":
			return "최근 접속 · 질문에 짧게 답함"
		_:
			return "최근 접속"


func seller_message_text(listing: Dictionary) -> String:
	var seller: Dictionary = listing.get("seller", {})
	var seller_type = str(seller.get("type", ""))
	var messages := {
		"urgent":["“가능하면 오늘 바로 거래하고 싶어요.”","“시간 맞으면 오늘 저녁에도 가능합니다.”"],
		"greedy":["“가격은 물건 보시면 납득하실 거예요.”","“너무 낮은 제안은 조금 어려워요.”"],
		"bluffer":["“이런 물건은 흔하게 나오는 게 아니에요.”","“아는 분들은 보면 바로 알아보실 겁니다.”"],
		"naive":["“저도 정확한 시세는 잘 모르겠어요.”","“필요한 분이 가져가시면 좋겠어요.”"],
		"expert":["“궁금한 부분 있으면 구체적으로 물어보세요.”","“상태는 직접 확인하고 결정하시는 게 좋습니다.”"]
	}
	var pool: Array = messages.get(seller_type, ["“궁금한 부분 있으면 물어보세요.”"])
	var fingerprint = abs(int(("%s_message" % listing.get("listing_id", "")).hash()))
	return str(pool[fingerprint % pool.size()])


func matches_filter(listing: Dictionary, query: String, tab_id: String, category_id: String) -> bool:
	var seller: Dictionary = listing.get("seller", {})
	var viewed = bool(listing.get("viewed", false)) or not listing.get("inspected_actions", []).is_empty()
	var q = query.strip_edges().to_lower()

	if not q.is_empty():
		var haystack = "%s %s %s %s %s" % [
			Art.item_name(listing),
			Art.seller_name(seller),
			str(listing.get("category", "")),
			public_location_text(listing),
			listing_story_text(listing)
		]
		if not haystack.to_lower().contains(q):
			return false

	if tab_id == "negotiable":
		if str(listing.get("listing_status", "미확인")) in ["구매 완료", "판매 완료"]:
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


func _seller_content(seller: Dictionary) -> Dictionary:
	var seller_id = str(seller.get("id", ""))
	for entry in Content.SELLERS:
		if str(entry.get("id", "")) == seller_id:
			return entry
	return {}


func _item_content(listing: Dictionary) -> Dictionary:
	var item_id = str(listing.get("item_id", ""))
	for entry in Content.ITEMS:
		if str(entry.get("id", "")) == item_id:
			return entry
	return {}


func public_location_text(listing: Dictionary) -> String:
	var seller: Dictionary = listing.get("seller", {})
	if seller.has("neighborhood"):
		return str(seller["neighborhood"])
	var canonical = _seller_content(seller)
	return str(canonical.get("neighborhood", "어둠마을"))


func public_meetup_text(listing: Dictionary) -> String:
	var seller: Dictionary = listing.get("seller", {})
	if seller.has("meetup"):
		return str(seller["meetup"])
	var canonical = _seller_content(seller)
	return str(canonical.get("meetup", "%s 근처" % public_location_text(listing)))


func seller_profile_text(listing: Dictionary) -> String:
	var seller: Dictionary = listing.get("seller", {})
	if seller.has("profile"):
		return str(seller["profile"])
	var canonical = _seller_content(seller)
	return str(canonical.get("profile", "근처에서 직거래를 선호하는 판매자입니다."))


func listing_story_text(listing: Dictionary) -> String:
	var saved_story = str(listing.get("listing_story", "")).strip_edges()
	if not saved_story.is_empty():
		return saved_story
	var item = _item_content(listing)
	var stories: Array = item.get("market_stories", [])
	if stories.is_empty():
		return "정리 중 나온 물건입니다. 직접 보고 결정해주세요."
	var fingerprint = abs(int(str(listing.get("listing_id", listing.get("item_id", ""))).hash()))
	return str(stories[fingerprint % stories.size()])


func listing_post_text(listing: Dictionary) -> String:
	var story = listing_story_text(listing)
	var claim = str(listing.get("seller_claim", {}).get("text", "")).strip_edges()
	if claim.is_empty():
		return story
	return "%s\n\n%s" % [story, claim]


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
