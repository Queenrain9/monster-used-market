extends Control

const MarketEngine = preload("res://scripts/game_logic.gd")
const Content = preload("res://data/content.gd")
const Art = preload("res://scripts/art_catalog.gd")
const MarketTheme = preload("res://scripts/market_theme.gd")
const HomeFeed = preload("res://scripts/home_feed.gd")

const STARTING_GOLD = 50000
const SAVE_PATH = "user://monster_used_market_save_v022.json"

@onready var gold_label = $Margin/RootVBox/Header/GoldLabel
@onready var inventory_count_label = $Margin/RootVBox/Header/InventoryCount
@onready var stats_label = $Margin/RootVBox/ResultPanel/Scroll/Box/StatsLabel
@onready var global_header = $Margin/RootVBox/Header
@onready var status_panel = $Margin/RootVBox/StatusPanel
@onready var status_label = $Margin/RootVBox/StatusPanel/StatusLabel
@onready var nav_row = $Margin/RootVBox/NavRow
@onready var market_nav_button = $Margin/RootVBox/NavRow/MarketNavButton
@onready var inventory_nav_button = $Margin/RootVBox/NavRow/InventoryNavButton
@onready var records_nav_button = $Margin/RootVBox/NavRow/RecordsNavButton

@onready var market_panel = $Margin/RootVBox/MarketPanel
@onready var detail_panel = $Margin/RootVBox/DetailPanel
@onready var seller_chat_panel = $Margin/RootVBox/SellerChatPanel
@onready var deal_panel = $Margin/RootVBox/DealPanel
@onready var inventory_panel = $Margin/RootVBox/InventoryPanel
@onready var appraisal_panel = $Margin/RootVBox/AppraisalPanel
@onready var sale_panel = $Margin/RootVBox/SalePanel
@onready var result_panel = $Margin/RootVBox/ResultPanel

@onready var market_scroll = $Margin/RootVBox/MarketPanel/Scroll
@onready var search_input = $Margin/RootVBox/MarketPanel/Scroll/Box/SearchInput
@onready var recommend_tab_button = $Margin/RootVBox/MarketPanel/Scroll/Box/TabRow/RecommendTabButton
@onready var negotiable_tab_button = $Margin/RootVBox/MarketPanel/Scroll/Box/TabRow/NegotiableTabButton
@onready var viewed_tab_button = $Margin/RootVBox/MarketPanel/Scroll/Box/TabRow/ViewedTabButton
@onready var category_tab_button = $Margin/RootVBox/MarketPanel/Scroll/Box/TabRow/CategoryTabButton
@onready var category_buttons = [
	$Margin/RootVBox/MarketPanel/Scroll/Box/CategoryGrid/AllCategoryButton,
	$Margin/RootVBox/MarketPanel/Scroll/Box/CategoryGrid/AccessoryCategoryButton,
	$Margin/RootVBox/MarketPanel/Scroll/Box/CategoryGrid/MaterialCategoryButton,
	$Margin/RootVBox/MarketPanel/Scroll/Box/CategoryGrid/RelicCategoryButton,
	$Margin/RootVBox/MarketPanel/Scroll/Box/CategoryGrid/MagicToolCategoryButton,
	$Margin/RootVBox/MarketPanel/Scroll/Box/CategoryGrid/MiscCategoryButton,
	$Margin/RootVBox/MarketPanel/Scroll/Box/CategoryGrid/OtherCategoryButton
]
@onready var market_info_label = $Margin/RootVBox/MarketPanel/Scroll/Box/MarketBanner/Inset/MarketState/MarketInfo
@onready var market_empty_state = $Margin/RootVBox/MarketPanel/Scroll/Box/EmptyState
@onready var market_cards = [
	$Margin/RootVBox/MarketPanel/Scroll/Box/FeedCards/ListingCard1,
	$Margin/RootVBox/MarketPanel/Scroll/Box/FeedCards/ListingCard2,
	$Margin/RootVBox/MarketPanel/Scroll/Box/FeedCards/ListingCard3
]
@onready var next_market_button = $Margin/RootVBox/MarketPanel/Scroll/Box/NextMarketButton
@onready var next_market_hint = $Margin/RootVBox/MarketPanel/Scroll/Box/NextMarketHint

@onready var detail_title = $Margin/RootVBox/DetailPanel/Scroll/Box/HeroRow/SummaryColumn/DetailTitle
@onready var detail_price = $Margin/RootVBox/DetailPanel/Scroll/Box/HeroRow/SummaryColumn/DetailPrice
@onready var detail_gold_label = $Margin/RootVBox/DetailPanel/Scroll/Box/TopBar/DetailGoldLabel
@onready var detail_tags = $Margin/RootVBox/DetailPanel/Scroll/Box/HeroRow/SummaryColumn/DetailTags
@onready var detail_seller = $Margin/RootVBox/DetailPanel/Scroll/Box/HeroRow/SummaryColumn/SellerInfo
@onready var detail_description = $Margin/RootVBox/DetailPanel/Scroll/Box/HeroRow/SummaryColumn/DescriptionPanel/ItemDescription
@onready var detail_info = $Margin/RootVBox/DetailPanel/Scroll/Box/DetailInfoPanel/DetailInfo
@onready var seller_card_text = $Margin/RootVBox/DetailPanel/Scroll/Box/SellerCard/SellerRow/SellerCardText
@onready var seller_portrait = $Margin/RootVBox/DetailPanel/Scroll/Box/SellerCard/SellerRow/SellerPortrait
@onready var market_price_label = $Margin/RootVBox/DetailPanel/Scroll/Box/MarketPricePanel/PriceBox/MarketPriceLabel
@onready var detail_budget = $Margin/RootVBox/DetailPanel/Scroll/Box/DetailBudget
@onready var open_seller_chat_button = $Margin/RootVBox/DetailPanel/Scroll/Box/OpenSellerChatButton
@onready var detail_memo_title = $Margin/RootVBox/DetailPanel/Scroll/Box/KnownTitle
@onready var detail_clues = $Margin/RootVBox/DetailPanel/Scroll/Box/ClueList
@onready var chat_seller_portrait = $Margin/RootVBox/SellerChatPanel/Root/TopBar/SellerPortrait
@onready var chat_seller_name = $Margin/RootVBox/SellerChatPanel/Root/TopBar/SellerHead/SellerName
@onready var chat_seller_status = $Margin/RootVBox/SellerChatPanel/Root/TopBar/SellerHead/SellerStatus
@onready var chat_gold_label = $Margin/RootVBox/SellerChatPanel/Root/TopBar/GoldLabel
@onready var chat_item_art = $Margin/RootVBox/SellerChatPanel/Root/ItemContext/Row/ItemArt
@onready var chat_item_title = $Margin/RootVBox/SellerChatPanel/Root/ItemContext/Row/Info/ItemTitle
@onready var chat_item_meta = $Margin/RootVBox/SellerChatPanel/Root/ItemContext/Row/Info/ItemMeta
@onready var chat_scroll = $Margin/RootVBox/SellerChatPanel/Root/MessagesPanel/MessagesScroll
@onready var chat_messages = $Margin/RootVBox/SellerChatPanel/Root/MessagesPanel/MessagesScroll/Messages
@onready var chat_choice_hint = $Margin/RootVBox/SellerChatPanel/Root/Composer/ChoiceHint
@onready var inquiry_panel = $Margin/RootVBox/DetailPanel/Scroll/Box/InquiryPanel
@onready var inquiry_title = $Margin/RootVBox/DetailPanel/Scroll/Box/InquiryPanel/Box/InquiryTitle
@onready var inquiry_text = $Margin/RootVBox/DetailPanel/Scroll/Box/InquiryPanel/Box/InquiryText
@onready var inspect_buttons = [
	$Margin/RootVBox/SellerChatPanel/Root/Composer/ReplyGrid/InspectButton1,
	$Margin/RootVBox/SellerChatPanel/Root/Composer/ReplyGrid/InspectButton2,
	$Margin/RootVBox/SellerChatPanel/Root/Composer/ReplyGrid/InspectButton3,
	$Margin/RootVBox/SellerChatPanel/Root/Composer/ReplyGrid/InspectButton4,
	$Margin/RootVBox/SellerChatPanel/Root/Composer/SearchMarketButton
]
@onready var resale_option = $Margin/RootVBox/DetailPanel/Scroll/Box/ResaleOption
@onready var max_buy_slider = $Margin/RootVBox/DetailPanel/Scroll/Box/MaxBuySlider
@onready var max_buy_label = $Margin/RootVBox/DetailPanel/Scroll/Box/MaxBuyLabel
@onready var suspect_option = $Margin/RootVBox/DetailPanel/Scroll/Box/SuspectOption

