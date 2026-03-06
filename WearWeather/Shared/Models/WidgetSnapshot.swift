import Foundation

/// 위젯이 읽어갈 “한 덩어리 스냅샷”
/// - 앱/위젯 공통 파이프라인(mock/실연동)에서 생성
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

    // 코디 한 줄 요약(주로 위젯용 짧은 문구)
    let outfitSummary: String

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
        let summary = OutfitSummaryBuilder.makeWidgetSummary(weather: weather, outfit: outfit)

        return WidgetSnapshot(
            updatedAt: Date().timeIntervalSince1970,
            locationName: locationName,
            temperature: Int(weather.temperature.rounded()),
            condition: weather.condition,
            highTemperature: Int(weather.highTemperature.rounded()),
            lowTemperature: Int(weather.lowTemperature.rounded()),
            outfit: outfit,
            outfitSummary: summary,
            aqi: weather.aqi,
            aqiStatusText: (weather.aqi == nil) ? nil : weather.aqiStatusText
        )
    }
}
