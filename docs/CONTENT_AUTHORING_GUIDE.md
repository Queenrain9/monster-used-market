# 괴물 중고마켓 — Content Authoring Guide

## 새 아이템 추가의 기본 원칙

대부분의 새 아이템은 게임 로직을 수정하지 않는다.

`data/content.gd > ITEMS`에 아이템 데이터 한 덩어리를 추가하고 기존 `investigation_profile` 중 하나를 지정하면 바로 시장 생성, 조사, 흥정, 감정, 재판매 시스템에 참여할 수 있다.

## 최소 아이템 예시

```gdscript
{
    "id":"demon_music_box",
    "name":"악마의 오르골",
    "category":"잡화",
    "tags":["기계","마법","수집"],
    "base_value":18000,
    "rarity_weights":{"고급":0.40,"희귀":0.40,"영웅":0.20},
    "state_weights":{"진품":0.55,"모조품":0.25,"결함품":0.20},
    "investigation_profile":"mechanical"
}
```

이 상태만으로 다음을 자동 상속한다.

- 외장 마모
- 내부 각인
- 작동 상태
- 수리 이력
- 기계품 시세
- mechanical 프로필용 진품/모조/결함/애매 단서
- 기존 공용 단서
- 기존 가격/희귀도/판매자/흥정/감정/구매자 시스템

## 한두 개만 특별하게 만들기

프로필 전체를 복사하지 말고 `investigation_overrides`를 사용한다.

```gdscript
"investigation_profile":"mechanical",
"investigation_overrides":{
    "function":{
        "short_label":"멜로디 역재생",
        "label":"태엽을 감아 멜로디가 거꾸로 흐르는지 듣는다"
    }
}
```

나머지 네 행동은 mechanical 프로필을 그대로 상속한다.

## 정말 특별한 단서 추가

필요한 아이템에만 `unique_clues`를 넣는다.

```gdscript
"unique_clues":[
    {
        "id":"music_box_u1",
        "kind":"애매한",
        "signal":"neutral",
        "text":"뚜껑을 닫은 뒤에도 마지막 한 음이 아주 약하게 남는다.",
        "reveal":"잔류 마력 현상이었지만 진품 여부를 확정하는 신호는 아니었다."
    }
]
```

고유 단서는 항상 나오지 않는다. 프로필/공용 단서와 섞여 등장한다.

## 언제 새 investigation_profile을 만드는가

새 아이템 하나 때문에 만들지 않는다.

다음 조건일 때 새 프로필을 만든다.

- 앞으로 비슷한 물건을 여러 개 추가할 예정
- 기존 프로필의 조사 행동 3개 이상을 매번 override해야 함
- 플레이어가 해당 물건군을 완전히 다른 방식으로 살펴봐야 함

예: 책/문서류가 여러 개 추가된다면 `manuscript` 프로필을 새로 만든다.

## 아트

새 아이템 ID가 아직 `data/art_catalog.gd`에 없어도 게임은 UI fallback texture를 사용하므로 로직 테스트가 가능하다.

최종 이미지를 준비한 뒤 art catalog에 같은 item ID를 연결하면 된다.

## 변경하면 안 되는 안정 ID

기존 세이브 호환을 위해 조사 행동 내부 ID는 다음 5개를 유지한다.

- exterior
- mark
- function
- origin
- market

플레이어에게 보이는 문구는 프로필과 override로 자유롭게 바꿀 수 있다.

## 콘텐츠 추가 체크리스트

1. ITEMS에 새 데이터 추가
2. 기존 investigation_profile 선택
3. 꼭 필요한 행동만 override
4. 특별한 물건이면 unique_clues 추가
5. 이미지가 준비되면 art catalog 연결
6. Godot smoke test 통과 확인

이 구조에서는 새 아이템을 추가하기 위해 `main.gd`나 `game_logic.gd`를 수정할 필요가 없어야 한다.
