import 'package:flutter/material.dart';

/// Subtle footer credit shown in support and about sections.
class MadeInKaseseLabel extends StatelessWidget {
  const MadeInKaseseLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Made in Kasese',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        fontSize: 11,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.2,
      ),
      textAlign: TextAlign.center,
    );
  }
}
