# P4 — Seller Relationship & Story Arcs

## Goal

판매자를 단순한 랜덤 매물 공급원이 아니라 **플레이어와 거래를 기억하는 캐릭터**로 만든다.

플레이어가 같은 판매자를 다시 만났을 때:

- "전에 봤던 괴물"이라고 느끼고
- 지난 거래가 기억되고
- 관계 단계가 올라가며
- 개인 이야기가 열리고
- 관계 전용 매물이 생겨야 한다.

---

## Relationship State

판매자 8명 각각 다음 상태를 가진다.

```
seller_relationships[seller_id] = {
  points: 0,
  chats: 0,
  purchases: 0,
  last_day: 0,
  last_memory: "",
  story_step: 0,
  story_seen_step: 0,
  special_offer_ready: false,
  special_offer_claimed: false
}
```

### Relationship Points

- 한 매물에서 첫 의미 있는 채팅: +1
- 해당 판매자에게서 구매 완료: +6
- 관계 전용 특별 매물 구매: +3 추가

동일 매물에서 질문을 여러 번 눌러 관계 포인트를 반복 획득할 수 없다.

### Relationship Stages

- 0~3: 낯선 사이
- 4~11: 얼굴 익힘
- 12~23: 신뢰
- 24+: 단골

단계는 파생값이며 저장하지 않는다.

---

## Memory

판매자는 다음을 기억한다.

- 대화 횟수
- 구매 횟수
- 마지막으로 만난 Day
- 마지막 의미 있는 행동

예:

- "DAY 2 · 처음으로 물건을 샀다."
- "DAY 4 · 가격을 제안하고 거래했다."
- "DAY 7 · 단골 전용 매물을 구매했다."

관계 화면에서 이 기억을 확인할 수 있다.

---

## Story Arc

각 판매자는 3개의 personal beat를 가진다.

Threshold:

- Beat 1: 관계 4
- Beat 2: 관계 12
- Beat 3: 관계 24

각 beat는:

```
{
  threshold,
  title,
  message
}
```

를 가진다.

새 beat가 열리면 다음 seller chat에서 한 번만 story message가 삽입된다.

관계 화면에서는 현재 story title과 진행도 0/3~3/3을 항상 볼 수 있다.

---

## Seller Stories

### 별빛 상인 블루 — 탑에서 사라진 감정표
오래된 탑 물건을 정리하는 블루가 사라진 감정 기록의 흔적을 조금씩 털어놓는다.
Signature item: moon_ring

### 비늘장수 크록 — 창고를 비워야 하는 이유
가격을 세게 부르던 크록이 왜 창고 물건을 급하게 정리하는지 드러난다.
Signature item: dragon_tooth

### 유령 모르나 — 묘지길의 빈 랜턴
모르나가 매일 밤 같은 가로등에서 거래하는 이유가 영혼의 랜턴과 연결된다.
Signature item: soul_lantern

### 야시장지기 묘묘 — 북문 장부
야시장 흐름을 누구보다 잘 아는 묘묘가 잃어버린 장부와 특정 거래를 추적한다.
Signature item: meteor_coin

### 바느질 마녀 피피 — 돌아오지 않은 공방 동료
공방 정리 매물들이 예전 동료와 연결돼 있다는 사실이 드러난다.
Signature item: witch_thimble

### 고철상 그리즐 — 3번 크레인의 부품
그리즐이 오래 모아둔 기계 부품들이 하나의 장치였다는 이야기가 열린다.
Signature item: goblin_watch

### 해골 악사 토토 — 마지막 공연
토토가 더 이상 불지 않는 피리와 마지막 공연의 사연을 털어놓는다.
Signature item: bone_flute

### 까마귀 루크 — 종탑 뒤 우편함
항상 빠른 거래만 원하던 루크가 특정 우편함을 비우려는 이유가 드러난다.
Signature item: mimic_key

---

## Relationship Special Listing

Beat 3 unlock:

- special_offer_ready = true
- 해당 판매자가 속한 district를 방문하면 관계 전용 매물을 1칸에 주입
- seller는 반드시 해당 캐릭터
- signature item 사용
- rarity pool을 희귀/영웅/전설 쪽으로 강화
- 진품 여부는 보장하지 않음

즉:

> 관계가 높으면 "좋은 기회"는 생기지만 정답은 공짜로 주지 않는다.

특별 매물 표시:
- 단골 전용 매물
- seller story 전용 판매글

구매 완료 시:
- special_offer_ready = false
- special_offer_claimed = true
- 관계 +3

무시하면 다음 해당 district 방문에서도 다시 등장한다.

---

## Dialogue Adaptation

seller chat first message는 relationship stage에 따라 달라진다.

낯선 사이:
- 기존 소개/거래 메시지

얼굴 익힘:
- "전에 한 번 봤죠?"

신뢰:
- "이번 건은 먼저 말해두는데..."

단골:
- "다른 사람 올리기 전에 먼저 보여주는 겁니다."

새 story beat가 열려 있으면 greeting 뒤에 seller story message를 1회 삽입한다.

---

## Relationship Screen

Town → 괴물 인연

Layout:

- 상단: 괴물 인연
- seller list: 8명
  - portrait
  - name
  - relationship stage
  - points
- detail:
  - seller name / neighborhood
  - 관계 stage + points
  - 대화 N회 / 구매 N회
  - 최근 기억
  - 개인 이야기 title
  - story progress N/3
  - 다음 beat 조건 or 완료
  - 단골 전용 매물 상태

P7에서 final skin만 교체할 수 있도록 stable seller art key 사용.

---

## Save Migration

추가:
```
seller_relationships
```

legacy save:
- 8명 모두 default relationship state 생성
- 기존 거래 기록에서 특정 seller를 정확히 복원할 수 없으므로 임의 관계 포인트 부여 금지

---

## P4 Acceptance

- 8 seller relationship state exists
- first chat on a listing gives +1 once only
- purchase gives +6
- relationship stage changes at 4 / 12 / 24
- relationship appears in seller detail/chat
- seller relationship screen exists
- seller memories update
- story beat unlocks at thresholds
- new story beat appears once in seller chat
- final beat enables special listing
- special listing uses signature item + exact seller
- special listing does not guarantee authenticity
- special listing remains available until purchased
- special purchase consumes offer and adds bonus relationship
- save/load persists all seller relationship/story fields
- legacy save initializes safely
- 390×844 no horizontal overflow
