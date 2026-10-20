# KeepCat · 不困猫

KeepCat is a lightweight macOS menu bar utility that keeps a Mac awake during
downloads, builds, AI tasks, and other long-running work.

## Current MVP

- Start or stop an awake session from the menu bar.
- Let the display sleep while the Mac continues working, or keep the display on.
- End sessions after 15 minutes, 30 minutes, 1 hour, 2 hours, 4 hours, or never.
- Stop automatically at a configurable low-battery threshold.
- Optionally run only while connected to power.
- Launch at login.
- English and Simplified Chinese localization.

Closing a MacBook lid is governed by additional macOS and hardware rules and is
not part of the first release.

## Requirements

- macOS 14 or later
- Swift 6.2 or later
- Full Xcode is recommended for signing, archiving, and App Store distribution

## Run locally

```bash
swift run KeepCat
```

## Build an app bundle

```bash
chmod +x scripts/package-app.sh
scripts/package-app.sh
open dist/KeepCat.app
```

The packaging script creates an ad-hoc signed app for local development. App
Store or Developer ID distribution should use the Apple Developer signing
identity and a standard Xcode archive.

## Architecture

- `SleepAssertionController` owns the IOKit power-management assertion.
- `AppState` coordinates session timing, preferences, and power policies.
- SwiftUI provides the menu bar panel and Settings window.
