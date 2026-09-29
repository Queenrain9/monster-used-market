# 09. Implementation Notes

## Status

Interaction Wireframe Pack이 Godot 실제 화면에 구현되었다.

## 연결된 실제 코드

- Scene: `scenes/main.tscn > DealPanel`
- Controller: `scripts/main.gd`
- Existing engine: `scripts/game_logic.gd`

## 구현된 상태

- NEG-01 협상 진입
- NEG-02 제안 작성
- NEG-03 카운터 / 거절 피드백
- NEG-04 closed 상태 및 구매 / 보류

## 표시용으로 negotiation_state에 추가 저장되는 값

게임 계산에는 영향을 주지 않고 화면 복원을 위해 다음 값을 저장한다.

- `previous_price`
- `last_evidence_text`
- `last_status`

기존 엔진의 수락 / 카운터 / 거절 공식에는 변경이 없다.

## 테스트

`tests/home_feed_smoke_test.gd`에서 다음을 검증한다.

- 전용 협상 화면
- 판매자가 / 최대 매입가 / 예상 재판매가 동시 노출
- 매입 상한 초과 경고
- 발견 단서 팝업의 모바일 폭
- 제안 후 round 증가
- 직전 제안 표시
- 판매자 가격 변화 표시
- 390×844 bounds 및 가로 스크롤 방지
