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
	{"id":"moon_ring","name":"달빛 속삭임 반지","category":"장신구","tags":["마법","수집","고대"],"base_value":24000,"rarity_weights":{"고급":0.25,"희귀":0.34,"영웅":0.26,"전설":0.15},"state_weights":{"진품":0.58,"모조품":0.25,"결함품":0.17},"investigation_profile":"ornament_magic","investigation_overrides":{"exterior":{"short_label":"보석 결","label":"보석 안쪽 결을 빛에 비춰 본다"},"mark":{"short_label":"안쪽 각인","label":"반지 안쪽의 제작 각인을 확인한다"},"function":{"short_label":"마력 맥동","label":"달빛에 비춰 마력 맥동을 확인한다"},"market":{"short_label":"반지 시세","label":"비슷한 고대 마법 반지의 최근 거래가를 확인한다"}},"market_stories":["이사하다 서랍 깊숙한 곳에서 나왔어요. 저는 반지를 안 껴서 올립니다.","전 주인이 두고 간 상자에 있던 건데 정확히 뭔지는 저도 잘 몰라요.","밤에 책상 위에 두면 유난히 차가워지는 느낌이 있어서 그냥 정리하려고요."]},
	{"id":"dragon_tooth","name":"용의 이빨","category":"재료","tags":["재료","용","연금"],"base_value":19000,"rarity_weights":{"일반":0.18,"고급":0.34,"희귀":0.31,"영웅":0.17},"state_weights":{"진품":0.50,"모조품":0.32,"결함품":0.18},"investigation_profile":"organic_material","investigation_overrides":{"exterior":{"short_label":"성장결","label":"표면의 성장결과 자연 마모를 살펴본다"},"mark":{"short_label":"뿌리 단면","label":"뿌리 쪽 절단면과 층을 확인한다"},"function":{"short_label":"밀도·무게","label":"들어 보며 밀도와 무게 균형을 확인한다"},"origin":{"short_label":"채취 경로","label":"판매자에게 어디서 채취된 이빨인지 묻는다"}},"market_stories":["사냥꾼한테 물건값 대신 받은 건데 집에 둘 데가 없어서 내놓습니다.","창고 정리하다 다시 나온 거예요. 크기는 손바닥보다 조금 큽니다.","연금술 하시는 분이면 저보다 쓸모를 더 잘 아실 것 같아요."]},
	{"id":"cursed_mirror","name":"저주받은 손거울","category":"유물","tags":["저주","고대","수집"],"base_value":16000,"rarity_weights":{"고급":0.42,"희귀":0.34,"영웅":0.18,"전설":0.06},"state_weights":{"진품":0.54,"모조품":0.18,"결함품":0.28},"investigation_profile":"enchanted_relic","investigation_overrides":{"exterior":{"short_label":"은막 균열","label":"거울 은막과 가장자리 균열을 비스듬히 본다"},"mark":{"short_label":"뒷면 문양","label":"뒷판의 문양과 제작 흔적을 확인한다"},"function":{"short_label":"반사 반응","label":"얼굴과 촛불을 비춰 반사 반응을 확인한다"},"market":{"short_label":"저주유물 시세","label":"비슷한 저주 유물의 거래 범위를 확인한다"}},"unique_clues":[{"id":"mirror_u1","kind":"애매한","signal":"neutral","text":"거울을 기울일 때 아주 잠깐 뒤쪽 풍경이 늦게 따라온다.","reveal":"미세한 반사 지연은 저주 잔향이었지만 진위 자체를 확정하는 신호는 아니었다."}],"market_stories":["오래된 집에서 가져온 손거울이에요. 밤에는 천을 덮어두고 있었습니다.","장식용으로 샀는데 방에 두고 나서 계속 신경 쓰여서 정리해요.","거울 뒷면 문양이 예뻐서 갖고 있었는데 저는 이제 필요 없습니다."]},
	{"id":"soul_lantern","name":"영혼의 랜턴","category":"마도구","tags":["마법","영혼","고대"],"base_value":27000,"rarity_weights":{"고급":0.20,"희귀":0.42,"영웅":0.28,"전설":0.10},"state_weights":{"진품":0.62,"모조품":0.14,"결함품":0.24},"investigation_profile":"enchanted_relic","investigation_overrides":{"exterior":{"short_label":"유리 그을음","label":"유리 안쪽의 그을음과 사용 흔적을 본다"},"mark":{"short_label":"프레임 각인","label":"금속 프레임과 바닥의 제작 각인을 확인한다"},"function":{"short_label":"심지 반응","label":"심지에 약한 마력을 대어 반응을 확인한다"},"origin":{"short_label":"사용 이력","label":"판매자에게 어디에서 쓰이던 랜턴인지 묻는다"}},"market_stories":["창고에 오래 걸려 있던 랜턴이에요. 불 대신 다른 식으로 켜진다는 얘기는 들었습니다.","가족 물건 정리 중입니다. 이 랜턴은 제가 쓰는 법을 몰라서 내놓아요.","밤에만 거래 가능합니다. 들고 갈 때는 유리 부분 조심해주세요."]},
	{"id":"witch_thimble","name":"마녀의 은골무","category":"잡화","tags":["마법","공예","수집"],"base_value":9000,"rarity_weights":{"일반":0.24,"고급":0.42,"희귀":0.26,"영웅":0.08},"state_weights":{"진품":0.56,"모조품":0.28,"결함품":0.16},"investigation_profile":"crafted_magic","investigation_overrides":{"exterior":{"short_label":"바늘 자국","label":"표면의 바늘 자국과 마모 방향을 살펴본다"},"mark":{"short_label":"안쪽 표식","label":"골무 안쪽의 공방 표식과 마감을 확인한다"}},"market_stories":["예전에 공방에서 같이 일하던 분이 두고 간 골무예요. 저는 사이즈가 안 맞습니다.","바느질 상자 정리하다 나왔어요. 오래됐지만 손에 닿는 느낌은 괜찮습니다.","공방 물건 좋아하시는 분이 가져가면 좋겠어요."]},
	{"id":"goblin_watch","name":"고블린 회중시계","category":"장신구","tags":["기계","고대","수집"],"base_value":15000,"rarity_weights":{"일반":0.12,"고급":0.40,"희귀":0.35,"영웅":0.13},"state_weights":{"진품":0.57,"모조품":0.27,"결함품":0.16},"investigation_profile":"mechanical","investigation_overrides":{"mark":{"short_label":"무브먼트 각인","label":"뒷뚜껑을 열어 내부 각인과 부품 표식을 본다"},"function":{"short_label":"태엽 작동","label":"태엽을 감아 초침과 톱니 반응을 확인한다"},"market":{"short_label":"시계 시세","label":"고블린 기계식 회중시계의 거래가를 확인한다"}},"unique_clues":[{"id":"watch_u1","kind":"부정적","signal":"defect","text":"태엽을 감을 때 한 구간에서 미세하게 톱니가 튄다.","reveal":"내부 기어 하나가 마모되어 실제 수리 비용이 발생하는 결함이었다."}],"market_stories":["몇 년 전 고물 더미에서 건진 회중시계예요. 태엽은 아직 돌아갑니다.","수리하려고 모아뒀는데 다른 일이 많아서 그냥 내놓습니다.","겉은 낡았는데 안쪽 톱니 보는 맛이 있어서 한동안 가지고 있었어요."]},
	{"id":"bone_flute","name":"망자의 뼈피리","category":"악기","tags":["저주","음악","수집"],"base_value":12500,"rarity_weights":{"일반":0.16,"고급":0.42,"희귀":0.31,"영웅":0.11},"state_weights":{"진품":0.52,"모조품":0.22,"결함품":0.26},"investigation_profile":"organic_instrument","investigation_overrides":{"exterior":{"short_label":"골질 표면","label":"뼈 표면의 결, 균열, 마모를 살펴본다"},"mark":{"short_label":"마디 각인","label":"마디와 취구 주변의 새김 흔적을 확인한다"}},"market_stories":["공연 짐 정리하면서 내놓습니다. 저는 이 피리는 더 이상 안 불어요.","전에 같이 연주하던 친구 물건이었는데 주인을 찾지 못해서 올립니다.","소리는 나는데 밤에 불면 이웃들이 싫어해서 정리해요."]},
	{"id":"meteor_coin","name":"운석 동전","category":"수집품","tags":["수집","별","고대"],"base_value":21500,"rarity_weights":{"고급":0.22,"희귀":0.40,"영웅":0.27,"전설":0.11},"state_weights":{"진품":0.60,"모조품":0.29,"결함품":0.11},"investigation_profile":"collectible","investigation_overrides":{"exterior":{"short_label":"테두리 마모","label":"동전 테두리의 마모와 충격 흔적을 살펴본다"},"function":{"short_label":"자성·밀도","label":"자석 반응과 손에 느껴지는 밀도를 확인한다"},"market":{"short_label":"운석동전 시세","label":"운석 금속 수집품의 최근 거래가를 확인한다"}},"market_stories":["여행 다녀온 상인이랑 물물교환으로 받은 동전입니다. 저는 수집을 안 해요.","서랍에 몇 년 있었는데 쓸 일도 없고 정확한 출처도 기억이 흐릿합니다.","별무늬가 특이해서 갖고 있었어요. 수집하시는 분께 넘기고 싶습니다."]},
	{"id":"phoenix_feather","name":"불사조 깃털","category":"재료","tags":["재료","마법","연금"],"base_value":23500,"rarity_weights":{"고급":0.20,"희귀":0.38,"영웅":0.31,"전설":0.11},"state_weights":{"진품":0.47,"모조품":0.39,"결함품":0.14},"investigation_profile":"organic_material","investigation_overrides":{"exterior":{"short_label":"깃결·광택","label":"깃가지의 결, 색 변화, 자연 광택을 살펴본다"},"mark":{"short_label":"깃대 단면","label":"깃대 단면의 층과 인공 접합 흔적을 확인한다"},"function":{"short_label":"열 반응","label":"약한 열을 가까이 대어 색과 마력 반응을 본다"},"market":{"short_label":"연금재료 시세","label":"희귀 연금 재료와 불사조 깃털 거래가를 확인한다"}},"unique_clues":[{"id":"phoenix_u1","kind":"긍정적","signal":"genuine","text":"열을 가까이 대자 깃가지 끝의 빛이 사라지지 않고 안쪽으로 번진다.","reveal":"불꽃을 흉내 낸 염색이 아니라 실제 불사조 깃털의 열 반응이었다."}],"market_stories":["연금 재료 꾸러미에 섞여 들어왔는데 제가 쓸 조합식이 없어서 팝니다.","불 가까이에 둬도 색이 잘 안 변해서 신기해서 보관하던 깃털이에요.","재료상한테 받은 건데 저는 취급하기가 조금 부담스러워서 정리합니다."]},
	{"id":"mimic_key","name":"미믹의 황동열쇠","category":"열쇠","tags":["기계","마법","고대"],"base_value":11000,"rarity_weights":{"일반":0.22,"고급":0.44,"희귀":0.26,"영웅":0.08},"state_weights":{"진품":0.64,"모조품":0.20,"결함품":0.16},"investigation_profile":"mechanical","investigation_overrides":{"exterior":{"short_label":"톱니 마모","label":"열쇠 톱니의 마모와 사용 방향을 살펴본다"},"mark":{"short_label":"손잡이 각인","label":"황동 손잡이의 각인과 접합부를 확인한다"},"function":{"short_label":"잠금 반응","label":"시험 자물쇠에 넣어 걸림과 마력 반응을 확인한다"},"origin":{"short_label":"획득 경로","label":"판매자에게 미믹과 관련된 입수 경로를 묻는다"},"market":{"short_label":"고대열쇠 시세","label":"고대·마법 열쇠류의 최근 거래가를 확인한다"}},"market_stories":["열리는 문은 못 찾았고 서랍에만 굴러다녀서 내놓습니다.","미믹 잡고 나온 거라고 들었는데 저는 직접 본 건 아닙니다.","시험 삼아 자물쇠 몇 개에 넣어봤는데 맞는 건 없었어요."]},
	{"id":"mermaid_pearl","name":"심해 인어의 진주","category":"보석","tags":["수집","바다","마법"],"base_value":30000,"rarity_weights":{"고급":0.18,"희귀":0.37,"영웅":0.30,"전설":0.15},"state_weights":{"진품":0.45,"모조품":0.42,"결함품":0.13},"investigation_profile":"ornament_magic","investigation_overrides":{"exterior":{"short_label":"표면 결","label":"진주층의 결, 광택, 작은 흠을 빛에 비춰 본다"},"mark":{"short_label":"천공 흔적","label":"구멍과 밑면의 가공 흔적을 확대해 본다"},"function":{"short_label":"수분·마력","label":"물방울을 대어 색과 마력 반응을 확인한다"},"origin":{"short_label":"채취 해역","label":"판매자에게 어느 해역에서 나온 진주인지 묻는다"},"market":{"short_label":"진주 시세","label":"심해 진주와 마법 보석의 최근 거래가를 확인한다"}},"market_stories":["바닷가 상인에게 받아온 진주예요. 생각보다 커서 장신구로 쓰진 못했습니다.","물에 담가두라고 해서 그렇게 보관했는데 이제 관리가 귀찮아서 팔아요.","선물로 받았는데 제 취향이 아니라서 내놓습니다. 빛은 꽤 예뻐요."]},
	{"id":"frost_vial","name":"빙결 정수 병","category":"연금재료","tags":["재료","연금","마법"],"base_value":14000,"rarity_weights":{"일반":0.12,"고급":0.43,"희귀":0.32,"영웅":0.13},"state_weights":{"진품":0.66,"모조품":0.12,"결함품":0.22},"investigation_profile":"arcane_container","investigation_overrides":{"exterior":{"short_label":"병목 봉인","label":"병목의 봉인 상태와 서리 자국을 살펴본다"},"mark":{"short_label":"바닥 표식","label":"병 바닥의 제조 표식과 유리 가공을 확인한다"},"function":{"short_label":"냉기 반응","label":"병을 기울여 냉기와 내용물 반응을 확인한다"},"market":{"short_label":"정수 시세","label":"빙결 정수와 연금 용액의 최근 거래가를 확인한다"}},"market_stories":["연금 선반 정리 중입니다. 차갑게 보관하라고 해서 계속 그렇게 뒀어요.","제가 쓰는 조합에는 안 맞아서 필요한 분께 넘기려고 합니다.","병을 오래 들고 있으면 손이 시려서 저는 그냥 처분하려고요."]},
	{"id":"echo_compass","name":"메아리 나침반","category":"마도구","tags":["마법","기계","별"],"base_value":18000,"rarity_weights":{"일반":0.10,"고급":0.42,"희귀":0.34,"영웅":0.14},"state_weights":{"진품":0.55,"모조품":0.28,"결함품":0.17},"investigation_profile":"mechanical","investigation_overrides":{"exterior":{"short_label":"바늘 마모","label":"나침반 바늘과 유리 테두리의 마모를 본다"},"mark":{"short_label":"후면 좌표","label":"뒷면에 새겨진 좌표와 공방 표식을 확인한다"},"function":{"short_label":"방향 반응","label":"천천히 돌려 바늘이 북쪽이 아닌 곳에 반응하는지 본다"},"market":{"short_label":"마도 나침반 시세","label":"탐사 마도구와 고대 나침반 거래가를 확인한다"}},"market_stories":["길 찾는 데 쓰는 물건인 줄 알았는데 자꾸 엉뚱한 벽만 가리켜서 팝니다.","탑 아래 노점에서 샀어요. 밤마다 바늘이 같은 방향으로 돌아갑니다.","여행 짐을 줄이는 중입니다. 작동법 아시는 분이 가져가면 좋겠어요."]},
	{"id":"bottled_shadow","name":"병에 든 그림자","category":"연금재료","tags":["저주","영혼","연금"],"base_value":16500,"rarity_weights":{"일반":0.14,"고급":0.38,"희귀":0.33,"영웅":0.15},"state_weights":{"진품":0.49,"모조품":0.31,"결함품":0.20},"investigation_profile":"arcane_container","investigation_overrides":{"exterior":{"short_label":"검은 막","label":"병 안쪽 검은 막과 봉인 실의 상태를 본다"},"mark":{"short_label":"봉인 문자","label":"마개와 병목에 남은 봉인 문자를 확인한다"},"function":{"short_label":"그림자 반응","label":"빛을 비춰 내용물의 그림자가 어느 방향으로 움직이는지 본다"},"origin":{"short_label":"봉인 경로","label":"판매자에게 누가 언제 봉인한 병인지 묻는다"}},"market_stories":["선반 뒤에 두면 주변이 괜히 어두워져서 더는 보관하고 싶지 않아요.","연금 재료 묶음에 들어 있었는데 저는 봉인을 열 생각이 없습니다.","빛에 비추면 안쪽이 움직이는 것 같아요. 가져가실 분은 조심해주세요."]},
	{"id":"watching_brooch","name":"눈알 브로치","category":"장신구","tags":["수집","마법","저주"],"base_value":22000,"rarity_weights":{"고급":0.30,"희귀":0.38,"영웅":0.23,"전설":0.09},"state_weights":{"진품":0.46,"모조품":0.40,"결함품":0.14},"investigation_profile":"ornament_magic","investigation_overrides":{"exterior":{"short_label":"홍채 결","label":"보석 홍채처럼 보이는 부분의 결을 확대해 본다"},"mark":{"short_label":"핀 뒷면","label":"브로치 핀과 뒷판의 제작 표식을 확인한다"},"function":{"short_label":"시선 반응","label":"각도를 바꿨을 때 눈동자처럼 보이는 무늬가 따라오는지 본다"}},"market_stories":["옷에 달면 자꾸 누가 보는 느낌이 들어서 한 번도 밖에 차고 나간 적은 없어요.","수집상자에서 나온 브로치입니다. 가운데 보석이 좀 특이해요.","선물 받았는데 취향이 아니라 올립니다. 사진보다 실제로 보면 더 이상합니다."]},
	{"id":"moon_moth_case","name":"달나방 표본함","category":"수집품","tags":["수집","마법","별"],"base_value":13000,"rarity_weights":{"일반":0.18,"고급":0.43,"희귀":0.29,"영웅":0.10},"state_weights":{"진품":0.61,"모조품":0.23,"결함품":0.16},"investigation_profile":"collectible","investigation_overrides":{"exterior":{"short_label":"날개 인분","label":"나방 날개의 인분과 색 변화가 자연스러운지 본다"},"mark":{"short_label":"표본 라벨","label":"표본함 뒤 라벨의 연대와 채집 표식을 확인한다"},"function":{"short_label":"달빛 반응","label":"약한 달빛 마법에 날개 무늬가 반응하는지 확인한다"}},"market_stories":["벽에 걸어뒀는데 밤마다 색이 달라 보여서 정리하려고 합니다.","예전 박물상에게 산 표본함입니다. 라벨은 오래돼 보여요.","곤충 수집을 접어서 내놓습니다. 유리는 금 간 곳 없습니다."]},
	{"id":"drowned_bell","name":"물에 잠긴 은종","category":"악기","tags":["바다","저주","음악"],"base_value":19500,"rarity_weights":{"고급":0.34,"희귀":0.38,"영웅":0.20,"전설":0.08},"state_weights":{"진품":0.51,"모조품":0.21,"결함품":0.28},"investigation_profile":"crafted_magic","investigation_overrides":{"exterior":{"short_label":"염분 흔적","label":"은 표면의 부식과 오래된 염분 흔적을 확인한다"},"mark":{"short_label":"손잡이 문양","label":"손잡이 아래 새겨진 항구 문양을 본다"},"function":{"short_label":"종소리 공명","label":"가볍게 흔들어 소리와 물기 없는 공명이 자연스러운지 듣는다"},"origin":{"short_label":"인양 장소","label":"판매자에게 어느 바다에서 건져 올린 종인지 묻는다"}},"market_stories":["부두 창고 바닥에서 나왔어요. 닦아도 바닷물 냄새가 없어지질 않네요.","배에서 쓰던 종이라고 들었는데 저는 자세한 건 모릅니다.","소리가 너무 멀리 울리는 느낌이라 집에서는 못 쓰겠어요."]},
	{"id":"rune_glove","name":"룬 재봉사의 장갑","category":"잡화","tags":["마법","공예","고대"],"base_value":14500,"rarity_weights":{"일반":0.14,"고급":0.45,"희귀":0.31,"영웅":0.10},"state_weights":{"진품":0.59,"모조품":0.25,"결함품":0.16},"investigation_profile":"crafted_magic","investigation_overrides":{"exterior":{"short_label":"손바닥 마모","label":"손바닥의 닳은 방향과 실밥 상태를 확인한다"},"mark":{"short_label":"소매 룬","label":"소매 안쪽 자수 룬과 공방 표식을 본다"},"function":{"short_label":"실 반응","label":"실과 바늘을 가까이 뒀을 때 장갑의 마력 잔향을 확인한다"}},"market_stories":["공방 정리하면서 나왔습니다. 제 손에는 작아서 쓰지 못해요.","바느질할 때 실이 덜 꼬인다는 장갑인데 저는 그냥 장식으로만 뒀어요.","오래된 재봉함 안에 있던 겁니다. 한 짝이 아니라 양쪽 다 있어요."]},
	{"id":"basilisk_scale","name":"바실리스크 비늘","category":"재료","tags":["재료","연금","고대"],"base_value":26000,"rarity_weights":{"고급":0.22,"희귀":0.39,"영웅":0.27,"전설":0.12},"state_weights":{"진품":0.48,"모조품":0.38,"결함품":0.14},"investigation_profile":"organic_material","investigation_overrides":{"exterior":{"short_label":"겹층 무늬","label":"비늘의 겹층과 성장 무늬를 빛에 비춰 본다"},"mark":{"short_label":"뿌리 단면","label":"비늘 뿌리 쪽 단면이 자연 조직인지 확인한다"},"function":{"short_label":"석화 반응","label":"약한 연금 시약에 표면이 굳어지는 반응이 있는지 본다"}},"market_stories":["사냥꾼한테 빚 대신 받은 비늘입니다. 진짜인지는 직접 보셔야 해요.","연금용으로 모아뒀는데 필요한 양보다 하나 남아서 팝니다.","표면이 돌처럼 단단합니다. 보관은 마른 천에 싸서 했어요."]},
	{"id":"clockwork_beetle","name":"태엽 딱정벌레","category":"마도구","tags":["기계","수집","마법"],"base_value":20000,"rarity_weights":{"일반":0.12,"고급":0.39,"희귀":0.35,"영웅":0.14},"state_weights":{"진품":0.57,"모조품":0.24,"결함품":0.19},"investigation_profile":"mechanical","investigation_overrides":{"exterior":{"short_label":"날개 경첩","label":"금속 날개와 다리 관절의 마모를 확인한다"},"mark":{"short_label":"복부 각인","label":"복부 덮개 안쪽의 제작번호를 확인한다"},"function":{"short_label":"보행 작동","label":"태엽을 감아 걷는 방향과 반복 동작을 확인한다"}},"market_stories":["태엽을 감으면 책상 위를 계속 돌아다녀서 고양이가 싫어합니다.","기계 수집을 줄이는 중입니다. 작은데 내부 부품은 꽤 정교해요.","고철 상자에서 찾았는데 아직 움직입니다. 수리한 적은 없습니다."]},
	{"id":"grave_candle","name":"묘지의 푸른 초","category":"마도구","tags":["저주","영혼","마법"],"base_value":10500,"rarity_weights":{"일반":0.20,"고급":0.43,"희귀":0.28,"영웅":0.09},"state_weights":{"진품":0.62,"모조품":0.17,"결함품":0.21},"investigation_profile":"enchanted_relic","investigation_overrides":{"exterior":{"short_label":"왁스 층","label":"촛농의 층과 심지 주변 사용 흔적을 본다"},"mark":{"short_label":"밑면 문양","label":"초 밑면의 눌린 문양과 봉인 표시를 확인한다"},"function":{"short_label":"불꽃 반응","label":"불을 붙였을 때 색과 그림자 움직임을 확인한다"}},"market_stories":["묘지 행사 끝나고 남은 초라고 들었습니다. 저는 불을 붙여보진 않았어요.","불을 끈 뒤에도 심지가 한참 푸르게 보여서 그냥 내놓습니다.","상자째 받았는데 한 개만 남았어요. 필요한 분 가져가세요."]},
	{"id":"star_map_fragment","name":"별자리 지도 조각","category":"유물","tags":["별","고대","수집"],"base_value":28000,"rarity_weights":{"고급":0.18,"희귀":0.38,"영웅":0.30,"전설":0.14},"state_weights":{"진품":0.50,"모조품":0.36,"결함품":0.14},"investigation_profile":"collectible","investigation_overrides":{"exterior":{"short_label":"양피지 결","label":"찢어진 가장자리와 양피지 섬유의 노화를 확인한다"},"mark":{"short_label":"별자리 잉크","label":"별점 잉크와 좌표 기호의 층을 확대해 본다"},"function":{"short_label":"별빛 반응","label":"밤빛을 비췄을 때 사라진 선이 드러나는지 본다"},"origin":{"short_label":"탑 기록","label":"판매자에게 어느 탑 기록에서 나온 조각인지 묻는다"}},"market_stories":["책 사이에서 나온 지도 조각입니다. 전체 지도가 어디 있는지는 몰라요.","탑 창고 폐기물에서 건졌다는 걸 샀는데 저는 해독을 못 합니다.","별자리 좋아하시는 분이면 알아볼 것 같아서 올려요."]},
	{"id":"sea_witch_comb","name":"해마녀의 산호빗","category":"장신구","tags":["바다","마법","수집"],"base_value":17500,"rarity_weights":{"일반":0.10,"고급":0.40,"희귀":0.35,"영웅":0.15},"state_weights":{"진품":0.53,"모조품":0.34,"결함품":0.13},"investigation_profile":"ornament_magic","investigation_overrides":{"exterior":{"short_label":"산호 결","label":"빗살과 산호 장식의 자연 결을 확인한다"},"mark":{"short_label":"손잡이 표식","label":"손잡이 뒷면의 조개 문양과 제작 흔적을 본다"},"function":{"short_label":"수분 반응","label":"물방울을 묻혔을 때 색과 마력 반응이 변하는지 본다"}},"market_stories":["바닷가 시장에서 샀는데 제 머리에는 너무 커서 장식으로만 뒀어요.","물에 닿으면 색이 선명해지는 빗입니다. 저는 관리가 귀찮네요.","산호 장식이 예뻐서 샀는데 요즘은 수집을 줄이고 있습니다."]},
	{"id":"alchemist_spoon","name":"연금술사의 계량숟가락","category":"잡화","tags":["연금","공예","재료"],"base_value":8000,"rarity_weights":{"일반":0.27,"고급":0.45,"희귀":0.22,"영웅":0.06},"state_weights":{"진품":0.67,"모조품":0.18,"결함품":0.15},"investigation_profile":"crafted_magic","investigation_overrides":{"exterior":{"short_label":"그을음 마모","label":"숟가락 표면의 그을음과 반복 사용 흔적을 확인한다"},"mark":{"short_label":"눈금 각인","label":"손잡이 눈금과 공방 각인의 깊이를 확인한다"},"function":{"short_label":"계량 반응","label":"가루를 올렸을 때 눈금 룬이 반응하는지 확인한다"}},"market_stories":["연금 도구 정리 중입니다. 같은 크기가 여러 개라 하나 내놓아요.","손잡이에 눈금이 있는데 저는 그냥 일반 숟가락처럼 썼습니다.","공방 폐업 정리에서 받아온 겁니다. 약간 그을렸지만 휘진 않았어요."]}
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
	{"id":"blue","name":"별빛 상인 블루","type":"expert","neighborhood":"별빛탑 아래","meetup":"별빛탑 남쪽 계단","profile":"탑에서 나온 잡동사니와 오래된 도구를 가끔 정리해요."},
	{"id":"krok","name":"비늘장수 크록","type":"greedy","neighborhood":"비늘골목","meetup":"비늘골목 우물 앞","profile":"창고가 좁아서 오래된 물건을 하나씩 내놓는 중입니다."},
	{"id":"morna","name":"유령 모르나","type":"urgent","neighborhood":"묘지길","meetup":"묘지길 가로등 아래","profile":"낮에는 잘 없어요. 해 진 뒤 직거래가 편합니다."},
	{"id":"myomyo","name":"야시장지기 묘묘","type":"expert","neighborhood":"야시장 북문","meetup":"야시장 북문 등불 아래","profile":"야시장 안에서만 거래합니다. 물건 상태는 직접 보고 결정하세요."},
	{"id":"pipi","name":"바느질 마녀 피피","type":"naive","neighborhood":"재봉골목","meetup":"재봉골목 빨간 천막 앞","profile":"공방 정리하면서 작은 물건들을 종종 올리고 있어요."},
	{"id":"grizzle","name":"고철상 그리즐","type":"greedy","neighborhood":"고철부두","meetup":"고철부두 3번 크레인 앞","profile":"부품, 기계, 오래된 금속 물건이 많습니다. 현장에서 확인 가능."},
	{"id":"toto","name":"해골 악사 토토","type":"bluffer","neighborhood":"뼈다리 광장","meetup":"뼈다리 광장 작은 무대 옆","profile":"공연 끝나고 거래 가능해요. 악기나 기묘한 수집품도 가끔 올립니다."},
	{"id":"rook","name":"까마귀 루크","type":"urgent","neighborhood":"종탑 뒤편","meetup":"종탑 뒤 우편함 앞","profile":"오래 약속 잡는 건 싫어합니다. 가능하면 오늘 바로 거래해요."}
]

