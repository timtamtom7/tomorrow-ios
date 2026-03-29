import SwiftUI

struct TomorrowView: View {
    @State private var dataService = DataService.shared
    @State private var forecast: TomorrowForecast?

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing_md) {
                // Greeting header
                headerSection

                // Weather card
                weatherCard

                // Events section
                eventsSection

                // Tasks section
                tasksSection

                // Mood prediction
                moodSection

                // AI suggestion
                if let suggestion = forecast?.aiSuggestion, !suggestion.isEmpty {
                    aiSuggestionCard(suggestion)
                }
            }
            .padding(Theme.spacing_md)
        }
        .background(Theme.surface)
        .onAppear { loadData() }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_xs) {
            Text("What does tomorrow look like?")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textPrimary)

            Text(tomorrowDateString)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Weather Card
    private var weatherCard: some View {
        VStack(spacing: Theme.spacing_sm) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacing_xs) {
                    if let condition = forecast?.weatherCondition {
                        HStack(spacing: Theme.spacing_sm) {
                            Image(systemName: condition.icon)
                                .font(.system(size: 32))
                                .foregroundStyle(Theme.sunriseGradient)
                            VStack(alignment: .leading) {
                                Text(condition.rawValue)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.textPrimary)
                                if let high = forecast?.temperatureHigh, let low = forecast?.temperatureLow {
                                    Text("\(high)° / \(low)°")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                        }
                    } else {
                        HStack(spacing: Theme.spacing_sm) {
                            Image(systemName: "cloud.sun")
                                .font(.system(size: 28))
                                .foregroundStyle(Theme.sunriseGradient)
                            VStack(alignment: .leading) {
                                Text("Weather Unknown")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Theme.textSecondary)
                                Text("Tap to add forecast")
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.textMuted)
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(Theme.spacing_md)
        .background(
            RoundedRectangle(cornerRadius: Theme.radius_md)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Events Section
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            sectionHeader("Tomorrow's Events", icon: "calendar")

            if let events = forecast?.events, !events.isEmpty {
                ForEach(events) { event in
                    eventRow(event)
                }
            } else {
                emptyStateRow("No events scheduled", icon: "calendar.badge.plus")
            }
        }
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
                if let location = event.location {
                    Text(location)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textMuted)
                }
            }

            Spacer()

            Text(formatTime(event.startTime))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(Theme.spacing_sm)
        .background(Color.white)
        .cornerRadius(Theme.radius_sm)
    }

    // MARK: - Tasks Section
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            sectionHeader("Tomorrow's Tasks", icon: "checklist")

            let tasks = dataService.getTomorrowTasks()
            if !tasks.isEmpty {
                ForEach(tasks.prefix(5)) { task in
                    taskRow(task)
                }
                if tasks.count > 5 {
                    Text("+ \(tasks.count - 5) more")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textMuted)
                        .padding(.leading, Theme.spacing_sm)
                }
            } else {
                emptyStateRow("No tasks planned", icon: "checklist")
            }
        }
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
                    .foregroundColor(task.isCompleted ? Theme.success : Theme.textMuted)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(task.isCompleted ? Theme.textMuted : Theme.textPrimary)
                .strikethrough(task.isCompleted)

            Spacer()

            Image(systemName: task.category.icon)
                .font(.system(size: 11))
                .foregroundColor(Theme.textMuted)
        }
        .padding(Theme.spacing_sm)
        .background(Color.white)
        .cornerRadius(Theme.radius_sm)
    }

    // MARK: - Mood Section
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            sectionHeader("Tomorrow's Anticipation", icon: "sparkles")

            HStack(spacing: Theme.spacing_md) {
                if let rating = forecast?.moodPrediction {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "sun.max.fill" : "sun.max")
                            .font(.system(size: 20))
                            .foregroundStyle(star <= rating ? AnyShapeStyle(Theme.sunriseGradient) : AnyShapeStyle(Theme.divider))
                    }
                    Spacer()
                    Text(moodText(for: rating))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                } else {
                    Text("Rate your anticipation")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textMuted)
                }
            }
            .padding(Theme.spacing_md)
            .background(Color.white)
            .cornerRadius(Theme.radius_md)
        }
    }

    // MARK: - AI Suggestion Card
    private func aiSuggestionCard(_ suggestion: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            HStack(spacing: Theme.spacing_sm) {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(Theme.sunriseGradient)
                Text("AI Insight")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }

            Text(suggestion)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Theme.textSecondary)
                .lineLimit(3)
        }
        .padding(Theme.spacing_md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.radius_md)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radius_md)
                        .stroke(Theme.horizonBlue.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Helpers
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: Theme.spacing_sm) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.horizonBlue)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
        }
    }

    private func emptyStateRow(_ text: String, icon: String) -> some View {
        HStack(spacing: Theme.spacing_sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.textMuted)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Theme.textMuted)
        }
        .padding(Theme.spacing_md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(Theme.radius_sm)
    }

    private var tomorrowDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return formatter.string(from: tomorrow)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func moodText(for rating: Int) -> String {
        switch rating {
        case 1: return "Cautiously optimistic"
        case 2: return "Somewhat hopeful"
        case 3: return "Neutral"
        case 4: return "Excited"
        case 5: return "Very excited!"
        default: return "Neutral"
        }
    }

    private func loadData() {
        forecast = dataService.getTomorrowForecast()
    }
}
