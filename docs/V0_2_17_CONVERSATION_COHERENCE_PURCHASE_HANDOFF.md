# v0.2.17 — Conversation Coherence & Purchase Handoff

## 문제

v0.2.16은 괴물판 로컬 중고거래 감각을 만들었지만 실제 플레이에서 다섯 가지 이음새가 드러났다.

1. 질문과 발견 내용이 의미상 불일치할 수 있음
2. 홈에서 판매자 이름/동네가 카드 안에서 잘 안 읽힘
3. 가격 계획 버튼이 조사 행동처럼 보임
4. 협상 후에도 "판매자가 올린 가격"이라고 표시
5. 구매 직후 보유품이 큰 빈 목록 때문에 디버그 인벤토리처럼 보임

## Semantic Investigation Channels

구매 전 조사 결과를 action-specific clue channel로 분리한다.

```
exterior -> 외관
mark     -> 제작 표식
function -> 기능/반응
origin   -> 출처/이력
market   -> 시세
```

각 채널은 genuine / imitation / defect / neutral 변형을 가진다.

signal은 내부 판단/흥정에 계속 쓰지만 UI polarity label은 노출하지 않는다.

listing_id + action_id 기반 deterministic signal 선택을 사용하므로 화면을 다시 열어도 질문의 의미가 흔들리지 않는다.

## Price Planning

조사 Grid는 정확히 5개 행동만 가진다.

가격 계획은 별도 CTA로 분리한다.

이를 통해:

"무엇을 더 알아볼까?"

와

"그래서 얼마까지 낼까?"

를 서로 다른 의사결정 단계로 보이게 한다.

## Seller Price Vocabulary

```
round 0 : 판매자가 올린 가격
round 1+: 현재 판매자 가격
```

원래 등록가와 현재 협상가를 구분한다.

## Purchase Handoff

owned item에 선택적으로:

```
purchase_context {
  seller_name,
  neighborhood,
  meetup,
  price
}
```

를 저장한다.

Inventory 첫 화면은 이 정보를 이용해 "직거래 완료"를 먼저 보여준다.

legacy save에서 purchase_context가 없으면 listing의 공개 seller/meetup 정보를 사용한다.

## Inventory Density

- 0개: 빈 상태
- 1개: ItemList 숨김, 선택 물건 바로 노출
- 2개 이상: compact ItemList 표시

따라서 한 개를 방금 산 직후 큰 빈 리스트가 화면의 절반을 차지하지 않는다.