@onready var deal_gold_label = $Margin/RootVBox/DealPanel/Scroll/Box/TopBar/GoldLabel
@onready var deal_item_art = $Margin/RootVBox/DealPanel/Scroll/Box/ItemSellerSummary/Row/ItemArt
@onready var deal_title = $Margin/RootVBox/DealPanel/Scroll/Box/ItemSellerSummary/Row/Info/DealTitle
@onready var deal_seller = $Margin/RootVBox/DealPanel/Scroll/Box/ItemSellerSummary/Row/Info/SellerInfo
@onready var deal_personality = $Margin/RootVBox/DealPanel/Scroll/Box/ItemSellerSummary/Row/Info/SellerPersonality
@onready var deal_seller_price = $Margin/RootVBox/DealPanel/Scroll/Box/PriceComparison/Box/SellerPrice
@onready var deal_max_buy = $Margin/RootVBox/DealPanel/Scroll/Box/PriceComparison/Box/MaxBuyPrice
@onready var deal_expected_resale = $Margin/RootVBox/DealPanel/Scroll/Box/PriceComparison/Box/ExpectedResale
@onready var deal_price_change = $Margin/RootVBox/DealPanel/Scroll/Box/PriceComparison/Box/PriceChange
@onready var deal_round_label = $Margin/RootVBox/DealPanel/Scroll/Box/NegotiationStatus/Row/RoundLabel
@onready var deal_patience_label = $Margin/RootVBox/DealPanel/Scroll/Box/NegotiationStatus/Row/PatienceLabel
@onready var evidence_option = $Margin/RootVBox/DealPanel/Scroll/Box/EvidenceOption
@onready var offer_price_label = $Margin/RootVBox/DealPanel/Scroll/Box/OfferSection/Box/OfferPriceLabel
@onready var offer_warning_label = $Margin/RootVBox/DealPanel/Scroll/Box/OfferSection/Box/OfferWarning
@onready var offer_slider = $Margin/RootVBox/DealPanel/Scroll/Box/OfferSection/Box/OfferSlider
@onready var deal_submit_button = $Margin/RootVBox/DealPanel/Scroll/Box/SubmitOfferButton
@onready var deal_preset_buttons = [
	$Margin/RootVBox/DealPanel/Scroll/Box/OfferSection/Box/PresetRow/Preset5Button,
	$Margin/RootVBox/DealPanel/Scroll/Box/OfferSection/Box/PresetRow/Preset10Button,
	$Margin/RootVBox/DealPanel/Scroll/Box/OfferSection/Box/PresetRow/Preset20Button
]
@onready var deal_last_action = $Margin/RootVBox/DealPanel/Scroll/Box/SellerResponsePanel/Box/LastAction
@onready var seller_speech = $Margin/RootVBox/DealPanel/Scroll/Box/SellerResponsePanel/Box/SellerSpeech
@onready var deal_purchase_warning = $Margin/RootVBox/DealPanel/Scroll/Box/PurchaseWarning
@onready var buy_current_button = $Margin/RootVBox/DealPanel/Scroll/Box/BottomActions/BuyCurrentButton

@onready var purchase_handoff_panel = $Margin/RootVBox/InventoryPanel/Scroll/Box/PurchaseHandoffPanel
@onready var purchase_handoff_title = $Margin/RootVBox/InventoryPanel/Scroll/Box/PurchaseHandoffPanel/Box/Title
@onready var purchase_handoff_text = $Margin/RootVBox/InventoryPanel/Scroll/Box/PurchaseHandoffPanel/Box/Text
@onready var inventory_list = $Margin/RootVBox/InventoryPanel/Scroll/Box/InventoryList
@onready var inventory_detail = $Margin/RootVBox/InventoryPanel/Scroll/Box/InventoryDetail
@onready var inventory_appraise_button = $Margin/RootVBox/InventoryPanel/Scroll/Box/AppraisePlaceButton
@onready var inventory_sell_button = $Margin/RootVBox/InventoryPanel/Scroll/Box/SalePlaceButton

