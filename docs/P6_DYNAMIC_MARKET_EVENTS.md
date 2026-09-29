# P6 — Dynamic Market & Events

## Goal

같은 아이템/판매자 콘텐츠를 반복해도 DAY 상황에 따라 다른 판단이 필요해야 한다.

## Event Pipeline

```
DAY starts
→ event selected
→ affected tags become more common
→ affected listing asking prices move
→ up to one volatile rumor listing may appear
→ resale buyer demand changes
→ transaction record keeps the rumor context
```

## Safety Rule

Market events may alter:
- public asking
- supply weight
- buyer demand
- public event label
- volatile archetype for the one rumor-special listing

Market events never directly alter:
- state truth
- condition truth
- rarity truth
- actual item value

따라서 소문은 경제 환경이지 hidden truth leak가 아니다.

## Art Contract

No event-specific illustration is required for logic.

Stable future slots:
- event icon
- event banner
- optional rumor-special badge

현재 UI placeholder만으로 모든 event state가 식별 가능해야 한다.

## Gate

- content validation passes
- event supply weighting exists
- affected asking changes
- buyer quotes change
- quote reason explains demand
- hidden truth remains unchanged
- max one rumor-special per batch
- public UI never reveals jackpot/trap
- town/market/detail/result expose event context
- 390×844 regression passes
