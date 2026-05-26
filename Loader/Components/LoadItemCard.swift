//
//  LoadItemCard.swift
//  Loader
//

import SwiftUI

struct LoadItemCard: View {
    let item: Item
    let index: Int
    let isSelected: Bool

    private var progress: Double { item.simulatedProgress }

    private var status: (title: String, icon: String, color: Color) {
        if progress >= 0.95 {
            return ("Готово", "checkmark.seal.fill", LoaderTheme.accentCyan)
        }
        if progress >= 0.5 {
            return ("Загрузка", "arrow.down.circle.fill", LoaderTheme.accentViolet)
        }
        return ("В очереди", "clock.fill", LoaderTheme.textTertiary)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                status.color.opacity(0.35),
                                status.color.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: status.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(status.color)
                    .symbolEffect(.bounce, value: isSelected)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Пакет #\(index + 1)")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(LoaderTheme.textPrimary)

                    Spacer(minLength: 8)

                    Text(status.title)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(status.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(status.color.opacity(0.15), in: Capsule())
                }

                Text(item.timestamp, format: .dateTime.day().month(.wide).hour().minute())
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(LoaderTheme.textSecondary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)

                        Capsule()
                            .fill(LoaderTheme.heroGradient)
                            .frame(width: geo.size.width * progress, height: 6)
                            .shadow(color: LoaderTheme.accentCyan.opacity(0.4), radius: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(18)
        .loaderGlassCard(cornerRadius: 24)
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(LoaderTheme.heroGradient, lineWidth: 1.5)
                    .shadow(color: LoaderTheme.accentCyan.opacity(0.35), radius: 12)
            }
        }
        .scaleEffect(isSelected ? 1.02 : 1)
        .animation(.spring(response: 0.38, dampingFraction: 0.72), value: isSelected)
    }
}
