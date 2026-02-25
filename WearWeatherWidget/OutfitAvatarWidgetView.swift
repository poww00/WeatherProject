import SwiftUI
import UIKit

struct OutfitAvatarWidgetView: View {
    enum Style { case standard, circular }

    let outfit: ClothingModel
    let style: Style

    init(outfit: ClothingModel, style: Style = .standard) {
        self.outfit = outfit
        self.style = style
    }

    private var showsMask: Bool { outfit.hasMask }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let minSide = min(w, h)

            let (outerPadding, vSpacing): (CGFloat, CGFloat) = {
                switch style {
                case .standard:
                    return (max(4, minSide * 0.065), max(3, minSide * 0.035))
                case .circular:
                    // ✅ 원형: 내부 패딩 최소 (바깥에서 frame/position으로 제어)
                    return (max(0, minSide * 0.008), max(1, minSide * 0.012))
                }
            }()

            ZStack {
                if style == .standard {
                    RoundedRectangle(cornerRadius: cornerRadius(for: minSide), style: .continuous)
                        .fill(Color.black.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius(for: minSide), style: .continuous)
                                .stroke(Color.black.opacity(0.08), lineWidth: 0.6)
                        )
                }

                VStack(spacing: vSpacing) {
                    Circle()
                        .fill(Color.white.opacity(0.92))
                        .frame(
                            width: minSide * (style == .circular ? 0.38 : 0.30),
                            height: minSide * (style == .circular ? 0.38 : 0.30)
                        )
                        .overlay(maskOverlay(minSide: minSide), alignment: .center)

                    ZStack {
                        if let outer = outfit.outer {
                            itemView(name: outer, style: .outer)
                                .frame(width: w * (style == .circular ? 0.90 : 0.78),
                                       height: minSide * (style == .circular ? 0.26 : 0.22))
                                .offset(y: minSide * 0.006)
                        }

                        itemView(name: outfit.top, style: .top)
                            .frame(width: w * (style == .circular ? 0.86 : 0.74),
                                   height: minSide * (style == .circular ? 0.24 : 0.20))

                        if let acc = outfit.accessory {
                            accessoryView(name: acc, w: w, base: minSide)
                        }
                    }
                    .frame(height: minSide * (style == .circular ? 0.30 : 0.24))

                    itemView(name: outfit.bottom, style: .bottom)
                        .frame(width: w * (style == .circular ? 0.82 : 0.70),
                               height: minSide * (style == .circular ? 0.20 : 0.16))

                    itemView(name: outfit.shoes, style: .shoes)
                        .frame(width: w * (style == .circular ? 0.72 : 0.62),
                               height: minSide * (style == .circular ? 0.12 : 0.10))
                        .padding(.top, max(0, minSide * 0.006))
                }
                .padding(.vertical, style == .circular ? outerPadding * 0.2 : outerPadding * 0.90)
                .padding(.horizontal, outerPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(width: w, height: h)
            .clipped()
            .drawingGroup()
        }
    }

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

    @ViewBuilder
    private func accessoryView(name: String, w: CGFloat, base: CGFloat) -> some View {
        let lower = name.lowercased()

        if lower.contains("glove") {
            HStack {
                itemView(name: name, style: .accessory)
                    .frame(width: w * 0.20, height: base * 0.07)
                Spacer(minLength: 0)
                itemView(name: name, style: .accessory)
                    .frame(width: w * 0.20, height: base * 0.07)
            }
            .frame(width: w * 0.74)
            .offset(y: -base * 0.02)

        } else if lower.contains("umbrella") || lower.contains("umb") {
            itemView(name: name, style: .accessory)
                .frame(width: w * 0.34, height: base * 0.10)
                .offset(x: w * 0.30, y: base * 0.02)

        } else {
            itemView(name: name, style: .accessory)
                .frame(width: w * 0.46, height: base * 0.09)
                .offset(y: base * 0.10)
        }
    }

    private enum ItemStyle { case top, bottom, outer, accessory, shoes }

    @ViewBuilder
    private func itemView(name: String, style: ItemStyle) -> some View {
        if UIImage(named: name) != nil {
            Image(name).resizable().scaledToFit()
        } else {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(placeholderFill(for: style))
        }
    }

    private func placeholderFill(for style: ItemStyle) -> Color {
        switch style {
        case .outer: Color.white.opacity(0.30)
        case .top: Color.white.opacity(0.48)
        case .bottom: Color.white.opacity(0.40)
        case .accessory: Color.white.opacity(0.36)
        case .shoes: Color.white.opacity(0.34)
        }
    }

    private func cornerRadius(for minSide: CGFloat) -> CGFloat {
        if minSide < 80 { 14 }
        else if minSide < 140 { 18 }
        else { 22 }
    }
}