const SELLER_RELATIONSHIP_THRESHOLDS := [
	{"points":0,"name":"낯선 사이"},
	{"points":4,"name":"얼굴 익힘"},
	{"points":12,"name":"신뢰"},
	{"points":24,"name":"단골"}
]

const SELLER_STORIES := {
	"blue":{
		"title":"탑에서 사라진 감정표",
		"signature_item":"moon_ring",
		"special_post":"탑 창고 정리 중에 따로 빼둔 반지입니다. 다른 데 올리기 전에 먼저 보여드려요.",
		"beats":[
			{"threshold":4,"title":"접힌 감정표","message":"전에 거래했던 분이죠. 탑 물건 중엔 감정표가 빠진 것들이 가끔 있어요. 이상해서 따로 보고 있습니다."},
			{"threshold":12,"title":"지워진 서명","message":"감정표가 없어진 게 우연은 아닌 것 같아요. 같은 서명이 지워진 물건이 몇 개 더 나왔습니다."},
			{"threshold":24,"title":"블루가 감춰둔 반지","message":"이제는 말씀드려도 되겠네요. 그 기록과 같이 보관돼 있던 반지가 하나 있습니다. 다른 사람에게 넘기기 전 먼저 보시죠."}
		]
	},
	"krok":{
		"title":"창고를 비워야 하는 이유",
		"signature_item":"dragon_tooth",
		"special_post":"창고 깊숙한 데 있던 물건입니다. 값은 싸게 못 드리지만 단골한테 먼저 보여드리는 거예요.",
		"beats":[
			{"threshold":4,"title":"쌓여가는 상자","message":"또 왔군요. 요즘 창고 물건을 계속 빼고 있습니다. 그냥 공간이 모자라서 그런 건 아닙니다."},
			{"threshold":12,"title":"밀린 창고세","message":"사실 창고 계약이 꼬였습니다. 다음 달까지 일부를 비워야 해서 오래 묵은 물건도 꺼내는 중이죠."},
			{"threshold":24,"title":"마지막 큰 상자","message":"끝까지 남겨두려던 상자가 하나 있습니다. 당신 정도면 헐값부터 부르진 않을 테니 먼저 보여드리죠."}
		]
	},
	"morna":{
		"title":"묘지길의 빈 랜턴",
		"signature_item":"soul_lantern",
		"special_post":"묘지길에서 오래 기다리며 지켜온 랜턴이에요. 이제는 믿을 만한 분께 넘겨도 될 것 같네요.",
		"beats":[
			{"threshold":4,"title":"같은 가로등","message":"또 이 시간에 만났네요. 제가 늘 같은 가로등 아래서 거래하는 게 조금 이상했죠?"},
			{"threshold":12,"title":"기다리는 불빛","message":"예전에 이 길에서 누군가를 기다렸어요. 그 뒤로 불이 켜진 물건은 함부로 버리지 못하게 됐습니다."},
			{"threshold":24,"title":"빈 랜턴의 주인","message":"오래 붙잡고 있던 랜턴을 이제 놓으려고 해요. 다른 손에 가야 불빛도 다시 움직일 것 같아서요."}
		]
	},
	"myomyo":{
		"title":"북문 장부",
		"signature_item":"meteor_coin",
		"special_post":"북문 장부에 오래 표시해 둔 수집품입니다. 시장에 공개하기 전에 먼저 확인해보세요.",
		"beats":[
			{"threshold":4,"title":"사라진 거래 한 줄","message":"전에 본 얼굴이네요. 요즘 북문 장부에서 거래 한 줄이 통째로 사라진 게 신경 쓰입니다."},
			{"threshold":12,"title":"같은 별무늬","message":"지워진 기록마다 같은 별무늬가 남아 있더군요. 누군가 일부러 흔적을 지우는 것 같습니다."},
			{"threshold":24,"title":"장부 끝의 동전","message":"장부 마지막 장 사이에 끼워져 있던 동전을 찾았습니다. 이 일 따라온 분께 먼저 보여드리는 게 맞겠죠."}
		]
	},
	"pipi":{
		"title":"돌아오지 않은 공방 동료",
		"signature_item":"witch_thimble",
		"special_post":"공방 맨 안쪽 상자에서 나온 골무예요. 오래된 사연까지 들어도 괜찮다면 먼저 보여드릴게요.",
		"beats":[
			{"threshold":4,"title":"남겨진 바느질 상자","message":"전에 물건 봐주셨죠? 사실 공방 정리품 중엔 예전 동료가 두고 간 것들이 섞여 있어요."},
			{"threshold":12,"title":"완성되지 않은 옷","message":"그 친구는 마지막 주문을 끝내지 못하고 떠났어요. 그래서 표식이 남은 도구를 계속 찾고 있었답니다."},
			{"threshold":24,"title":"은골무의 주인","message":"찾던 표식이 있는 골무를 결국 발견했어요. 저는 갖고 있기보다 이 사정을 아는 분께 맡기고 싶어요."}
		]
	},
	"grizzle":{
		"title":"3번 크레인의 부품",
		"signature_item":"goblin_watch",
		"special_post":"3번 크레인 밑에서 나온 마지막 기계 부품입니다. 기계 좋아하는 단골에게 먼저 넘깁니다.",
		"beats":[
			{"threshold":4,"title":"맞지 않는 톱니","message":"전에 본 사람이지. 3번 크레인에서 이상한 톱니들이 계속 나와. 원래 부품이 아닌데 서로 맞물리더군."},
			{"threshold":12,"title":"멈춘 기계의 시간","message":"부품들을 맞춰보니 오래된 시계 장치 비슷한 게 됩니다. 누가 왜 크레인 아래 숨겼는지는 모르겠지만."},
			{"threshold":24,"title":"마지막 무브먼트","message":"마지막 조각이 나왔어. 내가 고쳐 쓰긴 귀찮고, 네가 이런 걸 보는 눈은 있으니 먼저 가져가서 봐."}
		]
	},
	"toto":{
		"title":"마지막 공연",
		"signature_item":"bone_flute",
		"special_post":"마지막 공연 뒤로 한 번도 불지 않은 피리입니다. 이제는 무대 밖으로 보내려 합니다.",
		"beats":[
			{"threshold":4,"title":"연주하지 않는 악사","message":"또 왔군! 내가 악사인데 요즘 피리를 안 부는 게 궁금하지 않나? 뭐, 아직은 긴 얘기지."},
			{"threshold":12,"title":"관객 없는 마지막 곡","message":"마지막 공연 날 관객이 한 명도 없었는데, 끝나고 박수 소리가 났어. 그 뒤로 그 피리를 손대지 않았지."},
			{"threshold":24,"title":"마지막 피리","message":"그 피리를 이제 팔려고 해. 네가 몇 번이나 내 허풍을 걸러냈으니 이 얘기는 믿든 말든 네 몫이다."}
		]
	},
	"rook":{
		"title":"종탑 뒤 우편함",
		"signature_item":"mimic_key",
		"special_post":"종탑 뒤 우편함에서 마지막으로 나온 열쇠입니다. 오래 끌 생각 없으니 먼저 연락한 단골에게 보여드립니다.",
		"beats":[
			{"threshold":4,"title":"항상 같은 우편함","message":"전에 거래했던 분이군요. 제가 늘 종탑 뒤 우편함 근처만 고집하는 건 이유가 있습니다."},
			{"threshold":12,"title":"주소 없는 소포","message":"한동안 주소도 없는 소포가 그 우편함에 계속 들어왔습니다. 대부분은 팔았지만 열쇠 몇 개는 남겨뒀죠."},
			{"threshold":24,"title":"마지막 황동열쇠","message":"오늘 마지막 소포를 비웠습니다. 안에 있던 열쇠는 공개 매물로 올리기 전에 당신에게 먼저 보여드리죠."}
		]
	}
}

