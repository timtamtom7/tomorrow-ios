import Foundation
import NaturalLanguage

// MARK: - TomorrowPrediction
struct TomorrowPrediction: Codable {
    let anticipationScore: Int // 1-10
    let summary: String
    let highlights: [String]
    let concerns: [String]
    let weather: String
    let factors: [FactorContribution]
    let suggestedIntention: String?
    let energyLevel: EnergyLevel
    let bestTimeForDeepWork: TimeOfDay?
    let predictedMood: String

    enum EnergyLevel: String, Codable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case veryHigh = "Very High"
    }

    enum TimeOfDay: String, Codable {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
    }
}

// MARK: - FactorContribution
struct FactorContribution: Codable {
    let factor: Factor
    let score: Int // 1-10 contribution to overall
    let weight: Double
    let description: String

    enum Factor: String, Codable, CaseIterable {
        case weather = "Weather"
        case calendarEvents = "Calendar Events"
        case taskLoad = "Task Load"
        case moodTrend = "Mood Trend"
        case dayOfWeek = "Day of Week"
        case pastReflections = "Past Reflections"
        case energyPattern = "Energy Pattern"

        var icon: String {
            switch self {
            case .weather: return "cloud.sun"
            case .calendarEvents: return "calendar"
            case .taskLoad: return "checklist"
            case .moodTrend: return "chart.line.uptrend.xyaxis"
            case .dayOfWeek: return "calendar.day.timeline.left"
            case .pastReflections: return "brain"
            case .energyPattern: return "bolt"
            }
        }
    }
}

// MARK: - AIAnticipationService
@MainActor
final class AIAnticipationService {
    static let shared = AIAnticipationService()

    private let dataService = DataService.shared
    private let sentimentAnalyzer = NLTagger(tagSchemes: [.sentimentScore])

    private init() {}

    // MARK: - Main Prediction
    func predictTomorrow() -> TomorrowPrediction {
        let factors = calculateFactors()
        let overallScore = calculateOverallScore(from: factors)
        let summary = generateSummary(score: overallScore, factors: factors)
        let highlights = extractHighlights(factors: factors)
        let concerns = extractConcerns(factors: factors)
        let weather = predictWeather()
        let intention = generateSuggestedIntention(factors: factors, score: overallScore)
        let energy = estimateEnergyLevel(factors: factors)
        let bestTime = determineBestTimeForDeepWork(energy: energy, factors: factors)
        let mood = predictMood(score: overallScore, factors: factors)

        return TomorrowPrediction(
            anticipationScore: overallScore,
            summary: summary,
            highlights: highlights,
            concerns: concerns,
            weather: weather,
            factors: factors,
            suggestedIntention: intention,
            energyLevel: energy,
            bestTimeForDeepWork: bestTime,
            predictedMood: mood
        )
    }

    // MARK: - Factor Analysis
    private func calculateFactors() -> [FactorContribution] {
        var factors: [FactorContribution] = []

        // Weather factor
        factors.append(calculateWeatherFactor())

        // Calendar events factor
        factors.append(calculateCalendarFactor())

        // Task load factor
        factors.append(calculateTaskLoadFactor())

        // Mood trend factor
        factors.append(calculateMoodTrendFactor())

        // Day of week factor
        factors.append(calculateDayOfWeekFactor())

        // Past reflections factor
        factors.append(calculateReflectionFactor())

        // Energy pattern factor
        factors.append(calculateEnergyPatternFactor())

        return factors
    }

    private func calculateWeatherFactor() -> FactorContribution {
        let forecast = dataService.getTomorrowForecast()
        var score = 7 // Default neutral

        if let condition = forecast.weatherCondition {
            switch condition {
            case .sunny:
                score = 9
            case .partlyCloudy:
                score = 8
            case .cloudy:
                score = 6
            case .rainy:
                score = 5
            case .stormy:
                score = 3
            case .snowy:
                score = 4
            case .windy:
                score = 5
            }
        }

        let description: String
        if let condition = forecast.weatherCondition {
            description = "\(condition.rawValue) (\(forecast.temperatureHigh ?? 70)°)"
        } else {
            description = "Weather forecast unavailable"
        }

        return FactorContribution(
            factor: .weather,
            score: score,
            weight: 0.15,
            description: description
        )
    }

