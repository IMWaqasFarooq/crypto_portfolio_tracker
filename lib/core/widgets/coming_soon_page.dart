import 'package:flutter/material.dart';

import 'empty_state_view.dart';

/// Placeholder tab body used until its real feature page replaces it.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyStateView(icon: icon, title: '$title coming soon'),
    );
  }
}
