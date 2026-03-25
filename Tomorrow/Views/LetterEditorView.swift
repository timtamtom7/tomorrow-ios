import SwiftUI

// MARK: - LetterEditorView

struct LetterEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LibraryViewModel.self) private var viewModel

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var scheduledDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var isScheduled = false
    @State private var showingDatePicker = false
    @State private var showingPrompt = false
    @State private var lastPauseTime: Date?

    private let promptTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    private let reflectionPrompts = [
        "What would you tell your future self about today?",
        "What's something you're grateful for right now?",
        "What challenge are you facing that future-you should know about?",
        "What are you hoping to feel when you read this letter?",
        "What's one thing you want to remember about this moment?",
        "If future-you could hear you now, what would you say?",
        "What would you tell a friend in your exact situation?",
        "What does your future self need to hear?"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        titleSection
                        contentSection
                        scheduleSection
                        characterCount

                        if showingPrompt {
                            promptSection
                        }
                    }
                    .padding(16)
                }

                VStack {
                    Spacer()
                    saveButton
                }
            }
            .navigationTitle(isEditing ? "Edit Letter" : "New Letter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    Color.tomorrowTextSecondary
                }
            }
            .onReceive(promptTimer) { _ in
                checkForPrompt()
            }
            .onChange(of: content) { _, _ in
                resetPauseTimer()
                if showingPrompt {
                    showingPrompt = false
                }
            }
            .onAppear {
                loadLetterIfEditing()
            }
        }
    }

    private var isEditing: Bool {
        existingLetter != nil
    }

    private var existingLetter: Letter?

    private func loadLetterIfEditing() {
        // This would be populated from navigation if editing
    }

    // MARK: - Sections

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.caption)
                Color.tomorrowTextSecondary

            TextField("Give your letter a title...", text: $title)
                .font(.body)
                Color.tomorrowTextPrimary
                .padding(12)
                .background(Color.tomorrowSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.tomorrowDivider, lineWidth: 1)
                )
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Letter to Future You")
                .font(.caption)
                Color.tomorrowTextSecondary

            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("Dear future me,\n\nWrite what's on your heart...")
                        .font(.body)
                        Color.tomorrowTextTertiary
                        .padding(.top, 12)
                        .padding(.leading, 4)
                }

                TextEditor(text: $content)
                    .font(.body)
                    Color.tomorrowTextPrimary
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 250)
            }
            .padding(12)
            .background(Color.tomorrowSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.tomorrowDivider, lineWidth: 1)
            )
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $isScheduled) {
                Label("Schedule for delivery", systemImage: "clock")
                    .font(.body)
                    Color.tomorrowTextPrimary
            }
            .tint(.tomorrowPrimary)

            if isScheduled {
                DatePicker(
                    "Deliver on",
                    selection: $scheduledDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(.tomorrowPrimary)
                .padding(12)
                .background(Color.tomorrowSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack {
                    Image(systemName: "info.circle")
                        Color.tomorrowTextTertiary
                    Text("This letter will unlock on \(formattedDate)")
                        .font(.caption)
                        Color.tomorrowTextSecondary
                }
            }
        }
        .padding(16)
        .background(Color.tomorrowSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var characterCount: some View {
        HStack {
            Spacer()
            Text("\(content.count) characters")
                .font(.caption)
                Color.tomorrowTextTertiary
        }
    }

    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Need inspiration?")
                .font(.caption)
                Color.tomorrowTextSecondary

            Text(reflectionPrompts.randomElement() ?? reflectionPrompts[0])
                .font(.body)
                Color.tomorrowAccent
                .italic()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.tomorrowPrimary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.tomorrowPrimary.opacity(0.3), lineWidth: 1)
                )

            Button("Dismiss") {
                showingPrompt = false
            }
            .font(.caption)
            Color.tomorrowTextTertiary
        }
        .padding(16)
        .background(Color.tomorrowSurfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeOut(duration: 0.3), value: showingPrompt)
    }

    private var saveButton: some View {
        Button {
            saveLetter()
        } label: {
            Text(isEditing ? "Save Changes" : (isScheduled ? "Schedule Letter" : "Save as Draft"))
                .font(.body)
                .fontWeight(.semibold)
                Color.tomorrowBackground
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    canSave ? Color.tomorrowPrimary : Color.tomorrowTextTertiary
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canSave)
        .padding(16)
        .background(
            LinearGradient(
                colors: [.tomorrowBackground.opacity(0), .tomorrowBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: scheduledDate)
    }

    // MARK: - Actions

    private func checkForPrompt() {
        guard content.isEmpty || content.count < 20 else { return }
        guard let lastPause = lastPauseTime else { return }

        if Date().timeIntervalSince(lastPause) >= 10 {
            withAnimation {
                showingPrompt = true
            }
        }
    }

    private func resetPauseTimer() {
        lastPauseTime = Date()
    }

    private func saveLetter() {
        let status: LetterStatus = isScheduled ? .scheduled : .draft

        if let existing = existingLetter {
            var updated = existing
            updated.title = title
            updated.content = content
            updated.scheduledDate = scheduledDate
            updated.status = status
            viewModel.updateLetter(updated)
        } else {
            viewModel.createLetter(
                title: title,
                content: content,
                scheduledDate: scheduledDate,
                status: status
            )
        }

        dismiss()
    }
}

// Extension for LetterEditorView to accept optional letter
extension LetterEditorView {
    init(letter: Letter?) {
        _title = State(initialValue: letter?.title ?? "")
        _content = State(initialValue: letter?.content ?? "")
        _scheduledDate = State(initialValue: letter?.scheduledDate ?? Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date())
        _isScheduled = State(initialValue: letter?.status != .draft)
    }
}

#Preview {
    LetterEditorView(letter: nil)
        .environment(LibraryViewModel())
}
