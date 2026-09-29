# P8 — Content & Release Completion

## Goal

P8 종료 시 코드/게임 규칙/화면/진행/콘텐츠 슬롯/저장/QA가 닫혀 있어야 한다.

남는 작업은 최종 visual/audio 파일 제작과 교체뿐이다.

---

## P8-A — Content Complete

### Target
- 거래 물건 12 → 24종
- 기존 4지역 정체성 유지
- 각 지역에서 신규 물건이 실제로 등장
- 일일 소문 4 → 8종
- 컬렉션 세트 확장
- 장기 목표 / 업적을 확장된 도감 규모에 맞춤

### Rule
신규 아이템도 기존 거래 엔진을 그대로 사용한다.
특별한 별도 미니게임을 만들지 않는다.

각 아이템은 반드시:
- category
- tags
- base_value
- rarity/state distribution
- investigation profile / overrides
- seller-like market stories
를 갖는다.

---

## P8-B — Balance & Long-run

자동 release simulation:
- 모든 아이템이 생성 가능
- 모든 지역에 최소 충분한 후보 pool
- 모든 day event가 실제 affected listing을 만들 수 있음
- 등록가/실제가/재판매가가 음수 또는 0이 되지 않음
- jackpot/trap/stable archetype이 장기 표본에서 모두 나타남
- state / rarity 분포가 한 값으로 붕괴하지 않음
- 업그레이드 비용과 평판 요구치가 진행 순서상 도달 가능

CI에서 deterministic long-run test로 고정한다.

---

## P8-C — Asset-only Finish

최종 asset은 stable slots를 사용한다.

Runtime behavior:
1. final asset path가 존재하면 사용
2. 없으면 현재 placeholder/fallback 사용

따라서 코드 변경 없이 파일만 추가해 최종 아트로 교체할 수 있다.

필수 slot:
- item 24
- seller 8
- district 4
- title / onboarding
- town / workshop / relationship / collection
- appraisal
- UI brand / fallback
- audio BGM/SFX (P7 path 유지)

문서:
- FINAL_ASSET_MANIFEST.md
- 각 파일명 / 용도 / 권장 비율 / 필수 여부

---

## P8-D — Release Gate

CI release checks:
- content integrity
- long-run economy
- current 390×844 portrait
- compact phone 375×812
- large phone 430×932
- old save migration
- corrupted primary → backup recovery
- missing final art → fallback
- full content IDs have stable asset slots

Release docs:
- APP_STORE_RELEASE_CHECKLIST.md
- FINAL_ASSET_MANIFEST.md
- RELEASE_CANDIDATE_STATUS.md

## Exit

P8 Gate 통과 후 버전은 `v1.0.0-rc1`.

그 이후 gameplay code 추가는 release blocker 수정만 허용한다.
