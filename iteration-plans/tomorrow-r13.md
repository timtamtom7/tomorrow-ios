# Tomorrow R13 — Polish, App Store & Launch

## Theme
**Ship it beautifully.**

---

## Overview

R13 is the final polish and launch round. Every detail is refined, the App Store presence is complete, and Tomorrow ships to the world.

---

## Features

### R13.1 — Visual Polish Pass

**UI Refinements:**
- Consistent 8pt grid across all screens
- Typography hierarchy audit (all text roles defined)
- Color token documentation (every hex mapped to semantic name)
- Animation duration review (all within spec)
- Shadow and elevation standardization
- Dark mode completion (all screens, all states)

**Empty States:**
- Illustrated empty states for every list
- Contextual "write your first letter" CTAs
- Onboarding hints for new users

**Accessibility:**
- Full VoiceOver support
- Dynamic Type compliance
- Reduced Motion support
- High contrast mode

### R13.2 — App Store Assets

**Screenshots:**
- iPhone 6 sizes (all modern devices)
- iPad sizes
- App preview video (30 seconds, letter-writing flow)
- Feature highlights (3-5 screens)

**Copy:**
- Title: "Tomorrow — Letter to Your Future Self"
- Subtitle: "Write today. Read someday."
- Description (3 versions: short, medium, full)
- Keywords (50 characters, comma-separated)
- Promotional text (for update announcements)
- What's New (for launch and subsequent releases)

**Category:** Health & Fitness > Mindfulness
**Age Rating:** 4+

### R13.3 — Marketing Site

**Pages:**
- Landing page (concept, demo, testimonials)
- Privacy policy
- Support/FAQ
- Press kit

**SEO:**
- "Letter to future self app"
- "Time capsule journaling"
- "Tomorrow planning"
- Open Graph tags
- Structured data (App Links)

### R13.4 — Launch Checklist

**Pre-Launch:**
- [ ] TestFlight build (internal, 2 weeks minimum)
- [ ] External testers (10-20 users)
- [ ] Crash reporting (Firebase or similar)
- [ ] Analytics consent flow
- [ ] Privacy policy live
- [ ] Support email configured
- [ ] Social accounts ready (Twitter, Instagram)

**Launch Day:**
- [ ] App Store submission
- [ ] Marketing site live
- [ ] Social announcement prepared
- [ ] Press release sent
- [ ] Hacker News "Show HN" prepared

**Post-Launch:**
- [ ] Monitor crash reports daily
- [ ] Respond to first App Store reviews
- [ ] Weekly user feedback review
- [ ] R12 planning begins

### R13.5 — Performance & Stability

**Optimizations:**
- Launch time < 2 seconds
- Scroll performance 60fps
- Memory usage < 100MB typical
- Background refresh efficiency

**Stability:**
- All known crashes resolved
- Edge case handling (no force unwraps, no crash on bad data)
- Graceful degradation if services unavailable
- Offline-first architecture verified

### R13.6 — First-Run Experience

**Onboarding Flow (3 screens):**
1. "Write to yourself" — concept introduction
2. "Choose your first delivery date" — date picker tutorial
3. "Seal your first letter" — write and schedule CTA

**Data Migration:**
- Detect first launch
- Show brief welcome
- Don't ask for notifications on first open (ask after first letter)

---

## Technical Approach

### App Store Connect
- New app submission workflow
- Build upload via Xcode Organizer
- App Store Connect metadata entry
- Age rating questionnaire
- Export compliance documentation

### Analytics (Opt-in)
- Anonymous usage stats
- Screen view tracking
- Feature adoption metrics
- Crash and ANR tracking

### Crash Reporting
- Firebase Crashlytics or similar
- Symbolication pipeline
- Alert thresholds configured

---

## UI Final Checklist

| Screen | State | Verified |
|--------|-------|----------|
| Library | Empty | [ ] |
| Library | Drafts | [ ] |
| Library | Scheduled | [ ] |
| Library | Delivered | [ ] |
| Timeline | Empty | [ ] |
| Timeline | Mixed | [ ] |
| Create | Empty | [ ] |
| Create | Writing | [ ] |
| Create | Scheduling | [ ] |
| Letter Detail | Delivered | [ ] |
| Settings | Default | [ ] |
| Menu Bar | All tabs | [ ] |

---

## Out of Scope

- Android app
- Apple Watch app
- Widgets
- Siri shortcuts
- Shortcuts integration
- Home screen quick actions (can add later)
