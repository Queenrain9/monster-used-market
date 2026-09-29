extends Control

const MarketEngine = preload("res://scripts/game_logic.gd")
const Content = preload("res://data/content.gd")
const Art = preload("res://scripts/art_catalog.gd")
const MarketTheme = preload("res://scripts/market_theme.gd")
const HomeFeed = preload("res://scripts/home_feed.gd")
const Presentation = preload("res://data/presentation_manifest.gd")

const STARTING_GOLD = 50000
const SAVE_PATH = "user://monster_used_market_save_v022.json"
const SAVE_BACKUP_PATH = "user://monster_used_market_save_v022.backup.json"
const SAVE_TEMP_PATH = "user://monster_used_market_save_v022.tmp.json"
const SETTINGS_PATH = "user://monster_used_market_settings.json"

@onready var gold_label = $Margin/RootVBox/Header/GoldLabel
@onready var inventory_count_label = $Margin/RootVBox/Header/InventoryCount
@onready var stats_label = $Margin/RootVBox/ResultPanel/Scroll/Box/StatsPanel/StatsLabel
@onready var global_header = $Margin/RootVBox/Header
@onready var status_panel = $Margin/RootVBox/StatusPanel
@onready var status_label = $Margin/RootVBox/StatusPanel/StatusLabel
@onready var nav_row = $Margin/RootVBox/NavRow
@onready var town_nav_button = $Margin/RootVBox/NavRow/TownNavButton
@onready var market_nav_button = $Margin/RootVBox/NavRow/MarketNavButton
@onready var inventory_nav_button = $Margin/RootVBox/NavRow/InventoryNavButton
@onready var records_nav_button = $Margin/RootVBox/NavRow/RecordsNavButton

@onready var meta_strip = $Margin/RootVBox/MetaStrip
@onready var day_label = $Margin/RootVBox/MetaStrip/Box/Row/DayLabel
@onready var rank_label = $Margin/RootVBox/MetaStrip/Box/Row/RankLabel
@onready var reputation_label = $Margin/RootVBox/MetaStrip/Box/Row/ReputationLabel
@onready var goal_label = $Margin/RootVBox/MetaStrip/Box/GoalLabel

@onready var commercial_shell = $CommercialShell
@onready var title_view = $CommercialShell/Center/Card/TitleView
@onready var onboarding_view = $CommercialShell/Center/Card/OnboardingView
@onready var continue_button = $CommercialShell/Center/Card/TitleView/ContinueButton
@onready var new_game_button = $CommercialShell/Center/Card/TitleView/NewGameButton
@onready var onboarding_step_label = $CommercialShell/Center/Card/OnboardingView/StepLabel
@onready var onboarding_title = $CommercialShell/Center/Card/OnboardingView/Title
@onready var onboarding_body = $CommercialShell/Center/Card/OnboardingView/Body
@onready var onboarding_next_button = $CommercialShell/Center/Card/OnboardingView/NextButton

@onready var music_player = $MusicPlayer
@onready var sfx_player = $SfxPlayer
@onready var toast_panel = $PresentationLayer/ToastPanel
@onready var toast_label = $PresentationLayer/ToastPanel/Label
@onready var context_tip = $ContextTip
@onready var context_tip_title = $ContextTip/Box/Title
@onready var context_tip_body = $ContextTip/Box/Body
@onready var settings_overlay = $SettingsOverlay
@onready var settings_music_label = $SettingsOverlay/Center/Card/Box/MusicLabel
@onready var settings_music_slider = $SettingsOverlay/Center/Card/Box/MusicSlider
@onready var settings_sfx_label = $SettingsOverlay/Center/Card/Box/SfxLabel
@onready var settings_sfx_slider = $SettingsOverlay/Center/Card/Box/SfxSlider
@onready var settings_haptics_check = $SettingsOverlay/Center/Card/Box/HapticsCheck
@onready var settings_reduced_motion_check = $SettingsOverlay/Center/Card/Box/ReducedMotionCheck
@onready var settings_large_text_check = $SettingsOverlay/Center/Card/Box/LargeTextCheck

@onready var town_panel = $Margin/RootVBox/TownPanel
@onready var workshop_panel = $Margin/RootVBox/WorkshopPanel
@onready var relationships_panel = $Margin/RootVBox/RelationshipsPanel
@onready var market_panel = $Margin/RootVBox/MarketPanel
@onready var detail_panel = $Margin/RootVBox/DetailPanel
@onready var seller_chat_panel = $Margin/RootVBox/SellerChatPanel
@onready var deal_panel = $Margin/RootVBox/DealPanel
@onready var inventory_panel = $Margin/RootVBox/InventoryPanel
@onready var appraisal_panel = $Margin/RootVBox/AppraisalPanel
@onready var sale_panel = $Margin/RootVBox/SalePanel
@onready var result_panel = $Margin/RootVBox/ResultPanel

@onready var town_visits_label = $Margin/RootVBox/TownPanel/Scroll/Box/TitleRow/VisitsLabel
@onready var town_event_text = $Margin/RootVBox/TownPanel/Scroll/Box/EventPanel/EventText
@onready var last_day_panel = $Margin/RootVBox/TownPanel/Scroll/Box/LastDayPanel
@onready var last_day_text = $Margin/RootVBox/TownPanel/Scroll/Box/LastDayPanel/LastDayText
@onready var district_cards = [
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard1,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard2,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard3,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard4
]
@onready var district_arts = [
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard1/Row/Art,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard2/Row/Art,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard3/Row/Art,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard4/Row/Art
]
@onready var district_name_labels = [
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard1/Row/Info/Name,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard2/Row/Info/Name,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard3/Row/Info/Name,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard4/Row/Info/Name
]
@onready var district_neighborhood_labels = [
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard1/Row/Info/Neighborhoods,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard2/Row/Info/Neighborhoods,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard3/Row/Info/Neighborhoods,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard4/Row/Info/Neighborhoods
]
@onready var district_description_labels = [
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard1/Row/Info/Description,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard2/Row/Info/Description,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard3/Row/Info/Description,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard4/Row/Info/Description
]
@onready var district_enter_buttons = [
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard1/Row/Info/EnterButton,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard2/Row/Info/EnterButton,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard3/Row/Info/EnterButton,
	$Margin/RootVBox/TownPanel/Scroll/Box/DistrictList/DistrictCard4/Row/Info/EnterButton
]
@onready var end_day_button = $Margin/RootVBox/TownPanel/Scroll/Box/EndDayButton

@onready var workshop_gold_label = $Margin/RootVBox/WorkshopPanel/Scroll/Box/TopRow/GoldLabel
@onready var workshop_rank_label = $Margin/RootVBox/WorkshopPanel/Scroll/Box/RankPanel/Box/RankLabel
@onready var workshop_progress_label = $Margin/RootVBox/WorkshopPanel/Scroll/Box/RankPanel/Box/ProgressLabel
@onready var workshop_unlock_label = $Margin/RootVBox/WorkshopPanel/Scroll/Box/RankPanel/Box/UnlockLabel
@onready var upgrade_cards = [
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard1,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard2,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard3,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard4,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard5
]
@onready var upgrade_name_labels = [
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard1/Box/Top/Name,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard2/Box/Top/Name,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard3/Box/Top/Name,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard4/Box/Top/Name,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard5/Box/Top/Name
]
@onready var upgrade_level_labels = [
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard1/Box/Top/Level,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard2/Box/Top/Level,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard3/Box/Top/Level,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard4/Box/Top/Level,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard5/Box/Top/Level
]
@onready var upgrade_description_labels = [
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard1/Box/Description,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard2/Box/Description,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard3/Box/Description,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard4/Box/Description,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard5/Box/Description
]
@onready var upgrade_effect_labels = [
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard1/Box/Effect,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard2/Box/Effect,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard3/Box/Effect,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard4/Box/Effect,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard5/Box/Effect
]
@onready var upgrade_requirement_labels = [
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard1/Box/Requirement,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard2/Box/Requirement,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard3/Box/Requirement,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard4/Box/Requirement,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard5/Box/Requirement
]
@onready var upgrade_buy_buttons = [
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard1/Box/BuyButton,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard2/Box/BuyButton,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard3/Box/BuyButton,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard4/Box/BuyButton,
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/UpgradeList/UpgradeCard5/Box/BuyButton
]

@onready var relationship_list = $Margin/RootVBox/RelationshipsPanel/Scroll/Box/SellerList
@onready var relationship_portrait = $Margin/RootVBox/RelationshipsPanel/Scroll/Box/ProfilePanel/Box/Hero/Portrait
@onready var relationship_name = $Margin/RootVBox/RelationshipsPanel/Scroll/Box/ProfilePanel/Box/Hero/Info/Name
@onready var relationship_neighborhood = $Margin/RootVBox/RelationshipsPanel/Scroll/Box/ProfilePanel/Box/Hero/Info/Neighborhood
@onready var relationship_stage_label = $Margin/RootVBox/RelationshipsPanel/Scroll/Box/ProfilePanel/Box/Hero/Info/Stage
@onready var relationship_stats = $Margin/RootVBox/RelationshipsPanel/Scroll/Box/ProfilePanel/Box/Stats
@onready var relationship_memory = $Margin/RootVBox/RelationshipsPanel/Scroll/Box/ProfilePanel/Box/MemoryText
@onready var relationship_story = $Margin/RootVBox/RelationshipsPanel/Scroll/Box/ProfilePanel/Box/StoryText
@onready var relationship_special = $Margin/RootVBox/RelationshipsPanel/Scroll/Box/ProfilePanel/Box/SpecialText
@onready var relationship_visit_button = $Margin/RootVBox/RelationshipsPanel/Scroll/Box/ProfilePanel/Box/VisitButton

@onready var collection_panel = $Margin/RootVBox/CollectionPanel
@onready var collection_completion_label = $Margin/RootVBox/CollectionPanel/Scroll/Box/TopRow/CompletionLabel
@onready var collection_summary_text = $Margin/RootVBox/CollectionPanel/Scroll/Box/SummaryPanel/SummaryText
@onready var collection_item_list = $Margin/RootVBox/CollectionPanel/Scroll/Box/ItemList
@onready var collection_item_art = $Margin/RootVBox/CollectionPanel/Scroll/Box/DetailPanel/Box/Hero/Art
@onready var collection_item_name = $Margin/RootVBox/CollectionPanel/Scroll/Box/DetailPanel/Box/Hero/Info/Name
@onready var collection_item_status = $Margin/RootVBox/CollectionPanel/Scroll/Box/DetailPanel/Box/Hero/Info/Status
@onready var collection_detail_text = $Margin/RootVBox/CollectionPanel/Scroll/Box/DetailPanel/Box/DetailText
@onready var collection_sets_text = $Margin/RootVBox/CollectionPanel/Scroll/Box/SetsText
@onready var collection_goals_text = $Margin/RootVBox/CollectionPanel/Scroll/Box/GoalsText
@onready var collection_achievements_text = $Margin/RootVBox/CollectionPanel/Scroll/Box/AchievementsText

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
@onready var record_recent_title = $Margin/RootVBox/ResultPanel/Scroll/Box/RecentTitle
@onready var record_hero = $Margin/RootVBox/ResultPanel/Scroll/Box/RecordHero
@onready var record_item_art = $Margin/RootVBox/ResultPanel/Scroll/Box/RecordHero/Row/ItemArt
@onready var record_item_name = $Margin/RootVBox/ResultPanel/Scroll/Box/RecordHero/Row/Info/ItemName
@onready var record_buyer_line = $Margin/RootVBox/ResultPanel/Scroll/Box/RecordHero/Row/Info/BuyerLine
@onready var record_profit_label = $Margin/RootVBox/ResultPanel/Scroll/Box/RecordHero/Row/Info/ProfitLabel
@onready var record_money_panel = $Margin/RootVBox/ResultPanel/Scroll/Box/MoneyPanel
@onready var record_purchase_value = $Margin/RootVBox/ResultPanel/Scroll/Box/MoneyPanel/Grid/PurchaseValue
@onready var record_cost_value = $Margin/RootVBox/ResultPanel/Scroll/Box/MoneyPanel/Grid/CostValue
@onready var record_sale_value = $Margin/RootVBox/ResultPanel/Scroll/Box/MoneyPanel/Grid/SaleValue
@onready var record_decision_title = $Margin/RootVBox/ResultPanel/Scroll/Box/DecisionTitle
@onready var record_decision_panel = $Margin/RootVBox/ResultPanel/Scroll/Box/DecisionPanel
@onready var record_decision_text = $Margin/RootVBox/ResultPanel/Scroll/Box/DecisionPanel/DecisionText
@onready var record_analysis_panel = $Margin/RootVBox/ResultPanel/Scroll/Box/AnalysisPanel
@onready var record_analysis_text = $Margin/RootVBox/ResultPanel/Scroll/Box/AnalysisPanel/AnalysisText
@onready var record_truth_title = $Margin/RootVBox/ResultPanel/Scroll/Box/TruthTitle
@onready var record_truth_panel = $Margin/RootVBox/ResultPanel/Scroll/Box/TruthPanel
@onready var record_truth_text = $Margin/RootVBox/ResultPanel/Scroll/Box/TruthPanel/TruthText
@onready var record_seller_panel = $Margin/RootVBox/ResultPanel/Scroll/Box/SellerReviewPanel
@onready var record_seller_text = $Margin/RootVBox/ResultPanel/Scroll/Box/SellerReviewPanel/SellerReviewText
@onready var record_assets_label = $Margin/RootVBox/ResultPanel/Scroll/Box/AssetsLabel
@onready var legacy_result_summary = $Margin/RootVBox/ResultPanel/Scroll/Box/LegacySummary

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
var last_result_record: Dictionary = {}

