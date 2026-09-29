extends RefCounted

const Content = preload("res://data/content.gd")

var rng = RandomNumberGenerator.new()


func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()


func content_summary() -> Dictionary:
	var profile_clue_count = 0
	for pool in Content.PROFILE_CLUES.values():
		profile_clue_count += pool.size()
	return {
		"items": Content.ITEMS.size(),
		"seller_types": Content.SELLER_TYPES.size(),
		"sellers": Content.SELLERS.size(),
		"buyers": Content.BUYERS.size(),
		"clues": Content.CLUES.size(),
		"profile_clues": profile_clue_count,
		"investigation_profiles": Content.INVESTIGATION_PROFILES.size()
	}


func validate_content() -> Array:
	var errors = []
	var summary = content_summary()
	if int(summary["items"]) < 12:
		errors.append("아이템이 12종보다 적습니다.")
	if int(summary["seller_types"]) < 5:
		errors.append("판매자 성격이 5종보다 적습니다.")
	if int(summary["sellers"]) < 8:
		errors.append("판매자 캐릭터가 8명보다 적습니다.")
	if int(summary["buyers"]) < 5:
		errors.append("구매자 유형이 5종보다 적습니다.")
	if int(summary["clues"]) < 25:
		errors.append("공용 단서가 25개보다 적습니다.")
	if int(summary["investigation_profiles"]) < 4:
		errors.append("재사용 가능한 조사 프로필이 부족합니다.")

	var required_ids = ["exterior", "mark", "function", "origin", "market"]
	for profile_id in Content.INVESTIGATION_PROFILES.keys():
		var profile: Array = Content.INVESTIGATION_PROFILES[profile_id]
		if profile.size() != 5:
			errors.append("%s 조사 프로필은 5개 행동이어야 합니다." % profile_id)
			continue
		var ids = []
		for action in profile:
			ids.append(str(action.get("id", "")))
			if str(action.get("short_label", "")).is_empty() or str(action.get("label", "")).is_empty():
				errors.append("%s 조사 프로필에 빈 라벨이 있습니다." % profile_id)
		if ids != required_ids:
			errors.append("%s 조사 프로필의 안정 ID 순서가 잘못됐습니다." % profile_id)

	for item in Content.ITEMS:
		var item_id = str(item["id"])
		var profile_id = str(item.get("investigation_profile", ""))
		if profile_id.is_empty() or not Content.INVESTIGATION_PROFILES.has(profile_id):
			errors.append("%s의 investigation_profile이 유효하지 않습니다." % item_id)
			continue
		var overrides: Dictionary = item.get("investigation_overrides", {})
		for action_id in overrides.keys():
			if not required_ids.has(str(action_id)):
				errors.append("%s에 알 수 없는 조사 override %s가 있습니다." % [item_id, action_id])
		for clue in item.get("unique_clues", []):
			if str(clue.get("id", "")).is_empty() or str(clue.get("signal", "")).is_empty() or str(clue.get("text", "")).is_empty():
				errors.append("%s의 unique clue가 불완전합니다." % item_id)

	for profile_id in Content.PROFILE_CLUES.keys():
		if not Content.INVESTIGATION_PROFILES.has(profile_id):
			errors.append("단서 풀 %s에 대응하는 조사 프로필이 없습니다." % profile_id)
	return errors

func generate_market(count: int = 3) -> Array:
	var pool = Content.ITEMS.duplicate(true)
	var result = []
	while result.size() < count and not pool.is_empty():
		var index = rng.randi_range(0, pool.size() - 1)
		var item: Dictionary = pool[index]
		pool.remove_at(index)
		result.append(generate_listing(item))
	return result


