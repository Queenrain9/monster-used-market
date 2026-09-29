extends Control

const MarketEngine = preload("res://scripts/game_logic.gd")
const Content = preload("res://data/content.gd")
const HomeFeed = preload("res://scripts/home_feed.gd")

const STARTING_GOLD = 50000
const SAVE_PATH = "user://monster_used_market_save_v022.json"

@onready var gold_label = $Margin/RootVBox/Header/GoldLabel
@onready var inventory_count_label = $Margin/RootVBox/Header/InventoryCount
@onready var stats_label = $Margin/RootVBox/ResultPanel/Scroll/Box/StatsLabel
@onready var status_label = $Margin/RootVBox/StatusPanel/StatusLabel
@onready var market_nav_button = $Margin/RootVBox/NavRow/MarketNavButton
@onready var inventory_nav_button = $Margin/RootVBox/NavRow/InventoryNavButton
@onready var records_nav_button = $Margin/RootVBox/NavRow/RecordsNavButton

@onready var market_panel = $Margin/RootVBox/MarketPanel
@onready var detail_panel = $Margin/RootVBox/DetailPanel
@onready var deal_panel = $Margin/RootVBox/DealPanel
@onready var inventory_panel = $Margin/RootVBox/InventoryPanel
@onready var appraisal_panel = $Margin/RootVBox/AppraisalPanel
@onready var sale_panel = $Margin/RootVBox/SalePanel
@onready var result_panel = $Margin/RootVBox/ResultPanel

@onready var market_scroll = $Margin/RootVBox/MarketPanel/Scroll
@onready var market_info_label = $Margin/RootVBox/MarketPanel/Scroll/Box/MarketState/MarketInfo
@onready var market_cards = [
	$Margin/RootVBox/MarketPanel/Scroll/Box/FeedCards/ListingCard1,
	$Margin/RootVBox/MarketPanel/Scroll/Box/FeedCards/ListingCard2,
	$Margin/RootVBox/MarketPanel/Scroll/Box/FeedCards/ListingCard3
]
@onready var next_market_button = $Margin/RootVBox/MarketPanel/Scroll/Box/NextMarketButton
@onready var next_market_hint = $Margin/RootVBox/MarketPanel/Scroll/Box/NextMarketHint

@onready var detail_title = $Margin/RootVBox/DetailPanel/Scroll/Box/DetailTitle
@onready var detail_seller = $Margin/RootVBox/DetailPanel/Scroll/Box/SellerInfo
@onready var detail_budget = $Margin/RootVBox/DetailPanel/Scroll/Box/DetailBudget
@onready var detail_clues = $Margin/RootVBox/DetailPanel/Scroll/Box/ClueList
@onready var inspect_buttons = [
	$Margin/RootVBox/DetailPanel/Scroll/Box/InspectButton1,
	$Margin/RootVBox/DetailPanel/Scroll/Box/InspectButton2,
	$Margin/RootVBox/DetailPanel/Scroll/Box/InspectButton3,
	$Margin/RootVBox/DetailPanel/Scroll/Box/InspectButton4,
	$Margin/RootVBox/DetailPanel/Scroll/Box/InspectButton5
]
@onready var resale_option = $Margin/RootVBox/DetailPanel/Scroll/Box/ResaleOption
@onready var max_buy_slider = $Margin/RootVBox/DetailPanel/Scroll/Box/MaxBuySlider
@onready var max_buy_label = $Margin/RootVBox/DetailPanel/Scroll/Box/MaxBuyLabel
@onready var suspect_option = $Margin/RootVBox/DetailPanel/Scroll/Box/SuspectOption

@onready var deal_title = $Margin/RootVBox/DealPanel/Scroll/Box/DealTitle
@onready var deal_seller = $Margin/RootVBox/DealPanel/Scroll/Box/SellerInfo
@onready var plan_summary = $Margin/RootVBox/DealPanel/Scroll/Box/PlanSummary
@onready var deal_state = $Margin/RootVBox/DealPanel/Scroll/Box/DealState
@onready var evidence_option = $Margin/RootVBox/DealPanel/Scroll/Box/EvidenceOption
@onready var offer_price_label = $Margin/RootVBox/DealPanel/Scroll/Box/OfferPriceLabel
@onready var offer_slider = $Margin/RootVBox/DealPanel/Scroll/Box/OfferSlider
@onready var seller_speech = $Margin/RootVBox/DealPanel/Scroll/Box/SellerSpeech
@onready var buy_current_button = $Margin/RootVBox/DealPanel/Scroll/Box/BuyCurrentButton

@onready var inventory_list = $Margin/RootVBox/InventoryPanel/Scroll/Box/InventoryList
@onready var inventory_detail = $Margin/RootVBox/InventoryPanel/Scroll/Box/InventoryDetail
@onready var inventory_appraise_button = $Margin/RootVBox/InventoryPanel/Scroll/Box/AppraisePlaceButton
@onready var inventory_sell_button = $Margin/RootVBox/InventoryPanel/Scroll/Box/SalePlaceButton

@onready var appraisal_title = $Margin/RootVBox/AppraisalPanel/Scroll/Box/AppraisalTitle
@onready var appraisal_info = $Margin/RootVBox/AppraisalPanel/Scroll/Box/AppraisalInfo
@onready var appraisal_clues = $Margin/RootVBox/AppraisalPanel/Scroll/Box/AppraisalClues
@onready var appraisal_state = $Margin/RootVBox/AppraisalPanel/Scroll/Box/AppraisalState
@onready var post_buttons = [
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PostInspectButton1,
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PostInspectButton2,
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PostInspectButton3
]
@onready var professional_appraise_button = $Margin/RootVBox/AppraisalPanel/Scroll/Box/ProfessionalAppraiseButton

