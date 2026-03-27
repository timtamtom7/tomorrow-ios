import SwiftUI

// R12: Family Archive & Social Features View
struct FamilyArchiveView: View {
    @State private var socialService = TomorrowR12Service.shared
    @State private var selectedTab: ArchiveTab = .familyTree
    @State private var showingNewArchive = false
    @State private var showingNewTimeline = false
    @State private var showingNewLetter = false

    enum ArchiveTab: String, CaseIterable {
        case familyTree = "Family"
        case community = "Community"
        case timelines = "Timelines"
        case exchanges = "Exchanges"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        ForEach(ArchiveTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                    ScrollView {
                        switch selectedTab {
                        case .familyTree:
                            familyTreeView
                        case .community:
                            communityView
                        case .timelines:
                            timelinesView
                        case .exchanges:
                            exchangesView
                        }
                    }
                }
            }
            .navigationTitle("Legacy")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingNewArchive = true
                        } label: {
                            Label("New Family Archive", systemImage: "person.3")
                        }
                        Button {
                            showingNewTimeline = true
                        } label: {
                            Label("New Shared Timeline", systemImage: "clock")
                        }
                        Button {
                            showingNewLetter = true
                        } label: {
                            Label("Share Letter", systemImage: "paperplane")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.tomorrowAccent)
                    }
                }
            }
            .sheet(isPresented: $showingNewArchive) {
                NewFamilyArchiveSheet(socialService: socialService)
            }
            .sheet(isPresented: $showingNewTimeline) {
                NewTimelineSheet(socialService: socialService)
            }
            .sheet(isPresented: $showingNewLetter) {
                ShareLetterSheet(socialService: socialService)
            }
            .onAppear {
                socialService.loadDemoData()
            }
        }
    }

    // MARK: - Family Tree View

    private var familyTreeView: some View {
        LazyVStack(spacing: 16) {
            ForEach(socialService.familyArchives) { archive in
                FamilyArchiveCard(archive: archive, socialService: socialService)
            }

            if socialService.familyArchives.isEmpty {
                emptyFamilyTreeView
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var emptyFamilyTreeView: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.2.and.child.holdinghands")
                .font(.system(size: 48))
                .foregroundStyle(.tomorrowGlow)

            Text("No family archives yet")
                .font(.headline)
                .foregroundStyle(.tomorrowTextSecondary)

            Text("Start your family's legacy archive")
                .font(.subheadline)
                .foregroundStyle(.tomorrowTextTertiary)
                .multilineTextAlignment(.center)

            Button {
                showingNewArchive = true
            } label: {
                Text("Create Archive")
                    .font(.headline)
                    .foregroundStyle(.tomorrowBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.tomorrowAccent)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 48)
    }

    // MARK: - Community Letters View

    private var communityView: some View {
        LazyVStack(spacing: 16) {
            ForEach(socialService.communityLetters) { letter in
                CommunityLetterCard(letter: letter, socialService: socialService)
            }

            if socialService.communityLetters.isEmpty {
                emptyCommunityView
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var emptyCommunityView: some View {
        VStack(spacing: 16) {
            Image(systemName: "paperplane")
                .font(.system(size: 48))
                .foregroundStyle(.tomorrowGlow)

            Text("No community letters")
                .font(.headline)
                .foregroundStyle(.tomorrowTextSecondary)

            Text("Share meaningful letters with the world")
                .font(.subheadline)
                .foregroundStyle(.tomorrowTextTertiary)

            Button {
                showingNewLetter = true
            } label: {
                Text("Share a Letter")
                    .font(.headline)
                    .foregroundStyle(.tomorrowBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.tomorrowAccent)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 48)
    }

    // MARK: - Shared Timelines View

    private var timelinesView: some View {
        LazyVStack(spacing: 12) {
            ForEach(socialService.sharedTimelines) { timeline in
                SharedTimelineCard(timeline: timeline, socialService: socialService)
            }

            if socialService.sharedTimelines.isEmpty {
                emptyTimelinesView
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var emptyTimelinesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 48))
                .foregroundStyle(.tomorrowGlow)

            Text("No shared timelines")
                .font(.headline)
                .foregroundStyle(.tomorrowTextSecondary)

            Text("Create a timeline to share your letters")
                .font(.subheadline)
                .foregroundStyle(.tomorrowTextTertiary)

            Button {
                showingNewTimeline = true
            } label: {
                Text("Create Timeline")
                    .font(.headline)
                    .foregroundStyle(.tomorrowBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.tomorrowAccent)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 48)
    }

    // MARK: - Letter Exchanges View

    private var exchangesView: some View {
        LazyVStack(spacing: 12) {
            ForEach(socialService.letterExchangePairs) { pair in
                LetterExchangeCard(pair: pair, socialService: socialService)
            }

            if socialService.letterExchangePairs.isEmpty {
                emptyExchangesView
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var emptyExchangesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 48))
                .foregroundStyle(.tomorrowGlow)

            Text("No letter exchanges")
                .font(.headline)
                .foregroundStyle(.tomorrowTextSecondary)

            Text("Start a letter exchange with a loved one")
                .font(.subheadline)
                .foregroundStyle(.tomorrowTextTertiary)
                .multilineTextAlignment(.center)

            Button {
                // Would open exchange creation sheet
            } label: {
                Text("Start Exchange")
                    .font(.headline)
                    .foregroundStyle(.tomorrowBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.tomorrowAccent)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 48)
    }
}

// MARK: - Family Archive Card

struct FamilyArchiveCard: View {
    let archive: TomorrowR12Service.FamilyArchive
    @ObservedObject var socialService: TomorrowR12Service
    @State private var showingMembers = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(archive.name)
                        .font(.headline)
                        .foregroundStyle(.tomorrowTextPrimary)

                    Text("\(archive.familyTree.members.count) members")
                        .font(.caption)
                        .foregroundStyle(.tomorrowTextTertiary)
                }

                Spacer()

                Button {
                    Task { @MainActor in
                        HapticsManager.shared.buttonTap()
                    }
                    showingMembers = true
                } label: {
                    Image(systemName: "person.2")
                        .foregroundStyle(.tomorrowAccent)
                }
                .accessibilityLabel("View family members")
                .accessibilityHint("Opens the family members sheet")
            }

            // Simple family tree visualization
            FamilyTreeVisualization(tree: archive.familyTree, socialService: socialService)

            HStack(spacing: 8) {
                Button {
                    showingMembers = true
                } label: {
                    Label("View Tree", systemImage: "tree")
                        .font(.caption)
                        .foregroundStyle(.tomorrowAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.tomorrowAccent.opacity(0.15))
                        .clipShape(Capsule())
                }

                Button {
                    Task { @MainActor in
                        HapticsManager.shared.deleteAction()
                    }
                    socialService.deleteFamilyArchive(archive.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                        .foregroundStyle(.tomorrowError)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.tomorrowError.opacity(0.1))
                        .clipShape(Capsule())
                }
                .accessibilityLabel("Delete family archive")
                .accessibilityHint("Permanently removes this family archive")
            }
        }
        .padding(16)
        .background(Color.tomorrowSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showingMembers) {
            FamilyMembersSheet(archive: archive, socialService: socialService)
        }
    }
}

// MARK: - Family Tree Visualization

struct FamilyTreeVisualization: View {
    let tree: TomorrowR12Service.FamilyTree
    @ObservedObject var socialService: TomorrowR12Service

    var generations: [Int: [TomorrowR12Service.FamilyMember]] {
        Dictionary(grouping: tree.members, by: { $0.generation })
    }

    var maxGeneration: Int {
        generations.keys.max() ?? 0
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach((0...maxGeneration).reversed(), id: \.self) { gen in
                if let members = generations[gen], !members.isEmpty {
                    HStack(spacing: 8) {
                        Text(generationLabel(gen))
                            .font(.caption2)
                            .foregroundStyle(.tomorrowTextTertiary)
                            .frame(width: 50, alignment: .trailing)

                        HStack(spacing: 6) {
                            ForEach(members) { member in
                                FamilyMemberDot(member: member)
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tomorrowSurfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func generationLabel(_ gen: Int) -> String {
        switch gen {
        case 0: return "You"
        case 1: return "Parents"
        case 2: return "Grand"
        case 3: return "Great"
        default: return "Gen \(gen)"
        }
    }
}

struct FamilyMemberDot: View {
    let member: TomorrowR12Service.FamilyMember

    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(dotColor)
                .frame(width: 24, height: 24)
                .overlay {
                    Text(String(member.name.prefix(1)))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.tomorrowBackground)
                }

            Text(member.name)
                .font(.caption2)
                .foregroundStyle(.tomorrowTextSecondary)
                .lineLimit(1)
        }
    }

    private var dotColor: Color {
        if member.passingYear != nil {
            return .tomorrowTextTertiary
        }
        switch member.relation {
        case .self_: return .tomorrowPrimary
        case .parent, .grandparent: return .tomorrowAccent
        case .child, .grandchild: return .tomorrowSecondary
        default: return .tomorrowSurfaceElevated
        }
    }
}

// MARK: - Community Letter Card

struct CommunityLetterCard: View {
    let letter: TomorrowR12Service.CommunityLetter
    @ObservedObject var socialService: TomorrowR12Service

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if letter.letterOfTheWeek {
                    Label("Letter of the Week", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.tomorrowPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.tomorrowPrimary.opacity(0.15))
                        .clipShape(Capsule())
                }

                Spacer()

                Text(letter.letterTheme.rawValue)
                    .font(.caption)
                    .foregroundStyle(.tomorrowAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.tomorrowAccent.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text(letter.title)
                .font(.headline)
                .foregroundStyle(.tomorrowTextPrimary)

            Text(letter.contentPreview)
                .font(.subheadline)
                .foregroundStyle(.tomorrowTextSecondary)
                .lineLimit(4)

            HStack {
                Circle()
                    .fill(Color.tomorrowAccent)
                    .frame(width: 24, height: 24)
                    .overlay {
                        Text(String(letter.displayName.prefix(1)))
                            .font(.caption2)
                            .foregroundStyle(.tomorrowBackground)
                    }

                Text(letter.displayName)
                    .font(.caption)
                    .foregroundStyle(.tomorrowTextTertiary)

                Spacer()

                ForEach(TomorrowR12Service.CommunityLetter.Reaction.ReactionType.allCases, id: \.self) { reactionType in
                    let reaction = letter.reactions.first { $0.type == reactionType }
                    let count = reaction?.count ?? 0

                    Button {
                        socialService.reactToLetter(letter.id, reaction: reactionType)
                    } label: {
                        HStack(spacing: 2) {
                            Text(reactionType.rawValue)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption2)
                                    .foregroundStyle(.tomorrowTextTertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .opacity(count > 0 || reaction?.hasReacted == true ? 1 : 0.5)
                }
            }
        }
        .padding(16)
        .background(Color.tomorrowSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Shared Timeline Card

struct SharedTimelineCard: View {
    let timeline: TomorrowR12Service.SharedTimeline
    @ObservedObject var socialService: TomorrowR12Service

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeline.name)
                        .font(.headline)
                        .foregroundStyle(.tomorrowTextPrimary)

                    HStack(spacing: 4) {
                        Image(systemName: timeline.isPublic ? "globe" : "lock")
                            .font(.caption2)
                        Text(timeline.isPublic ? "Public" : "Private")
                            .font(.caption)
                    }
                    .foregroundStyle(timeline.isPublic ? .tomorrowAccent : .tomorrowTextTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(timeline.letterIds.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.tomorrowTextPrimary)
                    Text("letters")
                        .font(.caption)
                        .foregroundStyle(.tomorrowTextTertiary)
                }
            }

            HStack(spacing: 8) {
                Button {
                    socialService.deleteSharedTimeline(timeline.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                        .foregroundStyle(.tomorrowError)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.tomorrowError.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Color.tomorrowSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Letter Exchange Card

struct LetterExchangeCard: View {
    let pair: TomorrowR12Service.LetterExchangePair
    @ObservedObject var socialService: TomorrowR12Service

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Exchange with \(pair.partnerName)")
                        .font(.headline)
                        .foregroundStyle(.tomorrowTextPrimary)

                    Text("Started \(formatDate(pair.exchangeStartedAt))")
                        .font(.caption)
                        .foregroundStyle(.tomorrowTextTertiary)
                }

                Spacer()

                Circle()
                    .fill(Color.tomorrowSuccess)
                    .frame(width: 8, height: 8)
            }

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(pair.sentLetterIds.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.tomorrowTextPrimary)
                    Text("Sent")
                        .font(.caption)
                        .foregroundStyle(.tomorrowTextTertiary)
                }

                VStack(spacing: 4) {
                    Text("\(pair.receivedLetterIds.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.tomorrowTextPrimary)
                    Text("Received")
                        .font(.caption)
                        .foregroundStyle(.tomorrowTextTertiary)
                }

                Spacer()

                Button {
                    socialService.deleteExchangePair(pair.id)
                } label: {
                    Label("End", systemImage: "xmark")
                        .font(.caption)
                        .foregroundStyle(.tomorrowError)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.tomorrowError.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Color.tomorrowSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - New Family Archive Sheet

struct NewFamilyArchiveSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: TomorrowR12Service
    @State private var name = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    TextField("Archive Name", text: $name)
                        .textFieldStyle(.plain)
                        .font(.title3)
                        .padding(16)
                        .background(Color.tomorrowSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("Start a multi-generational archive for your family")
                        .font(.caption)
                        .foregroundStyle(.tomorrowTextTertiary)

                    Spacer()

                    Button {
                        _ = socialService.createFamilyArchive(name: name)
                        dismiss()
                    } label: {
                        Text("Create Archive")
                            .font(.headline)
                            .foregroundStyle(.tomorrowBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(name.isEmpty ? Color.tomorrowTextTertiary : Color.tomorrowAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(name.isEmpty)
                    .padding(.bottom, 16)
                }
                .padding(.top, 24)
            }
            .navigationTitle("New Family Archive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Family Members Sheet

struct FamilyMembersSheet: View {
    let archive: TomorrowR12Service.FamilyArchive
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: TomorrowR12Service
    @State private var showingAddMember = false
    @State private var newMemberName = ""
    @State private var newMemberRelation: TomorrowR12Service.FamilyMember.Relation = .relative
    @State private var newMemberGeneration = 1

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(archive.familyTree.members.sorted(by: { $0.generation < $1.generation })) { member in
                            FamilyMemberRow(member: member)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(archive.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddMember = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMember) {
                AddFamilyMemberSheet(archiveId: archive.id, socialService: socialService)
            }
        }
    }
}

struct FamilyMemberRow: View {
    let member: TomorrowR12Service.FamilyMember

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(dotColor)
                .frame(width: 40, height: 40)
                .overlay {
                    Text(String(member.name.prefix(1)))
                        .font(.headline)
                        .foregroundStyle(.tomorrowBackground)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.headline)
                    .foregroundStyle(.tomorrowTextPrimary)

                HStack(spacing: 8) {
                    Text(member.relation.rawValue)
                        .font(.caption)
                        .foregroundStyle(.tomorrowAccent)

                    if let birth = member.birthYear {
                        Text("b. \(birth)")
                            .font(.caption)
                            .foregroundStyle(.tomorrowTextTertiary)
                    }

                    if let passing = member.passingYear {
                        Text("d. \(passing)")
                            .font(.caption)
                            .foregroundStyle(.tomorrowTextTertiary)
                    }
                }
            }

            Spacer()

            if !member.inheritedLetterIds.isEmpty {
                Label("\(member.inheritedLetterIds.count)", systemImage: "doc.text")
                    .font(.caption)
                    .foregroundStyle(.tomorrowTextTertiary)
            }
        }
        .padding(12)
        .background(Color.tomorrowSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var dotColor: Color {
        if member.passingYear != nil {
            return .tomorrowTextTertiary
        }
        switch member.relation {
        case .self_: return .tomorrowPrimary
        case .parent, .grandparent: return .tomorrowAccent
        case .child, .grandchild: return .tomorrowSecondary
        default: return .tomorrowSurfaceElevated
        }
    }
}

// MARK: - Add Family Member Sheet

struct AddFamilyMemberSheet: View {
    let archiveId: UUID
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: TomorrowR12Service
    @State private var name = ""
    @State private var relation: TomorrowR12Service.FamilyMember.Relation = .relative
    @State private var birthYear = ""
    @State private var passingYear = ""
    @State private var generation = 1

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()

                VStack(spacing: 16) {
                    TextField("Name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(16)
                        .background(Color.tomorrowSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Picker("Relation", selection: $relation) {
                        ForEach(TomorrowR12Service.FamilyMember.Relation.allCases, id: \.self) { rel in
                            Text(rel.rawValue).tag(rel)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(12)
                    .background(Color.tomorrowSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    HStack(spacing: 16) {
                        TextField("Birth Year", text: $birthYear)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.plain)
                            .padding(16)
                            .background(Color.tomorrowSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        TextField("Passing Year", text: $passingYear)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.plain)
                            .padding(16)
                            .background(Color.tomorrowSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Spacer()

                    Button {
                        let member = TomorrowR12Service.FamilyMember(
                            name: name,
                            relation: relation,
                            generation: generation,
                            birthYear: Int(birthYear),
                            passingYear: Int(passingYear)
                        )
                        socialService.addFamilyMember(to: archiveId, member: member)
                        dismiss()
                    } label: {
                        Text("Add Member")
                            .font(.headline)
                            .foregroundStyle(.tomorrowBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(name.isEmpty ? Color.tomorrowTextTertiary : Color.tomorrowAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(name.isEmpty)
                    .padding(.bottom, 16)
                }
                .padding(16)
            }
            .navigationTitle("Add Family Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - New Timeline Sheet

struct NewTimelineSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: TomorrowR12Service
    @State private var name = ""
    @State private var isPublic = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    TextField("Timeline Name", text: $name)
                        .textFieldStyle(.plain)
                        .font(.title3)
                        .padding(16)
                        .background(Color.tomorrowSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Toggle("Make Public", isOn: $isPublic)
                        .tint(.tomorrowAccent)
                        .padding(.horizontal, 16)

                    Spacer()

                    Button {
                        _ = socialService.createSharedTimeline(name: name, isPublic: isPublic)
                        dismiss()
                    } label: {
                        Text("Create Timeline")
                            .font(.headline)
                            .foregroundStyle(.tomorrowBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(name.isEmpty ? Color.tomorrowTextTertiary : Color.tomorrowAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(name.isEmpty)
                    .padding(.bottom, 16)
                }
                .padding(.top, 24)
            }
            .navigationTitle("New Shared Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Share Letter Sheet

struct ShareLetterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: TomorrowR12Service
    @State private var title = ""
    @State private var contentPreview = ""
    @State private var selectedTheme: TomorrowR12Service.CommunityLetter.LetterTheme = .wisdom
    @State private var isAnonymous = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()

                VStack(spacing: 16) {
                    TextField("Letter Title", text: $title)
                        .textFieldStyle(.plain)
                        .font(.title3)
                        .padding(16)
                        .background(Color.tomorrowSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    TextEditor(text: $contentPreview)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .background(Color.tomorrowSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(minHeight: 100)

                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(TomorrowR12Service.CommunityLetter.LetterTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(12)
                    .background(Color.tomorrowSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Toggle("Post Anonymously", isOn: $isAnonymous)
                        .tint(.tomorrowAccent)
                        .padding(.horizontal, 16)

                    Spacer()

                    Button {
                        _ = socialService.publishLetter(title: title, contentPreview: contentPreview, theme: selectedTheme, isAnonymous: isAnonymous)
                        dismiss()
                    } label: {
                        Text("Share with Community")
                            .font(.headline)
                            .foregroundStyle(.tomorrowBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(title.isEmpty ? Color.tomorrowTextTertiary : Color.tomorrowAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(title.isEmpty)
                    .padding(.bottom, 16)
                }
                .padding(16)
            }
            .navigationTitle("Share Letter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    FamilyArchiveView()
}
