import Foundation
import WeatherKit
import CoreLocation

final class WeatherManager: WeatherProviding {
    static let shared = WeatherManager()
    private let service = WeatherService()

    private init() {}

    func getWeatherPackage(latitude: Double, longitude: Double) async throws -> WeatherPackage {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let weather = try await service.weather(for: location)

        let currentWeather = weather.currentWeather
        let myCondition = mapCondition(from: currentWeather.condition)

        let today = weather.dailyForecast.first

        let current = WeatherModel(
            temperature: currentWeather.temperature.value,
            condition: myCondition,
            highTemperature: today?.highTemperature.value ?? 0.0,
            lowTemperature: today?.lowTemperature.value ?? 0.0
        )

        // ✅ 7일 예보(오늘 포함)
        let dailyItems: [DailyForecastItem] = weather.dailyForecast
            .prefix(7)
            .map { day in
                DailyForecastItem(
                    date: day.date,
                    highTemperature: day.highTemperature.value,
                    lowTemperature: day.lowTemperature.value,
                    condition: mapCondition(from: day.condition)
                )
            }

        return WeatherPackage(current: current, daily: dailyItems)
    }

    private func mapCondition(from condition: WeatherKit.WeatherCondition) -> WeatherModel.WeatherCondition {
        switch condition {
        case .clear, .mostlyClear, .hot:
            return .clear
        case .cloudy, .mostlyCloudy, .partlyCloudy, .haze, .foggy:
            return .cloudy
        case .rain, .drizzle, .heavyRain, .sunShowers:
            return .rain
        case .snow, .heavySnow, .flurries, .sunFlurries, .sleet, .freezingRain, .blowingSnow, .wintryMix:
            return .snow
        case .thunderstorms, .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms:
            return .storm
        default:
            return .clear
        }
    }
}