@onready var sale_title = $Margin/RootVBox/SalePanel/Scroll/Box/SaleTitle
@onready var sale_info = $Margin/RootVBox/SalePanel/Scroll/Box/SaleInfo
@onready var quote_state = $Margin/RootVBox/SalePanel/Scroll/Box/QuoteState
@onready var buyer_buttons = [
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerButton1,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerButton2,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerButton3,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerButton4
]
@onready var quote_button = $Margin/RootVBox/SalePanel/Scroll/Box/QuoteButton
@onready var sell_button = $Margin/RootVBox/SalePanel/Scroll/Box/SellButton

@onready var result_summary = $Margin/RootVBox/ResultPanel/Scroll/Box/ResultSummary

var engine = MarketEngine.new()
var feed = HomeFeed.new()
var home_scroll_offset = 0
var evidence_map = []
var suspect_map = []

var gold = STARTING_GOLD
var total_deals = 0
var today_deals = 0
var today_date = ""
var best_profit = 0
var worst_loss = 0
var rare_items = []

var market_items = []
var investigation_remaining = Content.MARKET_INVESTIGATION_BUDGET
var selected_market_index = -1
var owned_items = []
var selected_owned_index = -1
var current_stage = "market"
var last_result_text = ""


func _ready() -> void:
	_configure_mobile_ui()
	_connect_buttons()
	_setup_options()
	_load_game()
	_roll_daily_counter_if_needed()

	if market_items.size() != 3:
		_create_new_market(true, false)

	_update_header()
	_restore_stage()
	_save_game()


func _connect_buttons() -> void:
	market_nav_button.pressed.connect(_go_market)
	inventory_nav_button.pressed.connect(_go_inventory)
	records_nav_button.pressed.connect(_go_records)

	for i in range(market_cards.size()):
		market_cards[i].opened.connect(_open_listing.bind(i))
	for i in range(inspect_buttons.size()):
		inspect_buttons[i].pressed.connect(_investigate.bind(i))
	for i in range(post_buttons.size()):
		post_buttons[i].pressed.connect(_post_inspect.bind(i))
	for i in range(buyer_buttons.size()):
		buyer_buttons[i].pressed.connect(_select_buyer.bind(i))

	next_market_button.pressed.connect(_request_next_market)
	$Margin/RootVBox/ResultPanel/Scroll/Box/ResetButton.pressed.connect(_confirm_reset_save)
	$ResetConfirmation.confirmed.connect(_reset_save)

	max_buy_slider.value_changed.connect(_max_buy_changed)
	$Margin/RootVBox/DetailPanel/Scroll/Box/StartDealButton.pressed.connect(_start_deal)
	$Margin/RootVBox/DetailPanel/Scroll/Box/BackMarketButton.pressed.connect(_go_market)

	offer_slider.value_changed.connect(_offer_slider_changed)
	$Margin/RootVBox/DealPanel/Scroll/Box/PresetRow/Preset5Button.pressed.connect(_set_offer_discount.bind(0.05))
	$Margin/RootVBox/DealPanel/Scroll/Box/PresetRow/Preset10Button.pressed.connect(_set_offer_discount.bind(0.10))
	$Margin/RootVBox/DealPanel/Scroll/Box/PresetRow/Preset20Button.pressed.connect(_set_offer_discount.bind(0.20))
	$Margin/RootVBox/DealPanel/Scroll/Box/SubmitOfferButton.pressed.connect(_submit_offer)
	buy_current_button.pressed.connect(_buy_current_price)
	$Margin/RootVBox/DealPanel/Scroll/Box/DealBackButton.pressed.connect(_go_market)

	inventory_list.item_selected.connect(_inventory_selected)
	inventory_appraise_button.pressed.connect(_open_appraisal)
	inventory_sell_button.pressed.connect(_open_sale)
	$Margin/RootVBox/InventoryPanel/Scroll/Box/KeepButton.pressed.connect(_keep_item)
	$Margin/RootVBox/InventoryPanel/Scroll/Box/InventoryMarketButton.pressed.connect(_go_market)

	professional_appraise_button.pressed.connect(_professional_appraise)
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/AppraisalInventoryButton.pressed.connect(_go_inventory)
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/AppraisalSaleButton.pressed.connect(_open_sale)

	quote_button.pressed.connect(_request_quote)
	sell_button.pressed.connect(_sell_selected_buyer)
	$Margin/RootVBox/SalePanel/Scroll/Box/SaleInventoryButton.pressed.connect(_go_inventory)

	$Margin/RootVBox/ResultPanel/Scroll/Box/ResultMarketButton.pressed.connect(_go_market)
	$Margin/RootVBox/ResultPanel/Scroll/Box/ResultInventoryButton.pressed.connect(_go_inventory)


func _setup_options() -> void:
	resale_option.clear()
	for label in ["예상 재판매가 선택", "0~5,000G", "5,000~15,000G", "15,000~30,000G", "30,000G 이상"]:
		resale_option.add_item(label)


func _create_new_market(force: bool = false, save_after: bool = true) -> void:
	if not force and market_items.size() == 3 and not _can_rotate_market():
		_set_status("새 매물로 넘기려면 조사 기회를 모두 쓰거나, 이 장터에서 실제 구매를 한 번 진행해야 합니다.")
		return

	market_items = engine.generate_market(3)
	home_scroll_offset = 0
	market_scroll.scroll_vertical = 0
	investigation_remaining = Content.MARKET_INVESTIGATION_BUDGET
	selected_market_index = -1
	current_stage = "market"
	_render_market()
	_show_panel(market_panel)
	_set_status("매물들을 둘러보고, 자세히 확인할 정보 4회를 어디에 쓸지 정하세요.")
	if save_after:
		_save_game()