    private func calculateCalendarFactor() -> FactorContribution {
        let events = dataService.getTomorrowEvents()
        var score = 7
        var description = "No major events"

        let highStressKeywords = ["interview", "presentation", "deadline", "review", "exam"]
        let socialKeywords = ["dinner", "party", "birthday", "wedding", "celebration"]

        var eventDescriptions: [String] = []
        for event in events {
            let lowercased = event.title.lowercased()
            if highStressKeywords.contains(where: { lowercased.contains($0) }) {
                score = max(3, score - 2)
                eventDescriptions.append("High-stakes: \(event.title)")
            } else if socialKeywords.contains(where: { lowercased.contains($0) }) {
                score = min(9, score + 1)
                eventDescriptions.append("Social: \(event.title)")
            }
        }

        if !events.isEmpty {
            description = "\(events.count) event(s): \(events.map(\.title).joined(separator: ", "))"
        }

        return FactorContribution(
            factor: .calendarEvents,
            score: score,
            weight: 0.20,
            description: description
        )
    }

    private func calculateTaskLoadFactor() -> FactorContribution {
        let tasks = dataService.getTomorrowTasks()
        let highPriority = tasks.filter { $0.priority == .high }
        let mediumPriority = tasks.filter { $0.priority == .medium }
        let lowPriority = tasks.filter { $0.priority == .low }

        var score = 7

        // High priority tasks reduce score (more stress)
        if highPriority.count >= 3 {
            score = 4
        } else if highPriority.count == 2 {
            score = 5
        } else if highPriority.count == 1 {
            score = 6
        }

        // Low priority balance improves score
        if lowPriority.count > highPriority.count {
            score = min(9, score + 1)
        }

        let description = "\(highPriority.count) high, \(mediumPriority.count) medium, \(lowPriority.count) low priority"

        return FactorContribution(
            factor: .taskLoad,
            score: score,
            weight: 0.20,
            description: description
        )
    }

    private func calculateMoodTrendFactor() -> FactorContribution {
        let reflections = dataService.reflections.suffix(7)
        guard !reflections.isEmpty else {
            return FactorContribution(
                factor: .moodTrend,
                score: 6,
                weight: 0.15,
                description: "No recent reflections to analyze"
            )
        }

        let avgMood = reflections.map(\.anticipationRating).reduce(0, +) / reflections.count
        let avgScore = mapMoodToScore(avgMood)

        // Detect trend
        let trend = detectTrend(from: Array(reflections))

        var description: String
        if trend > 0.2 {
            description = "Improving mood trend (avg: \(String(format: "%.1f", avgMood))/5)"
        } else if trend < -0.2 {
            description = "Declining mood trend (avg: \(String(format: "%.1f", avgMood))/5)"
        } else {
            description = "Stable mood pattern (avg: \(String(format: "%.1f", avgMood))/5)"
        }

        return FactorContribution(
            factor: .moodTrend,
            score: avgScore,
            weight: 0.15,
            description: description
        )
    }

    private func calculateDayOfWeekFactor() -> FactorContribution {
        let tomorrow = dataService.tomorrowDate
        let weekday = Calendar.current.component(.weekday, from: tomorrow)

        var score: Int
        var description: String

        switch weekday {
        case 1: // Sunday
            score = 8
            description = "Sunday - recovery day"
        case 2: // Monday
            score = 5
            description = "Monday - fresh start"
        case 3: // Tuesday
            score = 6
            description = "Tuesday - building momentum"
        case 4: // Wednesday
            score = 7
            description = "Wednesday - midweek peak"
        case 5: // Thursday
            score = 7
            description = "Thursday - almost there"
        case 6: // Friday
            score = 8
            description = "Friday - week winding down"
        case 7: // Saturday
            score = 9
            description = "Saturday - weekend energy"
        default:
            score = 6
            description = "Typical weekday"
        }

        return FactorContribution(
            factor: .dayOfWeek,
            score: score,
            weight: 0.10,
            description: description
        )
    }

    private func calculateReflectionFactor() -> FactorContribution {
        guard let todayReflection = dataService.getTodayReflection() else {
            return FactorContribution(
                factor: .pastReflections,
                score: 6,
                weight: 0.10,
                description: "No reflection today yet"
            )
        }

        // Analyze sentiment of today's reflection
        let sentimentScore = analyzeSentiment(todayReflection.howWasToday)
        let highlightScore = analyzeSentiment(todayReflection.highlight)

        let avgScore = Int((sentimentScore + highlightScore) / 2 * 10)

        let description: String
        if sentimentScore > 0.3 {
            description = "Positive reflection: '\(todayReflection.highlight.prefix(30))...'"
        } else if sentimentScore < -0.3 {
            description = "Difficult day: '\(todayReflection.highlight.prefix(30))...'"
        } else {
            description = "Neutral reflection: '\(todayReflection.highlight.prefix(30))...'"
        }

        return FactorContribution(
            factor: .pastReflections,
            score: max(1, min(10, avgScore)),
            weight: 0.10,
            description: description
        )
    }

