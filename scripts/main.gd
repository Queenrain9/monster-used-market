extends Control

const STARTING_GOLD := 50000
const SAVE_PATH := "user://monster_used_market_save.json"

const ITEM_POOL := [
	{
		"id": "moon_ring",
		"name": "수상한 반지",
		"category": "마법/장신구",
		"asking": 12000,
		"floor_ratio": 0.72,
		"value_min": 85000,
		"value_max": 120000,
		"rarity": "전설",
		"seller": "별빛 상인 블루",
		"stubbornness": 0.35,
		"hint": "낡아 보이지만 보랏빛이 이상하게 맑다."
	},
	{
		"id": "dragon_tooth",
		"name": "용의 이빨",
		"category": "재료",
		"asking": 42000,
		"floor_ratio": 0.82,
		"value_min": 18000,
		"value_max": 52000,
		"rarity": "희귀",
		"seller": "비늘장수 크록",
		"stubbornness": 0.72,
		"hint": "판매자는 진짜 용의 것이라고 우긴다."
	},
	{
		"id": "cursed_mirror",
		"name": "저주받은 거울",
		"category": "가구/유물",
		"asking": 26000,
		"floor_ratio": 0.68,
		"value_min": 7000,
		"value_max": 18000,
		"rarity": "일반",
		"seller": "미망인 유령 모르나",
		"stubbornness": 0.20,
		"hint": "거울 속 표정이 아주 조금 늦게 따라온다."
	},
	{
		"id": "soul_lantern",
		"name": "영혼의 랜턴",
		"category": "기타",
		"asking": 28000,
		"floor_ratio": 0.75,
		"value_min": 36000,
		"value_max": 68000,
		"rarity": "영웅",
		"seller": "야시장지기 묘묘",
		"stubbornness": 0.45,
		"hint": "불이 꺼져 있는데도 안쪽이 따뜻하다."
	},
	{
		"id": "witch_thimble",
		"name": "마녀의 은골무",
		"category": "잡화",
		"asking": 8000,
		"floor_ratio": 0.60,
		"value_min": 3000,
		"value_max": 24000,
		"rarity": "고급",
		"seller": "바느질 마녀 피피",
		"stubbornness": 0.30,
		"hint": "손가락에 끼우면 아주 작은 속삭임이 들린다."
	},
	{
		"id": "goblin_watch",
		"name": "고블린 회중시계",
		"category": "장신구",
		"asking": 18000,
		"floor_ratio": 0.78,
		"value_min": 15000,
		"value_max": 42000,
		"rarity": "희귀",
		"seller": "고철상 그리즐",
		"stubbornness": 0.58,
		"hint": "초침이 가끔 거꾸로 움직인다."
	},
	{
		"id": "bone_flute",
		"name": "뼈피리",
		"category": "악기",
		"asking": 14500,
		"floor_ratio": 0.66,
		"value_min": 6000,
		"value_max": 35000,
		"rarity": "고급",
		"seller": "해골 악사 토토",
		"stubbornness": 0.25,
		"hint": "불면 안 된다는 메모가 함께 붙어 있다."
	},
	{
		"id": "meteor_coin",
		"name": "운석 동전",
		"category": "수집품",
		"asking": 33000,
		"floor_ratio": 0.80,
		"value_min": 60000,
		"value_max": 98000,
		"rarity": "영웅",
		"seller": "까마귀 수집가 루크",
		"stubbornness": 0.62,
		"hint": "빛을 비추면 표면의 문양이 바뀐다."
	}
]

@onready var gold_label = $Margin/RootVBox/Header/GoldLabel
@onready var status_label = $Margin/RootVBox/StatusPanel/StatusLabel

@onready var market_panel = $Margin/RootVBox/MarketPanel
@onready var deal_panel = $Margin/RootVBox/DealPanel
@onready var appraisal_panel = $Margin/RootVBox/AppraisalPanel
@onready var sale_panel = $Margin/RootVBox/SalePanel
@onready var result_panel = $Margin/RootVBox/ResultPanel

@onready var market_buttons := [
	$Margin/RootVBox/MarketPanel/MarketBox/ItemButton1,
	$Margin/RootVBox/MarketPanel/MarketBox/ItemButton2,
	$Margin/RootVBox/MarketPanel/MarketBox/ItemButton3
]

@onready var deal_title = $Margin/RootVBox/DealPanel/DealBox/DealTitle
@onready var seller_label = $Margin/RootVBox/DealPanel/DealBox/SellerLabel
@onready var deal_info = $Margin/RootVBox/DealPanel/DealBox/DealInfo
@onready var seller_speech = $Margin/RootVBox/DealPanel/DealBox/SellerSpeech
@onready var buy_full_button = $Margin/RootVBox/DealPanel/DealBox/BuyFullButton
@onready var offer_10_button = $Margin/RootVBox/DealPanel/DealBox/Offer10Button
@onready var offer_25_button = $Margin/RootVBox/DealPanel/DealBox/Offer25Button