func _request_next_market() -> void:
	_create_new_market(false, true)


func _can_rotate_market() -> bool:
	if investigation_remaining <= 0:
		return true
	for listing in market_items:
		if str(listing.get("listing_status", "")) in ["구매 완료", "판매 완료"]:
			return true
	return false


func _render_market() -> void:
	var available_count = 0
	var new_count = 0
	var featured_index = feed.choose_featured_index(market_items)
	for i in range(market_cards.size()):
		market_cards[i].visible = i < market_items.size()
		if i >= market_items.size():
			continue
		var listing: Dictionary = market_items[i]
		var data = feed.describe_listing(listing, i == featured_index)
		market_cards[i].render(data)
		if bool(data["available"]):
			available_count += 1
			if not bool(listing.get("viewed", false)) and listing.get("inspected_actions", []).is_empty():
				new_count += 1

	market_info_label.text = "새 매물 %d · 거래 가능 %d\n더 자세히 확인 가능 %d회" % [new_count, available_count, investigation_remaining]
	next_market_button.disabled = not _can_rotate_market()
	next_market_button.text = "다음 장터 보기"
	if not _can_rotate_market():
		next_market_hint.text = "남은 확인 기회를 모두 쓰거나 구매하면 다음 장터가 열립니다."
	elif investigation_remaining <= 0:
		next_market_hint.text = "확인 기회를 모두 썼어요. 다음 장터의 새 매물을 둘러볼 수 있습니다."
	else:
		next_market_hint.text = "이 장터에서 물건을 구매했어요. 다음 장터도 둘러볼 수 있습니다."


func _remember_home_position() -> void:
	if current_stage == "market":
		home_scroll_offset = market_scroll.scroll_vertical


func _restore_home_position() -> void:
	# Wait for the previously hidden container to finish its layout before clamping.
	await get_tree().process_frame
	await get_tree().process_frame
	if current_stage == "market":
		market_scroll.scroll_vertical = home_scroll_offset


func _open_listing(index: int) -> void:
	if index < 0 or index >= market_items.size():
		return
	if str(market_items[index].get("listing_status", "")) in ["구매 완료", "판매 완료"]:
		return
	_remember_home_position()
	market_items[index]["viewed"] = true
	selected_market_index = index
	$Margin/RootVBox/DetailPanel/Scroll.scroll_vertical = 0
	current_stage = "detail"
	_render_detail()
	_show_panel(detail_panel)
	_set_status("필요한 정보만 더 확인하고, 이 물건을 얼마에 되팔 수 있을지 거래 계획을 세워보세요.")
	_save_game()


func _render_detail() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		_go_market()
		return

	var seller: Dictionary = listing["seller"]
	var personality: Dictionary = seller["personality"]
	detail_title.text = "%s\n희망가 %sG" % [listing["name"], _money(int(listing["asking"]))]
	detail_seller.text = "판매자 %s · %s\n%s\n판매자 주장: %s" % [
		seller["name"], personality["name"], personality["summary"], listing["seller_claim"]["text"]
	]
	detail_budget.text = "더 자세히 확인할 수 있는 정보: %d회" % investigation_remaining
	detail_clues.text = "지금까지 확인한 정보\n%s" % _format_discovered_clues(listing)

	var options = engine.investigation_options(listing)
	var used: Array = listing.get("inspected_actions", [])
	for i in range(inspect_buttons.size()):
		var option: Dictionary = options[i]
		inspect_buttons[i].text = "%s%s" % [option["label"], " · 확인 완료" if used.has(option["id"]) else ""]
		inspect_buttons[i].disabled = investigation_remaining <= 0 or used.has(option["id"])

	_populate_suspect_options(listing)
	_restore_trade_plan(listing)


func _populate_suspect_options(listing: Dictionary) -> void:
	suspect_option.clear()
	suspect_option.add_item("가장 의심되는 부분 · 선택 안 함")
	suspect_map = []
	var clues: Array = listing.get("discovered_clues", [])
	for clue in clues:
		if clue["kind"] == "판매자 주장":
			continue
		_add_clue_option(suspect_option, "[%s] %s" % [clue["kind"], clue["text"]])
		suspect_map.append(str(clue["text"]))


func _restore_trade_plan(listing: Dictionary) -> void:
	var plan: Dictionary = listing.get("trade_plan", {})
	resale_option.select(0)
	if not plan.is_empty():
		_select_option_by_text(resale_option, str(plan.get("value_band", "")))

	var asking = int(listing["asking"])
	max_buy_slider.min_value = max(100, int(round(float(asking) * 0.45 / 50.0)) * 50)
	max_buy_slider.max_value = asking
	max_buy_slider.step = 50
	var initial = int(round(float(asking) * 0.85 / 50.0)) * 50
	if not plan.is_empty():
		initial = int(plan.get("max_buy_price", initial))
	max_buy_slider.value = clamp(initial, int(max_buy_slider.min_value), asking)
	_update_max_buy_label()

	if not plan.is_empty():
		var suspect_text = str(plan.get("suspect_text", ""))
		for i in range(suspect_map.size()):
			if suspect_map[i] == suspect_text:
				suspect_option.select(i + 1)
				break


func _max_buy_changed(_value: float) -> void:
	_update_max_buy_label()


func _update_max_buy_label() -> void:
	max_buy_label.text = "내 최대 매입가: %sG" % _money(int(round(max_buy_slider.value)))


