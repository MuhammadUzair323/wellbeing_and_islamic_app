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
  int _completedToday = 0;
  bool _initialized = false;

  /// Current completion state for the active date's prayers.
  Map<Prayer, bool> get activeDatePrayers =>
      Map<Prayer, bool>.unmodifiable(_activeDatePrayers);

  /// Active streak: consecutive days (ending at activeDate) with all 5 prayers done.
  int get streak => _streak;

  /// Number of prayers completed so far on the active date.
  int get completedOnActiveDate => _completedToday;

  /// Total number of prayers tracked per day (5).
  int get totalPrayers => _orderedPrayers.length;

  /// True when every prayer for the active date is checked.
  bool get allCompletedOnActiveDate => _completedToday == totalPrayers;

  /// Whether [loadForDate] has finished at least once.
  bool get isInitialized => _initialized;

  /// Loads the state for [date] (auto-resets for that calendar day) and its streak.
  Future<void> loadForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _formatDate(date);

    _activeDatePrayers = _decodeDay(prefs.getString('$_dayKeyPrefix$dateKey'));
    _completedToday = _countCompleted(_activeDatePrayers);
    _streak = await _computeStreak(prefs, date);
    _activeDate = date;
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
    _completedToday = _countCompleted(_activeDatePrayers);

    await prefs.setString(
        '$_dayKeyPrefix${_formatDate(_activeDate ?? DateTime.now())}',
        _encodeDay(_activeDatePrayers));
    await prefs.setString(_lastActiveDayKey, _formatDate(DateTime.now()));

    _streak = await _computeStreak(prefs, _activeDate ?? DateTime.now());
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Streak calculation
  // ---------------------------------------------------------------------------

  /// Walks backward from [today].
  /// - [today] counts toward the streak only if it is fully complete (otherwise
  ///   an in-progress day does not break the streak, it just isn't counted).
  /// - Every earlier day must be fully complete; the first incomplete day
  ///   breaks the streak.
  Future<int> _computeStreak(
    SharedPreferences prefs,
    DateTime today,
  ) async {
    int count = 0;
    DateTime cursor = today;

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

  int _countCompleted(Map<Prayer, bool> day) {
    return day.values.where((v) => v).length;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