@onready var mystery_label = $Margin/RootVBox/AppraisalPanel/AppraisalBox/MysteryLabel

@onready var appraisal_result = $Margin/RootVBox/SalePanel/SaleBox/AppraisalResult
@onready var buyer_offer_label = $Margin/RootVBox/SalePanel/SaleBox/BuyerOfferLabel

@onready var result_summary = $Margin/RootVBox/ResultPanel/ResultBox/ResultSummary

var rng := RandomNumberGenerator.new()
var gold := STARTING_GOLD
var total_deals := 0

var market_items := []
var selected_item := {}
var patience := 2
var purchased_price := 0
var appraised_value := 0
var sale_price := 0


func _ready() -> void:
	rng.randomize()
	_connect_buttons()
	_load_game()
	_update_header()
	_refresh_market()
	_show_panel(market_panel)
	_set_status("첫 매물을 골라보세요. 감정 전에는 진짜 가치가 보이지 않습니다.")


func _connect_buttons() -> void:
	market_buttons[0].pressed.connect(_open_deal.bind(0))
	market_buttons[1].pressed.connect(_open_deal.bind(1))
	market_buttons[2].pressed.connect(_open_deal.bind(2))

	$Margin/RootVBox/MarketPanel/MarketBox/RefreshButton.pressed.connect(_refresh_market)
	$Margin/RootVBox/MarketPanel/MarketBox/ResetButton.pressed.connect(_reset_save)

	buy_full_button.pressed.connect(_attempt_purchase.bind(0.0))
	offer_10_button.pressed.connect(_attempt_purchase.bind(0.10))
	offer_25_button.pressed.connect(_attempt_purchase.bind(0.25))
	$Margin/RootVBox/DealPanel/DealBox/BackMarketButton.pressed.connect(_return_to_market)

	$Margin/RootVBox/AppraisalPanel/AppraisalBox/AppraiseButton.pressed.connect(_appraise)
	$Margin/RootVBox/SalePanel/SaleBox/SellButton.pressed.connect(_sell)
	$Margin/RootVBox/ResultPanel/ResultBox/NextButton.pressed.connect(_next_round)


func _refresh_market() -> void:
	var pool = ITEM_POOL.duplicate(true)
	pool.shuffle()
	market_items = pool.slice(0, 3)

	for i in range(3):
		var item = market_items[i]
		market_buttons[i].text = "%s\n%sG · %s\n%s" % [
			item["name"],
			_money(item["asking"]),
			item["category"],
			item["hint"]
		]

	selected_item = {}
	_set_status("새 매물 3개가 올라왔습니다. 수상한 물건을 골라보세요.")


func _open_deal(index: int) -> void:
	if index < 0 or index >= market_items.size():
		return

	selected_item = market_items[index].duplicate(true)
	patience = 2
	purchased_price = 0
	appraised_value = 0
	sale_price = 0

	deal_title.text = selected_item["name"]
	seller_label.text = "판매자: %s" % selected_item["seller"]
	deal_info.text = "판매 희망가 %sG\n%s" % [
		_money(selected_item["asking"]),
		selected_item["hint"]
	]
	seller_speech.text = "“좋은 물건이야. 가격만 맞으면 바로 넘기지.”"

	buy_full_button.text = "좋아요. %sG에 살게요." % _money(selected_item["asking"])
	offer_10_button.text = "10%% 깎아주세요 · %sG 제안" % _money(_offer_price(0.10))
	offer_25_button.text = "25%% 깎아주세요 · %sG 제안" % _money(_offer_price(0.25))

	buy_full_button.disabled = false
	offer_10_button.disabled = false
	offer_25_button.disabled = false

	_show_panel(deal_panel)
	_set_status("흥정 중입니다. 너무 세게 깎으면 판매자가 버틸 수 있습니다.")


func _attempt_purchase(discount: float) -> void:
	if selected_item.is_empty():
		return

	var asking = int(selected_item["asking"])
	var target_price = int(round(float(asking) * (1.0 - discount)))

	if discount <= 0.0:
		_complete_purchase(target_price)
		return

	var floor_price = int(round(float(asking) * float(selected_item["floor_ratio"])))
	var stubbornness = float(selected_item["stubbornness"])
	var chance = 0.84 - (discount * 1.55) - (stubbornness * 0.24)

	if target_price < floor_price:
		chance *= 0.30

	chance = clamp(chance, 0.08, 0.92)

	if rng.randf() <= chance:
		seller_speech.text = "“흠… 좋아. 오늘만 이 가격에 넘기지.”"
		_complete_purchase(target_price)
	else:
		patience -= 1
		if patience <= 0:
			seller_speech.text = "“더는 못 깎아. 살 거면 원래 가격에 가져가.”"
			offer_10_button.disabled = true
			offer_25_button.disabled = true
			_set_status("흥정 한도가 끝났습니다. 정가 구매 또는 뒤로 가기를 선택하세요.")
		else:
			seller_speech.text = "“그 가격은 너무 낮아. 한 번만 다시 말해봐.”"
			_set_status("제안이 거절됐습니다. 한 번 더 흥정할 수 있습니다.")