const DAY_MARKET_VISITS = 3

const DISTRICTS := [
	{
		"id":"night_market",
		"name":"야시장권",
		"neighborhoods":"야시장 북문 · 재봉골목",
		"description":"잡화와 마법 물건이 가장 많이 섞이는 어둠마을의 중심 장터.",
		"unlock_reputation":0,
		"seller_ids":["myomyo","pipi"],
		"preferred_tags":["마법","공예","재료","수집"],
		"art_key":"district_night_market"
	},
	{
		"id":"tower",
		"name":"탑지구",
		"neighborhoods":"별빛탑 아래 · 종탑 뒤편",
		"description":"전문가의 물건과 급하게 나온 희귀품이 함께 섞이는 상권.",
		"unlock_reputation":40,
		"seller_ids":["blue","rook"],
		"preferred_tags":["마법","고대","수집","별"],
		"art_key":"district_tower"
	},
	{
		"id":"dock",
		"name":"부두권",
		"neighborhoods":"고철부두 · 비늘골목",
		"description":"기계 부품과 재료가 많고 가격을 세게 부르는 상인이 많은 곳.",
		"unlock_reputation":100,
		"seller_ids":["grizzle","krok"],
		"preferred_tags":["기계","재료","고대","연금"],
		"art_key":"district_dock"
	},
	{
		"id":"grave",
		"name":"묘지권",
		"neighborhoods":"묘지길 · 뼈다리 광장",
		"description":"저주품과 기묘한 수집품이 자주 나오지만 판단 난도가 높은 상권.",
		"unlock_reputation":180,
		"seller_ids":["morna","toto"],
		"preferred_tags":["저주","영혼","음악","수집"],
		"art_key":"district_grave"
	}
]

