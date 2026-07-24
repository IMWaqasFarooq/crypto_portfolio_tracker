import 'package:flutter/material.dart';

import '../bloc/coin_detail_state.dart';

class ChartTypeToggle extends StatelessWidget {
  const ChartTypeToggle({super.key, required this.selected, required this.onChanged});

  final ChartType selected;
  final ValueChanged<ChartType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ChartType>(
      segments: const [
        ButtonSegment(
          value: ChartType.line,
          icon: Icon(Icons.show_chart_rounded),
          label: Text('Line'),
        ),
        ButtonSegment(
          value: ChartType.candles,
          icon: Icon(Icons.candlestick_chart_rounded),
          label: Text('Candles'),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
      showSelectedIcon: false,
    );
  }
}
