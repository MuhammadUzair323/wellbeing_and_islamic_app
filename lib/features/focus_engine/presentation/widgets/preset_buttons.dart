import 'package:flutter/material.dart';
import '../../domain/focus_session.dart';

/// Preset buttons for quick session duration selection.
class PresetButtons extends StatelessWidget {
  const PresetButtons({
    super.key,
    required this.selectedPreset,
    required this.onPresetSelected,
    this.customMinutesController,
    this.onCustomChanged,
  });

  final FocusPreset? selectedPreset;
  final ValueChanged<FocusPreset> onPresetSelected;
  final TextEditingController? customMinutesController;
  final ValueChanged<int>? onCustomChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: FocusPreset.values.map((preset) {
            final isSelected = selectedPreset == preset;
            return _PresetButton(
              preset: preset,
              isSelected: isSelected,
              onTap: () => onPresetSelected(preset),
            );
          }).toList(),
        ),
        if (customMinutesController != null) ...[
          const SizedBox(height: 16),
          Text(
            'Custom Duration',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: customMinutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Minutes',
                    hintText: 'Enter minutes',
                    suffixText: 'min',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) {
                    final minutes = int.tryParse(value);
                    if (minutes != null && minutes > 0 && minutes <= 480) {
                      onCustomChanged?.call(minutes);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final FocusPreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              preset.icon,
              size: 20,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              preset.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${preset.minutes}m',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}