func generate_listing(item: Dictionary) -> Dictionary:
	var state = _weighted_choice(item["state_weights"])
	var condition = _choose_condition(state)
	var rarity = _weighted_choice(item["rarity_weights"])
	var rarity_mult = float(Content.RARITY_MULTIPLIERS.get(rarity, 1.0))
	var state_mult = float(Content.STATE_MULTIPLIERS.get(state, 1.0))
	var condition_mult = float(Content.CONDITION_MULTIPLIERS.get(condition, 1.0))
	var actual_value = max(500, int(round(
		float(item["base_value"]) * rarity_mult * state_mult * condition_mult * rng.randf_range(0.93, 1.07)
	)))

	var seller: Dictionary = Content.SELLERS[rng.randi_range(0, Content.SELLERS.size() - 1)].duplicate(true)
	var personality: Dictionary = Content.SELLER_TYPES[seller["type"]].duplicate(true)
	seller["personality"] = personality

	var archetype = _choose_archetype()
	var asking = _calculate_asking(actual_value, archetype, seller)
	var clue_pack = _generate_clues(state, condition, seller, item)

	var public_clues: Array = clue_pack["public"]
	var hidden_clues: Array = clue_pack["hidden"]
	var initial_clue: Dictionary = public_clues[0].duplicate(true)
	var seller_claim: Dictionary = public_clues[3].duplicate(true)

	var investigation_clues = [
		public_clues[1].duplicate(true),
		hidden_clues[0].duplicate(true),
		hidden_clues[1].duplicate(true),
		public_clues[2].duplicate(true)
	]

	var post_clues = [
		_pick_clue_for_item(item, _truth_signal(state), true),
		_pick_clue_for_item(item, "defect" if condition in ["사용감", "손상"] else "quality", true),
		_pick_clue_for_item(item, "neutral", true)
	]

	return {
		"listing_id": "%s_%d_%d" % [item["id"], int(Time.get_unix_time_from_system()), rng.randi_range(1000, 9999)],
		"item_id": item["id"],
		"name": item["name"],
		"category": item["category"],
		"tags": item["tags"].duplicate(),
		"investigation_profile": str(item.get("investigation_profile", "")),
		"investigation_overrides": item.get("investigation_overrides", {}).duplicate(true),
		"base_value": item["base_value"],
		"state": state,
		"condition": condition,
		"rarity": rarity,
		"actual_value": actual_value,
		"asking": asking,
		"seller": seller,
		"archetype": archetype,
		"listing_status": "미확인",
		"initial_clue": initial_clue,
		"seller_claim": seller_claim,
		"discovered_clues": [initial_clue.duplicate(true), seller_claim.duplicate(true)],
		"investigation_clues": investigation_clues,
		"post_clues": post_clues,
		"inspected_actions": [],
		"post_inspected_actions": [],
		"hypothesis": {},
		"trade_plan": {}
	}


func investigation_options(listing: Dictionary) -> Array:
	var profile_id = str(listing.get("investigation_profile", ""))
	var overrides: Dictionary = listing.get("investigation_overrides", {})
	if profile_id.is_empty():
		var item = _item_definition(str(listing.get("item_id", "")))
		if not item.is_empty():
			profile_id = str(item.get("investigation_profile", ""))
			overrides = item.get("investigation_overrides", {})

	if Content.INVESTIGATION_PROFILES.has(profile_id):
		var options: Array = Content.INVESTIGATION_PROFILES[profile_id].duplicate(true)
		for i in range(options.size()):
			var action_id = str(options[i]["id"])
			if overrides.has(action_id):
				var patch: Dictionary = overrides[action_id]
				for key in patch.keys():
					options[i][key] = patch[key]
		return options

	var fallback = Content.INVESTIGATION_ACTIONS.duplicate(true)
	for option in fallback:
		option["short_label"] = str(option["label"])
		if option["id"] == "market":
			option["market"] = true
		else:
			option["clue_slot"] = {
				"exterior":0,
				"mark":1,
				"function":2,
				"origin":3
			}.get(str(option["id"]), 0)
	return fallback

func investigate(listing: Dictionary, action_id: String) -> Dictionary:
	var updated = listing.duplicate(true)
	var inspected: Array = updated.get("inspected_actions", [])
	if inspected.has(action_id):
		return {"listing": updated, "consumed": false, "message": "이미 확인한 항목입니다."}

	var options = investigation_options(updated)
	var known_action = false
	for option in options:
		if option["id"] == action_id:
			known_action = true
			break
	if not known_action:
		return {"listing": updated, "consumed": false, "message": "사용할 수 없는 조사입니다."}

	inspected.append(action_id)
	updated["inspected_actions"] = inspected
	updated["listing_status"] = "조사 중"

	var selected_action = {}
	for option in options:
		if str(option["id"]) == action_id:
			selected_action = option
			break

	if bool(selected_action.get("market", false)) or action_id == "market":
		var low = max(500, int(round(float(updated["base_value"]) * 0.55)))
		var high = int(round(float(updated["base_value"]) * 1.85))
		var market_clue = {
			"id":"market_estimate",
			"kind":"시세",
			"signal":"market",
			"text":"동종품 거래 범위는 대략 %s~%sG. 진위·희귀도·상태에 따라 크게 달라진다." % [_money(low), _money(high)],
			"reveal":"기본 종류의 시세 정보였으며 실제 개체 가치는 별도로 결정됐다.",
			"aligned":true
		}
		_add_discovered_clue(updated, market_clue)
		return {
			"listing": updated,
			"consumed": true,
			"message": market_clue["text"],
			"action_label": str(selected_action.get("label", "시세 조사"))
		}

	var clue_index = int(selected_action.get("clue_slot", 0))
	var clues: Array = updated["investigation_clues"]
	var preferred_index = clamp(clue_index, 0, clues.size() - 1)
	var clue = {}
	for offset in range(clues.size()):
		var candidate_index = (preferred_index + offset) % clues.size()
		var candidate: Dictionary = clues[candidate_index].duplicate(true)
		if not _clue_discovered(updated, candidate):
			clue = candidate
			break

	if clue.is_empty():
		clue = clues[preferred_index].duplicate(true)
		clue["id"] = "%s_%s_repeat" % [clue.get("id", "clue"), action_id]
		clue["text"] = "%s 같은 징후가 다른 조사에서도 다시 확인됐다." % clue["text"]

	_add_discovered_clue(updated, clue)
	return {
		"listing": updated,
		"consumed": true,
		"message":str(clue["text"]),
		"action_label":str(selected_action.get("label", action_id))
	}