const UPGRADES := [
	{
		"id":"storage",
		"name":"보관 선반",
		"description":"동시에 보관할 수 있는 물건 수를 늘립니다.",
		"base_value":2,
		"unit":"칸",
		"levels":[
			{"cost":6000,"reputation":0,"value":3},
			{"cost":12000,"reputation":60,"value":4},
			{"cost":25000,"reputation":150,"value":6}
		]
	},
	{
		"id":"notebook",
		"name":"현장 수첩",
		"description":"장터에서 더 많은 질문과 확인을 할 수 있습니다.",
		"base_value":4,
		"unit":"회",
		"levels":[
			{"cost":7500,"reputation":40,"value":5},
			{"cost":16000,"reputation":100,"value":6}
		]
	},
	{
		"id":"appraisal",
		"name":"감정소 계약",
		"description":"전문 감정 비용을 할인받습니다.",
		"base_value":0,
		"unit":"%",
		"levels":[
			{"cost":8000,"reputation":40,"value":10},
			{"cost":18000,"reputation":150,"value":20},
			{"cost":35000,"reputation":300,"value":30}
		]
	},
	{
		"id":"network",
		"name":"구매자 연락망",
		"description":"한 물건에서 확인할 수 있는 전문 견적 수를 늘립니다.",
		"base_value":2,
		"unit":"곳",
		"levels":[
			{"cost":12000,"reputation":100,"value":3},
			{"cost":30000,"reputation":300,"value":4}
		]
	},
	{
		"id":"routes",
		"name":"장터 동선 장부",
		"description":"하루에 둘러볼 수 있는 장터 수를 늘립니다.",
		"base_value":3,
		"unit":"회",
		"levels":[
			{"cost":10000,"reputation":60,"value":4},
			{"cost":22000,"reputation":180,"value":5}
		]
	}
]

