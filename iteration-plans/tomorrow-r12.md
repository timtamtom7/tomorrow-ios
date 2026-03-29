# Tomorrow R12 — Social Planning & Shared Horizons

## Theme
**Tomorrow, together.**

---

## Overview

R12 introduces social features that let Tomorrow extend beyond the individual — shared tomorrow planning with partners, family, or close friends. Coordinate schedules, align intentions, and build anticipation together.

---

## Features

### R12.1 — Shared Tomorrow Lists

**What it does:** Invite others to view/contribute to your tomorrow planning.

**Mechanics:**
- Generate a shareable "Tomorrow link" (read-only or collaborative)
- Invite via email, message, or QR code
- Granular permissions: view-only, add tasks, full edit

**Use cases:**
- Households planning the next day together
- Co-workers syncing on tomorrow's priorities
- Partners aligning intentions

### R12.2 — Couple/Family Hub

**What it does:** A shared space for two or more people to see each other's tomorrows.

**Features:**
- "Our Tomorrow" combined view
- Shared tasks/events highlighted
- Individual spaces preserved
- Morning check-in prompt

**UI:**
- Horizontal card layout per person
- Shared items in center
- Color-coded by person

### R12.3 — Calendar Integration (Enhanced)

**What it does:** Import shared calendars and show tomorrow's coordination points.

**Supported:**
- Google Calendar (read events)
- Apple Calendar (local)
- ICS subscription feeds

**Display:**
- Which shared events are tomorrow
- Who's attending
- Location and time details
- Conflict detection

### R12.4 — Group Intentions

**What it does:** Set shared intentions that multiple people commit to.

**Examples:**
- "Tomorrow we both want to eat dinner together"
- "Let's both take a walk tomorrow evening"
- "No screens after 9pm"

**Features:**
- Mutual commitment (both must accept)
- Gentle reminder to both parties
- Success tracking (did it happen?)

### R12.5 — Tomorrow Coordination Notifications

**What it does:** Notify relevant people when your tomorrow affects theirs.

**Triggers:**
- You added an event they might attend
- You changed a shared plan
- Tomorrow's weather changed significantly
- You reflected — they can see your mood

**Delivery:**
- Push notification to shared group
- Summary card in app

---

## Technical Approach

### Sync Strategy
- No real-time sync (pull-based, on open)
- Tomorrow Cloud service for shared state
- Conflict resolution: last-write-wins with merge

### Data Model Extensions
```swift
struct SharedTomorrow {
    let id: UUID
    let name: String
    var participants: [Participant]
    var sharedItems: [SharedItem]
    var coordinationNotes: String?
}

struct Participant {
    let userId: UUID
    let name: String
    var permission: Permission
    var tomorrowItems: [TomorrowItem]
}

struct SharedItem: Identifiable {
    let id: UUID
    var type: SharedItemType
    var title: String
    var participants: [UUID] // who's involved
    var status: SharedStatus
}

enum SharedItemType {
    case sharedTask
    case sharedEvent
    case groupIntention
    case note
}
```

### Privacy
- Read-only visibility by default
- Participants can hide specific items
- "Appear offline" mode
- Full data never stored on third-party servers

### Architecture
- `SharedTomorrowService` manages sync
- `CalendarIntegrationService` pulls events
- `CoordinationService` handles notifications
- End-to-end encryption for shared data

---

## UI Changes

### New: SharedTomorrowView
- Participant cards (scrollable horizontal)
- Shared items section
- Coordination bar (weather + summary)
- Chat/mote for quick coordination

### New: InviteFlow
- Share sheet integration
- Permission picker
- QR code generation

### TomorrowView Enhancements
- "Shared with X people" indicator
- Shared items highlighted with multi-person avatar

---

## Out of Scope
- Real-time messaging
- Video/audio calls
- Task dependencies across users
- Public/community boards (see R9)