var game_started = false
var onboarding_complete = false
var onboarding_page = 0
var merchant_day = 1
var merchant_reputation = 0
var daily_goal_progress = 0
var daily_goal_claimed = false
var last_progress_message = ""

var current_district_id = "night_market"
var market_visits_remaining = Content.DAY_MARKET_VISITS
var day_start_gold = STARTING_GOLD
var last_day_summary: Dictionary = {}
var day_event_id = ""
var upgrade_levels: Dictionary = {
	"storage":0,
	"notebook":0,
	"appraisal":0,
	"network":0,
	"routes":0
}

var seller_relationships: Dictionary = {}
var selected_relationship_seller_index = 0

var collection_records: Dictionary = {}
var collection_goal_claimed: Dictionary = {}
var achievement_unlocks: Dictionary = {}
var selected_collection_index = 0
var last_collection_reward = ""

var presentation_settings: Dictionary = {
	"music_volume":0.70,
	"sfx_volume":0.80,
	"haptics":true,
	"reduced_motion":false,
	"large_text":false
}
var tutorial_flags: Dictionary = {}
var active_context_tip = ""
var current_bgm_state = ""
var last_presentation_event = ""
var save_recovery_notice = false
var _skip_backup_on_next_save = false
var _base_font_sizes: Dictionary = {}
var _syncing_settings = false
var _toast_serial = 0


func _ready() -> void:
	theme = MarketTheme.build()
	$Backdrop.texture = Art.texture_for("ui", "market")
	$Margin/RootVBox/Header/Brand.texture = Art.texture_for("ui", "brand")
	$Margin/RootVBox/MarketPanel/Scroll/Box/MarketBanner/Art.texture = Art.texture_for("ui", "market")
	$Margin/RootVBox/AppraisalPanel/Scroll/Box/PreView/ItemSummary/Row/ItemArt.texture = Art.texture_for("ui", "appraiser")
	$CommercialShell/Center/Card/TitleView/Brand.texture = Art.texture_for("ui", "brand")
	$CommercialShell/Center/Card/OnboardingView/Art.texture = Art.texture_for("ui", "market")
	_load_presentation_settings()
	_configure_mobile_ui()
	_capture_base_font_sizes()
	_apply_accessibility_settings()
	_apply_audio_settings()
	_connect_buttons()
	_setup_options()
	_ensure_seller_relationships()
	_load_game()
	_restore_home_controls()
	_roll_daily_counter_if_needed()

	if market_items.size() != 3:
		_create_new_market(true, false)

	_update_header()
	_restore_stage()

	# Automated headless tests exercise the gameplay surface directly.
	# Real players always enter through the commercial title shell.
	if DisplayServer.get_name() == "headless":
		commercial_shell.hide()
	else:
		_show_title_screen()
	_save_game()


func _connect_buttons() -> void:
	town_nav_button.pressed.connect(_go_town)
	market_nav_button.pressed.connect(_go_market)
	inventory_nav_button.pressed.connect(_go_inventory)
	records_nav_button.pressed.connect(_go_records)
	continue_button.pressed.connect(_continue_from_title)
	new_game_button.pressed.connect(_new_game_from_title)
	onboarding_next_button.pressed.connect(_advance_onboarding)
	$CommercialShell/Center/Card/TitleView/SettingsButton.pressed.connect(_show_settings)
	$Margin/RootVBox/TownPanel/Scroll/Box/SettingsButton.pressed.connect(_show_settings)
	$SettingsOverlay/Center/Card/Box/TopRow/CloseButton.pressed.connect(_hide_settings)
	$ContextTip/Box/DismissButton.pressed.connect(_dismiss_context_tip)
	settings_music_slider.value_changed.connect(_on_music_volume_changed)
	settings_sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	settings_haptics_check.toggled.connect(_on_haptics_toggled)
	settings_reduced_motion_check.toggled.connect(_on_reduced_motion_toggled)
	settings_large_text_check.toggled.connect(_on_large_text_toggled)

	search_input.text_changed.connect(_on_home_search_changed)
	recommend_tab_button.pressed.connect(_set_home_tab.bind("recommended"))
	negotiable_tab_button.pressed.connect(_set_home_tab.bind("negotiable"))
	viewed_tab_button.pressed.connect(_set_home_tab.bind("viewed"))
	category_tab_button.pressed.connect(_set_home_tab.bind("category"))
	for button in category_buttons:
		button.pressed.connect(_set_home_category.bind(button.text))

	for i in range(district_enter_buttons.size()):
		district_enter_buttons[i].pressed.connect(_enter_district.bind(i))
	end_day_button.pressed.connect(_end_day)
	$Margin/RootVBox/TownPanel/Scroll/Box/WorkshopButton.pressed.connect(_go_workshop)
	$Margin/RootVBox/TownPanel/Scroll/Box/RelationshipsButton.pressed.connect(_go_relationships)
	$Margin/RootVBox/TownPanel/Scroll/Box/CollectionButton.pressed.connect(_go_collection)
	$Margin/RootVBox/WorkshopPanel/Scroll/Box/TopRow/BackButton.pressed.connect(_go_town)
	$Margin/RootVBox/RelationshipsPanel/Scroll/Box/TopRow/BackButton.pressed.connect(_go_town)
	$Margin/RootVBox/CollectionPanel/Scroll/Box/TopRow/BackButton.pressed.connect(_go_town)
	collection_item_list.item_selected.connect(_collection_item_selected)
	relationship_list.item_selected.connect(_relationship_seller_selected)
	relationship_visit_button.pressed.connect(_visit_relationship_seller)
	for i in range(upgrade_buy_buttons.size()):
		upgrade_buy_buttons[i].pressed.connect(_buy_upgrade.bind(i))
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


func _default_presentation_settings() -> Dictionary:
	return {
		"music_volume":0.70,
		"sfx_volume":0.80,
		"haptics":true,
		"reduced_motion":false,
		"large_text":false
	}


func _load_presentation_settings() -> void:
	presentation_settings = _default_presentation_settings()
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	presentation_settings["music_volume"] = clamp(float(parsed.get("music_volume", 0.70)), 0.0, 1.0)
	presentation_settings["sfx_volume"] = clamp(float(parsed.get("sfx_volume", 0.80)), 0.0, 1.0)
	presentation_settings["haptics"] = bool(parsed.get("haptics", true))
	presentation_settings["reduced_motion"] = bool(parsed.get("reduced_motion", false))
	presentation_settings["large_text"] = bool(parsed.get("large_text", false))


func _save_presentation_settings() -> void:
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(presentation_settings))


func _sync_settings_controls() -> void:
	_syncing_settings = true
	settings_music_slider.value = float(presentation_settings.get("music_volume", 0.70))
	settings_sfx_slider.value = float(presentation_settings.get("sfx_volume", 0.80))
	settings_haptics_check.button_pressed = bool(presentation_settings.get("haptics", true))
	settings_reduced_motion_check.button_pressed = bool(presentation_settings.get("reduced_motion", false))
	settings_large_text_check.button_pressed = bool(presentation_settings.get("large_text", false))
	settings_music_label.text = "배경음악 %d%%" % int(round(float(settings_music_slider.value) * 100.0))
	settings_sfx_label.text = "효과음 %d%%" % int(round(float(settings_sfx_slider.value) * 100.0))
	_syncing_settings = false


func _show_settings() -> void:
	_sync_settings_controls()
	settings_overlay.show()
	_presentation_event("tap", "light")


func _hide_settings() -> void:
	settings_overlay.hide()
	_presentation_event("tap", "light")


func _on_music_volume_changed(value: float) -> void:
	if _syncing_settings:
		return
	presentation_settings["music_volume"] = clamp(value, 0.0, 1.0)
	settings_music_label.text = "배경음악 %d%%" % int(round(value * 100.0))
	_apply_audio_settings()
	_save_presentation_settings()


func _on_sfx_volume_changed(value: float) -> void:
	if _syncing_settings:
		return
	presentation_settings["sfx_volume"] = clamp(value, 0.0, 1.0)
	settings_sfx_label.text = "효과음 %d%%" % int(round(value * 100.0))
	_apply_audio_settings()
	_save_presentation_settings()
	_play_sfx("tap")


func _on_haptics_toggled(enabled: bool) -> void:
	if _syncing_settings:
		return
	presentation_settings["haptics"] = enabled
	_save_presentation_settings()
	if enabled:
		_emit_haptic("light")


func _on_reduced_motion_toggled(enabled: bool) -> void:
	if _syncing_settings:
		return
	presentation_settings["reduced_motion"] = enabled
	_save_presentation_settings()


func _on_large_text_toggled(enabled: bool) -> void:
	if _syncing_settings:
		return
	presentation_settings["large_text"] = enabled
	_apply_accessibility_settings()
	_save_presentation_settings()


func _capture_base_font_sizes() -> void:
	for control in find_children("*", "Control", true, false):
		if control is Label or control is Button or control is LineEdit:
			var key = str(control.get_instance_id())
			if not _base_font_sizes.has(key):
				_base_font_sizes[key] = int(control.get_theme_font_size("font_size"))


func _apply_accessibility_settings() -> void:
	var extra = 1 if bool(presentation_settings.get("large_text", false)) else 0
	for control in find_children("*", "Control", true, false):
		if not (control is Label or control is Button or control is LineEdit):
			continue
		var key = str(control.get_instance_id())
		if not _base_font_sizes.has(key):
			_base_font_sizes[key] = int(control.get_theme_font_size("font_size"))
		var base_size = int(_base_font_sizes[key])
		control.add_theme_font_size_override("font_size", base_size + extra)


func _apply_audio_settings() -> void:
	var music_value = max(0.0001, float(presentation_settings.get("music_volume", 0.70)))
	var sfx_value = max(0.0001, float(presentation_settings.get("sfx_volume", 0.80)))
	music_player.volume_db = linear_to_db(music_value)
	sfx_player.volume_db = linear_to_db(sfx_value)


func _presentation_stream(path: String) -> AudioStream:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as AudioStream


func _set_bgm_state(state_id: String) -> void:
	if current_bgm_state == state_id:
		return
	current_bgm_state = state_id
	var path = str(Presentation.BGM.get(state_id, ""))
	var stream = _presentation_stream(path)
	if stream == null:
		music_player.stop()
		music_player.stream = null
		return
	music_player.stream = stream
	music_player.play()


func _play_sfx(event_id: String) -> void:
	last_presentation_event = event_id
	var path = str(Presentation.SFX.get(event_id, ""))
	var stream = _presentation_stream(path)
	if stream == null:
		return
	sfx_player.stream = stream
	sfx_player.play()


func _emit_haptic(kind: String) -> void:
	if not bool(presentation_settings.get("haptics", true)):
		return
	if DisplayServer.get_name() == "headless":
		return
	var duration = int(Presentation.HAPTIC_MS.get(kind, 18))
	Input.vibrate_handheld(duration)


