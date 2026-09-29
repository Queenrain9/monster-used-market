# P3 — Meta Progression & Merchant Workshop

## Goal

평판이 단순 숫자가 아니라 **다음 플레이 선택과 기능 확장**으로 연결돼야 한다.

원칙:

- Reputation = unlock requirement
- Gold = upgrade investment
- 별도 프리미엄 재화 없음
- 코어 거래 판단을 자동으로 정답내주는 업그레이드는 금지
- 업그레이드는 "더 많은 선택/여유"를 주되 판단 자체는 플레이어가 한다

---

## Workshop

동네 화면에서 `내 작업실`로 진입한다.

작업실은 5개 성장 트랙을 가진다.

### 1. 보관 선반 — storage

기본 보유 한도: 2

- Lv1: 3칸 / 6,000G / 평판 0
- Lv2: 4칸 / 12,000G / 평판 60
- Lv3: 6칸 / 25,000G / 평판 150

효과:
- 동시 보유 가능 물건 수 증가

### 2. 현장 수첩 — notebook

기본 장터 확인 기회: 4

- Lv1: 5회 / 7,500G / 평판 40
- Lv2: 6회 / 16,000G / 평판 100

효과:
- 새로운 장터 batch의 질문/확인 기회 증가

### 3. 감정소 계약 — appraisal

기본 전문 감정 할인: 0%

- Lv1: 10% / 8,000G / 평판 40
- Lv2: 20% / 18,000G / 평판 150
- Lv3: 30% / 35,000G / 평판 300

효과:
- 전문 감정 비용 할인
- hidden truth를 무료로 주지는 않음

### 4. 구매자 연락망 — network

기본 전문 견적: 2곳

- Lv1: 3곳 / 12,000G / 평판 100
- Lv2: 4곳 / 30,000G / 평판 300

효과:
- 한 물건에서 확인 가능한 전문 구매처 증가

### 5. 장터 동선 장부 — routes

기본 하루 장터 방문: 3회

- Lv1: 4회 / 10,000G / 평판 60
- Lv2: 5회 / 22,000G / 평판 180

효과:
- 다음 DAY부터 하루 방문 가능 횟수 증가
- 구매 직후 현재 day capacity도 안전하게 증가분 반영

---

## Rank Progress

Rank:

- 0 견습 물건상
- 60 동네 감정꾼
- 150 골목 상인
- 300 기묘품 중개상
- 600 어둠마을 상인

작업실 상단에서:

- current rank
- current reputation
- next rank
- next threshold
- unlocked districts

를 보여준다.

---

## Save State

```
upgrade_levels = {
 storage:0,
 notebook:0,
 appraisal:0,
 network:0,
 routes:0
}
```

legacy:
all level 0.

---

## Stable Effects API

UI/logic는 직접 level 숫자를 해석하지 않고 helper를 사용한다.

- _inventory_capacity()
- _market_investigation_capacity()
- _professional_appraisal_discount()
- _quote_request_capacity()
- _daily_market_visit_capacity()

P8 밸런스 조정 시 data table만 변경 가능해야 한다.

---

## Upgrade Purchase

구매 가능 조건:

- next level exists
- reputation >= requirement
- gold >= cost

구매:
- gold 차감
- level +1
- effect 즉시 적용
- 저장
- 작업실 카드 갱신

locked:
- "평판 N 필요"

poor:
- "N G 필요"

max:
- "최대 단계"

---

## P3 Acceptance

- Workshop screen
- 5 upgrade tracks visible
- locked/cost/max state readable
- upgrade purchase persists
- storage limit blocks further purchase safely
- notebook changes next market investigation budget
- appraisal discount changes shown and paid professional appraisal fee
- network changes quote capacity
- routes changes next-day visit budget
- legacy save level 0 migration
- 390×844 no overflow
