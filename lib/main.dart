import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellbeing_and_islamic_app/app_config.dart';
import 'package:wellbeing_and_islamic_app/core/theme/app_theme.dart';
import 'package:wellbeing_and_islamic_app/features/focus_engine/presentation/focus_dashboard_page.dart';
import 'package:wellbeing_and_islamic_app/features/focus_engine/trackers/focus_session_tracker.dart';
import 'package:wellbeing_and_islamic_app/features/islamic_hub/presentation/islamic_hub_page.dart';
import 'package:wellbeing_and_islamic_app/features/islamic_hub/trackers/prayer_tracker.dart';

void main() {
  runApp(const WellbeingApp());
}

class WellbeingApp extends StatelessWidget {
  const WellbeingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FocusSessionTracker()),
        ChangeNotifierProvider(create: (_) => PrayerTracker()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.isIslamicEdition
            ? 'Focus Shield & Islamic Wellbeing Suite'
            : 'Focus Shield',
        theme: AppTheme.darkTheme,
        home: const HomeDashboard(),
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const FocusDashboardPage(),
      if (AppConfig.isIslamicEdition) const IslamicHubPage(),
    ];

    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.shield_moon_outlined),
        label: 'Focus Engine',
      ),
      if (AppConfig.isIslamicEdition)
        const BottomNavigationBarItem(
          icon: Icon(Icons.mosque_outlined),
          label: 'Islamic Hub',
        ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: items,
      ),
    );
  }
}
