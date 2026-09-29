extends RefCounted

# P8 Final Visual Asset Contract
#
# Final files may be absent during structural production.
# data/art_catalog.gd supplies a placeholder until a file exists at final_texture.
# Adding/replacing the file at the stable path must never require gameplay code edits.

const ITEM_SIZE := Vector2i(1024, 1024)
const SELLER_SIZE := Vector2i(1024, 1024)
const DISTRICT_SIZE := Vector2i(1200, 675)
const TITLE_SIZE := Vector2i(1080, 1920)
const ONBOARDING_SIZE := Vector2i(1200, 900)

const REQUIRED_UI_KEYS := [
	"market",
	"brand",
	"appraiser",
	"title_background",
	"onboarding_world",
	"onboarding_role",
	"onboarding_goal",
	"district_night_market",
	"district_tower",
	"district_dock",
	"district_grave",
	"fallback"
]

const OPTIONAL_UI_KEYS := [
	"workshop",
	"relationships",
	"collection"
]

const DISTRICT_FINAL_PATHS := {
	"district_night_market":"res://assets/art/districts/night_market.png",
	"district_tower":"res://assets/art/districts/tower.png",
	"district_dock":"res://assets/art/districts/dock.png",
	"district_grave":"res://assets/art/districts/grave.png"
}

const COMMERCIAL_FINAL_PATHS := {
	"title_background":"res://assets/art/ui/title_background.png",
	"onboarding_world":"res://assets/art/ui/onboarding_world.png",
	"onboarding_role":"res://assets/art/ui/onboarding_role.png",
	"onboarding_goal":"res://assets/art/ui/onboarding_goal.png"
}

const AUDIO_ROOTS := {
	"bgm":"res://assets/audio/bgm/",
	"sfx":"res://assets/audio/sfx/"
}