@onready var appraisal_pre_view = $Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView
@onready var appraisal_result_view = $Margin/RootVBox/AppraisalPanel/Scroll/Box/ResultView
@onready var appraisal_gold_label = $Margin/RootVBox/AppraisalPanel/Scroll/Box/TopBar/GoldLabel
@onready var appraisal_title = $Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/ItemSummary/Row/Info/AppraisalTitle
@onready var appraisal_info = $Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/ItemSummary/Row/Info/AppraisalInfo
@onready var appraisal_clues = $Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/KnownPanel/AppraisalClues
@onready var appraisal_state = $Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/ItemSummary/Row/Info/AppraisalState
@onready var post_buttons = [
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/InspectRow/PostInspectButton1,
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/InspectRow/PostInspectButton2,
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/InspectRow/PostInspectButton3
]
@onready var professional_appraise_button = $Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/ProfessionalAppraiseButton
@onready var appraisal_result_hero = $Margin/RootVBox/AppraisalPanel/Scroll/Box/ResultView/ResultHero/Row/ResultImage
@onready var appraisal_result_summary = $Margin/RootVBox/AppraisalPanel/Scroll/Box/ResultView/ResultHero/Row/SummaryColumn/ResultItemSummary
@onready var appraisal_result_metrics = $Margin/RootVBox/AppraisalPanel/Scroll/Box/ResultView/MetricsPanel/ResultMetrics
@onready var appraisal_comment = $Margin/RootVBox/AppraisalPanel/Scroll/Box/ResultView/CommentPanel/AppraiserComment

@onready var sale_gold_label = $Margin/RootVBox/SalePanel/Scroll/Box/TopBar/GoldLabel
@onready var sale_item_art = $Margin/RootVBox/SalePanel/Scroll/Box/ItemSummary/Row/ItemArt
@onready var sale_title = $Margin/RootVBox/SalePanel/Scroll/Box/ItemSummary/Row/Info/SaleTitle
@onready var sale_info = $Margin/RootVBox/SalePanel/Scroll/Box/ItemSummary/Row/Info/SaleInfo
@onready var quote_state = $Margin/RootVBox/SalePanel/Scroll/Box/QuoteStatePanel/QuoteState
@onready var buyer_buttons = [
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard1/Body/SelectButton,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard2/Body/SelectButton,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard3/Body/SelectButton,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerCard4/Body/SelectButton
]
@onready var buyer_name_labels = [
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard1/Body/NameRow/BuyerName,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard2/Body/NameRow/BuyerName,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard3/Body/NameRow/BuyerName,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerCard4/Body/NameRow/BuyerName
]
@onready var buyer_status_labels = [
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard1/Body/NameRow/Status,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard2/Body/NameRow/Status,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard3/Body/NameRow/Status,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerCard4/Body/NameRow/Status
]
@onready var buyer_summary_labels = [
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard1/Body/Summary,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard2/Body/Summary,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard3/Body/Summary,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerCard4/Body/Summary
]
@onready var buyer_reason_labels = [
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard1/Body/Reason,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard2/Body/Reason,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerList/BuyerCard3/Body/Reason,
	$Margin/RootVBox/SalePanel/Scroll/Box/BuyerCard4/Body/Reason
]
@onready var sale_selected_label = $Margin/RootVBox/SalePanel/Scroll/Box/ActionPanel/Box/SelectedLabel
@onready var quote_button = $Margin/RootVBox/SalePanel/Scroll/Box/ActionPanel/Box/QuoteButton
@onready var sell_button = $Margin/RootVBox/SalePanel/Scroll/Box/ActionPanel/Box/SellButton

@onready var result_summary = $Margin/RootVBox/ResultPanel/Scroll/Box/ResultSummary

var engine = MarketEngine.new()
var feed = HomeFeed.new()
var home_scroll_offset = 0
var home_query = ""
var home_tab = "recommended"
var home_category = "전체"
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
	theme = MarketTheme.build()
	$Backdrop.texture = Art.texture_for("ui", "market")
	$Margin/RootVBox/Header/Brand.texture = Art.texture_for("ui", "brand")
	$Margin/RootVBox/MarketPanel/Scroll/Box/MarketBanner/Art.texture = Art.texture_for("ui", "market")
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/ItemSummary/Row/ItemArt.texture = Art.texture_for("ui", "appraiser")
	_configure_mobile_ui()
	_connect_buttons()
	_setup_options()
	_load_game()
	_restore_home_controls()
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

	search_input.text_changed.connect(_on_home_search_changed)
	recommend_tab_button.pressed.connect(_set_home_tab.bind("recommended"))
	negotiable_tab_button.pressed.connect(_set_home_tab.bind("negotiable"))
	viewed_tab_button.pressed.connect(_set_home_tab.bind("viewed"))
	category_tab_button.pressed.connect(_set_home_tab.bind("category"))
	for button in category_buttons:
		button.pressed.connect(_set_home_category.bind(button.text))

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
	$Margin/RootVBox/DetailPanel/Scroll/Box/TopBar/BackTopButton.pressed.connect(_go_market)
	$Margin/RootVBox/DetailPanel/Scroll/Box/HeroRow/ImageColumn/ImageExpandButton.pressed.connect(_open_image_preview)
	$Margin/RootVBox/DetailPanel/Scroll/Box/ThumbnailRow/Thumb1.pressed.connect(_open_image_preview)
	$Margin/RootVBox/DetailPanel/Scroll/Box/OpenSellerChatButton.pressed.connect(_open_seller_chat)
	$Margin/RootVBox/DetailPanel/Scroll/Box/NegotiationJumpButton.pressed.connect(_jump_to_trade_plan)
	$Margin/RootVBox/SellerChatPanel/Root/TopBar/BackButton.pressed.connect(_back_to_detail)
	$Margin/RootVBox/SellerChatPanel/Root/BackToDetailButton.pressed.connect(_back_to_detail)
	$ImagePreview/Box/CloseButton.pressed.connect(func(): $ImagePreview.hide())

	offer_slider.value_changed.connect(_offer_slider_changed)
	deal_preset_buttons[0].pressed.connect(_set_offer_discount.bind(0.05))
	deal_preset_buttons[1].pressed.connect(_set_offer_discount.bind(0.10))
	deal_preset_buttons[2].pressed.connect(_set_offer_discount.bind(0.20))
	deal_submit_button.pressed.connect(_submit_offer)
	buy_current_button.pressed.connect(_buy_current_price)
	$Margin/RootVBox/DealPanel/Scroll/Box/TopBar/BackButton.pressed.connect(_go_market)
	$Margin/RootVBox/DealPanel/Scroll/Box/BottomActions/DealBackButton.pressed.connect(_go_market)

	inventory_list.item_selected.connect(_inventory_selected)
	inventory_appraise_button.pressed.connect(_open_appraisal)
	inventory_sell_button.pressed.connect(_open_sale)
	$Margin/RootVBox/InventoryPanel/Scroll/Box/KeepButton.pressed.connect(_keep_item)
	$Margin/RootVBox/InventoryPanel/Scroll/Box/InventoryMarketButton.pressed.connect(_go_market)

	professional_appraise_button.pressed.connect(_professional_appraise)
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/TopBar/BackButton.pressed.connect(_go_inventory)
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/SecondaryActions/AppraisalInventoryButton.pressed.connect(_go_inventory)
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/SecondaryActions/AppraisalSaleButton.pressed.connect(_open_sale)
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/ResultView/ResultActions/StoreResultButton.pressed.connect(_go_inventory)
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/ResultView/ResultActions/PrepareResaleButton.pressed.connect(_confirm_prepare_resale)
	$ResaleConfirmation.confirmed.connect(_open_sale)

	quote_button.pressed.connect(_request_quote)
	sell_button.pressed.connect(_sell_selected_buyer)
	$Margin/RootVBox/SalePanel/Scroll/Box/TopBar/BackButton.pressed.connect(_go_inventory)
	$Margin/RootVBox/SalePanel/Scroll/Box/ActionPanel/Box/SaleInventoryButton.pressed.connect(_go_inventory)

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
	home_query = ""
	home_tab = "recommended"
	home_category = "전체"
	if is_instance_valid(search_input):
		search_input.text = ""
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
	var visible_count = 0
	var featured_index = feed.choose_featured_index(market_items)
	for i in range(market_cards.size()):
		market_cards[i].visible = false
		if i >= market_items.size():
			continue
		var listing: Dictionary = market_items[i]
		var data = feed.describe_listing(listing, i == featured_index)
		if bool(data["available"]):
			available_count += 1
			if not bool(listing.get("viewed", false)) and listing.get("inspected_actions", []).is_empty():
				new_count += 1
		if not feed.matches_filter(listing, home_query, home_tab, home_category):
			continue
		market_cards[i].visible = true
		market_cards[i].render(data)
		visible_count += 1

	market_empty_state.visible = visible_count == 0
	market_info_label.text = "새 매물 %d · 거래 가능 %d · 더 자세히 확인 %d회" % [new_count, available_count, investigation_remaining]
	_update_home_filter_controls()
	next_market_button.disabled = not _can_rotate_market()
	next_market_button.text = "다음 장터 보기"
	if not _can_rotate_market():
		next_market_hint.text = "남은 확인 기회를 모두 쓰거나 구매하면 다음 장터가 열립니다."
	elif investigation_remaining <= 0:
		next_market_hint.text = "확인 기회를 모두 썼어요. 다음 장터의 새 매물을 둘러볼 수 있습니다."
	else:
		next_market_hint.text = "이 장터에서 물건을 구매했어요. 다음 장터도 둘러볼 수 있습니다."


