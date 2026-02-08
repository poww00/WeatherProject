import SwiftUI

struct LightningFlashView: View {
    var intensity: Double = 0.55

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            // 0~1 사이에서 주기적으로 번쩍(대충 4~7초 사이 느낌)
            // 여러 사인파를 섞어서 랜덤 같은 패턴 만듦
            let a = abs(sin(t * 0.9))
            let b = abs(sin(t * 1.7 + 1.2))
            let c = abs(sin(t * 2.3 + 2.6))
            let spike = max(0, (a * b * c - 0.78) * 4.5) // 임계치 넘을 때만

            Color.white
                .opacity(min(intensity, spike))
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }
}