    private func calculateEnergyPatternFactor() -> FactorContribution {
        // Analyze historical patterns
        let reflections = dataService.reflections.suffix(14)
        guard !reflections.isEmpty else {
            return FactorContribution(
                factor: .energyPattern,
                score: 6,
                weight: 0.10,
                description: "Not enough data for pattern"
            )
        }

        // Look for energy-related keywords in reflections
        var energyKeywords = 0
        for reflection in reflections {
            let text = "\(reflection.howWasToday) \(reflection.highlight)".lowercased()
            let keywords = ["tired", "energized", "exhausted", "motivated", "drained", "focused", "productive"]
            energyKeywords += keywords.filter { text.contains($0) }.count
        }

        var score = 6
        if energyKeywords > 5 {
            score = 8
        } else if energyKeywords > 3 {
            score = 7
        } else if energyKeywords < 2 {
            score = 5
        }

        return FactorContribution(
            factor: .energyPattern,
            score: score,
            weight: 0.10,
            description: "Based on \(reflections.count) recent reflections"
        )
    }

    // MARK: - Score Calculation
    private func calculateOverallScore(from factors: [FactorContribution]) -> Int {
        var weightedSum = 0.0
        var totalWeight = 0.0

        for factor in factors {
            weightedSum += Double(factor.score) * factor.weight
            totalWeight += factor.weight
        }

        let rawScore = weightedSum / totalWeight
        return max(1, min(10, Int(rawScore.rounded())))
    }

    private func mapMoodToScore(_ mood: Int) -> Int {
        // Mood is 1-5, convert to 1-10
        return (mood - 1) * 2 + 1
    }

    private func detectTrend(from reflections: [Reflection]) -> Double {
        guard reflections.count >= 2 else { return 0 }

        let ratings = reflections.map(\.anticipationRating)
        let midpoint = ratings.count / 2

        let firstHalf = Array(ratings.prefix(midpoint))
        let secondHalf = Array(ratings.suffix(midpoint))

        let firstAvg = Double(firstHalf.reduce(0, +)) / max(1, Double(firstHalf.count))
        let secondAvg = Double(secondHalf.reduce(0, +)) / max(1, Double(secondHalf.count))

        return (secondAvg - firstAvg) / 5.0
    }

