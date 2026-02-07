import SwiftUI

struct SnowEffectView: View {
    @State private var flakes: [Flake] = []
    @State private var lastTime: Date?

    struct Flake: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var r: CGFloat
        var speed: CGFloat
        var drift: CGFloat
        var phase: CGFloat
        var opacity: Double
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                if flakes.isEmpty {
                    flakes = makeFlakes(count: 140, size: size)
                    lastTime = timeline.date
                }

                let dt: CGFloat
                if let lastTime {
                    dt = CGFloat(timeline.date.timeIntervalSince(lastTime))
                } else {
                    dt = 1.0 / 60.0
                }
                self.lastTime = timeline.date

                for i in flakes.indices {
                    flakes[i].y += flakes[i].speed * dt
                    flakes[i].phase += dt
                    flakes[i].x += sin(flakes[i].phase) * flakes[i].drift * dt

                    if flakes[i].y > size.height + 20 {
                        flakes[i].y = -CGFloat.random(in: 0...60)
                        flakes[i].x = CGFloat.random(in: 0...max(1, size.width))
                        flakes[i].phase = CGFloat.random(in: 0...6.28)
                    }

                    let rect = CGRect(
                        x: flakes[i].x - flakes[i].r,
                        y: flakes[i].y - flakes[i].r,
                        width: flakes[i].r * 2,
                        height: flakes[i].r * 2
                    )

                    ctx.fill(
                        Path(ellipseIn: rect),
                        with: .color(.white.opacity(flakes[i].opacity))
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(0.85)
    }

    private func makeFlakes(count: Int, size: CGSize) -> [Flake] {
        (0..<count).map { _ in
            Flake(
                x: CGFloat.random(in: 0...max(1, size.width)),
                y: CGFloat.random(in: 0...max(1, size.height)),
                r: CGFloat.random(in: 1.2...3.2),
                speed: CGFloat.random(in: 40...120),
                drift: CGFloat.random(in: 10...40),
                phase: CGFloat.random(in: 0...6.28),
                opacity: Double.random(in: 0.25...0.70)
            )
        }
    }
}

