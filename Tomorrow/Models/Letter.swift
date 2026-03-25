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

    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        scheduledDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
        createdAt: Date = Date(),
        status: LetterStatus = .draft,
        parentLetterId: UUID? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.scheduledDate = scheduledDate
        self.createdAt = createdAt
        self.status = status
        self.parentLetterId = parentLetterId
        self.tags = tags
    }

    var previewText: String {
        let maxLength = 100
        if content.count <= maxLength {
            return content
        }
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

// MARK: - Family Tree

struct FamilyTree: Codable {
    var nodes: [UUID: Letter]
    var edges: [UUID: [UUID]]

    init() {
        nodes = [:]
        edges = [:]
    }

    mutating func addLetter(_ letter: Letter) {
        nodes[letter.id] = letter
    }

    mutating func addEdge(parent: UUID, child: UUID) {
        if edges[parent] == nil {
            edges[parent] = []
        }
        edges[parent]?.append(child)
    }

    func children(of letterId: UUID) -> [Letter] {
        guard let childIds = edges[letterId] else { return [] }
        return childIds.compactMap { nodes[$0] }
    }

    func parent(of letterId: UUID) -> Letter? {
        guard let letter = nodes[letterId],
              let parentId = letter.parentLetterId else { return nil }
        return nodes[parentId]
    }

    func rootLetters() -> [Letter] {
        nodes.values.filter { $0.parentLetterId == nil }
    }
}
