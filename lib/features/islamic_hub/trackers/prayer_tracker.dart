import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing_and_islamic_app/features/islamic_hub/domain/prayer.dart';

/// State manager for the Daily Prayer (Namaz) Tracker.
///
/// Persistence model (SharedPreferences):
///   - `prayer_day_YYYY-MM-DD` : a 5 character string of "0"/"1" flags in the
///     fixed order Fajr, Dhuhr, Asr, Maghrib, Isha.
///   - `prayer_last_active_day` : the last date string the user interacted with.
///
class PrayerTracker extends ChangeNotifier {
  PrayerTracker();

  static const String _dayKeyPrefix = 'prayer_day_';
  static const String _lastActiveDayKey = 'prayer_last_active_day';

  /// Order of the flags inside the persisted day string.
  static const List<Prayer> _orderedPrayers = Prayer.values;

  /// Current completion state for the [activeDate]'s prayers.
  Map<Prayer, bool> _activeDatePrayers = {};

  /// The date whose prayers and streak are currently loaded.
  DateTime? _activeDate;

  int _streak = 0;
  bool _hasWarning = false;
  bool _initialized = false;

  /// Current completion state for the active date's prayers.
  Map<Prayer, bool> get activeDatePrayers =>
      Map<Prayer, bool>.unmodifiable(_activeDatePrayers);

  /// Active streak: consecutive days (ending at activeDate) with all 5 prayers done.
  /// Resets to 0 immediately when any prayer is missed.
  int get streak => _streak;

  /// Whether the streak is in warning state (previous day incomplete).
  /// User must complete all prayers today to avoid streak reset.
  bool get hasWarning => _hasWarning;

  /// Number of prayers completed so far on the active date.
  int get completedOnActiveDate => _completedToday;

  /// Total number of prayers tracked per day (5).
  int get totalPrayers => _orderedPrayers.length;

  /// True when every prayer for the active date is checked.
  bool get allCompletedOnActiveDate => _completedToday == totalPrayers;

  int get _completedToday => _activeDatePrayers.values.where((v) => v).length;

  /// Whether [loadForDate] has finished at least once.
  bool get isInitialized => _initialized;

  /// Loads the state for [date] (auto-resets for that calendar day) and its streak.
  Future<void> loadForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _formatDate(date);

    _activeDatePrayers = _decodeDay(prefs.getString('$_dayKeyPrefix$dateKey'));
    _activeDate = date;
    _updateStreakAndWarning(prefs, date);
    _initialized = true;
    notifyListeners();
  }

  /// Toggles a single prayer for the active date and persists the change.
  Future<void> togglePrayer(Prayer prayer) async {
    if (!_initialized) {
      await loadForDate(DateTime.now());
    }

    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());

    // Defensive: if the day rolled over between load and this call, refresh.
    final storedToday = prefs.getString('$_dayKeyPrefix$today');
    if (storedToday != _encodeDay(_activeDatePrayers) &&
        _formatDate(DateTime.now()) != today) {
      _activeDatePrayers = _decodeDay(storedToday);
    }

    _activeDatePrayers[prayer] = !(_activeDatePrayers[prayer] ?? false);

    await prefs.setString(
        '$_dayKeyPrefix${_formatDate(_activeDate ?? DateTime.now())}',
        _encodeDay(_activeDatePrayers));
    await prefs.setString(_lastActiveDayKey, _formatDate(DateTime.now()));

    _updateStreakAndWarning(prefs, _activeDate ?? DateTime.now());
    notifyListeners();
  }

  /// Updates streak and warning state based on current date and previous day.
  void _updateStreakAndWarning(SharedPreferences prefs, DateTime date) {
    final todayComplete =
        _decodeDay(prefs.getString('$_dayKeyPrefix${_formatDate(date)}'))
            .values
            .every((v) => v);

    final yesterday = date.subtract(const Duration(days: 1));
    final yesterdayComplete =
        _decodeDay(prefs.getString('$_dayKeyPrefix${_formatDate(yesterday)}'))
            .values
            .every((v) => v);

    if (todayComplete) {
      if (yesterdayComplete) {
        // Continuing streak: increment previous day's streak
        final yesterdayStreak = _getStreakForDate(prefs, yesterday);
        _streak = yesterdayStreak + 1;
        _hasWarning = false;
      } else {
        // Recovered from warning: start new streak of 1
        _streak = 1;
        _hasWarning = false;
      }
    } else {
      // Incomplete day: streak broken
      _streak = 0;
      _hasWarning = yesterdayComplete; // Warn only if we had a streak to lose
    }
  }

  /// Gets the streak value for a specific date by computing it.
  int _getStreakForDate(SharedPreferences prefs, DateTime date) {
    // Compute streak ending at [date]
    int count = 0;
    DateTime cursor = date;

    final todayComplete =
        _decodeDay(prefs.getString('$_dayKeyPrefix${_formatDate(cursor)}'))
            .values
            .every((v) => v);
    if (todayComplete) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    // Guard against infinite loops from corrupted storage / clock changes.
    const int maxLookback = 3650;
    while (count < maxLookback) {
      final complete =
          _decodeDay(prefs.getString('$_dayKeyPrefix${_formatDate(cursor)}'))
              .values
              .every((v) => v);
      if (!complete) break;
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return count;
  }

  // ---------------------------------------------------------------------------
  // Encoding helpers
  // ---------------------------------------------------------------------------

  Map<Prayer, bool> _decodeDay(String? raw) {
    final result = <Prayer, bool>{};
    for (var i = 0; i < _orderedPrayers.length; i++) {
      final flag = (raw != null && raw.length > i) ? raw[i] : '0';
      result[_orderedPrayers[i]] = flag == '1';
    }
    return result;
  }

  String _encodeDay(Map<Prayer, bool> day) {
    final buffer = StringBuffer();
    for (final prayer in _orderedPrayers) {
      buffer.write((day[prayer] ?? false) ? '1' : '0');
    }
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
