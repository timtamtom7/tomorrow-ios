import SwiftUI

// MARK: - LetterEditorView

struct LetterEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LibraryViewModel.self) private var viewModel

    @State private var letter: Letter
    @State private var scheduledDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var isScheduled = false
    @State private var showingDatePicker = false
    @State private var showingPrompt = false
    @State private var lastPauseTime: Date?
    @State private var showingAttachments = false
    @State private var showingMemoryTags = false

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

    init(letter: Letter?) {
        _letter = State(initialValue: letter ?? Letter())
        _isScheduled = State(initialValue: (letter?.status ?? .draft) != .draft)
        if let l = letter {
            _scheduledDate = State(initialValue: l.scheduledDate)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        titleSection
                        contentSection
                        attachmentsSection
                        memoryTagsSection
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
            .onChange(of: letter.content) { _, _ in
                resetPauseTimer()
                if showingPrompt {
                    showingPrompt = false
                }
            }
        }
    }

    private var isEditing: Bool {
        viewModel.letters.contains { $0.id == letter.id }
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

            TextField("Give your letter a title...", text: $letter.title)
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
                if letter.content.isEmpty {
                    Text("Dear future me,\n\nWrite what's on your heart...")
                        .font(.body)
                        Color.tomorrowTextTertiary
                        .padding(.top, 12)
                        .padding(.leading, 4)
                }

                TextEditor(text: $letter.content)
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
    
    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Attachments")
                    .font(.caption)
                    Color.tomorrowTextSecondary
                
                Spacer()
                
                Button {
                    showingAttachments = true
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.tomorrowPrimary)
                }
            }
            
            // Voice recordings
            VoiceRecorderView(letter: $letter)
        }
    }
    
    private var memoryTagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Memory Tags")
                    .font(.caption)
                    Color.tomorrowTextSecondary
                
                Spacer()
                
                Button {
                    showingMemoryTags = true
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.tomorrowPrimary)
                }
            }
            
            MemoryTagsPickerView(letter: $letter)
        }
        .sheet(isPresented: $showingMemoryTags) {
            NavigationStack {
                ZStack {
                    Color.tomorrowBackground.ignoresSafeArea()
                    MemoryTagsPickerView(letter: $letter)
                        .padding()
                }
                .navigationTitle("Memory Tags")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showingMemoryTags = false
                        }
                        .foregroundColor(.tomorrowPrimary)
                    }
                }
            }
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
            Text("\(letter.content.count) characters")
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
        !letter.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: scheduledDate)
    }

    // MARK: - Actions

    private func checkForPrompt() {
        guard letter.content.isEmpty || letter.content.count < 20 else { return }
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
        var updatedLetter = letter
        updatedLetter.scheduledDate = scheduledDate
        updatedLetter.status = status

        if isEditing {
            viewModel.updateLetter(updatedLetter)
        } else {
            viewModel.createLetter(
                title: updatedLetter.title,
                content: updatedLetter.content,
                scheduledDate: updatedLetter.scheduledDate,
                status: updatedLetter.status,
                tags: updatedLetter.tags,
                recipientId: updatedLetter.recipientId
            )
        }

        dismiss()
    }
}

#Preview {
    LetterEditorView(letter: nil)
        .environment(LibraryViewModel())
}
