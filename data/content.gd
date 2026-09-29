extends RefCounted

const RARITY_MULTIPLIERS := {
	"일반": 0.78,
	"고급": 1.0,
	"희귀": 1.35,
	"영웅": 1.78,
	"전설": 2.45
}

const STATE_MULTIPLIERS := {
	"진품": 1.0,
	"모조품": 0.18,
	"결함품": 0.48
}

const CONDITION_MULTIPLIERS := {
	"최상": 1.16,
	"양호": 1.0,
	"사용감": 0.82,
	"손상": 0.58
}

const ITEMS := [
	{"id":"moon_ring","name":"달빛 속삭임 반지","category":"장신구","tags":["마법","수집","고대"],"base_value":24000,"rarity_weights":{"고급":0.25,"희귀":0.34,"영웅":0.26,"전설":0.15},"state_weights":{"진품":0.58,"모조품":0.25,"결함품":0.17},"investigation_profile":"ornament_magic","investigation_overrides":{"exterior":{"short_label":"보석 결","label":"보석 안쪽 결을 빛에 비춰 본다"},"mark":{"short_label":"안쪽 각인","label":"반지 안쪽의 제작 각인을 확인한다"},"function":{"short_label":"마력 맥동","label":"달빛에 비춰 마력 맥동을 확인한다"},"market":{"short_label":"반지 시세","label":"비슷한 고대 마법 반지의 최근 거래가를 확인한다"}}},
	{"id":"dragon_tooth","name":"용의 이빨","category":"재료","tags":["재료","용","연금"],"base_value":19000,"rarity_weights":{"일반":0.18,"고급":0.34,"희귀":0.31,"영웅":0.17},"state_weights":{"진품":0.50,"모조품":0.32,"결함품":0.18},"investigation_profile":"organic_material","investigation_overrides":{"exterior":{"short_label":"성장결","label":"표면의 성장결과 자연 마모를 살펴본다"},"mark":{"short_label":"뿌리 단면","label":"뿌리 쪽 절단면과 층을 확인한다"},"function":{"short_label":"밀도·무게","label":"들어 보며 밀도와 무게 균형을 확인한다"},"origin":{"short_label":"채취 경로","label":"판매자에게 어디서 채취된 이빨인지 묻는다"}}},
	{"id":"cursed_mirror","name":"저주받은 손거울","category":"유물","tags":["저주","고대","수집"],"base_value":16000,"rarity_weights":{"고급":0.42,"희귀":0.34,"영웅":0.18,"전설":0.06},"state_weights":{"진품":0.54,"모조품":0.18,"결함품":0.28},"investigation_profile":"enchanted_relic","investigation_overrides":{"exterior":{"short_label":"은막 균열","label":"거울 은막과 가장자리 균열을 비스듬히 본다"},"mark":{"short_label":"뒷면 문양","label":"뒷판의 문양과 제작 흔적을 확인한다"},"function":{"short_label":"반사 반응","label":"얼굴과 촛불을 비춰 반사 반응을 확인한다"},"market":{"short_label":"저주유물 시세","label":"비슷한 저주 유물의 거래 범위를 확인한다"}},"unique_clues":[{"id":"mirror_u1","kind":"애매한","signal":"neutral","text":"거울을 기울일 때 아주 잠깐 뒤쪽 풍경이 늦게 따라온다.","reveal":"미세한 반사 지연은 저주 잔향이었지만 진위 자체를 확정하는 신호는 아니었다."}]},
	{"id":"soul_lantern","name":"영혼의 랜턴","category":"마도구","tags":["마법","영혼","고대"],"base_value":27000,"rarity_weights":{"고급":0.20,"희귀":0.42,"영웅":0.28,"전설":0.10},"state_weights":{"진품":0.62,"모조품":0.14,"결함품":0.24},"investigation_profile":"enchanted_relic","investigation_overrides":{"exterior":{"short_label":"유리 그을음","label":"유리 안쪽의 그을음과 사용 흔적을 본다"},"mark":{"short_label":"프레임 각인","label":"금속 프레임과 바닥의 제작 각인을 확인한다"},"function":{"short_label":"심지 반응","label":"심지에 약한 마력을 대어 반응을 확인한다"},"origin":{"short_label":"사용 이력","label":"판매자에게 어디에서 쓰이던 랜턴인지 묻는다"}}},
	{"id":"witch_thimble","name":"마녀의 은골무","category":"잡화","tags":["마법","공예","수집"],"base_value":9000,"rarity_weights":{"일반":0.24,"고급":0.42,"희귀":0.26,"영웅":0.08},"state_weights":{"진품":0.56,"모조품":0.28,"결함품":0.16},"investigation_profile":"crafted_magic","investigation_overrides":{"exterior":{"short_label":"바늘 자국","label":"표면의 바늘 자국과 마모 방향을 살펴본다"},"mark":{"short_label":"안쪽 표식","label":"골무 안쪽의 공방 표식과 마감을 확인한다"}}},
	{"id":"goblin_watch","name":"고블린 회중시계","category":"장신구","tags":["기계","고대","수집"],"base_value":15000,"rarity_weights":{"일반":0.12,"고급":0.40,"희귀":0.35,"영웅":0.13},"state_weights":{"진품":0.57,"모조품":0.27,"결함품":0.16},"investigation_profile":"mechanical","investigation_overrides":{"mark":{"short_label":"무브먼트 각인","label":"뒷뚜껑을 열어 내부 각인과 부품 표식을 본다"},"function":{"short_label":"태엽 작동","label":"태엽을 감아 초침과 톱니 반응을 확인한다"},"market":{"short_label":"시계 시세","label":"고블린 기계식 회중시계의 거래가를 확인한다"}},"unique_clues":[{"id":"watch_u1","kind":"부정적","signal":"defect","text":"태엽을 감을 때 한 구간에서 미세하게 톱니가 튄다.","reveal":"내부 기어 하나가 마모되어 실제 수리 비용이 발생하는 결함이었다."}]},
	{"id":"bone_flute","name":"망자의 뼈피리","category":"악기","tags":["저주","음악","수집"],"base_value":12500,"rarity_weights":{"일반":0.16,"고급":0.42,"희귀":0.31,"영웅":0.11},"state_weights":{"진품":0.52,"모조품":0.22,"결함품":0.26},"investigation_profile":"organic_instrument","investigation_overrides":{"exterior":{"short_label":"골질 표면","label":"뼈 표면의 결, 균열, 마모를 살펴본다"},"mark":{"short_label":"마디 각인","label":"마디와 취구 주변의 새김 흔적을 확인한다"}}},
	{"id":"meteor_coin","name":"운석 동전","category":"수집품","tags":["수집","별","고대"],"base_value":21500,"rarity_weights":{"고급":0.22,"희귀":0.40,"영웅":0.27,"전설":0.11},"state_weights":{"진품":0.60,"모조품":0.29,"결함품":0.11},"investigation_profile":"collectible","investigation_overrides":{"exterior":{"short_label":"테두리 마모","label":"동전 테두리의 마모와 충격 흔적을 살펴본다"},"function":{"short_label":"자성·밀도","label":"자석 반응과 손에 느껴지는 밀도를 확인한다"},"market":{"short_label":"운석동전 시세","label":"운석 금속 수집품의 최근 거래가를 확인한다"}}},
	{"id":"phoenix_feather","name":"불사조 깃털","category":"재료","tags":["재료","마법","연금"],"base_value":23500,"rarity_weights":{"고급":0.20,"희귀":0.38,"영웅":0.31,"전설":0.11},"state_weights":{"진품":0.47,"모조품":0.39,"결함품":0.14},"investigation_profile":"organic_material","investigation_overrides":{"exterior":{"short_label":"깃결·광택","label":"깃가지의 결, 색 변화, 자연 광택을 살펴본다"},"mark":{"short_label":"깃대 단면","label":"깃대 단면의 층과 인공 접합 흔적을 확인한다"},"function":{"short_label":"열 반응","label":"약한 열을 가까이 대어 색과 마력 반응을 본다"},"market":{"short_label":"연금재료 시세","label":"희귀 연금 재료와 불사조 깃털 거래가를 확인한다"}},"unique_clues":[{"id":"phoenix_u1","kind":"긍정적","signal":"genuine","text":"열을 가까이 대자 깃가지 끝의 빛이 사라지지 않고 안쪽으로 번진다.","reveal":"불꽃을 흉내 낸 염색이 아니라 실제 불사조 깃털의 열 반응이었다."}]},
	{"id":"mimic_key","name":"미믹의 황동열쇠","category":"열쇠","tags":["기계","마법","고대"],"base_value":11000,"rarity_weights":{"일반":0.22,"고급":0.44,"희귀":0.26,"영웅":0.08},"state_weights":{"진품":0.64,"모조품":0.20,"결함품":0.16},"investigation_profile":"mechanical","investigation_overrides":{"exterior":{"short_label":"톱니 마모","label":"열쇠 톱니의 마모와 사용 방향을 살펴본다"},"mark":{"short_label":"손잡이 각인","label":"황동 손잡이의 각인과 접합부를 확인한다"},"function":{"short_label":"잠금 반응","label":"시험 자물쇠에 넣어 걸림과 마력 반응을 확인한다"},"origin":{"short_label":"획득 경로","label":"판매자에게 미믹과 관련된 입수 경로를 묻는다"},"market":{"short_label":"고대열쇠 시세","label":"고대·마법 열쇠류의 최근 거래가를 확인한다"}}},
	{"id":"mermaid_pearl","name":"심해 인어의 진주","category":"보석","tags":["수집","바다","마법"],"base_value":30000,"rarity_weights":{"고급":0.18,"희귀":0.37,"영웅":0.30,"전설":0.15},"state_weights":{"진품":0.45,"모조품":0.42,"결함품":0.13},"investigation_profile":"ornament_magic","investigation_overrides":{"exterior":{"short_label":"표면 결","label":"진주층의 결, 광택, 작은 흠을 빛에 비춰 본다"},"mark":{"short_label":"천공 흔적","label":"구멍과 밑면의 가공 흔적을 확대해 본다"},"function":{"short_label":"수분·마력","label":"물방울을 대어 색과 마력 반응을 확인한다"},"origin":{"short_label":"채취 해역","label":"판매자에게 어느 해역에서 나온 진주인지 묻는다"},"market":{"short_label":"진주 시세","label":"심해 진주와 마법 보석의 최근 거래가를 확인한다"}}},
	{"id":"frost_vial","name":"빙결 정수 병","category":"연금재료","tags":["재료","연금","마법"],"base_value":14000,"rarity_weights":{"일반":0.12,"고급":0.43,"희귀":0.32,"영웅":0.13},"state_weights":{"진품":0.66,"모조품":0.12,"결함품":0.22},"investigation_profile":"arcane_container","investigation_overrides":{"exterior":{"short_label":"병목 봉인","label":"병목의 봉인 상태와 서리 자국을 살펴본다"},"mark":{"short_label":"바닥 표식","label":"병 바닥의 제조 표식과 유리 가공을 확인한다"},"function":{"short_label":"냉기 반응","label":"병을 기울여 냉기와 내용물 반응을 확인한다"},"market":{"short_label":"정수 시세","label":"빙결 정수와 연금 용액의 최근 거래가를 확인한다"}}}
]

