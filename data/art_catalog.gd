extends RefCounted

# Replace paths / public display names here; gameplay IDs stay unchanged.
const ENTRIES = {
  "items": {
    "moon_ring": {
      "texture": "res://assets/art/items/moon_ring.png",
      "final_texture": "res://assets/art/items/moon_ring.png",
      "name": "빛나는 낡은 반지",
      "legacy_name": "달빛 속삭임 반지"
    },
    "dragon_tooth": {
      "texture": "res://assets/art/items/dragon_tooth.png",
      "final_texture": "res://assets/art/items/dragon_tooth.png",
      "name": "불타는 칼날 조각",
      "legacy_name": "용의 이빨"
    },
    "cursed_mirror": {
      "texture": "res://assets/art/items/cursed_mirror.png",
      "final_texture": "res://assets/art/items/cursed_mirror.png",
      "name": "금이 간 마법 거울",
      "legacy_name": "저주받은 손거울"
    },
    "soul_lantern": {
      "texture": "res://assets/art/items/soul_lantern.png",
      "final_texture": "res://assets/art/items/soul_lantern.png",
      "name": "저주받은 램프",
      "legacy_name": "영혼의 랜턴"
    },
    "witch_thimble": {
      "texture": "res://assets/art/items/witch_thimble.png",
      "final_texture": "res://assets/art/items/witch_thimble.png",
      "name": "신비한 찻잔",
      "legacy_name": "마녀의 은골무"
    },
    "goblin_watch": {
      "texture": "res://assets/art/items/goblin_watch.png",
      "final_texture": "res://assets/art/items/goblin_watch.png",
      "name": "낡은 왕실 목걸이",
      "legacy_name": "고블린 회중시계"
    },
    "bone_flute": {
      "texture": "res://assets/art/items/bone_flute.png",
      "final_texture": "res://assets/art/items/bone_flute.png",
      "name": "수상한 검은 인형",
      "legacy_name": "망자의 뼈피리"
    },
    "meteor_coin": {
      "texture": "res://assets/art/items/meteor_coin.png",
      "final_texture": "res://assets/art/items/meteor_coin.png",
      "name": "이상한 가면",
      "legacy_name": "운석 동전"
    },
    "phoenix_feather": {
      "texture": "res://assets/art/items/phoenix_feather.png",
      "final_texture": "res://assets/art/items/phoenix_feather.png",
      "name": "낡은 마법서",
      "legacy_name": "불사조 깃털"
    },
    "mimic_key": {
      "texture": "res://assets/art/items/mimic_key.png",
      "final_texture": "res://assets/art/items/mimic_key.png",
      "name": "움직이는 보물상자",
      "legacy_name": "미믹의 황동열쇠"
    },
    "mermaid_pearl": {
      "texture": "res://assets/art/items/mermaid_pearl.png",
      "final_texture": "res://assets/art/items/mermaid_pearl.png",
      "name": "울고 있는 수정 구슬",
      "legacy_name": "심해 인어의 진주"
    },
    "frost_vial": {
      "texture": "res://assets/art/items/frost_vial.png",
      "final_texture": "res://assets/art/items/frost_vial.png",
      "name": "유령이 든 병",
      "legacy_name": "빙결 정수 병"
    },
    "echo_compass": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/echo_compass.png","name":"메아리 나침반","legacy_name":"메아리 나침반"},
    "bottled_shadow": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/bottled_shadow.png","name":"병에 든 그림자","legacy_name":"병에 든 그림자"},
    "watching_brooch": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/watching_brooch.png","name":"눈알 브로치","legacy_name":"눈알 브로치"},
    "moon_moth_case": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/moon_moth_case.png","name":"달나방 표본함","legacy_name":"달나방 표본함"},
    "drowned_bell": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/drowned_bell.png","name":"물에 잠긴 은종","legacy_name":"물에 잠긴 은종"},
    "rune_glove": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/rune_glove.png","name":"룬 재봉사의 장갑","legacy_name":"룬 재봉사의 장갑"},
    "basilisk_scale": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/basilisk_scale.png","name":"바실리스크 비늘","legacy_name":"바실리스크 비늘"},
    "clockwork_beetle": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/clockwork_beetle.png","name":"태엽 딱정벌레","legacy_name":"태엽 딱정벌레"},
    "grave_candle": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/grave_candle.png","name":"묘지의 푸른 초","legacy_name":"묘지의 푸른 초"},
    "star_map_fragment": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/star_map_fragment.png","name":"별자리 지도 조각","legacy_name":"별자리 지도 조각"},
    "sea_witch_comb": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/sea_witch_comb.png","name":"해마녀의 산호빗","legacy_name":"해마녀의 산호빗"},
    "alchemist_spoon": {"texture":"res://assets/art/ui/fallback.png","final_texture":"res://assets/art/items/alchemist_spoon.png","name":"연금술사의 계량숟가락","legacy_name":"연금술사의 계량숟가락"}
  },
  "sellers": {
    "blue": {
      "texture": "res://assets/art/sellers/blue.png",
      "final_texture": "res://assets/art/sellers/blue.png",
      "name": "가면 수집가",
      "legacy_name": "별빛 상인 블루"
    },
    "krok": {
      "texture": "res://assets/art/sellers/krok.png",
      "final_texture": "res://assets/art/sellers/krok.png",
      "name": "상자덕후 고블린",
      "legacy_name": "비늘장수 크록"
    },
    "morna": {
      "texture": "res://assets/art/sellers/morna.png",
      "final_texture": "res://assets/art/sellers/morna.png",
      "name": "눈물냥이",
      "legacy_name": "유령 모르나"
    },
    "myomyo": {
      "texture": "res://assets/art/sellers/myomyo.png",
      "final_texture": "res://assets/art/sellers/myomyo.png",
      "name": "지하램프상인",
      "legacy_name": "야시장지기 묘묘"
    },
    "pipi": {
      "texture": "res://assets/art/sellers/pipi.png",
      "final_texture": "res://assets/art/sellers/pipi.png",
      "name": "찻잔 할멈",
      "legacy_name": "바느질 마녀 피피"
    },
    "grizzle": {
      "texture": "res://assets/art/sellers/grizzle.png",
      "final_texture": "res://assets/art/sellers/grizzle.png",
      "name": "책벌레 임프",
      "legacy_name": "고철상 그리즐"
    },
    "toto": {
      "texture": "res://assets/art/sellers/toto.png",
      "final_texture": "res://assets/art/sellers/toto.png",
      "name": "허풍쟁이 마법사",
      "legacy_name": "해골 악사 토토"
    },
    "rook": {
      "texture": "res://assets/art/sellers/rook.png",
      "final_texture": "res://assets/art/sellers/rook.png",
      "name": "급전 오우거",
      "legacy_name": "까마귀 루크"
    }
  },
  "ui": {
    "market": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/ui/market.png"
    },
    "brand": {
      "texture": "res://assets/art/ui/brand.png",
      "final_texture": "res://assets/art/ui/brand.png"
    },
    "appraiser": {
      "texture": "res://assets/art/ui/appraiser.png",
      "final_texture": "res://assets/art/ui/appraiser.png"
    },
    "title_background": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/ui/title_background.png"
    },
    "onboarding_world": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/ui/onboarding_world.png"
    },
    "onboarding_role": {
      "texture": "res://assets/art/ui/appraiser.png",
      "final_texture": "res://assets/art/ui/onboarding_role.png"
    },
    "onboarding_goal": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/ui/onboarding_goal.png"
    },
    "district_night_market": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/districts/night_market.png"
    },
    "district_tower": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/districts/tower.png"
    },
    "district_dock": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/districts/dock.png"
    },
    "district_grave": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/districts/grave.png"
    },
    "workshop": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/ui/workshop.png"
    },
    "relationships": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/ui/relationships.png"
    },
    "collection": {
      "texture": "res://assets/art/ui/market.png",
      "final_texture": "res://assets/art/ui/collection.png"
    },
    "fallback": {
      "texture": "res://assets/art/ui/fallback.png",
      "final_texture": "res://assets/art/ui/fallback.png"
    }
  }
}
