# P5 — Collection & Long-term Goals

## Purpose

수익만 반복하는 루프를 넘어:

- 아직 못 본 물건
- 아직 못 본 실제 상태
- 완성하고 싶은 테마 세트
- 장기 목표
- 업적

을 플레이 동기로 만든다.

## Discovery Contract

도감 기록은 hidden truth를 플레이어가 실제로 알게 된 뒤에만 발생한다.

기록 trigger:
1. Professional Appraisal
2. Completed Sale / Post-trade Reveal

홈/상세를 보기만 해서는 도감 발견 처리하지 않는다.

## Record Schema

```
collection_records[item_id] {
  discovered,
  appraisals,
  sales,
  states[],
  highest_rarity,
  best_profit,
  total_profit,
  last_day
}
```

## Completion

전체 완성도:
- discovered item types / Content.ITEMS

State completion:
- genuine / imitation / defect discovered globally

Theme completion:
- COLLECTION_SETS item_ids all discovered

## Long-term Goal Reward Rule

완료 순간 자동 지급한다.
claimed map을 save하여 재지급을 방지한다.

## Commercial Art Contract

미발견:
- ui/fallback

발견:
- items/<stable item_id>

따라서 final art pass에서는 item asset만 교체하면 수집 화면도 자동 반영된다.

## Gate

- appraisal writes collection
- sale updates collection statistics
- three truth states persist
- theme set completion works
- goals reward once
- achievements unlock
- collection screen fits 390×844
- save/load persists
- legacy result seeds new collection