const SELLER_TYPES := {
	"urgent": {
		"name":"급한 판매자","summary":"빨리 처분하려 해 큰 폭의 양보가 나올 수 있음","public_cues":["오늘 안에 정리하고 싶다는 말을 먼저 꺼냈다.","답장이 빠르고 거래를 오래 끌고 싶어 하지 않는 눈치다."],"discount_receptiveness":0.90,"claim_honesty":0.82,"knowledge":0.52,"patience":2,"floor_ratio":0.66
	},
	"greedy": {
		"name":"욕심 많은 판매자","summary":"가치 있는 물건일수록 비싸게 부르고 잘 안 깎아줌","public_cues":["가격 이야기가 나오면 물건의 장점을 길게 늘어놓는다.","작은 흠집을 지적해도 가치와는 별개라고 선을 긋는다."],"discount_receptiveness":0.26,"claim_honesty":0.76,"knowledge":0.73,"patience":3,"floor_ratio":0.86
	},
	"bluffer": {
		"name":"허풍쟁이","summary":"설명에 과장이 섞일 수 있어 말보다 실물 단서가 중요","public_cues":["희귀하다는 말을 여러 번 강조하지만 구체적인 근거는 잘 말하지 않는다.","질문을 바꾸면 설명의 세부 내용이 조금씩 달라진다."],"discount_receptiveness":0.48,"claim_honesty":0.36,"knowledge":0.58,"patience":2,"floor_ratio":0.74
	},
	"naive": {
		"name":"순진한 판매자","summary":"물건 값을 잘 몰라 대박과 함정이 모두 생길 수 있음","public_cues":["시세를 묻자 확신 없이 예전에 들은 가격부터 이야기한다.","가격 근거보다 이 물건을 어떻게 얻게 됐는지 사연을 더 많이 말한다."],"discount_receptiveness":0.72,"claim_honesty":0.84,"knowledge":0.22,"patience":2,"floor_ratio":0.68
	},
	"expert": {
		"name":"전문가","summary":"시세를 잘 알고 있어 큰 차익을 만들기 어렵지만 설명은 정확한 편","public_cues":["질문에 짧고 구체적으로 답하며 가격 근거를 바로 제시한다.","상태와 출처를 구분해서 설명하고 애매한 부분은 단정하지 않는다."],"discount_receptiveness":0.33,"claim_honesty":0.94,"knowledge":0.95,"patience":3,"floor_ratio":0.90
	}
}