func save_hypothesis(listing: Dictionary, authenticity: String, condition_guess: String, value_band: String) -> Dictionary:
	var updated = listing.duplicate(true)
	updated["hypothesis"] = {
		"authenticity": authenticity,
		"condition": condition_guess,
		"value_band": value_band
	}
	if updated["listing_status"] == "미확인":
		updated["listing_status"] = "조사 중"
	return updated


func hypothesis_complete(listing: Dictionary) -> bool:
	var hypothesis: Dictionary = listing.get("hypothesis", {})
	return (
		not str(hypothesis.get("authenticity", "")).is_empty()
		and not str(hypothesis.get("condition", "")).is_empty()
		and not str(hypothesis.get("value_band", "")).is_empty()
	)


func evaluate_hypothesis(listing: Dictionary) -> Array:
	var feedback = []
	var hypothesis: Dictionary = listing.get("hypothesis", {})
	if hypothesis.is_empty():
		return ["△ 구매 전 판단 기록 없음"]

	var auth_guess = str(hypothesis.get("authenticity", ""))
	if auth_guess == "애매함":
		feedback.append("△ 진위 판단은 보류함")
	elif auth_guess == "진품 같음":
		feedback.append("✓ 진품 판단 적중" if listing["state"] == "진품" else "✕ 진품으로 봤지만 실제는 %s" % listing["state"])
	elif auth_guess == "가짜 같음":
		feedback.append("✓ 모조품 의심 적중" if listing["state"] == "모조품" else "✕ 가짜로 봤지만 실제는 %s" % listing["state"])

	var condition_guess = str(hypothesis.get("condition", ""))
	var actual_problem = listing["state"] == "결함품" or listing["condition"] in ["사용감", "손상"]
	if condition_guess == "결함 의심":
		feedback.append("✓ 결함/상태 문제 의심 적중" if actual_problem else "✕ 결함을 의심했지만 상태는 양호한 편")
	elif condition_guess == "정상":
		feedback.append("✓ 정상 상태 판단 적중" if not actual_problem else "✕ 정상으로 봤지만 실제 상태 문제 존재")

	var value_band = str(hypothesis.get("value_band", ""))
	var value_hit = _value_band_contains(value_band, int(listing["actual_value"]))
	feedback.append("✓ 예상 가치 범위 적중" if value_hit else "✕ 예상 가치 범위를 벗어남")
	return feedback


func save_trade_plan(listing: Dictionary, value_band: String, max_buy_price: int, suspect_text: String = "") -> Dictionary:
	var updated = listing.duplicate(true)
	updated["trade_plan"] = {
		"value_band": value_band,
		"max_buy_price": max(0, max_buy_price),
		"suspect_text": suspect_text
	}
	if updated["listing_status"] == "미확인":
		updated["listing_status"] = "조사 중"
	return updated


func trade_plan_complete(listing: Dictionary) -> bool:
	var plan: Dictionary = listing.get("trade_plan", {})
	return (
		not str(plan.get("value_band", "")).is_empty()
		and int(plan.get("max_buy_price", 0)) > 0
	)


func evaluate_trade_plan(listing: Dictionary, purchase_price: int, sale_price: int) -> Array:
	var feedback = []
	var plan: Dictionary = listing.get("trade_plan", {})
	if plan.is_empty():
		return ["△ 구매 전 거래 계획 기록 없음"]

	var value_band = str(plan.get("value_band", ""))
	if _value_band_contains(value_band, sale_price):
		feedback.append("✓ 예상 재판매가 범위 안에서 판매")
	else:
		feedback.append("△ 실제 판매가가 예상 범위를 벗어남")

	var max_buy_price = int(plan.get("max_buy_price", 0))
	if purchase_price <= max_buy_price:
		feedback.append("✓ 내가 정한 최대 매입가 이하로 구매")
	else:
		feedback.append("△ 최대 매입가보다 %sG 더 비싸게 구매" % _money(purchase_price - max_buy_price))

	var suspect_text = str(plan.get("suspect_text", ""))
	if not suspect_text.is_empty():
		feedback.append("• 구매 전 가장 신경 쓴 단서: %s" % suspect_text)
	return feedback


