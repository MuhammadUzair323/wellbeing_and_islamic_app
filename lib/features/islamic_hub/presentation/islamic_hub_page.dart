import 'package:flutter/material.dart';
import 'package:wellbeing_and_islamic_app/core/widgets/feature_card.dart';

class IslamicHubPage extends StatelessWidget {
  const IslamicHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              'Islamic Hub',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            FeatureCard(
              icon: Icons.access_time,
              title: '5 Daily Prayer Tracker',
              subtitle: 'Track consistency across all Namaz prayers.',
            ),
            FeatureCard(
              icon: Icons.menu_book_outlined,
              title: 'Quran Streak Logging',
              subtitle: 'Record daily recitation and build streaks.',
            ),
            FeatureCard(
              icon: Icons.auto_awesome_outlined,
              title: 'Ayah & Hadith Reminder',
              subtitle: 'Receive authentic daily spiritual reminders.',
            ),
          ],
        ),
      ),
    );
  }
}
