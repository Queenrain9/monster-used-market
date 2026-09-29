# 괴물 중고마켓 — Final Asset Manifest

이 문서는 P8 이후 **코드 수정 없이 최종 에셋만 교체**하기 위한 파일 계약이다.

Runtime rule:

1. `final_texture` 파일이 존재하면 그것을 사용
2. 없으면 현재 placeholder `texture` 사용
3. 둘 다 없으면 global fallback 사용

따라서 아래 파일을 같은 경로/이름으로 넣으면 자동 적용된다.

---

## 1. Item Art — 24종

권장:
- PNG
- 1024×1024
- 1:1
- 물건 중심 실루엣
- 앱 전체 UI/프레임/텍스트를 이미지에 포함하지 않음

| ID | 표시 물건 | Final path |
|---|---|---|
| moon_ring | 빛나는 낡은 반지 | `res://assets/art/items/moon_ring.png` |
| dragon_tooth | 불타는 칼날 조각 | `res://assets/art/items/dragon_tooth.png` |
| cursed_mirror | 금이 간 마법 거울 | `res://assets/art/items/cursed_mirror.png` |
| soul_lantern | 저주받은 램프 | `res://assets/art/items/soul_lantern.png` |
| witch_thimble | 신비한 찻잔 | `res://assets/art/items/witch_thimble.png` |
| goblin_watch | 낡은 왕실 목걸이 | `res://assets/art/items/goblin_watch.png` |
| bone_flute | 수상한 검은 인형 | `res://assets/art/items/bone_flute.png` |
| meteor_coin | 이상한 가면 | `res://assets/art/items/meteor_coin.png` |
| phoenix_feather | 낡은 마법서 | `res://assets/art/items/phoenix_feather.png` |
| mimic_key | 움직이는 보물상자 | `res://assets/art/items/mimic_key.png` |
| mermaid_pearl | 울고 있는 수정 구슬 | `res://assets/art/items/mermaid_pearl.png` |
| frost_vial | 유령이 든 병 | `res://assets/art/items/frost_vial.png` |
| echo_compass | 메아리 나침반 | `res://assets/art/items/echo_compass.png` |
| bottled_shadow | 병에 든 그림자 | `res://assets/art/items/bottled_shadow.png` |
| watching_brooch | 눈알 브로치 | `res://assets/art/items/watching_brooch.png` |
| moon_moth_case | 달나방 표본함 | `res://assets/art/items/moon_moth_case.png` |
| drowned_bell | 물에 잠긴 은종 | `res://assets/art/items/drowned_bell.png` |
| rune_glove | 룬 재봉사의 장갑 | `res://assets/art/items/rune_glove.png` |
| basilisk_scale | 바실리스크 비늘 | `res://assets/art/items/basilisk_scale.png` |
| clockwork_beetle | 태엽 딱정벌레 | `res://assets/art/items/clockwork_beetle.png` |
| grave_candle | 묘지의 푸른 초 | `res://assets/art/items/grave_candle.png` |
| star_map_fragment | 별자리 지도 조각 | `res://assets/art/items/star_map_fragment.png` |
| sea_witch_comb | 해마녀의 산호빗 | `res://assets/art/items/sea_witch_comb.png` |
| alchemist_spoon | 연금술사의 계량숟가락 | `res://assets/art/items/alchemist_spoon.png` |

---

## 2. Seller Portrait — 8명

권장:
- PNG
- 1024×1024
- 1:1
- 얼굴/상반신 중심
- 각 판매자의 silhouette와 성격이 작은 썸네일에서도 구분

| ID | Final path |
|---|---|
| blue | `res://assets/art/sellers/blue.png` |
| krok | `res://assets/art/sellers/krok.png` |
| morna | `res://assets/art/sellers/morna.png` |
| myomyo | `res://assets/art/sellers/myomyo.png` |
| pipi | `res://assets/art/sellers/pipi.png` |
| grizzle | `res://assets/art/sellers/grizzle.png` |
| toto | `res://assets/art/sellers/toto.png` |
| rook | `res://assets/art/sellers/rook.png` |

---

## 3. District Art — 4지역

권장:
- 1200×675
- 16:9
- 텍스트 없음
- 해당 지역을 한눈에 구분할 수 있는 장소 establishing art

| 지역 | Final path |
|---|---|
| 야시장권 | `res://assets/art/districts/night_market.png` |
| 탑지구 | `res://assets/art/districts/tower.png` |
| 부두권 | `res://assets/art/districts/dock.png` |
| 묘지권 | `res://assets/art/districts/grave.png` |

---

## 4. Commercial Shell / Onboarding

### Title background
- `res://assets/art/ui/title_background.png`
- 권장 1080×1920, 9:16
- 중앙 카드 뒤에서도 세계관이 읽히되 UI 텍스트 영역은 과밀하지 않게

### Onboarding
- `res://assets/art/ui/onboarding_world.png`
- `res://assets/art/ui/onboarding_role.png`
- `res://assets/art/ui/onboarding_goal.png`
- 권장 1200×900, 4:3

세 장은 각각:
1. 어둠마을과 시장
2. 신참 물건상 역할
3. 첫 거래/성장 목표

를 보여준다.

---

## 5. Existing UI Art

현재 사용 중이며 최종 파일로 그대로 교체 가능:

- `res://assets/art/ui/brand.png`
- `res://assets/art/ui/market.png`
- `res://assets/art/ui/appraiser.png`
- `res://assets/art/ui/fallback.png`

### Meta screen art

작업실 상단 배너:
- `res://assets/art/ui/workshop.png`
- 권장 1200×675

관계/도감 화면은 각각 판매자 초상과 아이템 아트를 직접 사용하므로 별도 배너 없이도 final composition이 완성된다.

### UI 9-slice skin

아래 이미지는 **128×128 PNG / 안전한 24px 9-slice border** 기준으로 제작한다.

- `res://assets/art/ui/skin/panel.png`
- `res://assets/art/ui/skin/button_normal.png`
- `res://assets/art/ui/skin/button_hover.png`
- `res://assets/art/ui/skin/button_pressed.png`
- `res://assets/art/ui/skin/button_disabled.png`
- `res://assets/art/ui/skin/input.png`

파일이 존재하면 `MarketTheme`가 자동으로 사용한다.
없으면 현재 neutral production theme가 그대로 fallback 된다.

따라서 황동/목재/양피지 기반의 최종 UI skin도 **코드 수정 없이 이미지 파일만 교체**할 수 있다.

---

## 6. Audio

P7에서 path 고정 완료.

### BGM
`res://assets/audio/bgm/`

- title.ogg
- town.ogg
- market.ogg
- chat.ogg
- deal.ogg
- appraisal.ogg
- sale.ogg
- result.ogg

### SFX
`res://assets/audio/sfx/`

- tap.ogg
- open_listing.ogg
- message_send.ogg
- clue_reveal.ogg
- offer_submit.ogg
- purchase.ogg
- appraisal_reveal.ogg
- sale_complete.ogg
- goal_complete.ogg
- achievement.ogg
- upgrade.ogg
- day_end.ogg
- warning.ogg

오디오 파일이 없어도 gameplay는 실패하지 않는다.

---

# Asset-only Finish Rule

최종 제작자는:

1. 위 경로에 파일을 넣고
2. Godot import를 실행하고
3. release QA를 통과시키면 된다.

게임 규칙, UI hierarchy, save schema, content ID, interaction code를 다시 수정하지 않는다.
