import Foundation

// MARK: - ScheduledTask
struct ScheduledTask: Identifiable, Codable {
    let id: UUID
    let task: TomorrowTask
    var suggestedTime: Date
    var timeSlot: TimeSlot
    var reasoning: String
    var confidence: Double // 0-1 how confident the AI is

    enum TimeSlot: String, Codable, CaseIterable {
        case morning = "Morning (6am-12pm)"
        case afternoon = "Afternoon (12pm-5pm)"
        case evening = "Evening (5pm-9pm)"
        case night = "Night (9pm+)"

        var icon: String {
            switch self {
            case .morning: return "sunrise"
            case .afternoon: return "sun.max"
            case .evening: return "sunset"
            case .night: return "moon.stars"
            }
        }

        var hourRange: ClosedRange<Int> {
            switch self {
            case .morning: return 6...11
            case .afternoon: return 12...16
            case .evening: return 17...20
            case .night: return 21...23
            }
        }

        var energyLevel: EnergyRequirement {
            switch self {
            case .morning: return .high
            case .afternoon: return .medium
            case .evening: return .low
            case .night: return .minimal
            }
        }

        enum EnergyRequirement {
            case high, medium, low, minimal
        }
    }
}

// MARK: - EnergyProfile
struct EnergyProfile: Codable {
    var morningEfficiency: Double // 0-1
    var afternoonEfficiency: Double // 0-1
    var eveningEfficiency: Double // 0-1
    var preferredDeepWorkTime: ScheduledTask.TimeSlot
    var avgCompletionRate: Double

    static var defaultProfile: EnergyProfile {
        EnergyProfile(
            morningEfficiency: 0.7,
            afternoonEfficiency: 0.6,
            eveningEfficiency: 0.4,
            preferredDeepWorkTime: .morning,
            avgCompletionRate: 0.75
        )
    }
}

// MARK: - SchedulingSuggestion
struct SchedulingSuggestion: Identifiable, Codable {
    let id: UUID
    let message: String
    let tasks: [ScheduledTask]
    let warnings: [String]
    let opportunities: [String]

    init(id: UUID = UUID(), message: String, tasks: [ScheduledTask], warnings: [String] = [], opportunities: [String] = []) {
        self.id = id
        self.message = message
        self.tasks = tasks
        self.warnings = warnings
        self.opportunities = opportunities
    }
}

// MARK: - SchedulingAIService
@MainActor
final class SchedulingAIService {
    static let shared = SchedulingAIService()

    private let dataService = DataService.shared
    private let anticipationService = AIAnticipationService.shared

    private let energyProfilesKey = "tomorrow_energy_profiles"
    private var energyProfiles: [UUID: EnergyProfile] = [:]

    private init() {
        loadEnergyProfiles()
    }

    // MARK: - Main Scheduling
    func generateSchedule(for date: Date = Date()) -> SchedulingSuggestion {
        let tasks = dataService.getTomorrowTasks()
        let events = dataService.getTomorrowEvents()
        let prediction = anticipationService.predictTomorrow()

        var scheduledTasks: [ScheduledTask] = []
        var warnings: [String] = []
        var opportunities: [String] = []

        // Analyze task characteristics
        let deepWorkTasks = tasks.filter { isDeepWorkTask($0) }
        let creativeTasks = tasks.filter { isCreativeTask($0) }
        let administrativeTasks = tasks.filter { isAdministrativeTask($0) }
        let highPriorityTasks = tasks.filter { $0.priority == .high }

        // Check for conflicts
        if highPriorityTasks.count > 3 {
            warnings.append("You have \(highPriorityTasks.count) high-priority tasks scheduled. Consider deferring some.")
        }

        // Check energy vs demand
        if prediction.energyLevel == .low && !highPriorityTasks.isEmpty {
            warnings.append("Tomorrow's energy is low but you have high-priority tasks. Consider scheduling them when you're sharpest.")
        }

        // Schedule deep work during optimal times
        for task in deepWorkTasks {
            let scheduled = scheduleTask(
                task,
                events: events,
                prediction: prediction,
                profile: getOrCreateProfile()
            )
            scheduledTasks.append(scheduled)
        }

        // Schedule creative tasks
        for task in creativeTasks {
            let scheduled = scheduleTask(
                task,
                events: events,
                prediction: prediction,
                profile: getOrCreateProfile()
            )
            scheduledTasks.append(scheduled)
        }

        // Schedule administrative tasks during lower energy times
        for task in administrativeTasks {
            let scheduled = scheduleTask(
                task,
                events: events,
                prediction: prediction,
                profile: getOrCreateProfile()
            )
            scheduledTasks.append(scheduled)
        }

        // Schedule remaining general tasks
        let scheduledIds = Set(scheduledTasks.map(\.task.id))
        for task in tasks where !scheduledIds.contains(task.id) {
            let scheduled = scheduleTask(
                task,
                events: events,
                prediction: prediction,
                profile: getOrCreateProfile()
            )
            scheduledTasks.append(scheduled)
        }

        // Identify opportunities
        if prediction.energyLevel == .high && deepWorkTasks.count >= 2 {
            opportunities.append("High energy day - ideal for tackling challenging deep work")
        }

        if let bestTime = prediction.bestTimeForDeepWork {
            opportunities.append("AI suggests \(bestTime.rawValue) for your most demanding tasks")
        }

        if events.isEmpty {
            opportunities.append("No scheduled events - full day available for your priorities")
        }

        // Generate message
        let message = generateScheduleMessage(
            taskCount: tasks.count,
            prediction: prediction,
            warnings: warnings,
            opportunities: opportunities
        )

        return SchedulingSuggestion(
            message: message,
            tasks: scheduledTasks.sorted { $0.suggestedTime < $1.suggestedTime },
            warnings: warnings,
            opportunities: opportunities
        )
    }

