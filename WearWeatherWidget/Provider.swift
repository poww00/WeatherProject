import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> WearWeatherEntry {
        WearWeatherEntry(date: Date(), snapshot: mockSnapshot())
    }

    func getSnapshot(in context: Context, completion: @escaping (WearWeatherEntry) -> Void) {
        completion(WearWeatherEntry(date: Date(), snapshot: mockSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WearWeatherEntry>) -> Void) {
        // ✅ Personal Team: App Groups가 막히는 경우 많아서 mock으로 고정
        // 나중에 유료 + App Groups 가능해지면 여기서 loadSnapshot() 쓰면 됨.
        let entry = WearWeatherEntry(date: Date(), snapshot: mockSnapshot())

        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())
        ?? Date().addingTimeInterval(1800)

        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    // MARK: - Mock
    private func mockSnapshot() -> WidgetSnapshot {
        return WidgetSnapshot(
            updatedAt: Date().timeIntervalSince1970,
            locationName: "서울",
            temperature: 7,
            condition: .cloudy,
            highTemperature: 10,
            lowTemperature: 2,
            outfit: ClothingModel(
                top: "hoodie",
                bottom: "jeans",
                outer: "padding",
                accessory: "umbrella",
                shoes: "sneakers",
                hasMask: true
              ),
            aqi: 145,
            aqiStatusText: "나쁨"
        )
    }
}
