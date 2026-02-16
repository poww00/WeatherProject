import Foundation

struct WeatherModel: Codable, Equatable {

    enum WeatherCondition: String, Codable, Equatable {
        case clear
        case cloudy
        case rain
        case snow
        case storm
    }

    // 기존 필드
    let temperature: Double
    let condition: WeatherCondition
    let highTemperature: Double
    let lowTemperature: Double

    // ✅ 상세값(optional)
    let feelsLike: Double?
    /// 0~1 (WeatherKit humidity가 보통 이 범위)
    let humidity: Double?
    /// m/s 기준 값으로 저장
    let windSpeed: Double?
    /// 도(degrees) 0~360
    let windDirection: Double?
    /// 0~1
    let precipitationChance: Double?

    // MARK: - Display strings

    var tempString: String { "\(Int(temperature.rounded()))°" }

    var feelsLikeString: String {
        guard let v = feelsLike else { return "--" }
        return "\(Int(v.rounded()))°"
    }

    var humidityString: String {
        guard let h = humidity else { return "--" }
        let pct = Int((h * 100).rounded())
        return "\(pct)%"
    }

    /// 풍향(16방위) + 풍속(m/s)
    var windString: String {
        guard let sp = windSpeed else { return "--" }
        let speedText = String(format: "%.1f m/s", sp)

        if let dir = windDirection {
            return "\(windDirectionText(dir)) · \(speedText)"
        } else {
            return speedText
        }
    }

    var precipChanceString: String {
        guard let p = precipitationChance else { return "--" }
        let pct = Int((p * 100).rounded())
        return "\(pct)%"
    }

    // MARK: - Helpers

    private func windDirectionText(_ degrees: Double) -> String {
        // 16방위 (N, NNE, NE...)
        let dirs = ["N","NNE","NE","ENE","E","ESE","SE","SSE",
                    "S","SSW","SW","WSW","W","WNW","NW","NNW"]
        let normalized = (degrees.truncatingRemainder(dividingBy: 360) + 360)
            .truncatingRemainder(dividingBy: 360)
        let idx = Int((normalized / 22.5).rounded()) % 16
        return dirs[idx]
    }

    // ✅ 기존 코드와 호환되게 기본 생성용 init 제공(상세값 nil)
    init(
        temperature: Double,
        condition: WeatherCondition,
        highTemperature: Double,
        lowTemperature: Double,
        feelsLike: Double? = nil,
        humidity: Double? = nil,
        windSpeed: Double? = nil,
        windDirection: Double? = nil,
        precipitationChance: Double? = nil
    ) {
        self.temperature = temperature
        self.condition = condition
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.feelsLike = feelsLike
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.precipitationChance = precipitationChance
    }
}
