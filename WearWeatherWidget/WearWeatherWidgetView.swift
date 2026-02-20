import SwiftUI
import WidgetKit

struct WearWeatherWidgetView: View {
    let entry: WearWeatherEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            systemSmallView
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryCircular:
            accessoryCircularView
        case .accessoryInline:
            accessoryInlineView
        default:
            systemSmallView
        }
    }
}

// MARK: - Layouts
private extension WearWeatherWidgetView {

    // 공통 텍스트
    var temperatureText: String {
        "\(Int(entry.snapshot.temperature))°"
    }

    var summaryText: String {
        // 예: "H 10° L 2° · 흐림"
        let h = Int(entry.snapshot.highTemperature)
        let l = Int(entry.snapshot.lowTemperature)
        let cond = entry.snapshot.condition.shortText
        return "H \(h)°  L \(l)° · \(cond)"
    }

    var systemSmallView: some View {
        ZStack {
            Color.clear

            VStack(spacing: 8) {
                HStack {
                    Text(entry.snapshot.locationName)
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Text(entry.snapshot.condition.emoji)
                        .font(.caption)
                }

                // ✅ 변경된 init 시그니처에 맞춤
                OutfitAvatarView(
                    outfit: entry.snapshot.outfit,
                    temperatureText: temperatureText,
                    summaryText: summaryText
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 6)

                // AQI (있으면 표시)
                if let aqi = entry.snapshot.aqi {
                    Text("AQI \(aqi) · \(entry.snapshot.aqiStatusText ?? "--")")
                        .font(.caption2)
                        .opacity(0.8)
                        .lineLimit(1)
                }
            }
            .padding(10)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    var accessoryRectangularView: some View {
        HStack(spacing: 10) {
            OutfitAvatarView(
                outfit: entry.snapshot.outfit,
                temperatureText: temperatureText,
                summaryText: summaryText
            )
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.snapshot.locationName)
                    .font(.caption2)
                    .lineLimit(1)
                    .opacity(0.9)

                Text(temperatureText)
                    .font(.headline)

                Text(summaryText)
                    .font(.caption2)
                    .opacity(0.85)
                    .lineLimit(1)

                if let aqi = entry.snapshot.aqi {
                    Text("AQI \(aqi) · \(entry.snapshot.aqiStatusText ?? "--")")
                        .font(.caption2)
                        .opacity(0.8)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .containerBackground(.fill.tertiary, for: .widget)
    }

    var accessoryCircularView: some View {
        ZStack {
            OutfitAvatarView(
                outfit: entry.snapshot.outfit,
                temperatureText: temperatureText,
                summaryText: summaryText
            )
            .padding(6)

            VStack {
                Spacer()
                Text(temperatureText)
                    .font(.caption).bold()
                    .padding(.bottom, 2)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    var accessoryInlineView: some View {
        Text("\(entry.snapshot.locationName) \(temperatureText) \(entry.snapshot.condition.emoji)")
    }
}

// MARK: - Condition helpers
private extension WeatherModel.WeatherCondition {

    var emoji: String {
        switch self {
        case .clear:  return "☀️"
        case .cloudy: return "☁️"
        case .rain:   return "🌧️"
        case .snow:   return "❄️"
        case .storm:  return "⛈️"
        }
    }

    var shortText: String {
        switch self {
        case .clear:  return "맑음"
        case .cloudy: return "흐림"
        case .rain:   return "비"
        case .snow:   return "눈"
        case .storm:  return "폭풍"
        }
    }
}
