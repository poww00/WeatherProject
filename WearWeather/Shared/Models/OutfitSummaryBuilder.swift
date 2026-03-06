import Foundation

enum OutfitSummaryBuilder {

    // MARK: - Backward Compatibility
    // 기존 호출부(OutfitSummaryBuilder.make)를 깨지 않게 유지
    static func make(weather: WeatherModel, outfit: ClothingModel) -> String {
        makeWidgetSummary(weather: weather, outfit: outfit)
    }

    // MARK: - App

    static func makeAppSummary(weather: WeatherModel, outfit: ClothingModel) -> String {
        var messages: [String] = []

        messages.append(primaryAppMessage(weather: weather, outfit: outfit))

        if let extra = extraAppAdvice(weather: weather, outfit: outfit) {
            messages.append(extra)
        }

        if messages.count >= 2 {
            return "\(messages[0]) \(messages[1])"
        } else {
            return messages[0]
        }
    }

    // MARK: - Widget

    static func makeWidgetSummary(weather: WeatherModel, outfit: ClothingModel) -> String {
        if weather.condition == .rain || weather.condition == .storm {
            return "우산 챙기기"
        }

        if weather.condition == .snow {
            return "따뜻하게 입기"
        }

        if outfit.hasMask || weather.isBadAir {
            return "마스크 챙기기"
        }

        if let outer = outfit.outer {
            switch outer {
            case "padding": return "패딩 추천"
            case "coat": return "코트 추천"
            case "jacket": return "자켓 추천"
            case "cardigan": return "가디건 추천"
            case "light_jacket": return "얇은 겉옷 추천"
            default: break
            }
        }

        switch outfit.top {
        case "tshirt_basic":
            if outfit.bottom == "shorts_basic" {
                return "반팔·반바지 추천"
            } else {
                return "반팔 차림 추천"
            }

        case "longsleeve":
            return "긴팔 차림 추천"

        case "knit":
            return "니트 추천"

        case "heattech":
            return "보온 옷차림 추천"

        case "sleeveless":
            return "시원한 옷차림 추천"

        default:
            let temp = Int(weather.temperature.rounded())
            if temp >= 27 {
                return "가벼운 옷차림 추천"
            } else if temp >= 20 {
                return "가볍게 입기 좋아요"
            } else if temp >= 12 {
                return "겉옷 하나 추천"
            } else {
                return "따뜻한 옷차림 추천"
            }
        }
    }

    // MARK: - App Primary

    private static func primaryAppMessage(weather: WeatherModel, outfit: ClothingModel) -> String {
        let temp = Int(weather.temperature.rounded())

        if let outer = outfit.outer {
            switch outer {
            case "padding":
                return "패딩 챙겨야 할 만큼 꽤 추워요"
            case "coat":
                return "코트 입기 좋은 쌀쌀한 날씨예요"
            case "jacket":
                return "자켓 걸치면 딱 좋은 날씨예요"
            case "cardigan":
                return "가디건 하나 걸치면 무난해요"
            case "light_jacket":
                return "얇은 겉옷 하나 챙기면 딱 좋아요"
            default:
                break
            }
        }

        switch outfit.top {
        case "tshirt_basic":
            if outfit.bottom == "shorts_basic" {
                return "가볍게 반팔·반바지로 괜찮아요"
            } else {
                return "반팔 차림으로도 무난한 날씨예요"
            }

        case "longsleeve":
            if temp >= 20 {
                return "긴팔 하나면 편하게 다니기 좋아요"
            } else {
                return "긴팔 차림이 잘 맞는 날씨예요"
            }

        case "knit":
            return "니트처럼 포근한 옷이 어울려요"

        case "heattech":
            return "히트텍처럼 보온성 있는 옷이 필요해요"

        case "sleeveless":
            return "민소매처럼 시원한 옷차림이 잘 맞아요"

        default:
            if temp >= 27 {
                return "가볍고 시원한 옷차림을 추천해요"
            } else if temp >= 20 {
                return "너무 덥지도 춥지도 않아 입기 편해요"
            } else if temp >= 12 {
                return "가벼운 긴팔이나 겉옷이 잘 맞아요"
            } else {
                return "보온성 있는 옷차림이 좋아요"
            }
        }
    }

    // MARK: - App Extra

    private static func extraAppAdvice(weather: WeatherModel, outfit: ClothingModel) -> String? {
        if weather.condition == .rain || weather.condition == .storm {
            return "비 소식이 있어 우산 챙기는 걸 추천해요"
        }

        if weather.condition == .snow {
            return "눈 예보가 있어 따뜻하게 입는 게 좋아요"
        }

        if outfit.hasMask || weather.isBadAir {
            return "공기가 탁해 마스크를 챙기면 좋아요"
        }

        if let acc = outfit.accessory?.lowercased() {
            if acc.contains("umbrella") || acc.contains("umb") {
                return "우산 하나 챙기면 더 안심돼요"
            }
            if acc.contains("glove") {
                return "손이 시릴 수 있어 장갑이 있으면 좋아요"
            }
            if acc.contains("muffler") {
                return "목도리까지 하면 더 따뜻하게 다닐 수 있어요"
            }
            if acc.contains("cap") {
                return "가벼운 모자 하나 써도 잘 어울려요"
            }
        }

        switch outfit.shoes {
        case "rain_boots":
            return "젖지 않게 방수 신발이 잘 맞아요"
        case "winter_boots":
            return "발이 차가울 수 있어 부츠가 잘 어울려요"
        default:
            return nil
        }
    }
}
