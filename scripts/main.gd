extends Control

const MarketEngine = preload("res://scripts/game_logic.gd")
const Content = preload("res://data/content.gd")

const STARTING_GOLD = 50000
const SAVE_PATH = "user://monster_used_market_save_v021.json"

@onready var gold_label = $Margin/RootVBox/Header/GoldLabel
@onready var stats_label = $Margin/RootVBox/StatsLabel
@onready var status_label = $Margin/RootVBox/StatusPanel/StatusLabel

@onready var market_panel = $Margin/RootVBox/MarketPanel
@onready var inspect_panel = $Margin/RootVBox/InspectPanel
@onready var deal_panel = $Margin/RootVBox/DealPanel
@onready var post_panel = $Margin/RootVBox/PostPurchasePanel
@onready var sale_panel = $Margin/RootVBox/SalePanel
@onready var result_panel = $Margin/RootVBox/ResultPanel

@onready var market_investigation_label = $Margin/RootVBox/MarketPanel/MarketBox/InvestigationLabel
@onready var market_buttons = [
	$Margin/RootVBox/MarketPanel/MarketBox/ItemButton1,
	$Margin/RootVBox/MarketPanel/MarketBox/ItemButton2,
	$Margin/RootVBox/MarketPanel/MarketBox/ItemButton3
]
@onready var refresh_button = $Margin/RootVBox/MarketPanel/MarketBox/RefreshButton

@onready var inspect_title = $Margin/RootVBox/InspectPanel/InspectBox/InspectTitle
@onready var inspect_seller = $Margin/RootVBox/InspectPanel/InspectBox/SellerInfo
@onready var inspect_budget = $Margin/RootVBox/InspectPanel/InspectBox/InspectBudget
@onready var clue_list = $Margin/RootVBox/InspectPanel/InspectBox/ClueList
@onready var inspect_buttons = [
	$Margin/RootVBox/InspectPanel/InspectBox/InspectButton1,
	$Margin/RootVBox/InspectPanel/InspectBox/InspectButton2,
	$Margin/RootVBox/InspectPanel/InspectBox/InspectButton3,
	$Margin/RootVBox/InspectPanel/InspectBox/InspectButton4,
	$Margin/RootVBox/InspectPanel/InspectBox/InspectButton5
]
@onready var authenticity_option = $Margin/RootVBox/InspectPanel/InspectBox/AuthenticityOption
@onready var condition_option = $Margin/RootVBox/InspectPanel/InspectBox/ConditionOption
@onready var value_option = $Margin/RootVBox/InspectPanel/InspectBox/ValueOption

@onready var deal_title = $Margin/RootVBox/DealPanel/DealBox/DealTitle
@onready var deal_seller = $Margin/RootVBox/DealPanel/DealBox/SellerInfo
@onready var deal_state = $Margin/RootVBox/DealPanel/DealBox/DealState
@onready var deal_clues = $Margin/RootVBox/DealPanel/DealBox/DealClues
@onready var evidence_option = $Margin/RootVBox/DealPanel/DealBox/EvidenceOption
@onready var offer_price_label = $Margin/RootVBox/DealPanel/DealBox/OfferPriceLabel
@onready var offer_slider = $Margin/RootVBox/DealPanel/DealBox/OfferSlider
@onready var seller_speech = $Margin/RootVBox/DealPanel/DealBox/SellerSpeech
@onready var buy_current_button = $Margin/RootVBox/DealPanel/DealBox/BuyCurrentButton

@onready var post_title = $Margin/RootVBox/PostPurchasePanel/PostBox/PostTitle
@onready var post_info = $Margin/RootVBox/PostPurchasePanel/PostBox/PostInfo
@onready var post_clues = $Margin/RootVBox/PostPurchasePanel/PostBox/PostClues
@onready var post_state = $Margin/RootVBox/PostPurchasePanel/PostBox/PostState
@onready var post_buttons = [
	$Margin/RootVBox/PostPurchasePanel/PostBox/PostInspectButton1,
	$Margin/RootVBox/PostPurchasePanel/PostBox/PostInspectButton2,
	$Margin/RootVBox/PostPurchasePanel/PostBox/PostInspectButton3
]
@onready var appraisal_button = $Margin/RootVBox/PostPurchasePanel/PostBox/AppraiseButton

