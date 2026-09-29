# 06. State & Interaction Matrix

| UI 영역 | 초기 | 카운터 후 | 거절 후 | closed | accepted |
|---|---|---|---|---|---|
| 판매자 현재가 | asking | counter | 유지/변경 | 최종가 | accepted_price |
| 내 최대 매입가 | 표시 | 표시 | 표시 | 표시 | - |
| 근거 선택 | 활성 | 활성 | 활성 | 비활성 | - |
| 제안 슬라이더 | 활성 | 활성 | 활성 | 비활성 | - |
| -5/-10/-20 | 활성 | 활성 | 활성 | 비활성 | - |
| 제안 버튼 | 활성 | 활성 | 활성 | 비활성 | - |
| 판매자 반응 | 기본 문구 | counter speech | reject speech | close speech | accept speech |
| 현재가 구매 | gold 충분 시 활성 | 동일 | 동일 | 동일 | 자동 구매 |
| 보류 | 활성 | 활성 | 활성 | 활성 | - |

## 기존 데이터 바인딩

| 표시 | 데이터 |
|---|---|
| 아이템 이름 | listing.item_id → Art.item_name |
| 판매자 이름 | listing.seller |
| 판매자 성격 | seller.personality.name |
| 판매자 가격 | negotiation_state.current_price |
| 협상 횟수 | negotiation_state.rounds / max_rounds |
| 인내도 | negotiation_state.patience |
| 판매자 반응 | negotiation_state.last_speech |
| 예상 재판매가 | trade_plan.value_band |
| 최대 매입가 | trade_plan.max_buy_price |
| 근거 | discovered_clues + negotiation_evidence_options |
| 제안가 | OfferSlider.value |

## 추가 저장 데이터

**필수 추가 없음.**

화면에서 필요한 대부분의 정보가 이미 저장되고 있다.

선택적으로 화면 복원을 더 정확하게 하고 싶다면 향후:

- last_selected_evidence
- draft_offer_price

정도만 고려할 수 있으나 v0.2.10 필수 사항이 아니다.
