import SwiftUI

// MARK: - CouplePlanningView
/// "Our Tomorrow" shared planning view
/// Both partners' tasks visible, coordinate who's doing what
struct CouplePlanningView: View {
    @State private var service = SocialPlanningService.shared
    @State private var selectedPlan: SharedPlan?
    @State private var showingAddIntention = false
    @State private var showingInviteSheet = false
    @State private var newIntentionText = ""
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            if service.sharedPlans.isEmpty {
                emptyStateView
            } else {
                TabView(selection: $selectedTab) {
                    ourTomorrowTab
                        .tag(0)

                    groupIntentionsTab
                        .tag(1)

                    weekAheadTab
                        .tag(2)
                }
                .tabViewStyle(.automatic)
            }
        }
        .background(Theme.surface.ignoresSafeArea())
        .sheet(isPresented: $showingAddIntention) {
            addIntentionSheet
        }
        .sheet(isPresented: $showingInviteSheet) {
            inviteSheet
        }
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Our Tomorrow")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                if let plan = selectedPlan {
                    Text("\(plan.participants.count) people planning together")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }
            }

            Spacer()

            if selectedPlan != nil {
                Menu {
                    Button {
                        showingInviteSheet = true
                    } label: {
                        Label("Invite Someone", systemImage: "person.badge.plus")
                    }

                    Button {
                        showingAddIntention = true
                    } label: {
                        Label("Add Group Intention", systemImage: "heart")
                    }

                    Divider()

                    Button(role: .destructive) {
                        if let plan = selectedPlan {
                            service.deleteSharedPlan(plan.id)
                            selectedPlan = service.sharedPlans.first
                        }
                    } label: {
                        Label("Delete Plan", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .padding(.horizontal, Theme.spacing_lg)
        .padding(.vertical, Theme.spacing_md)
        .background(Color.white)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: Theme.spacing_lg) {
            Spacer()

            Image(systemName: "person.2.wave.2")
                .font(.system(size: 64))
                .foregroundColor(Theme.glowAmber.opacity(0.6))

            VStack(spacing: Theme.spacing_sm) {
                Text("Plan Together")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text("Share your tomorrow with a partner or family member.\nCoordinate, collaborate, and anticipate together.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                createDemoPlan()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Start Planning Together")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, Theme.spacing_lg)
                .padding(.vertical, Theme.spacing_md)
                .background(Theme.glowAmber)
                .cornerRadius(Theme.radius_md)
            }

            Spacer()
        }
        .padding(Theme.spacing_xl)
    }

    // MARK: - Our Tomorrow Tab
    private var ourTomorrowTab: some View {
        ScrollView {
            VStack(spacing: Theme.spacing_lg) {
                if let plan = selectedPlan {
                    // Participant Cards
                    participantCardsSection(plan: plan)

                    Divider().padding(.horizontal, Theme.spacing_lg)

                    // Shared Items
                    sharedItemsSection(plan: plan)

                    Divider().padding(.horizontal, Theme.spacing_lg)

                    // Coordination Notes
                    coordinationNotesSection(plan: plan)
                }
            }
            .padding(.vertical, Theme.spacing_md)
        }
    }

    // MARK: - Participant Cards
    private func participantCardsSection(plan: SharedPlan) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacing_md) {
            Text("Tomorrow's Plans")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, Theme.spacing_lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.spacing_md) {
                    ForEach(plan.participants) { participant in
                        ParticipantCard(participant: participant)
                    }
                }
                .padding(.horizontal, Theme.spacing_lg)
            }
        }
    }

    // MARK: - Shared Items Section
    private func sharedItemsSection(plan: SharedPlan) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacing_md) {
            HStack {
                Text("Shared Items")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)

                Spacer()

                Button {
                    showingAddIntention = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.glowAmber)
                }
            }
            .padding(.horizontal, Theme.spacing_lg)

            if plan.sharedItems.isEmpty {
                emptySharedItemsView
            } else {
                VStack(spacing: Theme.spacing_sm) {
                    ForEach(plan.sharedItems) { item in
                        SharedItemRow(item: item) { newStatus in
                            service.updateSharedItemStatus(planId: plan.id, itemId: item.id, status: newStatus)
                        }
                    }
                }
                .padding(.horizontal, Theme.spacing_lg)
            }
        }
    }

    private var emptySharedItemsView: some View {
        VStack(spacing: Theme.spacing_sm) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 32))
                .foregroundColor(Theme.textMuted)

            Text("No shared items yet")
                .font(.system(size: 14))
                .foregroundColor(Theme.textMuted)

            Text("Add tasks, events, or intentions you want to do together")
                .font(.system(size: 12))
                .foregroundColor(Theme.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacing_xl)
        .background(Theme.divider.opacity(0.3))
        .cornerRadius(Theme.radius_md)
        .padding(.horizontal, Theme.spacing_lg)
    }

    // MARK: - Coordination Notes
    private func coordinationNotesSection(plan: SharedPlan) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacing_md) {
            Text("Coordination Notes")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, Theme.spacing_lg)

            if let notes = plan.coordinationNotes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textPrimary)
                    .padding(Theme.spacing_md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(Theme.radius_md)
                    .padding(.horizontal, Theme.spacing_lg)
            } else {
                Text("Tap to add coordination notes...")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textMuted)
                    .italic()
                    .padding(Theme.spacing_md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.divider.opacity(0.3))
                    .cornerRadius(Theme.radius_md)
                    .padding(.horizontal, Theme.spacing_lg)
                    .onTapGesture {
                        // Would open editor
                    }
            }
        }
    }

    // MARK: - Group Intentions Tab
    private var groupIntentionsTab: some View {
        ScrollView {
            VStack(spacing: Theme.spacing_lg) {
                intentionsHeader

                let intentions = selectedPlan.flatMap { service.getIntentions(for: $0.id) } ?? []
                if intentions.isEmpty {
                    emptyIntentionsView
                } else {
                    intentionsList(intentions)
                }
            }
            .padding(.vertical, Theme.spacing_md)
        }
    }

    private var intentionsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Group Intentions")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text("Things we both want to do")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            Button {
                showingAddIntention = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                    Text("Add")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, Theme.spacing_md)
                .padding(.vertical, Theme.spacing_sm)
                .background(Theme.glowAmber)
                .cornerRadius(Theme.radius_sm)
            }
        }
        .padding(.horizontal, Theme.spacing_lg)
    }

    private var emptyIntentionsView: some View {
        VStack(spacing: Theme.spacing_md) {
            Image(systemName: "heart.circle")
                .font(.system(size: 48))
                .foregroundColor(Theme.glowAmber.opacity(0.5))

            Text("We're having a creative day tomorrow")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Theme.textPrimary)
                .italic()

            Text("Set shared intentions that you both commit to.\nWalk together. Eat dinner together. No screens after 9pm.")
                .font(.system(size: 14))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddIntention = true
            } label: {
                Text("Create First Intention")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.glowAmber)
            }
            .padding(.top, Theme.spacing_sm)
        }
        .padding(Theme.spacing_xl)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(Theme.radius_lg)
        .padding(.horizontal, Theme.spacing_lg)
    }

    private func intentionsList(_ intentions: [GroupIntention]) -> some View {
        VStack(spacing: Theme.spacing_md) {
            ForEach(intentions) { intention in
                IntentionCard(intention: intention) { action in
                    handleIntentionAction(intention, action: action)
                }
            }
        }
        .padding(.horizontal, Theme.spacing_lg)
    }

    private func handleIntentionAction(_ intention: GroupIntention, action: IntentionAction) {
        switch action {
        case .accept:
            service.acceptIntention(intention.id, by: UUID())
        case .decline:
            service.declineIntention(intention.id, by: UUID())
        case .complete:
            service.completeIntention(intention.id)
        }
    }

    // MARK: - Week Ahead Tab
    private var weekAheadTab: some View {
        ScrollView {
            VStack(spacing: Theme.spacing_lg) {
                weekAheadHeader

                weekDaysGrid
            }
            .padding(.vertical, Theme.spacing_md)
        }
    }

    private var weekAheadHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Our Week Ahead")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            Text("Shared plans and milestones")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.spacing_lg)
    }

    private var weekDaysGrid: some View {
        let calendar = Calendar.current
        let today = Date()
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }

        return VStack(spacing: Theme.spacing_md) {
            ForEach(weekDays, id: \.self) { day in
                WeekDayCard(
                    date: day,
                    isToday: calendar.isDateInToday(day),
                    sharedItems: selectedPlan?.sharedItems ?? []
                )
            }
        }
        .padding(.horizontal, Theme.spacing_lg)
    }

    // MARK: - Add Intention Sheet
    private var addIntentionSheet: some View {
        NavigationStack {
            VStack(spacing: Theme.spacing_lg) {
                VStack(alignment: .leading, spacing: Theme.spacing_sm) {
                    Text("Group Intention")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                        .textCase(.uppercase)

                    TextField("e.g. Tomorrow we both want to eat dinner together", text: $newIntentionText)
                        .font(.system(size: 16))
                        .padding(Theme.spacing_md)
                        .background(Color.white)
                        .cornerRadius(Theme.radius_md)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radius_md)
                                .stroke(Theme.divider, lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: Theme.spacing_sm) {
                    Text("Examples")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                        .textCase(.uppercase)

                    VStack(alignment: .leading, spacing: Theme.spacing_sm) {
                        ForEach(exampleIntentions, id: \.self) { example in
                            Button {
                                newIntentionText = example
                            } label: {
                                HStack {
                                    Image(systemName: "lightbulb")
                                        .foregroundColor(Theme.glowAmber)
                                    Text(example)
                                        .font(.system(size: 14))
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                }
                                .padding(Theme.spacing_sm)
                                .background(Theme.divider.opacity(0.3))
                                .cornerRadius(Theme.radius_sm)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer()
            }
            .padding(Theme.spacing_lg)
            .navigationTitle("New Intention")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newIntentionText = ""
                        showingAddIntention = false
                    }
                    .foregroundColor(Theme.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let plan = selectedPlan, !newIntentionText.isEmpty {
                            let intention = service.createGroupIntention(
                                text: newIntentionText,
                                createdBy: plan.participants.first?.id ?? UUID(),
                                participants: plan.participants.map { $0.id }
                            )
                            // Add as shared item
                            let sharedItem = SharedItem(
                                type: .groupIntention,
                                title: newIntentionText,
                                participants: plan.participants.map { $0.id },
                                status: .pending
                            )
                            service.addSharedItem(to: plan.id, item: sharedItem)
                        }
                        newIntentionText = ""
                        showingAddIntention = false
                    }
                    .foregroundColor(Theme.glowAmber)
                    .disabled(newIntentionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var exampleIntentions: [String] {
        [
            "Take a walk together tomorrow evening",
            "Eat dinner together without screens",
            "No screens after 9pm",
            "Both exercise in the morning",
            "Call family together"
        ]
    }

    // MARK: - Invite Sheet
    private var inviteSheet: some View {
        NavigationStack {
            VStack(spacing: Theme.spacing_xl) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 48))
                    .foregroundColor(Theme.glowAmber)
                    .padding(.top, Theme.spacing_xl)

                VStack(spacing: Theme.spacing_sm) {
                    Text("Invite Someone")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text("Share this link with your partner or family member to start planning together.")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: Theme.spacing_md) {
                    PermissionPicker()

                    Button {
                        if let plan = selectedPlan {
                            let link = service.generateInviteLink(for: plan.id, permission: .viewOnly)
                            #if os(macOS)
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(link, forType: .string)
                            #endif
                        }
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Invite Link")
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.spacing_md)
                        .background(Theme.glowAmber)
                        .cornerRadius(Theme.radius_md)
                    }
                }
                .padding(.horizontal, Theme.spacing_xl)

                Spacer()
            }
            .background(Theme.surface.ignoresSafeArea())
            .navigationTitle("Invite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showingInviteSheet = false
                    }
                    .foregroundColor(Theme.glowAmber)
                }
            }
        }
    }

    // MARK: - Actions
    private func createDemoPlan() {
        let me = Participant(name: "Me", avatarColor: "F59E0B", permission: .fullEdit)
        let partner = Participant(name: "Partner", avatarColor: "EC4899", permission: .viewOnly)
        let plan = service.createSharedPlan(name: "Our Tomorrow", participants: [me, partner])
        selectedPlan = plan
    }
}

