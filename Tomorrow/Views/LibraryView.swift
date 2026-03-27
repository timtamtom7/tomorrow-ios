import SwiftUI

// MARK: - LibraryView

struct LibraryView: View {
    @Environment(LibraryViewModel.self) private var viewModel
    @State private var showingEditor = false
    @State private var selectedLetter: Letter?
    @State private var showingTemplatePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()

                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.isEmpty {
                    emptyState
                } else {
                    libraryContent
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { @MainActor in
                            HapticsManager.shared.buttonTap()
                        }
                        selectedLetter = nil
                        showingEditor = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.tomorrowPrimary)
                    }
                    .accessibilityLabel("Create new letter")
                    .accessibilityHint("Opens the letter editor to write a new letter")
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task { @MainActor in
                            HapticsManager.shared.buttonTap()
                        }
                        showingTemplatePicker = true
                    } label: {
                        Image(systemName: "doc.text.fill")
                            .font(.body)
                    }
                    .tint(Color.tomorrowTextSecondary)
                    .accessibilityLabel("Choose template")
                    .accessibilityHint("Opens template picker for letter creation")
                }
            }
            .sheet(isPresented: $showingEditor) {
                LetterEditorView(letter: selectedLetter)
            }
            .sheet(isPresented: $showingTemplatePicker) {
                TemplatePickerSheet { template in
                    selectedLetter = nil
                    showingEditor = true
                }
            }
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "doc.text",
            title: "No Letters Yet",
            message: "Write your first letter to future-you. What do you want to remember?",
            actionTitle: "Write a Letter"
        ) {
            selectedLetter = nil
            showingEditor = true
        }
    }

    private var libraryContent: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Scheduled section
                if !viewModel.scheduledLetters.isEmpty {
                    LetterListView(
                        title: "Scheduled",
                        letters: viewModel.scheduledLetters,
                        emptyIcon: "clock",
                        emptyTitle: "No Scheduled Letters",
                        emptyMessage: "Schedule a letter to send to future-you",
                        onLetterTap: { letter in
                            selectedLetter = letter
                            showingEditor = true
                        },
                        onLetterDelete: { letter in
                            viewModel.deleteLetter(id: letter.id)
                        }
                    )
                }

                // Delivered section
                if !viewModel.deliveredLetters.isEmpty {
                    LetterListView(
                        title: "Delivered",
                        letters: viewModel.deliveredLetters,
                        emptyIcon: "seal",
                        emptyTitle: "No Delivered Letters",
                        emptyMessage: "Your letters will appear here when delivered",
                        onLetterTap: { letter in
                            selectedLetter = letter
                            showingEditor = true
                        },
                        onLetterDelete: { letter in
                            viewModel.deleteLetter(id: letter.id)
                        }
                    )
                }

                // Drafts section
                if !viewModel.drafts.isEmpty {
                    LetterListView(
                        title: "Drafts",
                        letters: viewModel.drafts,
                        emptyIcon: "pencil",
                        emptyTitle: "No Drafts",
                        emptyMessage: "Your drafts will appear here",
                        onLetterTap: { letter in
                            selectedLetter = letter
                            showingEditor = true
                        },
                        onLetterDelete: { letter in
                            viewModel.deleteLetter(id: letter.id)
                        }
                    )
                }
            }
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    LibraryView()
        .environment(LibraryViewModel())
}
