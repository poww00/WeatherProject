import Foundation

/// App Group UserDefaults에 JSON으로 저장/로드
enum AppGroupStore {

    static func save<T: Codable>(_ value: T, key: String, suiteName: String) {
        guard let ud = UserDefaults(suiteName: suiteName) else { return }
        do {
            let data = try JSONEncoder().encode(value)
            ud.set(data, forKey: key)
            ud.synchronize()
        } catch {
            // 일부러 조용히 실패(위젯용이라 앱 크래시 방지)
            // 필요하면 print(error)로 디버깅 가능
        }
    }

    static func load<T: Codable>(_ type: T.Type, key: String, suiteName: String) -> T? {
        guard let ud = UserDefaults(suiteName: suiteName) else { return nil }
        guard let data = ud.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    static func remove(key: String, suiteName: String) {
        guard let ud = UserDefaults(suiteName: suiteName) else { return }
        ud.removeObject(forKey: key)
        ud.synchronize()
    }
}

