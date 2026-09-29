# v0.2.12 — Item-Specific Investigation

## 문제

v0.2.11까지는 아이템의 이름과 이미지가 달라도 구매 전 조사법은 거의 동일했다.

플레이어가 반복 플레이 후:

> 아직 안 누른 조사 버튼이 뭐지?

라고 생각할 위험이 있었다.

## 변경

12개 아이템 각각에 5개 조사 행동 프로필을 부여했다.

각 프로필은:

- stable action id
- player-facing short label
- full investigation description
- connected clue slot

을 가진다.

## 저장 호환

기존 세이브의 `inspected_actions`와 호환하기 위해 내부 action id는 바꾸지 않았다.

`exterior / mark / function / origin / market`

의 의미를 각 아이템의 실제 조사 행위가 재해석한다.

## 게임 디자인 효과

같은 4회의 조사 기회를 사용하더라도:

- 반지는 보석과 마력 반응을 본다.
- 시계는 무브먼트와 태엽을 본다.
- 피리는 골질과 공명을 본다.
- 진주는 표면층과 수분 반응을 본다.
- 용의 이빨은 성장결과 뿌리 단면을 본다.

따라서 아이템 선택이 곧 조사 방법의 선택으로 연결된다.

## 아직 하지 않은 것

이번 단계에서는 기존 30개 단서 풀 자체를 아이템 전용 문장 수십 개로 확장하지 않았다.

숨은 상태와 연결된 기존 clue truth system을 유지하면서, 플레이어가 **어떤 관찰 행위를 선택하는지**를 먼저 아이템별로 차별화했다.

다음 단계는 계획대로 Information Economy Rebalance다.
