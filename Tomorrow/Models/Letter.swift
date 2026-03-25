import Foundation

// MARK: - Letter Model

struct Letter: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var scheduledDate: Date
    var createdAt: Date
    var status: LetterStatus
    var parentLetterId: UUID?
    var tags: [String]
    var recipientId: UUID?
    var isAIGenerated: Bool
    
    // R7: Rich content attachments
    var audioAttachments: [AudioAttachment]
    var photoAttachments: [PhotoAttachment]
    var richTextContent: String?  // Stores HTML/markdown version of content
    var memoryTags: [MemoryTag]
    
    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        scheduledDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
        createdAt: Date = Date(),
        status: LetterStatus = .draft,
        parentLetterId: UUID? = nil,
        tags: [String] = [],
        recipientId: UUID? = nil,
        isAIGenerated: Bool = false,
        audioAttachments: [AudioAttachment] = [],
        photoAttachments: [PhotoAttachment] = [],
        richTextContent: String? = nil,
        memoryTags: [MemoryTag] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.scheduledDate = scheduledDate
        self.createdAt = createdAt
        self.status = status
        self.parentLetterId = parentLetterId
        self.tags = tags
        self.recipientId = recipientId
        self.isAIGenerated = isAIGenerated
        self.audioAttachments = audioAttachments
        self.photoAttachments = photoAttachments
        self.richTextContent = richTextContent
        self.memoryTags = memoryTags
    }
    
    var previewText: String {
        let maxLength = 100
        if content.count <= maxLength { return content }
        return String(content.prefix(maxLength)) + "..."
    }
    
    var displayTitle: String {
        title.isEmpty ? "Untitled Letter" : title
    }
    
    var formattedScheduledDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: scheduledDate)
    }
    
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
    
    var daysUntilDelivery: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: scheduledDate).day ?? 0
    }
    
    var isDeliveryToday: Bool {
        Calendar.current.isDateInToday(scheduledDate)
    }
}

// MARK: - Letter Status

enum LetterStatus: String, Codable, CaseIterable {
    case draft
    case scheduled
    case delivered
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .scheduled: return "Scheduled"
        case .delivered: return "Delivered"
        }
    }
    
    var iconName: String {
        switch self {
        case .draft: return "pencil"
        case .scheduled: return "clock"
        case .delivered: return "seal.fill"
        }
    }
}

// MARK: - Recipient

struct Recipient: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var relationship: String
    var email: String
    var avatarInitials: String
    
    init(id: UUID = UUID(), name: String, relationship: String = "", email: String = "") {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.email = email
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            self.avatarInitials = "\(parts[0].prefix(1))\(parts[1].prefix(1))"
        } else {
            self.avatarInitials = String(name.prefix(2)).uppercased()
        }
    }
    
    static let templates: [Recipient] = [
        Recipient(name: "My Future Self", relationship: "Self", email: ""),
        Recipient(name: "My Child (born 2026)", relationship: "Child", email: ""),
        Recipient(name: "My Partner", relationship: "Partner", email: ""),
        Recipient(name: "My Future Self in 10 Years", relationship: "Self", email: ""),
    ]
}

// MARK: - Letter Template

struct LetterTemplate: Identifiable {
    let id: UUID
    var title: String
    var prompt: String
    var suggestedDuration: Int // days
    var recipientPreset: String?
    
    init(id: UUID = UUID(), title: String, prompt: String, suggestedDuration: Int = 365, recipientPreset: String? = nil) {
        self.id = id
        self.title = title
        self.prompt = prompt
        self.suggestedDuration = suggestedDuration
        self.recipientPreset = recipientPreset
    }
    
    static let templates: [LetterTemplate] = [
        LetterTemplate(
            title: "Letter to My Future Self",
            prompt: "Write a letter to yourself one year from now. What do you hope to have achieved? What are you worried about? What advice would you give yourself?",
            suggestedDuration: 365,
            recipientPreset: "My Future Self"
        ),
        LetterTemplate(
            title: "Letter to My Child",
            prompt: "Write a letter to your child. Tell them about who you are right now, what you dream for them, and what you hope they always remember.",
            suggestedDuration: 365 * 18,
            recipientPreset: "My Child"
        ),
        LetterTemplate(
            title: "Letter to My Partner",
            prompt: "Write a letter to your partner expressing what they mean to you, a favorite memory, and something you've always wanted to say.",
            suggestedDuration: 365,
            recipientPreset: "My Partner"
        ),
        LetterTemplate(
            title: "Letter to My Past Self",
            prompt: "Write a letter to yourself 5 years ago. What would you tell them? What do you know now that you wish you knew then?",
            suggestedDuration: 365 * 5,
            recipientPreset: "My Past Self"
        ),
        LetterTemplate(
            title: "Annual Check-In",
            prompt: "Where are you right now? What's working, what's not? What do you want to change? Write honestly — this is just for you.",
            suggestedDuration: 365,
            recipientPreset: "My Future Self"
        ),
    ]
}

