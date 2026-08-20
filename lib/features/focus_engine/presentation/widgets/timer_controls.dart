import 'package:flutter/material.dart';

/// Timer state enum.
enum TimerState {
  idle,
  running,
  paused,
  completed,
}

/// Timer controls widget with Start, Pause, Resume, and Cancel/Reset buttons.
class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.primaryColor,
    this.isLoading = false,
  });

  final TimerState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final Color primaryColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cancel/Reset button
        if (state != TimerState.idle && state != TimerState.completed)
          _ControlButton(
            icon: Icons.close_rounded,
            label: 'Cancel',
            color: theme.colorScheme.error,
            onPressed: onCancel,
            isSecondary: true,
          ),
        if (state == TimerState.idle || state == TimerState.completed)
          const SizedBox(width: 56), // Placeholder for alignment

        const SizedBox(width: 16),

        // Main action button (Start/Pause/Resume)
        _ControlButton(
          icon: _mainIcon,
          label: _mainLabel,
          color: _mainColor,
          onPressed: _mainAction,
          isLoading: isLoading,
        ),

        const SizedBox(width: 16),

        // Secondary button (Pause when running, hidden otherwise)
        if (state == TimerState.running)
          _ControlButton(
            icon: Icons.pause_rounded,
            label: 'Pause',
            color: theme.colorScheme.secondary,
            onPressed: onPause,
            isSecondary: true,
          )
        else if (state == TimerState.paused)
          _ControlButton(
            icon: Icons.refresh_rounded,
            label: 'Reset',
            color: theme.colorScheme.outline,
            onPressed: onCancel,
            isSecondary: true,
          )
        else
          const SizedBox(width: 56), // Placeholder for alignment
      ],
    );
  }

  IconData get _mainIcon {
    switch (state) {
      case TimerState.idle:
      case TimerState.completed:
        return Icons.play_arrow_rounded;
      case TimerState.running:
        return Icons.stop_rounded;
      case TimerState.paused:
        return Icons.play_arrow_rounded;
    }
  }

  String get _mainLabel {
    switch (state) {
      case TimerState.idle:
      case TimerState.completed:
        return 'Start';
      case TimerState.running:
        return 'Stop';
      case TimerState.paused:
        return 'Resume';
    }
  }

  Color get _mainColor {
    switch (state) {
      case TimerState.idle:
      case TimerState.completed:
        return primaryColor;
      case TimerState.running:
        return Colors.red;
      case TimerState.paused:
        return Colors.orange;
    }
  }

  VoidCallback get _mainAction {
    switch (state) {
      case TimerState.idle:
      case TimerState.completed:
        return onStart;
      case TimerState.running:
        return onCancel;
      case TimerState.paused:
        return onResume;
    }
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isSecondary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isSecondary
        ? color.withValues(alpha: 0.15)
        : color;
    final foregroundColor = isSecondary ? color : theme.colorScheme.onPrimary;

    return SizedBox(
      width: 56,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: isSecondary ? 0 : 4,
          shadowColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isSecondary
                ? BorderSide(color: color.withValues(alpha: 0.5), width: 1.5)
                : BorderSide.none,
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Icon(icon, size: 24),
      ),
    );
  }
}