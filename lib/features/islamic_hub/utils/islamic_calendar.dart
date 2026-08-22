import 'package:hijri/hijri_calendar.dart';

/// Utility class for Islamic (Hijri) calendar operations.
class IslamicCalendar {
  /// Converts a Gregorian [DateTime] to Hijri date components.
  ///
  /// Returns a map with keys: 'year', 'month', 'day'.
  static Map<String, int> gregorianToHijri(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return {
      'year': hijri.hYear,
      'month': hijri.hMonth,
      'day': hijri.hDay,
    };
  }

  /// Returns the name of the Hijri month (1-12).
  static String getHijriMonthName(int month) {
    switch (month) {
      case 1:
        return 'Muharram';
      case 2:
        return 'Safar';
      case 3:
        return 'Rabi\' al-Awwal';
      case 4:
        return 'Rabi\' ath-Thani';
      case 5:
        return 'Jumada al-Ula';
      case 6:
        return 'Jumada al-Akhirah';
      case 7:
        return 'Rajab';
      case 8:
        return 'Sha\'ban';
      case 9:
        return 'Ramadan';
      case 10:
        return 'Shawwal';
      case 11:
        return 'Dhu al-Qi\'dah';
      case 12:
        return 'Dhu al-Hijjah';
      default:
        return 'Unknown';
    }
  }

  /// Returns the day name in Arabic/English format.
  static String getHijriDayName(int weekday) {
    // Dart DateTime.weekday uses 1 = Monday, 7 = Sunday
    switch (weekday) {
      case 1:
        return 'Al-Ithnayn';
      case 2:
        return 'Ath-Thulatha';
      case 3:
        return 'Al-Arbia\'a';
      case 4:
        return 'Al-Khamis';
      case 5:
        return 'Al-Jumu\'ah';
      case 6:
        return 'As-Sabt';
      case 7:
        return 'Al-Ahad';
      default:
        return '';
    }
  }

  /// Checks if a given Gregorian date is during Ramadan.
  static bool isInRamadan(DateTime date) {
    final hijri = gregorianToHijri(date);
    return hijri['month'] == 9; // Ramadan is the 9th month
  }

  /// Checks if a given Gregorian date is Eid al-Fitr (1st of Shawwal).
  static bool isEidAlFitr(DateTime date) {
    final hijri = gregorianToHijri(date);
    return hijri['month'] == 10 && hijri['day'] == 1; // Shawwal 1
  }

  /// Checks if a given Gregorian date is Eid al-Adha (10th of Dhu al-Hijjah).
  static bool isEidAlAdha(DateTime date) {
    final hijri = gregorianToHijri(date);
    return hijri['month'] == 12 && hijri['day'] == 10; // Dhu al-Hijjah 10
  }

  /// Checks if a given Gregorian date is the Day of Arafah (9th of Dhu al-Hijjah).
  static bool isDayOfArafah(DateTime date) {
    final hijri = gregorianToHijri(date);
    return hijri['month'] == 12 && hijri['day'] == 9; // Dhu al-Hijjah 9
  }

  /// Gets a list of Islamic events for a given Gregorian date.
  static List<String> getIslamicEvents(DateTime date) {
    final events = <String>[];

    if (isInRamadan(date)) {
      events.add('Ramadan');
    }

    if (isEidAlFitr(date)) {
      events.add('Eid al-Fitr');
    }

    if (isEidAlAdha(date)) {
      events.add('Eid al-Adha');
    }

    if (isDayOfArafah(date)) {
      events.add('Day of Arafah');
    }

    return events;
  }

  /// Formats a Hijri date as a readable string.
  static String formatHijriDate(DateTime gregorianDate) {
    final hijri = gregorianToHijri(gregorianDate);
    final dayName = getHijriDayName(
        DateTime(gregorianDate.year, gregorianDate.month, gregorianDate.day)
            .weekday);
    final monthName = getHijriMonthName(hijri['month']!);
    return '$dayName, ${hijri['day']} $monthName ${hijri['year']} AH';
  }
}
