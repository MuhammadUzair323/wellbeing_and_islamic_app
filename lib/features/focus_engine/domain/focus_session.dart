import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Represents a single focus session record.
class FocusSession {
  FocusSession({
    required this.id,
    required this.startTime,
    required this.durationMinutes,
    required this.label,
  });

  final String id;
  final DateTime startTime;
  final int durationMinutes;
  final String label;

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  String get formattedDate => DateFormat('MMM d, yyyy').format(startTime);
  String get formattedTime => DateFormat('h:mm a').format(startTime);
  String get durationLabel => '$durationMinutes min';

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'label': label,
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        durationMinutes: json['durationMinutes'] as int,
        label: json['label'] as String,
      );
}

/// Preset durations for quick selection.
enum FocusPreset {
  pomodoro(25, 'Pomodoro', Icons.timer_outlined),
  deepWork(50, 'Deep Work', Icons.work_outline),
  shortBreak(5, 'Short Break', Icons.coffee_outlined);

  const FocusPreset(this.minutes, this.label, this.icon);
  final int minutes;
  final String label;
  final IconData icon;
}