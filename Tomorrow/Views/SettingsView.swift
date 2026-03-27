import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    @Environment(LibraryViewModel.self) private var viewModel
    @AppStorage("notifications_enabled") private var notificationsEnabled = true
    @AppStorage("reminder_days_before") private var reminderDaysBefore = 1

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Stats Section
                        statsSection

                        // Notifications Section
                        notificationsSection

                        // About Section
                        aboutSection

                        // Danger Zone
                        dangerZone
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Letters")
                .font(.heading2)
                Color.tomorrowTextPrimary

            HStack(spacing: 16) {
                StatCard(
                    title: "Total",
                    value: "\(viewModel.letters.count)",
                    icon: "doc.text",
                    color: .tomorrowPrimary
                )

                StatCard(
                    title: "Delivered",
                    value: "\(viewModel.deliveredLetters.count)",
                    icon: "seal.fill",
                    color: .tomorrowSuccess
                )

                StatCard(
                    title: "Drafts",
                    value: "\(viewModel.drafts.count)",
                    icon: "pencil",
                    color: .tomorrowTextSecondary
                )
            }
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .font(.heading2)
                Color.tomorrowTextPrimary

            VStack(spacing: 0) {
                Toggle(isOn: $notificationsEnabled) {
                    Label("Delivery Reminders", systemImage: "bell")
                        Color.tomorrowTextPrimary
                }
                .tint(.tomorrowPrimary)
                .padding(16)
                .accessibilityLabel("Delivery Reminders")
                .accessibilityHint("When enabled, you'll be notified when letters are delivered")
                .onChange(of: notificationsEnabled) { _, _ in
                    Task { @MainActor in
                        HapticsManager.shared.toggle()
                    }
                }

                if notificationsEnabled {
                    Divider()
                        .background(Color.tomorrowDivider)

                    HStack {
                        Label("Remind me", systemImage: "clock")
                            Color.tomorrowTextPrimary

                        Spacer()

                        Picker("", selection: $reminderDaysBefore) {
                            Text("Same day").tag(0)
                            Text("1 day before").tag(1)
                            Text("3 days before").tag(3)
                            Text("1 week before").tag(7)
                        }
                        .pickerStyle(.menu)
                        .tint(.tomorrowPrimary)
                    }
                    .padding(16)
                }
            }
            .background(Color.tomorrowSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.heading2)
                Color.tomorrowTextPrimary

            VStack(spacing: 0) {
                SettingsRow(
                    title: "Version",
                    value: "1.0.0",
                    icon: "info.circle"
                )

                Divider()
                    .background(Color.tomorrowDivider)

                SettingsRow(
                    title: "Built with",
                    value: "SwiftUI",
                    icon: "swift"
                )
            }
            .background(Color.tomorrowSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Danger Zone")
                .font(.heading2)
                Color.tomorrowTextPrimary

            Button(role: .destructive) {
                Task { @MainActor in
                    HapticsManager.shared.deleteAction()
                }
                // Would show confirmation
            } label: {
                Label("Delete All Letters", systemImage: "trash")
                    Color.tomorrowError
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.tomorrowError.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .stroke(Color.tomorrowError.opacity(0.3), lineWidth: 1)
                    )
            }
            .accessibilityLabel("Delete all letters")
            .accessibilityHint("Permanently removes all your letters. Confirmation required.")
        }
    }
}

// MARK: - StatCard

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.heading1)
                Color.tomorrowTextPrimary

            Text(title)
                .font(.caption)
                Color.tomorrowTextSecondary
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.tomorrowSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(Color.tomorrowDivider, lineWidth: 1)
        )
    }
}

// MARK: - SettingsRow

struct SettingsRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                Color.tomorrowTextPrimary

            Spacer()

            Text(value)
                Color.tomorrowTextSecondary
        }
        .padding(16)
    }
}

#Preview {
    SettingsView()
        .environment(LibraryViewModel())
}
