//
//  ContentView.swift
//  Loader
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]

    @State private var selectedItemID: UUID?
    @State private var showHeroPulse = false
    @State private var addHapticTick = 0
    private var overallProgress: Double {
        guard !items.isEmpty else { return 0 }
        return items.reduce(0.0) { $0 + $1.simulatedProgress } / Double(items.count)
    }

    private var activeCount: Int {
        items.filter(\.isLoading).count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AuroraBackground()

                ScrollView {
                    VStack(spacing: 28) {
                        heroSection
                        statsRow
                        itemsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)

                floatingAddButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(LoaderTheme.heroGradient)
                        Text("Loader")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(LoaderTheme.textPrimary)
                    }
                }
            }
            .navigationDestination(item: $selectedItemID) { id in
                LoadDetailView(
                    item: items.first(where: { $0.id == id }) ?? Item(timestamp: .now),
                    index: items.firstIndex(where: { $0.id == id }) ?? 0
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                showHeroPulse = true
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LoaderTheme.accentViolet.opacity(showHeroPulse ? 0.22 : 0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)

                LoaderRingView(
                    progress: items.isEmpty ? 0.12 : overallProgress,
                    isActive: activeCount > 0
                )
                .frame(width: 148, height: 148)
            }

            VStack(spacing: 8) {
                Text(items.isEmpty ? "Нет активных загрузок" : "Синхронизация")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(LoaderTheme.textPrimary)

                Text(items.isEmpty
                     ? "Добавьте первый пакет — анимация оживёт"
                     : "\(Int(overallProgress * 100))% · \(activeCount) в работе")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(LoaderTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .loaderGlassCard(cornerRadius: 32)
        .padding(.top, 4)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatPill(
                title: "Всего",
                value: "\(items.count)",
                icon: "square.stack.3d.up.fill",
                tint: LoaderTheme.accentCyan
            )
            StatPill(
                title: "Активно",
                value: "\(activeCount)",
                icon: "waveform.path",
                tint: LoaderTheme.accentViolet
            )
            StatPill(
                title: "Готово",
                value: "\(max(0, items.count - activeCount))",
                icon: "sparkles",
                tint: LoaderTheme.accentMagenta
            )
        }
    }

    @ViewBuilder
    private var itemsSection: some View {
        if items.isEmpty {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: 14) {
                Text("Очередь")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(LoaderTheme.textPrimary)
                    .padding(.leading, 4)

                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button {
                        selectedItemID = item.id
                    } label: {
                        LoadItemCard(
                            item: item,
                            index: index,
                            isSelected: selectedItemID == item.id
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            delete(item)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.65)
                            .scaleEffect(phase.isIdentity ? 1 : 0.94)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.and.arrow.down.fill")
                .font(.system(size: 44))
                .foregroundStyle(LoaderTheme.heroGradient)
                .symbolEffect(.bounce, value: items.isEmpty)

            Text("Очередь пуста")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(LoaderTheme.textPrimary)

            Text("Нажмите «+» внизу, чтобы создать новую загрузку с плавной анимацией.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(LoaderTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .loaderGlassCard(cornerRadius: 28)
    }

    private var floatingAddButton: some View {
        VStack {
            Spacer()
            Button(action: addItem) {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                    Text("Новая загрузка")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(LoaderTheme.bgDeep)
                .padding(.horizontal, 28)
                .padding(.vertical, 18)
                .background {
                    Capsule()
                        .fill(LoaderTheme.heroGradient)
                        .shadow(color: LoaderTheme.accentViolet.opacity(0.55), radius: 20, y: 10)
                }
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .medium), trigger: addHapticTick)
            .padding(.bottom, 28)
        }
    }

    private func addItem() {
        addHapticTick += 1
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func delete(_ item: Item) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if selectedItemID == item.id {
                selectedItemID = nil
            }
            modelContext.delete(item)
        }
    }
}

private struct StatPill: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)

            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(LoaderTheme.textPrimary)

            Text(title)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(LoaderTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .loaderGlassCard(cornerRadius: 20)
    }
}

struct LoadDetailView: View {
    let item: Item
    let index: Int

    @Environment(\.dismiss) private var dismiss

    private var progress: Double { item.simulatedProgress }

    var body: some View {
        ZStack {
            AuroraBackground()

            ScrollView {
                VStack(spacing: 28) {
                    LoaderRingView(progress: progress, isActive: progress < 0.95)
                        .frame(width: 160, height: 160)
                        .padding(.top, 24)

                    VStack(spacing: 10) {
                        Text("Пакет #\(index + 1)")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(LoaderTheme.textPrimary)

                        Text(item.timestamp, format: .dateTime.weekday(.wide).day().month(.wide).year().hour().minute().second())
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(LoaderTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        detailRow(icon: "number", title: "Идентификатор", value: String(item.id.uuidString.prefix(8)) + "…")
                        detailRow(icon: "gauge.with.needle", title: "Прогресс", value: "\(Int(progress * 100))%")
                        detailRow(icon: "internaldrive", title: "Размер", value: formatSize(seed: item.timestamp))
                    }
                    .padding(22)
                    .loaderGlassCard(cornerRadius: 26)
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Готово") { dismiss() }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(LoaderTheme.accentCyan)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(LoaderTheme.accentCyan)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(LoaderTheme.textTertiary)
                Text(value)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(LoaderTheme.textPrimary)
            }
            Spacer()
        }
    }

    private func formatSize(seed: Date) -> String {
        let mb = 48 + abs(seed.timeIntervalSince1970.bitPattern.hashValue % 900)
        if mb >= 1024 {
            return String(format: "%.1f GB", Double(mb) / 1024)
        }
        return "\(mb) MB"
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
