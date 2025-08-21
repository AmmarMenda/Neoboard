// lib/widgets/retro_panel.dart
import 'package:flutter/material.dart';

enum RetroPanelType { raised, sunken }

class RetroPanel extends StatelessWidget {
  final Widget child;
  final RetroPanelType type;
  final EdgeInsets padding;

  const RetroPanel({
    super.key,
    required this.child,
    this.type = RetroPanelType.raised,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Should be white
        border: Border.all(color: theme.dividerColor, width: 1.0),
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        // Apply padding to the child, not the container, to keep the border tight
        child: Padding(padding: const EdgeInsets.all(12.0), child: child),
      ),
    );
  }
}
