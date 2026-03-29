# TomorrowMac — Launch Checklist

## Pre-Launch

### Code & Quality
- [ ] All Theme colors verified (no hardcoded non-token hexes outside dynamic data colors)
- [ ] Dark mode renders correctly across all views
- [ ] Menu bar icon visible on both light and dark menu bars
- [ ] No crash on first launch (cold start)
- [ ] No crash when menu bar popover is opened/closed rapidly
- [ ] All async operations (AI services) have loading/error states

### macOS Specific
- [ ] Sandbox entitlements configured
- [ ] Hardened Runtime enabled for notarization
- [ ] App Sandbox user-selected file access if data persistence is needed
- [ ] App Store Connect team ID configured in project
- [ ] Minimum deployment target set (13.0+)
- [ ] Info.plist: LSUIElement = YES (menu bar app, no Dock icon)
- [ ] App icon at all required sizes (16, 32, 64, 128, 256, 512, 1024)

### Entitlements
- [ ] com.apple.security.app-sandbox = true
- [ ] com.apple.security.network.client = true (if AI features call external APIs)
- [ ] com.apple.security.files.user-selected.read-write = true (if using file storage)

---

## App Store Listing

### Metadata
- [ ] Tagline: "Your tomorrow, planned today."
- [ ] Short description written and localized-ready
- [ ] Full description written
- [ ] Screenshots: 3–5 images at 512×320 (Mac 2x)
- [ ] App icon uploaded at 512×512 and 1024×1024
- [ ] Keywords set (15 max, comma-separated)
- [ ] Category: Productivity
- [ ] Pricing: Free
- [ ] Content rating: 4+

### Screenshots Checklist
- [ ] Screenshot 1: Forecast popup — horizon gradient, tomorrow's items
- [ ] Screenshot 2: Planning view — task entry, priorities
- [ ] Screenshot 3: Evening Reflection — mood check-in
- [ ] Screenshot 4: Couple Planning — shared items
- [ ] No device frames, clean backgrounds
- [ ] All text in English, no lorem ipsum

---

## Build & Sign

### Certificate & Signing
- [ ] Apple Developer account active
- [ ] macOS Development certificate created and installed
- [ ] Developer ID Application certificate for direct distribution
- [ ] Signing identity selected in Xcode: `Developer ID Application (Team ID)`
- [ ] Or: `Sign to Run Locally` for local testing with `CODE_SIGN_IDENTITY="-"`

### Build Verification
```bash
# Local test build (no signing)
cd TomorrowMac
xcodegen generate
xcodebuild -scheme TomorrowMac -configuration Release \
  -destination 'platform=macOS,arch=arm64' \
  build CODE_SIGN_IDENTITY="-"

# App Store build (requires certs)
xcodebuild -scheme TomorrowMac -configuration Release \
  -destination 'platform=macOS,arch=arm64' \
  build \
  CODE_SIGN_IDENTITY="Developer ID Application (XXXXXXXXXX)" \
  CODE_SIGN_STYLE=Manual
```

### Archive & Upload
- [ ] Product → Archive
- [ ] Validate (Organizer → Validate App)
- [ ] Distribute App Store Connect or Direct Distribution
- [ ] If App Store: wait for processing, test with TestFlight internal

---

## Post-Launch

- [ ] Check for any crash reports in Console or App Store Connect
- [ ] Monitor for any dark mode issues reported by users
- [ ] Announce on social/Telegram if applicable
- [ ] Add to TOMORROW's iteration-plans for v1.1 feedback integration

---

## Notes

- **No Dock icon** — LSUIElement = YES. The app lives in the menu bar only.
- **Data persistence** — Currently in-memory. If adding file storage, update Sandbox entitlements.
- **AI Services** — Scheduling and anticipation services require network. Handle offline gracefully.
- **Partner sync** — Currently simulated/local. Real sync is a future feature.
