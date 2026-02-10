import Foundation

struct ClothingModel: Codable, Equatable {
    let top: String
    let bottom: String
    let outer: String?
    let accessory: String?
    let shoes: String          // ✅ 추가
    let hasMask: Bool

    static let `default` = ClothingModel(
        top: "tshirt_basic",
        bottom: "shorts_basic",
        outer: nil,
        accessory: nil,
        shoes: "shoes_basic",   // ✅ 기본 신발
        hasMask: false
    )
}