    // MARK: - Task Classification
    private func isDeepWorkTask(_ task: TomorrowTask) -> Bool {
        let deepWorkKeywords = ["write", "code", "design", "plan", "strategy", "analyze", "review", "learn"]
        let category = task.category

        if category == .work || category == .creative {
            let lowercased = task.title.lowercased()
            return deepWorkKeywords.contains { lowercased.contains($0) }
        }

        return false
    }

    private func isCreativeTask(_ task: TomorrowTask) -> Bool {
        let creativeKeywords = [" brainstorm", "create", "sketch", "compose", "art", "music", "write"]
        let lowercased = task.title.lowercased()
        return creativeKeywords.contains { lowercased.contains($0) } || task.category == .creative
    }

    private func isAdministrativeTask(_ task: TomorrowTask) -> Bool {
        let adminKeywords = ["email", "reply", "schedule", "organize", "file", "update", "check"]
        let lowercased = task.title.lowercased()
        return adminKeywords.contains { lowercased.contains($0) }
    }

    private func isHighEnergyTask(_ task: TomorrowTask) -> Bool {
        return task.priority == .high || isDeepWorkTask(task)
    }

    // MARK: - Scheduling Logic
    private func scheduleTask(
        _ task: TomorrowTask,
        events: [TomorrowEvent],
        prediction: TomorrowPrediction,
        profile: EnergyProfile
    ) -> ScheduledTask {
        let preferredSlot = determineOptimalSlot(
            for: task,
            events: events,
            prediction: prediction,
            profile: profile
        )

        let suggestedTime = determineTimeWithinSlot(
            slot: preferredSlot,
            task: task,
            events: events
        )

        let reasoning = generateReasoning(
            task: task,
            slot: preferredSlot,
            prediction: prediction,
            profile: profile
        )

        let confidence = calculateConfidence(
            task: task,
            slot: preferredSlot,
            events: events,
            profile: profile
        )

        return ScheduledTask(
            id: UUID(),
            task: task,
            suggestedTime: suggestedTime,
            timeSlot: preferredSlot,
            reasoning: reasoning,
            confidence: confidence
        )
    }

    private func determineOptimalSlot(
        for task: TomorrowTask,
        events: [TomorrowEvent],
        prediction: TomorrowPrediction,
        profile: EnergyProfile
    ) -> ScheduledTask.TimeSlot {
        // Check event conflicts
        let occupiedSlots = determineOccupiedSlots(from: events)

        // High energy tasks need optimal energy times
        if isHighEnergyTask(task) {
            // If prediction suggests a specific time, use it
            if let bestTime = prediction.bestTimeForDeepWork,
               !occupiedSlots.contains(timeOfDayToSlot(bestTime)) {
                return timeOfDayToSlot(bestTime)
            }

            // Fall back to profile preference
            let preferred = profile.preferredDeepWorkTime
            if !occupiedSlots.contains(preferred) {
                return preferred
            }

            // Find first available high-energy slot
            for slot in [ScheduledTask.TimeSlot.morning,
                         .afternoon,
                         .evening] as [ScheduledTask.TimeSlot] {
                if !occupiedSlots.contains(slot) {
                    return slot
                }
            }
        }

        // Low energy tasks can go in quieter times
        if task.priority == .low || isAdministrativeTask(task) {
            // Prefer evening if available
            if !occupiedSlots.contains(.evening) {
                return .evening
            }
            if !occupiedSlots.contains(.night) {
                return .night
            }
        }

        // Default: find first available slot
        for slot in ScheduledTask.TimeSlot.allCases {
            if !occupiedSlots.contains(slot) {
                return slot
            }
        }

        return .evening // fallback
    }

