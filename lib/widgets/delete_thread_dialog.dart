// lib/widgets/delete_thread_dialog.dart

import 'package:flutter/material.dart';

class DeleteThreadDialog extends StatelessWidget {
  final int threadId;

  const DeleteThreadDialog({super.key, required this.threadId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Thread'),
      content: const Text('Are you sure you want to delete this thread? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
