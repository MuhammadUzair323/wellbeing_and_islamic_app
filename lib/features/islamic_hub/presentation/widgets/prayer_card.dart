import 'package:flutter/material.dart';
import 'package:wellbeing_and_islamic_app/features/islamic_hub/domain/prayer.dart';

/// A single prayer row card with a completion animation.
///
/// When the prayer is toggled to complete, a checkmark bounces in and the
/// card subtly glows with the emerald accent.
class PrayerCard extends StatefulWidget {
  const PrayerCard({
    super.key,
    required this.prayer,
    required this.completed,
    required this.onToggle,
  });

  final Prayer prayer;
  final bool completed;
  final VoidCallback onToggle;

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant PrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.completed && widget.completed) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildIconCircle(accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.prayer.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            widget.completed ? TextDecoration.none : null,
                        color: widget.completed
                            ? accent
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      widget.prayer.timeHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCheckbox(accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconCircle(Color accent) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.completed
            ? accent.withValues(alpha: 0.18)
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
      ),
      child: Icon(
        widget.prayer.icon,
        color: widget.completed ? accent : Theme.of(context).colorScheme.onSurface,
        size: 22,
      ),
    );
  }

  Widget _buildCheckbox(Color accent) {
    if (!widget.completed) {
      return Icon(
        Icons.radio_button_unchecked,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      );
    }
    return ScaleTransition(
      scale: _scale,
      child: Icon(Icons.check_circle, color: accent, size: 28),
    );
  }
}