func _presentation_event(event_id: String, haptic_kind: String = "") -> void:
	_play_sfx(event_id)
	if not haptic_kind.is_empty():
		_emit_haptic(haptic_kind)


func _show_toast(text_value: String, event_id: String = "") -> void:
	if text_value.strip_edges().is_empty():
		return
	if not event_id.is_empty():
		_play_sfx(event_id)
	_toast_serial += 1
	var serial = _toast_serial
	toast_label.text = text_value
	if DisplayServer.get_name() == "headless":
		toast_panel.hide()
		return
	toast_panel.show()
	get_tree().create_timer(2.2).timeout.connect(_hide_toast_if_serial.bind(serial), CONNECT_ONE_SHOT)


func _hide_toast_if_serial(serial: int) -> void:
	if serial == _toast_serial:
		toast_panel.hide()


func _maybe_show_context_tip(stage_id: String, force: bool = false) -> void:
	if not Presentation.CONTEXT_TIPS.has(stage_id):
		return
	if bool(tutorial_flags.get(stage_id, false)):
		return
	if DisplayServer.get_name() == "headless" and not force:
		return
	var tip: Dictionary = Presentation.CONTEXT_TIPS[stage_id]
	active_context_tip = stage_id
	context_tip_title.text = str(tip.get("title", "알아둘 점"))
	context_tip_body.text = str(tip.get("body", ""))
	context_tip.show()


func _dismiss_context_tip() -> void:
	if not active_context_tip.is_empty():
		tutorial_flags[active_context_tip] = true
	active_context_tip = ""
	context_tip.hide()
	_presentation_event("tap", "light")
	if game_started:
		_save_game()


func _play_screen_enter(target: Control) -> void:
	if DisplayServer.get_name() == "headless" or bool(presentation_settings.get("reduced_motion", false)):
		target.modulate = Color(1, 1, 1, 1)
		return
	target.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate", Color(1, 1, 1, 1), 0.14)


func _bgm_state_for_target(target: Control) -> String:
	if target == town_panel or target == workshop_panel or target == relationships_panel or target == collection_panel:
		return "town"
	if target == seller_chat_panel:
		return "chat"
	if target == deal_panel:
		return "deal"
	if target == appraisal_panel:
		return "appraisal"
	if target == sale_panel:
		return "sale"
	if target == result_panel:
		return "result"
	return "market"


func _show_title_screen() -> void:
	_set_bgm_state("title")
	commercial_shell.show()
	title_view.show()
	onboarding_view.hide()
	continue_button.disabled = not game_started
	continue_button.text = "이어하기" if game_started else "이어할 게임 없음"


func _continue_from_title() -> void:
	if not game_started:
		return
	if onboarding_complete:
		commercial_shell.hide()
		_restore_stage()
		if save_recovery_notice:
			_show_toast("이전 정상 저장에서 플레이를 복구했습니다.", "warning")
			save_recovery_notice = false
	else:
		_show_onboarding_page(0)


func _new_game_from_title() -> void:
	_reset_core_progress()
	game_started = true
	onboarding_complete = false
	_create_new_market(true, false, true)
	_show_onboarding_page(0)
	_save_game()


func _show_onboarding_page(page: int) -> void:
	onboarding_page = clamp(page, 0, 2)
	commercial_shell.show()
	title_view.hide()
	onboarding_view.show()
	var titles = [
		"어둠마을에 도착했습니다",
		"당신은 신참 물건상",
		"첫 거래를 만들어보세요"
	]
	var bodies = [
		"괴물들이 수상한 물건을 사고파는 동네 장터입니다.\n판매글만 믿지 말고, 상대에게 물어보고 직접 판단해야 합니다.",
		"시작 자금은 50,000G.\n싸게 사는 것만으로는 부족합니다. 진짜 가치를 알아보고, 어디에 되팔지까지 결정하세요.",
		"오늘의 첫 목표는 거래 1건을 끝까지 완료하는 것.\n매물 확인 → 판매자 대화 → 가격 제안 → 구매 → 감정/조사 → 재판매까지 이어가세요.\n\n보상: 500G + 평판 10"
	]
	onboarding_step_label.text = "%d / 3" % [onboarding_page + 1]
	onboarding_title.text = titles[onboarding_page]
	onboarding_body.text = bodies[onboarding_page]
	onboarding_next_button.text = "장터 열기" if onboarding_page == 2 else "다음"


func _advance_onboarding() -> void:
	if onboarding_page < 2:
		_show_onboarding_page(onboarding_page + 1)
		return
	_finish_onboarding()


func _finish_onboarding() -> void:
	onboarding_complete = true
	current_stage = "market"
	commercial_shell.hide()
	_render_market()
	_show_panel(market_panel)
	_set_status("첫 거래를 시작하세요. 수상한 매물을 하나 골라 판매자에게 말을 걸어보세요.")
	_save_game()


func _reset_core_progress() -> void:
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
	last_result_record = {}
	home_query = ""
	home_tab = "recommended"
	home_category = "전체"
	merchant_day = 1
	merchant_reputation = 0
	daily_goal_progress = 0
	daily_goal_claimed = false
	last_progress_message = ""

	upgrade_levels = {
		"storage":0,
		"notebook":0,
		"appraisal":0,
		"network":0,
		"routes":0
	}
	current_district_id = "night_market"
	market_visits_remaining = _daily_market_visit_capacity()
	day_start_gold = STARTING_GOLD
	last_day_summary = {}
	day_event_id = ""
	seller_relationships = {}
	selected_relationship_seller_index = 0
	_ensure_seller_relationships()
	collection_records = {}
	collection_goal_claimed = {}
	achievement_unlocks = {}
	selected_collection_index = 0
	last_collection_reward = ""
	tutorial_flags = {}
	active_context_tip = ""


func _merchant_rank() -> String:
	if merchant_reputation >= 600:
		return "어둠마을 상인"
	if merchant_reputation >= 300:
		return "기묘품 중개상"
	if merchant_reputation >= 150:
		return "골목 상인"
	if merchant_reputation >= 60:
		return "동네 감정꾼"
	return "견습 물건상"


func _apply_trade_progress(profit: int, listing: Dictionary) -> Dictionary:
	var previous_rank = _merchant_rank()
	var reputation_gain = 10
	if profit > 0:
		reputation_gain += 5
	if listing.get("discovered_clues", []).size() >= 2:
		reputation_gain += 2
	merchant_reputation += reputation_gain

	var goal_gold = 0
	var goal_reputation = 0
	if daily_goal_progress < 1:
		daily_goal_progress = 1
	if daily_goal_progress >= 1 and not daily_goal_claimed:
		daily_goal_claimed = true
		goal_gold = 500
		goal_reputation = 10
		gold += goal_gold
		merchant_reputation += goal_reputation

	var total_rep = reputation_gain + goal_reputation
	last_progress_message = "평판 +%d" % total_rep
	if goal_gold > 0:
		last_progress_message += " · 첫 거래 목표 완료 +%sG" % _money(goal_gold)
	var new_rank = _merchant_rank()
	if new_rank != previous_rank:
		last_progress_message += " · 등급 상승: %s" % new_rank
	return {
		"reputation_gain":total_rep,
		"goal_gold":goal_gold,
		"rank":_merchant_rank()
	}


func _default_seller_relationship() -> Dictionary:
	return {
		"points":0,
		"chats":0,
		"purchases":0,
		"last_day":0,
		"last_memory":"",
		"story_step":0,
		"story_seen_step":0,
		"special_offer_ready":false,
		"special_offer_claimed":false
	}


func _normalize_seller_relationship(raw: Dictionary) -> Dictionary:
	var base = _default_seller_relationship()
	for key in base.keys():
		if raw.has(key):
			base[key] = raw[key]
	base["points"] = max(0, int(base["points"]))
	base["chats"] = max(0, int(base["chats"]))
	base["purchases"] = max(0, int(base["purchases"]))
	base["last_day"] = max(0, int(base["last_day"]))
	base["story_step"] = clamp(int(base["story_step"]), 0, 3)
	base["story_seen_step"] = clamp(int(base["story_seen_step"]), 0, int(base["story_step"]))
	base["special_offer_ready"] = bool(base["special_offer_ready"])
	base["special_offer_claimed"] = bool(base["special_offer_claimed"])
	return base


func _ensure_seller_relationships() -> void:
	for seller in Content.SELLERS:
		var seller_id = str(seller.get("id", ""))
		var existing: Dictionary = seller_relationships.get(seller_id, {})
		seller_relationships[seller_id] = _normalize_seller_relationship(existing)


func _seller_definition(seller_id: String) -> Dictionary:
	for seller in Content.SELLERS:
		if str(seller.get("id", "")) == seller_id:
			return seller
	return {}


func _item_definition(item_id: String) -> Dictionary:
	for item in Content.ITEMS:
		if str(item.get("id", "")) == item_id:
			return item
	return {}


func _seller_relationship(seller_id: String) -> Dictionary:
	if not seller_relationships.has(seller_id):
		seller_relationships[seller_id] = _default_seller_relationship()
	return _normalize_seller_relationship(seller_relationships[seller_id])


func _relationship_stage_name(points: int) -> String:
	var stage_name = "낯선 사이"
	for stage in Content.SELLER_RELATIONSHIP_THRESHOLDS:
		if points >= int(stage.get("points", 0)):
			stage_name = str(stage.get("name", stage_name))
	return stage_name


func _refresh_seller_story_state(seller_id: String, state: Dictionary) -> Dictionary:
	var story: Dictionary = Content.SELLER_STORIES.get(seller_id, {})
	if story.is_empty():
		return state
	var unlocked = 0
	for beat in story.get("beats", []):
		if int(state.get("points", 0)) >= int(beat.get("threshold", 999999)):
			unlocked += 1
	state["story_step"] = max(int(state.get("story_step", 0)), unlocked)
	if int(state["story_step"]) >= 3 and not bool(state.get("special_offer_claimed", false)):
		state["special_offer_ready"] = true
	return state


func _add_seller_relationship(
	seller_id: String,
	points: int,
	chat_delta: int = 0,
	purchase_delta: int = 0,
	memory: String = ""
) -> Dictionary:
	if seller_id.is_empty():
		return {}
	var state = _seller_relationship(seller_id)
	state["points"] = max(0, int(state["points"]) + points)
	state["chats"] = max(0, int(state["chats"]) + chat_delta)
	state["purchases"] = max(0, int(state["purchases"]) + purchase_delta)
	if not memory.is_empty():
		state["last_day"] = merchant_day
		state["last_memory"] = memory
	state = _refresh_seller_story_state(seller_id, state)
	seller_relationships[seller_id] = state
	_refresh_collection_achievements()
	return state


func _apply_relationship_context(listing: Dictionary) -> Dictionary:
	if listing.is_empty():
		return listing
	var seller_id = str(listing.get("seller", {}).get("id", ""))
	var state = _seller_relationship(seller_id)
	listing["relationship_points"] = int(state.get("points", 0))
	listing["relationship_stage"] = _relationship_stage_name(int(state.get("points", 0)))
	listing["relationship_story_step"] = int(state.get("story_step", 0))
	return listing


func _append_unseen_story_messages(listing: Dictionary) -> Dictionary:
	if listing.is_empty():
		return listing
	var seller_id = str(listing.get("seller", {}).get("id", ""))
	var state = _seller_relationship(seller_id)
	var story: Dictionary = Content.SELLER_STORIES.get(seller_id, {})
	if story.is_empty():
		return listing
	var unlocked = int(state.get("story_step", 0))
	var seen = int(state.get("story_seen_step", 0))
	if unlocked <= seen:
		return listing

	var history: Array = listing.get("chat_history", []).duplicate(true)
	var beats: Array = story.get("beats", [])
	for step in range(seen + 1, unlocked + 1):
		if step - 1 >= beats.size():
			break
		var beat: Dictionary = beats[step - 1]
		history.append({
			"speaker":"seller",
			"text":str(beat.get("message", "")),
			"story":true,
			"story_title":str(beat.get("title", "개인 이야기"))
		})
	listing["chat_history"] = history
	state["story_seen_step"] = unlocked
	state["last_day"] = merchant_day
	if unlocked > 0 and unlocked - 1 < beats.size():
		state["last_memory"] = "DAY %d · 개인 이야기 ‘%s’을 들었다." % [
			merchant_day,
			str(beats[unlocked - 1].get("title", ""))
		]
	seller_relationships[seller_id] = state
	return listing


