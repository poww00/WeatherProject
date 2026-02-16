import SwiftUI

struct MainView: View {

    @StateObject private var vm = MainViewModel()

    var body: some View {
        ZStack {
            AppBackgroundView(condition: vm.weather?.condition)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {

                    Spacer().frame(height: 70)

                    // 캐릭터(가슴: 현재온도 + H/L/상태)
                    OutfitAvatarView(
                        outfit: vm.outfit,
                        temperatureText: vm.weather?.tempString ?? "--°",
                        summaryText: summaryLine()
                    )
                    .padding(.bottom, 10)

                    Spacer().frame(height: 6)

                    // Hourly Forecast
                    sectionCard(title: "Hourly Forecast") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(vm.hourly) { item in
                                    HourlyCard(
                                        hourText: item.hourText,
                                        symbol: symbolName(for: item.condition),
                                        temp: item.temperature
                                    )
                                }
                            }
                            .padding(.horizontal, 2)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal)

                    // Daily Forecast
                    sectionCard(title: "Daily Forecast") {
                        if vm.daily.isEmpty {
                            VStack(spacing: 10) {
                                ProgressView()
                                Text("주간 예보 불러오는 중…")
                                    .foregroundColor(.black.opacity(0.55))
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        } else {
                            DailyForecastList(daily: vm.daily)
                        }
                    }
                    .padding(.horizontal)

                    // ✅ Weather Details (NEW)
                    sectionCard(title: "Weather Details") {
                        WeatherDetailsGrid(weather: vm.weather)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 22)
                }
                .padding(.bottom, 24)
            }
            .modifier(AlwaysBounceIfPossible())
            .safeAreaInset(edge: .top) {
                header
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                    .background(Color.black.opacity(0.10).ignoresSafeArea())
                    .zIndex(999)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .font(.title2)
                .foregroundColor(.white)

            Text(vm.locationName)
                .font(.title3)
                .bold()
                .foregroundColor(.white)

            Spacer()

            Button { vm.manualRefresh() } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Helpers

    private func summaryLine() -> String? {
        guard let w = vm.weather else { return nil }
        return "H \(Int(w.highTemperature))°  L \(Int(w.lowTemperature))° · \(conditionText(w.condition))"
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

    private func symbolName(for c: WeatherModel.WeatherCondition) -> String {
        switch c {
        case .clear: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rain: return "cloud.rain.fill"
        case .snow: return "snowflake"
        case .storm: return "cloud.bolt.rain.fill"
        }
    }

    // MARK: - Card Style (기존 톤 유지)

    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.85))
                Spacer()
            }

            content()
        }
        .padding(16)
        .background(Color.white.opacity(0.92))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Weather Details Grid

private struct WeatherDetailsGrid: View {
    let weather: WeatherModel?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            detailCell(
                icon: "thermometer.medium",
                title: "체감온도",
                value: weather?.feelsLikeString ?? "--"
            )

            detailCell(
                icon: "drop.fill",
                title: "습도",
                value: weather?.humidityString ?? "--"
            )

            detailCell(
                icon: "wind",
                title: "바람",
                value: weather?.windString ?? "--"
            )

            detailCell(
                icon: "umbrella.fill",
                title: "강수확률",
                value: weather?.precipChanceString ?? "--"
            )
        }
    }

    private func detailCell(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 26)
                .foregroundColor(.black.opacity(0.75))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.55))
                Text(value)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.04))
        .cornerRadius(16)
    }
}

// MARK: - Hourly Card

private struct HourlyCard: View {
    let hourText: String
    let symbol: String
    let temp: Int

    var body: some View {
        VStack(spacing: 10) {
            Text(hourText)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.55))

            Image(systemName: symbol)
                .font(.title2)
                .foregroundColor(.black.opacity(0.75))

            Text("\(temp)°")
                .font(.headline)
                .foregroundColor(.black.opacity(0.85))
        }
        .frame(width: 72)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.85))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 5)
    }
}

// MARK: - Daily Forecast List (7일, 막대 UI)

private struct DailyForecastList: View {
    let daily: [DailyForecastItem]

    private var globalMin: Double { daily.map { $0.lowTemperature }.min() ?? 0 }
    private var globalMax: Double { daily.map { $0.highTemperature }.max() ?? 0 }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(daily) { d in
                DailyForecastRow(
                    dayText: d.dayText,
                    symbol: symbolName(for: d.condition),
                    low: d.lowTemperature,
                    high: d.highTemperature,
                    globalMin: globalMin,
                    globalMax: globalMax
                )
            }
        }
    }

    private func symbolName(for c: WeatherModel.WeatherCondition) -> String {
        switch c {
        case .clear: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rain: return "cloud.rain.fill"
        case .snow: return "snowflake"
        case .storm: return "cloud.bolt.rain.fill"
        }
    }
}

private struct DailyForecastRow: View {
    let dayText: String
    let symbol: String
    let low: Double
    let high: Double
    let globalMin: Double
    let globalMax: Double

    var body: some View {
        HStack(spacing: 12) {
            Text(dayText)
                .font(.headline)
                .foregroundColor(.black.opacity(0.85))
                .frame(width: 44, alignment: .leading)

            Image(systemName: symbol)
                .font(.title3)
                .foregroundColor(.black.opacity(0.75))
                .frame(width: 24)

            TemperatureBar(
                low: low,
                high: high,
                globalMin: globalMin,
                globalMax: globalMax
            )
            .frame(height: 10)

            VStack(alignment: .trailing, spacing: 2) {
                Text("H \(Int(high))°")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.75))
                Text("L \(Int(low))°")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.55))
            }
            .frame(width: 64, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.04))
        .cornerRadius(16)
    }
}

private struct TemperatureBar: View {
    let low: Double
    let high: Double
    let globalMin: Double
    let globalMax: Double

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let range = max(globalMax - globalMin, 0.1)
            let startRatio = (low - globalMin) / range
            let endRatio = (high - globalMin) / range

            let startX = max(0, min(width, width * startRatio))
            let endX = max(0, min(width, width * endRatio))
            let barW = max(6, endX - startX)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.10))

                Capsule()
                    .fill(Color.black.opacity(0.35))
                    .frame(width: barW)
                    .offset(x: startX)
            }
        }
    }
}

// MARK: - iOS17+ bounce

private struct AlwaysBounceIfPossible: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.scrollBounceBehavior(.always)
        } else {
            content
        }
    }
}
