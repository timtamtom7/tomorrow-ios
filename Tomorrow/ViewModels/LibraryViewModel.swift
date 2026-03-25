import Foundation
import SwiftUI

// MARK: - LibraryViewModel

@Observable
@MainActor
final class LibraryViewModel {
    var letters: [Letter] = []
    var isLoading = false
    var errorMessage: String?
    var selectedTab: AppTab = .library

    private let letterService = LetterService.shared

    enum AppTab: Int {
        case library = 0
        case timeline = 1
        case create = 2
        case settings = 3
    }

    var drafts: [Letter] {
        letters.filter { $0.status == .draft }
    }

    var scheduledLetters: [Letter] {
        letters
            .filter { $0.status == .scheduled && $0.scheduledDate > Date() }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }

    var deliveredLetters: [Letter] {
        letters
            .filter { $0.status == .delivered }
            .sorted { $0.scheduledDate > $1.scheduledDate }
    }

    var upcomingDeliveries: [Letter] {
        letters
            .filter { $0.status == .scheduled || $0.status == .delivered }
            .filter { $0.scheduledDate > Date() }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }

    var pastDeliveries: [Letter] {
        letters
            .filter { $0.status == .delivered }
            .sorted { $0.scheduledDate > $1.scheduledDate }
    }

    var isEmpty: Bool {
        letters.isEmpty
    }

    // MARK: - Actions

    func loadLetters() {
        isLoading = true
        errorMessage = nil

        letters = letterService.getAllLetters()
        isLoading = false
    }

    func createLetter(
        title: String,
        content: String,
        scheduledDate: Date,
        status: LetterStatus = .draft,
        parentLetterId: UUID? = nil,
        tags: [String] = []
    ) {
        _ = letterService.createLetter(
            title: title,
            content: content,
            scheduledDate: scheduledDate,
            status: status,
            parentLetterId: parentLetterId,
            tags: tags
        )
        loadLetters()
    }

    func updateLetter(_ letter: Letter) {
        letterService.updateLetter(letter)
        loadLetters()
    }

    func deleteLetter(id: UUID) {
        letterService.deleteLetter(id: id)
        loadLetters()
    }

    func scheduleLetter(id: UUID, date: Date) {
        letterService.scheduleLetter(id: id, date: date)
        loadLetters()
    }

    func getLetter(id: UUID) -> Letter? {
        letterService.getLetter(id: id)
    }
}
