import Foundation

struct DailyForecastItem: Identifiable, Codable, Equatable {
    let date: Date
    let highTemperature: Double
    let lowTemperature: Double
    let condition: WeatherModel.WeatherCondition

    var id: TimeInterval { date.timeIntervalSince1970 }

    var dayText: String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "오늘" }
        if cal.isDateInTomorrow(date) { return "내일" }

        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "E" // 월/화/수...
        return df.string(from: date)
    }
}