func start_negotiation(listing: Dictionary) -> Dictionary:
	var personality: Dictionary = listing["seller"]["personality"]
	return {
		"current_price": int(listing["asking"]),
		"rounds": 0,
		"max_rounds": 3,
		"patience": int(personality["patience"]),
		"mood": 0,
		"closed": false,
		"evidence_used": [],
		"last_offer": 0
	}


func negotiation_evidence_options(listing: Dictionary) -> Array:
	var result = []
	var clues: Array = listing.get("discovered_clues", [])
	for i in range(clues.size()):
		var clue: Dictionary = clues[i]
		if clue["kind"] == "판매자 주장":
			continue
		result.append({
			"clue_index": i,
			"label":str(clue["text"])
		})
	return result


func negotiate_offer(listing: Dictionary, state: Dictionary, offer_price: int, evidence_clue_index: int) -> Dictionary:
	var updated = state.duplicate(true)
	if bool(updated.get("closed", false)):
		return {
			"state": updated,
			"accepted": false,
			"accepted_price": 0,
			"speech":"“흥정은 끝났어. 현재 가격에 살지 말지만 정해.”",
			"status":"더 이상 새 가격을 제안할 수 없습니다."
		}

	var current_price = int(updated["current_price"])
	var min_offer = max(1, int(round(float(current_price) * 0.50)))
	offer_price = clamp(offer_price, min_offer, current_price)

	var personality: Dictionary = listing["seller"]["personality"]
	var seller_type = str(listing["seller"]["type"])
	var evidence_strength = 0.0
	var evidence_text = "근거 없음"

	var clues: Array = listing.get("discovered_clues", [])
	if evidence_clue_index >= 0 and evidence_clue_index < clues.size():
		var clue: Dictionary = clues[evidence_clue_index]
		evidence_strength = _evidence_strength(clue)
		evidence_text = str(clue["text"])
		var used: Array = updated.get("evidence_used", [])
		if used.has(evidence_text):
			evidence_strength *= 0.20
		else:
			used.append(evidence_text)
			updated["evidence_used"] = used

	var floor_ratio = float(personality["floor_ratio"])
	var receptiveness = float(personality["discount_receptiveness"])
	var base_floor = float(listing["asking"]) * floor_ratio
	var evidence_discount = float(listing["asking"]) * max(0.0, evidence_strength) * 0.085
	var personality_adjust = 0.0
	if seller_type == "urgent":
		personality_adjust = -float(listing["asking"]) * 0.055
	elif seller_type == "greedy":
		personality_adjust = float(listing["asking"]) * 0.035
	elif seller_type == "naive":
		personality_adjust = -float(listing["asking"]) * 0.025
	elif seller_type == "expert" and evidence_strength <= 0.0:
		personality_adjust = float(listing["asking"]) * 0.025

	var acceptable_floor = max(1.0, base_floor - evidence_discount + personality_adjust)
	var mood = int(updated["mood"])
	acceptable_floor *= 1.0 - clamp(float(mood) * 0.012, -0.04, 0.04)

	updated["rounds"] = int(updated["rounds"]) + 1
	updated["last_offer"] = offer_price

	var accepted = false
	var accepted_price = 0
	var speech = ""
	var status = ""

	var acceptance_margin = lerp(1.035, 0.985, receptiveness)
	if float(offer_price) >= acceptable_floor * acceptance_margin:
		accepted = true
		accepted_price = offer_price
		updated["current_price"] = offer_price
		updated["closed"] = true
		speech = _accept_speech(seller_type, offer_price, evidence_strength)
		status = "제안이 받아들여졌습니다."
	elif float(offer_price) >= acceptable_floor * 0.84:
		var counter = int(round(max(acceptable_floor, (float(offer_price) + float(current_price)) * 0.5)))
		counter = min(counter, current_price - 1)
		counter = max(counter, offer_price + 1)
		updated["current_price"] = counter
		updated["mood"] = mood + (1 if evidence_strength > 0.55 else 0)
		speech = _counter_speech(seller_type, counter, evidence_strength)
		status = "판매자가 카운터 가격을 제시했습니다."
	else:
		updated["patience"] = max(0, int(updated["patience"]) - 1)
		updated["mood"] = mood - 1
		speech = _reject_speech(seller_type, evidence_strength)
		status = "제안이 너무 낮아 거절됐습니다."

	if not accepted and (int(updated["rounds"]) >= int(updated["max_rounds"]) or int(updated["patience"]) <= 0):
		updated["closed"] = true
		speech += "\n“이제 더 흥정하지 않을게. 현재 가격으로 결정해.”"
		status += " 흥정 기회를 모두 사용했습니다."

	return {
		"state": updated,
		"accepted": accepted,
		"accepted_price": accepted_price,
		"speech": speech,
		"status": status,
		"evidence_text": evidence_text,
		"evidence_strength": evidence_strength
	}