const DAY_EVENTS := [
	{
		"id":"rain_market",
		"title":"비 오는 야시장",
		"description":"젖은 천막 아래로 평소보다 오래된 물건들이 많이 나왔다는 소문이 돈다.",
		"affected_tags":["수집","마법"],
		"asking_multiplier":0.95,
		"demand_multiplier":1.08,
		"effect_text":"수집·마법 물건 등록가 약 -5% · 재판매 수요 +8%",
		"volatile_special":true
	},
	{
		"id":"tower_open",
		"title":"탑의 야간 개방",
		"description":"탑 창고를 정리하는 날이라 오래 묵은 마도구가 동네로 흘러나오고 있다.",
		"affected_tags":["마법","고대"],
		"asking_multiplier":0.88,
		"demand_multiplier":1.00,
		"effect_text":"마법·고대 물건 공급 증가 · 등록가 약 -12%",
		"volatile_special":true
	},
	{
		"id":"dock_check",
		"title":"부두 검문 강화",
		"description":"짐 검사가 길어져 급하게 처분하려는 상인들이 있다는 이야기가 들린다.",
		"affected_tags":["기계","재료"],
		"asking_multiplier":0.90,
		"demand_multiplier":1.06,
		"effect_text":"기계·재료 급매 증가 · 등록가 약 -10% · 재판매 수요 +6%",
		"volatile_special":true
	},
	{
		"id":"grave_festival",
		"title":"묘지 축제 준비",
		"description":"묘지 쪽 공연과 제례 준비로 기묘한 수집품 거래가 늘었다.",
		"affected_tags":["저주","영혼","음악"],
		"asking_multiplier":1.08,
		"demand_multiplier":1.20,
		"effect_text":"저주·영혼·음악 물건 등록가 +8% · 재판매 수요 +20%",
		"volatile_special":true
	}
]

