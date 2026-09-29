extends Control

const MarketEngine = preload("res://scripts/game_logic.gd")
const STARTING_GOLD = 50000
const SAVE_PATH = "user://monster_used_market_save_v02.json"

@onready var gold_label = $Margin/RootVBox/Header/GoldLabel
@onready var stats_label = $Margin/RootVBox/StatsLabel
@onready var status_label = $Margin/RootVBox/StatusPanel/StatusLabel

@onready var market_panel = $Margin/RootVBox/MarketPanel
@onready var deal_panel = $Margin/RootVBox/DealPanel
@onready var appraisal_panel = $Margin/RootVBox/AppraisalPanel
@onready var sale_panel = $Margin/RootVBox/SalePanel
@onready var result_panel = $Margin/RootVBox/ResultPanel

@onready var market_buttons = [
	$Margin/RootVBox/MarketPanel/MarketBox/ItemButton1,
	$Margin/RootVBox/MarketPanel/MarketBox/ItemButton2,
	$Margin/RootVBox/MarketPanel/MarketBox/ItemButton3
]

@onready var deal_title = $Margin/RootVBox/DealPanel/DealBox/DealTitle
@onready var seller_label = $Margin/RootVBox/DealPanel/DealBox/SellerLabel
@onready var negotiation_state_label = $Margin/RootVBox/DealPanel/DealBox/NegotiationStateLabel
@onready var deal_info = $Margin/RootVBox/DealPanel/DealBox/DealInfo
@onready var seller_speech = $Margin/RootVBox/DealPanel/DealBox/SellerSpeech
@onready var buy_full_button = $Margin/RootVBox/DealPanel/DealBox/BuyFullButton
@onready var quick_offer_button = $Margin/RootVBox/DealPanel/DealBox/Offer10Button
@onready var condition_button = $Margin/RootVBox/DealPanel/DealBox/Offer25Button
@onready var soft_offer_button = $Margin/RootVBox/DealPanel/DealBox/SoftOfferButton

@onready var mystery_label = $Margin/RootVBox/AppraisalPanel/AppraisalBox/MysteryLabel
@onready var appraisal_result = $Margin/RootVBox/SalePanel/SaleBox/AppraisalResult
@onready var buyer_offer_label = $Margin/RootVBox/SalePanel/SaleBox/BuyerOfferLabel
@onready var buyer_buttons = [
	$Margin/RootVBox/SalePanel/SaleBox/BuyerButton1,
	$Margin/RootVBox/SalePanel/SaleBox/BuyerButton2,
	$Margin/RootVBox/SalePanel/SaleBox/BuyerButton3
]
@onready var result_summary = $Margin/RootVBox/ResultPanel/ResultBox/ResultSummary

var engine = MarketEngine.new()

var gold = STARTING_GOLD
var total_deals = 0
var today_deals = 0
var today_date = ""
var best_profit = 0
var worst_loss = 0
var rare_items = []

var market_items = []
var selected_item = {}
var negotiation_state = {}
var purchased_price = 0
var appraisal_data = {}
var buyer_offers = []
var current_stage = "market"


func _ready() -> void:
	_connect_buttons()
	var validation_errors = engine.validate_content()
	for error in validation_errors:
		push_error("v0.2 content validation: %s" % error)

	_load_game()
	_roll_daily_counter_if_needed()
	_update_header()

	if market_items.size() < 3:
		_refresh_market(false)
	else:
		_render_market()

	_restore_stage()


func _connect_buttons() -> void:
	for i in range(market_buttons.size()):
		market_buttons[i].pressed.connect(_open_deal.bind(i))

	$Margin/RootVBox/MarketPanel/MarketBox/RefreshButton.pressed.connect(_refresh_market)
	$Margin/RootVBox/MarketPanel/MarketBox/ResetButton.pressed.connect(_reset_save)

	buy_full_button.pressed.connect(_buy_current_price)
	quick_offer_button.pressed.connect(_bargain.bind("quick"))
	condition_button.pressed.connect(_bargain.bind("condition"))
	soft_offer_button.pressed.connect(_bargain.bind("soft"))
	$Margin/RootVBox/DealPanel/DealBox/BackMarketButton.pressed.connect(_return_to_market)

	$Margin/RootVBox/AppraisalPanel/AppraisalBox/AppraiseButton.pressed.connect(_appraise)
	for i in range(buyer_buttons.size()):
		buyer_buttons[i].pressed.connect(_sell_to_buyer.bind(i))
	$Margin/RootVBox/ResultPanel/ResultBox/NextButton.pressed.connect(_next_round)


