import SwiftUI

struct MainView: View {

    @StateObject private var vm = MainViewModel()

    #if DEBUG
    @State private var showDebugPanel: Bool = false
    #endif

    var body: some View {
        let content = ZStack {
            AppBackgroundView(condition: vm.weather?.condition)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {

                    Spacer().frame(height: 70)

                    OutfitAvatarView(
                        outfit: vm.outfit,
                        temperatureText: vm.weather?.tempString ?? "--°",
                        summaryText: summaryLine()
                    )
                    .padding(.bottom, 10)

                    sectionCard(title: "Hourly Forecast") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(vm.hourly.enumerated()), id: \.offset) { _, item in
                                    WW_HourlyCard(
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

                    sectionCard(title: "Daily Forecast") {
                        WW_DailyForecastList(daily: vm.daily)
                    }
                    .padding(.horizontal)

                    sectionCard(title: "Weather Details") {
                        WW_WeatherDetailsGrid(weather: vm.weather)
                    }
                    .padding(.horizontal)

                    sectionCard(title: "Air Quality") {
                        WW_AirQualityRow(weather: vm.weather)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 22)
                }
                .padding(.bottom, 24)
            }
            .modifier(WW_AlwaysBounceIfPossible())
            .safeAreaInset(edge: .top) {
                header
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                    .background(Color.black.opacity(0.10).ignoresSafeArea())
                    .zIndex(999)
            }
        }

        #if DEBUG
        return AnyView(
            content.sheet(isPresented: $showDebugPanel) {
                WW_DebugScenarioSheet(vm: vm)
            }
        )
        #else
        return AnyView(content)
        #endif
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "mappin.and.ellipse")
                .font(.title2)
                .foregroundColor(.white)

            // ✅ Release 빌드에서는 디버그 제스처/배지를 아예 노출하지 않음
            #if DEBUG
            Text(vm.locationName)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
                .onLongPressGesture(minimumDuration: 0.6) {
                    guard AppConfig.useMockWeather else { return }
                    showDebugPanel = true
                }

            debugModeBadge
            #else
            Text(vm.locationName)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
            #endif

            Spacer()

            Button { vm.manualRefresh() } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(.white)
            }
        }
    }

    #if DEBUG
    private var debugModeBadge: some View {
        Group {
            guard AppConfig.useMockWeather else { return AnyView(EmptyView()) }

            let text: String
            if let s = vm.debugScenarioOverride {
                text = "LOCK: \(s.title)"
            } else {
                text = "AUTO"
            }

            return AnyView(
                Text(text)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white.opacity(0.92))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.16))
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 0.6)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            )
        }
    }
    #endif

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

#if DEBUG
// MARK: - Debug Sheet (DEBUG 빌드에서만 컴파일)

private struct WW_DebugScenarioSheet: View {
    @ObservedObject var vm: MainViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selected: WearWeatherMockPipeline.Scenario = .rainy

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Mock Scenario 고정")) {
                    if let current = vm.debugScenarioOverride {
                        HStack {
                            Text("현재 고정")
                            Spacer()
                            Text(current.title).bold()
                        }
                    } else {
                        Text("현재: 자동(시간 기반)")
                            .foregroundStyle(.secondary)
                    }

                    Picker("시나리오", selection: $selected) {
                        ForEach(WearWeatherMockPipeline.Scenario.allCases) { s in
                            Text(s.title).tag(s)
                        }
                    }
                }

                Section {
                    Button {
                        vm.setMockScenarioOverride(selected)
                    } label: {
                        Text("선택한 시나리오로 고정")
                    }

                    Button(role: .destructive) {
                        vm.clearMockScenarioOverride()
                    } label: {
                        Text("고정 해제(자동으로)")
                    }
                }

                Section(footer: Text("※ Debug 빌드 전용 기능. Release/TestFlight/App Store에서는 노출되지 않음.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Debug")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
            .onAppear {
                selected = vm.debugScenarioOverride ?? WearWeatherMockPipeline.currentScenario()
            }
        }
    }
}
#endif

// MARK: - Local UI Components (프로젝트 의존성 제거용)

private struct WW_HourlyCard: View {
    let hourText: String
    let symbol: String
    let temp: Int

    var body: some View {
        VStack(spacing: 10) {
            Text(hourText)
                .font(.caption)
                .foregroundColor(.black.opacity(0.60))

            Image(systemName: symbol)
                .font(.title3)
                .foregroundColor(.black.opacity(0.75))

            Text("\(temp)°")
                .font(.headline)
                .foregroundColor(.black.opacity(0.85))
                .monospacedDigit()
        }
        .frame(width: 72, height: 110)
        .background(Color.white.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
    }
}

private struct WW_DailyForecastList: View {
    let daily: [DailyForecastItem]

    var body: some View {
        if daily.isEmpty {
            VStack(spacing: 10) {
                ProgressView()
                Text("주간 예보 불러오는 중…")
                    .foregroundColor(.black.opacity(0.55))
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        } else {
            VStack(spacing: 10) {
                ForEach(Array(daily.enumerated()), id: \.offset) { _, d in
                    HStack {
                        Text(WW_DateFormat.dayString(d.date))
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.70))
                            .frame(width: 52, alignment: .leading)

                        Image(systemName: WW_Symbol.symbolName(for: d.condition))
                            .foregroundColor(.black.opacity(0.70))
                            .frame(width: 22)

                        Spacer()

                        Text("H \(Int(d.highTemperature))°")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.black.opacity(0.80))
                            .monospacedDigit()

                        Text("L \(Int(d.lowTemperature))°")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.60))
                            .monospacedDigit()
                            .frame(width: 54, alignment: .trailing)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.04))
                    .cornerRadius(14)
                }
            }
        }
    }
}

private struct WW_AirQualityRow: View {
    let weather: WeatherModel?

    var body: some View {
        let aqiText = weather?.aqiString ?? "--"
        let status = weather?.aqiStatusText ?? "--"
        let pm25 = weather?.pm25String ?? "--"

        HStack(spacing: 12) {
            Image(systemName: "aqi.medium")
                .font(.title2)
                .foregroundColor(.black.opacity(0.75))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text("대기질(AQI)")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.55))

                Text("\(status) · \(aqiText)")
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("PM2.5")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.55))
                Text(pm25)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.75))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.04))
        .cornerRadius(16)
    }
}

private struct WW_WeatherDetailsGrid: View {
    let weather: WeatherModel?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            cell(icon: "thermometer.medium", title: "체감온도", value: weather?.feelsLikeString ?? "--")
            cell(icon: "drop.fill", title: "습도", value: weather?.humidityString ?? "--")
            cell(icon: "wind", title: "바람", value: weather?.windString ?? "--")
            cell(icon: "umbrella.fill", title: "강수확률", value: weather?.precipChanceString ?? "--")
        }
    }

    private func cell(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.black.opacity(0.70))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.55))
                Text(value)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.85))
            }

            Spacer()
        }
        .padding(12)
        .background(Color.black.opacity(0.04))
        .cornerRadius(16)
    }
}

private enum WW_Symbol {
    static func symbolName(for c: WeatherModel.WeatherCondition) -> String {
        switch c {
        case .clear: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rain: return "cloud.rain.fill"
        case .snow: return "snowflake"
        case .storm: return "cloud.bolt.rain.fill"
        }
    }
}

private enum WW_DateFormat {
    static func dayString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "E"
        return f.string(from: date)
    }
}

private struct WW_AlwaysBounceIfPossible: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollBounceBehavior(.basedOnSize)
        } else {
            content
        }
    }
}
