# 07. Godot Component Map

## 권장 구조

현재 `DealPanel`의 로직은 유지하되 시각 구조를 다음처럼 재배치한다.

```
DealPanel
└─ Scroll
   └─ Box
      ├─ TopBar
      │  ├─ BackButton
      │  ├─ PageTitle
      │  └─ GoldLabel
      ├─ ItemSellerSummary
      │  ├─ ItemArt
      │  └─ SellerMeta
      ├─ PriceComparison
      │  ├─ SellerPrice
      │  ├─ MaxBuyPrice
      │  └─ ExpectedResale
      ├─ NegotiationStatus
      │  ├─ RoundLabel
      │  └─ PatienceLabel
      ├─ EvidenceSection
      │  └─ EvidenceOption
      ├─ OfferSection
      │  ├─ OfferPriceLabel
      │  ├─ OfferSlider
      │  └─ PresetRow
      ├─ SubmitOfferButton
      ├─ SellerResponsePanel
      │  ├─ PriceChangeLabel
      │  └─ SellerSpeech
      └─ BottomActions
         ├─ BuyCurrentButton
         └─ DealBackButton
```

## 재사용

그대로 유지:

- `_start_deal()`
- `_render_deal()`
- `_offer_slider_changed()`
- `_set_offer_discount()`
- `_submit_offer()`
- `_buy_current_price()`
- `engine.start_negotiation()`
- `engine.negotiation_evidence_options()`
- `engine.negotiate_offer()`

## 바꿔야 할 것

주로:

- `scenes/main.tscn` DealPanel 구조
- `scripts/main.gd` onready 경로
- `_render_deal()`의 표시 문자열/상태표현
- 390×844 레이아웃 회귀 테스트

## 바꾸지 말 것

- 수락 공식
- counter 계산
- evidence strength
- seller personality 수치
- max_rounds
- patience 규칙
- 구매 처리
- 저장 구조