const SELLERS := [
	{"id":"blue","name":"별빛 상인 블루","type":"expert"},
	{"id":"krok","name":"비늘장수 크록","type":"greedy"},
	{"id":"morna","name":"유령 모르나","type":"urgent"},
	{"id":"myomyo","name":"야시장지기 묘묘","type":"expert"},
	{"id":"pipi","name":"바느질 마녀 피피","type":"naive"},
	{"id":"grizzle","name":"고철상 그리즐","type":"greedy"},
	{"id":"toto","name":"해골 악사 토토","type":"bluffer"},
	{"id":"rook","name":"까마귀 루크","type":"urgent"}
]

const BUYERS := [
	{"id":"collector","name":"기묘한 수집가","summary":"희귀하고 수집 가치가 높은 물건에 웃돈을 얹음","preferred_tags":["수집","고대"],"base_multiplier":0.86},
	{"id":"mage","name":"탑의 마법사","summary":"마법·영혼 속성이 뚜렷한 물건을 비싸게 삼","preferred_tags":["마법","영혼"],"base_multiplier":0.84},
	{"id":"alchemist","name":"연금술사","summary":"재료·연금용 물건의 실용 가치를 높게 평가","preferred_tags":["재료","연금"],"base_multiplier":0.86},
	{"id":"antiquarian","name":"골동품상","summary":"고대·저주·기계 계열의 출처와 상태를 중요하게 봄","preferred_tags":["고대","저주","기계"],"base_multiplier":0.85},
	{"id":"scrap","name":"고물상","summary":"거의 무엇이든 바로 사지만 제안가는 낮음","preferred_tags":[],"base_multiplier":0.66}
]

