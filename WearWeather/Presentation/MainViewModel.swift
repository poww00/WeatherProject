import Foundation
import Combine
import CoreLocation

@MainActor
final class MainViewModel: ObservableObject {

    @Published var locationName: String = "내 위치"
    @Published var weather: WeatherModel?
    @Published var outfit: ClothingModel = .default
    @Published var hourly: [HourlyForecastItem] = []
    @Published var daily: [DailyForecastItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var isBadAir: Bool = false

    private let locationManager = LocationManager()
    private let geocoder = CLGeocoder()
    private let weatherProvider: WeatherProviding
    private var cancellables = Set<AnyCancellable>()

    private let cacheKey = "WearWeather.cache.v5"
    private let cacheTTL: TimeInterval = 15 * 60

    struct CachePayload: Codable {
        let savedAt: TimeInterval
        let locationName: String
        let weather: WeatherModel
        let outfit: ClothingModel
        let daily: [DailyForecastItem]
        let isBadAir: Bool
    }

    init() {
        if AppConfig.useMockWeather {
            self.weatherProvider = MockWeatherProvider(style: .random)
        } else {
            self.weatherProvider = WeatherManager.shared
        }

        loadCacheIfValid()

        locationManager.$location
            .compactMap { $0 }
            .removeDuplicates(by: { lhs, rhs in lhs.distance(from: rhs) < 50 })
            .sink { [weak self] location in
                guard let self else { return }
                Task { await self.updateLocationName(for: location) }
                Task { await self.refreshWeather(using: location, force: false) }
            }
            .store(in: &cancellables)

        Task { await refreshWeather(using: nil, force: false) }
    }

    func manualRefresh() {
        Task { await refreshWeather(using: locationManager.location, force: true) }
    }

    private func refreshWeather(using location: CLLocation?, force: Bool) async {
        if !force, isCacheStillValid() {
            if let w = weather { self.hourly = makeMockHourly(from: w) }
            // 캐시로 들어온 경우에도 위젯 스냅샷 동기화(안전)
            saveWidgetSnapshotIfPossible()
            return
        }

        isLoading = true
        errorMessage = nil

        let lat = location?.coordinate.latitude ?? 37.5665
        let lon = location?.coordinate.longitude ?? 126.9780

        do {
            let pkg = try await weatherProvider.getWeatherPackage(latitude: lat, longitude: lon)

            let w = pkg.current
            self.weather = w
            self.daily = pkg.daily

            let badAir = w.isBadAir
            self.isBadAir = badAir

            let recommended = Stylist.shared.recommendOutfit(
                temp: w.temperature,
                condition: w.condition,
                isBadAir: badAir
            )
            self.outfit = recommended

            self.hourly = makeMockHourly(from: w)

            saveCache()

            // ✅ refresh 성공 시점에 위젯 스냅샷 저장
            saveWidgetSnapshotIfPossible()

        } catch {
            let ns = error as NSError
            self.errorMessage = "날씨 가져오기 실패: \(ns.localizedDescription)"
        }

        isLoading = false
    }

    private func saveWidgetSnapshotIfPossible() {
        guard let w = weather else { return }

        let snap = WidgetSnapshot.make(
            locationName: locationName,
            weather: w,
            outfit: outfit
        )

        AppGroupStore.save(
            snap,
            key: AppConfig.widgetSnapshotKey,
            suiteName: AppConfig.appGroupId
        )
    }

    private func makeMockHourly(from weather: WeatherModel) -> [HourlyForecastItem] {
        let base = Int(weather.temperature.rounded())
        let now = Calendar.current.component(.hour, from: Date())

        func tempOffset(_ i: Int) -> Int {
            let pattern = [-2, -1, 0, 1, 2, 1, 0, -1]
            return pattern[i % pattern.count]
        }

        func conditionForHour(_ i: Int) -> WeatherModel.WeatherCondition {
            switch weather.condition {
            case .storm: return (i % 3 == 0) ? .storm : .rain
            case .snow:  return (i % 4 == 0) ? .snow : .cloudy
            case .rain:  return (i % 4 == 0) ? .rain : .cloudy
            case .cloudy:return (i % 5 == 0) ? .cloudy : .clear
            case .clear: return .clear
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

    // MARK: - Cache

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
        self.daily = payload.daily
        self.isBadAir = payload.isBadAir
        self.hourly = makeMockHourly(from: payload.weather)

        // ✅ 캐시로 들어와도 위젯 스냅샷 동기화
        saveWidgetSnapshotIfPossible()
    }

    private func saveCache() {
        guard let weather else { return }
        let payload = CachePayload(
            savedAt: Date().timeIntervalSince1970,
            locationName: locationName,
            weather: weather,
            outfit: outfit,
            daily: daily,
            isBadAir: isBadAir
        )
        guard let data = try? JSONEncoder().encode(payload) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
    }
}
