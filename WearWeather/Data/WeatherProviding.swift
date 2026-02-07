import Foundation
import CoreLocation

protocol WeatherProviding {
    func getWeather(latitude: Double, longitude: Double) async throws -> WeatherModel
}