@onready var sale_title = $Margin/RootVBox/SalePanel/SaleBox/SaleTitle
@onready var sale_info = $Margin/RootVBox/SalePanel/SaleBox/SaleInfo
@onready var quote_state = $Margin/RootVBox/SalePanel/SaleBox/QuoteState
@onready var buyer_buttons = [
	$Margin/RootVBox/SalePanel/SaleBox/BuyerButton1,
	$Margin/RootVBox/SalePanel/SaleBox/BuyerButton2,
	$Margin/RootVBox/SalePanel/SaleBox/BuyerButton3
]
@onready var quote_button = $Margin/RootVBox/SalePanel/SaleBox/QuoteButton
@onready var sell_button = $Margin/RootVBox/SalePanel/SaleBox/SellButton

@onready var result_summary = $Margin/RootVBox/ResultPanel/ResultBox/ResultScroll/ResultSummary
@onready var next_button = $Margin/RootVBox/ResultPanel/ResultBox/NextButton

var engine = MarketEngine.new()
var evidence_map = []

var gold = STARTING_GOLD
var total_deals = 0
var today_deals = 0
var today_date = ""
var best_profit = 0
var worst_loss = 0
var rare_items = []

var market_items = []
var investigation_remaining = Content.MARKET_INVESTIGATION_BUDGET
var selected_index = -1
var current_stage = "market"

var purchased_price = 0
var inspection_remaining = Content.POST_INSPECTION_BUDGET
var inspection_cost_total = 0
var appraisal_cost = 0
var appraisal_data = {}
var buyer_offers = []
var quote_requests_remaining = Content.QUOTE_REQUEST_BUDGET
var selected_buyer_index = -1
var last_result_text = ""


func _ready() -> void:
	_connect_buttons()
	_setup_options()

	var validation_errors = engine.validate_content()
	for error in validation_errors:
		push_error("v0.2.1 content validation: %s" % error)

	_load_game()
	_roll_daily_counter_if_needed()

	if market_items.size() != 3:
		_create_new_market(false)

	_update_header()
	_restore_stage()


func _connect_buttons() -> void:
	for i in range(market_buttons.size()):
		market_buttons[i].pressed.connect(_open_listing.bind(i))
	for i in range(inspect_buttons.size()):
		inspect_buttons[i].pressed.connect(_investigate.bind(i))
	for i in range(post_buttons.size()):
		post_buttons[i].pressed.connect(_post_inspect.bind(i))
	for i in range(buyer_buttons.size()):
		buyer_buttons[i].pressed.connect(_select_buyer.bind(i))

	refresh_button.pressed.connect(_create_new_market)
	$Margin/RootVBox/MarketPanel/MarketBox/ResetButton.pressed.connect(_reset_save)

	$Margin/RootVBox/InspectPanel/InspectBox/StartDealButton.pressed.connect(_start_deal)
	$Margin/RootVBox/InspectPanel/InspectBox/BackMarketButton.pressed.connect(_back_to_market)
	$Margin/RootVBox/InspectPanel/InspectBox/AbandonButton.pressed.connect(_abandon_listing)

	offer_slider.value_changed.connect(_offer_slider_changed)
	$Margin/RootVBox/DealPanel/DealBox/PresetRow/Preset5Button.pressed.connect(_set_offer_discount.bind(0.05))
	$Margin/RootVBox/DealPanel/DealBox/PresetRow/Preset10Button.pressed.connect(_set_offer_discount.bind(0.10))
	$Margin/RootVBox/DealPanel/DealBox/PresetRow/Preset20Button.pressed.connect(_set_offer_discount.bind(0.20))
	$Margin/RootVBox/DealPanel/DealBox/SubmitOfferButton.pressed.connect(_submit_offer)
	buy_current_button.pressed.connect(_buy_current_price)
	$Margin/RootVBox/DealPanel/DealBox/DealBackButton.pressed.connect(_back_to_market)

	appraisal_button.pressed.connect(_professional_appraise)
	$Margin/RootVBox/PostPurchasePanel/PostBox/SkipAppraiseButton.pressed.connect(_skip_appraisal)

	quote_button.pressed.connect(_request_quote)
	sell_button.pressed.connect(_sell_selected_buyer)

	next_button.pressed.connect(_result_next)


func _setup_options() -> void:
	authenticity_option.clear()
	for label in ["진위 판단 선택", "진품 같음", "애매함", "가짜 같음"]:
		authenticity_option.add_item(label)

	condition_option.clear()
	for label in ["상태 판단 선택", "정상", "결함 의심"]:
		condition_option.add_item(label)

	value_option.clear()
	for label in ["가치 범위 선택", "0~5,000G", "5,000~15,000G", "15,000~30,000G", "30,000G 이상"]:
		value_option.add_item(label)


