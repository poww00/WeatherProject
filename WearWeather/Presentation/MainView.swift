import SwiftUI

struct MainView: View {

    @StateObject private var vm = MainViewModel()

    var body: some View {
        ZStack {
            // 1. 배경
            AppBackgroundView(condition: vm.weather?.condition)

            VStack(spacing: 16) {

                // 상단 헤더
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title2)
                        .foregroundColor(.white)

                    Text(vm.locationName)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        vm.manualRefresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // 중앙 캐릭터 + 온도
                VStack(spacing: 10) {
                    ZStack {
                        // (지금은 도형 캐릭터 그대로 유지)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 220, height: 260)

                        VStack(spacing: 12) {
                            // 얼굴
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 70, height: 70)

                            // 상의(더미)
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 140, height: 70)

                            // 하의(더미)
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 120, height: 55)
                        }
                    }

                    Text(vm.weather?.tempString ?? "--°")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(.white)

                    // 최고/최저 + 상태
                    HStack(spacing: 10) {
                        if let w = vm.weather {
                            Text("H \(Int(w.highTemperature))°")
                                .foregroundColor(.white.opacity(0.9))
                            Text("L \(Int(w.lowTemperature))°")
                                .foregroundColor(.white.opacity(0.9))
                            Text("· \(conditionText(w.condition))")
                                .foregroundColor(.white.opacity(0.9))
                        } else {
                            Text("날씨 불러오는 중")
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .font(.headline)
                }

                // 추천 코디 카드
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("오늘 코디")
                            .font(.headline)

                        Spacer()

                        if vm.isLoading {
                            ProgressView()
                        }
                    }

                    // 코디 태그들(일단 문자열로 확인 가능하게)
                    WrapTags(tags: outfitTags(vm.outfit))

                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.92))
                .cornerRadius(18)
                .padding(.horizontal)

                // 하단 Hourly Forecast (일단은 기존 더미 유지)
                VStack(alignment: .leading) {
                    Text("Hourly Forecast")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(vm.hourly) { item in
                                VStack(spacing: 8) {
                                    Text(item.hourText)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Image(systemName: symbolName(for: item.condition))
                                        .font(.title2)

                                    Text("\(item.temperature)°")
                                        .font(.headline)
                                }
                                .padding()
                                .background(Color.white.opacity(0.85))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
        }
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
}

// MARK: - 작은 유틸 UI(태그 래핑)
private struct WrapTags: View {
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 간단 래핑(두 줄 이상이면 자동 줄바꿈)
            FlexibleView(data: tags, spacing: 8, alignment: .leading) { tag in
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

private struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(data: Data,
         spacing: CGFloat = 8,
         alignment: HorizontalAlignment = .leading,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
        .frame(minHeight: 0)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
            ForEach(Array(data), id: \.self) { element in
                content(element)
                    .padding(.all, spacing / 2)
                    .alignmentGuide(.leading) { d in
                        if width + d.width > geometry.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        width += d.width
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        return result
                    }
            }
        }
    }
}