// MARK: - Permission Picker
struct PermissionPicker: View {
    @State private var selected: Permission = .viewOnly

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            Text("Permission Level")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)

            ForEach(Permission.allCases, id: \.self) { permission in
                Button {
                    selected = permission
                } label: {
                    HStack {
                        Image(systemName: permission.icon)
                            .foregroundColor(selected == permission ? Theme.glowAmber : Theme.textMuted)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(permission.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.textPrimary)

                            Text(permissionDescription(permission))
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textSecondary)
                        }

                        Spacer()

                        if selected == permission {
                            Image(systemName: "checkmark")
                                .foregroundColor(Theme.glowAmber)
                        }
                    }
                    .padding(Theme.spacing_md)
                    .background(Color.white)
                    .cornerRadius(Theme.radius_md)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func permissionDescription(_ permission: Permission) -> String {
        switch permission {
        case .viewOnly: return "Can see your tomorrow plans"
        case .addTasks: return "Can add tasks to shared list"
        case .fullEdit: return "Can edit everything"
        }
    }
}

// MARK: - Participant Card
struct ParticipantCard: View {
    let participant: Participant

    var body: some View {
        VStack(spacing: Theme.spacing_md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: participant.avatarColor).opacity(0.2))
                    .frame(width: 56, height: 56)

