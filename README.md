# NEXT (WearWeather)

## Current state
- Branch: main
- Last commit: (여기에 커밋 해시 붙여넣기)
- Build status: OK (스크롤/헤더 클릭 정상)

## What we changed today
- MainView UI 정리:
  - ScrollView 적용 + safeAreaInset으로 헤더(위치/새로고침) 상단 고정
  - 캐릭터(OutfitAvatarView)와 아래 섹션 사이 간격 확보
  - 섹션 UI 카드 톤 통일(헤드라인 + 카드 배경/라운드/그림자)
- 캐릭터 UI(OutfitAvatarView) 개선:
  - 현재 온도 표시를 캐릭터 가슴(상의 영역)에 오버레이로 표시
  - H/L/상태(예: "H 17° L 12° · 비")도 온도와 함께 캐릭터 몸에 붙도록 오버레이 추가
  - 악세서리 위치 분리(임시 룰):
    - gloves → 양손 위치
    - umbrella → 오른쪽 손/옆 소품 느낌 위치
    - 기타 accessory → 상의 아래 작은 슬롯(임시)
  - 발쪽 슬롯에서 악세서리가 신발 위치로 내려가던 문제 확인 및 해결(발에는 신발만 보이도록 로직 정리)
- 주간 예보(7일) UI 개선:
  - Daily Forecast 섹션 추가/복구
  - 최저~최고 온도 범위를 한눈에 보는 막대(bar) 형태의 리스트 UI 적용
- 오늘 코디 카드:
  - 기획서 기준 필수 UI는 아니라서 디버그 확인용으로만 유지(필요시 #if DEBUG로 숨김)

## Known issues
- 캐릭터/의상은 아직 플레이스홀더(임시 에셋)라 실제 아바타 에셋 적용 시 좌표/크기 재조정 필요
- 신발/악세서리/코디 데이터 모델은 아직 “임시 문자열 기반” (추후 구조화 필요)
- Daily/Hourly 데이터는 현재 일부는 목데이터/간단 생성 로직이 섞여있을 수 있음(WeatherKit 기반 확장 예정)

## Next tasks (priority)
1) UI 계속 다듬기:
   - Daily Forecast 행 간격/타이포/아이콘 크기 조정
   - 섹션 간 spacing 통일, 카드 내부 padding 최적화
   - (옵션) 주간예보 접기/펼치기(기본 3일 + 더보기)
2) 날씨 상세 정보 섹션 추가:
   - 바람(풍속/풍향), 습도, 체감온도, 강수확률 등 WeatherKit 값 연결
3) 공기질(AQI/미세먼지) 섹션 추가 + 마스크 표시 로직 연동
4) 위젯(App Group 저장) 연동을 위한 데이터 저장 구조 설계

## Notes
- 다음 대화 시작 시: "main 브랜치, 마지막 커밋 해시 xxx 기준으로 이어가자" 라고 말하면 바로 이어갈 수 있음.
