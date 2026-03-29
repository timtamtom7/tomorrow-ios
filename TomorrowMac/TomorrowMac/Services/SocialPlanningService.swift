import Foundation

// MARK: - SharedPlan
struct SharedPlan: Identifiable, Codable {
    let id: UUID
    var name: String
    var participants: [Participant]
    var sharedItems: [SharedItem]
    var coordinationNotes: String?
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), name: String = "Our Tomorrow", participants: [Participant] = [], sharedItems: [SharedItem] = [], coordinationNotes: String? = nil) {
        self.id = id
        self.name = name
        self.participants = participants
        self.sharedItems = sharedItems
        self.coordinationNotes = coordinationNotes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Participant
struct Participant: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var avatarColor: String
    var permission: Permission
    var tomorrowTasks: [TomorrowTask]
    var tomorrowEvents: [TomorrowEvent]
    var mood: String?
    var joinedAt: Date

    init(id: UUID = UUID(), name: String, avatarColor: String = "F59E0B", permission: Permission = .viewOnly) {
        self.id = id
        self.name = name
        self.avatarColor = avatarColor
        self.permission = permission
        self.tomorrowTasks = []
        self.tomorrowEvents = []
        self.mood = nil
        self.joinedAt = Date()
    }

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Permission
enum Permission: String, Codable, CaseIterable {
    case viewOnly = "View Only"
    case addTasks = "Add Tasks"
    case fullEdit = "Full Edit"

    var icon: String {
        switch self {
        case .viewOnly: return "eye"
        case .addTasks: return "plus.circle"
        case .fullEdit: return "pencil.circle"
        }
    }
}

// MARK: - SharedItem
struct SharedItem: Identifiable, Codable, Hashable {
    let id: UUID
    var type: SharedItemType
    var title: String
    var detail: String?
    var participants: [UUID]
    var status: SharedStatus
    var createdAt: Date

    init(id: UUID = UUID(), type: SharedItemType, title: String, detail: String? = nil, participants: [UUID] = [], status: SharedStatus = .pending) {
        self.id = id
        self.type = type
        self.title = title
        self.detail = detail
        self.participants = participants
        self.status = status
        self.createdAt = Date()
    }
}

// MARK: - SharedItemType
enum SharedItemType: String, Codable, CaseIterable {
    case sharedTask = "Task"
    case sharedEvent = "Event"
    case groupIntention = "Intention"
    case note = "Note"

    var icon: String {
        switch self {
        case .sharedTask: return "checkmark.circle"
        case .sharedEvent: return "calendar"
        case .groupIntention: return "heart"
        case .note: return "note.text"
        }
    }

    var color: String {
        switch self {
        case .sharedTask: return "10B981"
        case .sharedEvent: return "3B82F6"
        case .groupIntention: return "F59E0B"
        case .note: return "8B5CF6"
        }
    }
}

// MARK: - SharedStatus
enum SharedStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
    case completed = "Completed"

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .accepted: return "checkmark"
        case .declined: return "xmark"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

// MARK: - GroupIntention
struct GroupIntention: Identifiable, Codable {
    let id: UUID
    var text: String
    var createdBy: UUID
    var acceptedBy: [UUID]
    var reminderTime: Date?
    var isActive: Bool
    var createdAt: Date

    init(id: UUID = UUID(), text: String, createdBy: UUID, acceptedBy: [UUID] = [], reminderTime: Date? = nil, isActive: Bool = true) {
        self.id = id
        self.text = text
        self.createdBy = createdBy
        self.acceptedBy = acceptedBy
        self.reminderTime = reminderTime
        self.isActive = isActive
        self.createdAt = Date()
    }
}

// MARK: - SocialPlanningService
final class SocialPlanningService: @unchecked Sendable {
    static let shared = SocialPlanningService()

    private let defaults = UserDefaults.standard
    private let sharedPlansKey = "tomorrow_shared_plans"
    private let groupIntentionsKey = "tomorrow_group_intentions"
    private let inviteLinksKey = "tomorrow_invite_links"

    private(set) var sharedPlans: [SharedPlan] = []
    private(set) var groupIntentions: [GroupIntention] = []

    private init() {
        load()
    }

    // MARK: - Load / Save
    private func load() {
        sharedPlans = loadArray(SharedPlan.self, forKey: sharedPlansKey)
        groupIntentions = loadArray(GroupIntention.self, forKey: groupIntentionsKey)
    }

    private func save() {
        saveArray(sharedPlans, forKey: sharedPlansKey)
        saveArray(groupIntentions, forKey: groupIntentionsKey)
    }

    // MARK: - Shared Plans

    /// Share your tomorrow list with a partner (by UUID)
    func shareTomorrowList(with partner: UUID) {
        // In a real app, this would generate an invite link or send a notification
        // For now, create a placeholder shared plan
        let plan = SharedPlan(
            name: "Our Tomorrow",
            participants: [
                Participant(id: UUID(), name: "Me", avatarColor: "F59E0B", permission: .fullEdit),
                Participant(id: partner, name: "Partner", avatarColor: "EC4899", permission: .viewOnly)
            ],
            sharedItems: []
        )
        sharedPlans.append(plan)
        save()
    }

    /// Get all shared plans
    func getSharedPlans() -> [SharedPlan] {
        return sharedPlans
    }

    /// Collaborate on a tomorrow plan
    func collaborateOnTomorrow(planId: UUID) {
        if let index = sharedPlans.firstIndex(where: { $0.id == planId }) {
            sharedPlans[index].updatedAt = Date()
            save()
        }
    }

    /// Create a new shared plan
    func createSharedPlan(name: String, participants: [Participant]) -> SharedPlan {
        let plan = SharedPlan(name: name, participants: participants)
        sharedPlans.append(plan)
        save()
        return plan
    }

    /// Add a shared item to a plan
    func addSharedItem(to planId: UUID, item: SharedItem) {
        if let index = sharedPlans.firstIndex(where: { $0.id == planId }) {
            sharedPlans[index].sharedItems.append(item)
            sharedPlans[index].updatedAt = Date()
            save()
        }
    }

    /// Update a shared item's status
    func updateSharedItemStatus(planId: UUID, itemId: UUID, status: SharedStatus) {
        if let planIndex = sharedPlans.firstIndex(where: { $0.id == planId }),
           let itemIndex = sharedPlans[planIndex].sharedItems.firstIndex(where: { $0.id == itemId }) {
            sharedPlans[planIndex].sharedItems[itemIndex].status = status
            sharedPlans[planIndex].updatedAt = Date()
            save()
        }
    }

    /// Remove a participant from a shared plan
    func removeParticipant(from planId: UUID, participantId: UUID) {
        if let index = sharedPlans.firstIndex(where: { $0.id == planId }) {
            sharedPlans[index].participants.removeAll { $0.id == participantId }
            sharedPlans[index].updatedAt = Date()
            save()
        }
    }

    /// Update coordination notes
    func updateCoordinationNotes(planId: UUID, notes: String?) {
        if let index = sharedPlans.firstIndex(where: { $0.id == planId }) {
            sharedPlans[index].coordinationNotes = notes
            sharedPlans[index].updatedAt = Date()
            save()
        }
    }

    /// Delete a shared plan
    func deleteSharedPlan(_ planId: UUID) {
        sharedPlans.removeAll { $0.id == planId }
        save()
    }

    /// Get plan by ID
    func getPlan(id: UUID) -> SharedPlan? {
        return sharedPlans.first { $0.id == id }
    }

    // MARK: - Group Intentions

    /// Create a group intention ("We're having a creative day tomorrow")
    func createGroupIntention(text: String, createdBy: UUID, participants: [UUID]) -> GroupIntention {
        let intention = GroupIntention(text: text, createdBy: createdBy, acceptedBy: [createdBy])
        groupIntentions.append(intention)
        save()
        return intention
    }

    /// Accept an intention
    func acceptIntention(_ intentionId: UUID, by participantId: UUID) {
        if let index = groupIntentions.firstIndex(where: { $0.id == intentionId }) {
            if !groupIntentions[index].acceptedBy.contains(participantId) {
                groupIntentions[index].acceptedBy.append(participantId)
                save()
            }
        }
    }

    /// Decline an intention
    func declineIntention(_ intentionId: UUID, by participantId: UUID) {
        if let index = groupIntentions.firstIndex(where: { $0.id == intentionId }) {
            groupIntentions[index].acceptedBy.removeAll { $0 == participantId }
            groupIntentions[index].isActive = false
            save()
        }
    }

    /// Get active intentions for tomorrow
    func getTomorrowIntentions() -> [GroupIntention] {
        return groupIntentions.filter { $0.isActive }
    }

    /// Get intentions for a specific plan
    func getIntentions(for planId: UUID) -> [GroupIntention] {
        return groupIntentions.filter { intention in
            guard let plan = getPlan(id: planId) else { return false }
            let participantIds = plan.participants.map { $0.id }
            return participantIds.contains(intention.createdBy) && intention.isActive
        }
    }

    /// Mark intention as completed
    func completeIntention(_ intentionId: UUID) {
        if let index = groupIntentions.firstIndex(where: { $0.id == intentionId }) {
            groupIntentions[index].isActive = false
            save()
        }
    }

    // MARK: - Invite Links

    struct InviteLink: Codable {
        let code: String
        let planId: UUID
        let permission: Permission
        let createdAt: Date
        let expiresAt: Date?
    }

    /// Generate an invite link for a shared plan
    func generateInviteLink(for planId: UUID, permission: Permission, expiresInDays: Int? = nil) -> String {
        let code = UUID().uuidString.prefix(8).lowercased()
        let link = InviteLink(
            code: String(code),
            planId: planId,
            permission: permission,
            createdAt: Date(),
            expiresAt: expiresInDays.flatMap { Calendar.current.date(byAdding: .day, value: $0, to: Date()) }
        )

        var links = loadArray(InviteLink.self, forKey: inviteLinksKey)
        links.append(link)
        saveArray(links, forKey: inviteLinksKey)

        return "tomorrow://invite/\(code)"
    }

    /// Accept an invite link
    func acceptInviteLink(_ code: String) -> SharedPlan? {
        let links = loadArray(InviteLink.self, forKey: inviteLinksKey)
        guard let link = links.first(where: { $0.code == code }),
              let planIndex = sharedPlans.firstIndex(where: { $0.id == link.planId }) else {
            return nil
        }

        // Check expiry
        if let expiresAt = link.expiresAt, expiresAt < Date() {
            return nil
        }

        return sharedPlans[planIndex]
    }

    // MARK: - Tomorrow Coordination

    /// Sync a participant's tomorrow items into a shared plan
    func syncParticipantTomorrow(planId: UUID, participantId: UUID, tasks: [TomorrowTask], events: [TomorrowEvent]) {
        if let index = sharedPlans.firstIndex(where: { $0.id == planId }),
           let participantIndex = sharedPlans[index].participants.firstIndex(where: { $0.id == participantId }) {
            sharedPlans[index].participants[participantIndex].tomorrowTasks = tasks
            sharedPlans[index].participants[participantIndex].tomorrowEvents = events
            sharedPlans[index].updatedAt = Date()
            save()
        }
    }

    /// Update participant mood
    func updateParticipantMood(planId: UUID, participantId: UUID, mood: String) {
        if let index = sharedPlans.firstIndex(where: { $0.id == planId }),
           let participantIndex = sharedPlans[index].participants.firstIndex(where: { $0.id == participantId }) {
            sharedPlans[index].participants[participantIndex].mood = mood
            sharedPlans[index].updatedAt = Date()
            save()
        }
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
