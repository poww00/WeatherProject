import SwiftUI

struct LightningFlashView: View {
    @State private var flashOpacity: Double = 0.0

    var body: some View {
        Color.white
            .opacity(flashOpacity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .onAppear {
                scheduleNextFlash()
            }
    }

    private func scheduleNextFlash() {
        // 2~7초 랜덤 간격으로 번개
        let delay = Double.random(in: 2.0...7.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            Task { @MainActor in
                await flash()
                scheduleNextFlash()
            }
        }
    }

    @MainActor
    private func flash() async {
        // 짧게 1~2번 번쩍
        let times = Int.random(in: 1...2)
        for _ in 0..<times {
            withAnimation(.easeOut(duration: 0.08)) { flashOpacity = 0.55 }
            try? await Task.sleep(nanoseconds: 80_000_000)
            withAnimation(.easeIn(duration: 0.18)) { flashOpacity = 0.0 }
            try? await Task.sleep(nanoseconds: 180_000_000)
        }
    }
}