const CLUES := [
	{"id":"g1","kind":"긍정적","signal":"genuine","text":"마법 각인이 얕지 않고 안쪽까지 이어져 있다.","reveal":"감정 결과, 이 각인은 실제 제작 공정에서 새겨진 흔적이었다."},
	{"id":"g2","kind":"긍정적","signal":"genuine","text":"손때가 닿지 않은 홈에도 같은 재질의 변색이 남아 있다.","reveal":"표면만 인위적으로 낡힌 것이 아니라 오래 사용된 진품의 흔적이었다."},
	{"id":"g3","kind":"긍정적","signal":"genuine","text":"빛을 비추면 표면 문양이 각도에 따라 자연스럽게 이어진다.","reveal":"복제품에서 내기 어려운 연속 문양이 진품 판정 근거가 되었다."},
	{"id":"g4","kind":"긍정적","signal":"genuine","text":"접합부 안쪽에 오래된 제작소 표식이 희미하게 남아 있다.","reveal":"희미한 제작소 표식이 실제 연대와 일치했다."},
	{"id":"g5","kind":"긍정적","signal":"genuine","text":"재질의 무게감이 겉보기보다 묵직하고 균일하다.","reveal":"재질 밀도가 알려진 진품 규격과 맞았다."},
	{"id":"g6","kind":"긍정적","signal":"genuine","text":"미세한 마력 반응이 일정한 박자로 반복된다.","reveal":"불규칙한 착색이 아니라 실제 마력 회로의 반응이었다."},
	{"id":"q1","kind":"긍정적","signal":"quality","text":"모서리 마감이 닳았는데도 형태가 무너지지 않았다.","reveal":"보존 상태가 예상보다 좋아 상태 등급에 가산점이 붙었다."},
	{"id":"q2","kind":"긍정적","signal":"quality","text":"보관 흔적은 있지만 균열이나 들뜸이 거의 없다.","reveal":"실사용품치고 구조 손상이 적어 높은 상태 등급을 받았다."},
	{"id":"q3","kind":"긍정적","signal":"quality","text":"냄새나 잔여물이 적고 관리된 흔적이 있다.","reveal":"오염이 적어 수리 비용이 거의 들지 않는 상태였다."},
	{"id":"q4","kind":"긍정적","signal":"quality","text":"움직이는 부분이 걸리지 않고 매끄럽게 반응한다.","reveal":"핵심 기능부가 정상 작동해 가치 하락이 없었다."},
	{"id":"i1","kind":"부정적","signal":"imitation","text":"밑면에 있어야 할 제작자 서명이 보이지 않는다.","reveal":"정식 제작품에는 필수인 서명이 없어 모조품 판정에 크게 작용했다."},
	{"id":"i2","kind":"부정적","signal":"imitation","text":"장식 홈의 깊이가 군데군데 일정하지 않다.","reveal":"주조 복제품에서 흔한 마감 오차였다."},
	{"id":"i3","kind":"부정적","signal":"imitation","text":"빛을 받으면 보석 안쪽에서 유리 같은 기포가 보인다.","reveal":"보석이 천연석이 아니라 착색 유리라는 것이 확인됐다."},
	{"id":"i4","kind":"부정적","signal":"imitation","text":"오래된 물건치고 표면의 마모 방향이 너무 균일하다.","reveal":"인위적으로 낡게 만든 흔적이 확인됐다."},
	{"id":"i5","kind":"부정적","signal":"imitation","text":"금속색이 긁힌 부분에서 갑자기 달라진다.","reveal":"귀금속이 아니라 얇은 도금층이었다."},
	{"id":"i6","kind":"부정적","signal":"imitation","text":"문양의 좌우가 기묘하게 대칭이라 손작업 흔적이 없다.","reveal":"최근 복제 틀에서 찍힌 패턴과 일치했다."},
	{"id":"d1","kind":"부정적","signal":"defect","text":"미세한 균열 주변만 색이 조금 어둡다.","reveal":"내부까지 이어진 균열이라 수리 비용이 크게 잡혔다."},
	{"id":"d2","kind":"부정적","signal":"defect","text":"작동할 때 아주 짧게 끊기는 느낌이 있다.","reveal":"핵심 기능부의 결함이 확인되어 가치가 내려갔다."},
	{"id":"d3","kind":"부정적","signal":"defect","text":"한쪽이 아주 조금 휘어 균형이 맞지 않는다.","reveal":"외관 문제가 아니라 구조 변형으로 판정됐다."},
	{"id":"d4","kind":"부정적","signal":"defect","text":"표면 일부에서 마력 반응이 아예 끊긴다.","reveal":"마력 회로가 손상된 결함품이었다."},
	{"id":"d5","kind":"부정적","signal":"defect","text":"닫히거나 맞물리는 부분이 한 번에 들어가지 않는다.","reveal":"부품 마모가 심해 상태 등급이 내려갔다."},
	{"id":"d6","kind":"부정적","signal":"defect","text":"보관함 안쪽에 수리용 접착 흔적이 남아 있다.","reveal":"과거 파손 후 임시 수리를 한 흔적이었다."},
	{"id":"n1","kind":"애매한","signal":"neutral","text":"판매자가 물건을 천으로 여러 겹 싸 두었다.","reveal":"보관 습관일 뿐 진품 여부와 직접 관계는 없었다."},
	{"id":"n2","kind":"애매한","signal":"neutral","text":"표면에서 약한 향초 냄새가 난다.","reveal":"이전 소유자의 보관 환경 흔적일 뿐 가치 판단 근거는 아니었다."},
	{"id":"n3","kind":"애매한","signal":"neutral","text":"판매자가 출처를 묻자 잠깐 대답을 망설였다.","reveal":"긴장한 행동이었지만 물건의 진위와는 직접 연결되지 않았다."},
	{"id":"n4","kind":"애매한","signal":"neutral","text":"포장 상자만 유난히 새것이다.","reveal":"상자는 최근 교체된 것으로 본품 가치와 무관했다."},
	{"id":"n5","kind":"애매한","signal":"neutral","text":"물건에서 미세하게 차가운 기운이 느껴진다.","reveal":"재질 특성 때문에 생긴 현상으로 진품의 결정적 증거는 아니었다."},
	{"id":"n6","kind":"애매한","signal":"neutral","text":"판매자는 오늘 안에 팔고 싶다고 여러 번 말한다.","reveal":"급한 사정은 가격 협상에는 영향을 줬지만 진위 자체를 뜻하진 않았다."},
	{"id":"n7","kind":"애매한","signal":"neutral","text":"이전 구매 영수증은 있지만 상호명이 지워져 있다.","reveal":"출처를 확정할 수 없는 자료라 보조 정보로만 취급됐다."},
	{"id":"n8","kind":"애매한","signal":"neutral","text":"같은 종류의 물건보다 크기가 아주 조금 작다.","reveal":"제작 시기별 규격 차이 범위 안이라 결정적 단서는 아니었다."}
]

