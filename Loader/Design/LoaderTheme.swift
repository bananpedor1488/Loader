//
//  LoaderTheme.swift
//  Loader
//

import SwiftUI

enum LoaderTheme {
    static let bgDeep = Color(red: 0.04, green: 0.05, blue: 0.12)
    static let bgMid = Color(red: 0.08, green: 0.06, blue: 0.18)

    static let accentCyan = Color(red: 0.22, green: 0.92, blue: 0.98)
    static let accentViolet = Color(red: 0.58, green: 0.35, blue: 1.0)
    static let accentMagenta = Color(red: 0.95, green: 0.28, blue: 0.72)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.38)

    static let cardFill = Color.white.opacity(0.07)
    static let cardStroke = Color.white.opacity(0.14)

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [accentCyan, accentViolet, accentMagenta],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var subtleGradient: LinearGradient {
        LinearGradient(
            colors: [
                accentViolet.opacity(0.35),
                accentCyan.opacity(0.12),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct LoaderGlassCard: ViewModifier {
    var cornerRadius: CGFloat = 22

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.06),
                                        LoaderTheme.accentCyan.opacity(0.25)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
            }
            .shadow(color: LoaderTheme.accentViolet.opacity(0.18), radius: 24, y: 12)
    }
}

extension View {
    func loaderGlassCard(cornerRadius: CGFloat = 22) -> some View {
        modifier(LoaderGlassCard(cornerRadius: cornerRadius))
    }
}
