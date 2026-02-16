import Foundation

final class MockWeatherProvider: WeatherProviding {

    enum MockStyle {
        case warmClear
        case mildCloudy
        case rainy
        case snowy
        case stormy
        case random
    }

    private var style: MockStyle

    init(style: MockStyle = .random) {
        self.style = style
    }

    func getWeatherPackage(latitude: Double, longitude: Double) async throws -> WeatherPackage {
        let pick = (style == .random) ? randomStyleByTime() : style

        let current: WeatherModel
        switch pick {
        case .warmClear:
            current = WeatherModel(
                temperature: 27, condition: .clear, highTemperature: 29, lowTemperature: 21,
                feelsLike: 29,
                humidity: 0.48,
                windSpeed: 2.1,
                windDirection: 120,
                precipitationChance: 0.05
            )

        case .mildCloudy:
            current = WeatherModel(
                temperature: 18, condition: .cloudy, highTemperature: 20, lowTemperature: 14,
                feelsLike: 17,
                humidity: 0.62,
                windSpeed: 3.4,
                windDirection: 40,
                precipitationChance: 0.20
            )

        case .rainy:
            current = WeatherModel(
                temperature: 16, condition: .rain, highTemperature: 17, lowTemperature: 12,
                feelsLike: 15,
                humidity: 0.86,
                windSpeed: 4.9,
                windDirection: 190,
                precipitationChance: 0.75
            )

        case .snowy:
            current = WeatherModel(
                temperature: -1, condition: .snow, highTemperature: 0, lowTemperature: -6,
                feelsLike: -4,
                humidity: 0.70,
                windSpeed: 5.2,
                windDirection: 320,
                precipitationChance: 0.55
            )

        case .stormy:
            current = WeatherModel(
                temperature: 12, condition: .storm, highTemperature: 13, lowTemperature: 8,
                feelsLike: 10,
                humidity: 0.90,
                windSpeed: 9.8,
                windDirection: 250,
                precipitationChance: 0.90
            )

        case .random:
            current = WeatherModel(
                temperature: 20, condition: .cloudy, highTemperature: 22, lowTemperature: 16,
                feelsLike: 19,
                humidity: 0.55,
                windSpeed: 2.8,
                windDirection: 80,
                precipitationChance: 0.15
            )
        }

        let daily = makeMockDaily(from: current, days: 7)
        return WeatherPackage(current: current, daily: daily)
    }

    private func makeMockDaily(from current: WeatherModel, days: Int) -> [DailyForecastItem] {
        let cal = Calendar.current
        let baseHigh = Int(current.highTemperature.rounded())
        let baseLow = Int(current.lowTemperature.rounded())

        func conditionForDay(_ i: Int) -> WeatherModel.WeatherCondition {
            switch current.condition {
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

        return (0..<days).compactMap { i in
            guard let date = cal.date(byAdding: .day, value: i, to: Date()) else { return nil }
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

    private func randomStyleByTime() -> MockStyle {
        let t = Int(Date().timeIntervalSince1970)
        switch t % 5 {
        case 0: return .warmClear
        case 1: return .mildCloudy
        case 2: return .rainy
        case 3: return .snowy
        default: return .stormy
        }
    }
}
