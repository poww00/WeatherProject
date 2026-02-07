import SwiftUI

struct AppBackgroundView: View {
    let condition: WeatherModel.WeatherCondition?

    var body: some View {
        ZStack {
            gradientBase

            switch condition {
            case .rain:
                CloudOverlay(intensity: 0.35)
                RainEffectView()
            case .snow:
                CloudOverlay(intensity: 0.25)
                SnowEffectView()
            case .storm:
                CloudOverlay(intensity: 0.45)
                RainEffectView(density: 1.2)
                LightningFlashView()
            case .cloudy:
                CloudOverlay(intensity: 0.25)
            case .clear, .none:
                // 맑음은 기본 그라데이션만
                EmptyView()
            }
        }
        .ignoresSafeArea()
    }

    private var gradientBase: some View {
        let c = condition ?? .clear
        switch c {
        case .clear:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(red: 0.35, green: 0.70, blue: 1.00),
                        Color(red: 0.55, green: 0.85, blue: 1.00)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .cloudy:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(red: 0.40, green: 0.65, blue: 0.90),
                        Color(red: 0.65, green: 0.80, blue: 0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .rain:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(red: 0.25, green: 0.45, blue: 0.70),
                        Color(red: 0.45, green: 0.65, blue: 0.80)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .snow:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(red: 0.70, green: 0.85, blue: 0.95),
                        Color(red: 0.90, green: 0.95, blue: 1.00)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .storm:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.22, blue: 0.35),
                        Color(red: 0.30, green: 0.45, blue: 0.55)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

// 흐림 오버레이(구름 낀 느낌)
private struct CloudOverlay: View {
    let intensity: Double

    var body: some View {
        Color.black
            .opacity(intensity)
            .blendMode(.overlay)
            .ignoresSafeArea()
    }
}

