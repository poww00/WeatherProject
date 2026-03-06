import SwiftUI
import WidgetKit

private struct WidgetHint: Equatable {
    let emoji: String
    let text: String
    var badgeText: String { "\(emoji) \(text)" }
}

struct WearWeatherWidgetView: View {
    let entry: WearWeatherEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall: systemSmallView
        case .systemMedium: systemMediumView
        case .accessoryRectangular: accessoryRectangularView
        case .accessoryCircular: accessoryCircularView
        case .accessoryInline: accessoryInlineView
        default: systemSmallView
        }
    }
}

private extension WearWeatherWidgetView {

    var temperatureText: String { "\(entry.snapshot.temperature)°" }

    var summaryText: String {
        let weather = WeatherModel(
            temperature: Double(entry.snapshot.temperature),
            condition: entry.snapshot.condition,
            highTemperature: Double(entry.snapshot.highTemperature),
            lowTemperature: Double(entry.snapshot.lowTemperature),
            aqi: entry.snapshot.aqi
        )
        return OutfitSummaryBuilder.makeWidgetSummary(weather: weather, outfit: entry.snapshot.outfit)
    }

    var aqiLineText: String? {
        guard let aqi = entry.snapshot.aqi else { return nil }
        return "AQI \(aqi) · \(entry.snapshot.aqiStatusText ?? "--")"
    }

    var isBadAir: Bool {
        if let aqi = entry.snapshot.aqi { return aqi >= 101 }
        return entry.snapshot.outfit.hasMask
    }

    var hint: WidgetHint? {
        if isBadAir { return WidgetHint(emoji: "😷", text: "마스크") }

        if let acc = entry.snapshot.outfit.accessory {
            let lower = acc.lowercased()
            if lower.contains("umbrella") || lower.contains("umb") { return WidgetHint(emoji: "☔️", text: "우산") }
            if lower.contains("glove") { return WidgetHint(emoji: "🧤", text: "장갑") }
            if lower.contains("muffler") { return WidgetHint(emoji: "🧣", text: "목도리") }
            if lower.contains("cap") { return WidgetHint(emoji: "🧢", text: "모자") }
        }

        switch entry.snapshot.condition {
        case .rain, .storm: return WidgetHint(emoji: "☔️", text: "우산")
        case .snow: return WidgetHint(emoji: "🧤", text: "장갑")
        default: return nil
        }
    }

    func badge(text: String, compactText: String? = nil, font: Font = .caption2) -> some View {
        ViewThatFits(in: .horizontal) {
            Text(text)
                .font(font.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule(style: .continuous).fill(Color.black.opacity(0.12)))
                .overlay(Capsule(style: .continuous).stroke(Color.black.opacity(0.10), lineWidth: 0.5))

            if let compactText {
                Text(compactText)
                    .font(font.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule(style: .continuous).fill(Color.black.opacity(0.12)))
                    .overlay(Capsule(style: .continuous).stroke(Color.black.opacity(0.10), lineWidth: 0.5))
            }
        }
        .foregroundStyle(.primary)
    }

    var systemSmallView: some View {
        GeometryReader { geo in
            let size = geo.size
            let minSide = min(size.width, size.height)

            let outerPadding = max(6, minSide * 0.055)
            let vSpacing = max(4, minSide * 0.032)

            let headerFontSize = max(11, minSide * 0.082)
            let tempFontSize = max(22, minSide * 0.275)
            let summaryFontSize = max(10, minSide * 0.068)

            let hasAQI = (entry.snapshot.aqi != nil)
            let avatarHeight = max(62, size.height * (hasAQI ? 0.50 : 0.54))

            VStack(spacing: vSpacing) {

                HStack(alignment: .firstTextBaseline) {
                    Text(entry.snapshot.locationName)
                        .font(.system(size: headerFontSize, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer(minLength: 6)

                    Text(entry.snapshot.condition.emoji)
                        .font(.system(size: headerFontSize))
                }

                OutfitAvatarWidgetView(outfit: entry.snapshot.outfit, style: .standard)
                    .frame(maxWidth: .infinity)
                    .frame(height: avatarHeight)
                    .padding(.horizontal, max(2, minSide * 0.01))

                VStack(alignment: .leading, spacing: max(2, minSide * 0.014)) {
                    Text(temperatureText)
                        .font(.system(size: tempFontSize, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)

                    Text(summaryText)
                        .font(.system(size: summaryFontSize, weight: .semibold))
                        .opacity(0.86)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    if let aqiLineText {
                        badge(text: aqiLineText, compactText: "AQI")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(outerPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    var systemMediumView: some View {
        HStack(spacing: 12) {
            OutfitAvatarWidgetView(outfit: entry.snapshot.outfit, style: .standard)
                .frame(width: 160)

            VStack(alignment: .leading, spacing: 6) {

                HStack(alignment: .firstTextBaseline) {
                    Text(entry.snapshot.locationName)
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 6)
                    Text(entry.snapshot.condition.emoji).font(.caption)
                }

                Text(temperatureText)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.85)

                Text(summaryText)
                    .font(.caption)
                    .opacity(0.86)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 6) {
                    if let aqiLineText { badge(text: aqiLineText, compactText: "AQI") }
                    if let hint { badge(text: hint.badgeText, compactText: hint.emoji) }
                    Spacer(minLength: 0)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .containerBackground(.fill.tertiary, for: .widget)
    }

    var accessoryRectangularView: some View {
        HStack(spacing: 10) {
            OutfitAvatarWidgetView(outfit: entry.snapshot.outfit, style: .standard)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(entry.snapshot.locationName)
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Spacer(minLength: 6)
                    Text(entry.snapshot.condition.emoji).font(.caption2)
                }

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(temperatureText)
                        .font(.headline.weight(.heavy))
                        .monospacedDigit()
                        .layoutPriority(2)

                    Text(summaryText)
                        .font(.caption2)
                        .opacity(0.85)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .layoutPriority(1)

                    Spacer(minLength: 6)

                    if isBadAir {
                        badge(text: "AQI \(entry.snapshot.aqiStatusText ?? "나쁨")", compactText: "AQI")
                    } else if let hint {
                        badge(text: hint.badgeText, compactText: hint.emoji)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .containerBackground(.fill.tertiary, for: .widget)
    }

    var accessoryCircularView: some View {
        GeometryReader { geo in
            let minSide = min(geo.size.width, geo.size.height)

            ZStack(alignment: .bottom) {
                OutfitAvatarWidgetView(outfit: entry.snapshot.outfit, style: .circular)
                    .frame(width: minSide * 0.92, height: minSide * 0.92)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.48)

                Text(temperatureText)
                    .font(.system(size: max(10, minSide * 0.22), weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .padding(.bottom, max(2, minSide * 0.06))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    var accessoryInlineView: some View {
        Text("\(entry.snapshot.locationName) \(temperatureText) · \(summaryText)")
            .lineLimit(1)
    }
}

private extension WeatherModel.WeatherCondition {
    var emoji: String {
        switch self {
        case .clear: "☀️"
        case .cloudy: "☁️"
        case .rain: "🌧️"
        case .snow: "❄️"
        case .storm: "⛈️"
        }
    }

    var shortText: String {
        switch self {
        case .clear: "맑음"
        case .cloudy: "흐림"
        case .rain: "비"
        case .snow: "눈"
        case .storm: "폭풍"
        }
    }
}