func _create_new_market(save_after: bool = true) -> void:
	if market_items.size() == 3 and not _market_closed():
		_set_status("남은 매물을 먼저 거래하거나 포기해야 새 장터를 받을 수 있습니다.")
		return

	market_items = engine.generate_market(3)
	investigation_remaining = Content.MARKET_INVESTIGATION_BUDGET
	selected_index = -1
	current_stage = "market"
	_clear_transaction_state()
	_render_market()
	_show_panel(market_panel)
	_set_status("장터 조사 기회 4회를 세 매물에 어떻게 나눠 쓸지 결정하세요.")
	if save_after:
		_save_game()


func _render_market() -> void:
	market_investigation_label.text = "장터 조사 기회 %d / %d" % [
		investigation_remaining,
		Content.MARKET_INVESTIGATION_BUDGET
	]

	for i in range(market_buttons.size()):
		if i >= market_items.size():
			market_buttons[i].visible = false
			continue

		market_buttons[i].visible = true
		var listing: Dictionary = market_items[i]
		var seller: Dictionary = listing["seller"]
		var personality: Dictionary = seller["personality"]
		var initial: Dictionary = listing["initial_clue"]
		var claim: Dictionary = listing["seller_claim"]
		var status = str(listing.get("listing_status", "미확인"))

		market_buttons[i].text = "[%s] %s · %sG\n%s · %s\n눈에 보임: %s\n주장: %s" % [
			status,
			listing["name"],
			_money(int(listing["asking"])),
			seller["name"],
			personality["name"],
			initial["text"],
			claim["text"]
		]
		market_buttons[i].disabled = status in ["포기", "판매 완료", "구매 완료"]

	refresh_button.disabled = not _market_closed()
	refresh_button.text = "새 장터 받기" if _market_closed() else "남은 매물 처리 후 새 장터"


func _open_listing(index: int) -> void:
	if index < 0 or index >= market_items.size():
		return
	var status = str(market_items[index].get("listing_status", "미확인"))
	if status in ["포기", "판매 완료", "구매 완료"]:
		return

	selected_index = index
	current_stage = "inspect"
	_render_inspect()
	_show_panel(inspect_panel)
	_set_status("어떤 정보를 더 확인할지, 또는 지금 가진 정보만으로 판단할지 선택하세요.")
	_save_game()


func _render_inspect() -> void:
	var listing = _current_listing()
	if listing.is_empty():
		_back_to_market()
		return

	var seller: Dictionary = listing["seller"]
	var personality: Dictionary = seller["personality"]
	inspect_title.text = "%s · %sG" % [listing["name"], _money(int(listing["asking"]))]
	inspect_seller.text = "판매자: %s · %s\n%s" % [
		seller["name"], personality["name"], personality["summary"]
	]
	inspect_budget.text = "남은 장터 조사 기회: %d회" % investigation_remaining
	clue_list.text = _format_discovered_clues(listing)

	var options = engine.investigation_options(listing)
	var used: Array = listing.get("inspected_actions", [])
	for i in range(inspect_buttons.size()):
		if i >= options.size():
			inspect_buttons[i].visible = false
			continue
		inspect_buttons[i].visible = true
		var option: Dictionary = options[i]
		inspect_buttons[i].text = "%s%s" % [
			option["label"],
			" · 확인 완료" if used.has(option["id"]) else " · 조사 1회"
		]
		inspect_buttons[i].disabled = investigation_remaining <= 0 or used.has(option["id"])

	_restore_hypothesis_options(listing)


func _investigate(option_index: int) -> void:
	var listing = _current_listing()
	if listing.is_empty() or investigation_remaining <= 0:
		return

	var options = engine.investigation_options(listing)
	if option_index < 0 or option_index >= options.size():
		return
	var action_id = str(options[option_index]["id"])
	var result: Dictionary = engine.investigate(listing, action_id)
	if bool(result["consumed"]):
		investigation_remaining -= 1
		_sync_listing(result["listing"])
		_set_status("조사 결과: %s" % result["message"])
		_render_inspect()
		_save_game()
	else:
		_set_status(str(result["message"]))


