import 'package:flutter/material.dart';
import 'package:wellbeing_and_islamic_app/core/widgets/feature_card.dart';

class FocusDashboardPage extends StatelessWidget {
  const FocusDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              'Focus Engine',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            FeatureCard(
              icon: Icons.timer_outlined,
              title: 'Session Timer',
              subtitle: 'Run deep-focus sessions with structured breaks.',
            ),
            FeatureCard(
              icon: Icons.shield_outlined,
              title: 'Distraction Shield',
              subtitle: 'Apply friction before opening distracting apps.',
            ),
            FeatureCard(
              icon: Icons.mobile_off_outlined,
              title: 'App Usage Limiter',
              subtitle: 'Set daily caps for high-distraction apps.',
            ),
          ],
        ),
      ),
    );
  }
}
