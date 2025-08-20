// lib/widgets/report_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import './retro_button.dart' as retro;

class ReportDialog extends StatefulWidget {
  final int targetId;
  final String targetType;
  final String baseUrl;
  const ReportDialog({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.baseUrl,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _reasons = [
    'Spam',
    'Hate Speech',
    'Illegal Content',
    'Harassment',
    'Other',
  ];
  late String _selectedReason;

  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedReason = _reasons.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uri = Uri.parse('${widget.baseUrl}report_create.php');
      final response = await http.post(
        uri,
        body: {
          'target_id': widget.targetId.toString(),
          'type': widget.targetType,
          'reason': _selectedReason,
          'description': _descriptionController.text.trim(),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error =
            json.decode(response.body)['error'] ?? 'An unknown error occurred';
        throw Exception(error);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Report Content',
        style: GoogleFonts.vt323(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedReason,
                items: _reasons
                    .map(
                      (reason) =>
                          DropdownMenuItem(value: reason, child: Text(reason)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedReason = value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Please select a reason' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Optional Description',
                  hintText: 'Provide more details here...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        retro.RetroButton(
          onTap: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        retro.RetroButton(
          onTap: _isSubmitting ? null : _submitReport,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
