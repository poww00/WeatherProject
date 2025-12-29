// Shared/Models/ClothingModel.swift
import Foundation

// 🧥 스타일리스트가 골라준 '오늘의 코디'
struct ClothingModel: Codable {
    var top: String        // 상의 이미지 이름 (예: "tshirt_short")
    var bottom: String     // 하의 이미지 이름 (예: "pants_denim")
    var outer: String?     // 아우터 (없을 수도 있어서 옵셔널 ?)
    var accessory: String? // 악세서리 (우산, 선글라스 등)
    var hasMask: Bool      // 마스크 착용 여부 (미세먼지용)
    
    // 기본 알몸(?) 상태 (초기화용)
    static let `default` = ClothingModel(
        top: "tshirt_basic",
        bottom: "shorts_basic",
        outer: nil,
        accessory: nil,
        hasMask: false
    )
}