const COLLECTION_SETS := [
	{
		"id":"moonlit_curios",
		"name":"달빛과 별의 물건",
		"description":"밤빛과 하늘에 얽힌 수집품을 모은 세트.",
		"item_ids":["moon_ring","meteor_coin","mermaid_pearl"]
	},
	{
		"id":"cursed_corner",
		"name":"수상한 저주품",
		"description":"저주와 영혼, 정체불명의 힘이 남은 물건들.",
		"item_ids":["cursed_mirror","soul_lantern","mimic_key"]
	},
	{
		"id":"workshop_relics",
		"name":"괴물 공방 도구",
		"description":"기계와 공예, 연금에 쓰였던 오래된 도구들.",
		"item_ids":["goblin_watch","witch_thimble","frost_vial"]
	},
	{
		"id":"wild_remains",
		"name":"기묘한 생물의 흔적",
		"description":"괴물과 환상 생물에게서 유래한 재료와 유품.",
		"item_ids":["dragon_tooth","phoenix_feather","bone_flute"]
	}
]

const ACHIEVEMENTS := [
	{"id":"first_truth","name":"첫 정체 확인","description":"전문 감정이나 거래 복기로 물건의 실제 정체를 처음 확인한다."},
	{"id":"three_states","name":"진짜도 가짜도","description":"진품·모조품·결함품 세 상태를 모두 한 번 이상 발견한다."},
	{"id":"six_items","name":"반쯤 채운 장부","description":"서로 다른 아이템 6종의 정체를 기록한다."},
	{"id":"one_set","name":"한 묶음 완성","description":"테마 컬렉션 세트 하나를 완성한다."},
	{"id":"all_items","name":"어둠마을 수집가","description":"아이템 12종을 모두 도감에 기록한다."},
	{"id":"trusted_seller","name":"믿고 먼저 보여주는 사이","description":"판매자 한 명과 신뢰 단계 이상이 된다."},
	{"id":"profit_10000","name":"보는 눈이 돈이 된다","description":"도감에 기록된 거래 누적 순이익 10,000G를 넘긴다."}
]

