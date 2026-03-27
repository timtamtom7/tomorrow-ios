import SwiftUI

struct VoiceRecorderView: View {
    @Binding var letter: Letter
    @State private var showingRecorder = false
    
    var body: some View {
        VStack(spacing: 16) {
            if letter.audioAttachments.isEmpty {
                emptyState
            } else {
                audioList
            }
        }
        .sheet(isPresented: $showingRecorder) {
            RecorderSheetView(letter: $letter)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "mic.circle")
                .font(.system(size: 40))
                .foregroundColor(.tomorrowTextTertiary)
            
            Text("No voice messages yet")
                .font(.subheadline)
                .foregroundColor(.tomorrowTextSecondary)
            
            Button {
                Task { @MainActor in
                    HapticsManager.shared.buttonTap()
                }
                showingRecorder = true
            } label: {
                Label("Record voice message", systemImage: "mic.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.tomorrowBackground)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.tomorrowPrimary)
                    .clipShape(Capsule())
            }
            .accessibilityLabel("Record voice message")
            .accessibilityHint("Opens the voice recorder to create an audio attachment")
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.tomorrowSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var audioList: some View {
        VStack(spacing: 12) {
            ForEach(letter.audioAttachments) { audio in
                AudioPlayerRow(audio: audio) {
                    letter.audioAttachments.removeAll { $0.id == audio.id }
                }
            }
            
            Button {
                showingRecorder = true
            } label: {
                Label("Add another", systemImage: "plus.circle")
                    .font(.subheadline)
                    .foregroundColor(.tomorrowPrimary)
            }
        }
    }
}

struct AudioPlayerRow: View {
    let audio: AudioAttachment
    let onDelete: () -> Void
    @State private var isPlaying = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                Task { @MainActor in
                    HapticsManager.shared.buttonTap()
                }
                isPlaying.toggle()
                if isPlaying {
                    playAudio()
                } else {
                    VoiceRecorderService.shared.stopPlayback()
                }
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundColor(.tomorrowPrimary)
            }
            .accessibilityLabel(isPlaying ? "Pause playback" : "Play audio")
            .accessibilityHint("Double tap to \(isPlaying ? "pause" : "play") this voice message")
            
            VStack(alignment: .leading, spacing: 4) {
                Text(audio.label)
                    .font(.subheadline)
                    .foregroundColor(.tomorrowTextPrimary)
                
                if !audio.waveformData.isEmpty {
                    WaveformView(data: audio.waveformData, isPlaying: isPlaying)
                        .frame(height: 24)
                }
                
                Text(audio.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.tomorrowTextTertiary)
            }
            
            Spacer()
            
            Button {
                Task { @MainActor in
                    HapticsManager.shared.deleteAction()
                }
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.tomorrowError)
            }
            .accessibilityLabel("Delete audio")
            .accessibilityHint("Removes this voice message from the letter")
        }
        .padding(12)
        .background(Color.tomorrowSurfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
    }
    
    private func playAudio() {
        let url = VoiceRecorderService.shared.getAbsoluteURL(for: audio.localURL)
        try? VoiceRecorderService.shared.playRecording(at: url)
    }
}

struct WaveformView: View {
    let data: [Float]
    let isPlaying: Bool
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(Array(displayBars.enumerated()), id: \.offset) { _, bar in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.tomorrowPrimary.opacity(isPlaying ? 1.0 : 0.5))
                        .frame(width: barWidth(geometry), height: max(4, geometry.size.height * CGFloat(bar)))
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
    
    private var displayBars: [Float] {
        if data.count <= 50 { return data }
        let step = data.count / 50
        return stride(from: 0, to: data.count, by: step).map { data[$0] }
    }
    
    private func barWidth(_ geometry: GeometryProxy) -> CGFloat {
        let count = max(1, displayBars.count)
        return max(2, (geometry.size.width - CGFloat(count - 1) * 2) / CGFloat(count))
    }
}

struct RecorderSheetView: View {
    @Binding var letter: Letter
    @State private var label = "Voice message"
    @State private var hasStarted = false
    @State private var isRecording = false
    @State private var isPaused = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var waveformData: [Float] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if !VoiceRecorderService.shared.permissionGranted {
                        permissionPrompt
                    } else if isRecording {
                        recordingUI
                    } else {
                        startUI
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Record Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if isRecording {
                            VoiceRecorderService.shared.cancelRecording()
                        }
                        dismiss()
                    }
                    .foregroundColor(.tomorrowTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isRecording {
                        Button("Done") {
                            saveRecording()
                        }
                        .foregroundColor(.tomorrowPrimary)
                    }
                }
            }
        }
    }
    
    private var permissionPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash")
                .font(.system(size: 48))
                .foregroundColor(.tomorrowTextTertiary)
            
            Text("Microphone Access Required")
                .font(.headline)
                .foregroundColor(.tomorrowTextPrimary)
            
            Text("Enable microphone access in Settings to record voice messages.")
                .font(.body)
                .foregroundColor(.tomorrowTextSecondary)
                .multilineTextAlignment(.center)
            
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .foregroundColor(.tomorrowPrimary)
        }
    }
    
    private var startUI: some View {
        VStack(spacing: 24) {
            TextField("Label (optional)", text: $label)
                .font(.body)
                .foregroundColor(.tomorrowTextPrimary)
                .padding(12)
                .background(Color.tomorrowSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Button {
                startRecording()
            } label: {
                HStack {
                    Image(systemName: "mic.fill")
                    Text("Start Recording")
                }
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.tomorrowBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.tomorrowPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var recordingUI: some View {
        VStack(spacing: 24) {
            Text(formatDuration(recordingDuration))
                .font(.system(size: 48, weight: .light, design: .rounded))
                .foregroundColor(.tomorrowTextPrimary)
                .monospacedDigit()
            
            WaveformView(data: waveformData, isPlaying: true)
                .frame(height: 60)
            
            HStack(spacing: 32) {
                Button {
                    Task { @MainActor in
                        HapticsManager.shared.recording()
                    }
                    if isPaused {
                        VoiceRecorderService.shared.resumeRecording()
                        isPaused = false
                    } else {
                        VoiceRecorderService.shared.pauseRecording()
                        isPaused = true
                    }
                } label: {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.title)
                        .foregroundColor(.tomorrowPrimary)
                }
                .accessibilityLabel(isPaused ? "Resume recording" : "Pause recording")
                
                Button {
                    Task { @MainActor in
                        HapticsManager.shared.deleteAction()
                    }
                    VoiceRecorderService.shared.cancelRecording()
                    isRecording = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.tomorrowError)
                }
                .accessibilityLabel("Cancel recording")
                .accessibilityHint("Discards the current recording")
            }
            
            Text(isPaused ? "Paused" : "Recording...")
                .font(.caption)
                .foregroundColor(.tomorrowTextSecondary)
        }
    }
    
    private func startRecording() {
        do {
            _ = try VoiceRecorderService.shared.startRecording(label: label)
            isRecording = true
            startTimer()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if !isRecording {
                timer.invalidate()
                return
            }
            recordingDuration += 1.0
            waveformData = VoiceRecorderService.shared.waveformData
        }
    }
    
    private func saveRecording() {
        if let result = VoiceRecorderService.shared.stopRecording() {
            let relativePath = "VoiceRecordings/\(result.url.lastPathComponent)"
            let audio = AudioAttachment(
                localURL: relativePath,
                duration: result.duration,
                waveformData: result.waveform,
                label: label
            )
            letter.audioAttachments.append(audio)
        }
        dismiss()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VoiceRecorderView(letter: .constant(Letter()))
}