    // MARK: - Sentiment Analysis
    private func analyzeSentiment(_ text: String) -> Double {
        guard !text.isEmpty else { return 0 }

        sentimentAnalyzer.string = text
        var totalScore = 0.0
        var count = 0

        sentimentAnalyzer.enumerateTags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                totalScore += score
                count += 1
            }
            return true
        }

        return count > 0 ? totalScore / Double(count) : 0
    }

    // MARK: - Summary Generation
    private func generateSummary(score: Int, factors: [FactorContribution]) -> String {
        let weatherFactor = factors.first { $0.factor == .weather }
        let taskFactor = factors.first { $0.factor == .taskLoad }
        let dayFactor = factors.first { $0.factor == .dayOfWeek }

        var summary: String

        switch score {
        case 9...10:
            summary = "Tomorrow looks exceptional! The combination of favorable conditions has you set up for a great day."
        case 7...8:
            summary = "Tomorrow is shaping up nicely with good energy and manageable demands."
        case 5...6:
            summary = "Tomorrow will be a steady day with a balanced mix of opportunities and challenges."
        case 3...4:
            summary = "Tomorrow might present some headwinds. Consider planning extra buffer time."
        default:
            summary = "Tomorrow may be challenging. Prioritize self-care and essential tasks."
        }

        if let weather = weatherFactor, weather.score >= 8 {
            summary += " The weather should lift your spirits."
        }

        if let tasks = taskFactor, tasks.score <= 4 {
            summary += " Your task load is heavy—consider what can be delegated or deferred."
        }

        if let day = dayFactor, day.score >= 8 {
            summary += " It's a great day of the week to tackle something meaningful."
        }

        return summary
    }

    private func extractHighlights(factors: [FactorContribution]) -> [String] {
        var highlights: [String] = []

        for factor in factors where factor.score >= 8 {
            switch factor.factor {
            case .weather:
                highlights.append("Great weather ahead!")
            case .calendarEvents:
                if factor.description.contains("Social") {
                    highlights.append("Social event to look forward to")
                }
            case .taskLoad:
                highlights.append("Manageable task load")
            case .moodTrend:
                if factor.description.contains("Improving") {
                    highlights.append("Your mood is trending upward")
                }
            case .dayOfWeek:
                highlights.append("\(factor.description) - energy bonus")
            case .pastReflections:
                highlights.append("Positive reflections suggest good momentum")
            case .energyPattern:
                highlights.append("Historical patterns show good energy levels")
            }
        }

        return highlights
    }

    private func extractConcerns(factors: [FactorContribution]) -> [String] {
        var concerns: [String] = []

        for factor in factors where factor.score <= 4 {
            switch factor.factor {
            case .weather:
                concerns.append("Weather may affect plans")
            case .calendarEvents:
                if factor.description.contains("High-stakes") {
                    concerns.append("High-stakes event scheduled")
                }
            case .taskLoad:
                concerns.append("Heavy task load - prioritize ruthlessly")
            case .moodTrend:
                if factor.description.contains("Declining") {
                    concerns.append("Mood has been declining - extra self-care needed")
                }
            case .dayOfWeek:
                concerns.append("Potentially challenging day of week")
            case .pastReflections:
                concerns.append("Recent reflections suggest difficulties")
            case .energyPattern:
                concerns.append("Energy patterns suggest potential fatigue")
            }
        }

        return concerns
    }

    private func predictWeather() -> String {
        let forecast = dataService.getTomorrowForecast()
        if let condition = forecast.weatherCondition {
            if let high = forecast.temperatureHigh, let low = forecast.temperatureLow {
                return "\(condition.rawValue), \(high)°/\(low)°"
            }
            return condition.rawValue
        }
        return "Weather forecast unavailable"
    }

    private func generateSuggestedIntention(factors: [FactorContribution], score: Int) -> String? {
        let moodFactor = factors.first { $0.factor == .moodTrend }
        let reflectionFactor = factors.first { $0.factor == .pastReflections }
        let taskFactor = factors.first { $0.factor == .taskLoad }

        // If today had a positive reflection, suggest carrying that forward
        if let rf = reflectionFactor, rf.description.contains("Positive") {
            return "Carry today's positive energy into tomorrow's challenges"
        }

        // If mood is improving, suggest building on momentum
        if let mf = moodFactor, mf.description.contains("Improving") {
            return "Build on the positive momentum from recent days"
        }

        // If task load is heavy, suggest prioritization
        if let tf = taskFactor, tf.score <= 4 {
            return "Focus on what truly matters - let go of the rest"
        }

        // Default intentions based on score
        switch score {
        case 8...10:
            return "Make the most of tomorrow's favorable energy"
        case 5...7:
            return "Find balance between productivity and rest"
        default:
            return "Prioritize essential tasks and gentle self-care"
        }
    }

    private func estimateEnergyLevel(factors: [FactorContribution]) -> TomorrowPrediction.EnergyLevel {
        let moodFactor = factors.first { $0.factor == .moodTrend }
        let energyFactor = factors.first { $0.factor == .energyPattern }
        let dayFactor = factors.first { $0.factor == .dayOfWeek }

        var energySum = 0
        var count = 0

        if let mf = moodFactor { energySum += mf.score; count += 1 }
        if let ef = energyFactor { energySum += ef.score; count += 1 }
        if let df = dayFactor { energySum += df.score; count += 1 }

        let avg = count > 0 ? energySum / count : 5

        switch avg {
        case 8...10: return .veryHigh
        case 6..<8: return .high
        case 4..<6: return .moderate
        default: return .low
        }
    }

    private func determineBestTimeForDeepWork(energy: TomorrowPrediction.EnergyLevel, factors: [FactorContribution]) -> TomorrowPrediction.TimeOfDay? {
        // Check calendar for existing commitments
        let events = dataService.getTomorrowEvents()

        // Morning people typically peak early
        // Afternoon people peak mid-day
        // Evening people peak later

        let hasMorningEvent = events.contains { Calendar.current.component(.hour, from: $0.startTime) < 12 }
        let hasAfternoonEvent = events.contains { (12..<17).contains(Calendar.current.component(.hour, from: $0.startTime)) }

        switch energy {
        case .veryHigh:
            if !hasMorningEvent {
                return .morning
            } else if !hasAfternoonEvent {
                return .afternoon
            }
            return .evening
        case .high:
            if !hasMorningEvent {
                return .morning
            }
            return .afternoon
        case .moderate:
            return .afternoon
        case .low:
            return .morning // Start early when energy is higher
        }
    }

    private func predictMood(score: Int, factors: [FactorContribution]) -> String {
        let moodFactor = factors.first { $0.factor == .moodTrend }

        if let mf = moodFactor {
            if mf.score >= 8 { return "Optimistic" }
            if mf.score >= 6 { return "Hopeful" }
            if mf.score >= 4 { return "Cautiously Neutral" }
            if mf.score >= 2 { return "Concerned" }
            return "Anxious"
        }

        switch score {
        case 8...10: return "Energetic"
        case 6..<8: return "Balanced"
        case 4..<6: return "Steady"
        default: return "Restorative"
        }
    }
}
