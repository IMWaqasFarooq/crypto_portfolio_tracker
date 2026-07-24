import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Pulsing dot + "Live" label, shown only once a real tick has arrived for this coin.
class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: Tween(begin: 0.3, end: 1.0).animate(_controller),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.bullish, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          'Live',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.bullish,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