func _refresh_market(save_after: bool = true) -> void:
	market_items = engine.generate_market(3)
	selected_item = {}
	negotiation_state = {}
	purchased_price = 0
	appraisal_data = {}
	buyer_offers = []
	current_stage = "market"
	_render_market()
	_show_panel(market_panel)
	_set_status("새 매물 3개가 올라왔습니다. 가격보다 단서와 판매자 성격을 먼저 비교해보세요.")
	if save_after:
		_save_game()


func _render_market() -> void:
	for i in range(min(3, market_items.size())):
		var listing: Dictionary = market_items[i]
		var seller: Dictionary = listing["seller"]
		var personality: Dictionary = seller["personality"]
		var clues: Array = listing["public_clues"]
		var clue_a = str(clues[0]["text"]) if clues.size() > 0 else "단서 없음"
		var clue_b = str(clues[1]["text"]) if clues.size() > 1 else ""
		market_buttons[i].text = "%s · %sG\n%s · %s\n• %s\n• %s" % [
			listing["name"],
			_money(int(listing["asking"])),
			seller["name"],
			personality["name"],
			clue_a,
			clue_b
		]


func _open_deal(index: int) -> void:
	if index < 0 or index >= market_items.size():
		return

	selected_item = market_items[index].duplicate(true)
	negotiation_state = engine.start_negotiation(selected_item)
	purchased_price = 0
	appraisal_data = {}
	buyer_offers = []
	current_stage = "deal"

	_render_deal()
	_show_panel(deal_panel)
	_set_status("판매자 성격과 공개 단서를 보고 흥정 방식을 고르세요. 흥정 기회는 최대 3번입니다.")
	_save_game()


func _render_deal() -> void:
	if selected_item.is_empty() or negotiation_state.is_empty():
		return

	var seller: Dictionary = selected_item["seller"]
	var personality: Dictionary = seller["personality"]
	var clues: Array = selected_item["public_clues"]
	var clue_lines = ""
	for clue in clues:
		clue_lines += "• [%s] %s\n" % [clue["kind"], clue["text"]]

	deal_title.text = str(selected_item["name"])
	seller_label.text = "판매자: %s · %s\n%s" % [
		seller["name"],
		personality["name"],
		personality["summary"]
	]
	deal_info.text = "최초 희망가 %sG\n\n공개 단서\n%s" % [
		_money(int(selected_item["asking"])),
		clue_lines.strip_edges()
	]

	var current_price = int(negotiation_state["current_price"])
	var rounds = int(negotiation_state["rounds"])
	var max_rounds = int(negotiation_state["max_rounds"])
	var patience = int(negotiation_state["patience"])
	negotiation_state_label.text = "현재가 %sG · 흥정 %d/%d · 인내도 %d" % [
		_money(current_price), rounds, max_rounds, patience
	]

	buy_full_button.text = "현재가 %sG에 구매" % _money(current_price)
	buy_full_button.disabled = gold < current_price

	var closed = bool(negotiation_state.get("closed", false))
	quick_offer_button.disabled = closed
	condition_button.disabled = closed
	soft_offer_button.disabled = closed

	quick_offer_button.text = "“지금 바로 살게요. 더 깎아주세요.”"
	condition_button.text = "“상태가 생각보다 별로인데요?”"
	soft_offer_button.text = "“조금만 더 맞춰주세요.”"


func _bargain(action: String) -> void:
	if selected_item.is_empty() or negotiation_state.is_empty():
		return

	var result: Dictionary = engine.negotiate(selected_item, negotiation_state, action)
	negotiation_state = result["state"]
	seller_speech.text = str(result["speech"])
	_set_status(str(result["status"]))

	var accepted_price = int(result.get("accepted_price", 0))
	if accepted_price > 0:
		_complete_purchase(accepted_price)
		return

	_render_deal()
	_save_game()


func _buy_current_price() -> void:
	if negotiation_state.is_empty():
		return
	_complete_purchase(int(negotiation_state["current_price"]))


