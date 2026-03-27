import SwiftUI

// MARK: - LetterListView

struct LetterListView: View {
    let title: String
    let letters: [Letter]
    let emptyIcon: String
    let emptyTitle: String
    let emptyMessage: String
    let onLetterTap: (Letter) -> Void
    let onLetterDelete: (Letter) -> Void

    @Environment(LibraryViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.heading2)
                Color.tomorrowTextPrimary
                .padding(.horizontal, 16)

            if letters.isEmpty {
                EmptyStateView(
                    icon: emptyIcon,
                    title: emptyTitle,
                    message: emptyMessage
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(letters) { letter in
                        LetterCard(letter: letter)
                            .onTapGesture {
                                Task { @MainActor in
                                    HapticsManager.shared.cardTap()
                                }
                                onLetterTap(letter)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    onLetterDelete(letter)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - LetterCard

struct LetterCard: View {
    let letter: Letter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(letter.displayTitle)
                    .font(.heading3)
                    Color.tomorrowTextPrimary
                    .lineLimit(1)

                Spacer()

                statusBadge
            }

            Text(letter.previewText)
                .font(.body)
                Color.tomorrowTextSecondary
                .lineLimit(2)

            HStack {
                Label(letter.formattedScheduledDate, systemImage: "calendar")
                    .font(.caption)
                    Color.tomorrowTextTertiary

                if letter.status == .scheduled {
                    Text("•")
                        Color.tomorrowTextTertiary
                    Text("\(letter.daysUntilDelivery) days away")
                        .font(.caption)
                        Color.tomorrowAccent
                }
            }
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(borderColor, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(letter.displayTitle). \(letter.status.displayName). \(letter.previewText)")
        .accessibilityHint("Double tap to open letter")
    }

    @ViewBuilder
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: letter.status.iconName)
                .font(.caption)
            Text(letter.status.displayName)
                .font(.caption)
        }
        .foregroundStyle(badgeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.15))
        .clipShape(Capsule())
    }

    private var cardBackground: Color {
        switch letter.status {
        case .draft:
            return .tomorrowSurface
        case .scheduled:
            return .tomorrowSurface
        case .delivered:
            return .tomorrowSurfaceElevated
        }
    }

    private var borderColor: Color {
        switch letter.status {
        case .draft:
            return .tomorrowDivider
        case .scheduled:
            return .tomorrowPrimary.opacity(0.3)
        case .delivered:
            return .tomorrowPrimary.opacity(0.5)
        }
    }

    private var badgeColor: Color {
        switch letter.status {
        case .draft:
            return .tomorrowTextTertiary
        case .scheduled:
            return .tomorrowAccent
        case .delivered:
            return .tomorrowPrimary
        }
    }
}

#Preview {
    ZStack {
        Color.tomorrowBackground.ignoresSafeArea()

        LetterListView(
            title: "Drafts",
            letters: [
                Letter(title: "Test Letter", content: "Hello future me, how are you doing today?"),
                Letter(title: "", content: "Another draft letter here")
            ],
            emptyIcon: "doc.text",
            emptyTitle: "No Drafts",
            emptyMessage: "Start writing your first letter",
            onLetterTap: { _ in },
            onLetterDelete: { _ in }
        )
    }
}
