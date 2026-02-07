import Foundation

final class MockWeatherProvider: WeatherProviding {

    enum MockStyle {
        case warmClear
        case mildCloudy
        case rainy
        case snowy
        case stormy
        case random
    }

    private var style: MockStyle

    init(style: MockStyle = .random) {
        self.style = style
    }

    func getWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        // 새로고침할 때마다 자연스럽게 바뀌게
        let pick = (style == .random) ? randomStyleByTime() : style

        switch pick {
        case .warmClear:
            return WeatherModel(
                temperature: 27,
                condition: .clear,
                highTemperature: 29,
                lowTemperature: 21
            )
        case .mildCloudy:
            return WeatherModel(
                temperature: 18,
                condition: .cloudy,
                highTemperature: 20,
                lowTemperature: 14
            )
        case .rainy:
            return WeatherModel(
                temperature: 16,
                condition: .rain,
                highTemperature: 17,
                lowTemperature: 12
            )
        case .snowy:
            return WeatherModel(
                temperature: -1,
                condition: .snow,
                highTemperature: 0,
                lowTemperature: -6
            )
        case .stormy:
            return WeatherModel(
                temperature: 12,
                condition: .storm,
                highTemperature: 13,
                lowTemperature: 8
            )
        case .random:
            // 위에서 이미 처리됨
            return WeatherModel(
                temperature: 20,
                condition: .cloudy,
                highTemperature: 22,
                lowTemperature: 16
            )
        }
    }

    private func randomStyleByTime() -> MockStyle {
        // 시간 기반으로 바뀌게 (테스트할 때 같은 값만 계속 나오지 않도록)
        let t = Int(Date().timeIntervalSince1970)
        switch t % 5 {
        case 0: return .warmClear
        case 1: return .mildCloudy
        case 2: return .rainy
        case 3: return .snowy
        default: return .stormy
        }
    }
}