func _complete_purchase(price: int) -> void:
	if selected_item.is_empty():
		return
	if gold < price:
		seller_speech.text = "“돈부터 챙겨와. 외상은 안 받아.”"
		_set_status("보유 골드가 부족합니다. 다른 매물을 살펴보세요.")
		return

	gold -= price
	purchased_price = price
	current_stage = "appraisal"
	_update_header()

	var clue_lines = ""
	for clue in selected_item["public_clues"]:
		clue_lines += "• [%s] %s\n" % [clue["kind"], clue["text"]]

	mystery_label.text = "%s\n\n구매가 %sG\n\n구매 전에 본 단서\n%s\n\n이제 감정하면 이 단서들이 무엇을 뜻했는지 확인됩니다." % [
		selected_item["name"],
		_money(purchased_price),
		clue_lines.strip_edges()
	]

	_show_panel(appraisal_panel)
	_set_status("구매 완료. 감정 결과는 이미 생성된 숨은 상태를 공개할 뿐, 여기서 다시 랜덤으로 정해지지 않습니다.")
	_save_game()


func _appraise() -> void:
	if selected_item.is_empty() or purchased_price <= 0:
		return

	appraisal_data = engine.appraise(selected_item)
	buyer_offers = engine.make_buyer_offers(selected_item)
	current_stage = "sale"

	if str(appraisal_data["rarity"]) in ["희귀", "영웅", "전설"]:
		var discovery = "%s · %s" % [selected_item["name"], appraisal_data["rarity"]]
		if not rare_items.has(discovery):
			rare_items.append(discovery)

	_render_sale()
	_update_header()
	_show_panel(sale_panel)
	_set_status("감정 완료. 구매자마다 선호 속성이 달라 제안가가 다릅니다. 누구에게 팔지 선택하세요.")
	_save_game()


func _render_sale() -> void:
	if appraisal_data.is_empty():
		return

	var feature_lines = ""
	for feature in appraisal_data["features"]:
		feature_lines += "• %s\n" % feature

	var feedback_lines = ""
	for feedback in appraisal_data["clue_feedback"]:
		feedback_lines += "• %s\n" % feedback

	appraisal_result.text = "%s\n%s · %s · %s\n최종 추정 가치 %sG\n\n발견된 특징\n%s\n단서 해석\n%s" % [
		selected_item["name"],
		appraisal_data["state"],
		appraisal_data["rarity"],
		appraisal_data["condition"],
		_money(int(appraisal_data["value"])),
		feature_lines,
		feedback_lines
	]
	buyer_offer_label.text = "구매자 3명의 성향과 제안가를 비교하세요."

	for i in range(buyer_buttons.size()):
		if i >= buyer_offers.size():
			buyer_buttons[i].visible = false
			continue
		buyer_buttons[i].visible = true
		var offer: Dictionary = buyer_offers[i]
		buyer_buttons[i].text = "%s · %sG\n%s\n%s" % [
			offer["name"],
			_money(int(offer["price"])),
			offer["summary"],
			offer["reason"]
		]


func _sell_to_buyer(index: int) -> void:
	if index < 0 or index >= buyer_offers.size():
		return

	var offer: Dictionary = buyer_offers[index]
	var sale_price = int(offer["price"])
	gold += sale_price
	total_deals += 1
	today_deals += 1

	var profit = sale_price - purchased_price
	if profit > best_profit:
		best_profit = profit
	if profit < worst_loss:
		worst_loss = profit

	_update_header()

	var profit_text = _signed_money(profit)
	result_summary.text = "%s 판매 완료\n\n구매자   %s\n매입가   %sG\n판매가   %sG\n순손익   %s\n\n오늘 %d회 · 누적 %d회\n최고 단일 수익 %s · 최고 손실 %s\n현재 자산 %sG" % [
		selected_item["name"],
		offer["name"],
		_money(purchased_price),
		_money(sale_price),
		profit_text,
		today_deals,
		total_deals,
		_signed_money(best_profit),
		_signed_money(worst_loss),
		_money(gold)
	]

	current_stage = "market"
	_save_game()
	_show_panel(result_panel)

	if profit > 0:
		_set_status("이익 거래입니다. 어떤 단서와 어떤 구매자 성향이 수익을 만들었는지 기억해두세요.")
	else:
		_set_status("손실 거래입니다. 비싼 매물·과장된 주장·부정적 단서를 다음 거래에서 더 경계해보세요.")


func _next_round() -> void:
	_refresh_market()


func _return_to_market() -> void:
	selected_item = {}
	negotiation_state = {}
	current_stage = "market"
	_render_market()
	_show_panel(market_panel)
	_set_status("거래를 포기했습니다. 포기도 판단입니다. 다른 매물의 단서를 비교해보세요.")
	_save_game()


