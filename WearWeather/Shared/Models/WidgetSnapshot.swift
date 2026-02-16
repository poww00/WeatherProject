import Foundation

/// 위젯이 읽어갈 “한 덩어리 스냅샷”
struct WidgetSnapshot: Codable, Equatable {
    let updatedAt: TimeInterval

    // UI에 필요한 최소 정보
    let locationName: String
    let temperature: Int
    let condition: WeatherModel.WeatherCondition
    let highTemperature: Int
    let lowTemperature: Int

    // 캐릭터/코디
    let outfit: ClothingModel

    // 공기질(있으면 표시)
    let aqi: Int?
    let aqiStatusText: String?

    // MARK: - Convenience

    var updatedDate: Date { Date(timeIntervalSince1970: updatedAt) }

    static func make(
        locationName: String,
        weather: WeatherModel,
        outfit: ClothingModel
    ) -> WidgetSnapshot {
        WidgetSnapshot(
            updatedAt: Date().timeIntervalSince1970,
            locationName: locationName,
            temperature: Int(weather.temperature.rounded()),
            condition: weather.condition,
            highTemperature: Int(weather.highTemperature.rounded()),
            lowTemperature: Int(weather.lowTemperature.rounded()),
            outfit: outfit,
            aqi: weather.aqi,
            aqiStatusText: (weather.aqi == nil) ? nil : weather.aqiStatusText
        )
    }
}

