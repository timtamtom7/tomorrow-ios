import Foundation

// MARK: - LetterService

@MainActor
final class LetterService {
    static let shared = LetterService()

    private let database = DatabaseService.shared

    private init() {}

    // MARK: - CRUD Operations

    func createLetter(
        title: String,
        content: String,
        scheduledDate: Date,
        status: LetterStatus = .draft,
        parentLetterId: UUID? = nil,
        tags: [String] = []
    ) -> Letter {
        let letter = Letter(
            title: title,
            content: content,
            scheduledDate: scheduledDate,
            createdAt: Date(),
            status: status,
            parentLetterId: parentLetterId,
            tags: tags
        )
        database.saveLetter(letter)

        // Update family tree if linked
        if let parentId = parentLetterId {
            var tree = database.loadFamilyTree()
            tree.addLetter(letter)
            tree.linkLetter(parentId: parentId, childId: letter.id)
            database.saveFamilyTree(tree)
        }

        return letter
    }

    func updateLetter(_ letter: Letter) {
        database.saveLetter(letter)
    }

    func deleteLetter(id: UUID) {
        database.deleteLetter(id: id)
    }

    func getLetter(id: UUID) -> Letter? {
        database.loadLetters().first { $0.id == id }
    }

    // MARK: - Queries

    func getAllLetters() -> [Letter] {
        let letters = database.loadLetters()
        return updateDeliveryStatuses(letters)
    }

    func getDrafts() -> [Letter] {
        getAllLetters().filter { $0.status == .draft }
    }

    func getScheduled() -> [Letter] {
        getAllLetters()
            .filter { $0.status == .scheduled || $0.status == .delivered }
            .filter { $0.status != .draft }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }

    func getDelivered() -> [Letter] {
        getAllLetters().filter { $0.status == .delivered }
    }

    func getScheduledForFuture() -> [Letter] {
        getAllLetters()
            .filter { $0.scheduledDate > Date() }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }

    // MARK: - Status Updates

    func scheduleLetter(id: UUID, date: Date) {
        guard var letter = getLetter(id: id) else { return }
        letter.scheduledDate = date
        letter.status = .scheduled
        updateLetter(letter)
    }

    func deliverLetter(id: UUID) {
        guard var letter = getLetter(id: id) else { return }
        letter.status = .delivered
        updateLetter(letter)
    }

    func markAsDraft(id: UUID) {
        guard var letter = getLetter(id: id) else { return }
        letter.status = .draft
        updateLetter(letter)
    }

    // MARK: - Family Tree

    func getFamilyTree() -> FamilyTreeModel {
        let tree = database.loadFamilyTree()
        let letters = database.loadLetters()

        var mergedTree = tree
        for letter in letters {
            if mergedTree.nodes[letter.id] == nil {
                mergedTree.addLetter(letter)
            }
        }

        return mergedTree
    }

    // MARK: - Private

    private func updateDeliveryStatuses(_ letters: [Letter]) -> [Letter] {
        var updated = letters
        let now = Date()

        for i in updated.indices {
            if updated[i].status == .scheduled && updated[i].scheduledDate <= now {
                updated[i].status = .delivered
                database.saveLetter(updated[i])
            }
        }

        return updated
    }
}
