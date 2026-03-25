# Tomorrow — AI Letter to Your Future Self

## 1. Concept & Vision

Tomorrow is a private, intimate space where you write letters to your future self — letters that unlock on specific dates, years from now. It's part journaling app, part time capsule, part AI-powered mirror. The experience feels like pressing a warm, glowing seal onto a handwritten envelope: deliberate, meaningful, and quietly exciting. You write today, and someday soon, your past self speaks back.

**Who it's for:** People who want to reflect, grow, and留下 a trail of themselves through time.

---

## 2. Design Language

### Aesthetic Direction
**Warm amber sanctuary.** Like candlelight reflected in aged paper. Dark, cozy, enveloping — not cold or clinical. The UI should feel like a private study at golden hour: rich shadows, warm highlights, and a sense that what you're writing *matters*.

### Color Palette

| Role | Color | Hex |
|------|-------|-----|
| Primary | Amber Gold | #F5A623 |
| Secondary | Warm Bronze | #C77B30 |
| Accent | Soft Peach | #FFCB8E |
| Background | Deep Charcoal | #1A1614 |
| Surface | Warm Dark | #252220 |
| Surface Elevated | Muted Bronze | #2E2A27 |
| Text Primary | Warm White | #FAF7F2 |
| Text Secondary | Muted Sand | #A89F94 |
| Text Tertiary | Faded Stone | #6B6560 |
| Divider | Subtle Line | #3A3633 |
| Success | Sage Green | #7BA seventeen |
| Error | Soft Rose | #E57373 |
| Glow | Amber Glow | #F5A623 (20% opacity) |

### Typography

| Role | Font | Weight | Size |
|------|------|--------|------|
| Display | SF Pro Display | Bold | 34pt |
| Heading 1 | SF Pro Display | Semibold | 28pt |
| Heading 2 | SF Pro Display | Medium | 22pt |
| Heading 3 | SF Pro Text | Semibold | 18pt |
| Body | SF Pro Text | Regular | 17pt |
| Body Small | SF Pro Text | Regular | 15pt |
| Caption | SF Pro Text | Regular | 13pt |
| Letter Preview | New York | Regular | 16pt |

### Spacing System (8pt Grid)

| Name | Value |
|------|-------|
| xxs | 4pt |
| xs | 8pt |
| sm | 12pt |
| md | 16pt |
| lg | 24pt |
| xl | 32pt |
| xxl | 48pt |

### Motion Philosophy

Motion is warm and unhurried — like paper settling onto a desk.

| Animation | Duration | Curve | Purpose |
|-----------|----------|-------|---------|
| Screen transition | 350ms | easeInOut | Continuity |
| Card appear | 250ms | spring(0.75) | Life |
| Button press | 100ms | easeOut | Responsiveness |
| Sheet present | 400ms | spring(0.8) | Intent |
| Letter seal/glow | 300ms | easeOut | Confirmation |
| Delete/sweep | 250ms | easeIn | Removal |
| Loading pulse | 1500ms | easeInOut(repeating) | Progress |
| Breathing glow | 4000ms | easeInOut(repeating) | Calm / Ambient |

### Visual Assets

- **Icons:** SF Symbols exclusively
- **Decorative:** Programmatic glow effects, warm gradients
- **Empty states:** Minimalist illustrations with warm amber accents
- **Letter cards:** Subtle paper texture via SwiftUI gradients

---

## 3. Layout & Structure

### Navigation
- **Tab-based navigation** with 4 tabs:
  1. **Library** — All letters organized by state (Draft, Scheduled, Delivered)
  2. **Timeline** — Chronological view of all letters across time
  3. **Create** — Quick-access to new letter creation
  4. **Settings** — Preferences and app info

### Screen Hierarchy

```
App
├── TabView
│   ├── LibraryView
│   │   ├── DraftsSection
│   │   ├── ScheduledSection
│   │   └── DeliveredSection
│   ├── TimelineView
│   │   └── Letter nodes on a vertical timeline
│   ├── CreateView (center FAB or tab)
│   │   └── LetterEditorView (full screen sheet)
│   └── SettingsView
│       ├── Notification preferences
│       ├── Theme toggle
│       └── About
└── LetterDetailView (modal)
    └── Letter preview when delivered
```

---

## 4. Features

### R1 — Foundation

**Core concept, basic UI, local storage**

1. **Letter Creation**
   - Rich text editor for writing letters
   - Title field (optional)
   - Schedule picker: select delivery date (minimum 1 day in future)
   - Save as draft or schedule immediately
   - Character count display