func _restore_stage() -> void:
	if current_stage == "deal" and not selected_item.is_empty() and not negotiation_state.is_empty():
		_render_deal()
		_show_panel(deal_panel)
		_set_status("중단했던 흥정을 이어갑니다.")
	elif current_stage == "appraisal" and not selected_item.is_empty() and purchased_price > 0:
		var clue_lines = ""
		for clue in selected_item["public_clues"]:
			clue_lines += "• [%s] %s\n" % [clue["kind"], clue["text"]]
		mystery_label.text = "%s\n\n구매가 %sG\n\n구매 전에 본 단서\n%s" % [
			selected_item["name"], _money(purchased_price), clue_lines.strip_edges()
		]
		_show_panel(appraisal_panel)
		_set_status("구매한 물건이 저장되어 있습니다. 감정을 계속하세요.")
	elif current_stage == "sale" and not appraisal_data.is_empty() and buyer_offers.size() >= 3:
		_render_sale()
		_show_panel(sale_panel)
		_set_status("감정 결과와 구매자 제안이 저장되어 있습니다. 판매 대상을 선택하세요.")
	else:
		current_stage = "market"
		_render_market()
		_show_panel(market_panel)
		_set_status("매물 3개를 비교하세요. 같은 이름의 물건도 진위·상태·희귀도가 매번 달라질 수 있습니다.")


func _reset_save() -> void:
	gold = STARTING_GOLD
	total_deals = 0
	today_deals = 0
	today_date = Time.get_date_string_from_system()
	best_profit = 0
	worst_loss = 0
	rare_items = []
	market_items = []
	selected_item = {}
	negotiation_state = {}
	purchased_price = 0
	appraisal_data = {}
	buyer_offers = []
	current_stage = "market"
	_update_header()
	_refresh_market(false)
	_save_game()
	_set_status("테스트 데이터를 초기화했습니다. 50,000G부터 v0.2 거래를 다시 시작합니다.")


func _roll_daily_counter_if_needed() -> void:
	var now = Time.get_date_string_from_system()
	if today_date != now:
		today_date = now
		today_deals = 0


func _show_panel(target) -> void:
	var panels = [market_panel, deal_panel, appraisal_panel, sale_panel, result_panel]
	for panel in panels:
		panel.visible = panel == target


func _update_header() -> void:
	gold_label.text = "%s G" % _money(gold)
	stats_label.text = "오늘 %d회 · 누적 %d회 · 최고 %s · 최악 %s · 희귀 발견 %d" % [
		today_deals,
		total_deals,
		_signed_money(best_profit),
		_signed_money(worst_loss),
		rare_items.size()
	]


func _set_status(text: String) -> void:
	status_label.text = text


func _save_game() -> void:
	var payload = {
		"version": 2,
		"gold": gold,
		"total_deals": total_deals,
		"today_deals": today_deals,
		"today_date": today_date,
		"best_profit": best_profit,
		"worst_loss": worst_loss,
		"rare_items": rare_items,
		"market_items": market_items,
		"selected_item": selected_item,
		"negotiation_state": negotiation_state,
		"purchased_price": purchased_price,
		"appraisal_data": appraisal_data,
		"buyer_offers": buyer_offers,
		"stage": current_stage
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))


func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		today_date = Time.get_date_string_from_system()
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		today_date = Time.get_date_string_from_system()
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		today_date = Time.get_date_string_from_system()
		return

	gold = int(parsed.get("gold", STARTING_GOLD))
	total_deals = int(parsed.get("total_deals", 0))
	today_deals = int(parsed.get("today_deals", 0))
	today_date = str(parsed.get("today_date", Time.get_date_string_from_system()))
	best_profit = int(parsed.get("best_profit", 0))
	worst_loss = int(parsed.get("worst_loss", 0))
	rare_items = parsed.get("rare_items", [])
	market_items = parsed.get("market_items", [])
	selected_item = parsed.get("selected_item", {})
	negotiation_state = parsed.get("negotiation_state", {})
	purchased_price = int(parsed.get("purchased_price", 0))
	appraisal_data = parsed.get("appraisal_data", {})
	buyer_offers = parsed.get("buyer_offers", [])
	current_stage = str(parsed.get("stage", "market"))


func _signed_money(value: int) -> String:
	if value > 0:
		return "+%sG" % _money(value)
	if value < 0:
		return "-%sG" % _money(abs(value))
	return "0G"


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
