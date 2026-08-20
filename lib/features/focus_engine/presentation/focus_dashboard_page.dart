import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/focus_session.dart';
import '../trackers/focus_session_tracker.dart';
import 'focus_session_page.dart';

class FocusDashboardPage extends StatefulWidget {
  const FocusDashboardPage({super.key});

  @override
  State<FocusDashboardPage> createState() => _FocusDashboardPageState();
}

class _FocusDashboardPageState extends State<FocusDashboardPage> {
  FocusPreset _selectedPreset = FocusPreset.pomodoro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 20),
              _buildQuickLaunchCard(theme),
              const SizedBox(height: 28),
              _buildDopamineAcademyCarousel(theme),
              const SizedBox(height: 28),
              _buildCognitiveToolGrid(theme),
              const SizedBox(height: 28),
              _buildRecentSessions(theme),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  int _calculateStreak(List<FocusSession> sessions) {
    if (sessions.isEmpty) return 0;
    int streak = 0;
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 365; i++) {
      final hasSession = sessions.any((s) {
        return s.startTime.year == checkDate.year &&
            s.startTime.month == checkDate.month &&
            s.startTime.day == checkDate.day;
      });

      if (hasSession) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (i == 0) {
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Widget _buildHeader(ThemeData theme) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Consumer<FocusSessionTracker>(
      builder: (context, tracker, _) {
        final todaySessions = tracker.sessions.where((s) {
          return s.startTime.year == now.year &&
              s.startTime.month == now.month &&
              s.startTime.day == now.day;
        }).toList();

        final todayMinutes = todaySessions.fold<int>(
          0,
          (sum, s) => sum + s.durationMinutes,
        );
        final currentStreak = _calculateStreak(tracker.sessions);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to focus today?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatChip(
                          icon: Icons.local_fire_department,
                          label: '$currentStreak day streak',
                          theme: theme,
                        ),
                        _buildStatChip(
                          icon: Icons.access_time,
                          label: '$todayMinutes min today',
                          theme: theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLaunchCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Start Session',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Select duration and begin',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToFullTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text(
                  'Start',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetPill(FocusPreset.pomodoro, '25m Pomodoro', theme),
              _buildPresetPill(FocusPreset.deepWork, '50m Deep Work', theme),
              _buildPresetPill(FocusPreset.reset, '15m Reset', theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetPill(
    FocusPreset preset,
    String label,
    ThemeData theme,
  ) {
    final isSelected = _selectedPreset == preset;
    return GestureDetector(
      onTap: () => setState(() => _selectedPreset = preset),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? theme.colorScheme.primary : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDopamineAcademyCarousel(ThemeData theme) {
    const techniques = [
      _Technique(
        title: 'The 20-Second Friction Rule',
        description:
            'Adding 20s of physical friction to compulsive impulses resets dopamine triggers.',
        category: 'Behavioral Friction',
        icon: Icons.timer_outlined,
      ),
      _Technique(
        title: 'The 3-Minute Resistance Curve',
        description:
            'Initial task friction drops by 80% once you push past the first 3 minutes.',
        category: 'Neuroscience',
        icon: Icons.psychology_outlined,
      ),
      _Technique(
        title: 'Ultradian Work Cycles',
        description:
            'Focus peaks in 90-minute waves. Pair deep output with deliberate downtime.',
        category: 'Deep Work',
        icon: Icons.waves_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.school_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Dopamine & Focus Academy',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: techniques.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = techniques[index];
              return Container(
                width: 270,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCognitiveToolGrid(ThemeData theme) {
    final tools = [
      const _Tool(
        title: 'Distraction Shield',
        subtitle: 'Block compulsive apps',
        icon: Icons.security_outlined,
        color: Color(0xFF0D9488),
      ),
      const _Tool(
        title: 'App Usage Limiter',
        subtitle: 'Set daily hard caps',
        icon: Icons.app_blocking_outlined,
        color: Color(0xFF10B981),
      ),
      const _Tool(
        title: 'Emergency Reset',
        subtitle: 'Box Breathing (4-4-4-4)',
        icon: Icons.air_outlined,
        color: Color(0xFF06B6D4),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.grid_view_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Cognitive Tools',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${tool.title} - Ready in next module'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: tool.color.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(tool.icon, color: tool.color, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tool.title,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (tool.subtitle != null)
                            Text(
                              tool.subtitle!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentSessions(ThemeData theme) {
    return Consumer<FocusSessionTracker>(
      builder: (context, tracker, _) {
        if (!tracker.isInitialized || tracker.sessions.isEmpty) {
          return const SizedBox.shrink();
        }

        final sessions = tracker.sessions.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...sessions.map(
              (s) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${s.formattedDate} • ${s.formattedTime}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      s.durationLabel,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToFullTimer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FocusSessionPage(),
      ),
    );
  }
}

class _Technique {
  const _Technique({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
  });

  final String title;
  final String description;
  final String category;
  final IconData icon;
}

class _Tool {
  const _Tool({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
}