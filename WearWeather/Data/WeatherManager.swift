// Data/WeatherManager.swift
import Foundation
import WeatherKit
import CoreLocation

class WeatherManager {
    static let shared = WeatherManager()
    private let service = WeatherService()
    
    private init() {}
    
    func getWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let weather = try await service.weather(for: location)
        
        let currentWeather = weather.currentWeather
        let dailyForecast = weather.dailyForecast.first
        
        // 애플의 날씨 상태를 변환
        let myCondition = mapCondition(from: currentWeather.condition)
        
        return WeatherModel(
            temperature: currentWeather.temperature.value,
            condition: myCondition,
            highTemperature: dailyForecast?.highTemperature.value ?? 0.0,
            lowTemperature: dailyForecast?.lowTemperature.value ?? 0.0
        )
    }
    
    // 👇 여기가 중요! 입력받는 타입 앞에 'WeatherKit.'을 붙여서 애플 거라고 딱 정해줍니다.
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