func _start_deal() -> void:
	var listing = _current_listing()
	if listing.is_empty():
		return

	if authenticity_option.selected == 0 or condition_option.selected == 0 or value_option.selected == 0:
		_set_status("흥정 전에 진위·상태·예상 가치에 대한 내 판단을 먼저 남겨주세요.")
		return

	listing = engine.save_hypothesis(
		listing,
		authenticity_option.get_item_text(authenticity_option.selected),
		condition_option.get_item_text(condition_option.selected),
		value_option.get_item_text(value_option.selected)
	)
	listing["listing_status"] = "거래 중"

	if not listing.has("negotiation_state") or typeof(listing["negotiation_state"]) != TYPE_DICTIONARY or listing["negotiation_state"].is_empty():
		listing["negotiation_state"] = engine.start_negotiation(listing)

	_sync_listing(listing)
	current_stage = "deal"
	_render_deal()
	_show_panel(deal_panel)
	_set_status("얼마를 부를지 정하고, 필요하면 발견한 단서를 흥정 근거로 사용하세요.")
	_save_game()


func _render_deal() -> void:
	var listing = _current_listing()
	if listing.is_empty():
		_back_to_market()
		return

	var negotiation: Dictionary = listing.get("negotiation_state", engine.start_negotiation(listing))
	var seller: Dictionary = listing["seller"]
	var personality: Dictionary = seller["personality"]
	var current_price = int(negotiation["current_price"])

	deal_title.text = str(listing["name"])
	deal_seller.text = "%s · %s\n%s" % [seller["name"], personality["name"], personality["summary"]]
	deal_state.text = "현재가 %sG · 제안 %d/%d · 인내도 %d" % [
		_money(current_price),
		int(negotiation["rounds"]),
		int(negotiation["max_rounds"]),
		int(negotiation["patience"])
	]
	deal_clues.text = "내가 확인한 정보\n%s" % _format_discovered_clues(listing)

	evidence_option.clear()
	evidence_option.add_item("흥정 근거 없음")
	evidence_map = []
	var evidence_options = engine.negotiation_evidence_options(listing)
	for evidence in evidence_options:
		evidence_option.add_item(str(evidence["label"]))
		evidence_map.append(int(evidence["clue_index"]))

	var minimum = max(100, int(round(float(current_price) * 0.50)))
	offer_slider.min_value = minimum
	offer_slider.max_value = current_price
	offer_slider.step = 50
	var suggested = int(round(float(current_price) * 0.90 / 50.0)) * 50
	offer_slider.value = clamp(suggested, minimum, current_price)
	_update_offer_price_label()

	var closed = bool(negotiation.get("closed", false))
	$Margin/RootVBox/DealPanel/DealBox/SubmitOfferButton.disabled = closed
	offer_slider.editable = not closed
	buy_current_button.disabled = gold < current_price
	buy_current_button.text = "현재가 %sG에 구매" % _money(current_price)

	seller_speech.text = str(negotiation.get("last_speech", "“가격을 불러봐. 근거가 있으면 들어보지.”"))


func _offer_slider_changed(_value: float) -> void:
	_update_offer_price_label()


func _update_offer_price_label() -> void:
	offer_price_label.text = "내 제안가: %sG" % _money(int(round(offer_slider.value)))


func _set_offer_discount(discount: float) -> void:
	var listing = _current_listing()
	if listing.is_empty():
		return
	var negotiation: Dictionary = listing["negotiation_state"]
	var current_price = int(negotiation["current_price"])
	var target = int(round(float(current_price) * (1.0 - discount) / 50.0)) * 50
	offer_slider.value = clamp(target, int(offer_slider.min_value), current_price)


func _submit_offer() -> void:
	var listing = _current_listing()
	if listing.is_empty():
		return
	var negotiation: Dictionary = listing["negotiation_state"]
	var clue_index = -1
	if evidence_option.selected > 0 and evidence_option.selected - 1 < evidence_map.size():
		clue_index = int(evidence_map[evidence_option.selected - 1])

	var result: Dictionary = engine.negotiate_offer(
		listing,
		negotiation,
		int(round(offer_slider.value)),
		clue_index
	)
	var updated_state: Dictionary = result["state"]
	updated_state["last_speech"] = result["speech"]
	updated_state["last_status"] = result["status"]
	listing["negotiation_state"] = updated_state
	_sync_listing(listing)

	if bool(result["accepted"]):
		_complete_purchase(int(result["accepted_price"]))
		return

	_render_deal()
	seller_speech.text = str(result["speech"])
	_set_status(str(result["status"]))
	_save_game()


func _buy_current_price() -> void:
	var listing = _current_listing()
	if listing.is_empty():
		return
	var negotiation: Dictionary = listing["negotiation_state"]
	_complete_purchase(int(negotiation["current_price"]))


