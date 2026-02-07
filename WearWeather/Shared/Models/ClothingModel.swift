import Foundation

struct ClothingModel: Codable, Equatable {
    let top: String
    let bottom: String
    let outer: String?
    let accessory: String?
    let hasMask: Bool

    static let `default` = ClothingModel(
        top: "tshirt_basic",
        bottom: "shorts_basic",
        outer: nil,
        accessory: nil,
        hasMask: false
    )
}
