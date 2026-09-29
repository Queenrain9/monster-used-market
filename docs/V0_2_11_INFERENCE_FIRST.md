# v0.2.11 — Inference First

## 문제

기존 프로토타입은 단서를 발견하게 만들었지만 구매 전에 `[긍정적]`, `[부정적]`, `[애매한]`을 표시해 플레이어 대신 해석했다.

판매자 역시 `급한 판매자`, `전문가`처럼 내부 성격 타입을 그대로 노출했다.

이 상태에서는 관찰은 있지만 추론은 약해진다.

## 새 정보 공개 규칙

### 구매 전
플레이어에게 보여줄 것:
- 관찰 사실
- 판매자의 실제 말과 행동
- 가격
- 조사 결과
- 시장 시세

숨길 것:
- clue.kind
- clue.signal
- seller.type
- seller personality summary의 정답형 설명

### 전문 감정 후
공개 가능:
- 실제 진위 / 상태 / 희귀도
- 각 단서가 실제로 무엇과 연결됐는지

### 거래 완료 후
공개 가능:
- 실제 판매자 성향
- 플레이어가 본 행동과 실제 성향의 비교

## 이후 단계

1. **완료 — Inference First**
2. Item-Specific Investigation
3. Information Economy Rebalance
4. Trade Planning Refinement
5. Buyer Uncertainty & Result Restraint
6. 15–20 Trade Core Playtest
7. Inventory / Records Fidelity + Art
