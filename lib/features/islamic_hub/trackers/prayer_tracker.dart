import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing_and_islamic_app/core/streak_tracker.dart';
import 'package:wellbeing_and_islamic_app/features/islamic_hub/domain/prayer.dart';

/// State manager for the Daily Prayer (Namaz) Tracker.
///
/// Uses a generic StreakTracker for streak logic while maintaining
/// prayer-specific storage for individual prayer completion states.
class PrayerTracker extends ChangeNotifier {
  PrayerTracker() : _streakTracker = StreakTracker(habitId: 'prayer_tracker');

  final StreakTracker _streakTracker;

  static const String _dayKeyPrefix = 'prayer_day_';
  static const String _lastActiveDayKey = 'prayer_last_active_day';

  /// Order of the flags inside the persisted day string.
  static const List<Prayer> _orderedPrayers = Prayer.values;

  /// Current completion state for the [activeDate]'s prayers.
  Map<Prayer, bool> _activeDatePrayers = {};

  /// The date whose prayers and streak are currently loaded.
  DateTime? _activeDate;

  bool _initialized = false;

  /// Current completion state for the active date's prayers.
  Map<Prayer, bool> get activeDatePrayers =>
      Map<Prayer, bool>.unmodifiable(_activeDatePrayers);

  /// Active streak: consecutive days (ending at activeDate) with all 5 prayers done.
  /// Resets to 0 immediately when any prayer is missed.
  int get streak => _streakTracker.currentStreak;

  /// Whether the streak is in warning state (previous day incomplete).
  /// User must complete all prayers today to avoid streak reset.
  bool get hasWarning => _streakTracker.isInWarning;

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

    // Update streak tracker based on whether all prayers were completed today
    final todayComplete = _activeDatePrayers.values.every((v) => v);
    await _streakTracker.setCompleted(date, todayComplete);

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

    // Update streak tracker based on whether all prayers are completed today
    final todayComplete = _activeDatePrayers.values.every((v) => v);
    await _streakTracker.setCompleted(
        _activeDate ?? DateTime.now(), todayComplete);

    notifyListeners();
  }

  /// Formats a [DateTime] as yyyy-MM-dd string.
  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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
}
