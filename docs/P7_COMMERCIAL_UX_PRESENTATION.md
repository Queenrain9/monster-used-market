# P7 — Commercial UX & Presentation Hooks

## Objective

Final asset production must not be responsible for inventing game feedback.

Before final art/audio:
- every important action already has a feedback event
- every major screen already has a BGM state
- tutorial timing is known
- motion can be reduced
- sound/haptic can be disabled
- corrupted saves can recover

## Presentation Event Contract

All audio is optional during development.
Missing asset files never make gameplay fail.

Stable event keys live in:
`data/presentation_manifest.gd`

## Motion

Default:
- panel enter alpha tween 0.14s

Reduced Motion:
- immediate full opacity

No gameplay state depends on tween completion.

## Context Tips

Context tips are supplemental onboarding.
They never block engine state or consume game resources.

Seen state:
`tutorial_flags[stage_id]`

## Settings Persistence

Settings are account/device preference rather than run progress.

Separate file:
`user://monster_used_market_settings.json`

## Save Recovery

Gameplay save uses:
- primary
- backup
- temp

Load order:
1. primary
2. backup
3. legacy v0.2.x path

If backup is used, primary is repaired before normal play continues.

## P8 Handoff

Final assets may be produced independently against stable slots.
No game-rule rewrite is expected during final asset integration.
