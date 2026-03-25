import Foundation
import SwiftUI
import UserNotifications

@Observable
@MainActor
final class LibraryViewModel {
    var letters: [Letter] = []
    var recipients: [Recipient] = []
    var isLoading = false
    var errorMessage: String?
    var selectedTab: AppTab = .library
    var aiInsights: [AIInsight] = []
    
    private let db = DatabaseService.shared
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
    
    var suggestedTemplates: [LetterTemplate] {
        LetterTemplate.templates
    }
    
    // MARK: - Actions
    
    func loadLetters() {
        isLoading = true
        errorMessage = nil
        
        letters = db.loadLetters()
        recipients = db.loadRecipients()
        
        // Check for letters ready to deliver
        checkAndDeliverLetters()
        
        isLoading = false
    }
    
    private func checkAndDeliverLetters() {
        // R6: Collect letters ready for delivery first, then update (avoid mutation during iteration)
        let now = Date()
        let toDeliver = letters.filter { $0.status == .scheduled && $0.scheduledDate <= now }
        for var letter in toDeliver {
            letter.status = .delivered
            db.saveLetter(letter)
            letterService.scheduleLetterDeliveryNotification(for: letter)
        }
    }
    
    func createLetter(
        title: String,
        content: String,
        scheduledDate: Date,
        status: LetterStatus = .draft,
        parentLetterId: UUID? = nil,
        tags: [String] = [],
        recipientId: UUID? = nil
    ) {
        let letter = Letter(
            title: title,
            content: content,
            scheduledDate: scheduledDate,
            status: status,
            parentLetterId: parentLetterId,
            tags: tags,
            recipientId: recipientId
        )
        db.saveLetter(letter)
        
        if status == .scheduled {
            letterService.scheduleLetterDeliveryNotification(for: letter)
        }
        
        loadLetters()
    }
    
    func updateLetter(_ letter: Letter) {
        db.saveLetter(letter)
        
        if letter.status == .scheduled {
            letterService.scheduleLetterDeliveryNotification(for: letter)
        } else {
            letterService.cancelNotification(for: letter)
        }
        
        loadLetters()
    }
    
    func deleteLetter(id: UUID) {
        if let letter = letters.first(where: { $0.id == id }) {
            letterService.cancelNotification(for: letter)
        }
        db.deleteLetter(id: id)
        loadLetters()
    }
    
    func scheduleLetter(id: UUID, date: Date) {
        guard var letter = letters.first(where: { $0.id == id }) else { return }
        letter.scheduledDate = date
        letter.status = .scheduled
        db.saveLetter(letter)
        letterService.scheduleLetterDeliveryNotification(for: letter)
        loadLetters()
    }
    
    func deliverLetter(id: UUID) {
        guard var letter = letters.first(where: { $0.id == id }) else { return }
        letter.status = .delivered
        db.saveLetter(letter)
        letterService.scheduleLetterDeliveryNotification(for: letter)
        loadLetters()
    }
    
    func getLetter(id: UUID) -> Letter? {
        letters.first { $0.id == id }
    }
    
    // MARK: - Recipients
    
    func addRecipient(_ recipient: Recipient) {
        db.saveRecipient(recipient)
        recipients = db.loadRecipients()
    }
    
    func deleteRecipient(id: UUID) {
        db.deleteRecipient(id: id)
        recipients = db.loadRecipients()
    }
    
    func recipient(for id: UUID?) -> Recipient? {
        guard let id = id else { return nil }
        return recipients.first { $0.id == id }
    }
    
    // MARK: - AI Insights
    
    func generateInsights() async {
        aiInsights = await letterService.generateInsights(from: deliveredLetters)
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermission() {
        letterService.requestNotificationPermission()
    }
}