func post_inspection_options(listing: Dictionary) -> Array:
	return Content.POST_INSPECTIONS.duplicate(true)


func run_post_inspection(listing: Dictionary, action_id: String) -> Dictionary:
	var updated = listing.duplicate(true)
	var used: Array = updated.get("post_inspected_actions", [])
	if used.has(action_id):
		return {"listing":updated, "consumed":false, "cost":0, "message":"이미 진행한 검사입니다."}

	var options: Array = Content.POST_INSPECTIONS
	var found = false
	var option_cost = 0
	for option in options:
		if option["id"] == action_id:
			found = true
			option_cost = int(option["cost"])
			break
	if not found:
		return {"listing":updated, "consumed":false, "cost":0, "message":"사용할 수 없는 검사입니다."}

	var mapping = {"material":0, "magic":1, "internal":2}
	var clue_index = int(mapping.get(action_id, 0))
	var clues: Array = updated["post_clues"]
	var clue: Dictionary = clues[clamp(clue_index, 0, clues.size() - 1)].duplicate(true)
	_add_discovered_clue(updated, clue)
	used.append(action_id)
	updated["post_inspected_actions"] = used

	return {
		"listing": updated,
		"consumed": true,
		"cost": option_cost,
		"message":str(clue["text"])
	}


func appraise(listing: Dictionary) -> Dictionary:
	var features = []
	if listing["state"] == "진품":
		features.append("제작 방식과 재질이 원본 규격과 일치")
	elif listing["state"] == "모조품":
		features.append("복제 틀·도금·대체 재료 사용 흔적 확인")
	else:
		features.append("원본 계열 특징은 있으나 핵심 구조/기능 결함 확인")

	if listing["condition"] == "최상":
		features.append("보존 상태가 매우 좋음")
	elif listing["condition"] == "양호":
		features.append("정상 사용 범위의 보존 상태")
	elif listing["condition"] == "사용감":
		features.append("마모와 사용 흔적이 가치에 반영됨")
	else:
		features.append("수리 또는 복원 비용이 필요한 손상")

	if listing["rarity"] in ["영웅", "전설"]:
		features.append("동종 매물 중 보기 드문 희소성 확인")
	elif listing["rarity"] == "희귀":
		features.append("시장에 자주 나오지 않는 희귀 등급")
	else:
		features.append("희소성 프리미엄은 크지 않음")

	var feedback = []
	var clues: Array = listing.get("discovered_clues", [])
	for clue in clues:
		if clue["kind"] == "시세":
			feedback.append("%s → %s" % [clue["text"], clue["reveal"]])
		elif bool(clue.get("aligned", true)):
			feedback.append("%s → %s" % [clue["text"], clue["reveal"]])
		else:
			feedback.append("%s → 실제로는 결정적 근거가 아닌 예외적 흔적이었다." % clue["text"])

	var rarity_order = {"일반":0, "고급":1, "희귀":2, "영웅":3, "전설":4}
	var rarity_score = int(rarity_order.get(str(listing["rarity"]), 1))
	var has_magic = listing["tags"].has("마법") or listing["tags"].has("영혼") or listing["tags"].has("연금")
	var magic_grades = ["C", "B", "B", "A", "S"]
	var magic_grade = magic_grades[rarity_score] if has_magic else "C"
	var curse_grade = "없음"
	if listing["tags"].has("저주"):
		curse_grade = ["C", "B", "B", "A", "S"][rarity_score]

	var value = int(listing["actual_value"])
	var value_low = max(1, int(round(float(value) * 0.88 / 100.0)) * 100)
	var value_high = max(value_low, int(round(float(value) * 1.18 / 100.0)) * 100)
	var comment = ""
	if listing["state"] == "진품":
		comment = "원본 제작 특징이 확인됩니다."
	elif listing["state"] == "모조품":
		comment = "겉보기보다 복제 흔적이 분명합니다."
	else:
		comment = "원본 계열 물건이지만 기능 또는 구조 결함이 가치에 반영됩니다."
	if str(listing["rarity"]) in ["영웅", "전설"]:
		comment += " 희소성이 높아 전문 수집가에게는 추가 가치가 생길 수 있습니다."
	else:
		comment += " 최종 판매가는 구매자의 선호 속성에 따라 달라질 수 있습니다."

	return {
		"state": listing["state"],
		"rarity": listing["rarity"],
		"condition": listing["condition"],
		"value": value,
		"value_low": value_low,
		"value_high": value_high,
		"magic_grade": magic_grade,
		"curse_grade": curse_grade,
		"comment": comment,
		"features": features,
		"clue_feedback": feedback
	}


