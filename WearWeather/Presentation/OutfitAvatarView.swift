import SwiftUI
import UIKit

struct OutfitAvatarView: View {
    let outfit: ClothingModel
    let temperatureText: String?
    let summaryText: String?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.18))

            VStack(spacing: 10) {

                // 얼굴
                Circle()
                    .fill(Color.white.opacity(0.92))
                    .frame(width: 70, height: 70)
                    .padding(.top, 10)

                // 상의 + 아우터 + (온도/요약) + 악세서리(손/옆)
                ZStack {
                    if let outer = outfit.outer {
                        assetOrPlaceholder(
                            outer,
                            size: CGSize(width: 196, height: 104),
                            style: .outer
                        )
                        .offset(y: 6)
                        .zIndex(0)
                    }

                    assetOrPlaceholder(
                        outfit.top,
                        size: CGSize(width: 176, height: 88),
                        style: .top
                    )
                    .zIndex(1)

                    // 온도 + 요약
                    if let t = temperatureText, !t.isEmpty, t != "--°" {
                        chestOverlay(temp: t, summary: summaryText)
                            .offset(y: 0)
                            .zIndex(3)
                    }

                    // 악세서리 배치(종류별)
                    if let acc = outfit.accessory {
                        if isGloves(acc) {
                            // 글러브: 양손
                            HStack {
                                assetOrPlaceholder(acc, size: CGSize(width: 54, height: 26), style: .accessory)
                                Spacer()
                                assetOrPlaceholder(acc, size: CGSize(width: 54, height: 26), style: .accessory)
                            }
                            .frame(width: 210)
                            .offset(y: -6)
                            .zIndex(2)

                        } else if isUmbrella(acc) {
                            // 우산: 오른쪽 손에 들고 있는 느낌
                            assetOrPlaceholder(acc, size: CGSize(width: 90, height: 46), style: .accessory)
                                .offset(x: 86, y: 10)
                                .zIndex(2)

                        } else {
                            // 기타 악세서리: 상의 아래 작은 슬롯
                            assetOrPlaceholder(acc, size: CGSize(width: 110, height: 34), style: .accessory)
                                .offset(y: 52)
                                .zIndex(2)
                        }
                    }
                }
                .frame(height: 122)

                // 하의
                assetOrPlaceholder(
                    outfit.bottom,
                    size: CGSize(width: 156, height: 74),
                    style: .bottom
                )

                // ✅ 발쪽 슬롯은 무조건 shoes
                assetOrPlaceholder(
                    outfit.shoes,
                    size: CGSize(width: 136, height: 40),
                    style: .shoes
                )
                .padding(.top, 4)

                if outfit.hasMask {
                    Text("😷")
                        .font(.system(size: 22))
                        .padding(.top, 2)
                }

                Spacer(minLength: 6)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
        }
        .frame(width: 250, height: 340)
    }

    // MARK: - Overlay UI

    private func chestOverlay(temp: String, summary: String?) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.18))
                    .frame(width: 74, height: 38)

                Text(temp)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
            }

            if let s = summary, !s.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.14))
                        .frame(height: 26)

                    Text(s)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 10)
                }
                .frame(maxWidth: 160)
            }
        }
    }

    // MARK: - Types

    private enum ItemStyle { case top, bottom, outer, accessory, shoes }

    // MARK: - Helpers

    private func isGloves(_ name: String) -> Bool {
        let lower = name.lowercased()
        return lower.contains("glove") || lower.contains("gloves")
    }

    private func isUmbrella(_ name: String) -> Bool {
        let lower = name.lowercased()
        return lower.contains("umbrella") || lower.contains("umb")
    }

    private func assetOrPlaceholder(_ name: String,
                                    size: CGSize,
                                    style: ItemStyle) -> some View {
        Group {
            if UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(placeholderFill(for: style))
                    .overlay(
                        Text(name)
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.48))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 10)
                    )
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func placeholderFill(for style: ItemStyle) -> Color {
        switch style {
        case .outer: return Color.white.opacity(0.42)
        case .top: return Color.white.opacity(0.62)
        case .bottom: return Color.white.opacity(0.56)
        case .accessory: return Color.white.opacity(0.50)
        case .shoes: return Color.white.opacity(0.46)
        }
    }
}
