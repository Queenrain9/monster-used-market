extends RefCounted

const Content = preload("res://data/content.gd")

var rng = RandomNumberGenerator.new()


func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()


func content_summary() -> Dictionary:
	return {
		"items": Content.ITEMS.size(),
		"seller_types": Content.SELLER_TYPES.size(),
		"sellers": Content.SELLERS.size(),
		"buyers": Content.BUYERS.size(),
		"clues": Content.CLUES.size()
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
		errors.append("단서가 25개보다 적습니다.")
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
	var clue_pack = _generate_clues(state, condition, seller)

	return {
		"listing_id": "%s_%d_%d" % [item["id"], int(Time.get_unix_time_from_system()), rng.randi_range(1000, 9999)],
		"item_id": item["id"],
		"name": item["name"],
		"category": item["category"],
		"tags": item["tags"].duplicate(),
		"base_value": item["base_value"],
		"state": state,
		"condition": condition,
		"rarity": rarity,
		"actual_value": actual_value,
		"asking": asking,
		"seller": seller,
		"public_clues": clue_pack["public"],
		"hidden_clues": clue_pack["hidden"],
		"archetype": archetype
	}


func start_negotiation(listing: Dictionary) -> Dictionary:
	var personality: Dictionary = listing["seller"]["personality"]
	return {
		"current_price": int(listing["asking"]),
		"rounds": 0,
		"max_rounds": 3,
		"patience": int(personality["patience"]),
		"mood": 0,
		"closed": false
	}


func negotiate(listing: Dictionary, state: Dictionary, action: String) -> Dictionary:
	var updated = state.duplicate(true)
	if bool(updated.get("closed", false)):
		return {
			"state": updated,
			"accepted_price": 0,
			"speech": "“흥정은 끝났어. 현재 가격에 살지 말지만 정해.”",
			"status": "더 이상 흥정할 수 없습니다."
		}

	var personality: Dictionary = listing["seller"]["personality"]
	var current_price = int(updated["current_price"])
	var floor_price = int(round(float(listing["asking"]) * float(personality["floor_ratio"])))
	var receptiveness = float(personality["discount_receptiveness"])
	var mood = int(updated["mood"])
	var accepted_price = 0
	var speech = ""
	var status = ""
	var patience_cost = 0
	updated["rounds"] = int(updated["rounds"]) + 1

	if action == "quick":
		var target = max(floor_price, int(round(float(current_price) * 0.86)))
		var chance = 0.34 + receptiveness * 0.50 + float(mood) * 0.04
		if target <= floor_price:
			chance -= 0.10
		if rng.randf() <= clamp(chance, 0.08, 0.94):
			accepted_price = target
			speech = "“지금 바로 산다면… 좋아. %sG에 넘기지.”" % _money(target)
			status = "빠른 거래 제안이 먹혔습니다."
			updated["current_price"] = target
			updated["closed"] = true
		else:
			patience_cost = 1
			updated["mood"] = mood - 1
			speech = "“그건 너무 세게 깎았어. 그렇게는 못 팔아.”"
			status = "공격적인 제안이 거절됐습니다."

	elif action == "condition":
		var evidence = _count_negative_clues(listing)
		var chance = 0.30 + receptiveness * 0.34 + min(evidence, 2) * 0.18 + float(mood) * 0.03
		var reduction = 0.045 + min(evidence, 2) * 0.035
		if rng.randf() <= clamp(chance, 0.08, 0.92):
			var new_price = max(floor_price, int(round(float(current_price) * (1.0 - reduction))))
			updated["current_price"] = new_price
			updated["mood"] = mood + 1
			speech = "“그 부분을 봤군… 그럼 %sG까지는 낮추지.”" % _money(new_price)
			status = "관찰한 단서를 근거로 가격을 낮췄습니다."
		else:
			patience_cost = 1
			updated["mood"] = mood - 1
			speech = "“그 정도 흠집으로 값을 깎을 순 없어.”"
			status = "단서 지적이 설득력을 얻지 못했습니다."

	elif action == "soft":
		var chance = 0.50 + receptiveness * 0.42 + float(mood) * 0.04
		if rng.randf() <= clamp(chance, 0.10, 0.95):
			var reduction = rng.randf_range(0.04, 0.075)
			var new_price = max(floor_price, int(round(float(current_price) * (1.0 - reduction))))
			updated["current_price"] = new_price
			updated["mood"] = mood + 1
			speech = "“조금만이다. %sG이면 어때?”" % _money(new_price)
			status = "작은 양보를 받아냈습니다."
		else:
			patience_cost = 1
			speech = "“이미 충분히 맞춰준 가격이야.”"
			status = "추가 할인이 거절됐습니다."

	updated["patience"] = max(0, int(updated["patience"]) - patience_cost)
	if accepted_price <= 0 and (int(updated["patience"]) <= 0 or int(updated["rounds"]) >= int(updated["max_rounds"])):
		updated["closed"] = true
		if int(updated["patience"]) <= 0:
			speech += "\n“흥정은 여기까지야.”"
			status += " 판매자의 인내도가 바닥났습니다."
		else:
			speech += "\n“세 번이나 얘기했잖아. 이제 결정해.”"
			status += " 흥정 기회를 모두 사용했습니다."

	return {
		"state": updated,
		"accepted_price": accepted_price,
		"speech": speech,
		"status": status
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
	for clue in listing["public_clues"]:
		if bool(clue.get("aligned", true)):
			feedback.append("%s → %s" % [clue["text"], clue["reveal"]])
		else:
			feedback.append("%s → 실제로는 결정적 근거가 아닌 예외적 흔적이었다." % clue["text"])

	return {
		"state": listing["state"],
		"rarity": listing["rarity"],
		"condition": listing["condition"],
		"value": int(listing["actual_value"]),
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
	while chosen.size() < 2 and not specialists.is_empty():
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
			"reason": reason
		})
	return offers


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


func _generate_clues(state: String, condition: String, seller: Dictionary) -> Dictionary:
	var public = []
	var hidden = []

	var truth_signal = "genuine"
	if state == "모조품":
		truth_signal = "imitation"
	elif state == "결함품":
		truth_signal = "defect"

	var first_signal = truth_signal
	var first_aligned = true
	if rng.randf() < 0.18:
		first_aligned = false
		if truth_signal == "genuine":
			first_signal = "defect" if rng.randf() < 0.5 else "neutral"
		else:
			first_signal = "genuine"
	public.append(_pick_clue(first_signal, first_aligned))

	var condition_signal = "neutral"
	if condition in ["최상", "양호"]:
		condition_signal = "quality"
	elif condition == "손상":
		condition_signal = "defect"
	elif condition == "사용감":
		condition_signal = "neutral"
	public.append(_pick_clue(condition_signal, true))
	public.append(_pick_clue("neutral", true))
	public.append(_make_seller_claim(state, seller))

	hidden.append(_pick_clue(truth_signal, true))
	if condition in ["최상", "양호"]:
		hidden.append(_pick_clue("quality", true))
	else:
		hidden.append(_pick_clue("defect", true))

	return {"public": public, "hidden": hidden}


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


func _pick_clue(clue_signal: String, aligned: bool) -> Dictionary:
	var candidates = []
	for clue in Content.CLUES:
		if clue["signal"] == clue_signal:
			candidates.append(clue)
	if candidates.is_empty():
		for clue in Content.CLUES:
			if clue["signal"] == "neutral":
				candidates.append(clue)

	var chosen: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)].duplicate(true)
	chosen["aligned"] = aligned
	return chosen


func _count_negative_clues(listing: Dictionary) -> int:
	var count = 0
	for clue in listing["public_clues"]:
		if clue["kind"] == "부정적":
			count += 1
	return count


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
