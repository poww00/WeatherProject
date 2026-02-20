import WidgetKit
import SwiftUI

struct WearWeatherWidget: Widget {
    let kind: String = "WearWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WearWeatherWidgetView(entry: entry)
        }
        .configurationDisplayName("WearWeather")
        .description("현재 날씨와 코디를 한눈에 보여줘.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,              // ✅ 추가
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline
        ])
    }
}
