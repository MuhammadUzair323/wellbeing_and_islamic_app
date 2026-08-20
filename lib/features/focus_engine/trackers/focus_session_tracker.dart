import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/focus_session.dart';

/// State manager for focus sessions using SharedPreferences.
class FocusSessionTracker extends ChangeNotifier {
  FocusSessionTracker();

  static const String _sessionsKey = 'focus_sessions';

  List<FocusSession> _sessions = [];
  bool _isInitialized = false;

  List<FocusSession> get sessions => List.unmodifiable(_sessions);
  bool get isInitialized => _isInitialized;

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
    notifyListeners();
  }

  /// Clear all session history.
  Future<void> clearAll() async {
    _sessions.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsKey, jsonString);
  }
}