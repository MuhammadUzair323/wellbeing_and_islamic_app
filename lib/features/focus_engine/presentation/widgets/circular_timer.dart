import 'package:flutter/material.dart';

/// A circular countdown timer with smooth progress animation.
class CircularTimer extends StatefulWidget {
  const CircularTimer({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.onComplete,
    this.strokeWidth = 8,
    this.size = 200,
    this.showSeconds = true,
  });

  final int totalSeconds;
  final int remainingSeconds;
  final VoidCallback? onComplete;
  final double strokeWidth;
  final double size;
  final bool showSeconds;

  @override
  State<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends State<CircularTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.totalSeconds),
    );
    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));
    _progressController.value = 1.0 - (widget.remainingSeconds / widget.totalSeconds);
  }

  @override
  void didUpdateWidget(covariant CircularTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingSeconds != widget.remainingSeconds) {
      final progress = widget.remainingSeconds / widget.totalSeconds;
      _progressController.animateTo(
        1.0 - progress,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    if (oldWidget.totalSeconds != widget.totalSeconds) {
      _progressController.duration = Duration(seconds: widget.totalSeconds);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = widget.remainingSeconds ~/ 60;
    final seconds = widget.remainingSeconds % 60;
    final timeString = widget.showSeconds
        ? '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')} min';

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: theme.colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // Progress circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Time text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (!widget.showSeconds && widget.totalSeconds > 60)
                    Text(
                      'Focus Session',
                      style: TextStyle(
                        fontSize: widget.size * 0.08,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}