import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../domain/focus_session.dart';
import '../trackers/focus_session_tracker.dart';
import 'widgets/circular_timer.dart';
import 'widgets/preset_buttons.dart';
import 'widgets/timer_controls.dart';
import 'widgets/session_complete_celebration.dart';

/// Focus session page with interactive timer.
class FocusSessionPage extends StatefulWidget {
  const FocusSessionPage({super.key});

  @override
  State<FocusSessionPage> createState() => _FocusSessionPageState();
}

class _FocusSessionPageState extends State<FocusSessionPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Timer state
  TimerState _timerState = TimerState.idle;
  FocusPreset? _selectedPreset = FocusPreset.pomodoro;
  int _customMinutes = 25;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _showCelebration = false;

  // Timer tick
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Custom input
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _customController.text = _customMinutes.toString();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _customController.dispose();
    super.dispose();
  }
@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _timerState == TimerState.running) {
    }
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
      if (_remainingSeconds <= 0) _onSessionComplete();
    });
  }

  void _onSessionComplete() {
    _timerState = TimerState.completed;
    _ticker.stop();
    _saveSession();
    _showCelebration = true;
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
      _remainingSeconds = _totalSeconds;
    });
  }

  void _onCelebrationDismiss() {
    setState(() {
      _showCelebration = false;
      _timerState = TimerState.idle;
      _remainingSeconds = _totalSeconds;
    });
  }
@override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Focus Session'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircularTimer(
                    totalSeconds: _totalSeconds,
                    remainingSeconds: _remainingSeconds,
                    size: 240,
                    strokeWidth: 10,
                  ),
                  const SizedBox(height: 32),
                  TimerControls(
                    state: _timerState,
                    onStart: _onStart,
                    onPause: _onPause,
                    onResume: _onResume,
                    onCancel: _onCancel,
                    primaryColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  PresetButtons(
                    selectedPreset: _selectedPreset,
                    onPresetSelected: _onPresetSelected,
                    customMinutesController: _customController,
                    onCustomChanged: _onCustomChanged,
                  ),
                  const SizedBox(height: 24),
                  _SessionHistoryPreview(),
                ],
              ),
            ),
          ),
        ),
        if (_showCelebration)
          SessionCompleteCelebration(onDismiss: _onCelebrationDismiss),
      ],
    );
  }
}

class _SessionHistoryPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FocusSessionTracker>(
      builder: (context, tracker, child) {
        if (!tracker.isInitialized || tracker.sessions.isEmpty) {
          return const SizedBox.shrink();
        }
        final recentSessions = tracker.sessions.take(3).toList();
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Sessions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentSessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _SessionHistoryTile(session: recentSessions[index]);
              },
            ),
          ],
        );
      },
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