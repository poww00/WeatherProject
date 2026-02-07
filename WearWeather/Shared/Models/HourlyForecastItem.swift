import Foundation

struct HourlyForecastItem: Identifiable, Equatable {
    let id = UUID()
    let hourText: String   // "1시"
    let temperature: Int   // 22
    let condition: WeatherModel.WeatherCondition
}
