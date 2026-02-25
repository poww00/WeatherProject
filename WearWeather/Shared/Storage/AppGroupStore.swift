import Foundation

enum AppGroupStore {

    static func save<T: Codable>(_ value: T, key: String, suiteName: String) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        do {
            let data = try JSONEncoder().encode(value)
            defaults.set(data, forKey: key)
        } catch {
            // ignore
        }
    }

    static func read<T: Codable>(key: String, suiteName: String, as type: T.Type) -> T? {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return nil }
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    // ✅ Raw Int 저장(override 같은 단순값용)
    static func saveRawInt(_ value: Int, key: String, suiteName: String) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.set(value, forKey: key)
    }

    // ✅ Raw Int 읽기
    static func read(key: String, suiteName: String, as type: Int.Type) -> Int? {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return nil }
        return defaults.object(forKey: key) as? Int
    }

    // ✅ Key 삭제
    static func remove(key: String, suiteName: String) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.removeObject(forKey: key)
    }
}
