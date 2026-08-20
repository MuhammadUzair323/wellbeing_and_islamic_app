import 'package:flutter/material.dart';

/// The five obligatory daily prayers (Salah / Namaz).
enum Prayer {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

/// Metadata for each [Prayer] kept in a single, modular extension.
extension PrayerX on Prayer {
  /// Human readable name.
  String get label {
    switch (this) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
    }
  }

  /// Short descriptive time-of-day hint shown on the card.
  String get timeHint {
    switch (this) {
      case Prayer.fajr:
        return 'Pre-dawn';
      case Prayer.dhuhr:
        return 'Noon';
      case Prayer.asr:
        return 'Afternoon';
      case Prayer.maghrib:
        return 'Sunset';
      case Prayer.isha:
        return 'Night';
    }
  }

  /// Material icon used on the prayer card.
  IconData get icon {
    switch (this) {
      case Prayer.fajr:
        return Icons.brightness_3_outlined;
      case Prayer.dhuhr:
        return Icons.light_mode_outlined;
      case Prayer.asr:
        return Icons.wb_sunny_outlined;
      case Prayer.maghrib:
        return Icons.brightness_5_outlined;
      case Prayer.isha:
        return Icons.nights_stay_outlined;
    }
  }
}