func _complete_purchase(price: int) -> void:
	var listing = _current_listing()
	if listing.is_empty():
		return
	if gold < price:
		_set_status("보유 골드가 부족합니다.")
		return

	gold -= price
	purchased_price = price
	inspection_remaining = Content.POST_INSPECTION_BUDGET
	inspection_cost_total = 0
	appraisal_cost = 0
	appraisal_data = {}
	buyer_offers = []
	quote_requests_remaining = Content.QUOTE_REQUEST_BUDGET
	selected_buyer_index = -1

	listing["listing_status"] = "구매 완료"
	listing["purchase_price"] = price
	_sync_listing(listing)

	current_stage = "post_purchase"
	_update_header()
	_render_post_purchase()
	_show_panel(post_panel)
	_set_status("구매는 끝났지만 정답은 아직 모릅니다. 추가 정보에 돈을 쓸지, 바로 팔지 결정하세요.")
	_save_game()


func _render_post_purchase() -> void:
	var listing = _current_listing()
	if listing.is_empty():
		return

	post_title.text = "구매 완료 · %s" % listing["name"]
	post_info.text = "구매가 %sG\n내 예상: %s / %s / %s" % [
		_money(purchased_price),
		listing["hypothesis"].get("authenticity", "-"),
		listing["hypothesis"].get("condition", "-"),
		listing["hypothesis"].get("value_band", "-")
	]
	post_clues.text = "현재까지 확인한 정보\n%s" % _format_discovered_clues(listing)
	post_state.text = "추가 검사 %d/%d회 남음 · 검사비 누적 %sG" % [
		inspection_remaining,
		Content.POST_INSPECTION_BUDGET,
		_money(inspection_cost_total)
	]

	var options = engine.post_inspection_options(listing)
	var used: Array = listing.get("post_inspected_actions", [])
	for i in range(post_buttons.size()):
		var option: Dictionary = options[i]
		post_buttons[i].text = "%s · %sG%s" % [
			option["label"],
			_money(int(option["cost"])),
			" · 완료" if used.has(option["id"]) else ""
		]
		post_buttons[i].disabled = (
			inspection_remaining <= 0
			or used.has(option["id"])
			or gold < int(option["cost"])
		)

	appraisal_button.text = "전문 감정 의뢰 · %sG" % _money(Content.PROFESSIONAL_APPRAISAL_COST)
	appraisal_button.disabled = gold < Content.PROFESSIONAL_APPRAISAL_COST


func _post_inspect(option_index: int) -> void:
	var listing = _current_listing()
	if listing.is_empty() or inspection_remaining <= 0:
		return
	var options = engine.post_inspection_options(listing)
	if option_index < 0 or option_index >= options.size():
		return
	var option: Dictionary = options[option_index]
	var cost = int(option["cost"])
	if gold < cost:
		_set_status("검사 비용이 부족합니다.")
		return

	var result: Dictionary = engine.run_post_inspection(listing, str(option["id"]))
	if not bool(result["consumed"]):
		_set_status(str(result["message"]))
		return

	gold -= int(result["cost"])
	inspection_cost_total += int(result["cost"])
	inspection_remaining -= 1
	_sync_listing(result["listing"])
	_update_header()
	_render_post_purchase()
	_set_status("추가 검사: %s" % result["message"])
	_save_game()


func _professional_appraise() -> void:
	var listing = _current_listing()
	if listing.is_empty():
		return
	if gold < Content.PROFESSIONAL_APPRAISAL_COST:
		_set_status("전문 감정 비용이 부족합니다.")
		return

	gold -= Content.PROFESSIONAL_APPRAISAL_COST
	appraisal_cost = Content.PROFESSIONAL_APPRAISAL_COST
	appraisal_data = engine.appraise(listing)
	_update_header()
	_prepare_sale()
	_set_status("전문 감정으로 정체를 확인했습니다. 이제 누구에게 견적을 물어볼지 결정하세요.")


func _skip_appraisal() -> void:
	appraisal_data = {}
	_prepare_sale()
	_set_status("전문 감정 없이 판매처를 탐색합니다. 현재 단서와 구매자 성향만으로 판단해야 합니다.")


func _prepare_sale() -> void:
	var listing = _current_listing()
	if listing.is_empty():
		return
	if buyer_offers.is_empty():
		buyer_offers = engine.make_buyer_offers(listing)
		quote_requests_remaining = Content.QUOTE_REQUEST_BUDGET
		selected_buyer_index = -1
	current_stage = "sale"
	_render_sale()
	_show_panel(sale_panel)
	_save_game()


