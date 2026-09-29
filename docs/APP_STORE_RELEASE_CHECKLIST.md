# 괴물 중고마켓 — Release Checklist

P8 이후 실제 배포 직전 확인용 체크리스트.

이 문서는 gameplay 설계 목록이 아니다.
아래에서 **Code / Data / QA** 항목은 P8에서 닫고,
**Final Asset / Store Admin**만 출시 준비 단계에 남긴다.

---

## A. Code / Runtime — P8에서 완료

- [x] 타이틀 / 새 게임 / 이어하기
- [x] 첫 세션 onboarding
- [x] 하루 lifecycle / 다음 날
- [x] 4개 상권과 해금
- [x] 매물 탐색 / 판매자 채팅 / 조사
- [x] 가격 계획 / 흥정 / 구매
- [x] 보유품 / 추가 검사 / 전문 감정
- [x] 판매처 탐색 / 견적 / 재판매
- [x] 거래 복기
- [x] 상인 평판 / 등급
- [x] 작업실 업그레이드
- [x] 판매자 관계 / 개인 story arc
- [x] 24종 도감 / 8 collection sets
- [x] 장기 목표 / 업적
- [x] 8종 daily market rumor
- [x] 설정 / reduced motion / large text
- [x] BGM/SFX/haptic event hooks
- [x] atomic primary/backup/temp save
- [x] corrupted-save recovery
- [x] 구버전 save migration

---

## B. Automated Release QA

CI가 다음을 모두 통과해야 RC 가능.

- [ ] Content syntax
- [ ] Game logic syntax
- [ ] Main scene syntax
- [ ] Main scene boot
- [ ] Core gameplay smoke
- [ ] 960+ listing long-run balance simulation
- [ ] Full 390×844 transaction regression
- [ ] 375×812 layout
- [ ] 390×844 layout
- [ ] 430×932 layout
- [ ] v37 → v38 expanded-catalog migration
- [ ] corrupted primary → backup recovery
- [ ] final asset slot integrity
- [ ] placeholder fallback / no hidden-truth art leak

RC 상태는 `RELEASE_CANDIDATE_STATUS.md`에 기록한다.

---

## C. Final Visual Assets — 제작 파일 교체

Source of Truth:
`docs/FINAL_ASSET_MANIFEST.md`

- [ ] Item art 24종
- [ ] Seller portrait 8명
- [ ] District art 4장
- [ ] Title background 1장
- [ ] Onboarding 3장
- [ ] Brand/logo final
- [ ] Market/appraiser final polish
- [ ] UI icon/skin pass
- [ ] 필요한 VFX texture

파일명/경로를 바꾸지 않는다.
같은 stable path에 넣으면 runtime이 자동 사용한다.

---

## D. Audio Assets

Stable paths:
`data/presentation_manifest.gd`

- [ ] BGM 8 tracks
- [ ] SFX 13 events
- [ ] 실제 기기에서 music/sfx volume 확인
- [ ] mute 상태 확인
- [ ] haptic off 확인

파일 부재는 gameplay blocker가 아니며 placeholder production 중에는 허용된다.

---

## E. Real Device QA

자동 테스트 이후 실제 기기에서 마지막으로 확인:

- [ ] iPhone portrait 첫 실행
- [ ] 새 게임 → onboarding → 첫 장터
- [ ] 판매자 채팅에서 터치/스크롤
- [ ] 긴 매물명/판매자명
- [ ] 가격 slider 조작
- [ ] 구매 → 감정 → 판매
- [ ] 하루 마감 → 다음 날
- [ ] 앱 종료 후 이어하기
- [ ] 설정 persistence
- [ ] offline 실행
- [ ] reduced motion / large text

---

## F. Store Package / Admin

코드와 별도의 출시 운영 작업:

- [ ] App icon
- [ ] launch/splash assets
- [ ] store screenshots
- [ ] preview/promo art if used
- [ ] app description
- [ ] age/content questionnaire
- [ ] privacy/support pages
- [ ] version/build number
- [ ] signing/provisioning
- [ ] TestFlight/internal distribution
- [ ] final archive validation
- [ ] release notes

---

# RC Definition

다음을 동시에 만족하면 gameplay repository를 Release Candidate로 본다.

1. Section B 자동 Gate 전부 green
2. 저장 마이그레이션/복구 green
3. 모든 final asset stable slot 존재
4. placeholder 상태에서도 전체 플레이 가능
5. gameplay code에 TODO 형태의 필수 흐름이 남지 않음

그 이후 최종 아트/오디오 교체는 gameplay code rewrite가 아니다.