func _investigate(option_index: int) -> void:
	var listing = _current_market_listing()
	if listing.is_empty() or investigation_remaining <= 0:
		return
	var options = engine.investigation_options(listing)
	var result: Dictionary = engine.investigate(listing, str(options[option_index]["id"]))
	if bool(result["consumed"]):
		investigation_remaining -= 1
		_sync_market_listing(result["listing"])
		_render_detail()
		_set_status("확인 결과: %s" % result["message"])
		_save_game()


func _start_deal() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		return
	if resale_option.selected == 0:
		_set_status("먼저 이 물건을 어느 정도에 되팔 수 있을지 예상해보세요.")
		return

	var suspect_text = ""
	if suspect_option.selected > 0 and suspect_option.selected - 1 < suspect_map.size():
		suspect_text = suspect_map[suspect_option.selected - 1]

	listing = engine.save_trade_plan(
		listing,
		resale_option.get_item_text(resale_option.selected),
		int(round(max_buy_slider.value)),
		suspect_text
	)
	listing["listing_status"] = "거래 중"
	if not listing.has("negotiation_state") or listing["negotiation_state"].is_empty():
		listing["negotiation_state"] = engine.start_negotiation(listing)
	_sync_market_listing(listing)

	current_stage = "deal"
	_render_deal()
	_show_panel(deal_panel)
	_set_status("내 매입 상한을 보면서 실제 제안가와 근거를 정하세요.")
	_save_game()


func _render_deal() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		_go_market()
		return
	var negotiation: Dictionary = listing.get("negotiation_state", engine.start_negotiation(listing))
	var seller: Dictionary = listing["seller"]
	var plan: Dictionary = listing.get("trade_plan", {})
	var current_price = int(negotiation["current_price"])

	deal_title.text = "%s · 판매자와 거래" % listing["name"]
	deal_seller.text = "%s · %s" % [seller["name"], seller["personality"]["name"]]
	plan_summary.text = "내 예상 재판매가 %s\n내 최대 매입가 %sG" % [
		plan.get("value_band", "-"), _money(int(plan.get("max_buy_price", 0)))
	]
	deal_state.text = "현재 판매자 가격 %sG · 흥정 %d/%d · 인내도 %d" % [
		_money(current_price), int(negotiation["rounds"]), int(negotiation["max_rounds"]), int(negotiation["patience"])
	]

	evidence_option.clear()
	evidence_option.add_item("흥정 근거 없음")
	evidence_map = []
	var evidence_options = engine.negotiation_evidence_options(listing)
	for evidence in evidence_options:
		_add_clue_option(evidence_option, str(evidence["label"]))
		evidence_map.append(int(evidence["clue_index"]))
	var suspect_text = str(plan.get("suspect_text", ""))
	if not suspect_text.is_empty():
		for i in range(evidence_map.size()):
			var clues: Array = listing.get("discovered_clues", [])
			var clue_index = int(evidence_map[i])
			if clue_index >= 0 and clue_index < clues.size() and str(clues[clue_index]["text"]) == suspect_text:
				evidence_option.select(i + 1)
				break

	var minimum = max(100, int(round(float(current_price) * 0.50)))
	offer_slider.min_value = minimum
	offer_slider.max_value = current_price
	offer_slider.step = 50
	var suggested = int(round(float(current_price) * 0.90 / 50.0)) * 50
	offer_slider.value = clamp(suggested, minimum, current_price)
	_update_offer_price_label()

	var closed = bool(negotiation.get("closed", false))
	$Margin/RootVBox/DealPanel/Scroll/Box/SubmitOfferButton.disabled = closed
	offer_slider.editable = not closed
	buy_current_button.disabled = gold < current_price
	buy_current_button.text = "현재가 %sG에 구매" % _money(current_price)
	seller_speech.text = str(negotiation.get("last_speech", "“가격을 불러봐. 이유가 있으면 들어보지.”"))


func _offer_slider_changed(_value: float) -> void:
	_update_offer_price_label()


func _update_offer_price_label() -> void:
	var price = int(round(offer_slider.value))
	var listing = _current_market_listing()
	var warning = ""
	if not listing.is_empty():
		var plan: Dictionary = listing.get("trade_plan", {})
		if price > int(plan.get("max_buy_price", price)):
			warning = " · 내 매입 상한 초과"
	offer_price_label.text = "내 제안가: %sG%s" % [_money(price), warning]


func _set_offer_discount(discount: float) -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		return
	var current_price = int(listing["negotiation_state"]["current_price"])
	var target = int(round(float(current_price) * (1.0 - discount) / 50.0)) * 50
	offer_slider.value = clamp(target, int(offer_slider.min_value), current_price)


func _submit_offer() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		return
	var clue_index = -1
	if evidence_option.selected > 0 and evidence_option.selected - 1 < evidence_map.size():
		clue_index = int(evidence_map[evidence_option.selected - 1])

	var result: Dictionary = engine.negotiate_offer(
		listing,
		listing["negotiation_state"],
		int(round(offer_slider.value)),
		clue_index
	)
	var updated_state: Dictionary = result["state"]
	updated_state["last_speech"] = result["speech"]
	listing["negotiation_state"] = updated_state
	_sync_market_listing(listing)

	if bool(result["accepted"]):
		_complete_purchase(int(result["accepted_price"]))
		return

	_render_deal()
	_set_status(str(result["status"]))
	_save_game()


func _buy_current_price() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		return
	_complete_purchase(int(listing["negotiation_state"]["current_price"]))


