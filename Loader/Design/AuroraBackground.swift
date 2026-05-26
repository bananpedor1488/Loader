//
//  AuroraBackground.swift
//  Loader
//

import SwiftUI

struct AuroraBackground: View {
    var body: some View {
        ZStack {
            LoaderTheme.bgDeep

            TimelineView(.animation(minimumInterval: 1 / 24)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    auroraOrb(
                        color: LoaderTheme.accentViolet.opacity(0.7),
                        x: 0.2 + 0.04 * sin(t * 0.6),
                        y: 0.15 + 0.03 * cos(t * 0.5),
                        scale: 1.05 + 0.08 * sin(t * 0.7)
                    )
                    auroraOrb(
                        color: LoaderTheme.accentCyan.opacity(0.55),
                        x: 0.75 + 0.05 * cos(t * 0.45),
                        y: 0.22 + 0.04 * sin(t * 0.55),
                        scale: 0.95 + 0.06 * cos(t * 0.65)
                    )
                    auroraOrb(
                        color: LoaderTheme.accentMagenta.opacity(0.5),
                        x: 0.42 + 0.06 * sin(t * 0.4 + 1),
                        y: 0.68 + 0.05 * cos(t * 0.5 + 0.5),
                        scale: 1.1 + 0.07 * sin(t * 0.35)
                    )
                }
                .blur(radius: 64)
            }

            LinearGradient(
                colors: [
                    LoaderTheme.bgDeep.opacity(0.15),
                    LoaderTheme.bgMid.opacity(0.75),
                    LoaderTheme.bgDeep
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private func auroraOrb(color: Color, x: Double, y: Double, scale: Double) -> some View {
        GeometryReader { geo in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, color.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: min(geo.size.width, geo.size.height) * 0.42
                    )
                )
                .frame(
                    width: geo.size.width * 0.95,
                    height: geo.size.width * 0.95
                )
                .scaleEffect(scale)
                .position(
                    x: geo.size.width * x,
                    y: geo.size.height * y
                )
        }
    }
}