func _on_home_search_changed(value: String) -> void:
	home_query = value
	_render_market()


func _set_home_tab(tab_id: String) -> void:
	home_tab = tab_id
	_render_market()
	_save_game()


func _set_home_category(category_id: String) -> void:
	home_category = category_id
	home_tab = "category"
	_render_market()
	_save_game()


func _restore_home_controls() -> void:
	if is_instance_valid(search_input):
		search_input.text = home_query
	_update_home_filter_controls()


func _update_home_filter_controls() -> void:
	recommend_tab_button.set_pressed_no_signal(home_tab == "recommended")
	negotiable_tab_button.set_pressed_no_signal(home_tab == "negotiable")
	viewed_tab_button.set_pressed_no_signal(home_tab == "viewed")
	category_tab_button.set_pressed_no_signal(home_tab == "category")
	for button in category_buttons:
		button.set_pressed_no_signal(home_tab == "category" and button.text == home_category)




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
	_set_status("판매자가 올린 글을 보고 필요한 것만 더 물어보거나 확인한 뒤, 가격을 제안해보세요.")
	_save_game()


func _render_detail() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		_go_market()
		return

	var seller: Dictionary = listing["seller"]
	var item_texture = Art.texture_for("items", str(listing.get("item_id", "")))
	var public_data = feed.describe_listing(listing, false)
	$Margin/RootVBox/DetailPanel/Scroll/Box/HeroRow/ImageColumn/ItemArt.texture = item_texture
	$Margin/RootVBox/DetailPanel/Scroll/Box/ThumbnailRow/Thumb1.icon = item_texture
	$Margin/RootVBox/DetailPanel/Scroll/Box/ThumbnailRow/Thumb1.expand_icon = true
	detail_title.text = Art.item_name(listing)
	detail_price.text = "%sG" % _money(int(listing["asking"]))
	detail_tags.text = public_data["tags_text"]
	detail_seller.text = "%s · %s · %s" % [Art.seller_name(seller), feed.public_location_text(listing), feed.public_age_text(listing)]
	detail_description.text = feed.listing_post_text(listing)
	detail_info.text = "직거래   %s\n올린 지   %s\n가격 제안 가능" % [
		feed.public_meetup_text(listing),
		feed.public_age_text(listing)
	]
	seller_portrait.texture = Art.texture_for("sellers", str(seller.get("id", "")))
	seller_card_text.text = "%s · %s\n%s\n%s\n%s" % [
		Art.seller_name(seller),
		feed.public_location_text(listing),
		feed.seller_activity_text(listing),
		feed.seller_profile_text(listing),
		feed.seller_message_text(listing)
	]
	detail_budget.text = "남은 질문/확인 기회: %d번" % investigation_remaining
	inquiry_panel.visible = false
	var discovered: Array = listing.get("discovered_clues", [])
	detail_memo_title.text = "거래 메모 %d개" % discovered.size()
	if discovered.is_empty():
		detail_clues.text = "아직 메모한 내용이 없습니다."
	else:
		var preview_lines = []
		var start_index = max(0, discovered.size() - 2)
		for i in range(start_index, discovered.size()):
			preview_lines.append("• %s" % str(discovered[i].get("text", "")))
		detail_clues.text = "\n".join(preview_lines)
	var chat_count = listing.get("chat_history", []).size()
	open_seller_chat_button.text = "판매자에게 채팅하기%s" % (" · 대화 %d개" % chat_count if chat_count > 0 else "")
	market_price_label.text = _market_price_reference_text(listing)

	_populate_suspect_options(listing)
	_restore_trade_plan(listing)


func _open_seller_chat() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		return
	current_stage = "chat"
	_render_seller_chat()
	_show_panel(seller_chat_panel)
	_set_status("판매자에게 궁금한 걸 물어보세요.")
	_save_game()


func _back_to_detail() -> void:
	if _current_market_listing().is_empty():
		_go_market()
		return
	current_stage = "detail"
	_render_detail()
	_show_panel(detail_panel)
	$Margin/RootVBox/DetailPanel/Scroll.ensure_control_visible(open_seller_chat_button)
	_save_game()


