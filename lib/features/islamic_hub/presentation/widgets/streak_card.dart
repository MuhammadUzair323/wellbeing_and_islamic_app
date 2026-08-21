import 'package:flutter/material.dart';

/// Compact summary card that shows the current active streak and today's
/// completion progress.
class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.streak,
    required this.completedToday,
    required this.totalPrayers,
    this.hasWarning = false,
  });

  final int streak;
  final int completedToday;
  final int totalPrayers;
  final bool hasWarning;

  // Get milestone icons based on streak
  IconData? _getMilestoneIcon() {
    if (streak >= 100) return Icons.emoji_events;
    if (streak >= 30) return Icons.star;
    if (streak >= 7) return Icons.check_circle;
    return null;
  }

  // Get milestone color based on streak
  Color _getMilestoneColor(BuildContext context) {
    if (streak >= 100) return Theme.of(context).colorScheme.secondary;
    if (streak >= 30) return Colors.amber;
    if (streak >= 7) return Colors.green;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    const warningColor = Colors.orange;
    final progress = totalPrayers == 0 ? 0.0 : completedToday / totalPrayers;
    final milestoneIcon = _getMilestoneIcon();
    final milestoneColor = _getMilestoneColor(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Milestone icon if applicable
                if (milestoneIcon != null)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: milestoneColor.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      milestoneIcon,
                      color: milestoneColor,
                      size: 20,
                    ),
                  )
                else
                  const SizedBox(width: 24), // Space for alignment

                const SizedBox(width: 8),

                Icon(
                  Icons.local_fire_department_outlined,
                  color: hasWarning ? warningColor : accent,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '$streak',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasWarning ? warningColor : accent,
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
                backgroundColor: theme.colorScheme.onSurface.withAlpha(20),
                color: hasWarning ? warningColor : accent,
              ),
            ),
            if (hasWarning)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Complete all prayers today to keep your streak!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (milestoneIcon != null && !hasWarning)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      milestoneIcon,
                      color: milestoneColor,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak day streak!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: milestoneColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
