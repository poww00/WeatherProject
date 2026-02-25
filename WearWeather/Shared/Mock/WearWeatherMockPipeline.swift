import Foundation

/// 앱/위젯이 공통으로 사용하는 “목데이터 파이프라인”
/// - 기본: 시간 기반 시나리오
/// - 디버그: override가 있으면 override 우선
enum WearWeatherMockPipeline {

    enum Scenario: Int, CaseIterable, Identifiable {
        case cloudyCold
        case rainy
        case clearWarm
        case snowy
        case stormy

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .cloudyCold: return "흐림/추움"
            case .rainy: return "비"
            case .clearWarm: return "맑음/따뜻"
            case .snowy: return "눈"
            case .stormy: return "폭풍"
            }
        }
    }

    // MARK: - Override Storage

    /// override 가져오기 (있으면 Scenario, 없으면 nil)
    static func getScenarioOverride() -> Scenario? {
        // App Groups ON이면 공유 저장소에서 읽기
        if AppConfig.useAppGroupForWidget {
            if let raw: Int = AppGroupStore.read(
                key: AppConfig.mockScenarioOverrideKey,
                suiteName: AppConfig.appGroupId,
                as: Int.self
            ) {
                return Scenario(rawValue: raw)
            }
            return nil
        }

        // OFF면 일반 UserDefaults(앱/위젯 각각 따로)
        let raw = UserDefaults.standard.object(forKey: AppConfig.mockScenarioOverrideKey) as? Int
        if let raw { return Scenario(rawValue: raw) }
        return nil
    }

    /// override 설정
    static func setScenarioOverride(_ scenario: Scenario) {
        if AppConfig.useAppGroupForWidget {
            AppGroupStore.saveRawInt(
                scenario.rawValue,
                key: AppConfig.mockScenarioOverrideKey,
                suiteName: AppConfig.appGroupId
            )
        } else {
            UserDefaults.standard.set(scenario.rawValue, forKey: AppConfig.mockScenarioOverrideKey)
        }
    }

    /// override 해제(자동 시간 기반으로 돌아감)
    static func clearScenarioOverride() {
        if AppConfig.useAppGroupForWidget {
            AppGroupStore.remove(
                key: AppConfig.mockScenarioOverrideKey,
                suiteName: AppConfig.appGroupId
            )
        } else {
            UserDefaults.standard.removeObject(forKey: AppConfig.mockScenarioOverrideKey)
        }
    }

    // MARK: - Scenario 결정 로직

    /// ✅ 현재 시나리오: override가 있으면 override 우선, 없으면 시간 기반
    static func currentScenario(now: Date = Date()) -> Scenario {
        if let override = getScenarioOverride() {
            return override
        }
        let hour = Calendar.current.component(.hour, from: now)
        let idx = hour % Scenario.allCases.count
        return Scenario.allCases[idx]
    }

    static func locationName(now: Date = Date()) -> String {
        // 목데이터 단계에서는 고정(지오코더/권한/지도 다 나중)
        return "서울"
    }

    static func makeWeatherPackage(now: Date = Date()) -> WeatherPackage {
        let scenario = currentScenario(now: now)
        let current = weather(for: scenario)
        let daily = makeDaily(now: now, base: current)
        return WeatherPackage(current: current, daily: daily)
    }

    static func makeHourly(now: Date = Date(), current: WeatherModel) -> [HourlyForecastItem] {
        let base = Int(current.temperature.rounded())
        let nowHour = Calendar.current.component(.hour, from: now)

        func tempOffset(_ i: Int) -> Int {
            let pattern = [-2, -1, 0, 1, 2, 1, 0, -1]
            return pattern[i % pattern.count]
        }

        func conditionForHour(_ i: Int) -> WeatherModel.WeatherCondition {
            switch current.condition {
            case .storm: return (i % 3 == 0) ? .storm : .rain
            case .snow:  return (i % 4 == 0) ? .snow : .cloudy
            case .rain:  return (i % 4 == 0) ? .rain : .cloudy
            case .cloudy:return (i % 5 == 0) ? .cloudy : .clear
            case .clear: return .clear
            }
        }

        return (0..<8).map { i in
            let hour = (nowHour + i + 1) % 24
            return HourlyForecastItem(
                hourText: "\(hour)시",
                temperature: base + tempOffset(i),
                condition: conditionForHour(i)
            )
        }
    }

    static func makeWidgetSnapshot(now: Date = Date()) -> WidgetSnapshot {
        let loc = locationName(now: now)
        let pkg = makeWeatherPackage(now: now)
        let w = pkg.current

        let outfit = Stylist.shared.recommendOutfit(
            temp: w.temperature,
            condition: w.condition,
            isBadAir: w.isBadAir
        )

        return WidgetSnapshot.make(
            locationName: loc,
            weather: w,
            outfit: outfit
        )
    }

    // MARK: - Internals

    private static func weather(for scenario: Scenario) -> WeatherModel {
        switch scenario {
        case .cloudyCold:
            return WeatherModel(
                temperature: 7, condition: .cloudy, highTemperature: 10, lowTemperature: 2,
                feelsLike: 5, humidity: 0.62, windSpeed: 3.2, windDirection: 40, precipitationChance: 0.10,
                aqi: 72, pm25: 22
            )

        case .rainy:
            return WeatherModel(
                temperature: 16, condition: .rain, highTemperature: 17, lowTemperature: 12,
                feelsLike: 15, humidity: 0.86, windSpeed: 4.9, windDirection: 190, precipitationChance: 0.75,
                aqi: 96, pm25: 30
            )

        case .clearWarm:
            return WeatherModel(
                temperature: 27, condition: .clear, highTemperature: 29, lowTemperature: 21,
                feelsLike: 29, humidity: 0.48, windSpeed: 2.1, windDirection: 120, precipitationChance: 0.05,
                aqi: 38, pm25: 8
            )

        case .snowy:
            return WeatherModel(
                temperature: -1, condition: .snow, highTemperature: 0, lowTemperature: -6,
                feelsLike: -4, humidity: 0.70, windSpeed: 5.2, windDirection: 320, precipitationChance: 0.55,
                aqi: 118, pm25: 42
            )

        case .stormy:
            return WeatherModel(
                temperature: 12, condition: .storm, highTemperature: 13, lowTemperature: 8,
                feelsLike: 10, humidity: 0.90, windSpeed: 9.8, windDirection: 250, precipitationChance: 0.90,
                aqi: 165, pm25: 68
            )
        }
    }

    private static func makeDaily(now: Date, base: WeatherModel) -> [DailyForecastItem] {
        let cal = Calendar.current
        let baseHigh = Int(base.highTemperature.rounded())
        let baseLow = Int(base.lowTemperature.rounded())

        func conditionForDay(_ i: Int) -> WeatherModel.WeatherCondition {
            switch base.condition {
            case .storm:
                return (i % 3 == 0) ? .storm : .rain
            case .snow:
                return (i % 4 == 0) ? .snow : .cloudy
            case .rain:
                return (i % 4 == 0) ? .rain : .cloudy
            case .cloudy:
                return (i % 5 == 0) ? .cloudy : .clear
            case .clear:
                return .clear
            }
        }

        return (0..<7).compactMap { i in
            guard let date = cal.date(byAdding: .day, value: i, to: now) else { return nil }
            let wiggle = [0, 1, -1, 2, -2, 1, 0][i % 7]
            let high = Double(baseHigh + wiggle)
            let low = Double(baseLow + min(wiggle, 0))

            return DailyForecastItem(
                date: date,
                highTemperature: high,
                lowTemperature: low,
                condition: conditionForDay(i)
            )
        }
    }
}