const ARCHETYPES := {
	"stable":{"name":"안정형","min":0.68,"max":0.90},
	"ambiguous":{"name":"애매형","min":0.82,"max":1.22},
	"risky":{"name":"고위험형","min":0.62,"max":1.48},
	"jackpot":{"name":"대박 후보","min":0.34,"max":0.66},
	"trap":{"name":"함정형","min":1.38,"max":1.95}
}


# v0.2.1 Core Interaction Rewrite
const MARKET_INVESTIGATION_BUDGET = 4
const POST_INSPECTION_BUDGET = 2
const QUOTE_REQUEST_BUDGET = 2

# v0.2.14 Information Economy Rebalance
# Information prices are based only on the player's known purchase price.
# Hidden actual value / rarity / authenticity never changes a displayed cost.
const INFORMATION_COST_ROUND_TO = 50
const PROFESSIONAL_APPRAISAL_COST_RULE := {
	"ratio":0.075,
	"min":300,
	"max":2500
}

const INVESTIGATION_ACTIONS = [
	{"id":"exterior","label":"외형 자세히 보기"},
	{"id":"mark","label":"각인 / 제작자 표시 확인"},
	{"id":"function","label":"작동 / 반응 상태 확인"},
	{"id":"origin","label":"판매자에게 출처 묻기"},
	{"id":"market","label":"동종품 시세 조사"}
]


