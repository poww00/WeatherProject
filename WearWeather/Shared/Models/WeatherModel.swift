// Shared/Models/WeatherModel.swift
import Foundation

struct WeatherModel: Codable {

    enum WeatherCondition: String, Codable {
        case clear, cloudy, rain, snow, storm
    }
    
    let temperature: Double
    let condition: WeatherCondition // 이제 내부의 WeatherCondition을 가리킴
    let highTemperature: Double
    let lowTemperature: Double
    
    var tempString: String {
        return String(format: "%.0f°", temperature)
    }
}
