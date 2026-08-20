# Focus Shield & Islamic Wellbeing Project Blueprint

A unified Flutter & Native Android codebase designed to deploy two distinct standalone applications to the Google Play Store using a single configuration flag (`AppConfig.isIslamicEdition`).

---

## 1. App Editions Overview

### Edition A: Universal Focus Shield (General Audience)
- **App Lock & System Limits:** Hard limits on distracting apps via Android Accessibility Services.
- **Doom-Scrolling Friction:** Full-screen interruption timers on infinite-scroll feeds (Shorts, Reels, TikTok).
- **Adult & Explicit Content Shield:** Real-time text and screen filters to block inappropriate media.
- **Attention Recovery:** Focus sessions, session logs, and daily screen-time analytics.

### Edition B: Islamic Wellbeing & Focus Shield (Spiritual Audience)
- **Includes All Edition A Features:** Full anti-addiction, app-lock, and scroll-friction engine.
- **Spiritual Friction Replacement:** Replaces generic countdown timers with authentic Quranic Ayat, Hadith, and Adhkar during scroll triggers.
- **Haram Content Blocker:** Gaze-shielding filters targeting NSFW and explicit keywords/screens.
- **Authentic Islamic Sources:** Certified offline Quran text and undisputed Sahih Hadith (Sihah Sitta consensus).
- **Daily Fard & Habit Trackers:** 5 Daily Prayers (Namaz) logging, Quran reading streaks, and daily targets.
- **Core Knowledge:** Simple guides on Islamic fundamentals, Faraiz, and verified history.
- **Audience Profiles:** Customized presets for Kids, Adults, Male, and Female users.
- **Home Screen Widgets:** Live Salah countdown and daily Ayah/Hadith widgets.

---

## 2. Vibe-Coding Rules with Cline

1. **One Feature Prompt at a Time:** Let Cline generate or update specific screens/services rather than building the entire app in one run.
2. **Edition Toggle Discipline:** Ensure all Islamic-specific features check `if (AppConfig.isIslamicEdition)` so the core Focus engine remains cleanly separable.
3. **Commit After Every Working Module:**
   - Test locally -> Run `git add .` -> `git commit -m "added [feature]"` -> `git push origin main`.
4. **Sync Routine:** Always run `git pull origin main` before starting a new prompt session on MS Teams.