import Foundation
import AVFoundation
import Observation

/// R7: Voice recording service for audio letters
@MainActor
@Observable
final class VoiceRecorderService {
    static let shared = VoiceRecorderService()
    
    var isRecording = false
    var isPaused = false
    var recordingDuration: TimeInterval = 0
    var waveformData: [Float] = []
    var permissionGranted = false
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var currentRecordingURL: URL?
    private var meterTimer: Timer?
    private var currentDelegate: AudioRecorderDelegate?
    
    private let audioSession = AVAudioSession.sharedInstance()
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            permissionGranted = true
        case .denied:
            permissionGranted = false
        case .undetermined:
            requestPermission()
        @unknown default:
            permissionGranted = false
        }
    }
    
    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
            }
        }
    }
    
    func startRecording(label: String = "Voice message") throws -> URL {
        try configureAudioSession()
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordingsPath = documentsPath.appendingPathComponent("VoiceRecordings", isDirectory: true)
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: recordingsPath, withIntermediateDirectories: true)
        
        let fileName = "\(UUID().uuidString).m4a"
        let fileURL = recordingsPath.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        let delegate = AudioRecorderDelegate()
        delegate.onFinish = { flag in
            if !flag {
                print("Recording did not finish successfully")
            }
        }
        audioRecorder?.delegate = delegate
        currentDelegate = delegate
        audioRecorder?.record()
        
        currentRecordingURL = fileURL
        isRecording = true
        isPaused = false
        recordingDuration = 0
        waveformData = []
        
        // Start meter timer for waveform
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateMeter()
        }
        
        // Start duration timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            DispatchQueue.main.async {
                self.recordingDuration += 1.0
            }
        }
        
        return fileURL
    }
    
    func pauseRecording() {
        audioRecorder?.pause()
        isPaused = true
    }
    
    func resumeRecording() {
        audioRecorder?.record()
        isPaused = false
    }
    
    func stopRecording() -> (url: URL, duration: TimeInterval, waveform: [Float])? {
        guard let recorder = audioRecorder, let url = currentRecordingURL else { return nil }
        
        let duration = recordingDuration
        let waveform = waveformData
        
        recorder.stop()
        
        timer?.invalidate()
        timer = nil
        meterTimer?.invalidate()
        meterTimer = nil
        
        isRecording = false
        isPaused = false
        audioRecorder = nil
        
        return (url, duration, waveform)
    }
    
    func cancelRecording() {
        audioRecorder?.stop()
        if let url = currentRecordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        
        timer?.invalidate()
        timer = nil
        meterTimer?.invalidate()
        meterTimer = nil
        
        isRecording = false
        isPaused = false
        recordingDuration = 0
        waveformData = []
        currentRecordingURL = nil
    }
    
    private func configureAudioSession() throws {
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)
    }
    
    private func updateMeter() {
        guard let recorder = audioRecorder, isRecording, !isPaused else { return }
        
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        
        // Normalize power from -160...0 to 0...1
        let normalizedPower = max(0, (power + 60) / 60)
        DispatchQueue.main.async {
            self.waveformData.append(Float(normalizedPower))
            if self.waveformData.count > 200 {
                self.waveformData.removeFirst()
            }
        }
    }
    
    // MARK: - Playback
    
    func playRecording(at url: URL) throws {
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    // MARK: - File Management
    
    func deleteRecording(at relativePath: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(relativePath)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func getAbsoluteURL(for relativePath: String) -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(relativePath)
    }
}

// MARK: - Audio Recorder Delegate

final class AudioRecorderDelegate: NSObject, AVAudioRecorderDelegate {
    var onFinish: ((Bool) -> Void)?
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording did not finish successfully")
        }
        onFinish?(flag)
    }
}
