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
  @override
  void initState() {
    super.initState();
    // Edition guard: the whole hub only renders when Islamic edition is on.
    assert(AppConfig.isIslamicEdition);
    // Initialize tracker via Provider; load is async so we don't await here.
    context.read<PrayerTracker>().load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Islamic Hub',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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
    );
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
              completedToday: tracker.completedToday,
              totalPrayers: tracker.totalPrayers,
            ),
            const SizedBox(height: 12),
            for (final prayer in Prayer.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PrayerCard(
                  prayer: prayer,
                  completed: tracker.todayPrayers[prayer] ?? false,
                  onToggle: () => tracker.togglePrayer(prayer),
                ),
              ),
          ],
        );
      },
    );
  }
}
