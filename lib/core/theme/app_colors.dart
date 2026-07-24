import 'package:flutter/material.dart';

/// Brand seed colors; the rest of the palette is derived via ColorScheme.fromSeed.
abstract final class AppColors {
  static const seed = Color(0xFF5B5FEF);

  static const bullish = Color(0xFF16C784);
  static const bearish = Color(0xFFEA3943);

  static const chartGridLight = Color(0xFFE4E7EC);
  static const chartGridDark = Color(0xFF2A2E3A);

  static Color priceChangeColor(double change) =>
      change >= 0 ? bullish : bearish;
}
