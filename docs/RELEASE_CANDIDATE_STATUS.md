# Release Candidate Status

Target: `v1.0.0-rc1`

## Production Stage

- P1 Commercial Shell: PASS
- P2 World / Day Structure: PASS
- P3 Meta Progression: PASS
- P4 Seller Relationships: PASS
- P5 Collection / Long-term Goals: PASS
- P6 Dynamic Market: PASS
- P7 Commercial UX / Presentation: PASS
- P8 Content / Release Completion: IN PROGRESS

## P8 State

### Content
- Tradable item types: 24
- Sellers: 8
- Districts: 4
- Daily rumors: 8
- Collection sets: 8
- Stable item final-image slots: 24
- Stable seller final-image slots: 8
- Stable district final-image slots: 4

### Automated gates

- Core syntax / boot: awaiting final P8 HEAD run
- Core smoke: awaiting final P8 HEAD run
- Long-run balance: implemented; deterministic 960-listing simulation
- Full 390×844 flow: awaiting final P8 HEAD run
- Multi-device layout: implemented for 375×812 / 390×844 / 430×932
- Expanded-catalog migration: implemented
- Backup recovery: implemented and previously green
- Asset contract: implemented

## Remaining before RC tag

1. Final P8 CI must be entirely green.
2. Any release-gate failures must be fixed, not waived.
3. Master Plan / README version must move to `v1.0.0-rc1`.
4. P8 must be marked PASS.

## After RC

Remaining production is asset/store work:

- final item/seller/location art
- UI skin/icons/VFX
- final BGM/SFX
- store screenshots/icon/promo
- real-device release QA
- signing/store submission

Gameplay feature design is frozen after RC except release blockers.
