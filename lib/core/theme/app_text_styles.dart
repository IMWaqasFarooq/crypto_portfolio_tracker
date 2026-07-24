import 'package:flutter/material.dart';

/// Semantic text styles for numeric/price display with tabular figures.
abstract final class AppTextStyles {
  static const _tabularFeatures = [FontFeature.tabularFigures()];

  static TextStyle priceLarge(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: _tabularFeatures,
          );

  static TextStyle priceMedium(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: _tabularFeatures,
          );

  static TextStyle priceChange(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: _tabularFeatures,
          );

  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700);

  static TextStyle caption(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
}
