# Plan for Islamic Calendar Integration

## Objective
Integrate Islamic (Hijri) calendar alongside the Gregorian calendar in the Islamic Hub to show accurate Islamic dates and events.

## Proposed Solution
1. Use the `hijri` package for conversion between Gregorian and Hijri dates.
2. Create a utility class `IslamicCalendar` in `lib/features/islamic_hub/utils/islamic_calendar.dart` that provides:
   - Conversion from Gregorian to Hijri (year, month, day)
   - Names of Hijri months
   - A method to get Islamic events for a given Gregorian date (we can start with a hardcoded list of major events like Ramadan, Eid al-Fitr, Eid al-Adha, Hajj, etc.)
3. Update the `IslamicHubPage`:
   - In the build method, after the date selector, add a new widget that shows:
        * The current Islamic date (in the format: "Day Month Year AH")
        * Any Islamic events for the selected date (if any)
   - Optionally, we can also show the Islamic date in the date selector button alongside the Gregorian date, but for simplicity and to avoid width issues, we'll show it below.

## Implementation Steps
1. Add `hijri: ^2.0.0` to `pubspec.yaml` and run `flutter pub get`.
2. Create the file `lib/features/islamic_hub/utils/islamic_calendar.dart` with the IslamicCalendar class.
3. Update `lib/features/islamic_hub/presentation/islamic_hub_page.dart` to use the IslamicCalendar and display the Islamic date and events.
4. Test the integration.

## Considerations for Ease of Use
- The Islamic date will be shown below the date selector so it's visible without cluttering the date picker button.
- Events will be shown only if there are any for the selected date, to avoid unnecessary information.
- We will use the selected date (which the user can change via the date picker) to show the corresponding Islamic date and events.