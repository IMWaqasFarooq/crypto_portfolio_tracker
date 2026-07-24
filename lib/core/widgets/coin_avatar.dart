import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A coin's logo, cached to disk, falling back to its initial letter on error.
class CoinAvatar extends StatelessWidget {
  const CoinAvatar({
    super.key,
    required this.imageUrl,
    required this.symbol,
    this.size = 40,
  });

  final String imageUrl;
  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, _) => _fallback(scheme),
        errorWidget: (_, _, _) => _fallback(scheme),
      ),
    );
  }

  Widget _fallback(ColorScheme scheme) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: scheme.surfaceContainerHighest,
      child: Text(
        symbol.isNotEmpty ? symbol[0].toUpperCase() : '?',
        style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
