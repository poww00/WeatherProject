import SwiftUI

struct SnowEffectView: View {

    private struct Flake {
        let x: CGFloat
        let y0: CGFloat
        let r: CGFloat
        let speed: CGFloat
        let drift: CGFloat
        let phase: CGFloat
        let opacity: Double
    }

    private let flakes: [Flake] = {
        (0..<160).map { _ in
            Flake(
                x: CGFloat.random(in: 0...1),
                y0: CGFloat.random(in: 0...1),
                r: CGFloat.random(in: 1.2...3.2),
                speed: CGFloat.random(in: 40...120),
                drift: CGFloat.random(in: 10...55),
                phase: CGFloat.random(in: 0...6.28),
                opacity: Double.random(in: 0.25...0.75)
            )
        }
    }()

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                for f in flakes {
                    // 아래로 떨어지기
                    let y = (f.y0 * size.height + CGFloat(t) * f.speed)
                        .truncatingRemainder(dividingBy: (size.height + 40))

                    // 좌우 흔들림(sine)
                    let sway = sin(CGFloat(t) * 1.2 + f.phase) * f.drift
                    let x = f.x * size.width + sway

                    let rect = CGRect(
                        x: x - f.r,
                        y: y - f.r,
                        width: f.r * 2,
                        height: f.r * 2
                    )

                    ctx.fill(
                        Path(ellipseIn: rect),
                        with: .color(.white.opacity(f.opacity))
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(0.90)
    }
}
