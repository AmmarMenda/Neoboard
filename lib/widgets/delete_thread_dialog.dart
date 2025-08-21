// lib/widgets/delete_thread_dialog.dart
import 'package:flutter/material.dart';
import './retro_button.dart' as retro; // Ensure you have this import

class DeleteThreadDialog extends StatelessWidget {
  final int threadId;
  const DeleteThreadDialog({super.key, required this.threadId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the theme for styling

    return AlertDialog(
      // *** THE FIX: Dialog now uses themed properties ***
      backgroundColor: theme.dialogTheme.backgroundColor,
      shape: theme.dialogTheme.shape,
      title: Row(
        children: [
          // Add a warning icon for better UX, using the theme's error color
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            // *** THE FIX: Title uses themed font and style ***
            child: Text('Delete Thread', style: theme.textTheme.titleLarge),
          ),
        ],
      ),
      // *** THE FIX: Content text uses themed font and style ***
      content: Text(
        'Are you sure you want to delete this thread? This action cannot be undone.',
        style: theme.textTheme.bodyMedium,
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        // *** THE FIX: Replaced TextButton with your themed RetroButton ***
        retro.RetroButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'), // Text inherits style from button
        ),
        // *** THE FIX: Replaced ElevatedButton with your themed RetroButton ***
        retro.RetroButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () => Navigator.of(context).pop(true),
          child: Text(
            'Delete',
            // Use the theme's error color for the text to signify a destructive action
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }
}
