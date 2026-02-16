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

    // 상세값(optional)
    let feelsLike: Double?
    /// 0~1
    let humidity: Double?
    /// m/s
    let windSpeed: Double?
    /// degrees 0~360
    let windDirection: Double?
    /// 0~1
    let precipitationChance: Double?

    // ✅ 공기질(optional) — 지금은 Mock에서만 채움
    /// US AQI 기준 (0~500)
    let aqi: Int?
    /// PM2.5 µg/m³ (선택)
    let pm25: Double?

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

    // ✅ AQI 표시
    var aqiString: String {
        guard let v = aqi else { return "--" }
        return "\(v)"
    }

    var pm25String: String {
        guard let v = pm25 else { return "--" }
        // 소수점 0~1자리 정도만
        return String(format: "%.0f µg/m³", v)
    }

    /// AQI 상태 텍스트(한글)
    var aqiStatusText: String {
        guard let v = aqi else { return "--" }
        switch v {
        case 0...50: return "좋음"
        case 51...100: return "보통"
        case 101...150: return "나쁨"
        default: return "매우나쁨"
        }
    }

    /// 마스크 권장 기준(임시): AQI 101 이상이면 true
    var isBadAir: Bool {
        guard let v = aqi else { return false }
        return v >= 101
    }

    // MARK: - Helpers

    private func windDirectionText(_ degrees: Double) -> String {
        let dirs = ["N","NNE","NE","ENE","E","ESE","SE","SSE",
                    "S","SSW","SW","WSW","W","WNW","NW","NNW"]
        let normalized = (degrees.truncatingRemainder(dividingBy: 360) + 360)
            .truncatingRemainder(dividingBy: 360)
        let idx = Int((normalized / 22.5).rounded()) % 16
        return dirs[idx]
    }

    // init (기존 호출부 호환)
    init(
        temperature: Double,
        condition: WeatherCondition,
        highTemperature: Double,
        lowTemperature: Double,
        feelsLike: Double? = nil,
        humidity: Double? = nil,
        windSpeed: Double? = nil,
        windDirection: Double? = nil,
        precipitationChance: Double? = nil,
        aqi: Int? = nil,
        pm25: Double? = nil
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
        self.aqi = aqi
        self.pm25 = pm25
    }
}
