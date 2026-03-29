# Tomorrow R11 — AI Tomorrow Prediction & Anticipation Engine

## Theme
**Know what tomorrow wants before you do.**

---

## Overview

R11 introduces AI-powered tomorrow prediction — analyzing your patterns, past reflections, and current state to generate a personalized "tomorrow forecast." This moves Tomorrow from a passive planning tool to an active anticipation engine.

---

## Features

### R11.1 — Anticipation Score Engine

**What it does:** Calculates a holistic "tomorrow anticipation score" (1-100) based on multiple factors.

**Inputs analyzed:**
- Recent reflection patterns (mood trends, highlight frequency)
- Upcoming events (count, type, significance)
- Task load and priority distribution
- Time of week (Sunday night vs Thursday)
- Weather forecast for tomorrow's location
- Historical completion rates

**Output:**
- Numeric anticipation score
- Breakdown visualization (radar chart style)
- Key factors contributing to score
- "Tomorrow's energy" text summary

### R11.2 — Smart Task Scheduling

**What it does:** AI suggests optimal times for tomorrow's tasks based on your historical productivity patterns.

**Features:**
- Analyzes when you've completed similar tasks in the past
- Groups tasks by energy level required (deep work vs. administrative)
- Suggests morning/afternoon/evening blocks
- Respects your calendar events
- Learns from your adjustments

**UI:**
- Timeline view with AI-suggested slots
- One-tap accept or drag to reschedule
- "AI scheduled" badge on auto-placed tasks

### R11.3 — Reflection-to-Forecast Pipeline

**What it does:** Uses today's reflection to inform tomorrow's prediction.

**Connections:**
- Today's highlight → tomorrow's opportunity
- Today's challenge → tomorrow's awareness
- Today's mood → energy baseline for tomorrow
- Uncompleted intentions → carried forward

**Example:**
"You noted today was 'productive but exhausting.' Tomorrow might need more recovery time. Consider lighter tasks."

### R11.4 — Anticipation Notifications

**What it does:** Sends a gentle evening notification with tomorrow's forecast.

**Timing:** 8pm (configurable)

**Content:**
- Tomorrow's anticipation score
- Key factors (weather, events, task count)
- One suggested intention
- "Plan now" quick action

### R11.5 — Prediction Accuracy Learning

**What it does:** Compares predictions to actual outcomes over time.

**Metrics tracked:**
- Did tomorrow's mood match prediction?
- Did you complete scheduled tasks?
- Was the anticipation score accurate?

**Feedback loop:**
- Weekly "prediction review" micro-survey
- Model adjustment based on feedback
- Improved accuracy over time

---

## Technical Approach

### AI Strategy
- Use on-device NaturalLanguage framework for text analysis
- Local ML models for pattern recognition
- No cloud API dependency — fully private

### Data Model Extensions
```swift
struct AnticipationScore {
    let overall: Int // 1-100
    let factors: [FactorContribution]
    let summary: String
    let suggestedIntention: String?
}

struct FactorContribution {
    let factor: Factor
    let score: Int
    let weight: Double
}

enum Factor {
    case weather
    case events
    case tasks
    case moodTrend
    case energyLevel
    case dayOfWeek
}
```

### Architecture
- `AnticipationEngine` service analyzes all inputs
- `PredictionService` generates forecasts
- `LearningService` tracks accuracy and adapts
- All processing on-device

---

## UI Changes

### TomorrowView Enhancements
- Anticipation score gauge (circular progress, sunrise gradient)
- Factor breakdown (expandable)
- AI summary text card
- "Why this score" tooltip

### New: AnticipationDetailView
- Radar chart of contributing factors
- Historical accuracy chart
- "Adjust prediction" slider
- Override AI with manual score

---

## Out of Scope
- Cloud-based AI models
- Sharing predictions
- Cross-user comparison
- Complex natural language generation
