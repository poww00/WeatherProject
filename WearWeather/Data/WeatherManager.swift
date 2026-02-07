import Foundation
import WeatherKit
import CoreLocation

final class WeatherManager: WeatherProviding {
    static let shared = WeatherManager()
    private let service = WeatherService()
    
    private init() {}
    
    func getWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let weather = try await service.weather(for: location)

        let currentWeather = weather.currentWeather
        let dailyForecast = weather.dailyForecast.first

        let myCondition = mapCondition(from: currentWeather.condition)

        return WeatherModel(
            temperature: currentWeather.temperature.value,
            condition: myCondition,
            highTemperature: dailyForecast?.highTemperature.value ?? 0.0,
            lowTemperature: dailyForecast?.lowTemperature.value ?? 0.0
        )
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
