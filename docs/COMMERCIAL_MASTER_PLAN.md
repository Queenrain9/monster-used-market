# 괴물 중고마켓 — Commercial Production Master Plan

## North Star

최종 목표는 **최종 아트/아이콘/배경/사운드 에셋만 교체하면 출시 가능한 게임**이다.

코드가 담당해야 하는 완성 범위:

- 완결된 첫 실행 / 새 게임 / 이어하기
- 플레이어 역할과 장기 목표
- 하루 단위 플레이 세션
- 핵심 거래 루프
- 월드/지역/이벤트
- 판매자 관계와 이야기
- 메타 성장과 해금
- 수집/도감/업적
- 콘텐츠 확장 구조
- 튜토리얼과 UX
- 화면 전환과 연출 hook
- 음악/SFX/VFX/애니메이션 hook
- 저장/마이그레이션/복구
- 접근성/설정
- 밸런스/QA/릴리즈 체크
- Asset Manifest

기존 v0.2.x 코어는 폐기하지 않는다.
상용판의 핵심 거래 엔진으로 승격한다.

---

## 제품 판타지

> 어둠마을의 괴물들이 올리는 수상한 중고 물건을 찾아,
> 판매자와 대화하고 단서를 모으고 가격을 흥정한 뒤,
> 진짜 가치를 판단해 되팔면서 이름난 기묘한 물건 상인으로 성장한다.

핵심 감정:

1. "이 괴물이 왜 이걸 파는 거지?"
2. "이 물건 진짜 맞나?"
3. "어디까지 가격을 불러도 될까?"
4. "내가 남들보다 먼저 가치를 알아봤다."
5. "다음에는 더 위험하고 희귀한 매물을 다뤄보고 싶다."

---

# Production Stages

## P1 — Commercial Game Shell & First Session ✅ IMPLEMENTED v0.3.0

목표:
게임 실행 순간부터 개발용 프로토타입이 아니라 제품처럼 느껴지게 한다.

구현:
- 타이틀 화면
- 이어하기 / 새 게임
- 첫 진입 3-step onboarding
- 플레이어 역할: 어둠마을 신참 물건상
- Day
- 상인 등급
- 평판
- 오늘의 목표
- 첫 거래 목표 / 보상
- 저장 확장 및 옛 저장 migration

Gate:
- 처음 실행한 플레이어가 설명 없이 "나는 누구고 무엇을 하면 되는가"를 안다.
- 기존 유저는 이어하기로 기존 플레이를 잃지 않는다.
- 신규 유저는 60초 안에 첫 매물까지 진입한다.

## P2 — World & Session Structure ✅ IMPLEMENTED v0.4.0

- 어둠마을 구역
- 구역별 판매자/매물 특성
- 하루 장터 lifecycle
- Morning → Market → Close
- 다음 날
- 지역 해금
- 지역 사건
- 하루 요약

Gate:
거래 1건이 아니라 "하루를 운영했다"는 느낌.

## P3 — Meta Progression ✅ IMPLEMENTED v0.5.0

- 평판 레벨
- 상인 등급
- 기능 해금
- 보관함 확장
- 감정/조사 업그레이드
- 초기 자본 성장
- 위험 허용 범위 증가

Gate:
플레이어가 5~10회 거래 뒤에도 다음 해금 목표를 가진다.

## P4 — Seller Relationship & Story Arcs ✅ IMPLEMENTED v0.6.0

- 판매자별 관계값
- 신뢰 / 경계
- 반복 거래 기억
- 판매자 개인 사건
- 관계 기반 희귀 매물
- 관계 기반 대화 변화

Gate:
판매자가 랜덤 데이터 공급원이 아니라 기억되는 캐릭터가 된다.

## P5 — Collection & Long-term Goals ✅ IMPLEMENTED v0.7.0

- 물건 도감
- 발견 기록
- 진품/모조품/결함품 기록
- 희귀도 컬렉션
- 테마 세트
- 업적
- 장기 의뢰
- Collection completion

Gate:
수익 외에도 "찾고 싶은 물건"이 생긴다.

## P6 — Dynamic Market & Events

- 시세 변동
- 소문
- 지역 이벤트
- 특정 카테고리 붐/폭락
- 시간 제한 매물
- 위험한 특별 거래
- jackpot/trap 강화

Gate:
같은 콘텐츠도 매 세션 다른 판단을 요구한다.

## P7 — Commercial UX & Presentation Hooks

- 화면 전환
- 튜토리얼 highlight
- modal/notification 규칙
- feedback animation hooks
- SFX hooks
- BGM states
- VFX slots
- haptic hooks
- settings
- accessibility
- error/recovery UX

Gate:
placeholder art 상태에서도 모든 상호작용 feedback이 완성돼 있다.

## P8 — Content & Release Completion

- 확장 콘텐츠 팩
- 밸런스 pass
- 장기 플레이 테스트
- 세이브 migration
- 기기 QA
- performance
- final Asset Manifest
- App Store release checklist

Gate:
최종 이미지/사운드를 Asset Manifest에 맞춰 교체하면 release candidate.

---

# Asset-only Finish Definition

다음 항목이 모두 충족되면 "이미지만 만들어 넣으면 완성" 상태로 본다.

- 모든 화면의 final layout 확정
- 모든 state/transition 구현
- 모든 버튼/입력/팝업 구현
- 모든 meta system 구현
- 모든 content slot 데이터화
- 모든 image slot에 stable asset key 존재
- 모든 SFX/BGM slot에 stable event key 존재
- placeholder라도 animation/VFX timing 구현
- save/load/recovery 완료
- production QA 통과

그 이후 남는 작업:

- final item art
- final seller art
- background art
- UI skin/icon
- VFX textures
- BGM/SFX source files
- store screenshots / icon / promo art

---

# Operating Rule

각 단계는:

Design Lock
→ Implementation
→ Regression Test
→ Real-screen Review
→ Gate Pass

순서로 끝낸다.

다음 단계는 이전 단계의 시스템을 지우는 방식으로 만들지 않는다.
