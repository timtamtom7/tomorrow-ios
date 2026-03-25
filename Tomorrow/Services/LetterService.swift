import Foundation
import NaturalLanguage
import UserNotifications

final class LetterService: @unchecked Sendable {
    static let shared = LetterService()
    
    private init() {}
    
    // MARK: - AI Insights
    
    func generateInsights(from letters: [Letter]) async -> [AIInsight] {
        let deliveredLetters = letters.filter { $0.status == .delivered && !$0.content.isEmpty }
        guard deliveredLetters.count >= 3 else { return [] }
        
        let allText = deliveredLetters.map { $0.content }.joined(separator: " ")
        let themes = extractThemes(from: allText)
        var insights: [AIInsight] = []
        
        for theme in themes.prefix(5) {
            let quotes = deliveredLetters
                .filter { $0.content.lowercased().contains(theme.keyword.lowercased()) }
                .prefix(3)
                .map { String($0.content.prefix(150)) + "..." }
            
            insights.append(AIInsight(
                theme: theme.keyword,
                occurrences: theme.count,
                exampleQuotes: Array(quotes)
            ))
        }
        
        return insights
    }
    
    private struct ThemeResult {
        let keyword: String
        let count: Int
    }
    
    private func extractThemes(from text: String) -> [ThemeResult] {
        let sentimentTags = [
            "love", "family", "work", "fear", "hope", "dreams", "change", "growth",
            "gratitude", "regret", "success", "failure", "health", "relationship",
            "happiness", "anxiety", "future", "past", "present", "goals"
        ]
        
        let lowercased = text.lowercased()
        var results: [ThemeResult] = []
        
        for tag in sentimentTags {
            let count = lowercased.components(separatedBy: tag).count - 1
            if count >= 2 {
                results.append(ThemeResult(keyword: tag.capitalized, count: count))
            }
        }
        
        // Extract named entities as potential themes
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var entityCounts: [String: Int] = [:]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
            if let tag = tag, tag == .personalName || tag == .placeName {
                let entity = String(text[range])
                if entity.count > 2 {
                    entityCounts[entity, default: 0] += 1
                }
            }
            return true
        }
        
        for (entity, count) in entityCounts where count >= 2 {
            results.append(ThemeResult(keyword: entity, count: count))
        }
        
        return results.sorted { $0.count > $1.count }
    }
    
    // MARK: - AI Writing Prompt
    
    func generateWritingPrompt(for letter: Letter) async -> String? {
        guard letter.content.count > 20 else {
            let prompts = [
                "What's on your mind today?",
                "If you could tell your future self one thing, what would it be?",
                "What's something you've been putting off saying?",
                "Describe a recent moment that mattered to you.",
                "What are you grateful for right now?"
            ]
            return prompts.randomElement()
        }
        
        let lowercased = letter.content.lowercased()
        
        let triggerWords = ["worried", "fear", "anxious", "stressed", "hope", "dream", "love", "miss"]
        for word in triggerWords {
            if lowercased.contains(word) {
                let followUps: [String: String] = [
                    "worried": "What specifically is worrying you? Is there something you can control about it?",
                    "fear": "What would you tell someone else who felt this fear?",
                    "anxious": "Try describing the anxiety as if it's a weather pattern — it comes and goes.",
                    "stressed": "What's the one thing you could let go of today?",
                    "hope": "What are you doing right now to move toward that hope?",
                    "dream": "What's the smallest step you could take toward that dream today?",
                    "love": "Who in your life has shown you love recently? Have you told them?",
                    "miss": "What would you do if you could see them right now?"
                ]
                return followUps[word]
            }
        }
        
        return nil
    }
    
    // MARK: - Notifications
    
    func scheduleLetterDeliveryNotification(for letter: Letter) {
        let center = UNUserNotificationCenter.current()
        
        // Remove existing notification for this letter
        center.removePendingNotificationRequests(withIdentifiers: [letter.id.uuidString])
        
        let content = UNMutableNotificationContent()
        
        if letter.recipientId != nil {
            content.title = "A letter has arrived"
            content.body = "Someone wrote you a letter. Open to read it."
        } else {
            content.title = "A letter from your past"
            content.body = "Open to read what you wrote to yourself on \(letter.formattedScheduledDate)."
        }
        content.sound = .default
        content.categoryIdentifier = "LETTER_DELIVERED"
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: letter.scheduledDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: letter.id.uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func scheduleWriteReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["write_reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Write a letter to someone"
        content.body = "You haven't written a letter in a while. Take a moment to capture what's on your mind."
        content.sound = .default
        
        // Weekly reminder
        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 10
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "write_reminder", content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func cancelNotification(for letter: Letter) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [letter.id.uuidString])
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                Task { await MainActor.run { self.scheduleWriteReminder() } }
            }
        }
    }
}