                Text(participant.initials)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: participant.avatarColor))
            }

            // Name
            VStack(spacing: 2) {
                Text(participant.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textPrimary)

                if let mood = participant.mood {
                    Text(mood)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
            }

            // Tasks Summary
            HStack(spacing: Theme.spacing_xs) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.success)
                Text("\(participant.tomorrowTasks.filter { $0.isCompleted }.count)/\(participant.tomorrowTasks.count)")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(Theme.spacing_md)
        .frame(width: 120)
        .background(Color.white)
        .cornerRadius(Theme.radius_lg)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Shared Item Row
struct SharedItemRow: View {
    let item: SharedItem
    let onStatusChange: (SharedStatus) -> Void

    var body: some View {
        HStack(spacing: Theme.spacing_md) {
            // Icon
            Image(systemName: item.type.icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: item.type.color))
                .frame(width: 32, height: 32)
                .background(Color(hex: item.type.color).opacity(0.1))
                .cornerRadius(Theme.radius_sm)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textPrimary)

                if let detail = item.detail {
                    Text(detail)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }
            }

            Spacer()

            // Status
            Menu {
                ForEach(SharedStatus.allCases.filter { $0 != .completed }, id: \.self) { status in
                    Button {
                        onStatusChange(status)
                    } label: {
                        Label(status.rawValue, systemImage: status.icon)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: item.status.icon)
                        .font(.system(size: 12))
                    Text(item.status.rawValue)
                        .font(.system(size: 12))
                }
                .foregroundColor(statusColor(item.status))
                .padding(.horizontal, Theme.spacing_sm)
                .padding(.vertical, Theme.spacing_xs)
                .background(statusColor(item.status).opacity(0.1))
                .cornerRadius(Theme.radius_sm)
            }
        }
        .padding(Theme.spacing_md)
        .background(Color.white)
        .cornerRadius(Theme.radius_md)
    }

    private func statusColor(_ status: SharedStatus) -> Color {
        switch status {
        case .pending: return Theme.textMuted
        case .accepted: return Theme.success
        case .declined: return Color(hex: "EF4444")
        case .completed: return Theme.success
        }
    }
}

