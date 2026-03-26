import Foundation

// R12: Social Features — Family Archives, Collaborative Letters, Legacy Sharing
@MainActor
final class TomorrowR12Service: ObservableObject {
    static let shared = TomorrowR12Service()

    @Published var familyArchives: [FamilyArchive] = []
    @Published var sharedTimelines: [SharedTimeline] = []
    @Published var communityLetters: [CommunityLetter] = []
    @Published var letterExchangePairs: [LetterExchangePair] = []

    private let storageKey = "tomorrowSocialData"

    private init() {
        loadData()
    }

    // MARK: - Family Archives

    struct FamilyArchive: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var familyTree: FamilyTree
        var inheritedLetterIds: [UUID]
        var createdAt: Date
        var updatedAt: Date

        init(
            id: UUID = UUID(),
            name: String,
            familyTree: FamilyTree = FamilyTree(),
            inheritedLetterIds: [UUID] = [],
            createdAt: Date = Date(),
            updatedAt: Date = Date()
        ) {
            self.id = id
            self.name = name
            self.familyTree = familyTree
            self.inheritedLetterIds = inheritedLetterIds
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }

    struct FamilyTree: Codable, Equatable {
        var members: [FamilyMember]

        init(members: [FamilyMember] = []) {
            self.members = members
        }

        static var empty: FamilyTree { FamilyTree() }
    }

    struct FamilyMember: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var relation: Relation
        var generation: Int  // 0 = root/you, 1 = parents, 2 = grandparents, etc.
        var birthYear: Int?
        var passingYear: Int?
        var inheritedLetterIds: [UUID]
        var parentIds: [UUID]  // For building tree structure

        enum Relation: String, Codable, CaseIterable {
            case self_ = "You"
            case parent = "Parent"
            case sibling = "Sibling"
            case grandparent = "Grandparent"
            case child = "Child"
            case grandchild = "Grandchild"
            case spouse = "Spouse"
            case relative = "Relative"
            case ancestor = "Ancestor"
        }