func _render_seller_chat() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		_go_market()
		return
	var seller: Dictionary = listing.get("seller", {})
	chat_gold_label.text = "%s G" % _money(gold)
	chat_seller_portrait.texture = Art.texture_for("sellers", str(seller.get("id", "")))
	chat_seller_name.text = Art.seller_name(seller)
	chat_seller_status.text = feed.seller_activity_text(listing)
	chat_item_art.texture = Art.texture_for("items", str(listing.get("item_id", "")))
	chat_item_title.text = Art.item_name(listing)
	chat_item_meta.text = "%sG · %s · %s" % [
		_money(int(listing.get("asking", 0))),
		feed.public_location_text(listing),
		feed.public_meetup_text(listing)
	]

	var options = engine.investigation_options(listing)
	var used: Array = listing.get("inspected_actions", [])
	for i in range(inspect_buttons.size()):
		var option: Dictionary = options[i]
		var was_used = used.has(option["id"])
		var exhausted = investigation_remaining <= 0
		var choice_text = feed.investigation_button_text(option)
		if i < 4:
			inspect_buttons[i].text = "보낸 메시지 · %s" % choice_text if was_used else "“%s”" % choice_text
			_apply_chat_reply_style(inspect_buttons[i], was_used or exhausted, false)
		else:
			inspect_buttons[i].text = "시세 확인 완료" if was_used else "직접 조사 · 비슷한 매물 찾아보기"
			_apply_chat_reply_style(inspect_buttons[i], was_used or exhausted, true)
		inspect_buttons[i].tooltip_text = str(option["label"])
		inspect_buttons[i].disabled = exhausted or was_used

	_render_chat_thread(listing)


func _render_chat_thread(listing: Dictionary) -> void:
	var seller: Dictionary = listing.get("seller", {})
	chat_seller_portrait.texture = Art.texture_for("sellers", str(seller.get("id", "")))
	chat_seller_name.text = Art.seller_name(seller)
	chat_seller_status.text = feed.seller_activity_text(listing)
	chat_choice_hint.text = "뭐라고 물어볼까? · 남은 기회 %d번" % investigation_remaining

	for child in chat_messages.get_children():
		chat_messages.remove_child(child)
		child.queue_free()

	_add_chat_message({
		"speaker":"seller",
		"text":feed.seller_message_text(listing).trim_prefix("“").trim_suffix("”")
	}, Art.seller_name(seller))

	for message in listing.get("chat_history", []):
		_add_chat_message(message, Art.seller_name(seller))

	call_deferred("_scroll_chat_to_bottom")


func _chat_bubble_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


func _chat_reply_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(11)
	style.content_margin_left = 12
	style.content_margin_right = 10
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style


func _apply_chat_reply_style(button: Button, muted: bool, search: bool) -> void:
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color("4f5661") if muted else Color("253041"))
	button.add_theme_color_override("font_hover_color", Color("18283d"))
	button.add_theme_color_override("font_pressed_color", Color("18283d"))
	button.add_theme_color_override("font_disabled_color", Color("9aa0a8"))
	if search:
		button.add_theme_stylebox_override("normal", _chat_reply_style(Color("faf7ee"), Color("ddd3b7")))
		button.add_theme_stylebox_override("hover", _chat_reply_style(Color("f6f0df"), Color("cfc09b")))
		button.add_theme_stylebox_override("pressed", _chat_reply_style(Color("f1e8cf"), Color("c0af83")))
	else:
		button.add_theme_stylebox_override("normal", _chat_reply_style(Color("eef5ff"), Color("c7d9ef")))
		button.add_theme_stylebox_override("hover", _chat_reply_style(Color("e5f0ff"), Color("abc7e8")))
		button.add_theme_stylebox_override("pressed", _chat_reply_style(Color("dceaff"), Color("94b7df")))
	button.add_theme_stylebox_override("disabled", _chat_reply_style(Color("f3f4f5"), Color("dde0e4")))


func _add_chat_message(message: Dictionary, seller_name: String) -> void:
	var speaker = str(message.get("speaker", "note"))
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)

	var left_spacer = Control.new()
	var right_spacer = Control.new()
	left_spacer.custom_minimum_size = Vector2(24, 0)
	right_spacer.custom_minimum_size = Vector2(24, 0)

	var bubble = PanelContainer.new()
	bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bubble.clip_contents = true
	if speaker == "buyer":
		bubble.add_theme_stylebox_override("panel", _chat_bubble_style(Color("edf4ff"), Color("c4d9f2")))
	elif speaker == "seller":
		bubble.add_theme_stylebox_override("panel", _chat_bubble_style(Color("f7f7f5"), Color("d9d9d4")))
	else:
		bubble.add_theme_stylebox_override("panel", _chat_bubble_style(Color("faf7ee"), Color("e1d8be")))

	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 2)

	var who = Label.new()
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.add_theme_font_size_override("font_size", 9)
	who.add_theme_color_override("font_color", Color("6b7078"))
	who.clip_text = true
	who.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if speaker == "buyer":
		who.text = "나"
	elif speaker == "seller":
		who.text = seller_name
	else:
		who.text = str(message.get("label", "거래 메모"))

	var body = Label.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size", 10)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.text = str(message.get("text", ""))

	box.add_child(who)
	box.add_child(body)
	bubble.add_child(box)

	if speaker == "buyer":
		row.add_child(left_spacer)
		row.add_child(bubble)
	elif speaker == "note":
		row.add_child(bubble)
	else:
		row.add_child(bubble)
		row.add_child(right_spacer)

	chat_messages.add_child(row)


func _scroll_chat_to_bottom() -> void:
	await get_tree().process_frame
	chat_scroll.scroll_vertical = int(chat_scroll.get_v_scroll_bar().max_value)


func _market_price_reference_text(listing: Dictionary) -> String:
	for clue in listing.get("discovered_clues", []):
		if str(clue.get("kind", "")) == "시세" or str(clue.get("id", "")) == "market_estimate":
			return str(clue.get("text", "시세 정보를 확인했습니다."))
	return "아직 동종품 시세를 확인하지 않았습니다. 확인하면 거래 계획의 참고 자료로 사용할 수 있습니다."


func _open_image_preview() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		return
	$ImagePreview/Box/PreviewImage.texture = Art.texture_for("items", str(listing.get("item_id", "")))
	$ImagePreview.popup_centered(Vector2i(min(350, int(get_viewport_rect().size.x) - 24), 500))


func _jump_to_trade_plan() -> void:
	resale_option.grab_focus()
	$Margin/RootVBox/DetailPanel/Scroll.ensure_control_visible(resale_option)
	_set_status("예상 재판매가와 최대 매입가를 정하면 실제 가격 협상으로 이어집니다.")




