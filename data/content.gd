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
	{"id":"moon_ring","name":"달빛 속삭임 반지","category":"장신구","tags":["마법","수집","고대"],"base_value":24000,"rarity_weights":{"고급":0.25,"희귀":0.34,"영웅":0.26,"전설":0.15},"state_weights":{"진품":0.58,"모조품":0.25,"결함품":0.17}},
	{"id":"dragon_tooth","name":"용의 이빨","category":"재료","tags":["재료","용","연금"],"base_value":19000,"rarity_weights":{"일반":0.18,"고급":0.34,"희귀":0.31,"영웅":0.17},"state_weights":{"진품":0.50,"모조품":0.32,"결함품":0.18}},
	{"id":"cursed_mirror","name":"저주받은 손거울","category":"유물","tags":["저주","고대","수집"],"base_value":16000,"rarity_weights":{"고급":0.42,"희귀":0.34,"영웅":0.18,"전설":0.06},"state_weights":{"진품":0.54,"모조품":0.18,"결함품":0.28}},
	{"id":"soul_lantern","name":"영혼의 랜턴","category":"마도구","tags":["마법","영혼","고대"],"base_value":27000,"rarity_weights":{"고급":0.20,"희귀":0.42,"영웅":0.28,"전설":0.10},"state_weights":{"진품":0.62,"모조품":0.14,"결함품":0.24}},
	{"id":"witch_thimble","name":"마녀의 은골무","category":"잡화","tags":["마법","공예","수집"],"base_value":9000,"rarity_weights":{"일반":0.24,"고급":0.42,"희귀":0.26,"영웅":0.08},"state_weights":{"진품":0.56,"모조품":0.28,"결함품":0.16}},
	{"id":"goblin_watch","name":"고블린 회중시계","category":"장신구","tags":["기계","고대","수집"],"base_value":15000,"rarity_weights":{"일반":0.12,"고급":0.40,"희귀":0.35,"영웅":0.13},"state_weights":{"진품":0.57,"모조품":0.27,"결함품":0.16}},
	{"id":"bone_flute","name":"망자의 뼈피리","category":"악기","tags":["저주","음악","수집"],"base_value":12500,"rarity_weights":{"일반":0.16,"고급":0.42,"희귀":0.31,"영웅":0.11},"state_weights":{"진품":0.52,"모조품":0.22,"결함품":0.26}},
	{"id":"meteor_coin","name":"운석 동전","category":"수집품","tags":["수집","별","고대"],"base_value":21500,"rarity_weights":{"고급":0.22,"희귀":0.40,"영웅":0.27,"전설":0.11},"state_weights":{"진품":0.60,"모조품":0.29,"결함품":0.11}},
	{"id":"phoenix_feather","name":"불사조 깃털","category":"재료","tags":["재료","마법","연금"],"base_value":23500,"rarity_weights":{"고급":0.20,"희귀":0.38,"영웅":0.31,"전설":0.11},"state_weights":{"진품":0.47,"모조품":0.39,"결함품":0.14}},
	{"id":"mimic_key","name":"미믹의 황동열쇠","category":"열쇠","tags":["기계","마법","고대"],"base_value":11000,"rarity_weights":{"일반":0.22,"고급":0.44,"희귀":0.26,"영웅":0.08},"state_weights":{"진품":0.64,"모조품":0.20,"결함품":0.16}},
	{"id":"mermaid_pearl","name":"심해 인어의 진주","category":"보석","tags":["수집","바다","마법"],"base_value":30000,"rarity_weights":{"고급":0.18,"희귀":0.37,"영웅":0.30,"전설":0.15},"state_weights":{"진품":0.45,"모조품":0.42,"결함품":0.13}},
	{"id":"frost_vial","name":"빙결 정수 병","category":"연금재료","tags":["재료","연금","마법"],"base_value":14000,"rarity_weights":{"일반":0.12,"고급":0.43,"희귀":0.32,"영웅":0.13},"state_weights":{"진품":0.66,"모조품":0.12,"결함품":0.22}}
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
const PROFESSIONAL_APPRAISAL_COST = 300

const INVESTIGATION_ACTIONS = [
	{"id":"exterior","label":"외형 자세히 보기"},
	{"id":"mark","label":"각인 / 제작자 표시 확인"},
	{"id":"function","label":"작동 / 반응 상태 확인"},
	{"id":"origin","label":"판매자에게 출처 묻기"},
	{"id":"market","label":"동종품 시세 조사"}
]


