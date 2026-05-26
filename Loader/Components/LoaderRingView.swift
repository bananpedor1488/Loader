//
//  LoaderRingView.swift
//  Loader
//

import SwiftUI

struct LoaderRingView: View {
    var progress: Double
    var isActive: Bool

    @State private var spin: Double = 0

    private let lineWidth: CGFloat = 7

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0.04, min(1, progress)))
                .stroke(
                    LoaderTheme.heroGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: LoaderTheme.accentCyan.opacity(0.55), radius: 10)

            if isActive {
                Circle()
                    .trim(from: 0.02, to: 0.18)
                    .stroke(
                        Color.white.opacity(0.75),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(spin))
                    .blur(radius: 0.5)
            }

            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 34, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(LoaderTheme.accentCyan, LoaderTheme.accentViolet.opacity(0.9))
                .symbolEffect(.pulse, options: .repeating, value: isActive)
        }
        .padding(6)
        .onAppear {
            guard isActive else { return }
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                spin = 360
            }
        }
        .onChange(of: isActive) { _, active in
            if active {
                spin = 0
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    spin = 360
                }
            }
        }
    }
}