    private func timeOfDayToSlot(_ time: TomorrowPrediction.TimeOfDay) -> ScheduledTask.TimeSlot {
        switch time {
        case .morning: return .morning
        case .afternoon: return .afternoon
        case .evening: return .evening
        }
    }

    private func determineOccupiedSlots(from events: [TomorrowEvent]) -> Set<ScheduledTask.TimeSlot> {
        var occupied = Set<ScheduledTask.TimeSlot>()

        for event in events {
            let hour = Calendar.current.component(.hour, from: event.startTime)

            if ScheduledTask.TimeSlot.morning.hourRange.contains(hour) {
                occupied.insert(.morning)
            } else if ScheduledTask.TimeSlot.afternoon.hourRange.contains(hour) {
                occupied.insert(.afternoon)
            } else if ScheduledTask.TimeSlot.evening.hourRange.contains(hour) {
                occupied.insert(.evening)
            } else {
                occupied.insert(.night)
            }
        }

        return occupied
    }

    private func determineTimeWithinSlot(
        slot: ScheduledTask.TimeSlot,
        task: TomorrowTask,
        events: [TomorrowEvent]
    ) -> Date {
        let tomorrow = dataService.tomorrowDate
        var components = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)

        // Find a gap in events within the slot
        let slotEvents = events.filter { event in
            let hour = Calendar.current.component(.hour, from: event.startTime)
            return slot.hourRange.contains(hour)
        }.sorted { $0.startTime < $1.startTime }

        // Default to middle of slot
        let defaultHour: Int
        switch slot {
        case .morning: defaultHour = 9
        case .afternoon: defaultHour = 14
        case .evening: defaultHour = 18
        case .night: defaultHour = 21
        }

        components.hour = defaultHour
        components.minute = 0

