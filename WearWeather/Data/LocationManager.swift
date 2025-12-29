// Data/LocationManager.swift
import Foundation
import CoreLocation
import SwiftUI
import Combine // ✨ [필수] 이 줄이 없어서 에러가 난 겁니다!

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // GPS 관리자
    private let manager = CLLocationManager()

    // 📢 내 위치 정보
    @Published var location: CLLocation?
    @Published var isLoading = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // 위치 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.location = location
        self.isLoading = false
    }
    
    // 에러 발생
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 찾기 실패: \(error.localizedDescription)")
        isLoading = false
    }
}