func make_buyer_offers(listing: Dictionary) -> Array:
	var specialists = []
	var scrap = {}
	for buyer in Content.BUYERS:
		if buyer["id"] == "scrap":
			scrap = buyer
		else:
			specialists.append(buyer)

	var chosen = []
	while chosen.size() < 3 and not specialists.is_empty():
		var idx = rng.randi_range(0, specialists.size() - 1)
		chosen.append(specialists[idx])
		specialists.remove_at(idx)
	chosen.append(scrap)

	var offers = []
	for buyer in chosen:
		var multiplier = float(buyer["base_multiplier"])
		var matches = 0
		for tag in listing["tags"]:
			if buyer["preferred_tags"].has(tag):
				matches += 1
		multiplier += min(matches, 2) * 0.14

		if buyer["id"] == "collector":
			if listing["rarity"] == "희귀":
				multiplier += 0.10
			elif listing["rarity"] == "영웅":
				multiplier += 0.22
			elif listing["rarity"] == "전설":
				multiplier += 0.38
		elif buyer["id"] == "mage" and listing["tags"].has("마법"):
			multiplier += 0.18
		elif buyer["id"] == "alchemist" and (listing["tags"].has("재료") or listing["tags"].has("연금")):
			multiplier += 0.18
		elif buyer["id"] == "antiquarian" and (listing["tags"].has("고대") or listing["tags"].has("저주")):
			multiplier += 0.16
		elif buyer["id"] == "scrap" and listing["condition"] == "손상":
			multiplier += 0.08

		if listing["state"] == "모조품" and buyer["id"] != "scrap":
			multiplier *= 0.88
		if listing["condition"] == "손상" and buyer["id"] != "scrap":
			multiplier *= 0.90

		multiplier *= rng.randf_range(0.96, 1.05)
		var price = max(1, int(round(float(listing["actual_value"]) * multiplier)))
		var reason = "기본 시세 기준"
		if matches > 0:
			reason = "선호 속성 %d개 일치" % matches
		elif buyer["id"] == "scrap":
			reason = "즉시 매입 가능, 대신 낮은 가격"

		offers.append({
			"buyer_id": buyer["id"],
			"name": buyer["name"],
			"summary": buyer["summary"],
			"price": price,
			"reason": reason,
			"revealed": buyer["id"] == "scrap"
		})
	return offers


func reveal_quote(offers: Array, index: int) -> Array:
	var updated = offers.duplicate(true)
	if index < 0 or index >= updated.size():
		return updated
	updated[index]["revealed"] = true
	return updated


func best_offer_price(offers: Array) -> int:
	var best = 0
	for offer in offers:
		best = max(best, int(offer["price"]))
	return best


func _generate_clues(state: String, condition: String, seller: Dictionary, item: Dictionary) -> Dictionary:
	var public = []
	var hidden = []

	var truth_signal = _truth_signal(state)
	var first_signal = truth_signal
	var first_aligned = true
	if rng.randf() < 0.18:
		first_aligned = false
		if truth_signal == "genuine":
			first_signal = "defect" if rng.randf() < 0.5 else "neutral"
		else:
			first_signal = "genuine"
	public.append(_pick_clue_for_item(item, first_signal, first_aligned))

	var condition_signal = "neutral"
	if condition in ["최상", "양호"]:
		condition_signal = "quality"
	elif condition == "손상":
		condition_signal = "defect"
	public.append(_pick_clue_for_item(item, condition_signal, true))
	public.append(_pick_clue_for_item(item, "neutral", true))
	public.append(_make_seller_claim(state, seller))

	hidden.append(_pick_clue_for_item(item, truth_signal, true))
	if condition in ["최상", "양호"]:
		hidden.append(_pick_clue_for_item(item, "quality", true))
	else:
		hidden.append(_pick_clue_for_item(item, "defect", true))
	return {"public":public, "hidden":hidden}

