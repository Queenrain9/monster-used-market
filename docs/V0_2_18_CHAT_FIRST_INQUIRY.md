# v0.2.18 — Chat-first Inquiry

## 문제

v0.2.17까지는 문구가 대화체여도 실제 interaction model은:

`버튼 → 결과 panel`

이었다.

따라서 플레이어는 판매자와 대화하는 것이 아니라 정보를 조회한다고 느꼈다.

## 목표

질문 선택 자체를 채팅 composer의 reply choice로 보이게 한다.

플레이어가 화면을 보고:

> 어떤 정보 버튼을 누르지?

가 아니라:

> 이 괴물한테 뭐라고 물어볼까?

를 먼저 생각하게 한다.

## Chat Thread

상세 화면 안에 고정 높이의 판매자 채팅 영역을 둔다.

header:
- seller portrait
- seller name
- activity

thread:
- seller greeting
- accumulated buyer/seller messages
- observation notes

composer:
- remaining opportunities
- contextual reply choices

## Persistence

listing에 선택적으로:

```
chat_history: [
  {speaker:"buyer", text:"..."},
  {speaker:"seller", text:"..."},
  {speaker:"note", text:"..."}
]
```

를 저장한다.

기존 save에는 필드가 없어도 빈 배열로 취급한다.

## Choice Mapping

- exterior: 사진을 더 보여달라는 메시지
- mark: 특정 부위 근접사진 요청
- function: 직접 확인 허락 요청
- origin: 출처 질문
- market: 플레이어가 직접 비교검색 후 note 생성

## Secondary Notes

`거래 메모`는 discovered_clues의 복기 영역이다.

메모는 핵심 interaction이 아니라 conversation을 통해 얻은 사실의 보조 기록이다.
