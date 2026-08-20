import 'package:flutter/material.dart';

/// Compact summary card that shows the current active streak and today's
/// completion progress.
class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.streak,
    required this.completedToday,
    required this.totalPrayers,
  });

  final int streak;
  final int completedToday;
  final int totalPrayers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final progress = totalPrayers == 0 ? 0.0 : completedToday / totalPrayers;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department_outlined,
                    color: accent, size: 28),
                const SizedBox(width: 8),
                Text(
                  '$streak',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'day streak',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '$completedToday / $totalPrayers today',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.08),
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}