func _render_sale() -> void:
	var listing = _current_listing()
	if listing.is_empty():
		return

	sale_title.text = "판매처 탐색 · %s" % listing["name"]
	if appraisal_data.is_empty():
		sale_info.text = "전문 감정 안 함\n현재 단서만으로 어떤 구매자가 이 물건을 높게 볼지 판단하세요."
	else:
		sale_info.text = "감정 결과: %s · %s · %s\n추정 가치 %sG" % [
			appraisal_data["state"],
			appraisal_data["rarity"],
			appraisal_data["condition"],
			_money(int(appraisal_data["value"]))
		]

	quote_state.text = "전문 구매자 견적 요청 %d회 남음 · 고물상은 즉시가 공개" % quote_requests_remaining

	for i in range(buyer_buttons.size()):
		var offer: Dictionary = buyer_offers[i]
		var selected_prefix = "▶ " if i == selected_buyer_index else ""
		if bool(offer["revealed"]):
			buyer_buttons[i].text = "%s%s · %sG\n%s\n%s" % [
				selected_prefix,
				offer["name"],
				_money(int(offer["price"])),
				offer["summary"],
				offer["reason"]
			]
		else:
			buyer_buttons[i].text = "%s%s · 견적 미확인\n%s" % [
				selected_prefix,
				offer["name"],
				offer["summary"]
			]

	var can_quote = false
	var can_sell = false
	if selected_buyer_index >= 0 and selected_buyer_index < buyer_offers.size():
		var selected: Dictionary = buyer_offers[selected_buyer_index]
		can_quote = (
			not bool(selected["revealed"])
			and selected["buyer_id"] != "scrap"
			and quote_requests_remaining > 0
		)
		can_sell = bool(selected["revealed"])
		if can_sell:
			sell_button.text = "%s에게 %sG에 판매" % [
				selected["name"], _money(int(selected["price"]))
			]
		else:
			sell_button.text = "견적 확인 후 판매 가능"
	else:
		sell_button.text = "구매자를 먼저 선택하세요"

	quote_button.disabled = not can_quote
	sell_button.disabled = not can_sell


func _select_buyer(index: int) -> void:
	if index < 0 or index >= buyer_offers.size():
		return
	selected_buyer_index = index
	_render_sale()
	var offer: Dictionary = buyer_offers[index]
	if bool(offer["revealed"]):
		_set_status("%s의 확정 제안은 %sG입니다." % [offer["name"], _money(int(offer["price"]))])
	else:
		_set_status("%s에게 견적을 요청할지 결정하세요. 남은 요청은 %d회입니다." % [offer["name"], quote_requests_remaining])
	_save_game()


func _request_quote() -> void:
	if selected_buyer_index < 0 or selected_buyer_index >= buyer_offers.size():
		return
	var selected: Dictionary = buyer_offers[selected_buyer_index]
	if bool(selected["revealed"]) or selected["buyer_id"] == "scrap":
		return
	if quote_requests_remaining <= 0:
		_set_status("전문 구매자에게 더 이상 견적을 요청할 수 없습니다.")
		return

	buyer_offers = engine.reveal_quote(buyer_offers, selected_buyer_index)
	quote_requests_remaining -= 1
	var revealed: Dictionary = buyer_offers[selected_buyer_index]
	_render_sale()
	_set_status("%s의 확정 견적: %sG" % [revealed["name"], _money(int(revealed["price"]))])
	_save_game()


