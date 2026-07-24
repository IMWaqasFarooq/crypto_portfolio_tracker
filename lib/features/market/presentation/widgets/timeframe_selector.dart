import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class TimeframeOption {
  const TimeframeOption(this.label, this.days);
  final String label;
  final int days;
}

const timeframeOptions = [
  TimeframeOption('24H', 1),
  TimeframeOption('7D', 7),
  TimeframeOption('30D', 30),
  TimeframeOption('1Y', 365),
];

class TimeframeSelector extends StatelessWidget {
  const TimeframeSelector({super.key, required this.selectedDays, required this.onChanged});

  final int selectedDays;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in timeframeOptions)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: ChoiceChip(
              label: Text(option.label),
              selected: selectedDays == option.days,
              onSelected: (_) => onChanged(option.days),
            ),
          ),
      ],
    );
  }
}
