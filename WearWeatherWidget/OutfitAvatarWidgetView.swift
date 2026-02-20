import SwiftUI
import UIKit

/// 위젯 전용 캐릭터 렌더링 뷰
/// - 목적: 작은 캔버스에서도 레이아웃이 깨지지 않게 "고정 프레임"을 없애고,
///         라벨 텍스트(hoodie/jeans 등)를 위젯에서는 숨긴다.
/// - 앱(MainView)에서 쓰는 OutfitAvatarView는 그대로 유지.
struct OutfitAvatarWidgetView: View {
    let outfit: ClothingModel

    private var showsMask: Bool { outfit.hasMask }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let minSide = min(w, h)

            ZStack {
                // 카드 느낌의 바탕
                RoundedRectangle(cornerRadius: cornerRadius(for: minSide), style: .continuous)
                    .fill(Color.white.opacity(0.14))

                VStack(spacing: minSide * 0.06) {
                    // 얼굴
                    Circle()
                        .fill(Color.white.opacity(0.92))
                        .frame(width: minSide * 0.30, height: minSide * 0.30)
                        .overlay(maskOverlay(minSide: minSide), alignment: .center)

                    // 상의/아우터/악세서리
                    ZStack {
                        if let outer = outfit.outer {
                            itemView(name: outer, style: .outer)
                                .frame(width: w * 0.70, height: h * 0.22)
                                .offset(y: minSide * 0.01)
                        }

                        itemView(name: outfit.top, style: .top)
                            .frame(width: w * 0.66, height: h * 0.20)

                        if let acc = outfit.accessory {
                            accessoryView(name: acc, w: w, h: h, minSide: minSide)
                        }
                    }
                    .frame(height: h * 0.28)

                    // 하의
                    itemView(name: outfit.bottom, style: .bottom)
                        .frame(width: w * 0.60, height: h * 0.18)

                    // 신발
                    itemView(name: outfit.shoes, style: .shoes)
                        .frame(width: w * 0.54, height: h * 0.12)
                        .padding(.top, minSide * 0.02)

                    Spacer(minLength: 0)
                }
                .padding(.vertical, minSide * 0.10)
                .padding(.horizontal, minSide * 0.10)
            }
            .frame(width: w, height: h)
            .clipped()
            .drawingGroup()
        }
    }

    // MARK: - Mask

    @ViewBuilder
    private func maskOverlay(minSide: CGFloat) -> some View {
        if showsMask {
            RoundedRectangle(cornerRadius: minSide * 0.08, style: .continuous)
                .fill(Color.black.opacity(0.55))
                .frame(width: minSide * 0.22, height: minSide * 0.08)
                .offset(y: minSide * 0.03)
        } else {
            EmptyView()
        }
    }

    // MARK: - Accessory

    @ViewBuilder
    private func accessoryView(name: String, w: CGFloat, h: CGFloat, minSide: CGFloat) -> some View {
        let lower = name.lowercased()

        if lower.contains("glove") {
            HStack {
                itemView(name: name, style: .accessory)
                    .frame(width: w * 0.18, height: h * 0.07)
                Spacer()
                itemView(name: name, style: .accessory)
                    .frame(width: w * 0.18, height: h * 0.07)
            }
            .frame(width: w * 0.70)
            .offset(y: -minSide * 0.02)

        } else if lower.contains("umbrella") || lower.contains("umb") {
            itemView(name: name, style: .accessory)
                .frame(width: w * 0.30, height: h * 0.10)
                .offset(x: w * 0.28, y: minSide * 0.02)

        } else {
            itemView(name: name, style: .accessory)
                .frame(width: w * 0.40, height: h * 0.09)
                .offset(y: minSide * 0.12)
        }
    }

    // MARK: - Items

    private enum ItemStyle { case top, bottom, outer, accessory, shoes }

    @ViewBuilder
    private func itemView(name: String, style: ItemStyle) -> some View {
        // 위젯은 "라벨 텍스트"가 깨지는 1순위 원인이라, placeholder에 텍스트를 절대 넣지 않는다.
        if UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFit()
        } else {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(placeholderFill(for: style))
        }
    }

    private func placeholderFill(for style: ItemStyle) -> Color {
        switch style {
        case .outer: return Color.white.opacity(0.30)
        case .top: return Color.white.opacity(0.48)
        case .bottom: return Color.white.opacity(0.40)
        case .accessory: return Color.white.opacity(0.36)
        case .shoes: return Color.white.opacity(0.34)
        }
    }

    private func cornerRadius(for minSide: CGFloat) -> CGFloat {
        if minSide < 80 { return 14 }
        if minSide < 140 { return 18 }
        return 22
    }
}
