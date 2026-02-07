import Foundation

final class Stylist {
    static let shared = Stylist()
    private init() {}

    /// temp: 섭씨 기준
    func recommendOutfit(
        temp: Double,
        condition: WeatherModel.WeatherCondition,
        isBadAir: Bool
    ) -> ClothingModel {

        // 기본값
        var top = "tshirt_basic"
        var bottom = "shorts_basic"
        var outer: String? = nil
        var accessory: String? = nil
        var hasMask = false

        // 1) 특수 상황(비/눈/폭풍) 우선 처리
        switch condition {
        case .rain:
            accessory = "umbrella"
            // 비 오면 얇은 아우터 추천(예시)
            if temp < 18 { outer = "light_jacket" }
        case .snow:
            accessory = "gloves"
            if temp < 5 { outer = "padding" }
        case .storm:
            accessory = "umbrella"
            if temp < 10 { outer = "padding" }
        default:
            break
        }

        // 2) 온도 구간별 “국룰” 추천
        // (너가 나중에 룰표로 바꿔도 이 구조가 제일 편함)
        switch temp {
        case ..<5:
            top = "heattech"
            bottom = "pants_thick"
            outer = outer ?? "padding"
            accessory = accessory ?? "muffler"
        case 5..<10:
            top = "knit"
            bottom = "pants_basic"
            outer = outer ?? "coat"
        case 10..<15:
            top = "longsleeve"
            bottom = "pants_basic"
            outer = outer ?? "jacket"
        case 15..<20:
            top = "longsleeve"
            bottom = "pants_basic"
            outer = outer ?? "cardigan"
        case 20..<24:
            top = "tshirt_basic"
            bottom = "pants_light"
        case 24..<28:
            top = "tshirt_basic"
            bottom = "shorts_basic"
        default: // 28 이상
            top = "sleeveless"
            bottom = "shorts_basic"
            accessory = accessory ?? "cap"
        }

        // 3) 미세먼지
        if isBadAir {
            hasMask = true
        }

        return ClothingModel(
            top: top,
            bottom: bottom,
            outer: outer,
            accessory: accessory,
            hasMask: hasMask
        )
    }
}