# v0.2.12 Item-Specific Investigation
# Stable IDs preserve older saves, while each item exposes different player-facing
# investigation points and can map those actions to different clue slots.
const ITEM_INVESTIGATION_PROFILES := {
	"moon_ring": [
		{"id":"exterior","short_label":"보석 결","label":"보석 안쪽 결을 빛에 비춰 본다","clue_slot":0},
		{"id":"mark","short_label":"안쪽 각인","label":"반지 안쪽의 제작 각인을 확인한다","clue_slot":1},
		{"id":"function","short_label":"마력 맥동","label":"달빛에 비춰 마력 맥동을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"전 주인","label":"판매자에게 이전 소유자와 입수 경로를 묻는다","clue_slot":3},
		{"id":"market","short_label":"반지 시세","label":"비슷한 고대 마법 반지의 최근 거래가를 확인한다","market":true}
	],
	"dragon_tooth": [
		{"id":"exterior","short_label":"성장결","label":"표면의 성장결과 자연 마모를 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"뿌리 단면","label":"뿌리 쪽 절단면과 층을 확인한다","clue_slot":1},
		{"id":"function","short_label":"밀도·무게","label":"들어 보며 밀도와 무게 균형을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"채취 경로","label":"판매자에게 어디서 채취된 이빨인지 묻는다","clue_slot":3},
		{"id":"market","short_label":"용재료 시세","label":"용 계열 연금 재료의 최근 거래가를 확인한다","market":true}
	],
	"cursed_mirror": [
		{"id":"exterior","short_label":"은막 균열","label":"거울 은막과 가장자리 균열을 비스듬히 본다","clue_slot":0},
		{"id":"mark","short_label":"뒷면 문양","label":"뒷판의 문양과 제작 흔적을 확인한다","clue_slot":1},
		{"id":"function","short_label":"반사 반응","label":"얼굴과 촛불을 비춰 반사 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"소유 이력","label":"판매자에게 이전 소유자와 사고 이력을 묻는다","clue_slot":3},
		{"id":"market","short_label":"저주유물 시세","label":"비슷한 저주 유물의 거래 범위를 확인한다","market":true}
	],
	"soul_lantern": [
		{"id":"exterior","short_label":"유리 그을음","label":"유리 안쪽의 그을음과 사용 흔적을 본다","clue_slot":0},
		{"id":"mark","short_label":"프레임 각인","label":"금속 프레임과 바닥의 제작 각인을 확인한다","clue_slot":1},
		{"id":"function","short_label":"심지 반응","label":"심지에 약한 마력을 대어 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"사용 이력","label":"판매자에게 어디에서 쓰이던 랜턴인지 묻는다","clue_slot":3},
		{"id":"market","short_label":"영혼도구 시세","label":"영혼 계열 마도구의 최근 거래가를 확인한다","market":true}
	],
	"witch_thimble": [
		{"id":"exterior","short_label":"바늘 자국","label":"표면의 바늘 자국과 마모 방향을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"안쪽 표식","label":"골무 안쪽의 공방 표식과 마감을 확인한다","clue_slot":1},
		{"id":"function","short_label":"마력 잔향","label":"손가락에 끼워 남은 마력 잔향을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"공방 출처","label":"판매자에게 어느 마녀 공방 물건인지 묻는다","clue_slot":3},
		{"id":"market","short_label":"골무 시세","label":"마녀 공예품과 은골무의 최근 거래가를 확인한다","market":true}
	],
	"goblin_watch": [
		{"id":"exterior","short_label":"케이스 마모","label":"케이스의 찍힘과 손때 방향을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"무브먼트 각인","label":"뒷뚜껑을 열어 내부 각인과 부품 표식을 본다","clue_slot":1},
		{"id":"function","short_label":"태엽 작동","label":"태엽을 감아 초침과 톱니 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"수리 이력","label":"판매자에게 수리·부품 교체 이력을 묻는다","clue_slot":3},
		{"id":"market","short_label":"시계 시세","label":"고블린 기계식 회중시계의 거래가를 확인한다","market":true}
	],
	"bone_flute": [
		{"id":"exterior","short_label":"골질 표면","label":"뼈 표면의 결, 균열, 마모를 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"마디 각인","label":"마디와 취구 주변의 새김 흔적을 확인한다","clue_slot":1},
		{"id":"function","short_label":"음정·공명","label":"짧게 불어 음정과 공명이 끊기는지 확인한다","clue_slot":2},
		{"id":"origin","short_label":"연주자 출처","label":"판매자에게 이전 연주자와 입수 경로를 묻는다","clue_slot":3},
		{"id":"market","short_label":"저주악기 시세","label":"저주 계열 악기와 뼈피리의 최근 거래가를 확인한다","market":true}
	],
	"meteor_coin": [
		{"id":"exterior","short_label":"테두리 마모","label":"동전 테두리의 마모와 충격 흔적을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"주조 문양","label":"앞뒷면 문양의 깊이와 주조 흔적을 확인한다","clue_slot":1},
		{"id":"function","short_label":"자성·밀도","label":"자석 반응과 손에 느껴지는 밀도를 확인한다","clue_slot":2},
		{"id":"origin","short_label":"발견 경로","label":"판매자에게 운석과 함께 발견된 물건인지 묻는다","clue_slot":3},
		{"id":"market","short_label":"운석동전 시세","label":"운석 금속 수집품의 최근 거래가를 확인한다","market":true}
	],
	"phoenix_feather": [
		{"id":"exterior","short_label":"깃결·광택","label":"깃가지의 결, 색 변화, 자연 광택을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"깃대 단면","label":"깃대 단면의 층과 인공 접합 흔적을 확인한다","clue_slot":1},
		{"id":"function","short_label":"열 반응","label":"약한 열을 가까이 대어 색과 마력 반응을 본다","clue_slot":2},
		{"id":"origin","short_label":"채집 경로","label":"판매자에게 어디에서 얻은 깃털인지 묻는다","clue_slot":3},
		{"id":"market","short_label":"연금재료 시세","label":"희귀 연금 재료와 불사조 깃털 거래가를 확인한다","market":true}
	],
	"mimic_key": [
		{"id":"exterior","short_label":"톱니 마모","label":"열쇠 톱니의 마모와 사용 방향을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"손잡이 각인","label":"황동 손잡이의 각인과 접합부를 확인한다","clue_slot":1},
		{"id":"function","short_label":"잠금 반응","label":"시험 자물쇠에 넣어 걸림과 마력 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"획득 경로","label":"판매자에게 미믹과 관련된 입수 경로를 묻는다","clue_slot":3},
		{"id":"market","short_label":"고대열쇠 시세","label":"고대·마법 열쇠류의 최근 거래가를 확인한다","market":true}
	],
	"mermaid_pearl": [
		{"id":"exterior","short_label":"표면 결","label":"진주층의 결, 광택, 작은 흠을 빛에 비춰 본다","clue_slot":0},
		{"id":"mark","short_label":"천공 흔적","label":"구멍과 밑면의 가공 흔적을 확대해 본다","clue_slot":1},
		{"id":"function","short_label":"수분·마력","label":"물방울을 대어 색과 마력 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"채취 해역","label":"판매자에게 어느 해역에서 나온 진주인지 묻는다","clue_slot":3},
		{"id":"market","short_label":"진주 시세","label":"심해 진주와 마법 보석의 최근 거래가를 확인한다","market":true}
	],
	"frost_vial": [
		{"id":"exterior","short_label":"병목 봉인","label":"병목의 봉인 상태와 서리 자국을 살펴본다","clue_slot":0},
		{"id":"mark","short_label":"바닥 표식","label":"병 바닥의 제조 표식과 유리 가공을 확인한다","clue_slot":1},
		{"id":"function","short_label":"냉기 반응","label":"병을 기울여 냉기와 내용물 반응을 확인한다","clue_slot":2},
		{"id":"origin","short_label":"제조 경로","label":"판매자에게 제조자와 보관 경로를 묻는다","clue_slot":3},
		{"id":"market","short_label":"정수 시세","label":"빙결 정수와 연금 용액의 최근 거래가를 확인한다","market":true}
	]
}

const POST_INSPECTIONS = [
	{"id":"material","label":"재질 검사","cost":120},
	{"id":"magic","label":"마력 / 반응 검사","cost":160},
	{"id":"internal","label":"내부 구조 확인","cost":200}
]