func _sell_selected_buyer() -> void:
	if selected_buyer_index < 0 or selected_buyer_index >= buyer_offers.size():
		return
	var offer: Dictionary = buyer_offers[selected_buyer_index]
	if not bool(offer["revealed"]):
		return

	var listing = _current_listing()
	var sale_price = int(offer["price"])
	gold += sale_price
	total_deals += 1
	today_deals += 1

	var total_info_cost = inspection_cost_total + appraisal_cost
	var profit = sale_price - purchased_price - total_info_cost
	if profit > best_profit:
		best_profit = profit
	if profit < worst_loss:
		worst_loss = profit

	if str(listing["rarity"]) in ["희귀", "영웅", "전설"]:
		var discovery = "%s · %s" % [listing["name"], listing["rarity"]]
		if not rare_items.has(discovery):
			rare_items.append(discovery)

	listing["listing_status"] = "판매 완료"
	_sync_listing(listing)

	var review_lines = engine.evaluate_hypothesis(listing)
	var review_text = ""
	for line in review_lines:
		review_text += "%s\n" % line

	var analysis = ""
	var discount = int(listing["asking"]) - purchased_price
	if discount > 0:
		analysis += "✓ 최초 희망가에서 %sG 낮춰 구매\n" % _money(discount)
	else:
		analysis += "△ 희망가 그대로 구매\n"

	var negotiation: Dictionary = listing.get("negotiation_state", {})
	var evidence_used: Array = negotiation.get("evidence_used", [])
	if evidence_used.size() > 0:
		analysis += "✓ 조사 단서를 실제 흥정 근거로 사용\n"
	else:
		analysis += "△ 흥정에 조사 단서를 사용하지 않음\n"

	if total_info_cost > 0:
		analysis += "• 추가 정보 비용 %sG 사용\n" % _money(total_info_cost)
	else:
		analysis += "• 추가 정보 비용 없이 위험 감수\n"

	var best_possible = engine.best_offer_price(buyer_offers)
	if sale_price >= best_possible:
		analysis += "✓ 이번 구매자 풀의 최고 제안에 판매\n"
	else:
		analysis += "△ 더 높은 잠재 제안 %sG가 있었음\n" % _money(best_possible)

	analysis += "• 선택 구매자: %s — %s" % [offer["name"], offer["reason"]]

	last_result_text = "%s 거래 완료\n\n실제 정체\n%s · %s · %s\n실제 가치 %sG\n\n내 판단 복기\n%s\n거래 분석\n%s\n\n매입가 %sG\n검사/감정비 %sG\n판매가 %sG\n최종 손익 %s\n현재 자산 %sG" % [
		listing["name"],
		listing["state"],
		listing["rarity"],
		listing["condition"],
		_money(int(listing["actual_value"])),
		review_text,
		analysis,
		_money(purchased_price),
		_money(total_info_cost),
		_money(sale_price),
		_signed_money(profit),
		_money(gold)
	]

	current_stage = "result"
	result_summary.text = last_result_text
	next_button.text = "남은 매물로 돌아가기"
	_update_header()
	_show_panel(result_panel)
	_set_status("결과는 정답지가 아니라 다음 거래를 위한 복기입니다.")
	_save_game()


func _result_next() -> void:
	selected_index = -1
	current_stage = "market"
	_clear_transaction_state()
	_render_market()
	_show_panel(market_panel)
	if _market_closed():
		_set_status("이 장터의 세 매물을 모두 처리했습니다. 새 장터를 받을 수 있습니다.")
	else:
		_set_status("남은 매물은 그대로 있습니다. 남은 조사 기회를 어디에 쓸지 다시 판단하세요.")
	_save_game()


func _back_to_market() -> void:
	if selected_index >= 0 and selected_index < market_items.size():
		var listing: Dictionary = market_items[selected_index]
		if listing["listing_status"] == "거래 중":
			listing["listing_status"] = "조사 중"
			market_items[selected_index] = listing
	selected_index = -1
	current_stage = "market"
	_render_market()
	_show_panel(market_panel)
	_set_status("다른 매물을 비교할 수 있습니다. 사용한 조사 기회는 돌아오지 않습니다.")
	_save_game()


func _abandon_listing() -> void:
	var listing = _current_listing()
	if listing.is_empty():
		return
	listing["listing_status"] = "포기"
	_sync_listing(listing)
	selected_index = -1
	current_stage = "market"
	_render_market()
	_show_panel(market_panel)
	_set_status("이 매물은 포기했습니다. 포기도 거래 판단입니다.")
	_save_game()


func _restore_stage() -> void:
	match current_stage:
		"inspect":
			if _selected_valid():
				_render_inspect()
				_show_panel(inspect_panel)
			else:
				_back_to_market()
		"deal":
			if _selected_valid():
				_render_deal()
				_show_panel(deal_panel)
			else:
				_back_to_market()
		"post_purchase":
			if _selected_valid():
				_render_post_purchase()
				_show_panel(post_panel)
			else:
				_back_to_market()
		"sale":
			if _selected_valid() and buyer_offers.size() == 3:
				_render_sale()
				_show_panel(sale_panel)
			else:
				_back_to_market()
		"result":
			result_summary.text = last_result_text
			_show_panel(result_panel)
		_:
			current_stage = "market"
			_render_market()
			_show_panel(market_panel)
			_set_status("세 매물에 공유되는 조사 기회 4회를 어떻게 쓸지 결정하세요.")


func _restore_hypothesis_options(listing: Dictionary) -> void:
	authenticity_option.select(0)
	condition_option.select(0)
	value_option.select(0)
	var hypothesis: Dictionary = listing.get("hypothesis", {})
	if hypothesis.is_empty():
		return
	_select_option_by_text(authenticity_option, str(hypothesis.get("authenticity", "")))
	_select_option_by_text(condition_option, str(hypothesis.get("condition", "")))
	_select_option_by_text(value_option, str(hypothesis.get("value_band", "")))