// MARK: - AI Insight

struct AIInsight: Identifiable {
    let id: UUID
    var theme: String
    var occurrences: Int
    var exampleQuotes: [String]
    var generatedAt: Date
    
    init(id: UUID = UUID(), theme: String, occurrences: Int, exampleQuotes: [String], generatedAt: Date = Date()) {
        self.id = id
        self.theme = theme
        self.occurrences = occurrences
        self.exampleQuotes = exampleQuotes
        self.generatedAt = generatedAt
    }
}

// MARK: - R7: Audio Attachment

struct AudioAttachment: Identifiable, Codable, Equatable {
    let id: UUID
    var localURL: String  // Relative path in app documents
    var duration: TimeInterval
    var waveformData: [Float]  // For visualization
    var createdAt: Date
    var label: String  // User label like "Message to future self"
    
    init(
        id: UUID = UUID(),
        localURL: String,
        duration: TimeInterval,
        waveformData: [Float] = [],
        createdAt: Date = Date(),
        label: String = "Voice message"
    ) {
        self.id = id
        self.localURL = localURL
        self.duration = duration
        self.waveformData = waveformData
        self.createdAt = createdAt
        self.label = label
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - R7: Photo Attachment

struct PhotoAttachment: Identifiable, Codable, Equatable {
    let id: UUID
    var localURL: String  // Relative path in app documents
    var caption: String?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        localURL: String,
        caption: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.localURL = localURL
        self.caption = caption
        self.createdAt = createdAt
    }
}

// MARK: - R7: Memory Tags

struct MemoryTag: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var emoji: String
    var category: Category
    
    init(id: UUID = UUID(), name: String, emoji: String, category: Category = .general) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.category = category
    }
    
    enum Category: String, Codable, CaseIterable {
        case general = "General"
        case milestone = "Milestone"
        case relationship = "Relationship"
        case travel = "Travel"
        case achievement = "Achievement"
        case health = "Health"
        case family = "Family"
        case career = "Career"
        case creative = "Creative"
        case other = "Other"
        
        var color: String {
            switch self {
            case .general: return "7B6CF6"
            case .milestone: return "F5A623"
            case .relationship: return "FF6B6B"
            case .travel: return "00D4AA"
            case .achievement: return "34C759"
            case .health: return "FF9500"
            case .family: return "AF52DE"
            case .career: return "5856D6"
            case .creative: return "FF2D55"
            case .other: return "8E8E93"
            }
        }
    }
    
    static let defaultTags: [MemoryTag] = [
        MemoryTag(name: "Wedding", emoji: "💒", category: .milestone),
        MemoryTag(name: "Birth", emoji: "👶", category: .family),
        MemoryTag(name: "New Home", emoji: "🏠", category: .milestone),
        MemoryTag(name: "Graduation", emoji: "🎓", category: .achievement),
        MemoryTag(name: "New Job", emoji: "💼", category: .career),
        MemoryTag(name: "Travel", emoji: "✈️", category: .travel),
        MemoryTag(name: "Anniversary", emoji: "💕", category: .relationship),
        MemoryTag(name: "Birthday", emoji: "🎂", category: .milestone),
        MemoryTag(name: "Health Milestone", emoji: "💪", category: .health),
        MemoryTag(name: "Creative Project", emoji: "🎨", category: .creative),
        MemoryTag(name: "First Meeting", emoji: "🤝", category: .relationship),
        MemoryTag(name: "Big Decision", emoji: "🤔", category: .general),
    ]
}

// MARK: - R7: Voice Recording State

struct VoiceRecordingState {
    var isRecording: Bool = false
    var isPaused: Bool = false
    var duration: TimeInterval = 0
    var waveform: [Float] = []
}
