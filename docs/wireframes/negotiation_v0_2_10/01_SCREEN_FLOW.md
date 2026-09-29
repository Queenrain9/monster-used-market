# 01. Screen Flow

```
ITEM DETAIL
  │
  │ 거래 계획 저장
  ▼
NEG-01 협상 진입
  │
  │ 근거 선택 + 가격 조정
  ▼
NEG-02 제안 작성
  │
  │ 제안
  ├─────────────┐
  │             │
  ▼             ▼
수락          카운터/거절
  │             │
  │             ▼
  │          NEG-03 판매자 반응
  │             │
  │             ├─ 다시 제안 가능
  │             └─ 협상 종료 가능
  ▼
구매 완료
  │
  ▼
INVENTORY

협상 종료 / 보류
  │
  ▼
MARKET / ITEM DETAIL
```

## 상태 전이 규칙

### 상세 → 협상

필수 조건:

- 예상 재판매가 선택 완료
- 최대 매입가 > 0

기존 `_start_deal()` 흐름을 유지한다.

### 제안 → 판매자 반응

입력:

- offer_price
- evidence_clue_index

기존 `engine.negotiate_offer()` 사용.

### 수락

즉시 `_complete_purchase(accepted_price)`로 이동한다.

### 카운터

- `current_price` 갱신
- `rounds + 1`
- `patience / mood` 변화 가능
- 화면은 NEG-03 상태를 보여준 뒤 같은 협상 화면에서 다음 제안을 허용

### 거절

- 가격이 유지될 수 있음
- patience 감소 가능
- 협상 횟수 또는 patience가 끝나면 `closed = true`

### 보류

현재 구현의 `거래 보류하고 마켓으로` 유지.

보류는 실패가 아니다.
매물은 시장에 남아 다시 확인할 수 있어야 한다.
