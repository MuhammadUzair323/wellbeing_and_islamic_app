import 'package:flutter/material.dart';

class ConfettiParticles extends StatelessWidget {
  const ConfettiParticles({super.key, required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.amber,
      Colors.pink,
    ];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 100,
          child: Stack(
            children: List.generate(12, (index) {
              final progress = (controller.value + index * 0.08) % 1.0;
              final color = colors[index % colors.length];
              return ConfettiParticle(
                progress: progress,
                color: color,
                index: index,
              );
            }),
          ),
        );
      },
    );
  }
}

class ConfettiParticle extends StatelessWidget {
  const ConfettiParticle({
    super.key,
    required this.progress,
    required this.color,
    required this.index,
  });

  final double progress;
  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    final x = (index % 4) * 50.0 + 25.0 + (progress - 0.5) * 30;
    final y = progress * 100;

    return Positioned(
      left: x,
      top: y,
      child: Transform.rotate(
        angle: progress * 6.28,
        child: Opacity(
          opacity: (1.0 - progress).clamp(0.0, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}