import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/focus_session.dart';
import '../../../core/streak_tracker.dart';

/// State manager for focus sessions using SharedPreferences.
class FocusSessionTracker extends ChangeNotifier {
  FocusSessionTracker()
      : _streakTracker = StreakTracker(habitId: 'focus_sessions');

  static const String _sessionsKey = 'focus_sessions';

  final StreakTracker _streakTracker;

  List<FocusSession> _sessions = [];
  bool _isInitialized = false;

  List<FocusSession> get sessions => List.unmodifiable(_sessions);
  bool get isInitialized => _isInitialized;

  /// Current focus streak: consecutive days with at least one focus session.
  int get currentStreak => _streakTracker.currentStreak;

  /// Whether the streak is in warning state (yesterday had session, today doesn't).
  bool get isInWarning => _streakTracker.isInWarning;

  /// Initialize the tracker and load saved sessions.
  Future<void> initialize() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionsKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _sessions = decoded
            .map((e) => FocusSession.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime));
      } catch (_) {
        _sessions = [];
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Add a new completed session.
  Future<void> addSession(FocusSession session) async {
    _sessions.insert(0, session);
    await _save();

    // Update streak tracker - mark today as completed since we added a session
    final today = DateTime(
        session.startTime.year, session.startTime.month, session.startTime.day);
    await _streakTracker.setCompleted(today, true);

    notifyListeners();
  }

  /// Clear all session history.
  Future<void> clearAll() async {
    _sessions.clear();
    await _streakTracker.reset(); // Reset streak tracker as well
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsKey, jsonString);
  }
}
