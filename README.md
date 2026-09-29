# 괴물 중고마켓 MVP v0.2.3 — Home Feed Art Integration

“오늘 뭐 올라왔지?” 하고 세 매물을 둘러보는 **홈 피드 → 상세 조사 → 거래 계획·흥정 → 보유품 → 선택 감정 → 재판매 → 거래 기록** 흐름입니다. v0.2.2의 숨은 물건 상태와 제한된 조사·견적, 가격 협상, 정보 비용, 판매처 선택과 손익 복기를 유지합니다.

## 이번 버전

- 컴팩트한 골드·보유품 상단과 어둠마을 야시장 상태
- 이름, 희망가, 판매자, 데이터 기반 태그와 공개 단서 하나를 담은 세로 카드 3개
- 가끔 한 개의 특별 매물: 모든 archetype이 같은 표시를 쓰며 대박이나 안전을 보장하지 않음
- 다른 매물을 비교할 때 매물·단서·공유 조사 잔량·흥정 상태·홈 스크롤 유지
- 조사 기회 소진 또는 실제 구매 후에만 가능한 ‘다음 장터 보기’와 조건 안내
- 고정 하단 홈 / 보유품 / 거래 기록, 기존 최근 거래와 누적 손익 재진입
- v0.2.2 저장 호환, 390px 세로 UI와 긴 단서·선택 메뉴 폭 제한

제공된 ZIP의 아이템 12종·판매자 8명·야시장 배경·브랜드·감정사·공통 이미지 24개를 사용합니다. 표시 이름과 그림은 교체 가능한 별도 목록에 연결했습니다. 검색·필터, 가짜 메뉴와 새 핵심 게임 시스템은 추가하지 않습니다. 전문 감정은 선택한 보유품에서 이용하고, 감정 없이 판매해도 됩니다.

## 실행

Godot 4.5.1 이상에서 저장소 루트를 엽니다.

- 메인 씬: `res://scenes/main.tscn`
- 기준 해상도: 390×844
- PC 마우스 / iPhone Xogot 터치 대응, 기본 Control UI만 사용
- 첫 실행 시 홈, 저장이 있으면 진행 중 화면과 상태 복원

## 자동 검증

```sh
godot --headless --path . --editor --import
godot --headless --path . -s res://tests/art_smoke_test.gd
godot --headless --path . --quit-after 3
godot --headless --path . -s res://tests/core_smoke_test.gd
```

실제 화면과 저장을 검사하는 home feed smoke는 **격리된 저장 폴더**에서 실행합니다.

Linux:

```sh
export XDG_DATA_HOME="$PWD/.godot/smoke-data"
export MONSTER_SMOKE_DATA_ROOT="$XDG_DATA_HOME"
godot --headless --path . -s res://tests/home_feed_smoke_test.gd
```

Windows PowerShell:

```powershell
$env:APPDATA = Join-Path (Get-Location) '.godot/smoke-data'
$env:MONSTER_SMOKE_DATA_ROOT = $env:APPDATA
godot --headless --path . -s res://tests/home_feed_smoke_test.gd
```

GitHub Actions에서도 메인 씬 부팅, core smoke, 실제 UI의 390×844 가로 넘침과 거래/저장 회귀를 검증합니다. iPhone Xogot 기기 확인은 별도로 필요합니다.

에셋 교체: [이미지 연결·이름·저장 호환 안내](docs/ART_INTEGRATION.md).

설계: [v0.2.3 홈 피드](docs/V0_2_3_HOME_FEED.md), [v0.2.2 마켓 경험](docs/V0_2_2_MARKET_EXPERIENCE.md).
