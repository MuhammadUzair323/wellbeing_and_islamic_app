import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellbeing_and_islamic_app/app_config.dart';
import 'package:wellbeing_and_islamic_app/core/widgets/feature_card.dart';
import 'package:wellbeing_and_islamic_app/features/islamic_hub/domain/prayer.dart';
import 'package:wellbeing_and_islamic_app/features/islamic_hub/presentation/widgets/prayer_card.dart';
import 'package:wellbeing_and_islamic_app/features/islamic_hub/presentation/widgets/streak_card.dart';
import 'package:wellbeing_and_islamic_app/features/islamic_hub/trackers/prayer_tracker.dart';

class IslamicHubPage extends StatefulWidget {
  const IslamicHubPage({super.key});

  @override
  State<IslamicHubPage> createState() => _IslamicHubPageState();
}

class _IslamicHubPageState extends State<IslamicHubPage> {
  late final PrayerTracker _tracker;
  DateTime _selectedDate = DateTime.now();
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    assert(AppConfig.isIslamicEdition);
    _tracker = PrayerTracker();
    _loadSelectedDate();
    _startMidnightTimer();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  void _loadSelectedDate() {
    _tracker.loadForDate(_selectedDate);
  }

  void _startMidnightTimer() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final duration = midnight.difference(now);
    _midnightTimer = Timer(duration, _onMidnight);
  }

  void _onMidnight() {
    if (mounted) {
      // If user is viewing today, update to the new day at midnight.
      final now = DateTime.now();
      if (_selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day) {
        setState(() {
          _selectedDate = DateTime.now();
        });
        _loadSelectedDate();
      }
      // Schedule next midnight
      _startMidnightTimer();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020), // Reasonable minimum
      lastDate: now, // Restrict to past dates and today only
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate =
            DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      });
      _loadSelectedDate();
    }
  }

  void _goToToday() {
    final now = DateTime.now();
    if (_selectedDate.year != now.year ||
        _selectedDate.month != now.month ||
        _selectedDate.day != now.day) {
      setState(() {
        _selectedDate = DateTime(now.year, now.month, now.day);
      });
      _loadSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrayerTracker>.value(
      value: _tracker,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text(
                'Islamic Hub',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDateSelector(context),
              const SizedBox(height: 16),
              _buildPrayerSection(),
              const SizedBox(height: 24),
              const Text(
                'More',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const FeatureCard(
                icon: Icons.menu_book_outlined,
                title: 'Quran Streak Logging',
                subtitle: 'Record daily recitation and build streaks.',
              ),
              const FeatureCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Ayah & Hadith Reminder',
                subtitle: 'Receive authentic daily spiritual reminders.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final bool isToday = _isSameDay(_selectedDate, DateTime.now());
    final Color labelColor = isToday
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Today button
        ElevatedButton.icon(
          icon: const Icon(Icons.today),
          label: const Text('Today'),
          onPressed: _goToToday,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        const SizedBox(width: 12),
        // Date selector
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text(
            _formatDate(_selectedDate),
            style: TextStyle(color: labelColor),
          ),
          onPressed: () => _selectDate(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        // Visual indicator for past dates
        if (!isToday)
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    // Use intl if available, otherwise fallback to simple format.
    // For simplicity, we use a readable format without extra dependency.
    return '${_getDayName(date.weekday)}, ${date.month}/${date.day}/${date.year}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildPrayerSection() {
    return Consumer<PrayerTracker>(
      builder: (context, tracker, child) {
        if (!tracker.isInitialized) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Prayer Tracker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            StreakCard(
              streak: tracker.streak,
              completedToday: tracker.completedOnActiveDate,
              totalPrayers: tracker.totalPrayers,
              hasWarning: tracker.hasWarning,
            ),
            const SizedBox(height: 12),
            for (final prayer in Prayer.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PrayerCard(
                  prayer: prayer,
                  completed: tracker.activeDatePrayers[prayer] ?? false,
                  onToggle: () => tracker.togglePrayer(prayer),
                ),
              ),
          ],
        );
      },
    );
  }
}
