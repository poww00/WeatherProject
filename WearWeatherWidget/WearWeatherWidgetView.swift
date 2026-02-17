import WidgetKit
import SwiftUI

struct WearWeatherWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WearWeatherEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallAvatarWidget
        case .accessoryRectangular:
            lockRectAvatarWidget
        default:
            smallAvatarWidget
        }
    }

    // MARK: - Home small (systemSmall): 캐릭터가 메인

    private var smallAvatarWidget: some View {
        let s = entry.snapshot

        return ZStack {
            Color.black.opacity(0.92)

            VStack(spacing: 8) {
                // 상단: 위치
                HStack {
                    Text(s.locationName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                    Spacer()
                }

                // 캐릭터 + 온도/요약 오버레이
                ZStack {
                    // ✅ 여기서 OutfitAvatarView를 그대로 사용
                    // (타겟 멤버십 반드시 위젯 체크!)
                    OutfitAvatarView(
                        outfit: s.outfit,
                        temperatureText: "\(s.temperature)°",
                        summaryText: "H \(s.highTemperature)°  L \(s.lowTemperature)° · \(conditionText(s.condition))"
                    )
                    .scaleEffect(0.85) // 위젯은 공간이 작아서 약간 줄임
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 하단: 공기질(짧게)
                HStack(spacing: 6) {
                    Image(systemName: "aqi.medium")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.70))

                    if let aqi = s.aqi, let txt = s.aqiStatusText {
                        Text("AQI \(aqi) \(txt)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.80))
                            .lineLimit(1)
                    } else {
                        Text("AQI --")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.60))
                    }

                    Spacer()

                    if (s.aqi ?? 0) >= 101 {
                        Text("😷")
                            .font(.caption)
                    }
                }
            }
            .padding(12)
        }
        .containerBackground(for: .widget) { Color.black.opacity(0.92) }
    }

    // MARK: - Lock screen rectangular: 가로형(캐릭터 + 핵심 정보)

    private var lockRectAvatarWidget: some View {
        let s = entry.snapshot

        return HStack(spacing: 10) {

            // 왼쪽: 캐릭터 미니
            OutfitAvatarView(
                outfit: s.outfit,
                temperatureText: nil,
                summaryText: nil
            )
            .scaleEffect(0.55)
            .frame(width: 60, height: 60)
            .clipped()

            // 오른쪽: 텍스트
            VStack(alignment: .leading, spacing: 2) {
                Text(s.locationName)
                    .font(.caption2)
                    .opacity(0.8)
                    .lineLimit(1)

                Text("\(s.temperature)° · \(conditionText(s.condition))")
                    .font(.headline)
                    .lineLimit(1)

                Text("H \(s.highTemperature)°  L \(s.lowTemperature)°")
                    .font(.caption2)
                    .opacity(0.75)
                    .lineLimit(1)
            }

            Spacer()

            // AQI + 마스크
            VStack(alignment: .trailing, spacing: 2) {
                if let aqi = s.aqi {
                    Text("AQI \(aqi)")
                        .font(.caption2)
                        .opacity(0.8)
                } else {
                    Text("AQI --")
                        .font(.caption2)
                        .opacity(0.7)
                }

                Text(s.aqiStatusText ?? "--")
                    .font(.caption2)
                    .opacity(0.8)

                if (s.aqi ?? 0) >= 101 {
                    Text("😷")
                        .font(.caption)
                }
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }

    private func conditionText(_ c: WeatherModel.WeatherCondition) -> String {
        switch c {
        case .clear: return "맑음"
        case .cloudy: return "흐림"
        case .rain: return "비"
        case .snow: return "눈"
        case .storm: return "폭풍"
        }
    }
}