func _complete_purchase(price: int) -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		return
	if gold < price:
		_set_status("보유 골드가 부족합니다.")
		return

	gold -= price
	listing["listing_status"] = "구매 완료"
	listing["purchase_price"] = price
	_sync_market_listing(listing)

	var owned = {
		"owned_id": listing["listing_id"],
		"listing": listing.duplicate(true),
		"purchase_price": price,
		"inspection_remaining": Content.POST_INSPECTION_BUDGET,
		"inspection_cost_total": 0,
		"appraisal_cost": 0,
		"appraisal_data": {},
		"buyer_offers": [],
		"quote_requests_remaining": Content.QUOTE_REQUEST_BUDGET,
		"selected_buyer_index": -1
	}
	owned_items.append(owned)
	selected_owned_index = owned_items.size() - 1
	selected_market_index = -1
	current_stage = "inventory"
	_update_header()
	_render_inventory()
	_show_panel(inventory_panel)
	_set_status("구매한 물건이 보유품에 들어왔습니다. 지금 감정할 수도, 일단 보관하거나 판매처부터 볼 수도 있습니다.")
	_save_game()


func _go_market() -> void:
	_remember_home_position()
	selected_market_index = -1
	current_stage = "market"
	_render_market()
	_show_panel(market_panel)
	_restore_home_position()
	_set_status("다른 물건과 비교하고, 궁금한 매물을 다시 살펴보세요.")
	_save_game()


func _go_inventory() -> void:
	_remember_home_position()
	current_stage = "inventory"
	_render_inventory()
	_show_panel(inventory_panel)
	_set_status("내가 산 물건을 여기서 보관하고, 감정하거나 판매할 수 있습니다.")
	_save_game()


func _go_records() -> void:
	_remember_home_position()
	current_stage = "result"
	_render_records()
	_show_panel(result_panel)
	_set_status("최근 완료한 거래와 지금까지의 손익을 다시 확인할 수 있습니다.")
	_save_game()


func _render_records() -> void:
	_update_header()
	result_summary.text = last_result_text if not last_result_text.is_empty() else "아직 완료한 거래가 없습니다.\n구매한 물건을 판매하면 이곳에서 최근 거래의 손익과 판단을 다시 확인할 수 있습니다."


func _render_inventory() -> void:
	inventory_list.clear()
	for owned in owned_items:
		var listing: Dictionary = owned["listing"]
		var state_text = _owned_state_text(owned)
		var full_text = "%s · 매입 %sG · %s" % [listing["name"], _money(int(owned["purchase_price"])), state_text]
		inventory_list.add_item(_compact_option_text(inventory_list, full_text))
		inventory_list.set_item_tooltip(inventory_list.item_count - 1, full_text)

	if owned_items.is_empty():
		selected_owned_index = -1
		inventory_detail.text = "아직 보유한 물건이 없습니다.\n마켓에서 물건을 구매하면 이곳에 들어옵니다."
		inventory_appraise_button.disabled = true
		inventory_sell_button.disabled = true
		return

	if selected_owned_index < 0 or selected_owned_index >= owned_items.size():
		selected_owned_index = 0
	inventory_list.select(selected_owned_index)
	_render_inventory_detail()


func _inventory_selected(index: int) -> void:
	selected_owned_index = index
	_render_inventory_detail()
	_save_game()


func _render_inventory_detail() -> void:
	var owned = _current_owned()
	if owned.is_empty():
		return
	var listing: Dictionary = owned["listing"]
	var plan: Dictionary = listing.get("trade_plan", {})
	inventory_detail.text = "%s\n상태: %s\n매입가 %sG\n내 예상 재판매가 %s\n내 최대 매입가 %sG\n\n확인한 정보\n%s" % [
		listing["name"],
		_owned_state_text(owned),
		_money(int(owned["purchase_price"])),
		plan.get("value_band", "-"),
		_money(int(plan.get("max_buy_price", 0))),
		_format_discovered_clues(listing)
	]
	inventory_appraise_button.disabled = false
	inventory_sell_button.disabled = false


func _owned_state_text(owned: Dictionary) -> String:
	if not owned.get("appraisal_data", {}).is_empty():
		return "감정 완료"
	var listing: Dictionary = owned["listing"]
	if listing.get("post_inspected_actions", []).size() > 0:
		return "일부 검사"
	return "미감정"


func _keep_item() -> void:
	if _current_owned().is_empty():
		return
	_set_status("보관해두었습니다. 다른 매물을 보거나 나중에 다시 감정·판매할 수 있습니다.")
	_save_game()


func _open_appraisal() -> void:
	if _current_owned().is_empty():
		return
	current_stage = "appraisal"
	_render_appraisal()
	_show_panel(appraisal_panel)
	_set_status("감정소에서는 돈을 써서 불확실성을 줄일 수 있습니다. 모든 검사를 할 필요는 없습니다.")
	_save_game()


