import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing_and_islamic_app/app_config.dart';
import 'package:wellbeing_and_islamic_app/main.dart';

void main() {
  group('Dual edition navigation', () {
    tearDown(() {
      AppConfig.isIslamicEdition = true;
    });

    testWidgets('shows both tabs in Islamic edition', (tester) async {
      AppConfig.isIslamicEdition = true;

      await tester.pumpWidget(const WellbeingApp());

      expect(find.text('Focus Engine'), findsAtLeastNWidgets(1));
      expect(find.text('Islamic Hub'), findsOneWidget);
    });

    testWidgets('hides Islamic tab in universal edition', (tester) async {
      AppConfig.isIslamicEdition = false;

      await tester.pumpWidget(const WellbeingApp());

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Focus Engine'), findsAtLeastNWidgets(1));
      expect(find.text('Islamic Hub'), findsNothing);
    });
  });
}