        return Calendar.current.date(from: components) ?? tomorrow
    }

    private func generateReasoning(
        task: TomorrowTask,
        slot: ScheduledTask.TimeSlot,
        prediction: TomorrowPrediction,
        profile: EnergyProfile
    ) -> String {
        var reasons: [String] = []

        // Task-type reasoning
        if isDeepWorkTask(task) {
            reasons.append("Deep work task benefits from \(slot.rawValue.lowercased()) energy levels")
        } else if isCreativeTask(task) {
            reasons.append("Creative task scheduled during \(slot.rawValue.lowercased()) for inspiration")
        } else if isAdministrativeTask(task) {
            reasons.append("Administrative task fits well in \(slot.rawValue.lowercased())")
        }

        // Priority reasoning
        if task.priority == .high {
            reasons.append("High priority - matched to your peak energy times")
        }

        // Prediction-based reasoning
        if prediction.energyLevel == .low {
            if isHighEnergyTask(task) {
                reasons.append("Energy is low tomorrow - plan to tackle this when you feel sharpest")
            }
        }

        // Pattern-based reasoning
        if profile.avgCompletionRate > 0.8 {
            reasons.append("Your completion rate suggests you can handle this")
        }

        return reasons.joined(separator: ". ") + "."
    }

    private func calculateConfidence(
        task: TomorrowTask,
        slot: ScheduledTask.TimeSlot,
        events: [TomorrowEvent],
        profile: EnergyProfile
    ) -> Double {
        var confidence = 0.7 // base confidence

        // Adjust based on energy match
        let slotEnergy: ScheduledTask.TimeSlot.EnergyRequirement
        switch slot {
        case .morning: slotEnergy = .high
        case .afternoon: slotEnergy = .medium
        case .evening: slotEnergy = .low
        case .night: slotEnergy = .minimal
        }

        if isHighEnergyTask(task) && (slotEnergy == .high || slotEnergy == .medium) {
            confidence += 0.15
        }

        // Adjust based on event conflicts
        let occupiedSlots = determineOccupiedSlots(from: events)
        if occupiedSlots.contains(slot) {
            confidence -= 0.2
        }

        // Adjust based on historical completion
        confidence += (profile.avgCompletionRate - 0.5) * 0.2

        return max(0.1, min(1.0, confidence))
    }

    private func generateScheduleMessage(
        taskCount: Int,
        prediction: TomorrowPrediction,
        warnings: [String],
        opportunities: [String]
    ) -> String {
        var message: String

        switch prediction.energyLevel {
        case .veryHigh, .high:
            message = "Tomorrow is shaping up to be productive! With \(prediction.energyLevel.rawValue.lowercased()) energy, you can tackle demanding tasks."
        case .moderate:
            message = "Tomorrow looks steady. Focus on what matters most and pace yourself."
        case .low:
            message = "Tomorrow may require extra care. Consider lighter tasks and build in rest."
        }

        if !warnings.isEmpty && !opportunities.isEmpty {
            message += " I've identified \(opportunities.count) opportunity and \(warnings.count) consideration."
        }

        return message
    }

    // MARK: - Rescheduling Suggestions
    func suggestReschedule(for task: TomorrowTask, to newSlot: ScheduledTask.TimeSlot) -> String {
        let prediction = anticipationService.predictTomorrow()

        if prediction.energyLevel == .low && isHighEnergyTask(task) {
            return "Caution: Tomorrow's energy is low. This \(isDeepWorkTask(task) ? "deep work task" : "high priority task") might be better suited for \(prediction.bestTimeForDeepWork?.rawValue.lowercased() ?? "when you're sharpest")."
        }

        if isCreativeTask(task) && newSlot == .night {
            return "Creative tasks may be harder to complete late at night when mental energy is lower."
        }

        return "Rescheduling to \(newSlot.rawValue) looks reasonable for this task."
    }

    // MARK: - Energy Profile Management
    func getOrCreateProfile() -> EnergyProfile {
        // For now, use default profile
        // In future, could analyze historical completion data
        return .defaultProfile
    }

    func updateProfileWithCompletion(
        taskId: UUID,
        completedAt: Date?,
        originalSlot: ScheduledTask.TimeSlot
    ) {
        var profile = getOrCreateProfile()

        // Adjust energy efficiency based on when task was completed
        if let completedAt = completedAt {
            let hour = Calendar.current.component(.hour, from: completedAt)

            let completedSlot: ScheduledTask.TimeSlot
            if ScheduledTask.TimeSlot.morning.hourRange.contains(hour) {
                completedSlot = .morning
            } else if ScheduledTask.TimeSlot.afternoon.hourRange.contains(hour) {
                completedSlot = .afternoon
            } else if ScheduledTask.TimeSlot.evening.hourRange.contains(hour) {
                completedSlot = .evening
            } else {
                completedSlot = .night
            }

            // If task was completed in a different slot than suggested, adjust efficiency
            if completedSlot == originalSlot {
                // Task completed as scheduled - positive reinforcement
                switch originalSlot {
                case .morning: profile.morningEfficiency = min(1.0, profile.morningEfficiency + 0.05)
                case .afternoon: profile.afternoonEfficiency = min(1.0, profile.afternoonEfficiency + 0.05)
                case .evening: profile.eveningEfficiency = min(1.0, profile.eveningEfficiency + 0.05)
                case .night: break
                }
            } else {
                // Task was rescheduled - may indicate poor initial prediction
                switch originalSlot {
                case .morning: profile.morningEfficiency = max(0.1, profile.morningEfficiency - 0.05)
                case .afternoon: profile.afternoonEfficiency = max(0.1, profile.afternoonEfficiency - 0.05)
                case .evening: profile.eveningEfficiency = max(0.1, profile.eveningEfficiency - 0.05)
                case .night: break
                }
            }
        }

        // Update completion rate
        profile.avgCompletionRate = (profile.avgCompletionRate * 10 + 1) / 11

        saveEnergyProfile(profile)
    }

    // MARK: - Persistence
    private func loadEnergyProfiles() {
        guard let data = UserDefaults.standard.data(forKey: energyProfilesKey),
              let profiles = try? JSONDecoder().decode([UUID: EnergyProfile].self, from: data) else {
            return
        }
        energyProfiles = profiles
    }

    private func saveEnergyProfile(_ profile: EnergyProfile) {
        // For now, save as single default profile
        energyProfiles[UUID()] = profile
        if let data = try? JSONEncoder().encode(energyProfiles) {
            UserDefaults.standard.set(data, forKey: energyProfilesKey)
        }
    }
}
