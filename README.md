# NEXT (WearWeather) — 이어서 개발하기용 README

## 0) 현재 브랜치/상태
- Branch: `main`
- Last commit: `<여기에 커밋 해시 붙여넣기>`
- Build status:
  - Debug 빌드: OK (디버그 시나리오 패널 사용 가능)
  - Release 빌드: OK (디버그 기능 숨김 확인 완료)

---

## 1) 프로젝트 방향(현 단계 원칙)
- **오픈/비용 고려 → 당분간 목데이터 중심으로 UI/UX 완성**
- WeatherKit/공기질 실연동 + App Groups(위젯 공유 저장)는 **오픈 직전(또는 유료/팀 계정 가능 시점)**으로 보류
- 위젯/앱은 “깨지지 않게” 1차 완성 상태. **캐릭터가 임시라서 미세 튜닝은 중단**(나중에 이미지 캐릭터 들어오면 재조정 예정)

---

## 2) 이번까지 반영된 큰 변경 요약

### A. 위젯 UI/레이아웃 정리(1차 완료)
- 위젯 전용 캐릭터 뷰 도입(앱용 `OutfitAvatarView`와 분리)
- 위젯 family별 레이아웃 분기 확정  
  - `systemSmall / systemMedium / accessoryRectangular / accessoryCircular / accessoryInline`
- 위젯에서는 옷 라벨 텍스트(hoodie/jeans/umbrella 등) 제거(깨짐 방지)
- placeholder는 **“텍스트 없이 도형”**만 사용

**관련 파일**
- `WearWeatherWidget/WearWeatherWidgetView.swift`
- `WearWeatherWidget/OutfitAvatarWidgetView.swift`

---

### B. 목데이터 파이프라인 공통화(앱/위젯 일관성 확보)
- 앱/위젯이 서로 다른 mock을 쓰던 구조를 정리하고  
  **`WearWeatherMockPipeline` 한 곳에서 목데이터 생성**
- 기본 시나리오: 시간(시) 기반으로 자동 변경
- 앱/위젯에서 **서울/온도/상태/코디 추천이 동일한 시나리오로 맞춰지는 것 확인 완료**

**관련 파일**
- `WearWeather/Shared/Mock/WearWeatherMockPipeline.swift` (공통 목데이터 생성)
- `WearWeatherWidget/Provider.swift` (위젯도 pipeline 사용)
- `WearWeather/Presentation/MainViewModel.swift` (mock 모드에서 pipeline 적용)
- `WearWeather/Shared/AppConfig.swift`

> 주의: 위젯 타겟에서 컴파일 되도록 `WeatherPackage`, `HourlyForecastItem`, `DailyForecastItem`, `Stylist` 관련 파일들은 **Target Membership에 `WearWeatherWidgetExtension` 체크**가 되어 있어야 함.

---

### C. 개발자 전용 “시나리오 고정(Debug 패널)” 추가 + Release 숨김 처리
- 앱 상단 헤더의 **“서울” 텍스트 롱프레스(0.6s)** → Debug 시트 열림 (Debug 빌드에서만)
- Debug 시트에서 시나리오를 선택하면 앱 UI가 즉시 바뀜 (예: 비 → 맑음)
- 헤더에 `AUTO` / `LOCK: ...` 배지 표시 (Debug 빌드에서만)
- Release/TestFlight에서는 **디버그 배지/시트/제스처가 완전히 사라짐**(`#if DEBUG` 게이트)

**관련 파일**
- `WearWeather/Presentation/MainView.swift`
- `WearWeather/Presentation/MainViewModel.swift`
- `WearWeather/Shared/Mock/WearWeatherMockPipeline.swift`
- `WearWeather/Shared/AppConfig.swift`

---

## 3) 디버그 패널 사용법(개발 단계)
### Debug 빌드에서
1. 앱 실행
2. 상단 “서울” 텍스트를 **길게 누르기**
3. Debug 시트에서 시나리오 선택 → “선택한 시나리오로 고정”
4. 헤더에 `LOCK: ...` 배지가 표시되며 UI가 해당 시나리오로 고정됨
5. “고정 해제(자동으로)”로 원복 가능

### Release/TestFlight에서
- Debug 배지/시트/롱프레스가 **노출되지 않는 것이 정상**

---

## 4) Release 빌드 로컬 테스트 방법(중요)
1. Xcode: `Product > Scheme > Edit Scheme…`
2. `Run` → `Build Configuration`을 **Release**로 변경
3. Run 실행
4. 확인:
   - 헤더 배지(`AUTO/LOCK`) **없음**
   - “서울” 롱프레스해도 **Debug 시트 안 뜸**
5. 테스트 후 다시 Debug로 돌려놓기(개발 편의)

---

## 5) 현재 이슈/메모
- 위젯 디버깅 중 `Thread 1: signal SIGTERM` 간헐 발생 가능  
  → 위젯 호스트 종료로 **정상 케이스**가 많음
- iOS 26 기준 `CLGeocoder/reverseGeocodeLocation` deprecated 경고 존재  
  → 현 단계에서는 보류, 나중에 MapKit reverse geocoding으로 전환 예정
- App Groups는 현재 OFF  
  → 앱에서 고정한 시나리오를 위젯까지 완전 동기화하려면 App Groups ON이 필요(오픈 직전 작업)

---

## 6) 다음 작업 후보(우선순위 제안)
### 1순위(추천): “코디 텍스트” 사용자 친화적으로 요약
현재 임시 캐릭터 라벨 대신,
- 예: “반팔 + 반바지, 얇은 겉옷 불필요”
- 예: “우산 챙기기, 방수 신발 추천”
이런 **한 줄 요약**을 앱/위젯 공통으로 출력

### 2순위: 실제 캐릭터 이미지(에셋) 교체 대비 구조 고정
- 현재 placeholder 기반 캐릭터를 “이미지 캐릭터”로 갈아끼울 때
  - 스케일/정렬/마스크 처리 전략
  - 에셋 네이밍 규칙
  - fallback 정책
정리

### 3순위: 위젯 App Groups 연동(오픈 직전)
- App Groups ON
- 앱에서 저장한 시나리오 override/스냅샷을 위젯이 읽어서 **완전 동기화**

---

## 7) 작업 이어가기 “다음 대화 시작 문장”(복붙용)
아래를 다음 채팅 첫 메시지로 그대로 붙여넣으면 이어서 진행 가능:

```text
NEXT (WearWeather) 이어가기

Branch: main
Last commit: <커밋 해시>

현재 상태:
- 위젯 family별 레이아웃 + 위젯 전용 캐릭터 뷰 적용 완료
- 앱/위젯 목데이터 공통 파이프라인(WearWeatherMockPipeline) 적용 완료
- Debug 빌드에서 시나리오 고정 패널(서울 롱프레스) 동작, Release에서 숨김 확인 완료

다음 작업:
- (1순위) 코디 추천을 사용자 친화적인 한 줄 요약 텍스트로 만들고 앱/위젯에 공통 표시하게 구현해줘
요구사항:
- 파일 경로 포함해서 안내
- 수정 파일은 전체 코드로 제공(부분 코드 금지)
