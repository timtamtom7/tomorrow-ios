import SwiftUI

struct ForecastView: View {
    @State private var dataService = DataService.shared
    @State private var forecasts: [TomorrowForecast] = []
    @State private var selectedForecast: TomorrowForecast?

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing_md) {
                // Header
                headerSection

                // 7-day forecast cards
                LazyVStack(spacing: Theme.spacing_sm) {
                    ForEach(forecasts) { forecast in
                        forecastCard(forecast)
                    }
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
            Text("7-Day Horizon")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textPrimary)

            Text("A week ahead view of your tomorrow")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Forecast Card
    private func forecastCard(_ forecast: TomorrowForecast) -> some View {
        Button {
            selectedForecast = forecast
        } label: {
            VStack(spacing: Theme.spacing_sm) {
                HStack {
                    // Day indicator
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dayName(for: forecast.date))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isToday(forecast.date) ? Theme.horizonBlue : Theme.textPrimary)
                        Text(dateString(for: forecast.date))
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textMuted)
                    }

                    Spacer()

                    // Weather
                    if let condition = forecast.weatherCondition {
                        HStack(spacing: Theme.spacing_xs) {
                            Image(systemName: condition.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(Theme.sunriseGradient)
                            if let high = forecast.temperatureHigh {
                                Text("\(high)°")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Theme.textPrimary)
                            }
                        }
                    } else {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textMuted)
                    }

                    // Task/event count
                    HStack(spacing: Theme.spacing_xs) {
                        if !forecast.tasks.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 10))
                                Text("\(forecast.tasks.filter { !$0.isCompleted }.count)")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(Theme.textMuted)
                        }

                        if !forecast.events.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 10))
                                Text("\(forecast.events.count)")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(Theme.textMuted)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                }

                // Summary line
                if !forecast.tasks.isEmpty || !forecast.events.isEmpty {
                    Divider()

                    HStack(spacing: Theme.spacing_md) {
                        if !forecast.events.isEmpty, let firstEvent = forecast.events.first {
                            Label(firstEvent.title, systemImage: "calendar")
                                .font(.system(size: 11))
                                .foregroundColor(Theme.textSecondary)
                                .lineLimit(1)
                        }

                        if !forecast.tasks.filter({ !$0.isCompleted }).isEmpty {
                            let pending = forecast.tasks.filter { !$0.isCompleted }.count
                            Label("\(pending) tasks", systemImage: "checklist")
                                .font(.system(size: 11))
                                .foregroundColor(Theme.textSecondary)
                        }

                        Spacer()
                    }
                }
            }
            .padding(Theme.spacing_md)
            .background(
                RoundedRectangle(cornerRadius: Theme.radius_md)
                    .fill(isToday(forecast.date) ? Theme.horizonBlue.opacity(0.05) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radius_md)
                            .stroke(isToday(forecast.date) ? Theme.horizonBlue.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(item: $selectedForecast) { forecast in
            ForecastDetailSheet(forecast: forecast)
        }
    }

    // MARK: - Helpers
    private func loadData() {
        forecasts = dataService.getSevenDayForecasts()
    }

    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        if isToday(date) {
            return "Today"
        } else if isTomorrow(date) {
            return "Tomorrow"
        }
        return formatter.string(from: date)
    }

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    private func isTomorrow(_ date: Date) -> Bool {
        Calendar.current.isDateInTomorrow(date)
    }
}

// MARK: - Forecast Detail Sheet
struct ForecastDetailSheet: View {
    let forecast: TomorrowForecast
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayName(for: forecast.date))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                    Text(dateString(for: forecast.date))
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
                Button("Done") { dismiss() }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.horizonBlue)
            }
            .padding(Theme.spacing_md)
            .background(Color.white)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacing_md) {
                    // Weather
                    if let condition = forecast.weatherCondition {
                        weatherSection(condition)
                    }

                    // Events
                    if !forecast.events.isEmpty {
                        eventsSection
                    }

                    // Tasks
                    if !forecast.tasks.isEmpty {
                        tasksSection
                    }

                    // Mood prediction
                    if let mood = forecast.moodPrediction {
                        moodSection(mood)
                    }
                }
                .padding(Theme.spacing_md)
            }
            .background(Theme.surface)
        }
        .frame(width: 340, height: 460)
    }

    private func weatherSection(_ condition: TomorrowForecast.WeatherCondition) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            sectionTitle("Weather", icon: "cloud.sun")

            HStack(spacing: Theme.spacing_sm) {
                Image(systemName: condition.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.sunriseGradient)
                VStack(alignment: .leading) {
                    Text(condition.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                    if let high = forecast.temperatureHigh, let low = forecast.temperatureLow {
                        Text("High: \(high)° / Low: \(low)°")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(Theme.spacing_md)
            .background(Color.white)
            .cornerRadius(Theme.radius_md)
        }
    }

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            sectionTitle("Events", icon: "calendar")

            ForEach(forecast.events) { event in
                HStack(spacing: Theme.spacing_sm) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: event.colorHex))
                        .frame(width: 4, height: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.textPrimary)
                        Text(formatTime(event.startTime))
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textMuted)
                    }
                    Spacer()
                }
                .padding(Theme.spacing_sm)
                .background(Color.white)
                .cornerRadius(Theme.radius_sm)
            }
        }
    }

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            sectionTitle("Tasks", icon: "checklist")

            ForEach(forecast.tasks) { task in
                HStack(spacing: Theme.spacing_sm) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? Theme.success : Theme.textMuted)
                    Text(task.title)
                        .font(.system(size: 13))
                        .foregroundColor(task.isCompleted ? Theme.textMuted : Theme.textPrimary)
                        .strikethrough(task.isCompleted)
                    Spacer()
                    Image(systemName: task.category.icon)
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textMuted)
                }
                .padding(Theme.spacing_sm)
                .background(Color.white)
                .cornerRadius(Theme.radius_sm)
            }
        }
    }

    private func moodSection(_ rating: Int) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            sectionTitle("Anticipation", icon: "sparkles")

            HStack(spacing: Theme.spacing_sm) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "sun.max.fill" : "sun.max")
                        .font(.system(size: 18))
                        .foregroundStyle(star <= rating ? AnyShapeStyle(Theme.sunriseGradient) : AnyShapeStyle(Theme.divider))
                }
                Spacer()
            }
            .padding(Theme.spacing_md)
            .background(Color.white)
            .cornerRadius(Theme.radius_md)
        }
    }

    private func sectionTitle(_ title: String, icon: String) -> some View {
        HStack(spacing: Theme.spacing_xs) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.horizonBlue)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
        }
    }

    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
