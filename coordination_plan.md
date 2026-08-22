# Coordination Plan — Wellbeing & Islamic App

## Codebase State (as of 2026-08-21)

### Completed Features
- **Focus Engine** — Fully functional:
  - FocusDashboardPage (presets, dopamine academy carousel, cognitive tools, streak, recent sessions)
  - FocusSessionPage (timer with fractional-second ticker, presets, custom timer, session save)
  - FocusSessionTracker (SharedPreferences persistence, streak calculation)
  - Domain: FocusSession, FocusPreset enum
  - Widgets: circular_timer, confetti_particles, preset_buttons, session_complete_celebration, timer_controls
- **Islamic Hub** — Core tracker functional:
  - IslamicHubPage (prayer tracker, streak card, prayer cards)
  - PrayerTracker (SharedPreferences persistence, streak calculation, day-rollover reset)
  - Domain: Prayer enum (Fajr, Dhuhr, Asr, Maghrib, Isha) with labels, icons, time hints
  - Widgets: PrayerCard, StreakCard
- **Architecture** — Dual-edition gate (AppConfig.isIslamicEdition), provider setup, IndexedStack navigation
- **Core** — AppTheme, StorageService (placeholder), FeatureCard widget

### Remaining / Incomplete Areas
- **Islamic Hub — Missing Features** (marked as cards in UI, not yet implemented):
  1. Quran Streak Logging — FeatureCard exists, no implementation
  2. Ayah & Hadith Reminder — FeatureCard exists, no implementation
- **Shared Widgets** — FeatureCard created, but no shared reusable widgets beyond it
- **No API service layer** — StorageService is a placeholder; no network calls
- **No state management for settings/streaks** — All persistence is inline in trackers

---

## Assigned Tasks

### Uzair Muhammad — Focus Engine & Architecture
| Task | Description | Est. Time | Priority |
|------|-------------|-----------|----------|
| U-1 | Add "View All" history page to Focus Engine | 2-3h | Medium |
| U-2 | Implement Focus session export/share (PDF/text) | 2-3h | Low |
| U-3 | Add focus goal settings (target minutes/day) with persistence | 2-3h | Medium |

### Sarmad — Islamic Hub & Missing Features
| Task | Description | Est. Time | Priority |
|------|-------------|-----------|----------|
| S-1 | Implement Quran Streak Logging feature | 3-5h | High |
| S-2 | Implement Ayah & Hadith Reminder (local notifications) | 3-5h | High |
| S-3 | Add Islamic calendar integration (Hijri date display) | 2-3h | Medium | ✅ Completed 2026-08-22 |

### Both — Cross-Cutting Concerns
| Task | Description | Assigned To |
|------|-------------|-------------|
| C-1 | Write unit tests for FocusSessionTracker and PrayerTracker | Both (pair) |
| C-2 | Implement proper error handling / loading states for all async operations | Both (pair) |
| C-3 | Add SharedPreferences keys constant class to avoid key collisions | Both (pair) |

---

## Daily Coordination Log

> Updated by Cline before each task. Both contributors must update this log
> after completing their assigned work for the day.

### 2026-08-22 (Today)

| Time | Contributor | Task | Status |
|------|-------------|------|--------|
| 01:11 | Uzair | chore: add pre-task git sync to clinerules | Completed |
| 01:17 | Sarmad | Added contributors.md with push/pull records | Completed |
| 16:47 | Sarmad | feat: Islamic Hub - Hijri calendar integration & day name fix | Completed |

---

## Rules for Cline

1. **Before every task** — Run `git pull origin main` to sync with the other contributor.
2. **After every task** — Run `flutter analyze lib/` to verify zero errors before pushing.
3. **Before editing any file** — Check this coordination plan and the daily log to confirm:
   - The file is within your assigned scope (Uzair = Focus Engine only, Sarmad = Islamic Hub only).
   - No one else is currently working on the same feature.
4. **Never modify** the other contributor's files or scope without explicit coordination.
5. **Always update** the daily coordination log after completing your assigned task.
6. **If conflicts arise** — Stop work, update the coordination log with details, and coordinate with the other contributor before resolving.