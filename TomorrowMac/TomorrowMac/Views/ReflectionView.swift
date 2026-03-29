import SwiftUI

struct ReflectionView: View {
    @State private var dataService = DataService.shared
    @State private var hasReflected = false
    @State private var howWasToday = ""
    @State private var highlight = ""
    @State private var lowlight = ""
    @State private var selectedMood: Reflection.Mood = .neutral
    @State private var anticipationRating: Int = 3
    @State private var tomorrowIntention = ""
    @State private var showingSaved = false

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing_md) {
                // Header
                headerSection

                if hasReflected {
                    reflectedView
                } else {
                    reflectionForm
                }
            }
            .padding(Theme.spacing_md)
        }
        .background(Theme.surface)
        .onAppear { loadData() }
        .overlay {
            if showingSaved {
                savedOverlay
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_xs) {
            Text("Today was...")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textPrimary)

            Text(formattedDate)
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Reflection Form
    private var reflectionForm: some View {
        VStack(spacing: Theme.spacing_md) {
            // Mood picker
            moodSection

            // How was today
            inputSection(title: "How was your day?", placeholder: "A word or short phrase...", text: $howWasToday)

            // Highlight
            inputSection(title: "Highlight of the day", placeholder: "What made today special?", text: $highlight)

            // Lowlight (optional)
            inputSection(title: "Challenge (optional)", placeholder: "What was difficult?", text: $lowlight)

            // Anticipation rating
            anticipationSection

            // Tomorrow's intention
            inputSection(title: "Tomorrow's intention", placeholder: "How do you want tomorrow to go?", text: $tomorrowIntention)

            // Save button
            Button {
                saveReflection()
            } label: {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Theme.sunriseGradient)
                    Text("Seal Today's Reflection")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(Theme.spacing_md)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radius_md)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radius_md)
                                .stroke(Theme.horizonBlue.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Mood Section
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            Text("Overall mood")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            HStack(spacing: Theme.spacing_sm) {
                ForEach(Reflection.Mood.allCases, id: \.self) { mood in
                    Button {
                        selectedMood = mood
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: mood.icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedMood == mood ? Color(hex: mood.color) : Theme.textMuted)
                            Text(mood.rawValue)
                                .font(.system(size: 10, weight: selectedMood == mood ? .semibold : .regular))
                                .foregroundColor(selectedMood == mood ? Color(hex: mood.color) : Theme.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.spacing_sm)
                        .background(
                            selectedMood == mood ? Color(hex: mood.color).opacity(0.1) : Color.white
                        )
                        .cornerRadius(Theme.radius_sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radius_sm)
                                .stroke(selectedMood == mood ? Color(hex: mood.color).opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Anticipation Section
    private var anticipationSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing_sm) {
            HStack {
                Text("Tomorrow's anticipation")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text(anticipationLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }

            HStack(spacing: Theme.spacing_md) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        anticipationRating = rating
                    } label: {
                        Image(systemName: rating <= anticipationRating ? "sun.max.fill" : "sun.max")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                rating <= anticipationRating ?
                                AnyShapeStyle(Theme.sunriseGradient) :
                                AnyShapeStyle(Theme.divider)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.spacing_md)
            .background(Color.white)
            .cornerRadius(Theme.radius_md)
        }
    }

    private var anticipationLabel: String {
        switch anticipationRating {
        case 1: return "Cautious"
        case 2: return "Hopeful"
        case 3: return "Neutral"
        case 4: return "Excited"
        case 5: return "Very excited!"
        default: return "Neutral"
        }
    }

    // MARK: - Input Section
    private func inputSection(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacing_xs) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            TextField(placeholder, text: text, axis: .vertical)
                .font(.system(size: 13))
                .textFieldStyle(.plain)
                .lineLimit(2...4)
                .padding(Theme.spacing_sm)
                .background(Color.white)
                .cornerRadius(Theme.radius_sm)
        }
    }

    // MARK: - Reflected View
    private var reflectedView: some View {
        VStack(spacing: Theme.spacing_md) {
            // Thank you message
            VStack(spacing: Theme.spacing_sm) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.sunriseGradient)

                Text("Reflection complete")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text("You've sealed today's reflection")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.vertical, Theme.spacing_lg)

            Divider()

            // Show summary
            if let reflection = dataService.getTodayReflection() {
                VStack(alignment: .leading, spacing: Theme.spacing_md) {
                    // Mood
                    HStack(spacing: Theme.spacing_sm) {
                        Image(systemName: reflection.mood.icon)
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: reflection.mood.color))
                        Text("You felt \(reflection.mood.rawValue.lowercased())")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.textPrimary)
                    }

                    // Anticipation
                    HStack(spacing: Theme.spacing_sm) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.sunriseGradient)
                        Text("Tomorrow's anticipation:")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= reflection.anticipationRating ? "sun.max.fill" : "sun.max")
                                .font(.system(size: 12))
                                .foregroundStyle(star <= reflection.anticipationRating ? AnyShapeStyle(Theme.sunriseGradient) : AnyShapeStyle(Theme.divider))
                        }
                    }

                    if !reflection.highlight.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today's highlight")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Theme.textMuted)
                            Text(reflection.highlight)
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textPrimary)
                        }
                        .padding(Theme.spacing_sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(Theme.radius_sm)
                    }

                    if let intention = reflection.tomorrowIntention, !intention.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tomorrow's intention")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Theme.textMuted)
                            HStack(spacing: Theme.spacing_xs) {
                                Image(systemName: "arrow.up.heart")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.sunriseGradient)
                                Text(intention)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.textPrimary)
                            }
                        }
                        .padding(Theme.spacing_sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(Theme.radius_sm)
                    }
                }
            }

            Spacer()
        }
    }

    // MARK: - Saved Overlay
    private var savedOverlay: some View {
        VStack(spacing: Theme.spacing_md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.sunriseGradient)

            Text("Reflection saved")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            Text("See you tomorrow ✦")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(Theme.spacing_xl)
        .background(
            RoundedRectangle(cornerRadius: Theme.radius_lg)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Helpers
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private func loadData() {
        hasReflected = dataService.hasReflectedToday()
        if let existing = dataService.getTodayReflection() {
            howWasToday = existing.howWasToday
            highlight = existing.highlight
            lowlight = existing.lowlight ?? ""
            selectedMood = existing.mood
            anticipationRating = existing.anticipationRating
            tomorrowIntention = existing.tomorrowIntention ?? ""
        }
    }

    private func saveReflection() {
        let reflection = Reflection(
            date: Date(),
            howWasToday: howWasToday,
            highlight: highlight,
            lowlight: lowlight.isEmpty ? nil : lowlight,
            anticipationRating: anticipationRating,
            tomorrowIntention: tomorrowIntention.isEmpty ? nil : tomorrowIntention,
            mood: selectedMood
        )
        dataService.addReflection(reflection)

        // Update tomorrow's forecast anticipation
        var forecast = dataService.getTomorrowForecast()
        forecast = TomorrowForecast(
            id: forecast.id,
            date: forecast.date,
            weatherCondition: forecast.weatherCondition,
            temperatureHigh: forecast.temperatureHigh,
            temperatureLow: forecast.temperatureLow,
            tasks: forecast.tasks,
            events: forecast.events,
            moodPrediction: anticipationRating,
            aiSuggestion: forecast.aiSuggestion,
            reflection: reflection
        )
        dataService.updateForecast(forecast)

        withAnimation(Theme.springAnimation) {
            showingSaved = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingSaved = false
                hasReflected = true
            }
        }
    }
}