2. **Letter Library**
   - Three sections: Drafts, Scheduled, Delivered
   - Card-based UI for each letter showing: title, preview text, scheduled/created date
   - Tap to edit (drafts), tap to view (delivered), swipe to delete
   - Pull to refresh

3. **Delivery System**
   - Letters marked as "Delivered" when current date >= scheduled date
   - Delivered letters show full content
   - Scheduled letters show preview only (locked feel)

4. **Timeline View**
   - Vertical timeline of all letters
   - Visual nodes for each letter
   - Past (delivered) vs future (scheduled) distinction
   - Empty state when no letters

5. **Local Storage**
   - UserDefaults for letter persistence (R1 scope)
   - Data model: Letter (id, title, content, scheduledDate, createdAt, status)

### R2 — Core Features

**Main workflows complete**

1. **AI Reflection Prompts**
   - When user pauses writing for 10+ seconds, suggest a reflection prompt
   - "What would you tell your future self about this?"
   - Simple suggestion UI, not full AI generation

2. **Letter Status Badges**
   - Visual indicators for letter state
   - Draft: pencil icon, muted
   - Scheduled: clock icon, amber
   - Delivered: seal icon, glowing

3. **Edit Drafts**
   - Full editing of draft letters
   - Update scheduled date
   - Delete drafts

4. **View Delivered Letters**
   - Read-only view of delivered letters
   - Show original scheduled date vs delivered date
   - "This is what you wrote X days ago" context

### R3 — Advanced Features

**The good stuff**

1. **Family Tree of Letters**
   - Letters can reference other letters as "responses"
   - Visual tree/branch view showing letter lineage
   - "You wrote this letter after reading..."

2. **AI Writing Assistance**
   - Offer to expand a thought (on-device text analysis)
   - Tone suggestions
   - Help finding the right words

3. **Notifications**
   - Reminder on scheduled delivery day
   - Optional: reminder to write a letter on significant dates

### R4 — Deepen

**What makes the app unique**

1. **Time Capsule Preview**
   - Peek at scheduled letters (teaser only, no full content)
   - "You told yourself: 'In 3 months, I hope I... [first sentence]'"

2. **Voice Letters**
   - Record audio version of letter (future round)

3. **Memory Tags**
   - Tag letters with life moments: #newjob #grief #joy #milestone
   - Filter library by tags

---

## 5. Component Inventory

### LetterCard
- **States:** draft (muted, pencil badge), scheduled (amber glow, clock badge), delivered (warm glow, seal badge)
- **Content:** Title (or "Untitled"), preview text (max 2 lines), date
- **Interaction:** Tap to navigate, swipe to delete

### LetterEditor
- **States:** empty, writing, paused (prompt suggestion), saving
- **Content:** Title field, body TextEditor, schedule picker, save button
- **Interaction:** Keyboard-aware layout, auto-save drafts

### TimelineNode
- **States:** past (delivered, filled amber), future (scheduled, outlined amber)
- **Content:** Date, title, status indicator
- **Interaction:** Tap to view/edit

### EmptyState
- **Variants:** No letters yet, no drafts, no scheduled, no delivered
- **Content:** SF Symbol icon, title, subtitle, optional CTA button

### TabBar
- Custom amber-tinted tab bar
- Active: amber filled icon
- Inactive: muted sand outline icon

---

## 6. Technical Approach

### Architecture: MVVM + Services

```
Views (SwiftUI)
    ↓ binds to
ViewModels (@Observable)
    ↓ calls
Services (DatabaseService, LetterService)
    ↓ persists via
Models (Letter, FamilyTree)
```

### Data Model

```swift
struct Letter: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var scheduledDate: Date
    var createdAt: Date
    var status: LetterStatus // draft, scheduled, delivered
    var parentLetterId: UUID? // for family tree
    var tags: [String]
}

enum LetterStatus: String, Codable {
    case draft
    case scheduled
    case delivered
}

struct FamilyTree: Codable {
    var nodes: [UUID: Letter]
    var edges: [UUID: [UUID]] // parent -> children
}
```

### Services

- **DatabaseService:** UserDefaults persistence (R1), protocol for future SQLite migration
- **LetterService:** CRUD operations, delivery status updates, family tree management
- **NotificationService:** Local notification scheduling for delivery reminders

### Storage Strategy

- **R1:** UserDefaults with Codable (simple, sufficient for letters)
- **Future Rounds:** SQLite.swift migration path

### Dependencies

- None required for R1 — pure SwiftUI + Foundation
- Future: NaturalLanguage framework for AI features

---

## 7. Not in Scope (R1)

- CloudKit sync
- AI writing generation (only simple prompts in R2)
- Widgets
- watchOS
- Audio/video letters
- Tags and filtering (R4)
- Light mode (dark only for R1)
