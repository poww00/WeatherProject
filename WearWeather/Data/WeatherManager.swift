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

        let current = weather.currentWeather

        // 오늘 최고/최저(없으면 0)
        let today = weather.dailyForecast.first

        // ✅ 강수확률: “현재~다음 1시간” 기준으로 hourlyForecast 첫 요소
        let firstHour = weather.hourlyForecast.first
        let precipChance: Double? = firstHour?.precipitationChance

        let model = WeatherModel(
            temperature: current.temperature.value,
            condition: mapCondition(from: current.condition),
            highTemperature: today?.highTemperature.value ?? 0.0,
            lowTemperature: today?.lowTemperature.value ?? 0.0,

            // ✅ 상세값 매핑(WeatherKit)
            feelsLike: current.apparentTemperature.value,
            humidity: current.humidity, // 0~1
            windSpeed: current.wind.speed.value, // 기본 m/s
            windDirection: current.wind.direction.value,
            precipitationChance: precipChance
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

        return WeatherPackage(current: model, daily: dailyItems)
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
