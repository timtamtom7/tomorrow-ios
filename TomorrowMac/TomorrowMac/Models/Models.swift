import Foundation

// MARK: - TomorrowTask
struct TomorrowTask: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var priority: Priority
    var category: Category
    var createdAt: Date

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, priority: Priority = .medium, category: Category = .general) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.createdAt = Date()
    }

    enum Priority: String, Codable, CaseIterable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"

        var color: String {
            switch self {
            case .high: return "EF4444"
            case .medium: return "F59E0B"
            case .low: return "10B981"
            }
        }
    }

    enum Category: String, Codable, CaseIterable {
        case general = "General"
        case work = "Work"
        case personal = "Personal"
        case health = "Health"
        case social = "Social"
        case creative = "Creative"

        var icon: String {
            switch self {
            case .general: return "square.grid.2x2"
            case .work: return "briefcase"
            case .personal: return "person"
            case .health: return "heart"
            case .social: return "person.2"
            case .creative: return "paintbrush"
            }
        }
    }
}

// MARK: - TomorrowEvent
struct TomorrowEvent: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var startTime: Date
    var endTime: Date?
    var location: String?
    var notes: String?
    var colorHex: String

    init(id: UUID = UUID(), title: String, startTime: Date, endTime: Date? = nil, location: String? = nil, notes: String? = nil, colorHex: String = "3B82F6") {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.notes = notes
        self.colorHex = colorHex
    }
}

// MARK: - Reflection
struct Reflection: Identifiable, Codable {
    let id: UUID
    var date: Date
    var howWasToday: String
    var highlight: String
    var lowlight: String?
    var anticipationRating: Int // 1-5
    var tomorrowIntention: String?
    var mood: Mood

    init(id: UUID = UUID(), date: Date = Date(), howWasToday: String = "", highlight: String = "", lowlight: String? = nil, anticipationRating: Int = 3, tomorrowIntention: String? = nil, mood: Mood = .neutral) {
        self.id = id
        self.date = date
        self.howWasToday = howWasToday
        self.highlight = highlight
        self.lowlight = lowlight
        self.anticipationRating = anticipationRating
        self.tomorrowIntention = tomorrowIntention
        self.mood = mood
    }

    enum Mood: String, Codable, CaseIterable {
        case great = "Great"
        case good = "Good"
        case neutral = "Neutral"
        case tough = "Tough"
        case hard = "Hard"

        var icon: String {
            switch self {
            case .great: return "face.smiling"
            case .good: return "hand.thumbsup"
            case .neutral: return "minus.circle"
            case .tough: return "cloud.rain"
            case .hard: return "bolt.circle"
            }
        }

        var color: String {
            switch self {
            case .great: return "10B981"
            case .good: return "3B82F6"
            case .neutral: return "F59E0B"
            case .tough: return "F97316"
            case .hard: return "EF4444"
            }
        }
    }
}

// MARK: - TomorrowForecast
struct TomorrowForecast: Identifiable, Codable {
    let id: UUID
    let date: Date
    var weatherCondition: WeatherCondition?
    var temperatureHigh: Int?
    var temperatureLow: Int?
    var tasks: [TomorrowTask]
    var events: [TomorrowEvent]
    var moodPrediction: Int? // 1-5 predicted mood
    var aiSuggestion: String?
    var reflection: Reflection?

    init(id: UUID = UUID(), date: Date = Date(), weatherCondition: WeatherCondition? = nil, temperatureHigh: Int? = nil, temperatureLow: Int? = nil, tasks: [TomorrowTask] = [], events: [TomorrowEvent] = [], moodPrediction: Int? = nil, aiSuggestion: String? = nil, reflection: Reflection? = nil) {
        self.id = id
        self.date = date
        self.weatherCondition = weatherCondition
        self.temperatureHigh = temperatureHigh
        self.temperatureLow = temperatureLow
        self.tasks = tasks
        self.events = events
        self.moodPrediction = moodPrediction
        self.aiSuggestion = aiSuggestion
        self.reflection = reflection
    }

    enum WeatherCondition: String, Codable, CaseIterable {
        case sunny = "Sunny"
        case partlyCloudy = "Partly Cloudy"
        case cloudy = "Cloudy"
        case rainy = "Rainy"
        case stormy = "Stormy"
        case snowy = "Snowy"
        case windy = "Windy"

        var icon: String {
            switch self {
            case .sunny: return "sun.max.fill"
            case .partlyCloudy: return "cloud.sun.fill"
            case .cloudy: return "cloud.fill"
            case .rainy: return "cloud.rain.fill"
            case .stormy: return "cloud.bolt.rain.fill"
            case .snowy: return "snowflake"
            case .windy: return "wind"
            }
        }
    }
}

// MARK: - Intention
struct Intention: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var category: String
    var order: Int

    init(id: UUID = UUID(), text: String, category: String = "General", order: Int = 0) {
        self.id = id
        self.text = text
        self.category = category
        self.order = order
    }
}
