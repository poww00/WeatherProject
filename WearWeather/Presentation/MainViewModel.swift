import Foundation
import Combine
import CoreLocation
import WidgetKit

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

    /// ✅ (NEW) 현재 mock 시나리오 override
    @Published var debugScenarioOverride: WearWeatherMockPipeline.Scenario? = nil

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

            // ✅ 현재 override 로드
            self.debugScenarioOverride = WearWeatherMockPipeline.getScenarioOverride()

            // ✅ mock 데이터 적용
            applyMock(now: Date())
            return
        }

        // 실연동(나중)
        self.weatherProvider = WeatherManager.shared

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
        if AppConfig.useMockWeather {
            applyMock(now: Date())
        } else {
            Task { await refreshWeather(using: locationManager.location, force: true) }
        }
    }

    // MARK: - Debug Scenario Control (NEW)

    func setMockScenarioOverride(_ scenario: WearWeatherMockPipeline.Scenario) {
        WearWeatherMockPipeline.setScenarioOverride(scenario)
        self.debugScenarioOverride = scenario
        applyMock(now: Date())
    }

    func clearMockScenarioOverride() {
        WearWeatherMockPipeline.clearScenarioOverride()
        self.debugScenarioOverride = nil
        applyMock(now: Date())
    }

    // MARK: - Mock Pipeline

    private func applyMock(now: Date) {
        isLoading = true
        errorMessage = nil

        let loc = WearWeatherMockPipeline.locationName(now: now)
        let pkg = WearWeatherMockPipeline.makeWeatherPackage(now: now)
        let w = pkg.current

        self.locationName = loc
        self.weather = w
        self.daily = pkg.daily
        self.hourly = WearWeatherMockPipeline.makeHourly(now: now, current: w)

        let badAir = w.isBadAir
        self.isBadAir = badAir

        self.outfit = Stylist.shared.recommendOutfit(
            temp: w.temperature,
            condition: w.condition,
            isBadAir: badAir
        )

        // App Groups OFF여도 reload는 가능
        WidgetCenter.shared.reloadAllTimelines()

        isLoading = false
    }

    // MARK: - Real refresh (미래)

    private func refreshWeather(using location: CLLocation?, force: Bool) async {
        if !force, isCacheStillValid() {
            if let w = weather {
                self.hourly = WearWeatherMockPipeline.makeHourly(now: Date(), current: w)
            }
            WidgetCenter.shared.reloadAllTimelines()
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

            self.hourly = WearWeatherMockPipeline.makeHourly(now: Date(), current: w)

            saveCache()
            WidgetCenter.shared.reloadAllTimelines()

        } catch {
            let ns = error as NSError
            self.errorMessage = "날씨 가져오기 실패: \(ns.localizedDescription)"
        }

        isLoading = false
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
        self.hourly = WearWeatherMockPipeline.makeHourly(now: Date(), current: payload.weather)

        WidgetCenter.shared.reloadAllTimelines()
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
