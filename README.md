# Focus Shield & Islamic Wellbeing Suite

This repository contains a Flutter Android-first mobile project that supports **two editions** from a single codebase:

- **Universal Focus Shield Edition** (for all users)
- **Islamic Wellbeing Suite Edition** (adds spiritual wellbeing features)

## Dual-Edition Vision

The app ships with one shared focus/productivity core and an optional Islamic spiritual layer.

- When `isIslamicEdition = false`:
  - Universal Focus Shield experience
  - App blocking and usage limiting
  - Doom-scrolling friction timer and distraction shield
- When `isIslamicEdition = true`:
  - Everything in Universal Focus Shield
  - 5 daily prayer (Namaz) tracker
  - Quran streak logging
  - Authentic Ayah/Hadith reminders

## How to Toggle Edition

Edit `lib/app_config.dart`:

```dart
class AppConfig {
  static bool isIslamicEdition = true; // true = Islamic layer ON, false = OFF
}
```

## Folder Structure

```text
lib/
  app_config.dart
  core/
    constants/
    services/
    theme/
    widgets/
  features/
    focus_engine/
      presentation/
    islamic_hub/
      presentation/
android/
  app/
    src/
      main/
        kotlin/com/example/wellbeing_and_islamic_app/
          AccessibilityShieldService.kt
          OverlayShieldService.kt
```

## UI and Theme

- Modern dark foundation using slate/navy: `#0F172A`
- Emerald and indigo accent palette
- Home dashboard with bottom navigation:
  - **Focus Engine** tab is always available
  - **Islamic Hub** tab appears only when Islamic edition is enabled

## Getting Started

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
```
