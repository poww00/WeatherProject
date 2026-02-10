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
        var shoes = "shoes_basic"
        var hasMask = false

        // 1) 특수 상황(비/눈/폭풍) 우선 처리
        switch condition {
        case .rain:
            accessory = "umbrella"
            shoes = "rain_boots"      // ✅ 비: 레인부츠
            if temp < 18 { outer = "light_jacket" }

        case .snow:
            accessory = "gloves"
            shoes = "winter_boots"    // ✅ 눈: 방한부츠
            if temp < 5 { outer = "padding" }

        case .storm:
            accessory = "umbrella"
            shoes = "rain_boots"      // ✅ 폭풍: 레인부츠
            if temp < 10 { outer = "padding" }

        default:
            break
        }

        // 2) 온도 구간별 “국룰” 추천
        switch temp {
        case ..<5:
            top = "heattech"
            bottom = "pants_thick"
            outer = outer ?? "padding"
            accessory = accessory ?? "muffler"
            shoes = shoes == "shoes_basic" ? "winter_boots" : shoes

        case 5..<10:
            top = "knit"
            bottom = "pants_basic"
            outer = outer ?? "coat"
            shoes = shoes == "shoes_basic" ? "sneakers" : shoes

        case 10..<15:
            top = "longsleeve"
            bottom = "pants_basic"
            outer = outer ?? "jacket"
            shoes = shoes == "shoes_basic" ? "sneakers" : shoes

        case 15..<20:
            top = "longsleeve"
            bottom = "pants_basic"
            outer = outer ?? "cardigan"
            shoes = shoes == "shoes_basic" ? "sneakers" : shoes

        case 20..<24:
            top = "tshirt_basic"
            bottom = "pants_light"
            shoes = shoes == "shoes_basic" ? "sneakers" : shoes

        case 24..<28:
            top = "tshirt_basic"
            bottom = "shorts_basic"
            shoes = shoes == "shoes_basic" ? "sandals" : shoes

        default: // 28 이상
            top = "sleeveless"
            bottom = "shorts_basic"
            accessory = accessory ?? "cap"
            shoes = shoes == "shoes_basic" ? "sandals" : shoes
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
            shoes: shoes,         // ✅ 반환에 포함
            hasMask: hasMask
        )
    }
}
