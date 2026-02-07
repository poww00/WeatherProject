import Foundation
import Combine
import CoreLocation

@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - Published
    @Published var locationName: String = "내 위치"
    @Published var weather: WeatherModel?
    @Published var outfit: ClothingModel = .default
    @Published var hourly: [HourlyForecastItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let locationManager = LocationManager()
    private let geocoder = CLGeocoder()
    private let weatherProvider: WeatherProviding

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Cache
    private let cacheKey = "WearWeather.cache.v2"
    private let cacheTTL: TimeInterval = 15 * 60 // 15분

    struct CachePayload: Codable {
        let savedAt: TimeInterval
        let locationName: String
        let weather: WeatherModel
        let outfit: ClothingModel
    }

    init() {
        // 목데이터/실데이터 공급자 선택
        if AppConfig.useMockWeather {
            self.weatherProvider = MockWeatherProvider(style: .random)
        } else {
            self.weatherProvider = WeatherManager.shared
        }

        // 캐시 먼저 로드
        loadCacheIfValid()

        // 위치 구독
        locationManager.$location
            .compactMap { $0 }
            .removeDuplicates(by: { lhs, rhs in lhs.distance(from: rhs) < 50 })
            .sink { [weak self] location in
                guard let self else { return }
                Task { await self.updateLocationName(for: location) }
                Task { await self.refreshWeather(using: location, force: false) }
            }
            .store(in: &cancellables)

        // 시작 시점에도 mock은 바로 뿌리기
        Task { await refreshWeather(using: nil, force: false) }
    }

    func manualRefresh() {
        Task { await refreshWeather(using: locationManager.location, force: true) }
    }

    private func refreshWeather(using location: CLLocation?, force: Bool) async {
        if !force, isCacheStillValid() {
            // 캐시로 화면은 뜨니까 hourly만 맞춰서 다시 생성(앱 UX용)
            if let w = weather {
                self.hourly = makeMockHourly(from: w)
            }
            return
        }

        isLoading = true
        errorMessage = nil

        let lat = location?.coordinate.latitude ?? 37.5665
        let lon = location?.coordinate.longitude ?? 126.9780

        do {
            let w = try await weatherProvider.getWeather(latitude: lat, longitude: lon)
            self.weather = w

            let recommended = Stylist.shared.recommendOutfit(
                temp: w.temperature,
                condition: w.condition,
                isBadAir: false
            )
            self.outfit = recommended

            // ✅ Hourly 목데이터 생성
            self.hourly = makeMockHourly(from: w)

            saveCache()
        } catch {
            let ns = error as NSError
            self.errorMessage = "날씨 가져오기 실패: \(ns.localizedDescription)"
        }

        isLoading = false
    }

    private func makeMockHourly(from weather: WeatherModel) -> [HourlyForecastItem] {
        // 현재 온도를 중심으로 8개 생성(진짜처럼 흔들리게)
        let base = Int(weather.temperature.rounded())
        let now = Calendar.current.component(.hour, from: Date())

        func tempOffset(_ i: Int) -> Int {
            // -2 ~ +3 범위에서 자연스럽게 흔들림
            let pattern = [-2, -1, 0, 1, 2, 1, 0, -1]
            return pattern[i % pattern.count]
        }

        func conditionForHour(_ i: Int) -> WeatherModel.WeatherCondition {
            // 현재 condition 중심으로 약간만 변화(폭풍이면 비로 약화되는 느낌)
            switch weather.condition {
            case .storm:
                return (i % 3 == 0) ? .storm : .rain
            case .snow:
                return (i % 4 == 0) ? .snow : .cloudy
            case .rain:
                return (i % 4 == 0) ? .rain : .cloudy
            case .cloudy:
                return (i % 5 == 0) ? .cloudy : .clear
            case .clear:
                return .clear
            }
        }

        return (0..<8).map { i in
            let hour = (now + i + 1) % 24
            return HourlyForecastItem(
                hourText: "\(hour)시",
                temperature: base + tempOffset(i),
                condition: conditionForHour(i)
            )
        }
    }

    private func updateLocationName(for location: CLLocation) async {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let pm = placemarks.first {
                let name = pm.subLocality ?? pm.locality ?? pm.administrativeArea ?? "내 위치"
                self.locationName = name
            } else {
                self.locationName = "내 위치"
            }
        } catch {
            if self.locationName.isEmpty { self.locationName = "내 위치" }
        }
    }

    // MARK: - Cache helpers
    private func isCacheStillValid() -> Bool {
        guard
            let data = UserDefaults.standard.data(forKey: cacheKey),
            let payload = try? JSONDecoder().decode(CachePayload.self, from: data)
        else { return false }

        return Date().timeIntervalSince1970 - payload.savedAt <= cacheTTL
    }

    private func loadCacheIfValid() {
        guard
            let data = UserDefaults.standard.data(forKey: cacheKey),
            let payload = try? JSONDecoder().decode(CachePayload.self, from: data)
        else { return }

        let isValid = Date().timeIntervalSince1970 - payload.savedAt <= cacheTTL
        guard isValid else { return }

        self.locationName = payload.locationName
        self.weather = payload.weather
        self.outfit = payload.outfit
        self.hourly = makeMockHourly(from: payload.weather)
    }

    private func saveCache() {
        guard let weather else { return }
        let payload = CachePayload(
            savedAt: Date().timeIntervalSince1970,
            locationName: locationName,
            weather: weather,
            outfit: outfit
        )
        guard let data = try? JSONEncoder().encode(payload) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
    }
}
