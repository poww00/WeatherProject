import Foundation
import CoreLocation

struct WeatherPackage: Codable, Equatable {
    let current: WeatherModel
    let daily: [DailyForecastItem]
}

protocol WeatherProviding {
    func getWeatherPackage(latitude: Double, longitude: Double) async throws -> WeatherPackage
}