func _district_index_for_seller(seller_id: String) -> int:
	for i in range(Content.DISTRICTS.size()):
		if Content.DISTRICTS[i].get("seller_ids", []).has(seller_id):
			return i
	return -1


func _inject_relationship_special_listing() -> void:
	var district = _district_definition(current_district_id)
	if district.is_empty() or market_items.is_empty():
		return
	var ready_ids = []
	for seller_id_value in district.get("seller_ids", []):
		var seller_id = str(seller_id_value)
		var state = _seller_relationship(seller_id)
		if bool(state.get("special_offer_ready", false)) and not bool(state.get("special_offer_claimed", false)):
			ready_ids.append(seller_id)
	if ready_ids.is_empty():
		return

	var choose_index = (merchant_day + market_visits_remaining) % ready_ids.size()
	var seller_id = str(ready_ids[choose_index])
	var story: Dictionary = Content.SELLER_STORIES.get(seller_id, {})
	var signature_item = _item_definition(str(story.get("signature_item", "")))
	if signature_item.is_empty():
		return

	var special_item = signature_item.duplicate(true)
	special_item["rarity_weights"] = {"희귀":0.45, "영웅":0.35, "전설":0.20}
	var special_listing = engine.generate_listing(special_item, [seller_id])
	special_listing["relationship_special"] = true
	special_listing["relationship_seller_id"] = seller_id
	special_listing["listing_story"] = str(story.get("special_post", special_listing.get("listing_story", "")))
	special_listing["district_id"] = current_district_id
	special_listing["district_name"] = str(district.get("name", ""))
	special_listing = _apply_relationship_context(special_listing)
	market_items[0] = special_listing


func _upgrade_definition(upgrade_id: String) -> Dictionary:
	for upgrade in Content.UPGRADES:
		if str(upgrade.get("id", "")) == upgrade_id:
			return upgrade
	return {}


func _upgrade_level(upgrade_id: String) -> int:
	return max(0, int(upgrade_levels.get(upgrade_id, 0)))


func _upgrade_value(upgrade_id: String) -> int:
	var upgrade = _upgrade_definition(upgrade_id)
	if upgrade.is_empty():
		return 0
	var level = _upgrade_level(upgrade_id)
	if level <= 0:
		return int(upgrade.get("base_value", 0))
	var levels: Array = upgrade.get("levels", [])
	var index = clamp(level - 1, 0, max(0, levels.size() - 1))
	return int(levels[index].get("value", upgrade.get("base_value", 0)))


func _inventory_capacity() -> int:
	return _upgrade_value("storage")


func _market_investigation_capacity() -> int:
	return _upgrade_value("notebook")


func _professional_appraisal_discount() -> int:
	return _upgrade_value("appraisal")


func _quote_request_capacity() -> int:
	return _upgrade_value("network")


func _daily_market_visit_capacity() -> int:
	return _upgrade_value("routes")


func _professional_appraisal_cost(listing: Dictionary) -> int:
	var base_cost = engine.professional_appraisal_cost(listing)
	var discount = _professional_appraisal_discount()
	if discount <= 0:
		return base_cost
	var step = max(1, int(Content.INFORMATION_COST_ROUND_TO))
	var discounted = float(base_cost) * (1.0 - float(discount) / 100.0)
	return max(step, int(round(discounted / float(step))) * step)


func _next_rank_info() -> Dictionary:
	for entry in [
		{"rep":60,"name":"동네 감정꾼"},
		{"rep":150,"name":"골목 상인"},
		{"rep":300,"name":"기묘품 중개상"},
		{"rep":600,"name":"어둠마을 상인"}
	]:
		if merchant_reputation < int(entry["rep"]):
			return entry
	return {"rep":600,"name":"최고 등급"}


func _render_workshop() -> void:
	_update_header()
	workshop_gold_label.text = "%s G" % _money(gold)
	workshop_rank_label.text = "%s · 평판 %d" % [_merchant_rank(), merchant_reputation]
	var next_rank = _next_rank_info()
	if str(next_rank["name"]) == "최고 등급":
		workshop_progress_label.text = "최고 상인 등급 달성"
	else:
		workshop_progress_label.text = "다음 등급 %s · 평판 %d까지 %d" % [
			str(next_rank["name"]),
			int(next_rank["rep"]),
			max(0, int(next_rank["rep"]) - merchant_reputation)
		]
	var unlocked_names = []
	for district in Content.DISTRICTS:
		if _district_unlocked(district):
			unlocked_names.append(str(district["name"]))
	workshop_unlock_label.text = "열린 상권 · %s" % " · ".join(unlocked_names)

	for i in range(upgrade_cards.size()):
		if i >= Content.UPGRADES.size():
			upgrade_cards[i].hide()
			continue
		upgrade_cards[i].show()
		var upgrade: Dictionary = Content.UPGRADES[i]
		var upgrade_id = str(upgrade["id"])
		var level = _upgrade_level(upgrade_id)
		var levels: Array = upgrade.get("levels", [])
		var current_value = _upgrade_value(upgrade_id)
		upgrade_name_labels[i].text = str(upgrade["name"])
		upgrade_level_labels[i].text = "Lv.%d / %d" % [level, levels.size()]
		upgrade_description_labels[i].text = str(upgrade["description"])
		upgrade_effect_labels[i].text = "현재 효과 · %d%s" % [current_value, str(upgrade.get("unit", ""))]
		if level >= levels.size():
			upgrade_requirement_labels[i].text = "모든 업그레이드를 완료했습니다."
			upgrade_buy_buttons[i].text = "최대 단계"
			upgrade_buy_buttons[i].disabled = true
			continue
		var next: Dictionary = levels[level]
		var rep_need = int(next.get("reputation", 0))
		var cost = int(next.get("cost", 0))
		upgrade_requirement_labels[i].text = "다음 효과 %d%s · 평판 %d · %sG" % [
			int(next.get("value", current_value)),
			str(upgrade.get("unit", "")),
			rep_need,
			_money(cost)
		]
		if merchant_reputation < rep_need:
			upgrade_buy_buttons[i].text = "평판 %d 필요" % rep_need
			upgrade_buy_buttons[i].disabled = true
		elif gold < cost:
			upgrade_buy_buttons[i].text = "%sG 필요" % _money(cost)
			upgrade_buy_buttons[i].disabled = true
		else:
			upgrade_buy_buttons[i].text = "%sG로 업그레이드" % _money(cost)
			upgrade_buy_buttons[i].disabled = false


func _go_workshop() -> void:
	current_stage = "workshop"
	_render_workshop()
	_show_panel(workshop_panel)
	_set_status("평판으로 새 단계가 열리고, 골드를 투자해 거래 능력을 확장할 수 있습니다.")
	_save_game()


func _go_relationships() -> void:
	current_stage = "relationships"
	_render_relationships()
	_show_panel(relationships_panel)
	_set_status("괴물들과 쌓인 관계, 최근 기억, 개인 이야기 진행을 확인하세요.")
	_save_game()


func _render_relationships() -> void:
	_ensure_seller_relationships()
	relationship_list.clear()
	for seller in Content.SELLERS:
		var seller_id = str(seller.get("id", ""))
		var state = _seller_relationship(seller_id)
		var points = int(state.get("points", 0))
		var label = "%s · %s · 관계 %d" % [
			Art.seller_name(seller),
			_relationship_stage_name(points),
			points
		]
		if int(state.get("story_step", 0)) > int(state.get("story_seen_step", 0)):
			label += " · 새 이야기"
		if bool(state.get("special_offer_ready", false)) and not bool(state.get("special_offer_claimed", false)):
			label += " · 전용 매물"
		relationship_list.add_item(label, Art.texture_for("sellers", seller_id), true)
	if Content.SELLERS.is_empty():
		return
	selected_relationship_seller_index = clamp(selected_relationship_seller_index, 0, Content.SELLERS.size() - 1)
	relationship_list.select(selected_relationship_seller_index)
	_render_relationship_detail()


func _relationship_seller_selected(index: int) -> void:
	selected_relationship_seller_index = clamp(index, 0, max(0, Content.SELLERS.size() - 1))
	_render_relationship_detail()
	_save_game()


func _render_relationship_detail() -> void:
	if Content.SELLERS.is_empty():
		return
	var seller: Dictionary = Content.SELLERS[selected_relationship_seller_index]
	var seller_id = str(seller.get("id", ""))
	var state = _seller_relationship(seller_id)
	var points = int(state.get("points", 0))
	var story: Dictionary = Content.SELLER_STORIES.get(seller_id, {})
	var beats: Array = story.get("beats", [])
	var story_step = int(state.get("story_step", 0))

	relationship_portrait.texture = Art.texture_for("sellers", seller_id)
	relationship_name.text = Art.seller_name(seller)
	relationship_neighborhood.text = "%s · %s" % [
		str(seller.get("neighborhood", "어둠마을")),
		str(seller.get("profile", ""))
	]
	relationship_stage_label.text = "%s · 관계 %d" % [_relationship_stage_name(points), points]
	relationship_stats.text = "대화 %d회 · 구매 %d회 · 마지막 만남 %s" % [
		int(state.get("chats", 0)),
		int(state.get("purchases", 0)),
		("DAY %d" % int(state.get("last_day", 0))) if int(state.get("last_day", 0)) > 0 else "없음"
	]
	var memory = str(state.get("last_memory", "")).strip_edges()
	relationship_memory.text = memory if not memory.is_empty() else "아직 함께한 거래가 없습니다."

	var story_lines = ["%s · %d / 3" % [str(story.get("title", "개인 이야기")), story_step]]
	if story_step > 0 and story_step - 1 < beats.size():
		story_lines.append("현재 · %s" % str(beats[story_step - 1].get("title", "")))
	if story_step < beats.size():
		var next_beat: Dictionary = beats[story_step]
		story_lines.append("다음 이야기 · 관계 %d에서 해금" % int(next_beat.get("threshold", 0)))
	else:
		story_lines.append("모든 이야기를 들었습니다.")
	relationship_story.text = "\n".join(story_lines)

	var signature_item = _item_definition(str(story.get("signature_item", "")))
	var signature_name = str(signature_item.get("name", "특별한 물건"))
	if bool(state.get("special_offer_claimed", false)):
		relationship_special.text = "단골 전용 매물 · 거래 완료 · %s" % signature_name
	elif bool(state.get("special_offer_ready", false)):
		relationship_special.text = "단골 전용 매물 준비됨 · %s\n이 판매자의 동네 장터를 방문하면 먼저 볼 수 있습니다." % signature_name
	else:
		relationship_special.text = "단골 전용 매물 · 개인 이야기 3 / 3에서 해금"

	var district_index = _district_index_for_seller(seller_id)
	relationship_visit_button.disabled = district_index < 0
	if district_index >= 0:
		var district: Dictionary = Content.DISTRICTS[district_index]
		if not _district_unlocked(district):
			relationship_visit_button.disabled = true
			relationship_visit_button.text = "평판 %d 필요 · %s" % [
				int(district.get("unlock_reputation", 0)),
				str(district.get("name", "상권"))
			]
		elif current_district_id == str(district.get("id", "")) and market_items.size() == 3:
			relationship_visit_button.disabled = false
			relationship_visit_button.text = "현재 %s 장터 보기" % str(district.get("name", "상권"))
		elif market_visits_remaining <= 0:
			relationship_visit_button.disabled = true
			relationship_visit_button.text = "오늘 장터 방문 기회 없음"
		else:
			relationship_visit_button.disabled = false
			relationship_visit_button.text = "%s 장터 보기" % str(district.get("name", "상권"))


func _visit_relationship_seller() -> void:
	if Content.SELLERS.is_empty():
		return
	var seller_id = str(Content.SELLERS[selected_relationship_seller_index].get("id", ""))
	var district_index = _district_index_for_seller(seller_id)
	if district_index >= 0:
		_enter_district(district_index)


func _default_collection_record() -> Dictionary:
	return {
		"discovered":false,
		"appraisals":0,
		"sales":0,
		"states":[],
		"highest_rarity":"",
		"best_profit":0,
		"total_profit":0,
		"last_day":0
	}


