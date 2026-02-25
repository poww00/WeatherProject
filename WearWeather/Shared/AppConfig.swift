import Foundation

enum AppConfig {

    /// ✅ mock 사용 여부
    static let useMockWeather: Bool = true

    /// ✅ App Groups 사용 여부 (오픈 직전까지 OFF)
    static let useAppGroupForWidget: Bool = false

    /// App Group ID (나중에 ON할 때만 의미 있음)
    static let appGroupId: String = "group.ClothWeather.WearWeathe"

    /// 위젯 스냅샷 저장 키
    static let widgetSnapshotKey: String = "WearWeather.widgetSnapshot.v1"

    /// ✅ (NEW) 디버그 시나리오 override 저장 키
    /// - App Groups OFF면 앱/위젯이 각각 따로 저장됨(샌드박스 분리)
    /// - App Groups ON되면 같은 키로 공유 가능
    static let mockScenarioOverrideKey: String = "WearWeather.mockScenarioOverride.v1"
}
