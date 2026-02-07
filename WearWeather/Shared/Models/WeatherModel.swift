import Foundation

struct WeatherModel: Codable, Equatable {
    let temperature: Double
    let condition: WeatherCondition
    let highTemperature: Double
    let lowTemperature: Double

    enum WeatherCondition: String, Codable, Equatable {
        case clear
        case cloudy
        case rain
        case snow
        case storm
    }

    var tempString: String {
        "\(Int(temperature))°"
    }
}