func _collection_record(item_id: String) -> Dictionary:
	var base = _default_collection_record()
	var raw = collection_records.get(item_id, {})
	if typeof(raw) == TYPE_DICTIONARY:
		for key in base.keys():
			if raw.has(key):
				base[key] = raw[key]
	base["appraisals"] = max(0, int(base["appraisals"]))
	base["sales"] = max(0, int(base["sales"]))
	base["best_profit"] = int(base["best_profit"])
	base["total_profit"] = int(base["total_profit"])
	base["last_day"] = max(0, int(base["last_day"]))
	var normalized_states: Array = []
	for state_value in base.get("states", []):
		var state_text = str(state_value)
		if state_text in ["진품", "모조품", "결함품"] and not normalized_states.has(state_text):
			normalized_states.append(state_text)
	base["states"] = normalized_states
	return base


func _rarity_rank(rarity: String) -> int:
	var order = ["", "일반", "고급", "희귀", "영웅", "전설"]
	return order.find(rarity)


func _record_collection_discovery(listing: Dictionary, source: String, profit: int = 0, grant_rewards: bool = true) -> Dictionary:
	var item_id = str(listing.get("item_id", ""))
	if item_id.is_empty():
		return {}
	var record = _collection_record(item_id)
	record["discovered"] = true
	var actual_state = str(listing.get("state", ""))
	if actual_state in ["진품", "모조품", "결함품"] and not record["states"].has(actual_state):
		record["states"].append(actual_state)
	var rarity = str(listing.get("rarity", ""))
	if _rarity_rank(rarity) > _rarity_rank(str(record.get("highest_rarity", ""))):
		record["highest_rarity"] = rarity
	if source == "appraisal":
		record["appraisals"] = int(record["appraisals"]) + 1
	elif source == "sale":
		record["sales"] = int(record["sales"]) + 1
		record["total_profit"] = int(record["total_profit"]) + profit
		record["best_profit"] = max(int(record["best_profit"]), profit)
	record["last_day"] = merchant_day
	collection_records[item_id] = record

	_refresh_collection_achievements()
	var reward = {"gold":0, "reputation":0, "goals":[]}
	if grant_rewards:
		reward = _claim_completed_collection_goals()
		if int(reward["gold"]) > 0 or int(reward["reputation"]) > 0:
			last_collection_reward = "수집 목표 보상 · +%sG · 평판 +%d" % [
				_money(int(reward["gold"])),
				int(reward["reputation"])
			]
		else:
			last_collection_reward = ""
		_update_header()
	return reward


func _collection_discovered_count() -> int:
	var count = 0
	for item in Content.ITEMS:
		if bool(_collection_record(str(item.get("id", ""))).get("discovered", false)):
			count += 1
	return count


func _collection_discovered_states() -> Array:
	var result: Array = []
	for item_id in collection_records.keys():
		for state_value in _collection_record(str(item_id)).get("states", []):
			var state_text = str(state_value)
			if not result.has(state_text):
				result.append(state_text)
	return result


func _collection_total_profit() -> int:
	var total = 0
	for item_id in collection_records.keys():
		total += int(_collection_record(str(item_id)).get("total_profit", 0))
	return total


func _collection_set_progress(set_data: Dictionary) -> int:
	var progress = 0
	for item_id_value in set_data.get("item_ids", []):
		if bool(_collection_record(str(item_id_value)).get("discovered", false)):
			progress += 1
	return progress


func _completed_collection_sets() -> int:
	var completed = 0
	for set_data in Content.COLLECTION_SETS:
		var ids: Array = set_data.get("item_ids", [])
		if not ids.is_empty() and _collection_set_progress(set_data) >= ids.size():
			completed += 1
	return completed


func _collection_goal_progress(goal: Dictionary) -> int:
	match str(goal.get("kind", "")):
		"items":
			return _collection_discovered_count()
		"sets":
			return _completed_collection_sets()
		_:
			return 0


func _claim_completed_collection_goals() -> Dictionary:
	var reward_gold = 0
	var reward_reputation = 0
	var claimed: Array = []
	for goal in Content.LONG_TERM_GOALS:
		var goal_id = str(goal.get("id", ""))
		if bool(collection_goal_claimed.get(goal_id, false)):
			continue
		if _collection_goal_progress(goal) < int(goal.get("target", 0)):
			continue
		collection_goal_claimed[goal_id] = true
		var goal_gold = int(goal.get("reward_gold", 0))
		var goal_rep = int(goal.get("reward_reputation", 0))
		reward_gold += goal_gold
		reward_reputation += goal_rep
		claimed.append(goal_id)
	gold += reward_gold
	merchant_reputation += reward_reputation
	return {"gold":reward_gold, "reputation":reward_reputation, "goals":claimed}


func _achievement_condition(achievement_id: String) -> bool:
	match achievement_id:
		"first_truth":
			return _collection_discovered_count() >= 1
		"three_states":
			return _collection_discovered_states().size() >= 3
		"six_items":
			return _collection_discovered_count() >= 6
		"one_set":
			return _completed_collection_sets() >= 1
		"all_items":
			return _collection_discovered_count() >= Content.ITEMS.size()
		"trusted_seller":
			for seller_id in seller_relationships.keys():
				if int(_seller_relationship(str(seller_id)).get("points", 0)) >= 12:
					return true
			return false
		"profit_10000":
			return _collection_total_profit() >= 10000
		_:
			return false


func _refresh_collection_achievements() -> void:
	for achievement in Content.ACHIEVEMENTS:
		var achievement_id = str(achievement.get("id", ""))
		if achievement_unlocks.has(achievement_id):
			continue
		if _achievement_condition(achievement_id):
			achievement_unlocks[achievement_id] = merchant_day


func _migrate_legacy_collection_without_rewards() -> void:
	if not collection_records.is_empty():
		_refresh_collection_achievements()
		return
	var item_id = str(last_result_record.get("item_id", ""))
	if not item_id.is_empty():
		var listing = {
			"item_id":item_id,
			"state":str(last_result_record.get("state", "")),
			"rarity":str(last_result_record.get("rarity", ""))
		}
		_record_collection_discovery(listing, "sale", int(last_result_record.get("profit", 0)), false)
	for legacy_entry in rare_items:
		var legacy_text = str(legacy_entry)
		for item in Content.ITEMS:
			var legacy_listing = {"item_id":str(item.get("id", "")), "name":str(item.get("name", ""))}
			var display_name = Art.item_name(legacy_listing)
			if legacy_text.begins_with(display_name):
				var record = _collection_record(str(item.get("id", "")))
				record["discovered"] = true
				for rarity in ["전설", "영웅", "희귀", "고급", "일반"]:
					if legacy_text.contains(rarity):
						record["highest_rarity"] = rarity
						break
				collection_records[str(item.get("id", ""))] = record
	_refresh_collection_achievements()


func _go_collection() -> void:
	current_stage = "collection"
	_render_collection()
	_show_panel(collection_panel)
	_set_status("감정하거나 거래를 끝낸 물건의 정체와 장기 수집 목표를 확인하세요.")
	_save_game()


func _collection_item_selected(index: int) -> void:
	selected_collection_index = clamp(index, 0, max(0, Content.ITEMS.size() - 1))
	_render_collection_detail()
	_save_game()


func _render_collection() -> void:
	_refresh_collection_achievements()
	var discovered_count = _collection_discovered_count()
	var total_items = Content.ITEMS.size()
	collection_completion_label.text = "%d / %d" % [discovered_count, total_items]
	var states = _collection_discovered_states()
	collection_summary_text.text = "도감 %d/%d · 실제 상태 %d/3 · 완성 세트 %d/%d\n거래 누적 순이익 %s" % [
		discovered_count,
		total_items,
		states.size(),
		_completed_collection_sets(),
		Content.COLLECTION_SETS.size(),
		_signed_money(_collection_total_profit())
	]

	collection_item_list.clear()
	for item in Content.ITEMS:
		var item_id = str(item.get("id", ""))
		var record = _collection_record(item_id)
		var discovered = bool(record.get("discovered", false))
		var listing = {"item_id":item_id, "name":str(item.get("name", ""))}
		var label = "%s · %s" % [
			Art.item_name(listing) if discovered else "???",
			(str(record.get("highest_rarity", "기록됨")) if discovered else "미발견")
		]
		var icon = Art.texture_for("items", item_id) if discovered else Art.texture_for("ui", "fallback")
		collection_item_list.add_item(label, icon, true)
	selected_collection_index = clamp(selected_collection_index, 0, max(0, Content.ITEMS.size() - 1))
	if collection_item_list.item_count > 0:
		collection_item_list.select(selected_collection_index)
	_render_collection_detail()

	var set_lines: Array = []
	for set_data in Content.COLLECTION_SETS:
		var progress = _collection_set_progress(set_data)
		var total = set_data.get("item_ids", []).size()
		set_lines.append("%s %s %d/%d · %s" % [
			"✓" if progress >= total else "•",
			str(set_data.get("name", "세트")),
			progress,
			total,
			str(set_data.get("description", ""))
		])
	collection_sets_text.text = "\n".join(set_lines)

	var goal_lines: Array = []
	for goal in Content.LONG_TERM_GOALS:
		var progress = _collection_goal_progress(goal)
		var target = int(goal.get("target", 0))
		var claimed = bool(collection_goal_claimed.get(str(goal.get("id", "")), false))
		goal_lines.append("%s %s · %d/%d · 보상 %sG + 평판 %d" % [
			"✓" if claimed else "•",
			str(goal.get("name", "장기 목표")),
			min(progress, target),
			target,
			_money(int(goal.get("reward_gold", 0))),
			int(goal.get("reward_reputation", 0))
		])
	collection_goals_text.text = "\n".join(goal_lines)

	var achievement_lines: Array = []
	for achievement in Content.ACHIEVEMENTS:
		var achievement_id = str(achievement.get("id", ""))
		var unlocked = achievement_unlocks.has(achievement_id)
		var suffix = " · DAY %d" % int(achievement_unlocks[achievement_id]) if unlocked else ""
		achievement_lines.append("%s %s%s\n  %s" % [
			"✓" if unlocked else "□",
			str(achievement.get("name", "업적")),
			suffix,
			str(achievement.get("description", ""))
		])
	collection_achievements_text.text = "\n".join(achievement_lines)


func _render_collection_detail() -> void:
	if Content.ITEMS.is_empty():
		return
	var item: Dictionary = Content.ITEMS[selected_collection_index]
	var item_id = str(item.get("id", ""))
	var record = _collection_record(item_id)
	var discovered = bool(record.get("discovered", false))
	if not discovered:
		collection_item_art.texture = Art.texture_for("ui", "fallback")
		collection_item_name.text = "???"
		collection_item_status.text = "미발견"
		collection_detail_text.text = "전문 감정을 받거나 거래를 끝내 실제 정체를 확인하면 이 물건이 수집 장부에 기록됩니다."
		return

	var listing = {"item_id":item_id, "name":str(item.get("name", ""))}
	collection_item_art.texture = Art.texture_for("items", item_id)
	collection_item_name.text = Art.item_name(listing)
	var states: Array = record.get("states", [])
	collection_item_status.text = "%s · %s" % [
		str(item.get("category", "기타")),
		str(record.get("highest_rarity", "희귀도 미기록"))
	]
	collection_detail_text.text = "발견한 실제 상태 · %s\n전문 감정 %d회 · 판매 완료 %d회\n최고 거래 수익 %s · 누적 %s\n마지막 기록 DAY %d" % [
		(" · ".join(states) if not states.is_empty() else "아직 상태 기록 없음"),
		int(record.get("appraisals", 0)),
		int(record.get("sales", 0)),
		_signed_money(int(record.get("best_profit", 0))),
		_signed_money(int(record.get("total_profit", 0))),
		int(record.get("last_day", 0))
	]


func _buy_upgrade(index: int) -> void:
	if index < 0 or index >= Content.UPGRADES.size():
		return
	var upgrade: Dictionary = Content.UPGRADES[index]
	var upgrade_id = str(upgrade["id"])
	var level = _upgrade_level(upgrade_id)
	var levels: Array = upgrade.get("levels", [])
	if level >= levels.size():
		return
	var next: Dictionary = levels[level]
	var rep_need = int(next.get("reputation", 0))
	var cost = int(next.get("cost", 0))
	if merchant_reputation < rep_need or gold < cost:
		return
	var old_route_capacity = _daily_market_visit_capacity()
	gold -= cost
	upgrade_levels[upgrade_id] = level + 1
	if upgrade_id == "routes":
		var gain = max(0, _daily_market_visit_capacity() - old_route_capacity)
		market_visits_remaining += gain
	_update_header()
	_render_workshop()
	var upgrade_message = "%s Lv.%d 업그레이드 완료" % [str(upgrade["name"]), level + 1]
	_set_status(upgrade_message + " · 현재 플레이에 바로 적용됩니다.")
	_presentation_event("upgrade", "success")
	_show_toast(upgrade_message)
	_save_game()