func _render_appraisal() -> void:
	var owned = _current_owned()
	if owned.is_empty():
		_go_inventory()
		return
	var listing: Dictionary = owned["listing"]
	var appraisal_data: Dictionary = owned.get("appraisal_data", {})

	appraisal_title.text = "감정소 · %s" % listing["name"]
	appraisal_info.text = "매입가 %sG · 검사비 누적 %sG · 전문 감정비 %sG" % [
		_money(int(owned["purchase_price"])),
		_money(int(owned["inspection_cost_total"])),
		_money(int(owned["appraisal_cost"]))
	]
	appraisal_clues.text = "현재까지 아는 정보\n%s" % _format_discovered_clues(listing)
	appraisal_state.text = "추가 검사 %d회 남음" % int(owned["inspection_remaining"])
	if not appraisal_data.is_empty():
		appraisal_state.text += "\n\n전문 감정 결과: %s · %s · %s · 추정 가치 %sG" % [
			appraisal_data["state"], appraisal_data["rarity"], appraisal_data["condition"], _money(int(appraisal_data["value"]))
		]

	var options = engine.post_inspection_options(listing)
	var used: Array = listing.get("post_inspected_actions", [])
	for i in range(post_buttons.size()):
		var option: Dictionary = options[i]
		post_buttons[i].text = "%s · %sG%s" % [
			option["label"], _money(int(option["cost"])), " · 완료" if used.has(option["id"]) else ""
		]
		post_buttons[i].disabled = int(owned["inspection_remaining"]) <= 0 or used.has(option["id"]) or gold < int(option["cost"])

	professional_appraise_button.text = "전문 감정 · %sG" % _money(Content.PROFESSIONAL_APPRAISAL_COST)
	professional_appraise_button.disabled = not appraisal_data.is_empty() or gold < Content.PROFESSIONAL_APPRAISAL_COST


func _post_inspect(option_index: int) -> void:
	var owned = _current_owned()
	if owned.is_empty() or int(owned["inspection_remaining"]) <= 0:
		return
	var listing: Dictionary = owned["listing"]
	var options = engine.post_inspection_options(listing)
	var option: Dictionary = options[option_index]
	var cost = int(option["cost"])
	if gold < cost:
		return
	var result: Dictionary = engine.run_post_inspection(listing, str(option["id"]))
	if not bool(result["consumed"]):
		return

	gold -= int(result["cost"])
	owned["inspection_remaining"] = int(owned["inspection_remaining"]) - 1
	owned["inspection_cost_total"] = int(owned["inspection_cost_total"]) + int(result["cost"])
	owned["listing"] = result["listing"]
	owned_items[selected_owned_index] = owned
	_update_header()
	_render_appraisal()
	_set_status("검사 결과: %s" % result["message"])
	_save_game()


func _professional_appraise() -> void:
	var owned = _current_owned()
	if owned.is_empty() or gold < Content.PROFESSIONAL_APPRAISAL_COST:
		return
	if not owned.get("appraisal_data", {}).is_empty():
		return
	gold -= Content.PROFESSIONAL_APPRAISAL_COST
	owned["appraisal_cost"] = Content.PROFESSIONAL_APPRAISAL_COST
	owned["appraisal_data"] = engine.appraise(owned["listing"])
	owned_items[selected_owned_index] = owned
	_update_header()
	_render_appraisal()
	_set_status("전문 감정으로 물건 자체의 정체와 추정 가치를 확인했습니다. 판매처 가격은 여전히 직접 알아봐야 합니다.")
	_save_game()


func _open_sale() -> void:
	var owned = _current_owned()
	if owned.is_empty():
		return
	if owned.get("buyer_offers", []).is_empty():
		owned["buyer_offers"] = engine.make_buyer_offers(owned["listing"])
		owned["quote_requests_remaining"] = Content.QUOTE_REQUEST_BUDGET
		owned["selected_buyer_index"] = -1
		owned_items[selected_owned_index] = owned
	current_stage = "sale"
	_render_sale()
	_show_panel(sale_panel)
	_set_status("전문 판매처 3곳 중 견적은 두 곳에만 물어볼 수 있습니다. 고물상 즉시가는 항상 보입니다.")
	_save_game()


func _render_sale() -> void:
	var owned = _current_owned()
	if owned.is_empty():
		_go_inventory()
		return
	var listing: Dictionary = owned["listing"]
	var appraisal_data: Dictionary = owned.get("appraisal_data", {})
	var offers: Array = owned["buyer_offers"]
	var selected_buyer_index = int(owned.get("selected_buyer_index", -1))

	sale_title.text = "재판매 · %s" % listing["name"]
	if appraisal_data.is_empty():
		sale_info.text = "전문 감정 없음 · 지금까지 모은 정보와 판매처 성향으로 판단하세요."
	else:
		sale_info.text = "감정: %s · %s · %s · 추정 가치 %sG" % [
			appraisal_data["state"], appraisal_data["rarity"], appraisal_data["condition"], _money(int(appraisal_data["value"]))
		]
	quote_state.text = "전문 견적 요청 %d회 남음 · 전문 판매처 3곳 + 고물상 즉시가" % int(owned["quote_requests_remaining"])

	for i in range(buyer_buttons.size()):
		var offer: Dictionary = offers[i]
		var prefix = "▶ " if i == selected_buyer_index else ""
		if bool(offer["revealed"]):
			buyer_buttons[i].text = "%s%s · %sG\n%s\n%s" % [
				prefix, offer["name"], _money(int(offer["price"])), offer["summary"], offer["reason"]
			]
		else:
			buyer_buttons[i].text = "%s%s · 견적 미확인\n%s" % [prefix, offer["name"], offer["summary"]]

	var can_quote = false
	var can_sell = false
	if selected_buyer_index >= 0 and selected_buyer_index < offers.size():
		var selected: Dictionary = offers[selected_buyer_index]
		can_quote = not bool(selected["revealed"]) and selected["buyer_id"] != "scrap" and int(owned["quote_requests_remaining"]) > 0
		can_sell = bool(selected["revealed"])
		if can_sell:
			sell_button.text = "%s에게 %sG에 판매" % [selected["name"], _money(int(selected["price"]))]
		else:
			sell_button.text = "견적 확인 후 판매 가능"
	else:
		sell_button.text = "판매처를 먼저 선택하세요"
	quote_button.disabled = not can_quote
	sell_button.disabled = not can_sell


