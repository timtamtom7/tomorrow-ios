import SwiftUI

struct PlanningView: View {
    @State private var dataService = DataService.shared
    @State private var newTaskTitle = ""
    @State private var newIntentionText = ""
    @State private var selectedPriority: TomorrowTask.Priority = .medium
    @State private var selectedCategory: TomorrowTask.Category = .general
    @State private var selectedTab: PlanningTab = .tasks
    @State private var tasks: [TomorrowTask] = []
    @State private var intentions: [Intention] = []

    enum PlanningTab: String, CaseIterable {
        case tasks = "Tasks"
        case events = "Events"
        case intentions = "Intentions"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            tabPicker

            Divider()

            // Content
            TabView(selection: $selectedTab) {
                tasksTab.tag(PlanningTab.tasks)
                eventsTab.tag(PlanningTab.events)
                intentionsTab.tag(PlanningTab.intentions)
            }
            .tabViewStyle(.automatic)
        }
        .background(Theme.surface)
        .onAppear { loadData() }
    }

    // MARK: - Tab Picker
    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(PlanningTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(Theme.springAnimation) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(selectedTab == tab ? Theme.horizonBlue : Theme.textMuted)
                        .padding(.vertical, Theme.spacing_sm)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedTab == tab ? Theme.horizonBlue.opacity(0.1) : Color.clear
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Theme.spacing_sm)
        .padding(.top, Theme.spacing_sm)
    }

    // MARK: - Tasks Tab
    private var tasksTab: some View {
        VStack(spacing: Theme.spacing_sm) {
            // Add task
            addTaskInput

            // Task list
            ScrollView {
                LazyVStack(spacing: Theme.spacing_xs) {
                    ForEach(tasks) { task in
                        taskRow(task)
                    }
                }
                .padding(Theme.spacing_sm)
            }
        }
    }

    private var addTaskInput: some View {
        VStack(spacing: Theme.spacing_sm) {
            HStack(spacing: Theme.spacing_sm) {
                TextField("Add a task for tomorrow...", text: $newTaskTitle)
                    .font(.system(size: 13))
                    .textFieldStyle(.plain)
                    .padding(Theme.spacing_sm)
                    .background(Color.white)
                    .cornerRadius(Theme.radius_sm)

                Button {
                    addTask()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Theme.sunriseGradient)
                }
                .buttonStyle(.plain)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Priority/category pickers
            HStack(spacing: Theme.spacing_sm) {
                Picker("Priority", selection: $selectedPriority) {
                    ForEach(TomorrowTask.Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                .pickerStyle(.menu)
                .font(.system(size: 11))
                .padding(6)
                .background(Color.white)
                .cornerRadius(Theme.radius_sm)

                Picker("Category", selection: $selectedCategory) {
                    ForEach(TomorrowTask.Category.allCases, id: \.self) { category in
                        Label(category.rawValue, systemImage: category.icon).tag(category)
                    }
                }
                .pickerStyle(.menu)
                .font(.system(size: 11))
                .padding(6)
                .background(Color.white)
                .cornerRadius(Theme.radius_sm)
            }
        }
        .padding(Theme.spacing_sm)
    }

    private func taskRow(_ task: TomorrowTask) -> some View {
        HStack(spacing: Theme.spacing_sm) {
            Button {
                var updated = task
                updated.isCompleted.toggle()
                dataService.updateTask(updated)
                loadData()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? Theme.success : Color(hex: task.priority.color))
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(task.isCompleted ? Theme.textMuted : Theme.textPrimary)
                    .strikethrough(task.isCompleted)
                HStack(spacing: Theme.spacing_xs) {
                    Text(task.priority.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color(hex: task.priority.color))
                        .cornerRadius(3)
                    Text(task.category.rawValue)
                        .font(.system(size: 9))
                        .foregroundColor(Theme.textMuted)
                }
            }

            Spacer()

            Image(systemName: task.category.icon)
                .font(.system(size: 11))
                .foregroundColor(Theme.textMuted)

            Button {
                dataService.deleteTask(task)
                loadData()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.textMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(Theme.spacing_sm)
        .background(Color.white)
        .cornerRadius(Theme.radius_sm)
    }

    // MARK: - Events Tab
    private var eventsTab: some View {
        VStack(spacing: Theme.spacing_sm) {
            addEventButton

            ScrollView {
                LazyVStack(spacing: Theme.spacing_xs) {
                    ForEach(dataService.getTomorrowEvents()) { event in
                        eventRow(event)
                    }
                    if dataService.getTomorrowEvents().isEmpty {
                        emptyEventsState
                    }
                }
                .padding(Theme.spacing_sm)
            }
        }
    }

    private var addEventButton: some View {
        Button {
            // Open system calendar or add event sheet
            if let url = URL(string: "calshow://") {
                NSWorkspace.shared.open(url)
            }
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Theme.sunriseGradient)
                Text("Add Event")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.textPrimary)
            }
            .padding(Theme.spacing_sm)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(Theme.radius_sm)
        }
        .buttonStyle(.plain)
        .padding(Theme.spacing_sm)
    }

    private func eventRow(_ event: TomorrowEvent) -> some View {
        HStack(spacing: Theme.spacing_sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: event.colorHex))
                .frame(width: 4, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.textPrimary)
                HStack(spacing: Theme.spacing_xs) {
                    Text(formatTime(event.startTime))
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textMuted)
                    if let location = event.location {
                        Text("•")
                            .foregroundColor(Theme.textMuted)
                        Text(location)
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textMuted)
                    }
                }
            }

            Spacer()

            Button {
                dataService.deleteEvent(event)
                loadData()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.textMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(Theme.spacing_sm)
        .background(Color.white)
        .cornerRadius(Theme.radius_sm)
    }

    private var emptyEventsState: some View {
        VStack(spacing: Theme.spacing_sm) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 28))
                .foregroundColor(Theme.textMuted)
            Text("No events tomorrow")
                .font(.system(size: 13))
                .foregroundColor(Theme.textMuted)
            Text("Open Calendar to add events")
                .font(.system(size: 11))
                .foregroundColor(Theme.textMuted)
        }
        .padding(Theme.spacing_xl)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Intentions Tab
    private var intentionsTab: some View {
        VStack(spacing: Theme.spacing_sm) {
            addIntentionInput

            ScrollView {
                LazyVStack(spacing: Theme.spacing_xs) {
                    ForEach(intentions) { intention in
                        intentionRow(intention)
                    }
                    if intentions.isEmpty {
                        emptyIntentionsState
                    }
                }
                .padding(Theme.spacing_sm)
            }
        }
    }

    private var addIntentionInput: some View {
        HStack(spacing: Theme.spacing_sm) {
            TextField("What's your intention for tomorrow?", text: $newIntentionText)
                .font(.system(size: 13))
                .textFieldStyle(.plain)
                .padding(Theme.spacing_sm)
                .background(Color.white)
                .cornerRadius(Theme.radius_sm)

            Button {
                addIntention()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.sunriseGradient)
            }
            .buttonStyle(.plain)
            .disabled(newIntentionText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(Theme.spacing_sm)
    }

    private func intentionRow(_ intention: Intention) -> some View {
        HStack(spacing: Theme.spacing_sm) {
            Image(systemName: "arrow.up.heart")
                .font(.system(size: 14))
                .foregroundStyle(Theme.sunriseGradient)

            Text(intention.text)
                .font(.system(size: 13))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            Button {
                dataService.deleteIntention(intention)
                loadData()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.textMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(Theme.spacing_sm)
        .background(Color.white)
        .cornerRadius(Theme.radius_sm)
        .contextMenu {
            Button("Move Up") {
                moveIntention(intention, direction: -1)
            }
            Button("Move Down") {
                moveIntention(intention, direction: 1)
            }
        }
    }

    private var emptyIntentionsState: some View {
        VStack(spacing: Theme.spacing_sm) {
            Image(systemName: "heart.circle")
                .font(.system(size: 28))
                .foregroundStyle(Theme.sunriseGradient)
            Text("No intentions set")
                .font(.system(size: 13))
                .foregroundColor(Theme.textMuted)
            Text("Intentions guide your tomorrow")
                .font(.system(size: 11))
                .foregroundColor(Theme.textMuted)
        }
        .padding(Theme.spacing_xl)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions
    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let task = TomorrowTask(title: trimmed, priority: selectedPriority, category: selectedCategory)
        dataService.addTask(task)
        newTaskTitle = ""
        loadData()
    }

    private func addIntention() {
        let trimmed = newIntentionText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let intention = Intention(text: trimmed, order: intentions.count)
        dataService.addIntention(intention)
        newIntentionText = ""
        loadData()
    }

    private func moveIntention(_ intention: Intention, direction: Int) {
        guard let index = intentions.firstIndex(where: { $0.id == intention.id }) else { return }
        let newIndex = index + direction
        guard newIndex >= 0 && newIndex < intentions.count else { return }
        var reordered = intentions
        reordered.swapAt(index, newIndex)
        dataService.reorderIntentions(reordered)
        loadData()
    }

    private func loadData() {
        tasks = dataService.getTomorrowTasks()
        intentions = dataService.getTomorrowIntentions()
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
