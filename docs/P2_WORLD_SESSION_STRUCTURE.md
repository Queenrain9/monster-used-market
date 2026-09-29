# P2 — World & Session Structure

## Goal

기존:

`랜덤 매물 3개 → 새 장터 → 반복`

상용판:

`DAY 시작 → 갈 수 있는 상권 선택 → 제한된 장터 방문 → 거래/조사 → 하루 마감 → 다음 날`

플레이어가 거래 1건이 아니라 **하루를 운영했다**고 느끼게 한다.

---

## Dark Town Districts

### 1. 야시장권
unlock reputation: 0

생활권:
- 야시장 북문
- 재봉골목

대표 판매자:
- myomyo
- pipi

성격:
- 마법 잡화
- 공예품
- 재료
- 비교적 안전한 첫 상권

### 2. 탑지구
unlock reputation: 40

생활권:
- 별빛탑 아래
- 종탑 뒤편

대표 판매자:
- blue
- rook

성격:
- 마법
- 수집
- 고대
- 전문가와 급매가 섞임

### 3. 부두권
unlock reputation: 100

생활권:
- 고철부두
- 비늘골목

대표 판매자:
- grizzle
- krok

성격:
- 기계
- 재료
- 고대
- 가격 압박이 강함

### 4. 묘지권
unlock reputation: 180

생활권:
- 묘지길
- 뼈다리 광장

대표 판매자:
- morna
- toto

성격:
- 저주
- 영혼
- 음악/수집
- 고위험 매물이 많아지는 후반 상권

---

## Day Loop

하루 시작:

- market_visits_remaining = 3
- daily goal reset
- day event 결정
- unlocked districts 계산

한 번의 장터 방문:

- 선택한 district에서 매물 3개 생성
- 판매자는 해당 district seller pool에서만 등장
- 아이템은 district preferred tags를 우선
- 조사 4회는 기존처럼 해당 장터 batch에서 공유
- 새 batch로 넘어갈 때 방문 기회 1회 소비

하루 종료:

- merchant_day += 1
- today_deals reset
- daily goal reset
- visit budget reset
- previous day summary 저장
- new day event 생성

---

## District Unlock

reputation gate:

- night_market: 0
- tower: 40
- dock: 100
- grave: 180

locked district는 UI에 보이되:

`평판 40 필요`

형태로 이유를 명확히 표시한다.

---

## World Screen

Bottom navigation:

- 동네
- 장터
- 보유품
- 기록

World screen:

- DAY
- 오늘의 소문/사건
- 남은 장터 방문
- 지난 날 요약
- district 4 cards
- 하루 마감

District Card:

- stable art slot
- district name
- neighborhoods
- flavor
- unlock requirement
- current/available state
- enter CTA

---

## Day Event Scaffold

P2에서는 경제를 크게 흔들지 않는다.
P6에서 실제 market modifier로 확장할 수 있도록 event slot만 만든다.

예:

- 비 오는 야시장
- 탑의 야간 개방
- 부두 검문 강화
- 묘지 축제 준비

필드:

```
id
title
description
district_id (optional)
```

---

## Save State

추가:

```
current_district_id
market_visits_remaining
day_start_gold
last_day_summary
day_event_id
```

legacy save:
- current district = night_market
- visits = 3
- day_start_gold = current gold
- summary = empty

---

## P2 Acceptance

- World screen exists
- 4 districts visible
- reputation lock works
- first district accessible
- district visit generates only district sellers
- preferred item flavor works
- market visit budget is consumed
- no free infinite rerolls after budget exhausted
- end day increments Day
- daily goal resets
- day summary persists
- save/load preserves district/day state
- old save migrates
- 390×844 no overflow
