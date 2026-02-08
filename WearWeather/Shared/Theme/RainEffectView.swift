import SwiftUI

struct RainEffectView: View {
    var density: Double = 1.0

    private struct Drop {
        let x: CGFloat
        let y0: CGFloat
        let length: CGFloat
        let speed: CGFloat
        let thickness: CGFloat
        let opacity: Double
        let drift: CGFloat
    }

    // ✅ 랜덤 드롭은 "고정 seed"로 한 번만 생성되게
    private let drops: [Drop] = {
        let count = Int(240 * 1.0)  // 기본 개수(밀도는 Canvas에서 조절)
        return (0..<count).map { _ in
            Drop(
                x: CGFloat.random(in: 0...1),              // 0~1 정규화
                y0: CGFloat.random(in: 0...1),             // 0~1
                length: CGFloat.random(in: 10...22),
                speed: CGFloat.random(in: 380...720),
                thickness: CGFloat.random(in: 0.6...1.4),
                opacity: Double.random(in: 0.15...0.45),
                drift: CGFloat.random(in: 30...80)
            )
        }
    }()

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let count = Int(Double(drops.count) * density)

                for i in 0..<max(0, min(count, drops.count)) {
                    let d = drops[i]

                    let x = d.x * size.width + CGFloat((t * 0.12).truncatingRemainder(dividingBy: 1.0)) * d.drift
                    let y = (d.y0 * size.height + CGFloat(t) * d.speed)
                        .truncatingRemainder(dividingBy: (size.height + 60))

                    var path = Path()
                    path.move(to: CGPoint(x: x, y: y - 30))
                    path.addLine(to: CGPoint(x: x + 6, y: y - 30 + d.length))

                    ctx.stroke(
                        path,
                        with: .color(.white.opacity(d.opacity)),
                        lineWidth: d.thickness
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(0.60)
    }
}
