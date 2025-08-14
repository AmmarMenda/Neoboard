// widgets/report_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/retro_panel.dart';
import '../database/database_helper.dart';
import '../models/report.dart';

class ReportDialog extends StatefulWidget {
  final String reportType; // 'thread' or 'reply'
  final int targetId;
  final String targetTitle; // Thread title or reply preview

  const ReportDialog({
    super.key,
    required this.reportType,
    required this.targetId,
    required this.targetTitle,
  });

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedReason = '';
  bool _isSubmitting = false;

  final List<String> _reportReasons = [
    'Spam or Advertisement',
    'Inappropriate Content',
    'Harassment or Abuse',
    'Copyright Violation',
    'Off-topic Content',
    'Hate Speech',
    'Personal Information',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final report = Report(
        reportType: widget.reportType,
        targetId: widget.targetId,
        reason: _selectedReason,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      await _dbHelper.insertReport(report);
      
      Navigator.of(context).pop(true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting report: $e')),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFE0E0E0),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 2),
      ),
      title: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFC0C0C0),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.report, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'REPORT ${widget.reportType.toUpperCase()}',
              style: GoogleFonts.vt323(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      content: Container(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target info
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reporting ${widget.reportType}:',
                    style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.targetTitle,
                    style: GoogleFonts.vt323(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Reason selection
            Text(
              'Reason for report:',
              style: GoogleFonts.vt323(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  children: _reportReasons.map((reason) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedReason = reason;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedReason == reason 
                                ? const Color(0xFFDDEEFF) 
                                : Colors.white,
                            border: Border.all(
                              color: _selectedReason == reason 
                                  ? Colors.blue 
                                  : Colors.black54, 
                              width: 1
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedReason == reason 
                                    ? Icons.radio_button_checked 
                                    : Icons.radio_button_unchecked,
                                size: 16,
                                color: _selectedReason == reason 
                                    ? Colors.blue 
                                    : Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: GoogleFonts.vt323(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Additional description
            Text(
              'Additional details (optional):',
              style: GoogleFonts.vt323(fontSize: 14),
            ),
            const SizedBox(height: 8),
            RetroPanel(
              type: RetroPanelType.sunken,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Provide additional context...',
                ),
                style: GoogleFonts.vt323(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            
            // Warning message
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEDD),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Text(
                'Please only report content that violates community guidelines. False reports may be ignored.',
                style: GoogleFonts.vt323(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
      actions: [
  retro.RetroButton(
    onTap: _isSubmitting ? () {} : () => Navigator.of(context).pop(false), // Empty function instead of null
    child: Text(
      'CANCEL',
      style: GoogleFonts.vt323(fontSize: 14),
    ),
  ),
  const SizedBox(width: 8),
  retro.RetroButton(
    onTap: _isSubmitting ? () {} : _submitReport, // Empty function instead of null
    child: _isSubmitting
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                'SUBMITTING...',
                style: GoogleFonts.vt323(fontSize: 14),
              ),
            ],
          )
        : Text(
            'SUBMIT REPORT',
            style: GoogleFonts.vt323(fontSize: 14, color: Colors.red),
          ),
  ),
],
    );
  }
}