func _select_buyer(index: int) -> void:
	var owned = _current_owned()
	if owned.is_empty():
		return
	owned["selected_buyer_index"] = index
	owned_items[selected_owned_index] = owned
	_render_sale()
	_save_game()


func _request_quote() -> void:
	var owned = _current_owned()
	if owned.is_empty():
		return
	var index = int(owned.get("selected_buyer_index", -1))
	var offers: Array = owned["buyer_offers"]
	if index < 0 or index >= offers.size() or int(owned["quote_requests_remaining"]) <= 0:
		return
	if bool(offers[index]["revealed"]) or offers[index]["buyer_id"] == "scrap":
		return
	owned["buyer_offers"] = engine.reveal_quote(offers, index)
	owned["quote_requests_remaining"] = int(owned["quote_requests_remaining"]) - 1
	owned_items[selected_owned_index] = owned
	_render_sale()
	_set_status("%s의 확정 견적을 확인했습니다." % owned["buyer_offers"][index]["name"])
	_save_game()


func _sell_selected_buyer() -> void:
	var owned = _current_owned()
	if owned.is_empty():
		return
	var index = int(owned.get("selected_buyer_index", -1))
	var offers: Array = owned["buyer_offers"]
	if index < 0 or index >= offers.size():
		return
	var offer: Dictionary = offers[index]
	if not bool(offer["revealed"]):
		return

	var listing: Dictionary = owned["listing"]
	var sale_price = int(offer["price"])
	var purchase_price = int(owned["purchase_price"])
	var info_cost = int(owned["inspection_cost_total"]) + int(owned["appraisal_cost"])
	var profit = sale_price - purchase_price - info_cost

	gold += sale_price
	total_deals += 1
	today_deals += 1
	best_profit = max(best_profit, profit)
	worst_loss = min(worst_loss, profit)

	if str(listing["rarity"]) in ["희귀", "영웅", "전설"]:
		var discovery = "%s · %s" % [listing["name"], listing["rarity"]]
		if not rare_items.has(discovery):
			rare_items.append(discovery)

	_mark_market_listing_sold(str(listing["listing_id"]))

	var plan_feedback = engine.evaluate_trade_plan(listing, purchase_price, sale_price)
	var plan_text = ""
	for line in plan_feedback:
		plan_text += "%s\n" % line

	var negotiation: Dictionary = listing.get("negotiation_state", {})
	var analysis = ""
	var discount = int(listing["asking"]) - purchase_price
	analysis += "✓ 희망가보다 %sG 낮게 구매\n" % _money(discount) if discount > 0 else "△ 희망가 그대로 구매\n"
	analysis += "✓ 발견 단서를 흥정 근거로 사용\n" if negotiation.get("evidence_used", []).size() > 0 else "△ 조사 단서를 흥정에 사용하지 않음\n"
	analysis += "• 정보 비용 %sG\n" % _money(info_cost)
	var best_possible = engine.best_offer_price(offers)
	analysis += "✓ 확인 가능한 최고 제안에 판매\n" if sale_price >= best_possible else "△ 다른 판매처에 더 높은 잠재 제안 %sG가 있었음\n" % _money(best_possible)
	analysis += "• 판매처: %s — %s" % [offer["name"], offer["reason"]]

	last_result_text = "거래 완료 · %s\n\n매입가 %sG\n검사/감정비 %sG\n판매가 %sG\n순이익 %s\n\n내 거래 계획 복기\n%s\n거래 분석\n%s\n\n실제 물건\n%s · %s · %s\n실제 가치 %sG\n\n현재 자산 %sG" % [
		listing["name"], _money(purchase_price), _money(info_cost), _money(sale_price), _signed_money(profit),
		plan_text, analysis,
		listing["state"], listing["rarity"], listing["condition"], _money(int(listing["actual_value"])), _money(gold)
	]

	owned_items.remove_at(selected_owned_index)
	selected_owned_index = -1
	current_stage = "result"
	_render_records()
	_show_panel(result_panel)
	_set_status("거래 기록을 보고 내가 세운 매입 상한과 판매처 판단이 어땠는지 확인하세요.")
	_save_game()


func _mark_market_listing_sold(listing_id: String) -> void:
	for i in range(market_items.size()):
		if str(market_items[i].get("listing_id", "")) == listing_id:
			market_items[i]["listing_status"] = "판매 완료"
			return


func _current_market_listing() -> Dictionary:
	if selected_market_index < 0 or selected_market_index >= market_items.size():
		return {}
	return market_items[selected_market_index]


func _sync_market_listing(listing: Dictionary) -> void:
	if selected_market_index >= 0 and selected_market_index < market_items.size():
		market_items[selected_market_index] = listing


func _current_owned() -> Dictionary:
	if selected_owned_index < 0 or selected_owned_index >= owned_items.size():
		return {}
	return owned_items[selected_owned_index]


func _format_discovered_clues(listing: Dictionary) -> String:
	var text = ""
	for clue in listing.get("discovered_clues", []):
		text += "• [%s] %s\n" % [clue["kind"], clue["text"]]
	return text.strip_edges()


func _select_option_by_text(option_button: OptionButton, text_value: String) -> void:
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == text_value:
			option_button.select(i)
			return


func _show_panel(target) -> void:
	for panel in [market_panel, detail_panel, deal_panel, inventory_panel, appraisal_panel, sale_panel, result_panel]:
		panel.visible = panel == target
	$Margin/RootVBox/StatusPanel.visible = target != market_panel
	market_nav_button.set_pressed_no_signal(current_stage in ["market", "detail", "deal"])
	inventory_nav_button.set_pressed_no_signal(current_stage in ["inventory", "appraisal", "sale"])
	records_nav_button.set_pressed_no_signal(current_stage == "result")


