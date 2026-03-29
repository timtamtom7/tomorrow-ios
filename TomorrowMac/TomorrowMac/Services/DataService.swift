import Foundation

// MARK: - DataService
@MainActor
@Observable
final class DataService {
    static let shared: DataService = DataService()

    private let defaults = UserDefaults.standard
    private let tasksKey = "tomorrow_tasks"
    private let eventsKey = "tomorrow_events"
    private let forecastsKey = "tomorrow_forecasts"
    private let intentionsKey = "tomorrow_intentions"
    private let reflectionsKey = "tomorrow_reflections"

    var tasks: [TomorrowTask] = []
    var events: [TomorrowEvent] = []
    var forecasts: [TomorrowForecast] = []
    var intentions: [Intention] = []
    var reflections: [Reflection] = []

    private init() {
        load()
    }

    // MARK: - Load / Save
    func load() {
        tasks = loadArray(TomorrowTask.self, forKey: tasksKey)
        events = loadArray(TomorrowEvent.self, forKey: eventsKey)
        forecasts = loadArray(TomorrowForecast.self, forKey: forecastsKey)
        intentions = loadArray(Intention.self, forKey: intentionsKey)
        reflections = loadArray(Reflection.self, forKey: reflectionsKey)
    }

    func save() {
        saveArray(tasks, forKey: tasksKey)
        saveArray(events, forKey: eventsKey)
        saveArray(forecasts, forKey: forecastsKey)
        saveArray(intentions, forKey: intentionsKey)
        saveArray(reflections, forKey: reflectionsKey)
    }

    // MARK: - Tomorrow's Date
    var tomorrowDate: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }

    var tomorrowStart: Date {
        Calendar.current.startOfDay(for: tomorrowDate)
    }

    var tomorrowEnd: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: tomorrowStart) ?? tomorrowDate
    }

    // MARK: - Tomorrow's Forecast
    func getTomorrowForecast() -> TomorrowForecast {
        if let existing = forecasts.first(where: { Calendar.current.isDate($0.date, inSameDayAs: tomorrowStart) }) {
            return existing
        }
        let newForecast = TomorrowForecast(date: tomorrowStart)
        forecasts.append(newForecast)
        save()
        return newForecast
    }

    func updateForecast(_ forecast: TomorrowForecast) {
        if let index = forecasts.firstIndex(where: { $0.id == forecast.id }) {
            forecasts[index] = forecast
        } else {
            forecasts.append(forecast)
        }
        save()
    }

    // MARK: - Tasks
    func addTask(_ task: TomorrowTask) {
        tasks.append(task)
        save()
    }

    func updateTask(_ task: TomorrowTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            save()
        }
    }

    func deleteTask(_ task: TomorrowTask) {
        tasks.removeAll { $0.id == task.id }
        save()
    }

    func getTomorrowTasks() -> [TomorrowTask] {
        tasks.filter { !Calendar.current.isDateInToday($0.createdAt) || !$0.isCompleted }
    }

    // MARK: - Events
    func addEvent(_ event: TomorrowEvent) {
        events.append(event)
        save()
    }

    func updateEvent(_ event: TomorrowEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            save()
        }
    }

    func deleteEvent(_ event: TomorrowEvent) {
        events.removeAll { $0.id == event.id }
        save()
    }

    func getTomorrowEvents() -> [TomorrowEvent] {
        events.filter { event in
            event.startTime >= tomorrowStart && event.startTime < tomorrowEnd
        }.sorted { $0.startTime < $1.startTime }
    }

    // MARK: - Intentions
    func addIntention(_ intention: Intention) {
        var intention = intention
        intention.order = intentions.count
        intentions.append(intention)
        save()
    }

    func updateIntention(_ intention: Intention) {
        if let index = intentions.firstIndex(where: { $0.id == intention.id }) {
            intentions[index] = intention
            save()
        }
    }

    func deleteIntention(_ intention: Intention) {
        intentions.removeAll { $0.id == intention.id }
        save()
    }

    func reorderIntentions(_ reordered: [Intention]) {
        intentions = reordered.enumerated().map { index, intention in
            var updated = intention
            updated.order = index
            return updated
        }
        save()
    }

    func getTomorrowIntentions() -> [Intention] {
        intentions.sorted { $0.order < $1.order }
    }

    // MARK: - Reflections
    func addReflection(_ reflection: Reflection) {
        reflections.append(reflection)
        save()
    }

    func getTodayReflection() -> Reflection? {
        let today = Calendar.current.startOfDay(for: Date())
        return reflections.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    func hasReflectedToday() -> Bool {
        getTodayReflection() != nil
    }

    // MARK: - 7-Day Forecast
    func getSevenDayForecasts() -> [TomorrowForecast] {
        var result: [TomorrowForecast] = []
        let calendar = Calendar.current
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
            let startOfDay = calendar.startOfDay(for: date)

            if let forecast = forecasts.first(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) {
                result.append(forecast)
            } else {
                result.append(TomorrowForecast(date: startOfDay))
            }
        }
        return result
    }

    // MARK: - Private Helpers
    private func loadArray<T: Decodable>(_ type: T.Type, forKey key: String) -> [T] {
        guard let data = defaults.data(forKey: key),
              let array = try? JSONDecoder().decode([T].self, from: data) else {
            return []
        }
        return array
    }

    private func saveArray<T: Encodable>(_ array: [T], forKey key: String) {
        if let data = try? JSONEncoder().encode(array) {
            defaults.set(data, forKey: key)
        }
    }
}