// MARK: - Intention Card
struct IntentionCard: View {
    let intention: GroupIntention
    let onAction: (IntentionAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_md) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(Theme.glowAmber)

                Text(intention.text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.textPrimary)

                Spacer()
            }

            HStack(spacing: Theme.spacing_sm) {
                Button {
                    onAction(.accept)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                        Text("Accept")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.success)
                    .padding(.horizontal, Theme.spacing_md)
                    .padding(.vertical, Theme.spacing_sm)
                    .background(Theme.success.opacity(0.1))
                    .cornerRadius(Theme.radius_sm)
                }
                .buttonStyle(.plain)

                Button {
                    onAction(.complete)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Done")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.glowAmber)
                    .padding(.horizontal, Theme.spacing_md)
                    .padding(.vertical, Theme.spacing_sm)
                    .background(Theme.glowAmber.opacity(0.1))
                    .cornerRadius(Theme.radius_sm)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(intention.acceptedBy.count) accepted")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(Theme.spacing_md)
        .background(
            LinearGradient(
                colors: [Color.white, Theme.glowAmber.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Theme.radius_lg)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius_lg)
                .stroke(Theme.glowAmber.opacity(0.2), lineWidth: 1)
        )
    }
}

enum IntentionAction {
    case accept
    case decline
    case complete
}

// MARK: - Week Day Card
struct WeekDayCard: View {
    let date: Date
    let isToday: Bool
    let sharedItems: [SharedItem]

    private var dayFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }

    var body: some View {
        HStack(spacing: Theme.spacing_md) {
            // Day indicator
            VStack(spacing: 2) {
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 13, weight: isToday ? .semibold : .medium))
                    .foregroundColor(isToday ? Theme.glowAmber : Theme.textPrimary)

                Text(dateFormatter.string(from: date))
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(width: 72, alignment: .leading)

            // Divider
            if isToday {
                Rectangle()
                    .fill(Theme.glowAmber)
                    .frame(width: 3, height: 40)
                    .cornerRadius(2)
            } else {
                Rectangle()
                    .fill(Theme.divider)
                    .frame(width: 1, height: 40)
            }

            // Items for this day
            VStack(alignment: .leading, spacing: Theme.spacing_xs) {
                if sharedItems.isEmpty {
                    Text("No shared plans")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textMuted)
                        .italic()
                } else {
                    ForEach(sharedItems.prefix(3)) { item in
                        HStack(spacing: Theme.spacing_xs) {
                            Image(systemName: item.type.icon)
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: item.type.color))

                            Text(item.title)
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textPrimary)
                                .lineLimit(1)
                        }
                    }

                    if sharedItems.count > 3 {
                        Text("+\(sharedItems.count - 3) more")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textMuted)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Theme.textMuted)
        }
        .padding(Theme.spacing_md)
        .background(Color.white)
        .cornerRadius(Theme.radius_md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius_md)
                .stroke(isToday ? Theme.glowAmber.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - SharedStatus Extension
extension SharedStatus: CaseIterable {
    static var allCases: [SharedStatus] {
        [.pending, .accepted, .declined, .completed]
    }
}

#Preview {
    CouplePlanningView()
}