# v0.2.13 Content Scalability
# New items normally choose one reusable profile and only override exceptional actions.
# The stable action IDs preserve old saves and gameplay logic.
const INVESTIGATION_PROFILES := {
	"ornament_magic": [
		{"id":"exterior","short_label":"표면·광택","label":"표면의 결, 광택, 마모를 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"제작 표식","label":"안쪽이나 밑면의 제작 표식을 확인한다","clue_slot":1},
		{"id":"function","short_label":"마력 반응","label":"빛이나 약한 마력에 대한 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"소유 이력","label":"판매자에게 이전 소유자와 입수 경로를 묻는다","clue_slot":3},
		{"id":"market","short_label":"장신구 시세","label":"비슷한 장신구의 최근 거래가를 확인한다","market":true}
	],
	"organic_material": [
		{"id":"exterior","short_label":"표면 결","label":"자연 재질의 결, 마모, 변색을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"단면·성장 흔적","label":"단면과 성장·형성 흔적을 확인한다","clue_slot":1},
		{"id":"function","short_label":"밀도·반응","label":"무게, 밀도, 열·마력 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"채취 경로","label":"판매자에게 채취 장소와 입수 경로를 묻는다","clue_slot":3},
		{"id":"market","short_label":"재료 시세","label":"비슷한 희귀 재료의 최근 거래가를 확인한다","market":true}
	],
	"enchanted_relic": [
		{"id":"exterior","short_label":"표면 상태","label":"표면의 노화, 균열, 사용 흔적을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"제작 문양","label":"뒷면과 접합부의 제작 문양을 확인한다","clue_slot":1},
		{"id":"function","short_label":"이상 반응","label":"빛이나 마력에 나타나는 이상 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"소유 이력","label":"판매자에게 이전 소유자와 사용 이력을 묻는다","clue_slot":3},
		{"id":"market","short_label":"유물 시세","label":"비슷한 마법 유물의 거래 범위를 확인한다","market":true}
	],
	"mechanical": [
		{"id":"exterior","short_label":"외장 마모","label":"외장과 작동부의 마모 방향을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"내부 각인","label":"내부 부품과 제작 각인을 확인한다","clue_slot":1},
		{"id":"function","short_label":"작동 상태","label":"기구를 직접 작동시켜 걸림과 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"수리 이력","label":"판매자에게 수리와 부품 교체 이력을 묻는다","clue_slot":3},
		{"id":"market","short_label":"기계품 시세","label":"비슷한 고대 기계품의 최근 거래가를 확인한다","market":true}
	],
	"crafted_magic": [
		{"id":"exterior","short_label":"사용 흔적","label":"표면의 사용 흔적과 공예 마감을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"공방 표식","label":"안쪽의 공방 표식과 접합 마감을 확인한다","clue_slot":1},
		{"id":"function","short_label":"마력 잔향","label":"사용했을 때 남는 마력 잔향을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"공방·소유 이력","label":"판매자에게 제작 공방과 이전 소유자를 묻는다","clue_slot":3},
		{"id":"market","short_label":"공예품 시세","label":"비슷한 마법 공예품의 최근 거래가를 확인한다","market":true}
	],
	"organic_instrument": [
		{"id":"exterior","short_label":"재질 표면","label":"재질의 결, 균열, 손때를 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"제작 흔적","label":"취구와 마디 주변의 제작 흔적을 확인한다","clue_slot":1},
		{"id":"function","short_label":"음정·공명","label":"짧게 연주해 음정과 공명이 안정적인지 확인한다","clue_slot":2},
		{"id":"origin","short_label":"연주자 이력","label":"판매자에게 이전 연주자와 입수 경로를 묻는다","clue_slot":3},
		{"id":"market","short_label":"악기 시세","label":"비슷한 희귀 악기의 최근 거래가를 확인한다","market":true}
	],
	"collectible": [
		{"id":"exterior","short_label":"표면·테두리","label":"표면과 테두리의 마모, 충격 흔적을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"제작 문양","label":"앞뒷면의 제작 문양과 깊이를 확인한다","clue_slot":1},
		{"id":"function","short_label":"재질 반응","label":"무게, 자성, 재질 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"발견 경로","label":"판매자에게 발견 장소와 이전 소유자를 묻는다","clue_slot":3},
		{"id":"market","short_label":"수집품 시세","label":"비슷한 수집품의 최근 거래가를 확인한다","market":true}
	],
	"arcane_container": [
		{"id":"exterior","short_label":"봉인·용기","label":"봉인 상태와 용기의 균열·변색을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"제조 표식","label":"바닥과 병목의 제조 표식을 확인한다","clue_slot":1},
		{"id":"function","short_label":"내용물 반응","label":"기울이거나 마력을 대어 내용물 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"제조·보관 경로","label":"판매자에게 제조자와 보관 경로를 묻는다","clue_slot":3},
		{"id":"market","short_label":"연금재료 시세","label":"비슷한 연금 재료의 최근 거래가를 확인한다","market":true}
	]
}

# Optional profile-level clue pools. A new item automatically inherits these
# without needing a bespoke clue set. Missing signals fall back to CLUES.
const PROFILE_CLUES := {
	"ornament_magic": [
		{"id":"orn_g1","kind":"긍정적","signal":"genuine","text":"빛을 돌려 비추면 표면층의 무늬가 끊기지 않고 이어진다.","reveal":"표면 코팅이 아니라 재질 내부에서 형성된 진품 특유의 결이었다."},
		{"id":"orn_i1","kind":"부정적","signal":"imitation","text":"광택이 닳은 부분에서 안쪽 재질의 색이 갑자기 달라진다.","reveal":"겉면만 고급 재질처럼 처리한 복제품 흔적이었다."},
		{"id":"orn_d1","kind":"부정적","signal":"defect","text":"세팅과 몸체 사이가 미세하게 흔들린다.","reveal":"접합부가 약해져 수리가 필요한 상태였다."},
		{"id":"orn_n1","kind":"애매한","signal":"neutral","text":"보관 천에 희미한 향이 남아 있다.","reveal":"보관 환경의 흔적일 뿐 가치와 직접 관계는 없었다."}
	],
	"organic_material": [
		{"id":"org_g1","kind":"긍정적","signal":"genuine","text":"표면과 단면의 결이 한 방향으로 자연스럽게 이어진다.","reveal":"겉면만 꾸민 가공품이 아니라 자연적으로 형성된 재질이었다."},
		{"id":"org_i1","kind":"부정적","signal":"imitation","text":"단면 안쪽에 균일한 인공 기포가 반복된다.","reveal":"자연 재질을 흉내 낸 주조 복제품의 흔적이었다."},
		{"id":"org_d1","kind":"부정적","signal":"defect","text":"안쪽 층 하나가 말라 갈라지며 힘을 받으면 벌어진다.","reveal":"보관 중 생긴 내부 손상이 실제 가치 하락으로 이어졌다."},
		{"id":"org_n1","kind":"애매한","signal":"neutral","text":"표면 온도가 주변 물건보다 조금 다르게 느껴진다.","reveal":"재질 특성에 따른 차이로 진위 판단의 결정적 근거는 아니었다."}
	],
	"enchanted_relic": [
		{"id":"rel_g1","kind":"긍정적","signal":"genuine","text":"마력 반응이 장식이 아니라 구조 안쪽을 따라 이동한다.","reveal":"실제 제작 과정에서 형성된 마력 회로의 반응이었다."},
		{"id":"rel_i1","kind":"부정적","signal":"imitation","text":"문양은 오래돼 보이지만 홈 안쪽에는 새 연마 흔적이 남아 있다.","reveal":"최근 복제한 뒤 표면만 인위적으로 낡힌 흔적이었다."},
		{"id":"rel_d1","kind":"부정적","signal":"defect","text":"특정 지점에서만 마력 반응이 갑자기 끊긴다.","reveal":"내부 회로 일부가 손상된 결함이었다."},
		{"id":"rel_n1","kind":"애매한","signal":"neutral","text":"가까이 두면 주변 촛불이 아주 약하게 흔들린다.","reveal":"잔류 마력 현상이었지만 진품 여부와 직접 연결되지는 않았다."}
	],
	"mechanical": [
		{"id":"mec_g1","kind":"긍정적","signal":"genuine","text":"내부 부품의 마모 정도와 외장의 사용감이 비슷한 시기로 보인다.","reveal":"외장과 무브먼트가 함께 오래 사용된 원래 구성품이었다."},
		{"id":"mec_i1","kind":"부정적","signal":"imitation","text":"겉면은 오래됐지만 내부 나사산은 지나치게 새것이다.","reveal":"최근 조립한 복제품에 오래된 외장만 씌운 흔적이었다."},
		{"id":"mec_d1","kind":"부정적","signal":"defect","text":"작동 중 한 구간에서 반복적으로 걸리는 느낌이 난다.","reveal":"내부 부품 마모로 수리가 필요한 결함이었다."},
		{"id":"mec_n1","kind":"애매한","signal":"neutral","text":"기름 냄새가 평소보다 강하게 난다.","reveal":"최근 정비 흔적이었지만 진위와는 직접 관계가 없었다."}
	],
	"crafted_magic": [
		{"id":"cra_g1","kind":"긍정적","signal":"genuine","text":"공방 표식과 손으로 다듬은 미세한 비대칭이 함께 남아 있다.","reveal":"해당 공방의 실제 수공 제작 방식과 일치했다."},
		{"id":"cra_i1","kind":"부정적","signal":"imitation","text":"공방 표식 주변만 유난히 날카롭고 새것처럼 보인다.","reveal":"기존 물건에 유명 공방 표식을 나중에 새긴 흔적이었다."},
		{"id":"cra_d1","kind":"부정적","signal":"defect","text":"사용할 때 한쪽 접합부에서 미세한 유격이 느껴진다.","reveal":"반복 사용으로 접합부가 약해진 상태였다."},
		{"id":"cra_n1","kind":"애매한","signal":"neutral","text":"손에 쥐면 약한 따뜻함이 남는다.","reveal":"재질의 열 보존 특성일 뿐 진위 판단 근거는 아니었다."}
	],
	"organic_instrument": [
		{"id":"ins_g1","kind":"긍정적","signal":"genuine","text":"재질의 자연 결이 음공 안쪽까지 이어져 있다.","reveal":"겉면만 꾸민 복제품이 아니라 한 재질로 제작된 물건이었다."},
		{"id":"ins_i1","kind":"부정적","signal":"imitation","text":"음공 안쪽의 색과 바깥 표면의 노화 정도가 크게 다르다.","reveal":"겉면만 오래된 것처럼 가공한 복제품이었다."},
		{"id":"ins_d1","kind":"부정적","signal":"defect","text":"특정 음에서 공명이 짧게 끊기고 잡음이 섞인다.","reveal":"보이지 않는 미세 균열이 공명을 방해하고 있었다."},
		{"id":"ins_n1","kind":"애매한","signal":"neutral","text":"연주 뒤 손끝에 약한 진동이 오래 남는다.","reveal":"재질 특성에 따른 공명일 뿐 진위의 결정적 증거는 아니었다."}
	],
	"collectible": [
		{"id":"col_g1","kind":"긍정적","signal":"genuine","text":"테두리 마모와 문양 홈 안쪽의 변색이 자연스럽게 이어진다.","reveal":"오랜 사용과 보관에서 생긴 실제 노화 흔적이었다."},
		{"id":"col_i1","kind":"부정적","signal":"imitation","text":"문양의 깊이가 모든 부분에서 지나치게 일정하다.","reveal":"현대식 틀로 찍어낸 복제품의 특징이었다."},
		{"id":"col_d1","kind":"부정적","signal":"defect","text":"가장자리 충격이 안쪽 층까지 이어져 미세하게 벌어져 있다.","reveal":"표면 흠집이 아니라 구조적 손상이었다."},
		{"id":"col_n1","kind":"애매한","signal":"neutral","text":"보관 케이스만 본품보다 훨씬 새것이다.","reveal":"최근 교체된 케이스로 본품의 가치와 무관했다."}
	],
	"arcane_container": [
		{"id":"arc_g1","kind":"긍정적","signal":"genuine","text":"봉인 안쪽까지 같은 마력 흔적이 이어져 있다.","reveal":"나중에 덧씌운 봉인이 아니라 원래 제조 과정의 흔적이었다."},
		{"id":"arc_i1","kind":"부정적","signal":"imitation","text":"내용물의 색은 선명하지만 병 안쪽에 침전층이 전혀 없다.","reveal":"오래 보관된 정수를 흉내 낸 최근 혼합물이었다."},
		{"id":"arc_d1","kind":"부정적","signal":"defect","text":"병목 가까이에서만 반응이 약해지고 작은 기포가 생긴다.","reveal":"봉인이 약해져 내용물의 효력이 일부 빠져나간 상태였다."},
		{"id":"arc_n1","kind":"애매한","signal":"neutral","text":"유리 표면에 얇은 서리나 습기가 반복해서 맺힌다.","reveal":"내용물 특성에 따른 현상으로 진위와 직접 연결되지는 않았다."}
	]
}

const POST_INSPECTIONS = [
	{"id":"material","label":"재질 검사","ratio":0.020,"min":100,"max":700},
	{"id":"magic","label":"마력 / 반응 검사","ratio":0.030,"min":150,"max":900},
	{"id":"internal","label":"내부 구조 확인","ratio":0.040,"min":200,"max":1200}
]
