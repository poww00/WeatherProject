import SwiftUI

struct MainView: View {

    @StateObject private var vm = MainViewModel()

    var body: some View {
        ZStack {
            AppBackgroundView(condition: vm.weather?.condition)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {

                    Spacer().frame(height: 70)

                    // ✅ 캐릭터(가슴: 현재온도 + H/L/상태)
                    OutfitAvatarView(
                        outfit: vm.outfit,
                        temperatureText: vm.weather?.tempString ?? "--°",
                        summaryText: summaryLine()
                    )
                    .padding(.bottom, 10)

                    // ✅ 섹션 간격 확보 (캐릭터 ↔ 아래 카드)
                    Spacer().frame(height: 6)

                    // ✅ 오늘 코디(디버그용)
                    #if DEBUG
                    sectionCard(title: "오늘 코디(디버그)", trailing: {
                        if vm.isLoading { ProgressView() }
                    }) {
                        WrapTags(tags: outfitTags(vm.outfit))

                        if let err = vm.errorMessage {
                            Text(err)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.top, 6)
                        }
                    }
                    .padding(.horizontal)
                    #endif

                    // ✅ Hourly Forecast
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

                    // ✅ Daily Forecast(7일) — UI 개선 핵심
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

    private func outfitTags(_ outfit: ClothingModel) -> [String] {
        var tags: [String] = []
        tags.append("상의: \(outfit.top)")
        tags.append("하의: \(outfit.bottom)")
        if let outer = outfit.outer { tags.append("아우터: \(outer)") }
        if let acc = outfit.accessory { tags.append("악세서리: \(acc)") }
        if outfit.hasMask { tags.append("마스크") }
        return tags
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

    // MARK: - UI blocks

    private func sectionCard<Content: View, Trailing: View>(
        title: String,
        @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.85))

                Spacer()

                trailing()
            }

            content()
        }
        .padding(16)
        .background(Color.white.opacity(0.92))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        sectionCard(title: title, trailing: { EmptyView() }, content: content)
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

    private var globalMin: Double {
        daily.map { $0.lowTemperature }.min() ?? 0
    }

    private var globalMax: Double {
        daily.map { $0.highTemperature }.max() ?? 0
    }

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
            // 요일
            Text(dayText)
                .font(.headline)
                .foregroundColor(.black.opacity(0.85))
                .frame(width: 44, alignment: .leading)

            // 아이콘
            Image(systemName: symbol)
                .font(.title3)
                .foregroundColor(.black.opacity(0.75))
                .frame(width: 24)

            // 막대(최저~최고)
            TemperatureBar(
                low: low,
                high: high,
                globalMin: globalMin,
                globalMax: globalMax
            )
            .frame(height: 10)

            // H/L 숫자
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

// MARK: - Tags UI

private struct WrapTags: View {
    let tags: [String]

    private let columns = [
        GridItem(.adaptive(minimum: 90), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.black.opacity(0.06))
                    .cornerRadius(999)
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