func _populate_suspect_options(listing: Dictionary) -> void:
	suspect_option.clear()
	suspect_option.add_item("가장 의심되는 부분 · 선택 안 함")
	suspect_map = []
	var clues: Array = listing.get("discovered_clues", [])
	for clue in clues:
		if clue["kind"] == "판매자 주장":
			continue
		_add_clue_option(suspect_option, str(clue["text"]))
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
	var option: Dictionary = options[option_index]
	var result: Dictionary = engine.investigate(listing, str(option["id"]))
	if bool(result["consumed"]):
		investigation_remaining -= 1
		var updated: Dictionary = result["listing"]
		var history: Array = updated.get("chat_history", []).duplicate(true)
		for message in feed.investigation_chat_messages(listing, option, str(result["message"])):
			history.append(message)
		updated["chat_history"] = history
		# Keep the previous field for old saves/tests, but the player-facing UX now uses the thread.
		updated["last_inquiry"] = feed.investigation_interaction(listing, option, str(result["message"]))
		_sync_market_listing(updated)
		_render_seller_chat()
		_set_status("판매자와 대화를 이어갔습니다.")
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
	_set_status("내 기준 가격과 확인한 내용을 바탕으로 판매자에게 보낼 가격을 정하세요.")
	_save_game()


func _render_deal() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		_go_market()
		return

	var negotiation: Dictionary = listing.get("negotiation_state", engine.start_negotiation(listing))
	var seller: Dictionary = listing["seller"]
	var personality: Dictionary = seller["personality"]
	var plan: Dictionary = listing.get("trade_plan", {})
	var current_price = int(negotiation["current_price"])
	var max_buy_price = int(plan.get("max_buy_price", 0))
	var rounds = int(negotiation["rounds"])
	var max_rounds = int(negotiation["max_rounds"])
	var patience = int(negotiation["patience"])
	var initial_patience = max(1, int(personality.get("patience", patience)))

	deal_gold_label.text = "%s G" % _money(gold)
	deal_item_art.texture = Art.texture_for("items", str(listing.get("item_id", "")))
	deal_title.text = Art.item_name(listing)
	deal_seller.text = "%s · %s" % [Art.seller_name(seller), feed.public_location_text(listing)]
	deal_personality.text = "직거래 · %s\n%s\n%s" % [
		feed.public_meetup_text(listing),
		feed.seller_activity_text(listing),
		feed.seller_message_text(listing)
	]
	deal_personality.tooltip_text = "판매자의 실제 말과 행동을 보고 거래 성향을 직접 판단하세요."

	deal_seller_price.text = ("%s  %sG" % ["판매자가 올린 가격" if rounds <= 0 else "현재 판매자 가격", _money(current_price)])
	deal_max_buy.text = "내 최대 매입가  %sG" % _money(max_buy_price)
	deal_expected_resale.text = "예상 재판매가   %s" % str(plan.get("value_band", "-"))

	var previous_price = int(negotiation.get("previous_price", current_price))
	var last_offer = int(negotiation.get("last_offer", 0))
	var last_evidence = str(negotiation.get("last_evidence_text", ""))
	var last_status = str(negotiation.get("last_status", ""))
	if rounds <= 0:
		deal_price_change.text = "아직 제안 전 · 판매자 가격을 기준으로 첫 제안을 정하세요."
		deal_last_action.text = "아직 제안하지 않았습니다."
	else:
		if previous_price != current_price:
			deal_price_change.text = "판매자 가격  %sG → %sG" % [_money(previous_price), _money(current_price)]
		else:
			deal_price_change.text = "판매자 가격  %sG · 유지" % _money(current_price)
		var evidence_text = "근거 없음" if last_evidence.is_empty() else last_evidence
		deal_last_action.text = "직전 제안 %sG · %s\n사용 근거: %s" % [_money(last_offer), last_status, evidence_text]

	deal_round_label.text = "협상 %d / %d" % [rounds, max_rounds]
	var filled = clamp(patience, 0, initial_patience)
	var patience_dots = "●".repeat(filled) + "○".repeat(max(0, initial_patience - filled))
	deal_patience_label.text = "인내 %s" % patience_dots

	evidence_option.clear()
	evidence_option.add_item("근거 없이 가격만 제안")
	evidence_map = []
	var evidence_options = engine.negotiation_evidence_options(listing)
	var used_evidence: Array = negotiation.get("evidence_used", [])
	for evidence in evidence_options:
		var clue_index = int(evidence["clue_index"])
		var clues: Array = listing.get("discovered_clues", [])
		var clue_text = ""
		if clue_index >= 0 and clue_index < clues.size():
			clue_text = str(clues[clue_index]["text"])
		var label = str(evidence["label"])
		if used_evidence.has(clue_text):
			label += " · 사용함"
		_add_clue_option(evidence_option, label)
		evidence_map.append(clue_index)

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
	deal_submit_button.disabled = closed
	deal_submit_button.text = "새 제안 불가" if closed else ("다시 제안 보내기" if rounds > 0 else "이 가격으로 제안 보내기")
	offer_slider.editable = not closed
	evidence_option.disabled = closed
	for button in deal_preset_buttons:
		button.disabled = closed

	buy_current_button.disabled = gold < current_price
	buy_current_button.text = "%sG에 바로 거래" % _money(current_price)
	if gold < current_price:
		deal_purchase_warning.text = "보유 골드보다 %sG 부족" % _money(current_price - gold)
	elif closed:
		deal_purchase_warning.text = "협상 종료 · 현재 가격에 구매하거나 거래를 보류하세요."
	else:
		deal_purchase_warning.text = ""

	seller_speech.text = str(negotiation.get("last_speech", "“네, 아직 있어요. 가격 말씀해보세요.”"))

func _offer_slider_changed(_value: float) -> void:
	_update_offer_price_label()