func _district_definition(district_id: String) -> Dictionary:
	for district in Content.DISTRICTS:
		if str(district.get("id", "")) == district_id:
			return district
	return {}


func _district_unlocked(district: Dictionary) -> bool:
	return merchant_reputation >= int(district.get("unlock_reputation", 0))


func _day_event() -> Dictionary:
	if Content.DAY_EVENTS.is_empty():
		return {}
	if day_event_id.is_empty():
		day_event_id = str(Content.DAY_EVENTS[(merchant_day - 1) % Content.DAY_EVENTS.size()].get("id", ""))
	for event in Content.DAY_EVENTS:
		if str(event.get("id", "")) == day_event_id:
			return event
	return Content.DAY_EVENTS[(merchant_day - 1) % Content.DAY_EVENTS.size()]


func _render_town() -> void:
	_update_header()
	town_visits_label.text = "장터 방문 %d회 남음" % market_visits_remaining

	var event = _day_event()
	town_event_text.text = "오늘의 소문 · %s\n%s\n시장 영향 · %s" % [
		str(event.get("title", "조용한 하루")),
		str(event.get("description", "특별한 소문은 없습니다.")),
		str(event.get("effect_text", "특별한 시장 변화는 없습니다."))
	]

	last_day_panel.visible = not last_day_summary.is_empty()
	if last_day_panel.visible:
		last_day_text.text = "DAY %d 마감 · 거래 %d건 · 자산 변화 %s\n그날 소문 · %s" % [
			int(last_day_summary.get("day", max(1, merchant_day - 1))),
			int(last_day_summary.get("deals", 0)),
			_signed_money(int(last_day_summary.get("asset_delta", 0))),
			str(last_day_summary.get("event_title", "기록 없음"))
		]

	for i in range(district_cards.size()):
		if i >= Content.DISTRICTS.size():
			district_cards[i].hide()
			continue
		district_cards[i].show()
		var district: Dictionary = Content.DISTRICTS[i]
		var unlocked = _district_unlocked(district)
		var district_id = str(district.get("id", ""))
		district_arts[i].texture = Art.texture_for("ui", str(district.get("art_key", "market")))
		district_name_labels[i].text = str(district.get("name", "상권"))
		district_neighborhood_labels[i].text = str(district.get("neighborhoods", ""))
		district_description_labels[i].text = str(district.get("description", ""))
		district_enter_buttons[i].disabled = not unlocked or (market_visits_remaining <= 0 and not (current_district_id == district_id and market_items.size() == 3))
		if not unlocked:
			district_enter_buttons[i].text = "평판 %d 필요" % int(district.get("unlock_reputation", 0))
		elif current_district_id == district_id and market_items.size() == 3:
			district_enter_buttons[i].text = "현재 장터로 돌아가기"
		elif market_visits_remaining <= 0:
			district_enter_buttons[i].text = "오늘 방문 기회 없음"
		else:
			district_enter_buttons[i].text = "이 동네 장터 보기"

	end_day_button.text = "DAY %d 장사 마감" % merchant_day


func _go_town() -> void:
	_remember_home_position()
	current_stage = "town"
	_render_town()
	_show_panel(town_panel)
	_set_status("오늘 갈 상권을 고르거나, 장사를 마감하고 다음 날로 넘어가세요.")
	_save_game()


func _enter_district(index: int) -> void:
	if index < 0 or index >= Content.DISTRICTS.size():
		return
	var district: Dictionary = Content.DISTRICTS[index]
	if not _district_unlocked(district):
		_set_status("평판 %d이 되면 %s에 들어갈 수 있습니다." % [
			int(district.get("unlock_reputation", 0)),
			str(district.get("name", "이 상권"))
		])
		return
	var district_id = str(district.get("id", ""))
	if current_district_id == district_id and market_items.size() == 3:
		_go_market()
		return
	if market_visits_remaining <= 0:
		_set_status("오늘 장터 방문 기회를 모두 사용했습니다. 하루를 마감하세요.")
		return
	current_district_id = district_id
	_create_new_market(true, true, true)


func _end_day() -> void:
	var closing_event = _day_event()
	last_day_summary = {
		"day":merchant_day,
		"deals":today_deals,
		"asset_delta":gold - day_start_gold,
		"event_title":str(closing_event.get("title", "조용한 하루"))
	}
	merchant_day += 1
	today_deals = 0
	today_date = Time.get_date_string_from_system()
	daily_goal_progress = 0
	daily_goal_claimed = false
	market_visits_remaining = _daily_market_visit_capacity()
	day_start_gold = gold
	day_event_id = ""
	market_items = []
	selected_market_index = -1
	current_district_id = ""
	current_stage = "town"
	_update_header()
	_render_town()
	_show_panel(town_panel)
	var day_message = "DAY %d이 시작됐습니다." % merchant_day
	_set_status(day_message + " 새로운 상권과 매물을 확인하세요.")
	_presentation_event("day_end", "success")
	_show_toast(day_message)
	_save_game()


func _setup_options() -> void:
	resale_option.clear()
	for label in ["예상 재판매가 선택", "0~5,000G", "5,000~15,000G", "15,000~30,000G", "30,000G 이상"]:
		resale_option.add_item(label)


func _listing_matches_day_event(listing: Dictionary, event: Dictionary) -> bool:
	var affected_tags: Array = event.get("affected_tags", [])
	for tag_value in listing.get("tags", []):
		if affected_tags.has(str(tag_value)):
			return true
	return false


func _create_new_market(force: bool = false, save_after: bool = true, consume_visit: bool = false) -> void:
	if not force and market_items.size() == 3 and not _can_rotate_market():
		_set_status("새 매물로 넘기려면 조사 기회를 모두 쓰거나, 이 장터에서 실제 구매를 한 번 진행해야 합니다.")
		return
	if consume_visit and market_visits_remaining <= 0:
		_set_status("오늘 장터 방문 기회를 모두 사용했습니다. 동네 화면에서 하루를 마감하세요.")
		return

	var district = _district_definition(current_district_id)
	if district.is_empty():
		current_district_id = "night_market"
		district = _district_definition(current_district_id)

	var event = _day_event()
	var event_tags: Array = event.get("affected_tags", [])
	market_items = engine.generate_market_for_district(current_district_id, 3, event_tags)
	_inject_relationship_special_listing()

	var event_candidates: Array = []
	for i in range(market_items.size()):
		if bool(market_items[i].get("relationship_special", false)):
			continue
		if _listing_matches_day_event(market_items[i], event):
			event_candidates.append(i)
	var event_featured_index = -1
	if not event_candidates.is_empty():
		event_featured_index = int(event_candidates[(merchant_day + market_visits_remaining) % event_candidates.size()])

	for i in range(market_items.size()):
		market_items[i] = engine.apply_day_event_to_listing(
			market_items[i],
			event,
			i == event_featured_index
		)
		market_items[i] = _apply_relationship_context(market_items[i])
	if consume_visit:
		market_visits_remaining = max(0, market_visits_remaining - 1)
	home_scroll_offset = 0
	home_query = ""
	home_tab = "recommended"
	home_category = "전체"
	if is_instance_valid(search_input):
		search_input.text = ""
	market_scroll.scroll_vertical = 0
	investigation_remaining = _market_investigation_capacity()
	selected_market_index = -1
	current_stage = "market"
	_render_market()
	_show_panel(market_panel)
	_set_status("%s의 매물을 둘러보세요. 오늘 새 장터 방문은 %d회 남았습니다." % [
		str(district.get("name", "어둠마을")),
		market_visits_remaining
	])
	if save_after:
		_save_game()


func _request_next_market() -> void:
	if market_visits_remaining <= 0:
		_set_status("오늘 장터 방문 기회를 모두 사용했습니다. 동네 화면에서 하루를 마감하세요.")
		_render_market()
		return
	_create_new_market(false, true, true)


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
		var listing: Dictionary = _apply_relationship_context(market_items[i])
		market_items[i] = listing
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
	var district = _district_definition(current_district_id)
	var market_event = _day_event()
	market_info_label.text = "%s · 새 매물 %d · 거래 가능 %d · 확인 %d회\n오늘 소문 · %s" % [
		str(district.get("name", "어둠마을")),
		new_count,
		available_count,
		investigation_remaining,
		str(market_event.get("effect_text", "특별한 시장 변화 없음"))
	]
	_update_home_filter_controls()
	var can_rotate = _can_rotate_market()
	next_market_button.disabled = not can_rotate or market_visits_remaining <= 0
	next_market_button.text = "다음 장터 보기 · 오늘 %d회 남음" % market_visits_remaining
	if market_visits_remaining <= 0:
		next_market_hint.text = "오늘 방문 기회를 모두 썼어요. 동네에서 하루를 마감하면 새 장터가 열립니다."
	elif not can_rotate:
		next_market_hint.text = "남은 확인 기회를 모두 쓰거나 구매하면 다음 장터가 열립니다."
	elif investigation_remaining <= 0:
		next_market_hint.text = "확인 기회를 모두 썼어요. 다음 장터의 새 매물을 둘러볼 수 있습니다."
	else:
		next_market_hint.text = "이 장터에서 물건을 구매했어요. 남은 방문 기회로 다른 매물을 볼 수 있습니다."


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
	_presentation_event("open_listing", "light")
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
	var event_detail = ""
	if bool(listing.get("event_affected", false)):
		event_detail = "\n오늘 소문   %s" % str(listing.get("market_event_effect", "시장 영향 있음"))
	detail_info.text = "직거래   %s\n올린 지   %s\n가격 제안 가능%s" % [
		feed.public_meetup_text(listing),
		feed.public_age_text(listing),
		event_detail
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
	listing = _append_unseen_story_messages(_apply_relationship_context(listing))
	_sync_market_listing(listing)
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

		var action_id = str(option.get("id", ""))
		if action_id != "market":
			var seller_id = str(updated.get("seller", {}).get("id", ""))
			_add_seller_relationship(
				seller_id,
				1,
				1,
				0,
				"DAY %d · %s에 대해 대화했다." % [merchant_day, str(option.get("short_label", option.get("label", "물건")))]
			)
			updated = _apply_relationship_context(updated)
			updated = _append_unseen_story_messages(updated)

		_sync_market_listing(updated)
		_presentation_event("message_send", "light")
		_render_seller_chat()
		_set_status("판매자와 대화를 이어갔습니다.")
		_save_game()


func _start_deal() -> void:
	var listing = _current_market_listing()
	if listing.is_empty():
		return
	if owned_items.size() >= _inventory_capacity():
		_set_status("보관 선반이 가득 찼습니다. 보유품을 판매하거나 작업실에서 보관 공간을 늘리세요.")
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
	var storage_full = owned_items.size() >= _inventory_capacity()
	deal_submit_button.disabled = closed or storage_full
	deal_submit_button.text = "새 제안 불가" if closed else ("다시 제안 보내기" if rounds > 0 else "이 가격으로 제안 보내기")
	offer_slider.editable = not closed
	evidence_option.disabled = closed
	for button in deal_preset_buttons:
		button.disabled = closed

	buy_current_button.disabled = gold < current_price or storage_full
	buy_current_button.text = "%sG에 바로 거래" % _money(current_price)
	if storage_full:
		deal_purchase_warning.text = "보관 공간 %d/%d · 보유품을 정리하거나 작업실에서 확장하세요." % [owned_items.size(), _inventory_capacity()]
	elif gold < current_price:
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
	_presentation_event("offer_submit", "medium")
	var listing = _current_market_listing()
	if listing.is_empty():
		return
	if owned_items.size() >= _inventory_capacity():
		_set_status("보관 공간이 가득 차 새 물건을 살 수 없습니다.")
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
	if owned_items.size() >= _inventory_capacity():
		_set_status("보관 공간이 가득 찼습니다. 작업실의 보관 선반을 확장하거나 보유품을 판매하세요.")
		return
	if gold < price:
		_set_status("보유 골드가 부족합니다.")
		return

	gold -= price
	listing["listing_status"] = "구매 완료"
	listing["purchase_price"] = price

	var seller_id = str(listing.get("seller", {}).get("id", ""))
	var seller_state = _add_seller_relationship(
		seller_id,
		4,
		0,
		1,
		"DAY %d · %s을(를) %sG에 직거래했다." % [merchant_day, Art.item_name(listing), _money(price)]
	)
	if bool(listing.get("relationship_special", false)):
		seller_state["special_offer_ready"] = false
		seller_state["special_offer_claimed"] = true
		seller_relationships[seller_id] = seller_state
	listing = _apply_relationship_context(listing)
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
		"quote_requests_remaining": _quote_request_capacity(),
		"quote_capacity": _quote_request_capacity(),
		"selected_buyer_index": -1
	}
	owned_items.append(owned)
	selected_owned_index = owned_items.size() - 1
	selected_market_index = -1
	current_stage = "inventory"
	_update_header()
	_render_inventory()
	_show_panel(inventory_panel)
	var purchase_message = "%s에게서 물건을 받아왔습니다." % Art.seller_name(listing.get("seller", {}))
	_set_status(purchase_message + " 이제 감정할지, 바로 팔지, 보관할지 정할 수 있습니다.")
	_presentation_event("purchase", "success")
	_show_toast(purchase_message)
	_save_game()