func _select_option_by_text(option_button: OptionButton, text_value: String) -> void:
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == text_value:
			option_button.select(i)
			return


func _format_discovered_clues(listing: Dictionary) -> String:
	var result = ""
	var clues: Array = listing.get("discovered_clues", [])
	for clue in clues:
		result += "• [%s] %s\n" % [clue["kind"], clue["text"]]
	return result.strip_edges()


func _current_listing() -> Dictionary:
	if not _selected_valid():
		return {}
	return market_items[selected_index]


func _sync_listing(listing: Dictionary) -> void:
	if _selected_valid():
		market_items[selected_index] = listing


func _selected_valid() -> bool:
	return selected_index >= 0 and selected_index < market_items.size()


func _market_closed() -> bool:
	if market_items.size() != 3:
		return true
	for listing in market_items:
		var status = str(listing.get("listing_status", "미확인"))
		if status not in ["포기", "판매 완료"]:
			return false
	return true


func _clear_transaction_state() -> void:
	purchased_price = 0
	inspection_remaining = Content.POST_INSPECTION_BUDGET
	inspection_cost_total = 0
	appraisal_cost = 0
	appraisal_data = {}
	buyer_offers = []
	quote_requests_remaining = Content.QUOTE_REQUEST_BUDGET
	selected_buyer_index = -1


func _show_panel(target) -> void:
	var panels = [market_panel, inspect_panel, deal_panel, post_panel, sale_panel, result_panel]
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


func _roll_daily_counter_if_needed() -> void:
	var now = Time.get_date_string_from_system()
	if today_date != now:
		today_date = now
		today_deals = 0


func _reset_save() -> void:
	gold = STARTING_GOLD
	total_deals = 0
	today_deals = 0
	today_date = Time.get_date_string_from_system()
	best_profit = 0
	worst_loss = 0
	rare_items = []
	market_items = []
	selected_index = -1
	current_stage = "market"
	last_result_text = ""
	_clear_transaction_state()
	_create_new_market(false)
	_update_header()
	_save_game()
	_set_status("v0.2.1 테스트 데이터를 초기화했습니다. 50,000G부터 다시 시작합니다.")


func _save_game() -> void:
	var payload = {
		"version": 21,
		"gold": gold,
		"total_deals": total_deals,
		"today_deals": today_deals,
		"today_date": today_date,
		"best_profit": best_profit,
		"worst_loss": worst_loss,
		"rare_items": rare_items,
		"market_items": market_items,
		"investigation_remaining": investigation_remaining,
		"selected_index": selected_index,
		"stage": current_stage,
		"purchased_price": purchased_price,
		"inspection_remaining": inspection_remaining,
		"inspection_cost_total": inspection_cost_total,
		"appraisal_cost": appraisal_cost,
		"appraisal_data": appraisal_data,
		"buyer_offers": buyer_offers,
		"quote_requests_remaining": quote_requests_remaining,
		"selected_buyer_index": selected_buyer_index,
		"last_result_text": last_result_text
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))


func _load_game() -> void:
	today_date = Time.get_date_string_from_system()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	gold = int(parsed.get("gold", STARTING_GOLD))
	total_deals = int(parsed.get("total_deals", 0))
	today_deals = int(parsed.get("today_deals", 0))
	today_date = str(parsed.get("today_date", today_date))
	best_profit = int(parsed.get("best_profit", 0))
	worst_loss = int(parsed.get("worst_loss", 0))
	rare_items = parsed.get("rare_items", [])
	market_items = parsed.get("market_items", [])
	investigation_remaining = int(parsed.get("investigation_remaining", Content.MARKET_INVESTIGATION_BUDGET))
	selected_index = int(parsed.get("selected_index", -1))
	current_stage = str(parsed.get("stage", "market"))
	purchased_price = int(parsed.get("purchased_price", 0))
	inspection_remaining = int(parsed.get("inspection_remaining", Content.POST_INSPECTION_BUDGET))
	inspection_cost_total = int(parsed.get("inspection_cost_total", 0))
	appraisal_cost = int(parsed.get("appraisal_cost", 0))
	appraisal_data = parsed.get("appraisal_data", {})
	buyer_offers = parsed.get("buyer_offers", [])
	quote_requests_remaining = int(parsed.get("quote_requests_remaining", Content.QUOTE_REQUEST_BUDGET))
	selected_buyer_index = int(parsed.get("selected_buyer_index", -1))
	last_result_text = str(parsed.get("last_result_text", ""))


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
