import SwiftUI

struct RainEffectView: View {
    var density: Double = 1.0

    @State private var drops: [Drop] = []
    @State private var lastTime: Date?

    struct Drop: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var length: CGFloat
        var speed: CGFloat
        var thickness: CGFloat
        var opacity: Double
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                if drops.isEmpty {
                    // 첫 프레임에 초기화
                    let count = Int(220 * density)
                    drops = makeDrops(count: count, size: size)
                    lastTime = timeline.date
                }

                // delta time
                let dt: CGFloat
                if let lastTime {
                    dt = CGFloat(timeline.date.timeIntervalSince(lastTime))
                } else {
                    dt = 1.0 / 60.0
                }
                self.lastTime = timeline.date

                // 업데이트 + 그리기
                for i in drops.indices {
                    drops[i].y += drops[i].speed * dt
                    drops[i].x += 60 * dt // 약간 대각선

                    if drops[i].y > size.height + 40 || drops[i].x > size.width + 40 {
                        drops[i].y = -CGFloat.random(in: 20...size.height)
                        drops[i].x = -CGFloat.random(in: 0...80)
                    }

                    var path = Path()
                    path.move(to: CGPoint(x: drops[i].x, y: drops[i].y))
                    path.addLine(to: CGPoint(x: drops[i].x + 6, y: drops[i].y + drops[i].length))

                    ctx.stroke(
                        path,
                        with: .color(.white.opacity(drops[i].opacity)),
                        lineWidth: drops[i].thickness
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(0.55)
    }

    private func makeDrops(count: Int, size: CGSize) -> [Drop] {
        (0..<count).map { _ in
            Drop(
                x: CGFloat.random(in: 0...max(1, size.width)),
                y: CGFloat.random(in: 0...max(1, size.height)),
                length: CGFloat.random(in: 10...22),
                speed: CGFloat.random(in: 380...720),
                thickness: CGFloat.random(in: 0.6...1.4),
                opacity: Double.random(in: 0.15...0.45)
            )
        }
    }
}