func _make_seller_claim(state: String, seller: Dictionary) -> Dictionary:
	var personality: Dictionary = seller["personality"]
	var honest = rng.randf() <= float(personality["claim_honesty"])
	var text = ""
	var reveal = ""
	var aligned = honest

	if honest:
		if state == "진품":
			text = "“출처는 확실해. 오래 보관된 진짜 물건이라고 들었어.”"
			reveal = "판매자의 설명이 감정 결과와 대체로 일치했다."
		elif state == "모조품":
			text = "“솔직히 진품인지는 나도 확신 못 하겠어.”"
			reveal = "판매자가 확신하지 않았던 이유대로 모조품 판정이 나왔다."
		else:
			text = "“완벽하게 멀쩡하진 않아. 조금 손볼 수도 있어.”"
			reveal = "판매자가 언급한 이상 징후가 실제 결함으로 확인됐다."
	else:
		if state == "진품":
			text = "“별건 아니야. 그냥 오래된 잡동사니겠지.”"
			reveal = "판매자가 가치를 낮게 말했지만 실제로는 진품이었다."
		else:
			text = "“감정할 필요도 없어. 틀림없는 진짜야.”"
			reveal = "판매자의 강한 주장은 감정 결과와 맞지 않았다."

	return {
		"id":"seller_claim",
		"kind":"판매자 주장",
		"signal":"claim",
		"text":text,
		"reveal":reveal,
		"aligned":aligned
	}


func _clue_discovered(listing: Dictionary, clue: Dictionary) -> bool:
	var discovered: Array = listing.get("discovered_clues", [])
	for known in discovered:
		if str(known.get("id", "")) == str(clue.get("id", "")) and str(known.get("text", "")) == str(clue.get("text", "")):
			return true
	return false


func _add_discovered_clue(listing: Dictionary, clue: Dictionary) -> void:
	var discovered: Array = listing.get("discovered_clues", [])
	for known in discovered:
		if str(known.get("id", "")) == str(clue.get("id", "")) and str(known.get("text", "")) == str(clue.get("text", "")):
			return
	discovered.append(clue.duplicate(true))
	listing["discovered_clues"] = discovered


func _evidence_strength(clue: Dictionary) -> float:
	if clue["kind"] == "부정적":
		return 1.0 if bool(clue.get("aligned", true)) else 0.22
	if clue["kind"] == "시세":
		return 0.34
	if clue["kind"] == "긍정적":
		return -0.10
	if clue["kind"] == "애매한":
		return -0.16
	return 0.0


func _accept_speech(seller_type: String, price: int, evidence_strength: float) -> String:
	if seller_type == "urgent":
		return "“좋아. 오늘 안에 끝내고 싶었어. %sG에 가져가.”" % _money(price)
	if seller_type == "greedy":
		return "“마음에 안 들지만… %sG면 거래하지.”" % _money(price)
	if seller_type == "bluffer":
		return "“네가 그렇게까지 보았다니 어쩔 수 없군. %sG.”" % _money(price)
	if seller_type == "naive":
		return "“음… 그 정도면 괜찮은 건가? 좋아, %sG.”" % _money(price)
	if seller_type == "expert":
		return "“근거는 인정하지. %sG면 합리적이야.”" % _money(price)
	return "“좋아. %sG에 넘기지.”" % _money(price)


func _counter_speech(seller_type: String, price: int, evidence_strength: float) -> String:
	if seller_type == "urgent":
		return "“그 가격은 너무 낮아. 대신 오늘 바로 사면 %sG까지.”" % _money(price)
	if seller_type == "greedy":
		return "“그걸로는 안 돼. %sG 아래는 생각 없어.”" % _money(price)
	if seller_type == "bluffer":
		return "“그 흠집이 대수라고. 그래도 %sG까진 봐주지.”" % _money(price)
	if seller_type == "naive":
		return "“음… 네 말도 맞는 것 같네. %sG면 어때?”" % _money(price)
	if seller_type == "expert":
		if evidence_strength > 0.55:
			return "“그 지적은 맞아. 반영해서 %sG.”" % _money(price)
		return "“그 근거로는 부족해. 시세상 %sG가 한계야.”" % _money(price)
	return "“%sG면 생각해보지.”" % _money(price)


func _reject_speech(seller_type: String, evidence_strength: float) -> String:
	if seller_type == "urgent":
		return "“급하긴 해도 그 가격은 무리야.”"
	if seller_type == "greedy":
		return "“말도 안 되는 가격이야. 더 부를 생각 없으면 끝내.”"
	if seller_type == "bluffer":
		return "“그 정도 흔적으로 값을 깎겠다고? 이건 귀한 물건이야.”"
	if seller_type == "naive":
		return "“그렇게까지 싸게 팔아도 되는 건지 모르겠네… 그건 싫어.”"
	if seller_type == "expert":
		return "“근거가 약해. 그 가격은 시장가와 맞지 않아.”"
	return "“그 가격은 받을 수 없어.”"


func _choose_condition(state: String) -> String:
	if state == "결함품":
		return _weighted_choice({"양호":0.08,"사용감":0.37,"손상":0.55})
	return _weighted_choice({"최상":0.16,"양호":0.46,"사용감":0.30,"손상":0.08})


