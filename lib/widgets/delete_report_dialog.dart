// lib/widgets/delete_report_dialog.dart
import 'package:flutter/material.dart';
import '../models/report.dart';
import './retro_button.dart' as retro;

class DeleteReportDialog extends StatelessWidget {
  final Report report;
  const DeleteReportDialog({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the theme for styling

    return AlertDialog(
      // *** THE FIX: Dialog now uses themed properties ***
      backgroundColor: theme.dialogTheme.backgroundColor,
      shape: theme.dialogTheme.shape,
      title: Row(
        children: [
          // Use the theme's error color for the warning icon
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Delete Report',
              // *** THE FIX: Title now uses themed font and style ***
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: RichText(
        // *** THE FIX: RichText now uses themed styles for all parts ***
        text: TextSpan(
          // Establish a base style from the theme
          style: theme.textTheme.bodyMedium,
          children: [
            const TextSpan(
              text:
                  'Are you sure you want to permanently delete the report for this ',
            ),
            TextSpan(
              text: report.reportType,
              // Apply bold weight while inheriting the correct font
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '?\n\nThis action cannot be undone.'),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        // *** THE FIX: Buttons inherit their style correctly ***
        retro.RetroButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () => Navigator.of(context).pop(false),
          // Text now inherits font from button
          child: const Text('Cancel'),
        ),
        retro.RetroButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () => Navigator.of(context).pop(true),
          // Text inherits font from button, with color override for emphasis
          child: Text(
            'Delete',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }
}
