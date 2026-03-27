import SwiftUI

// MARK: - TimelineView

struct TimelineView: View {
    @Environment(LibraryViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()

                if viewModel.letters.isEmpty {
                    emptyState
                } else {
                    timelineContent
                }
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "clock",
            title: "No Letters Yet",
            message: "Your letters will appear here as you write them."
        )
    }

    private var timelineContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Future Section
                if !viewModel.upcomingDeliveries.isEmpty {
                    timelineSection(
                        title: "Scheduled",
                        letters: viewModel.upcomingDeliveries,
                        isPast: false
                    )
                }

                // Past Section
                if !viewModel.pastDeliveries.isEmpty {
                    timelineSection(
                        title: "Delivered",
                        letters: viewModel.pastDeliveries,
                        isPast: true
                    )
                }

                // Drafts Section
                if !viewModel.drafts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Drafts")
                            .font(.heading2)
                            .foregroundStyle(Color.tomorrowTextPrimary)
                            .padding(.horizontal, 16)
                            .padding(.top, 24)

                        ForEach(viewModel.drafts) { letter in
                            DraftTimelineCard(letter: letter)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }

    private func timelineSection(title: String, letters: [Letter], isPast: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.heading2)
                .foregroundStyle(Color.tomorrowTextPrimary)
                .padding(.horizontal, 16)

            ForEach(Array(letters.enumerated()), id: \.element.id) { index, letter in
                TimelineNodeView(
                    letter: letter,
                    isLast: index == letters.count - 1,
                    isPast: isPast
                )
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 12)
    }
}

// MARK: - TimelineNodeView

struct TimelineNodeView: View {
    let letter: Letter
    let isLast: Bool
    let isPast: Bool

    @State private var isExpanded = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline line and node
            VStack(spacing: 0) {
                Circle()
                    .fill(nodeColor)
                    .frame(width: 12, height: 12)

                if !isLast {
                    Rectangle()
                        .fill(Color.tomorrowDivider)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }

            // Content card
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(letter.formattedScheduledDate)
                        .font(.caption)
                        .foregroundStyle(Color.tomorrowTextTertiary)

                    Text(letter.displayTitle)
                        .font(.heading3)
                        .foregroundStyle(Color.tomorrowTextPrimary)
                }

                Text(letter.previewText)
                    .font(.body)
                    .foregroundStyle(Color.tomorrowTextSecondary)
                    .lineLimit(isExpanded ? nil : 2)

                if letter.content.count > 100 {
                    Button(isExpanded ? "Show less" : "Read more") {
                        Task { @MainActor in
                            HapticsManager.shared.light()
                        }
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isExpanded.toggle()
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Color.tomorrowPrimary)
                    .accessibilityLabel(isExpanded ? "Show less" : "Read more")
                    .accessibilityHint(isExpanded ? "Collapse letter content" : "Expand to read full letter")
                }

                if isPast {
                    deliveredBadge
                } else {
                    scheduledBadge
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(nodeColor.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var nodeColor: Color {
        isPast ? Color.tomorrowPrimary : Color.tomorrowSecondary
    }

    private var cardBackground: Color {
        isPast ? Color.tomorrowSurfaceElevated : Color.tomorrowSurface
    }

    private var deliveredBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "seal.fill")
            Text("Delivered")
        }
        .font(.caption)
        .foregroundStyle(Color.tomorrowPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.tomorrowPrimary.opacity(0.15))
        .clipShape(Capsule())
    }

    private var scheduledBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
            Text("\(letter.daysUntilDelivery) days away")
        }
        .font(.caption)
        .foregroundStyle(Color.tomorrowAccent)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.tomorrowAccent.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - DraftTimelineCard

struct DraftTimelineCard: View {
    let letter: Letter

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline node (muted for drafts)
            Circle()
                .fill(Color.tomorrowTextTertiary)
                .frame(width: 12, height: 12)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(letter.formattedCreatedAt)
                        .font(.caption)
                        .foregroundStyle(Color.tomorrowTextTertiary)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Draft")
                    }
                    .font(.caption)
                    .foregroundStyle(Color.tomorrowTextTertiary)
                }

                Text(letter.displayTitle)
                    .font(.heading3)
                    .foregroundStyle(Color.tomorrowTextPrimary)

                Text(letter.previewText)
                    .font(.body)
                    .foregroundStyle(Color.tomorrowTextSecondary)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tomorrowSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tomorrowDivider, lineWidth: 1)
            )
        }
    }
}

#Preview {
    TimelineView()
        .environment(LibraryViewModel())
}