func _choose_archetype() -> String:
	return _weighted_choice({"stable":0.28,"ambiguous":0.27,"risky":0.18,"jackpot":0.12,"trap":0.15})


func _calculate_asking(actual_value: int, archetype: String, seller: Dictionary) -> int:
	var band: Dictionary = Content.ARCHETYPES[archetype]
	var ratio = rng.randf_range(float(band["min"]), float(band["max"]))
	var personality: Dictionary = seller["personality"]
	var type_id = str(seller["type"])

	if type_id == "urgent":
		ratio -= 0.10
	elif type_id == "greedy":
		ratio += 0.16
	elif type_id == "bluffer":
		ratio += 0.08
	elif type_id == "naive":
		ratio += rng.randf_range(-0.20, 0.20)

	var knowledge = float(personality["knowledge"])
	if type_id == "expert":
		ratio = lerp(ratio, 1.02, 0.64 * knowledge)
	elif knowledge > 0.70:
		ratio = lerp(ratio, 1.0, 0.20 * knowledge)

	return max(1200, int(round(float(actual_value) * max(0.22, ratio))))


func _truth_signal(state: String) -> String:
	if state == "모조품":
		return "imitation"
	if state == "결함품":
		return "defect"
	return "genuine"


func _item_definition(item_id: String) -> Dictionary:
	for item in Content.ITEMS:
		if str(item.get("id", "")) == item_id:
			return item
	return {}


func _clue_candidates(pool: Array, clue_signal: String) -> Array:
	var candidates = []
	for clue in pool:
		if str(clue.get("signal", "")) == clue_signal:
			candidates.append(clue)
	return candidates


func _pick_from_candidates(candidates: Array, aligned: bool) -> Dictionary:
	var chosen: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)].duplicate(true)
	chosen["aligned"] = aligned
	return chosen


func _pick_clue_for_item(item: Dictionary, clue_signal: String, aligned: bool) -> Dictionary:
	var unique_candidates = _clue_candidates(item.get("unique_clues", []), clue_signal)
	var profile_id = str(item.get("investigation_profile", ""))
	var profile_candidates = []
	if Content.PROFILE_CLUES.has(profile_id):
		profile_candidates = _clue_candidates(Content.PROFILE_CLUES[profile_id], clue_signal)
	var common_candidates = _clue_candidates(Content.CLUES, clue_signal)

	# Unique clues stay special; profile clues are the normal flavor layer.
	# Random selection keeps repeated items from exposing identical facts every run.
	if not unique_candidates.is_empty() and rng.randf() < 0.32:
		return _pick_from_candidates(unique_candidates, aligned)
	if not profile_candidates.is_empty() and (common_candidates.is_empty() or rng.randf() < 0.78):
		return _pick_from_candidates(profile_candidates, aligned)
	if not common_candidates.is_empty():
		return _pick_from_candidates(common_candidates, aligned)

	# Signals such as quality may intentionally have no profile-specific entries.
	var neutral_profile = []
	if Content.PROFILE_CLUES.has(profile_id):
		neutral_profile = _clue_candidates(Content.PROFILE_CLUES[profile_id], "neutral")
	if not neutral_profile.is_empty():
		return _pick_from_candidates(neutral_profile, aligned)
	var neutral_common = _clue_candidates(Content.CLUES, "neutral")
	return _pick_from_candidates(neutral_common, aligned)


func _pick_clue(clue_signal: String, aligned: bool) -> Dictionary:
	var candidates = _clue_candidates(Content.CLUES, clue_signal)
	if candidates.is_empty():
		candidates = _clue_candidates(Content.CLUES, "neutral")
	return _pick_from_candidates(candidates, aligned)

func _value_band_contains(value_band: String, value: int) -> bool:
	if value_band == "0~5,000G":
		return value < 5000
	if value_band == "5,000~15,000G":
		return value >= 5000 and value < 15000
	if value_band == "15,000~30,000G":
		return value >= 15000 and value < 30000
	if value_band == "30,000G 이상":
		return value >= 30000
	return false


func _weighted_choice(weights: Dictionary) -> String:
	var total = 0.0
	for value in weights.values():
		total += float(value)
	var roll = rng.randf() * total
	var cursor = 0.0
	for key in weights.keys():
		cursor += float(weights[key])
		if roll <= cursor:
			return str(key)
	return str(weights.keys()[0])


func _money(value: int) -> String:
	var source = str(abs(value))
	var result = ""
	while source.length() > 3:
		result = "," + source.substr(source.length() - 3, 3) + result
		source = source.substr(0, source.length() - 3)
	result = source + result
	if value < 0:
		result = "-" + result
	return result