func _update_offer_price_label() -> void:
	var price = int(round(offer_slider.value))
	var listing = _current_market_listing()
	offer_price_label.text = "내 제안가   %sG" % _money(price)
	offer_warning_label.text = ""
	if listing.is_empty():
		return
	var plan: Dictionary = listing.get("trade_plan", {})
	var max_buy_price = int(plan.get("max_buy_price", price))
	if price > max_buy_price:
		offer_warning_label.text = "⚠ 내 매입 상한보다 %sG 높음" % _money(price - max_buy_price)

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

	var negotiation: Dictionary = listing["negotiation_state"]
	var previous_price = int(negotiation["current_price"])
	var clue_index = -1
	var evidence_text = ""
	if evidence_option.selected > 0 and evidence_option.selected - 1 < evidence_map.size():
		clue_index = int(evidence_map[evidence_option.selected - 1])
		var clues: Array = listing.get("discovered_clues", [])
		if clue_index >= 0 and clue_index < clues.size():
			evidence_text = str(clues[clue_index]["text"])

	var result: Dictionary = engine.negotiate_offer(
		listing,
		negotiation,
		int(round(offer_slider.value)),
		clue_index
	)
	var updated_state: Dictionary = result["state"]
	updated_state["previous_price"] = previous_price
	updated_state["last_evidence_text"] = evidence_text
	updated_state["last_status"] = str(result["status"])
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
		"purchase_context": {
			"seller_name": Art.seller_name(listing.get("seller", {})),
			"neighborhood": feed.public_location_text(listing),
			"meetup": feed.public_meetup_text(listing),
			"price": price
		},
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
	_set_status("%s에게서 물건을 받아왔습니다. 이제 감정할지, 바로 팔지, 보관할지 정할 수 있습니다." % Art.seller_name(listing.get("seller", {})))
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
		var full_text = "%s · 매입 %sG · %s" % [Art.item_name(listing), _money(int(owned["purchase_price"])), state_text]
		inventory_list.add_item(_compact_option_text(inventory_list, full_text))
		inventory_list.set_item_tooltip(inventory_list.item_count - 1, full_text)

	var has_items = not owned_items.is_empty()
	$Margin/RootVBox/InventoryPanel/Scroll/Box/ItemArt.visible = has_items
	purchase_handoff_panel.visible = has_items
	inventory_list.visible = owned_items.size() > 1

	if not has_items:
		selected_owned_index = -1
		purchase_handoff_panel.visible = false
		inventory_detail.text = "아직 보유한 물건이 없습니다.\n마켓에서 물건을 사면 직거래 후 이곳에 들어옵니다."
		inventory_appraise_button.disabled = true
		inventory_sell_button.disabled = true
		return

	if selected_owned_index < 0 or selected_owned_index >= owned_items.size():
		selected_owned_index = 0
	if inventory_list.visible:
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
	var context: Dictionary = owned.get("purchase_context", {})
	var seller_name = str(context.get("seller_name", Art.seller_name(listing.get("seller", {}))))
	var meetup = str(context.get("meetup", feed.public_meetup_text(listing)))
	var purchase_price = int(owned["purchase_price"])

	$Margin/RootVBox/InventoryPanel/Scroll/Box/ItemArt.texture = Art.texture_for("items", str(listing.get("item_id", "")))
	purchase_handoff_title.text = "직거래 완료 · %s" % Art.item_name(listing)
	purchase_handoff_text.text = "%s에게서 %s에서 받아왔습니다.\n%sG에 거래 완료 · 현재 %s" % [
		seller_name,
		meetup,
		_money(purchase_price),
		_owned_state_text(owned)
	]

	inventory_detail.text = "내가 산 가격  %sG\n내 예상 재판매가  %s\n내 최대 매입가  %sG\n\n거래 전에 알아낸 것\n%s" % [
		_money(purchase_price),
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
	var has_result = not appraisal_data.is_empty()
	appraisal_pre_view.visible = not has_result
	appraisal_result_view.visible = has_result
	appraisal_gold_label.text = "%s G" % _money(gold)

	if has_result:
		appraisal_result_hero.texture = Art.texture_for("items", str(listing.get("item_id", "")))
		appraisal_result_summary.text = "%s\n구매가 %sG\n%s · %s" % [
			Art.item_name(listing),
			_money(int(owned["purchase_price"])),
			appraisal_data["rarity"],
			appraisal_data["condition"]
		]
		appraisal_result_metrics.text = "진품 여부   %s\n마력 잔량   %s\n저주 강도   %s\n희귀도      %s\n예상 시세   %s~%sG" % [
			_appraisal_auth_text(str(appraisal_data["state"])),
			appraisal_data.get("magic_grade", "C"),
			appraisal_data.get("curse_grade", "없음"),
			appraisal_data["rarity"],
			_money(int(appraisal_data.get("value_low", appraisal_data["value"]))),
			_money(int(appraisal_data.get("value_high", appraisal_data["value"])))
		]
		var clue_review = ""
		for line in appraisal_data.get("clue_feedback", []):
			clue_review += "• %s\n" % str(line)
		appraisal_comment.text = "%s\n\n단서 복기\n%s" % [
			str(appraisal_data.get("comment", "감정 결과를 확인했습니다.")),
			clue_review.strip_edges()
		]
		return

	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/ItemSummary/Row/ItemArt.texture = Art.texture_for("items", str(listing.get("item_id", "")))
	appraisal_title.text = Art.item_name(listing)
	var appraisal_cost = engine.professional_appraisal_cost(listing)
	var purchase_price = max(1, int(owned["purchase_price"]))
	var appraisal_ratio = float(appraisal_cost) / float(purchase_price) * 100.0
	appraisal_info.text = "매입가 %sG\n검사비 누적 %sG\n전문 감정 %sG · 매입가 대비 %.1f%%" % [
		_money(purchase_price),
		_money(int(owned["inspection_cost_total"])),
		_money(appraisal_cost),
		appraisal_ratio
	]
	var known_text = _format_discovered_clues(listing)
	appraisal_clues.text = known_text if not known_text.is_empty() else "구매 전에 확실하게 확인한 정보가 없습니다."
	appraisal_state.text = "추가 검사 %d회 남음" % int(owned["inspection_remaining"])

	var options = engine.post_inspection_options(listing)
	var used: Array = listing.get("post_inspected_actions", [])
	var short_labels = ["재질", "마력", "내부 구조"]
	for i in range(post_buttons.size()):
		var option: Dictionary = options[i]
		post_buttons[i].text = "%s\n%sG%s" % [short_labels[i], _money(int(option["cost"])), " ✓" if used.has(option["id"]) else ""]
		post_buttons[i].tooltip_text = str(option["label"])
		post_buttons[i].disabled = int(owned["inspection_remaining"]) <= 0 or used.has(option["id"]) or gold < int(option["cost"])

	professional_appraise_button.text = "전문 감정 · %sG" % _money(appraisal_cost)
	professional_appraise_button.disabled = gold < appraisal_cost

func _appraisal_auth_text(state: String) -> String:
	if state == "진품":
		return "진품 확인"
	if state == "모조품":
		return "모조품"
	return "원본 계열 · 결함 확인"


func _confirm_prepare_resale() -> void:
	$ResaleConfirmation.popup_centered(Vector2i(min(320, int(get_viewport_rect().size.x) - 24), 190))




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
	if owned.is_empty():
		return
	if not owned.get("appraisal_data", {}).is_empty():
		return
	var listing: Dictionary = owned["listing"]
	var appraisal_cost = engine.professional_appraisal_cost(listing)
	if gold < appraisal_cost:
		return
	gold -= appraisal_cost
	owned["appraisal_cost"] = appraisal_cost
	owned["appraisal_data"] = engine.appraise(listing)
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
	var quote_remaining = int(owned["quote_requests_remaining"])

	sale_gold_label.text = "%s G" % _money(gold)
	sale_item_art.texture = Art.texture_for("items", str(listing.get("item_id", "")))
	sale_title.text = Art.item_name(listing)

	if appraisal_data.is_empty():
		sale_info.text = "매입가 %sG · 미감정\n현재까지 모은 정보와 판매처 성향으로 판단합니다." % _money(int(owned["purchase_price"]))
	else:
		var low = int(appraisal_data.get("value_low", appraisal_data["value"]))
		var high = int(appraisal_data.get("value_high", appraisal_data["value"]))
		sale_info.text = "매입가 %sG · 감정 완료\n%s · %s · 예상 시세 %s~%sG" % [
			_money(int(owned["purchase_price"])),
			appraisal_data["rarity"],
			appraisal_data["condition"],
			_money(low),
			_money(high)
		]

	quote_state.text = "전문 견적 %d회 남음 · 요청한 곳만 가격 공개 · 고물상은 즉시가" % quote_remaining

	for i in range(buyer_buttons.size()):
		var offer: Dictionary = offers[i]
		var is_selected = i == selected_buyer_index
		buyer_name_labels[i].text = str(offer["name"])
		buyer_summary_labels[i].text = str(offer["summary"])

		if str(offer["buyer_id"]) == "scrap":
			buyer_status_labels[i].text = "즉시가"
			buyer_reason_labels[i].text = "%sG · %s" % [_money(int(offer["price"])), str(offer["reason"])]
		elif bool(offer["revealed"]):
			buyer_status_labels[i].text = "%sG" % _money(int(offer["price"]))
			buyer_reason_labels[i].text = "%sG · %s" % [_money(int(offer["price"])), str(offer["reason"])]
		else:
			buyer_status_labels[i].text = "미확인"
			buyer_reason_labels[i].text = "견적 요청 후 가격 공개"

		buyer_buttons[i].text = "선택됨" if is_selected else ("고물상 선택" if str(offer["buyer_id"]) == "scrap" else "이 판매처 선택")
		buyer_buttons[i].disabled = is_selected

	var can_quote = false
	var can_sell = false
	if selected_buyer_index >= 0 and selected_buyer_index < offers.size():
		var selected: Dictionary = offers[selected_buyer_index]
		var selected_name = str(selected["name"])
		can_quote = not bool(selected["revealed"]) and selected["buyer_id"] != "scrap" and quote_remaining > 0
		can_sell = bool(selected["revealed"])

		if can_sell:
			sale_selected_label.text = "%s · 확인된 제안 %sG" % [selected_name, _money(int(selected["price"]))]
			sell_button.text = "%s에게 %sG에 판매" % [selected_name, _money(int(selected["price"]))]
		else:
			sale_selected_label.text = "%s · 아직 견적 미확인" % selected_name
			sell_button.text = "견적 확인 후 판매 가능"

		if can_quote:
			quote_button.text = "%s에게 견적 요청 · 남은 %d회" % [selected_name, quote_remaining]
		elif selected["buyer_id"] == "scrap":
			quote_button.text = "고물상은 견적 요청 없이 즉시 판매 가능"
		elif bool(selected["revealed"]):
			quote_button.text = "이 판매처의 견적을 확인했습니다."
		else:
			quote_button.text = "전문 견적 요청 기회를 모두 사용했습니다."
	else:
		sale_selected_label.text = "판매처를 선택하세요 · 전문 판매처는 두 곳만 견적 가능"
		quote_button.text = "선택한 전문 판매처에 견적 요청"
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
		# Cosmetic names must not create duplicate discoveries in existing saves.
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

	var seller: Dictionary = listing["seller"]
	var seller_personality: Dictionary = seller["personality"]
	var seller_review = "관찰 당시: %s\n실제 성향: %s" % [
		feed.seller_behavior_text(listing),
		str(seller_personality["name"])
	]

	last_result_text = "거래 완료 · %s\n\n매입가 %sG\n검사/감정비 %sG\n판매가 %sG\n순이익 %s\n\n내 거래 계획 복기\n%s\n거래 분석\n%s\n\n판매자 복기\n%s\n\n실제 물건\n%s · %s · %s\n실제 가치 %sG\n\n현재 자산 %sG" % [
		Art.item_name(listing), _money(purchase_price), _money(info_cost), _money(sale_price), _signed_money(profit),
		plan_text, analysis, seller_review,
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
		text += "• %s\n" % str(clue["text"])
	return text.strip_edges()


func _select_option_by_text(option_button: OptionButton, text_value: String) -> void:
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == text_value:
			option_button.select(i)
			return


func _show_panel(target) -> void:
	for panel in [market_panel, detail_panel, seller_chat_panel, deal_panel, inventory_panel, appraisal_panel, sale_panel, result_panel]:
		panel.visible = panel == target

	var focus_mode = target == detail_panel or target == seller_chat_panel or target == deal_panel or target == appraisal_panel or target == sale_panel
	global_header.visible = not focus_mode
	status_panel.visible = target != market_panel and not focus_mode
	nav_row.visible = not focus_mode

	market_nav_button.set_pressed_no_signal(current_stage in ["market", "detail", "chat", "deal"])
	inventory_nav_button.set_pressed_no_signal(current_stage in ["inventory", "appraisal", "sale"])
	records_nav_button.set_pressed_no_signal(current_stage == "result")


func _update_header() -> void:
	gold_label.text = "%s G" % _money(gold)
	detail_gold_label.text = "%s G" % _money(gold)
	chat_gold_label.text = "%s G" % _money(gold)
	deal_gold_label.text = "%s G" % _money(gold)
	appraisal_gold_label.text = "%s G" % _money(gold)
	sale_gold_label.text = "%s G" % _money(gold)
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
		"chat":
			if selected_market_index >= 0 and selected_market_index < market_items.size():
				_render_seller_chat()
				_show_panel(seller_chat_panel)
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
	home_query = ""
	home_tab = "recommended"
	home_category = "전체"
	_create_new_market(true, false)
	_update_header()
	_save_game()
	_set_status("새 장터에서 다시 시작합니다.")


func _save_game() -> void:
	var payload = {
		"version": 30,
		"home_scroll_offset": home_scroll_offset,
		"home_query": home_query,
		"home_tab": home_tab,
		"home_category": home_category,
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
	home_query = str(parsed.get("home_query", ""))
	home_tab = str(parsed.get("home_tab", "recommended"))
	home_category = str(parsed.get("home_category", "전체"))
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
