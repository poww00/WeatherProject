// Domain/Stylist.swift
import Foundation

class Stylist {
    // 누구나 부를 수 있게 공유 (Singleton)
    static let shared = Stylist()
    
    private init() {}
    
    // 🧠 옷 추천해주는 함수
    // 입력: 온도, 날씨상태, 공기나쁨여부 -> 출력: ClothingModel(코디)
    func recommendOutfit(temp: Double, condition: WeatherModel.WeatherCondition, isBadAir: Bool) -> ClothingModel {
        
        var outfit = ClothingModel.default
        
        // 1. 기온별 기본 옷차림 (한국인 국룰 코디표 반영)
        switch temp {
        case 28...: // 28도 이상 (한여름)
            outfit.top = "sleeveless"
            outfit.bottom = "shorts_short"
            outfit.accessory = "handfan" // 손풍기
            
        case 23..<28: // 23~27도 (초여름)
            outfit.top = "tshirt_short"
            outfit.bottom = "pants_cotton"
            
        case 20..<23: // 20~22도 (초가을/늦봄)
            outfit.top = "tshirt_long"
            outfit.bottom = "pants_denim"
            
        case 17..<20: // 17~19도 (가을)
            outfit.top = "hoodie"
            outfit.bottom = "slacks"
            
        case 12..<17: // 12~16도 (쌀쌀)
            outfit.top = "shirt"
            outfit.bottom = "pants_denim"
            outfit.outer = "cardigan" // 가디건 추가
            
        case 9..<12: // 9~11도 (늦가을)
            outfit.top = "knit"
            outfit.bottom = "pants_warm"
            outfit.outer = "trench_coat" // 트렌치코트
            
        case 5..<9: // 5~8도 (초겨울)
            outfit.top = "heattech"
            outfit.bottom = "pants_thick"
            outfit.outer = "coat_wool" // 코트
            
        default: // 4도 이하 (한파)
            outfit.top = "sweatshirt"
            outfit.bottom = "pants_padding"
            outfit.outer = "long_padding" // 롱패딩
            outfit.accessory = "muffler" // 목도리
        }
        
        // 2. 날씨 특수 상황 (비/눈) - 기온보다 우선순위 높음
        if condition == .rain {
            outfit.outer = "raincoat" // 우비
            outfit.accessory = "umbrella" // 우산
        } else if condition == .snow {
            outfit.accessory = "gloves" // 장갑
        }
        
        // 3. 미세먼지 체크 (마스크 착용)
        if isBadAir {
            outfit.hasMask = true
        }
        
        return outfit
    }
}
