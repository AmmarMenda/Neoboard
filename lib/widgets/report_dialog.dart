// lib/widgets/report_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';
import 'retro_button.dart' as retro;

class ReportDialog extends StatefulWidget {
  final String reportType; // 'thread' or 'reply'
  final int targetId;
  final String? targetTitle;

  const ReportDialog({
    super.key,
    required this.reportType,
    required this.targetId,
    this.targetTitle,
  });

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _reasons = [
    'Spam',
    'Offensive content',
    'Personal information',
    'Illegal content',
    'Other',
  ];

  String? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
    });

    // TODO: Implement API call to submit report via API
    // Example:
    // await apiProvider.submitReport(widget.reportType, widget.targetId, _selectedReason, _descriptionController.text);

    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    if (mounted) {
      setState(() {
        _submitting = false;
      });
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = MediaQuery.of(context).size.width * 0.8;
    final double maxDialogWidth = 400;
    final bool isWide = dialogWidth > maxDialogWidth;

    return Dialog(
      backgroundColor: const Color(0xFFE0E0E0),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isWide ? maxDialogWidth : dialogWidth,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Report ${widget.reportType.capitalize()}',
              style: GoogleFonts.vt323(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.targetTitle != null) ...[
              const SizedBox(height: 10),
              Text(
                widget.targetTitle!,
                style: GoogleFonts.vt323(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                    items: _reasons
                        .map(
                          (reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedReason = val),
                    validator: (val) =>
                        val == null ? 'Please select a reason' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Additional details (optional)',
                      border: OutlineInputBorder(),
                    ),
                    style: GoogleFonts.vt323(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: retro.RetroButton(
                      onTap: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