func _complete_purchase(price: int) -> void:
	if gold < price:
		seller_speech.text = "“돈부터 챙겨와. 외상은 안 받아.”"
		_set_status("보유 골드가 부족합니다.")
		return

	gold -= price
	purchased_price = price
	_update_header()
	_save_game()

	mystery_label.text = "%s\n\n구매가 %sG\n\n아직 진짜 가치는 알 수 없습니다." % [
		selected_item["name"],
		_money(purchased_price)
	]

	_show_panel(appraisal_panel)
	_set_status("구매 완료. 이제 감정해서 진짜 가치를 확인하세요.")


func _appraise() -> void:
	if selected_item.is_empty() or purchased_price <= 0:
		return

	appraised_value = rng.randi_range(
		int(selected_item["value_min"]),
		int(selected_item["value_max"])
	)

	var offer_multiplier = rng.randf_range(0.86, 1.08)
	sale_price = max(1, int(round(float(appraised_value) * offer_multiplier)))

	appraisal_result.text = "%s 등급\n%s\n\n감정 추정가: %sG" % [
		selected_item["rarity"],
		selected_item["name"],
		_money(appraised_value)
	]
	buyer_offer_label.text = "새 구매자가 나타났습니다.\n현재 제안가: %sG" % _money(sale_price)

	_show_panel(sale_panel)

	if appraised_value > purchased_price * 2:
		_set_status("대박 가능성이 보입니다. 매입가보다 가치가 크게 높습니다.")
	elif appraised_value < purchased_price:
		_set_status("감정 결과가 좋지 않습니다. 손실 거래가 될 수도 있습니다.")
	else:
		_set_status("감정 완료. 이제 되팔아서 실제 손익을 확정하세요.")


func _sell() -> void:
	if sale_price <= 0:
		return

	gold += sale_price
	total_deals += 1
	var profit = sale_price - purchased_price

	_update_header()
	_save_game()

	var profit_text = "+%sG" % _money(profit)
	if profit < 0:
		profit_text = "-%sG" % _money(abs(profit))

	result_summary.text = "%s 판매 완료\n\n매입가   %sG\n판매가   %sG\n순손익   %s\n\n누적 거래 %d회 · 현재 자산 %sG" % [
		selected_item["name"],
		_money(purchased_price),
		_money(sale_price),
		profit_text,
		total_deals,
		_money(gold)
	]

	_show_panel(result_panel)

	if profit > 0:
		_set_status("거래 성공! 다음 매물을 찾아 더 큰 차익을 노려보세요.")
	else:
		_set_status("손실 거래였습니다. 다음 매물에서는 단서를 더 의심해보세요.")


func _next_round() -> void:
	_refresh_market()
	_show_panel(market_panel)


func _return_to_market() -> void:
	selected_item = {}
	_show_panel(market_panel)
	_set_status("거래를 포기했습니다. 다른 매물을 골라보세요.")


func _reset_save() -> void:
	gold = STARTING_GOLD
	total_deals = 0
	selected_item = {}
	purchased_price = 0
	appraised_value = 0
	sale_price = 0
	_update_header()
	_save_game()
	_refresh_market()
	_show_panel(market_panel)
	_set_status("테스트 데이터를 초기화했습니다. 50,000G부터 다시 시작합니다.")


func _offer_price(discount: float) -> int:
	return int(round(float(selected_item["asking"]) * (1.0 - discount)))


func _show_panel(target) -> void:
	var panels = [market_panel, deal_panel, appraisal_panel, sale_panel, result_panel]
	for panel in panels:
		panel.visible = panel == target


func _update_header() -> void:
	gold_label.text = "%s G" % _money(gold)


func _set_status(text: String) -> void:
	status_label.text = text


func _save_game() -> void:
	var payload = {
		"gold": gold,
		"total_deals": total_deals
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))


func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		gold = int(parsed.get("gold", STARTING_GOLD))
		total_deals = int(parsed.get("total_deals", 0))


func _money(value: int) -> String:
	var negative = value < 0
	var source = str(abs(value))
	var result = ""

	while source.length() > 3:
		result = "," + source.substr(source.length() - 3, 3) + result
		source = source.substr(0, source.length() - 3)

	result = source + result
	if negative:
		result = "-" + result
	return result
