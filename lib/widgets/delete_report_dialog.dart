// lib/widgets/delete_report_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/report.dart'; // To get the Report model
import './retro_button.dart' as retro; // To use your custom button

class DeleteReportDialog extends StatelessWidget {
  final Report report;

  const DeleteReportDialog({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    // Using AlertDialog provides a standard, responsive layout that
    // works well on both mobile and desktop.
    return AlertDialog(
      backgroundColor: const Color(0xFFE0E0E0),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Delete Report',
              style: GoogleFonts.vt323(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          )
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
          children: [
            const TextSpan(text: 'Are you sure you want to permanently delete the report for this '),
            TextSpan(
              text: report.reportType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '?\n\nThis action cannot be undone.'),
          ],
        ),
      ),
      actions: [
        // 'Cancel' button, which returns `false` when pressed
        retro.RetroButton(
          onTap: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: GoogleFonts.vt323(fontSize: 16),
          ),
        ),
        // 'Delete' button, which returns `true` when pressed
        retro.RetroButton(
          onTap: () => Navigator.of(context).pop(true),
          child: Text(
            'Delete',
            style: GoogleFonts.vt323(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
