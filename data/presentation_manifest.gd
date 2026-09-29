extends RefCounted

# P7 Commercial Presentation Manifest
#
# These paths are intentionally allowed to be absent during structural production.
# The runtime checks ResourceLoader.exists() before loading a stream.
# P8 final asset integration only needs to place files at these stable slots.

const BGM := {
	"title":"res://assets/audio/bgm/title.ogg",
	"town":"res://assets/audio/bgm/town.ogg",
	"market":"res://assets/audio/bgm/market.ogg",
	"chat":"res://assets/audio/bgm/chat.ogg",
	"deal":"res://assets/audio/bgm/deal.ogg",
	"appraisal":"res://assets/audio/bgm/appraisal.ogg",
	"sale":"res://assets/audio/bgm/sale.ogg",
	"result":"res://assets/audio/bgm/result.ogg"
}

const SFX := {
	"tap":"res://assets/audio/sfx/tap.ogg",
	"open_listing":"res://assets/audio/sfx/open_listing.ogg",
	"message_send":"res://assets/audio/sfx/message_send.ogg",
	"clue_reveal":"res://assets/audio/sfx/clue_reveal.ogg",
	"offer_submit":"res://assets/audio/sfx/offer_submit.ogg",
	"purchase":"res://assets/audio/sfx/purchase.ogg",
	"appraisal_reveal":"res://assets/audio/sfx/appraisal_reveal.ogg",
	"sale_complete":"res://assets/audio/sfx/sale_complete.ogg",
	"goal_complete":"res://assets/audio/sfx/goal_complete.ogg",
	"achievement":"res://assets/audio/sfx/achievement.ogg",
	"upgrade":"res://assets/audio/sfx/upgrade.ogg",
	"day_end":"res://assets/audio/sfx/day_end.ogg",
	"warning":"res://assets/audio/sfx/warning.ogg"
}

const HAPTIC_MS := {
	"light":18,
	"medium":32,
	"success":48,
	"warning":65
}

const CONTEXT_TIPS := {
	"market":{
		"title":"장터에서는 다 볼 수 없습니다",
		"body":"확인 기회가 제한되어 있습니다. 싸 보이는 물건보다 ‘왜 수상한지’ 먼저 정하고 질문을 고르세요."
	},
	"chat":{
		"title":"괴물의 말도 단서입니다",
		"body":"사진·출처·작동 상태를 물어볼 수 있습니다. 같은 판매자를 다시 만나면 관계와 개인 이야기도 이어집니다."
	},
	"deal":{
		"title":"싸게 사는 것보다 상한이 중요합니다",
		"body":"미리 정한 최대 매입가를 넘는 순간 경고가 뜹니다. 발견한 단서는 흥정 근거로 쓸 수 있습니다."
	},
	"appraisal":{
		"title":"정보에도 가격이 있습니다",
		"body":"모든 검사를 살 필요는 없습니다. 이미 충분히 확신했다면 감정 없이 바로 판매하는 것도 선택입니다."
	},
	"sale":{
		"title":"판매처마다 원하는 물건이 다릅니다",
		"body":"전문 견적 횟수는 제한됩니다. 오늘의 소문과 물건 속성을 보고 어디에 먼저 물어볼지 정하세요."
	},
	"workshop":{
		"title":"돈을 버는 것만큼 도구도 중요합니다",
		"body":"보관·조사·감정·판매망·동선을 업그레이드하면 이후 모든 DAY의 선택지가 넓어집니다."
	},
	"collection":{
		"title":"수익 밖의 장기 목표",
		"body":"감정하거나 거래를 마치면 실제 정체가 수집 장부에 남습니다. 세트와 장기 목표 보상도 확인하세요."
	}
}