func _go_market() -> void:
	_remember_home_position()
	selected_market_index = -1
	if market_items.size() != 3:
		_go_town()
		_set_status("현재 열려 있는 장터가 없습니다. 오늘 갈 상권을 고르세요.")
		return
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
	_set_status("보관 공간 %d/%d · 물건을 감정하거나 판매하고, 작업실에서 공간을 늘릴 수 있습니다." % [owned_items.size(), _inventory_capacity()])
	_save_game()


func _go_records() -> void:
	_remember_home_position()
	current_stage = "result"
	_render_records()
	_show_panel(result_panel)
	_set_status("최근 거래에서 무엇을 맞췄고 놓쳤는지 다시 확인할 수 있습니다.")
	_save_game()


func _render_records() -> void:
	_update_header()
	result_summary.text = last_result_text
	var structured = not last_result_record.is_empty()
	for control in [
		record_hero, record_money_panel, record_decision_title, record_decision_panel,
		record_analysis_panel, record_truth_title, record_truth_panel, record_seller_panel,
		record_assets_label
	]:
		control.visible = structured

	if structured:
		legacy_result_summary.visible = false
		record_recent_title.text = "최근 완료한 거래"
		record_item_art.texture = Art.texture_for("items", str(last_result_record.get("item_id", "")))
		record_item_name.text = str(last_result_record.get("item_name", "최근 거래"))
		record_buyer_line.text = "%s에 판매 · %s" % [
			str(last_result_record.get("buyer_name", "판매처")),
			str(last_result_record.get("buyer_reason", "거래 완료"))
		]
		var profit = int(last_result_record.get("profit", 0))
		record_profit_label.text = "순이익 %s" % _signed_money(profit)
		record_profit_label.add_theme_color_override(
			"font_color",
			Color("267a4f") if profit >= 0 else Color("b34b4b")
		)
		record_purchase_value.text = "%sG" % _money(int(last_result_record.get("purchase_price", 0)))
		record_cost_value.text = "%sG" % _money(int(last_result_record.get("info_cost", 0)))
		record_sale_value.text = "%sG" % _money(int(last_result_record.get("sale_price", 0)))

		var plan_lines: Array = last_result_record.get("plan_feedback", [])
		record_decision_text.text = "\n".join(plan_lines) if not plan_lines.is_empty() else "거래 계획을 따로 세우지 않았습니다."
		var analysis_lines: Array = last_result_record.get("analysis_lines", []).duplicate()
		var event_title = str(last_result_record.get("market_event_title", ""))
		var event_effect = str(last_result_record.get("market_event_effect", ""))
		if not event_title.is_empty():
			analysis_lines.append("• 그날 소문: %s" % event_title)
			if not event_effect.is_empty():
				analysis_lines.append("  %s" % event_effect)
			if bool(last_result_record.get("event_special", false)):
				analysis_lines.append("  이 물건은 소문으로 변동성이 커진 특별 매물이었다.")
		record_analysis_text.text = "\n".join(analysis_lines) if not analysis_lines.is_empty() else "추가 분석이 없습니다."

		record_truth_text.text = "%s · %s · %s\n실제 가치 %sG" % [
			str(last_result_record.get("state", "-")),
			str(last_result_record.get("rarity", "-")),
			str(last_result_record.get("condition", "-")),
			_money(int(last_result_record.get("actual_value", 0)))
		]
		record_seller_text.text = "판매자 관찰\n%s\n\n거래 후 공개된 실제 성향\n%s" % [
			str(last_result_record.get("seller_observation", "-")),
			str(last_result_record.get("seller_actual", "-"))
		]
		record_assets_label.text = "거래 후 자산  %sG" % _money(int(last_result_record.get("current_assets", gold)))
	elif not last_result_text.is_empty():
		legacy_result_summary.visible = true
		record_recent_title.text = "최근 완료한 거래 · 이전 버전 기록"
		legacy_result_summary.text = last_result_text
	else:
		legacy_result_summary.visible = true
		record_recent_title.text = "최근 완료한 거래"
		legacy_result_summary.text = "아직 완료한 거래가 없습니다.\n물건을 구매한 뒤 판매까지 마치면 손익과 판단 복기가 이곳에 기록됩니다."


func _render_inventory() -> void:
	$Margin/RootVBox/InventoryPanel/Scroll/Box/InventoryHelp.text = "보관 공간 %d/%d · 감정하거나 판매하고, 작업실에서 선반을 확장할 수 있습니다." % [owned_items.size(), _inventory_capacity()]
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
	var appraisal_cost = _professional_appraisal_cost(listing)
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
	var appraisal_cost = _professional_appraisal_cost(listing)
	if gold < appraisal_cost:
		return
	gold -= appraisal_cost
	owned["appraisal_cost"] = appraisal_cost
	owned["appraisal_data"] = engine.appraise(listing)
	owned_items[selected_owned_index] = owned
	var collection_reward = _record_collection_discovery(listing, "appraisal", 0, true)
	_update_header()
	_render_appraisal()
	var appraisal_status = "전문 감정으로 물건 자체의 정체와 추정 가치를 확인했습니다. 판매처 가격은 여전히 직접 알아봐야 합니다."
	if int(collection_reward.get("gold", 0)) > 0 or int(collection_reward.get("reputation", 0)) > 0:
		appraisal_status += " " + last_collection_reward
	_set_status(appraisal_status)
	_presentation_event("appraisal_reveal", "success")
	_show_toast("감정 완료 · %s" % Art.item_name(listing))
	if not last_collection_reward.is_empty():
		_show_toast(last_collection_reward, "goal_complete")
	_save_game()


func _open_sale() -> void:
	var owned = _current_owned()
	if owned.is_empty():
		return
	var current_quote_capacity = _quote_request_capacity()
	var old_quote_capacity = int(owned.get("quote_capacity", Content.QUOTE_REQUEST_BUDGET))
	if current_quote_capacity > old_quote_capacity:
		owned["quote_requests_remaining"] = int(owned.get("quote_requests_remaining", old_quote_capacity)) + (current_quote_capacity - old_quote_capacity)
		owned["quote_capacity"] = current_quote_capacity
	if owned.get("buyer_offers", []).is_empty():
		owned["buyer_offers"] = engine.make_buyer_offers(owned["listing"])
		owned["quote_requests_remaining"] = current_quote_capacity
		owned["quote_capacity"] = current_quote_capacity
		owned["selected_buyer_index"] = -1
	owned_items[selected_owned_index] = owned
	current_stage = "sale"
	_render_sale()
	_show_panel(sale_panel)
	_set_status("전문 판매처 3곳 중 최대 %d곳의 견적을 확인할 수 있습니다. 고물상 즉시가는 항상 보입니다." % _quote_request_capacity())
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

	quote_state.text = "전문 견적 %d/%d회 남음 · 요청한 곳만 가격 공개 · 고물상은 즉시가" % [quote_remaining, _quote_request_capacity()]

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
		sale_selected_label.text = "판매처를 선택하세요 · 전문 견적 최대 %d곳" % _quote_request_capacity()
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
	var progression_reward = _apply_trade_progress(profit, listing)
	var collection_reward = _record_collection_discovery(listing, "sale", profit, true)
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
	var analysis_lines: Array = []
	var discount = int(listing["asking"]) - purchase_price
	analysis_lines.append("✓ 희망가보다 %sG 낮게 구매" % _money(discount) if discount > 0 else "△ 희망가 그대로 구매")
	analysis_lines.append("✓ 발견 단서를 흥정 근거로 사용" if negotiation.get("evidence_used", []).size() > 0 else "△ 조사 단서를 흥정에 사용하지 않음")
	analysis_lines.append("• 정보 비용 %sG" % _money(info_cost))
	var best_possible = engine.best_offer_price(offers)
	analysis_lines.append("✓ 확인 가능한 최고 제안에 판매" if sale_price >= best_possible else "△ 다른 판매처에 더 높은 잠재 제안 %sG가 있었음" % _money(best_possible))
	analysis_lines.append("• 판매처: %s — %s" % [offer["name"], offer["reason"]])
	var analysis = "\n".join(analysis_lines)

	var seller: Dictionary = listing["seller"]
	var seller_personality: Dictionary = seller["personality"]
	var seller_review = "관찰 당시: %s\n실제 성향: %s" % [
		feed.seller_behavior_text(listing),
		str(seller_personality["name"])
	]

	last_result_record = {
		"item_id":str(listing.get("item_id", "")),
		"item_name":Art.item_name(listing),
		"buyer_name":str(offer.get("name", "판매처")),
		"buyer_reason":str(offer.get("reason", "거래 완료")),
		"purchase_price":purchase_price,
		"info_cost":info_cost,
		"sale_price":sale_price,
		"profit":profit,
		"plan_feedback":plan_feedback.duplicate(true),
		"analysis_lines":analysis_lines.duplicate(true),
		"seller_observation":feed.seller_behavior_text(listing),
		"seller_actual":str(seller_personality.get("name", "-")),
		"state":str(listing.get("state", "-")),
		"rarity":str(listing.get("rarity", "-")),
		"condition":str(listing.get("condition", "-")),
		"actual_value":int(listing.get("actual_value", 0)),
		"current_assets":gold,
		"reputation_gain":int(progression_reward.get("reputation_gain", 0)),
		"goal_gold":int(progression_reward.get("goal_gold", 0)),
		"merchant_rank":str(progression_reward.get("rank", _merchant_rank())),
		"collection_reward_gold":int(collection_reward.get("gold", 0)),
		"collection_reward_reputation":int(collection_reward.get("reputation", 0)),
		"market_event_id":str(listing.get("market_event_id", "")),
		"market_event_title":str(listing.get("market_event_title", "")),
		"market_event_effect":str(listing.get("market_event_effect", "")),
		"event_special":bool(listing.get("event_special", false))
	}

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
	var result_status = "이번 거래를 복기하세요. %s" % last_progress_message
	if not last_collection_reward.is_empty():
		result_status += " · " + last_collection_reward
	_set_status(result_status)
	_presentation_event("sale_complete", "success")
	_show_toast("거래 완료 · 순이익 %s" % _signed_money(profit))
	if not last_collection_reward.is_empty():
		_show_toast(last_collection_reward, "goal_complete")
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
	for panel in [town_panel, workshop_panel, relationships_panel, collection_panel, market_panel, detail_panel, seller_chat_panel, deal_panel, inventory_panel, appraisal_panel, sale_panel, result_panel]:
		panel.visible = panel == target

	var focus_mode = target == detail_panel or target == seller_chat_panel or target == deal_panel or target == appraisal_panel or target == sale_panel
	global_header.visible = not focus_mode
	meta_strip.visible = not focus_mode
	status_panel.visible = target != market_panel and not focus_mode
	nav_row.visible = not focus_mode

	town_nav_button.set_pressed_no_signal(current_stage in ["town", "workshop", "relationships", "collection"])
	market_nav_button.set_pressed_no_signal(current_stage in ["market", "detail", "chat", "deal"])
	inventory_nav_button.set_pressed_no_signal(current_stage in ["inventory", "appraisal", "sale"])
	records_nav_button.set_pressed_no_signal(current_stage == "result")

	_set_bgm_state(_bgm_state_for_target(target))
	_capture_base_font_sizes()
	_apply_accessibility_settings()
	_play_screen_enter(target)
	_maybe_show_context_tip(current_stage)


