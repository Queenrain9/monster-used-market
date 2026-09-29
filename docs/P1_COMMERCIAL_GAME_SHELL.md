# P1 — Commercial Game Shell & First Session

## Player promise

게임을 켠 뒤 60초 안에 플레이어는 다음을 알아야 한다.

- 나는 어둠마을의 신참 물건상이다.
- 50,000G로 시작한다.
- 괴물이 올린 물건을 무작정 믿으면 안 된다.
- 대화/조사/흥정/재판매가 한 거래의 흐름이다.
- 거래를 성공시키면 평판이 쌓이고 상인으로 성장한다.

## Launch flow

```
App Launch
→ Commercial Title
   ├ Continue
   └ New Game
        → Onboarding 1: World
        → Onboarding 2: Role
        → Onboarding 3: First Goal
        → Market
```

기존 저장은 Continue로 기존 stage를 복원한다.

## Persistent state

```
game_started: bool
onboarding_complete: bool
merchant_day: int
merchant_reputation: int
daily_goal_progress: int
daily_goal_claimed: bool
```

## Reputation rule v0.3.0

거래 완료 기본:
- +10

순이익:
- +5

구매 전 발견 단서 2개 이상:
- +2

첫 거래 목표:
- +10
- +500G

P3에서 reputation curve와 실제 unlock table을 교체할 수 있도록 UI는 `_merchant_rank()`만 참조한다.

## Asset contract

현재 shell은 existing placeholder assets를 사용한다.

P7/P8에서 교체할 stable slots:
- title background
- brand/logo
- onboarding world art
- onboarding merchant-role art
- onboarding first-goal art

기능/상태/레이아웃은 최종 이미지 교체와 독립적이어야 한다.

## P1 Acceptance

- Fresh install: Continue disabled
- New Game: 3 onboarding steps
- Finish: market opens
- HUD: Day / Rank / Reputation / Goal
- First sale: reputation increases
- First goal: reward exactly once
- Relaunch: progression survives
- Old v0.2.x save: no forced onboarding
- 390×844: no horizontal overflow
