import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A generic streak tracker that can be used for any habit or activity.
/// It tracks consecutive days of completion and provides warning state.
class StreakTracker extends ChangeNotifier {
  StreakTracker({required this.habitId});

  final String habitId;

  static const String _completedDatesKeyPrefix = 'habit_';
  static const String _completedDatesKeySuffix = '_completed_dates';

  String get _completedDatesKey =>
      '$_completedDatesKeyPrefix$habitId$_completedDatesKeySuffix';

  /// Set of dates (in yyyy-MM-dd format) for which the habit was completed.
  Set<String> _completedDates = {};

  /// Unmodifiable view of completed dates.
  Set<String> get completedDates => Set.unmodifiable(_completedDates);

  /// Loads the completed dates from SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(_completedDatesKey);
    _completedDates = list != null ? list.toSet() : {};
    notifyListeners();
  }

  /// Saves the completed dates to SharedPreferences.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedDatesKey, _completedDates.toList());
  }

  /// Checks if the habit was completed on the given [date].
  bool isCompleted(DateTime date) {
    final String dateKey = _formatDate(date);
    return _completedDates.contains(dateKey);
  }

  /// Sets the completion status for the habit on the given [date].
  /// If [completed] is true, the date is added to the completed set.
  /// If [completed] is false, the date is removed from the completed set.
  Future<void> setCompleted(DateTime date, bool completed) async {
    final String dateKey = _formatDate(date);
    if (completed) {
      _completedDates.add(dateKey);
    } else {
      _completedDates.remove(dateKey);
    }
    await save();
    notifyListeners();
  }

  /// Returns the streak count ending at the given [date].
  /// This is the number of consecutive days (including [date])
  /// where the habit was completed, counting backwards from [date].
  int getStreakEndingAt(DateTime date) {
    int count = 0;
    DateTime cursor = date;
    const int maxLookback = 3650; // 10 years - prevents infinite loops
    while (count < maxLookback) {
      if (isCompleted(cursor)) {
        count++;
      } else {
        break;
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// Returns whether the streak is in warning state for the given [date].
  /// Warning state means: yesterday was completed but today is not completed.
  /// User must complete the habit today to avoid breaking the streak.
  bool getIsInWarning(DateTime date) {
    final yesterday = date.subtract(const Duration(days: 1));
    return !isCompleted(date) && isCompleted(yesterday);
  }

  /// Current streak: consecutive days ending today with habit completed.
  int get currentStreak => getStreakEndingAt(DateTime.now());

  /// Whether the streak is currently in warning state (yesterday completed, today not).
  bool get isInWarning => getIsInWarning(DateTime.now());

  /// Resets the streak tracker, clearing all completion records.
  Future<void> reset() async {
    _completedDates.clear();
    await save();
    notifyListeners();
  }

  /// Formats a [DateTime] as yyyy-MM-dd string.
  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