const LONG_TERM_GOALS := [
	{
		"id":"catalog_3",
		"name":"첫 수집 장부",
		"description":"서로 다른 아이템 3종의 정체를 기록한다.",
		"kind":"items",
		"target":3,
		"reward_gold":1000,
		"reward_reputation":5
	},
	{
		"id":"catalog_6",
		"name":"반쪽 도감",
		"description":"서로 다른 아이템 6종의 정체를 기록한다.",
		"kind":"items",
		"target":6,
		"reward_gold":2000,
		"reward_reputation":10
	},
	{
		"id":"set_1",
		"name":"첫 테마 컬렉션",
		"description":"테마 컬렉션 세트 하나를 완성한다.",
		"kind":"sets",
		"target":1,
		"reward_gold":2500,
		"reward_reputation":15
	},
	{
		"id":"catalog_all",
		"name":"어둠마을 도감 완성",
		"description":"아이템 12종을 모두 기록한다.",
		"kind":"items",
		"target":12,
		"reward_gold":6000,
		"reward_reputation":30
	}
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


# v0.2.17 Conversation Coherence
# Pre-purchase actions use semantic clue channels so the answer always matches
# what the player asked to inspect. Polarity stays hidden in the UI.
const INVESTIGATION_ACTION_CLUES := {
	"exterior":{
		"genuine":{"text":"표면의 마모가 손이 닿는 자리와 가장자리에 자연스럽게 몰려 있다.","reveal":"오랜 사용에서 생긴 자연스러운 마모 패턴이었다."},
		"imitation":{"text":"낡은 흔적이 손이 닿지 않는 부분까지 지나치게 고르게 퍼져 있다.","reveal":"최근 인위적으로 낡게 만든 표면 처리였다."},
		"defect":{"text":"겉의 작은 손상이 가장자리 안쪽까지 이어져 있다.","reveal":"표면 흠집처럼 보였지만 실제 구조 손상이었다."},
		"neutral":{"text":"표면에 오래 보관한 먼지와 희미한 냄새가 남아 있다.","reveal":"보관 환경의 흔적으로 진위와 직접 관계는 없었다."}
	},
	"mark":{
		"genuine":{"text":"제작 표식의 닳은 정도와 주변 재질의 노화가 자연스럽게 이어진다.","reveal":"표식과 본체가 같은 시기에 만들어진 흔적이었다."},
		"imitation":{"text":"제작 표식의 홈 안쪽만 주변보다 유난히 날카롭고 새것 같다.","reveal":"오래된 본체에 표식을 나중에 새긴 흔적이었다."},
		"defect":{"text":"표식 근처의 접합부가 미세하게 벌어져 있다.","reveal":"제작부 주변의 실제 손상으로 가치가 내려갔다."},
		"neutral":{"text":"제작 표식 일부가 닳아 글자나 문양을 완전히 읽기는 어렵다.","reveal":"노화 흔적은 맞지만 진위 판단을 확정할 정보는 아니었다."}
	},
	"function":{
		"genuine":{"text":"작동이나 마력 반응이 한 부분에만 몰리지 않고 구조 전체에서 일정하게 이어진다.","reveal":"실제 제작 구조에서 나오는 자연스러운 반응이었다."},
		"imitation":{"text":"반응이 겉의 장식 부분에서만 나타나고 안쪽으로는 이어지지 않는다.","reveal":"기능을 흉내 낸 표면 처리에 가까웠다."},
		"defect":{"text":"특정 구간에서 작동이나 반응이 반복적으로 끊긴다.","reveal":"핵심 기능부의 손상이 실제로 확인됐다."},
		"neutral":{"text":"반응 자체는 있지만 이것만으로 오래된 진품인지 판단하기는 어렵다.","reveal":"재질 특성으로도 나타날 수 있는 반응이었다."}
	},
	"origin":{
		"genuine":{"text":"판매자가 말한 입수 시기와 물건에 남은 사용·보관 흔적이 크게 모순되지 않는다.","reveal":"출처 설명과 물건의 실제 흔적이 대체로 일치했다."},
		"imitation":{"text":"판매자가 말한 입수 시기와 포장·가공 흔적의 시기가 서로 잘 맞지 않는다.","reveal":"출처 설명과 실제 제작 시점 사이에 모순이 있었다."},
		"defect":{"text":"판매자가 이야기를 이어가다 예전에 수리하거나 문제가 있었던 적을 뒤늦게 언급한다.","reveal":"판매 전 설명에서 빠져 있던 수리·결함 이력이 실제로 있었다."},
		"neutral":{"text":"판매자는 전 주인이나 정확한 구매처까지는 기억하지 못한다고 한다.","reveal":"출처를 확정할 수 없는 정보라 진위 판단의 결정적 근거는 아니었다."}
	}
}


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
