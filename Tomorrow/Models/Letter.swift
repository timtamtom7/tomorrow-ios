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
        isAIGenerated: Bool = false
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