        init(
            id: UUID = UUID(),
            name: String,
            relation: Relation = .relative,
            generation: Int = 0,
            birthYear: Int? = nil,
            passingYear: Int? = nil,
            inheritedLetterIds: [UUID] = [],
            parentIds: [UUID] = []
        ) {
            self.id = id
            self.name = name
            self.relation = relation
            self.generation = generation
            self.birthYear = birthYear
            self.passingYear = passingYear
            self.inheritedLetterIds = inheritedLetterIds
            self.parentIds = parentIds
        }
    }

    func createFamilyArchive(name: String) -> FamilyArchive {
        var tree = FamilyTree()
        // Add self as root
        let selfMember = FamilyMember(name: "Me", relation: .self_, generation: 0)
        tree.members.append(selfMember)

        let archive = FamilyArchive(name: name, familyTree: tree)
        familyArchives.append(archive)
        saveData()
        return archive
    }

    func addFamilyMember(to archiveId: UUID, member: FamilyMember) {
        guard let index = familyArchives.firstIndex(where: { $0.id == archiveId }) else { return }
        familyArchives[index].familyTree.members.append(member)
        familyArchives[index].updatedAt = Date()
        saveData()
    }

    func addInheritedLetter(to archiveId: UUID, memberId: UUID, letterId: UUID) {
        guard let archiveIndex = familyArchives.firstIndex(where: { $0.id == archiveId }),
              let memberIndex = familyArchives[archiveIndex].familyTree.members.firstIndex(where: { $0.id == memberId }) else { return }

        if !familyArchives[archiveIndex].familyTree.members[memberIndex].inheritedLetterIds.contains(letterId) {
            familyArchives[archiveIndex].familyTree.members[memberIndex].inheritedLetterIds.append(letterId)
        }
        if !familyArchives[archiveIndex].inheritedLetterIds.contains(letterId) {
            familyArchives[archiveIndex].inheritedLetterIds.append(letterId)
        }
        familyArchives[archiveIndex].updatedAt = Date()
        saveData()
    }

    func deleteFamilyArchive(_ archiveId: UUID) {
        familyArchives.removeAll { $0.id == archiveId }
        saveData()
    }

    // MARK: - Collaborative Letters

    struct CollaborativeLetter: Identifiable, Codable, Equatable {
        let id: UUID
        var authorIds: [String]
        var authorNames: [String]
        var title: String
        var content: String  // Current combined content
        var versionHistory: [LetterVersion]
        var status: LetterStatus
        var createdAt: Date
        var updatedAt: Date

        enum LetterStatus: String, Codable {
            case draft, inReview, approved, sent
        }

        struct LetterVersion: Identifiable, Codable, Equatable {
            let id: UUID
            var authorId: String
            var authorName: String
            var content: String
            var createdAt: Date
        }

        init(
            id: UUID = UUID(),
            authorIds: [String] = ["local"],
            authorNames: [String] = ["Me"],
            title: String,
            content: String = "",
            versionHistory: [LetterVersion] = [],
            status: LetterStatus = .draft,
            createdAt: Date = Date(),
            updatedAt: Date = Date()
        ) {
            self.id = id
            self.authorIds = authorIds
            self.authorNames = authorNames
            self.title = title
            self.content = content
            self.versionHistory = versionHistory
            self.status = status
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }

    @Published var collaborativeLetters: [CollaborativeLetter] = []

    func startCollaborativeLetter(title: String, coAuthorIds: [String] = []) -> CollaborativeLetter {
        var authors = ["local"]
        var names = ["Me"]
        for i in 0..<coAuthorIds.count {
            authors.append(coAuthorIds[i])
            names.append("Co-Author \(i + 1)")
        }
        let letter = CollaborativeLetter(authorIds: authors, authorNames: names, title: title)
        collaborativeLetters.append(letter)
        saveData()
        return letter
    }

    func addVersionToLetter(_ letterId: UUID, authorId: String, authorName: String, content: String) {
        guard let index = collaborativeLetters.firstIndex(where: { $0.id == letterId }) else { return }
        let version = CollaborativeLetter.LetterVersion(id: UUID(), authorId: authorId, authorName: authorName, content: content, createdAt: Date())
        collaborativeLetters[index].versionHistory.append(version)
        collaborativeLetters[index].content = content
        collaborativeLetters[index].updatedAt = Date()
        saveData()
    }

    // MARK: - Letter Exchange

    struct LetterExchangePair: Identifiable, Codable, Equatable {
        let id: UUID
        var partnerId: String
        var partnerName: String
        var sentLetterIds: [UUID]
        var receivedLetterIds: [UUID]
        var exchangeStartedAt: Date
        var lastActivityAt: Date

        init(
            id: UUID = UUID(),
            partnerId: String,
            partnerName: String,
            sentLetterIds: [UUID] = [],
            receivedLetterIds: [UUID] = [],
            exchangeStartedAt: Date = Date(),
            lastActivityAt: Date = Date()
        ) {
            self.id = id
            self.partnerId = partnerId
            self.partnerName = partnerName
            self.sentLetterIds = sentLetterIds
            self.receivedLetterIds = receivedLetterIds
            self.exchangeStartedAt = exchangeStartedAt
            self.lastActivityAt = lastActivityAt
        }
    }

    func startLetterExchange(partnerId: String, partnerName: String) -> LetterExchangePair {
        let pair = LetterExchangePair(partnerId: partnerId, partnerName: partnerName)
        letterExchangePairs.append(pair)
        saveData()
        return pair
    }

    func recordSentLetter(exchangePairId: UUID, letterId: UUID) {
        guard let index = letterExchangePairs.firstIndex(where: { $0.id == exchangePairId }) else { return }
        if !letterExchangePairs[index].sentLetterIds.contains(letterId) {
            letterExchangePairs[index].sentLetterIds.append(letterId)
        }
        letterExchangePairs[index].lastActivityAt = Date()
        saveData()
    }

    func recordReceivedLetter(exchangePairId: UUID, letterId: UUID) {
        guard let index = letterExchangePairs.firstIndex(where: { $0.id == exchangePairId }) else { return }
        if !letterExchangePairs[index].receivedLetterIds.contains(letterId) {
            letterExchangePairs[index].receivedLetterIds.append(letterId)
        }
        letterExchangePairs[index].lastActivityAt = Date()
        saveData()
    }

    func deleteExchangePair(_ pairId: UUID) {
        letterExchangePairs.removeAll { $0.id == pairId }
        saveData()
    }

    // MARK: - Shared Timeline

    struct SharedTimeline: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var memberIds: [String]
        var letterIds: [UUID]
        var isPublic: Bool
        var createdAt: Date

        init(
            id: UUID = UUID(),
            name: String,
            memberIds: [String] = ["local"],
            letterIds: [UUID] = [],
            isPublic: Bool = false,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.name = name
            self.memberIds = memberIds
            self.letterIds = letterIds
            self.isPublic = isPublic
            self.createdAt = createdAt
        }
    }

    func createSharedTimeline(name: String, isPublic: Bool = false) -> SharedTimeline {
        let timeline = SharedTimeline(name: name, isPublic: isPublic)
        sharedTimelines.append(timeline)
        saveData()
        return timeline
    }

    func addLetterToTimeline(_ timelineId: UUID, letterId: UUID) {
        guard let index = sharedTimelines.firstIndex(where: { $0.id == timelineId }) else { return }
        if !sharedTimelines[index].letterIds.contains(letterId) {
            sharedTimelines[index].letterIds.append(letterId)
            saveData()
        }
    }

    func deleteSharedTimeline(_ timelineId: UUID) {
        sharedTimelines.removeAll { $0.id == timelineId }
        saveData()
    }

    // MARK: - Community Letters

    struct CommunityLetter: Identifiable, Codable, Equatable {
        let id: UUID
        var authorId: String
        var authorName: String
        var isAnonymous: Bool
        var title: String
        var contentPreview: String
        var letterTheme: LetterTheme
        var reactions: [Reaction]
        var letterOfTheWeek: Bool
        var publishedAt: Date

        enum LetterTheme: String, Codable, CaseIterable {
            case gratitude = "Gratitude"
            case wisdom = "Wisdom"
            case family = "Family"
            case future = "Future Self"
            case love = "Love"
            case remembrance = "Remembrance"
            case hope = "Hope"
            case legacy = "Legacy"
        }

        struct Reaction: Codable, Equatable {
            var type: ReactionType
            var count: Int
            var hasReacted: Bool

            enum ReactionType: String, Codable, CaseIterable {
                case heart = "❤️"
                case inspiring = "✨"
                case tears = "😢"
                case save = "📌"
            }
        }

        init(
            id: UUID = UUID(),
            authorId: String = "local",
            authorName: String = "Anonymous",
            isAnonymous: Bool = false,
            title: String,
            contentPreview: String,
            letterTheme: LetterTheme = .wisdom,
            reactions: [Reaction] = [],
            letterOfTheWeek: Bool = false,
            publishedAt: Date = Date()
        ) {
            self.id = id
            self.authorId = authorId
            self.authorName = authorName
            self.isAnonymous = isAnonymous
            self.title = title
            self.contentPreview = contentPreview
            self.letterTheme = letterTheme
            self.reactions = reactions
            self.letterOfTheWeek = letterOfTheWeek
            self.publishedAt = publishedAt
        }

        var displayName: String { isAnonymous ? "Anonymous" : authorName }
    }

    func publishLetter(title: String, contentPreview: String, theme: CommunityLetter.LetterTheme, isAnonymous: Bool = false) -> CommunityLetter {
        let letter = CommunityLetter(isAnonymous: isAnonymous, title: title, contentPreview: contentPreview, letterTheme: theme)
        communityLetters.insert(letter, at: 0)
        saveData()
        return letter
    }

    func reactToLetter(_ letterId: UUID, reaction: CommunityLetter.Reaction.ReactionType) {
        guard let index = communityLetters.firstIndex(where: { $0.id == letterId }) else { return }
        if let reactionIndex = communityLetters[index].reactions.firstIndex(where: { $0.type == reaction }) {
            if communityLetters[index].reactions[reactionIndex].hasReacted {
                communityLetters[index].reactions[reactionIndex].count -= 1
                communityLetters[index].reactions[reactionIndex].hasReacted = false
            } else {
                communityLetters[index].reactions[reactionIndex].count += 1
                communityLetters[index].reactions[reactionIndex].hasReacted = true
            }
        } else {
            communityLetters[index].reactions.append(CommunityLetter.Reaction(type: reaction, count: 1, hasReacted: true))
        }
        saveData()
    }

    func markLetterOfTheWeek(_ letterId: UUID) {
        // Clear previous letter of the week
        for i in 0..<communityLetters.count {
            communityLetters[i].letterOfTheWeek = false
        }
        if let index = communityLetters.firstIndex(where: { $0.id == letterId }) {
            communityLetters[index].letterOfTheWeek = true
        }
        saveData()
    }

    // MARK: - Persistence

    private struct SocialData: Codable {
        var familyArchives: [FamilyArchive]
        var collaborativeLetters: [CollaborativeLetter]
        var letterExchangePairs: [LetterExchangePair]
        var sharedTimelines: [SharedTimeline]
        var communityLetters: [CommunityLetter]
    }

    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let socialData = try? JSONDecoder().decode(SocialData.self, from: data) else {
            return
        }
        familyArchives = socialData.familyArchives
        collaborativeLetters = socialData.collaborativeLetters
        letterExchangePairs = socialData.letterExchangePairs
        sharedTimelines = socialData.sharedTimelines
        communityLetters = socialData.communityLetters
    }

    private func saveData() {
        let socialData = SocialData(
            familyArchives: familyArchives,
            collaborativeLetters: collaborativeLetters,
            letterExchangePairs: letterExchangePairs,
            sharedTimelines: sharedTimelines,
            communityLetters: communityLetters
        )
        if let data = try? JSONEncoder().encode(socialData) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // MARK: - Demo Data

    func loadDemoData() {
        guard familyArchives.isEmpty && communityLetters.isEmpty else { return }

        // Demo family archive
        var tree = FamilyTree()
        let me = FamilyMember(name: "Me", relation: .self_, generation: 0)
        let mother = FamilyMember(name: "Grandma Rosa", relation: .grandparent, generation: 1, birthYear: 1945)
        let father = FamilyMember(name: "Grandpa Antonio", relation: .grandparent, generation: 1, birthYear: 1940, passingYear: 2018)
        tree.members = [me, mother, father]

        let archive = FamilyArchive(name: "The Mauriello Family", familyTree: tree)
        familyArchives = [archive]

        // Demo community letter
        let letter = CommunityLetter(
            isAnonymous: true,
            title: "Letters to Those We've Lost",
            contentPreview: "There's a particular silence that fills a room when someone you love is no longer there to fill it. It's not empty—it's waiting. Waiting for a voice that won't come, a laugh that echoes only in memory...",
            letterTheme: .remembrance
        )
        communityLetters = [letter]

        saveData()
    }
}
