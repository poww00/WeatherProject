import Foundation

enum AppConfig {

    /// ✅ mock 사용 여부 (기존에 쓰던 그대로 유지)
    static let useMockWeather: Bool = true

    /// ✅ 너가 직접 바꿔야 하는 값
    /// Xcode -> Signing & Capabilities -> App Groups 에 있는 그 ID랑 똑같이 맞춰야 함
    static let appGroupId: String = "group.ClothWeather.WearWeathe"

    /// 위젯 스냅샷 저장 키(버전 올리고 싶으면 v1→v2)
    static let widgetSnapshotKey: String = "WearWeather.widgetSnapshot.v1"
}
