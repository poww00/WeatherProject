import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> WearWeatherEntry {
        WearWeatherEntry(date: Date(), snapshot: WearWeatherMockPipeline.makeWidgetSnapshot())
    }

    func getSnapshot(in context: Context, completion: @escaping (WearWeatherEntry) -> Void) {
        completion(WearWeatherEntry(date: Date(), snapshot: WearWeatherMockPipeline.makeWidgetSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WearWeatherEntry>) -> Void) {
        let entry = WearWeatherEntry(date: Date(), snapshot: WearWeatherMockPipeline.makeWidgetSnapshot())

        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())
        ?? Date().addingTimeInterval(1800)

        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}
