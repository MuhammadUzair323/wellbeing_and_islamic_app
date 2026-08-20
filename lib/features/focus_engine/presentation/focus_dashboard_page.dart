import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:wellbeing_and_islamic_app/core/widgets/feature_card.dart';
import 'package:wellbeing_and_islamic_app/features/focus_engine/domain/focus_session.dart';
import 'package:wellbeing_and_islamic_app/features/focus_engine/trackers/focus_session_tracker.dart';
import 'package:wellbeing_and_islamic_app/features/focus_engine/presentation/focus_session_page.dart';
import 'package:wellbeing_and_islamic_app/features/focus_engine/presentation/widgets/circular_timer.dart';
import 'package:wellbeing_and_islamic_app/features/focus_engine/presentation/widgets/preset_buttons.dart';
import 'package:wellbeing_and_islamic_app/features/focus_engine/presentation/widgets/timer_controls.dart';

class FocusDashboardPage extends StatefulWidget {
  const FocusDashboardPage({super.key});

  @override
  State<FocusDashboardPage> createState() => _FocusDashboardPageState();
}

class _FocusDashboardPageState extends State<FocusDashboardPage>
    with TickerProviderStateMixin {
  TimerState _timerState = TimerState.idle;
  FocusPreset? _selectedPreset = FocusPreset.pomodoro;
  int _customMinutes = 25;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;

  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customController.text = _customMinutes.toString();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _customController.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_timerState != TimerState.running) {
      _lastElapsed = elapsed;
      return;
    }
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    setState(() {
      _remainingSeconds = (_remainingSeconds - delta.inSeconds).clamp(0, _totalSeconds);
      if (_remainingSeconds <= 0) {
        _timerState = TimerState.idle;
        _ticker.stop();
        _saveSession();
        _showCompletionSnackBar();
      }
    });
  }

  Future<void> _saveSession() async {
    final tracker = context.read<FocusSessionTracker>();
    final label = _selectedPreset?.label ?? 'Custom $_customMinutes min';
    final session = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now().subtract(Duration(minutes: _customMinutes)),
      durationMinutes: _customMinutes,
      label: label,
    );
    await tracker.addSession(session);
  }

  void _showCompletionSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🎉 Session Complete! Great job staying focused!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onStart() {
    setState(() {
      _timerState = TimerState.running;
      _lastElapsed = Duration.zero;
    });
    _ticker.start();
  }

  void _onPause() {
    setState(() => _timerState = TimerState.paused);
    _ticker.stop();
  }

  void _onResume() {
    setState(() {
      _timerState = TimerState.running;
      _lastElapsed = Duration.zero;
    });
    _ticker.start();
  }

  void _onCancel() {
    setState(() {
      _timerState = TimerState.idle;
      _remainingSeconds = _totalSeconds;
    });
    _ticker.stop();
  }

  void _onPresetSelected(FocusPreset preset) {
    if (_timerState != TimerState.idle) return;
    setState(() {
      _selectedPreset = preset;
      _customMinutes = preset.minutes;
      _totalSeconds = preset.minutes * 60;
      _remainingSeconds = _totalSeconds;
      _customController.text = _customMinutes.toString();
    });
  }

  void _onCustomChanged(int minutes) {
    if (_timerState != TimerState.idle) return;
    setState(() {
      _selectedPreset = null;
      _customMinutes = minutes;
      _totalSeconds = minutes * 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _navigateToFullTimer,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Focus Timer',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CircularTimer(
                      totalSeconds: _totalSeconds,
                      remainingSeconds: _remainingSeconds,
                      size: 160,
                      strokeWidth: 8,
                      showSeconds: true,
                    ),
                    const SizedBox(height: 16),
                    TimerControls(
                      state: _timerState,
                      onStart: _onStart,
                      onPause: _onPause,
                      onResume: _onResume,
                      onCancel: _onCancel,
                      primaryColor: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    PresetButtons(
                      selectedPreset: _selectedPreset,
                      onPresetSelected: _onPresetSelected,
                      customMinutesController: _customController,
                      onCustomChanged: _onCustomChanged,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Focus Engine',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FeatureCard(
              icon: Icons.timer_outlined,
              title: 'Full Screen Timer',
              subtitle: 'Open immersive focus session with celebrations.',
              onTap: _navigateToFullTimer,
            ),
            const FeatureCard(
              icon: Icons.shield_outlined,
              title: 'Distraction Shield',
              subtitle: 'Apply friction before opening distracting apps.',
            ),
            const FeatureCard(
              icon: Icons.mobile_off_outlined,
              title: 'App Usage Limiter',
              subtitle: 'Set daily caps for high-distraction apps.',
            ),
            const SizedBox(height: 24),
            Consumer<FocusSessionTracker>(
              builder: (context, tracker, child) {
                if (!tracker.isInitialized || tracker.sessions.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Sessions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        TextButton(onPressed: () {}, child: const Text('View All')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tracker.sessions.take(5).length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final session = tracker.sessions[index];
                        return _SessionHistoryTile(session: session);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFullTimer() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FocusSessionPage()),
    );
  }
}

class _SessionHistoryTile extends StatelessWidget {
  const _SessionHistoryTile({required this.session});
  final FocusSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.timer_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${session.formattedDate} at ${session.formattedTime}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            session.durationLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}