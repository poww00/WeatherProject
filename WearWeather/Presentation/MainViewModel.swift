import Foundation
import Combine
import CoreLocation

@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - Published
    @Published var locationName: String = "내 위치"
    @Published var weather: WeatherModel?
    @Published var outfit: ClothingModel = .default
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let locationManager = LocationManager()
    private let geocoder = CLGeocoder()
    private let weatherProvider: WeatherProviding

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Cache (목데이터라도 캐시 흐름은 미리 유지해두면 위젯 붙일 때 편함)
    private let cacheKey = "WearWeather.cache.v1"
    private let cacheTTL: TimeInterval = 15 * 60 // 15분

    struct CachePayload: Codable {
        let savedAt: TimeInterval
        let locationName: String
        let weather: WeatherModel
        let outfit: ClothingModel
    }

    init() {
        // 1) 목데이터/실데이터 공급자 선택
        if AppConfig.useMockWeather {
            self.weatherProvider = MockWeatherProvider(style: .random)
        } else {
            // 나중에 WeatherKit 붙일 때 여기만 바꾸면 됨
            self.weatherProvider = WeatherManager.shared
        }

        // 2) 캐시 먼저 로드
        loadCacheIfValid()

        // 3) 위치 변화 구독(위치명 표시용)
        locationManager.$location
            .compactMap { $0 }
            .removeDuplicates(by: { lhs, rhs in
                lhs.distance(from: rhs) < 50
            })
            .sink { [weak self] location in
                guard let self else { return }
                Task { await self.updateLocationName(for: location) }

                // 목데이터 개발 단계에서는 위치 없어도 날씨를 보여줄 수 있게
                Task { await self.refreshWeather(using: location, force: false) }
            }
            .store(in: &cancellables)

        // 4) 앱 시작 시점에 위치가 아직 없더라도 mock 날씨는 바로 한 번 띄움
        Task { await refreshWeather(using: nil, force: false) }
    }

    // MARK: - Public
    func manualRefresh() {
        Task { await refreshWeather(using: locationManager.location, force: true) }
    }

    // MARK: - Core
    private func refreshWeather(using location: CLLocation?, force: Bool) async {
        if !force, isCacheStillValid() {
            return
        }

        isLoading = true
        errorMessage = nil

        // 위치가 없으면 임의 좌표(서울)로도 테스트 가능
        let lat = location?.coordinate.latitude ?? 37.5665
        let lon = location?.coordinate.longitude ?? 126.9780

        do {
            let w = try await weatherProvider.getWeather(latitude: lat, longitude: lon)
            self.weather = w

            // 미세먼지 연동은 나중에. 지금은 false로 기능 흐름만 확인
            let recommended = Stylist.shared.recommendOutfit(
                temp: w.temperature,
                condition: w.condition,
                isBadAir: false
            )
            self.outfit = recommended

            saveCache()
        } catch {
            let ns = error as NSError
            self.errorMessage = """
            날씨 가져오기 실패
            domain: \(ns.domain)
            code: \(ns.code)
            desc: \(ns.localizedDescription)
            """
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
            // 실패해도 앱 진행엔 지장 없음
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