func _update_header() -> void:
	gold_label.text = "%s G" % _money(gold)
	detail_gold_label.text = "%s G" % _money(gold)
	chat_gold_label.text = "%s G" % _money(gold)
	deal_gold_label.text = "%s G" % _money(gold)
	appraisal_gold_label.text = "%s G" % _money(gold)
	sale_gold_label.text = "%s G" % _money(gold)
	inventory_count_label.text = "보유품 %d" % owned_items.size()
	day_label.text = "DAY %d" % merchant_day
	rank_label.text = _merchant_rank()
	reputation_label.text = "평판 %d" % merchant_reputation
	goal_label.text = (
		"오늘 목표 · 첫 거래 완료 ✓ · 장터 방문 %d회 남음" % market_visits_remaining
		if daily_goal_claimed
		else "오늘 목표 · 첫 거래 완료 %d/1 · 장터 방문 %d회 남음 · 보상 500G + 평판 10" % [daily_goal_progress, market_visits_remaining]
	)
	stats_label.text = "누적 %d회 · 오늘 %d회 · 최고 %s · 최저 %s" % [
		total_deals, today_deals, _signed_money(best_profit), _signed_money(worst_loss)
	]


func _configure_mobile_ui() -> void:
	var money_grid = $Margin/RootVBox/ResultPanel/Scroll/Box/MoneyPanel/Grid
	for label in find_children("*", "Label", true, false):
		if label.get_parent() == money_grid:
			label.autowrap_mode = TextServer.AUTOWRAP_OFF
		else:
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
	# v0.4+ uses an in-game day lifecycle. Keep the real date only as metadata;
	# changing the device date must not silently reset a virtual trading day.
	if today_date.is_empty():
		today_date = Time.get_date_string_from_system()


func _restore_stage() -> void:
	match current_stage:
		"town":
			_render_town()
			_show_panel(town_panel)
		"workshop":
			_render_workshop()
			_show_panel(workshop_panel)
		"relationships":
			_render_relationships()
			_show_panel(relationships_panel)
		"collection":
			_render_collection()
			_show_panel(collection_panel)
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
	_reset_core_progress()
	game_started = true
	onboarding_complete = false
	_create_new_market(true, false, true)
	_update_header()
	_show_onboarding_page(0)
	_save_game()


func _save_game() -> void:
	var payload = {
		"version": 36,
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
		"last_result_text": last_result_text,
		"last_result_record": last_result_record,
		"game_started": game_started,
		"onboarding_complete": onboarding_complete,
		"merchant_day": merchant_day,
		"merchant_reputation": merchant_reputation,
		"daily_goal_progress": daily_goal_progress,
		"daily_goal_claimed": daily_goal_claimed,
		"current_district_id": current_district_id,
		"market_visits_remaining": market_visits_remaining,
		"day_start_gold": day_start_gold,
		"last_day_summary": last_day_summary,
		"day_event_id": day_event_id,
		"upgrade_levels": upgrade_levels,
		"seller_relationships": seller_relationships,
		"selected_relationship_seller_index": selected_relationship_seller_index,
		"collection_records": collection_records,
		"collection_goal_claimed": collection_goal_claimed,
		"achievement_unlocks": achievement_unlocks,
		"selected_collection_index": selected_collection_index,
		"tutorial_flags": tutorial_flags
	}
	_write_save_payload(payload)


func _read_save_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func _write_save_payload(payload: Dictionary) -> bool:
	var primary_absolute = ProjectSettings.globalize_path(SAVE_PATH)
	var backup_absolute = ProjectSettings.globalize_path(SAVE_BACKUP_PATH)
	var temp_absolute = ProjectSettings.globalize_path(SAVE_TEMP_PATH)

	if FileAccess.file_exists(SAVE_PATH) and not _skip_backup_on_next_save:
		DirAccess.copy_absolute(primary_absolute, backup_absolute)

	var serialized = JSON.stringify(payload)
	var temp_file = FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
	if temp_file == null:
		return false
	temp_file.store_string(serialized)
	temp_file.close()

	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(primary_absolute)
	var rename_error = DirAccess.rename_absolute(temp_absolute, primary_absolute)
	if rename_error != OK:
		var fallback = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if fallback == null:
			return false
		fallback.store_string(serialized)
		fallback.close()
		if FileAccess.file_exists(SAVE_TEMP_PATH):
			DirAccess.remove_absolute(temp_absolute)

	if _skip_backup_on_next_save:
		# We loaded the backup because primary was invalid. Never copy the bad
		# primary over the good backup; repair both from the recovered payload.
		DirAccess.copy_absolute(primary_absolute, backup_absolute)
		_skip_backup_on_next_save = false
	return true


func _load_game() -> void:
	today_date = Time.get_date_string_from_system()
	var legacy_path = OS.get_user_data_dir().get_base_dir().path_join("괴물 중고마켓 MVP v0.2.2").path_join(SAVE_PATH.get_file())
	var parsed: Dictionary = {}
	var load_path = ""
	for candidate in [SAVE_PATH, SAVE_BACKUP_PATH, legacy_path]:
		var candidate_data = _read_save_dictionary(str(candidate))
		if candidate_data.is_empty():
			continue
		parsed = candidate_data
		load_path = str(candidate)
		break
	if parsed.is_empty():
		return
	if load_path == SAVE_BACKUP_PATH:
		save_recovery_notice = true
		_skip_backup_on_next_save = true
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
	investigation_remaining = int(parsed.get("investigation_remaining", _market_investigation_capacity()))
	selected_market_index = int(parsed.get("selected_market_index", -1))
	owned_items = parsed.get("owned_items", [])
	selected_owned_index = int(parsed.get("selected_owned_index", -1))
	current_stage = str(parsed.get("stage", "market"))
	last_result_text = str(parsed.get("last_result_text", ""))
	last_result_record = parsed.get("last_result_record", {})
	if last_result_record.is_empty() and not last_result_text.is_empty():
		last_result_record = _legacy_record_to_structured(last_result_text)

	# Old v0.2.x saves are real games even though these fields did not exist yet.
	game_started = bool(parsed.get("game_started", true))
	onboarding_complete = bool(parsed.get("onboarding_complete", true))
	merchant_day = max(1, int(parsed.get("merchant_day", 1)))
	merchant_reputation = max(0, int(parsed.get("merchant_reputation", total_deals * 15)))
	daily_goal_progress = clamp(int(parsed.get("daily_goal_progress", min(1, today_deals))), 0, 1)
	daily_goal_claimed = bool(parsed.get("daily_goal_claimed", today_deals > 0))

	var loaded_upgrades: Dictionary = parsed.get("upgrade_levels", {})
	for upgrade_id in upgrade_levels.keys():
		upgrade_levels[upgrade_id] = max(0, int(loaded_upgrades.get(upgrade_id, 0)))

	current_district_id = str(parsed.get("current_district_id", "night_market"))
	market_visits_remaining = clamp(
		int(parsed.get("market_visits_remaining", _daily_market_visit_capacity())),
		0,
		_daily_market_visit_capacity()
	)
	day_start_gold = int(parsed.get("day_start_gold", gold))
	last_day_summary = parsed.get("last_day_summary", {})
	day_event_id = str(parsed.get("day_event_id", ""))

	var loaded_relationships = parsed.get("seller_relationships", {})
	seller_relationships = loaded_relationships if typeof(loaded_relationships) == TYPE_DICTIONARY else {}
	selected_relationship_seller_index = clamp(
		int(parsed.get("selected_relationship_seller_index", 0)),
		0,
		max(0, Content.SELLERS.size() - 1)
	)
	_ensure_seller_relationships()

	var loaded_collection = parsed.get("collection_records", {})
	collection_records = loaded_collection if typeof(loaded_collection) == TYPE_DICTIONARY else {}
	var loaded_goals = parsed.get("collection_goal_claimed", {})
	collection_goal_claimed = loaded_goals if typeof(loaded_goals) == TYPE_DICTIONARY else {}
	var loaded_achievements = parsed.get("achievement_unlocks", {})
	achievement_unlocks = loaded_achievements if typeof(loaded_achievements) == TYPE_DICTIONARY else {}
	selected_collection_index = clamp(
		int(parsed.get("selected_collection_index", 0)),
		0,
		max(0, Content.ITEMS.size() - 1)
	)
	var loaded_tutorial_flags = parsed.get("tutorial_flags", {})
	tutorial_flags = loaded_tutorial_flags if typeof(loaded_tutorial_flags) == TYPE_DICTIONARY else {}
	_migrate_legacy_collection_without_rewards()


func _number_from_record_line(line: String) -> int:
	var token = ""
	for ch in line:
		if "0123456789+-".contains(ch):
			token += ch
	if token.is_empty() or token == "+" or token == "-":
		return 0
	return int(token)


func _legacy_record_to_structured(text_value: String) -> Dictionary:
	if text_value.strip_edges().is_empty():
		return {}

	var item_name = ""
	var item_id = ""
	var purchase_price = 0
	var info_cost = 0
	var sale_price = 0
	var profit = 0
	var actual_value = 0
	var current_assets = gold
	var buyer_name = "판매처"
	var buyer_reason = "거래 완료"
	var seller_observation = "-"
	var seller_actual = "-"
	var state = "-"
	var rarity = "-"
	var condition = "-"
	var plan_feedback: Array = []
	var analysis_lines: Array = []
	var section = ""

	for raw_line in text_value.split("\n", false):
		var line = str(raw_line).strip_edges()
		if line.is_empty():
			continue
		if line.begins_with("거래 완료 · "):
			item_name = line.trim_prefix("거래 완료 · ").strip_edges()
			continue
		if line == "내 거래 계획 복기":
			section = "plan"
			continue
		if line == "거래 분석":
			section = "analysis"
			continue
		if line == "판매자 복기":
			section = "seller"
			continue
		if line == "실제 물건":
			section = "truth"
			continue
		if line.begins_with("매입가 "):
			purchase_price = _number_from_record_line(line)
			continue
		if line.begins_with("검사/감정비 "):
			info_cost = _number_from_record_line(line)
			continue
		if line.begins_with("판매가 "):
			sale_price = _number_from_record_line(line)
			continue
		if line.begins_with("순이익 "):
			profit = _number_from_record_line(line)
			continue
		if line.begins_with("현재 자산 "):
			current_assets = _number_from_record_line(line)
			continue
		if line.begins_with("실제 가치 "):
			actual_value = _number_from_record_line(line)
			continue

		if section == "plan":
			plan_feedback.append(line)
		elif section == "analysis":
			analysis_lines.append(line)
			if line.begins_with("• 판매처: "):
				var buyer_text = line.trim_prefix("• 판매처: ")
				var parts = buyer_text.split(" — ", true, 1)
				buyer_name = str(parts[0]).strip_edges()
				if parts.size() > 1:
					buyer_reason = str(parts[1]).strip_edges()
		elif section == "seller":
			if line.begins_with("관찰 당시: "):
				seller_observation = line.trim_prefix("관찰 당시: ").strip_edges()
			elif line.begins_with("실제 성향: "):
				seller_actual = line.trim_prefix("실제 성향: ").strip_edges()
		elif section == "truth":
			var truth_parts = line.split(" · ")
			if truth_parts.size() >= 3:
				state = str(truth_parts[0]).strip_edges()
				rarity = str(truth_parts[1]).strip_edges()
				condition = str(truth_parts[2]).strip_edges()

	for listing in market_items:
		if Art.item_name(listing) == item_name:
			item_id = str(listing.get("item_id", ""))
			break

	if item_name.is_empty():
		return {}

	return {
		"item_id":item_id,
		"item_name":item_name,
		"buyer_name":buyer_name,
		"buyer_reason":buyer_reason,
		"purchase_price":purchase_price,
		"info_cost":info_cost,
		"sale_price":sale_price,
		"profit":profit,
		"plan_feedback":plan_feedback,
		"analysis_lines":analysis_lines,
		"seller_observation":seller_observation,
		"seller_actual":seller_actual,
		"state":state,
		"rarity":rarity,
		"condition":condition,
		"actual_value":actual_value,
		"current_assets":current_assets
	}


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