func _update_header() -> void:
	gold_label.text = "%s G" % _money(gold)
	inventory_count_label.text = "보유품 %d" % owned_items.size()
	stats_label.text = "완료 거래 %d회 · 오늘 %d회\n최고 순이익 %s · 최대 손실 %s" % [
		total_deals, today_deals, _signed_money(best_profit), _signed_money(worst_loss)
	]


func _configure_mobile_ui() -> void:
	for label in find_children("*", "Label", true, false):
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for button in find_children("*", "Button", true, false):
		# Godot-owned dialog buttons use intrinsic text widths. Wrapping them
		# reduces their HBox minimum to padding and makes their labels disappear.
		if button.owner == null:
			continue
		if button is OptionButton:
			button.fit_to_longest_item = false
			button.clip_text = true
			button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		else:
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for scroll in find_children("*", "ScrollContainer", true, false):
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inventory_list.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS


func _add_clue_option(option: OptionButton, full_text: String) -> void:
	option.add_item(_compact_option_text(option, full_text))
	option.get_popup().set_item_tooltip(option.item_count - 1, full_text)


func _compact_option_text(control: Control, full_text: String) -> String:
	# PopupMenu items cannot wrap. Keep the full clue in the detail and tooltip,
	# while the selectable label fits both the button and its embedded popup.
	var font = control.get_theme_font("font")
	var font_size = control.get_theme_font_size("font_size")
	var max_width = max(40.0, get_viewport_rect().size.x - 100.0)
	var compact = full_text.replace("\n", " ")
	if font.get_string_size(compact, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= max_width:
		return compact
	while compact.length() > 1 and font.get_string_size(compact + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > max_width:
		compact = compact.left(compact.length() - 1)
	return compact + "…"


func _set_status(text_value: String) -> void:
	status_label.text = text_value


func _roll_daily_counter_if_needed() -> void:
	var now = Time.get_date_string_from_system()
	if today_date != now:
		today_date = now
		today_deals = 0


func _restore_stage() -> void:
	match current_stage:
		"detail":
			if selected_market_index >= 0 and selected_market_index < market_items.size():
				_render_detail()
				_show_panel(detail_panel)
			else:
				_go_market()
		"deal":
			if selected_market_index >= 0 and selected_market_index < market_items.size():
				_render_deal()
				_show_panel(deal_panel)
			else:
				_go_market()
		"inventory":
			_render_inventory()
			_show_panel(inventory_panel)
		"appraisal":
			if not _current_owned().is_empty():
				_render_appraisal()
				_show_panel(appraisal_panel)
			else:
				_go_inventory()
		"sale":
			if not _current_owned().is_empty():
				_render_sale()
				_show_panel(sale_panel)
			else:
				_go_inventory()
		"result":
			_render_records()
			_show_panel(result_panel)
		_:
			_render_market()
			_show_panel(market_panel)
			_restore_home_position()


func _confirm_reset_save() -> void:
	$ResetConfirmation.popup_centered(Vector2i(min(320, int(get_viewport_rect().size.x) - 24), 180))


func _reset_save() -> void:
	gold = STARTING_GOLD
	total_deals = 0
	today_deals = 0
	today_date = Time.get_date_string_from_system()
	best_profit = 0
	worst_loss = 0
	rare_items = []
	owned_items = []
	market_items = []
	selected_market_index = -1
	selected_owned_index = -1
	current_stage = "market"
	last_result_text = ""
	_create_new_market(true, false)
	_update_header()
	_save_game()
	_set_status("새 장터에서 다시 시작합니다.")


func _save_game() -> void:
	var payload = {
		"version": 23,
		"home_scroll_offset": home_scroll_offset,
		"gold": gold,
		"total_deals": total_deals,
		"today_deals": today_deals,
		"today_date": today_date,
		"best_profit": best_profit,
		"worst_loss": worst_loss,
		"rare_items": rare_items,
		"market_items": market_items,
		"investigation_remaining": investigation_remaining,
		"selected_market_index": selected_market_index,
		"owned_items": owned_items,
		"selected_owned_index": selected_owned_index,
		"stage": current_stage,
		"last_result_text": last_result_text
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))


func _load_game() -> void:
	today_date = Time.get_date_string_from_system()
	var load_path = SAVE_PATH
	if not FileAccess.file_exists(load_path):
		# Desktop Godot uses the project title as its default save directory.
		# Xogot can keep user:// in place; keeping the existing filename covers it.
		load_path = OS.get_user_data_dir().get_base_dir().path_join("괴물 중고마켓 MVP v0.2.2").path_join(SAVE_PATH.get_file())
		if not FileAccess.file_exists(load_path):
			return
	var file = FileAccess.open(load_path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	home_scroll_offset = max(0, int(parsed.get("home_scroll_offset", 0)))
	gold = int(parsed.get("gold", STARTING_GOLD))
	total_deals = int(parsed.get("total_deals", 0))
	today_deals = int(parsed.get("today_deals", 0))
	today_date = str(parsed.get("today_date", today_date))
	best_profit = int(parsed.get("best_profit", 0))
	worst_loss = int(parsed.get("worst_loss", 0))
	rare_items = parsed.get("rare_items", [])
	market_items = parsed.get("market_items", [])
	investigation_remaining = int(parsed.get("investigation_remaining", Content.MARKET_INVESTIGATION_BUDGET))
	selected_market_index = int(parsed.get("selected_market_index", -1))
	owned_items = parsed.get("owned_items", [])
	selected_owned_index = int(parsed.get("selected_owned_index", -1))
	current_stage = str(parsed.get("stage", "market"))
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
